/*
 *                       Teensy 2.0 (Atmega 32U4)
 *                        _______
 *                    ___|       |___
 *               Gnd | o |       | o | Vcc
 * (interior) SS PB0 | o |_______| o | PF0 ADC0       (interior)
 *  PE6     SCLK PB1 | o           o | PF1 ADC1          AREF
 *  AIN0    MOSI PB2 | o           o | PF4 ADC4
 *  INT6    MISO PB3 | o o       o o | PF5 ADC5
 * RTS OC1C OC0A PB7 | o   _____   o | PF6 ADC6
 * OC0B SCL INT0 PD0 | o  |     |  o | PF7 ADC7
 *      SDA INT1 PD1 | o  |     |  o | PB6 ADC13 OC1B OC4B
 *     RXD1 INT2 PD2 | o  |_____|  o | PB5 ADC12 OC1A OC4B
 *     TXD1 INT3 PD3 | o           o | PB4 ADC11
 *    !OC4A OC3A PC6 | o    [   ]  o | PD7 ADC10 T0 OC4D
 *     OC4A ICP3 PC7 | o o o o o o o | PD6 ADC9  T1 !OC4D (LED on PD6)
 *                   |___|_|_|_|_|___|
 *                       | | | | |
 *            CTS XCK1 PD5 | | | PD4 ADC8 ICP1
 *                       Vcc | RST
 *                          GND
 * 
 *                        _______
 *                    ___|       |___
 *               Gnd | o |       | o | Vcc
 * (interior)      0 | o |_______| o | 21 A0        (interior)
 *     24          1 | o           o | 20 A1           AREF
 *                 2 | o           o | 19 A2
 *                 3 | o o       o o | 18 A3
 *        PWM      4 | o   _____   o | 17 A4
 *        PWM INT0 5 | o  |     |  o | 16 A5
 *            INT1 6 | o  |     |  o | 15 A6  PWM
 *         RX INT2 7 | o  |_____|  o | 14 A7  PWM
 *         TX INT3 8 | o           o | 13 A8
 *        PWM      9 | o    [   ]  o | 12 A9  PWM
 *        PWM     10 | o o o o o o o | 11 A10 (LED on 11)
 *                   |___|_|_|_|_|___|
 *                       | | | | |
 *                      23 | | | 22, A11
 *                       Vcc | RST
 *                          GND
 */


/*
 *  Clock Divisor Table
 * 0 | 0 | 0 No clock source
 * 0 | 0 | 1 clk/1
 * 0 | 1 | 0 clk/8
 * 0 | 1 | 1 clk/64
 * 1 | 0 | 0 clk/256
 * 1 | 0 | 1 clk/1024
 * 1 | 1 | 0 
 * 1 | 1 | 1 
 * 
 */


/*
 * Cyclical Buffer Operation
 * 
 * We define a buffer with n elements numbered from 0 to n-1.
 * The buffer elements contain readings taken sequentially.
 * We define an index to track which element is being written/overwritten.
 * We also define a buffer sum that keeps track of the sum of all elements within the buffer.
 * When a reading is taken, the value is placed in an element and the write index is incremented.
 * The removed element is subtracted from the buffer sum and the reading is added.
 * When the index reaches the end of the buffer, the index wraps around to zero.
 * 
 *      buffer, index = x          (n-4) (n-2)
 *  0  1  2  3  4  5  6     x   (n-5) (n-3) (n-1)
 * [#][#][#][#][#][#][#]...[#]...[#][#][#][#][#]
 * 
 * 
 * buffer_sum = buffer_sum + reading
 * buffer_sum = buffer_sum - buffer[x]
 * buffer[x] = reading;
 * 
 * Caveats:
 * 1. Alays add to the buffer sum before subtracting, especially if the buffer sum is an unsigned quantity.
 * 2. Avoid adding and subtracting quantities in the same line to avoid order of operations conflicts and variable wrap-around.
 * 
 */


/*
 * Exponential Moving Average
 * 
 * S_t = Y_1,               t = 1
 *       a*Y_t + (1-a)*S_t, t > 1
 * 
 * a ~= 0: Favor prior readings over newer readings
 * a ~= 1: Favor newer readings over prior readings
 * 
 */

#include <Wire.h>


// Length of the cyclical buffer used for the low-pass filter reading
// Higher values produce a "smoother" output but slow responsiveness to changes in touch
#define CYC_BUFF_LEN 128 

#define MHz_TO_MICROS 16 // Scaling clock ticks in MHz to microseconds
#define DT_TO_DELAY 1000 // 1000 Microseconds per 1 Hz
#define SAMPLE_RATE 100  // Hz, approximate
#define CUTOFF 5         // Hz

// A (red) and B (blue) electrode LED pins
#define REDLED 9    // Pin 9
#define BLUELED 10  // Pin 10

// I2C slave address
uint8_t address = 3;

volatile uint8_t state = 0;     // State of timer interrupt (intital condition)

uint8_t idx = 0;                // Index of the cyclical buffer
uint32_t buffer_overflow = 0;   // Number of times the cyclical buffer has overflowed

// Wait "n" number of milliseconds to begin analyzing readings
// This gives the buffer time to flush dummy (zero) readings and populate with real data
uint8_t start_after = 2000;

uint16_t cyc_buffer[CYC_BUFF_LEN][2] = { { 0, }, { 0, } }; // Definition of the cyclical buffer
uint32_t cyc_buffer_sum[2] = { 0, }; // Definition of the buffer sum

uint16_t tau_A = 0; // Signal A rise time
uint16_t tau_B = 0; // Signal B rise time

float smoothreadings[2][2] = { { 0, 0 }, { 0, 0 } };
float highpass[2][2] = { { 0, 0 }, { 0, 0 } };

// Filter gains
float dt = 1.0/SAMPLE_RATE;     // Time change
float RC = 1.0/(2.0*PI*CUTOFF); // "RC" constant of system
float alpha = RC/(RC + dt);     // High pass filter gain

// A and B electrode signal reading
float sigA = 0.0;
float sigB = 0.0;

float sigAScaled = 1.0;
float sigBScaled = 1.0;

uint8_t ledA = 0;
uint8_t ledB = 0;

float minReading[] = { 1000.0, 1000.0 };
float maxReading[] = { 0.0, 0.0 };

uint8_t minLEDBrightness[] = { 0, 0 };
uint8_t maxLEDBrightness[] = { 63, 63 };

uint32_t delay_time = (uint32_t)(DT_TO_DELAY*dt);

// Empirically observed base rise time
float baseA = 18.0;
float baseB = 18.0;

float aMax = 0.5;
float a = aMax;

float th = 0.15;

float tsigA = 0.0;
float tsigB = 0.0;

uint8_t isTouched  = 0;

String delim = " ";


struct CTSDataStruct{
    float raw[2];
    float highpass[2];
    float x;
    float pressure;
} dataStruct;

union CTSDataStructUnion {
    CTSDataStruct ds;
    uint8_t u8[24];
} dataStructUnion;


void setup() {
    // Start the serial port
    Serial.begin(115200);

    // Start the I2C port with the specified address
    Wire.begin(address);

    // Set the I2C request for data callback function
    Wire.onRequest(wireCallback);
    
    
    // Enable the built-in LED
    pinMode(LED_BUILTIN, OUTPUT);
    
    // Set the PWM-enabled LED pins
    pinMode(REDLED, ledA);
    pinMode(BLUELED, ledB);
    
    TCCR1A = 0; // Clear initial settings (use 16 bit timing)
    TCCR1B = (1 << WGM12) | (1 << CS10); // Clear timer on Compare and set prescaler to 1
    
    // Output Compare Register reset ticks
    OCR1A = 8191; // 8191 clock ticks, about 1 ms
    OCR1B = 5000;
    
    TCNT1 = 0; // Reset timer counter 1
    
    TIMSK1 |= (1 << OCIE1A) | (1 << OCIE1B); // (1 << TOIE1) | Enable TIMER1 overflow interrupt and output compare interrupt
        
    DDRD &= ~((1 << DDD2) | (1 << DDD3)); // Set input on pins 7 and 8 (Signal in)
    //DDRD &= ~((1 << DDD0) | (1 << DDD1)); // Set input on pins 5 and 6 (Signal in)
    // I2C uses PD0 and PD1
    DDRB |= (1 << DDB6) | (1 << DDB5);    // Set output on pins 14 and 15 (Signal out)
    DDRD |= (1 << DDD5) | (1 << DDD6); // Set output on pins 1 and 2 (ISR out)
    DDRF |= (1 << DDF0); // Set output on pin 21 (Trigger out)

    
    EICRA |= (1 << ISC30) | (1 << ISC20); // Fire interrupts on a change in external input
    //EICRA |= (1 << ISC10) | (1 << ISC00) | (1 << ISC11) | (1 << ISC01); // Fire interrupts on a rising edge external input
    EIMSK |= (1 << INT3) | (1 << INT2); // Enable external interrupts
    
    sei(); // Set enable interrupts
    
    // Wait for a specified time to fill and cycle the data buffer
    delay(start_after);
    
    // Turn on the built-in LED
    digitalWrite(LED_BUILTIN, HIGH);
}

/*
 * TODO:
 * self-calibration
 * 
 * The sensor subtracts an offset reading from the A and B signals when there is no touch.
 * The sensor is allowed to adjust the baseline offset when
 * 
 * Map the exponential filter alpha between 0 and 1
 * 
 */

void loop() {
    // Delay the loop
    delay(delay_time);
    
    // Get the windowed moving average
    sigA = (float)cyc_buffer_sum[0]/(MHz_TO_MICROS*CYC_BUFF_LEN);
    sigB = (float)cyc_buffer_sum[1]/(MHz_TO_MICROS*CYC_BUFF_LEN);
    
    // Set the average to the smoothing window
    smoothreadings[0][0] = sigA;
    smoothreadings[1][0] = sigB;
    
    // Find the highpass filter value
    highpass[0][0] = alpha*(highpass[0][1] + smoothreadings[0][0] - smoothreadings[0][1]);
    highpass[1][0] = alpha*(highpass[1][1] + smoothreadings[1][0] - smoothreadings[1][1]);
    
    // If the 
    if ((highpass[0][0] > th || highpass[1][0] > th) && isTouched == 0) {
        a = 0; // Freeze the baseline measurement
        tsigA = sigA; // Set the threshold of signal A
        tsigB = sigB; // Set the threshold of signal B
        isTouched = 1; // Enable the touch flag
    }

    if ((sigA < tsigA || sigB < tsigB) && isTouched == 1) {
        a = 0.5; // Enable the baseline measurement
        isTouched = 0; // Enable the touch flag
    }
    
    //a = (highpass[0][0] < -th || highpass[1][0] < -th)? aMax : 0;

    //a = 0.5;
    
    /*
    a = highpass[0][0] + highpass[0][1];
    a = (a < 0.0)? 0.0 : a;
    a = (a > aMax)? aMax : a;
    */
    
    // Get the baseline
    //baseA = a*sigA + (1.0 - a)*baseA;
    //baseB = a*sigB + (1.0 - a)*baseB;
    
    // 
    sigAScaled = sigA - baseA;
    sigBScaled = sigB - baseB;
    
    // 
    sigAScaled = (sigAScaled < 1.0)? 1.0 : sigAScaled;
    sigBScaled = (sigBScaled < 1.0)? 1.0 : sigBScaled;
    
    // 
    ledA = (uint8_t)map(sigAScaled, 1.0, 60.0, 0, 127);
    ledB = (uint8_t)map(sigBScaled, 1.0, 60.0, 0, 127);
    
    //updateReadingLimits();
    
    // 
    highpass[0][1] = highpass[0][0];
    highpass[1][1] = highpass[1][0];
    smoothreadings[0][1] = smoothreadings[0][0];
    smoothreadings[1][1] = smoothreadings[1][0];
    
    // 
    analogWrite(REDLED, ledA);
    analogWrite(BLUELED, ledB);
    

    dataStruct.raw[0] = sigA;
    dataStruct.raw[1] = sigB;
    dataStruct.highpass[0] = highpass[0][0];
    dataStruct.highpass[1] = highpass[1][0];
    dataStruct.x = log(sigAScaled) - log(sigBScaled);
    dataStruct.pressure = (sigAScaled + sigBScaled)/2.0 - 1.0;

    dataStructUnion.ds = dataStruct;
    
    Serial.print(dataStruct.raw[0]);
    Serial.print(delim);
    Serial.print(dataStruct.raw[1]);
    Serial.print(delim);
    Serial.print(dataStruct.highpass[0]);
    Serial.print(delim);
    Serial.print(dataStruct.highpass[1]);
    Serial.print(delim);
    Serial.print(dataStruct.x);
    Serial.print(delim);
    Serial.println(dataStruct.pressure);
}

void wireCallback() {
    Wire.write(dataStructUnion.u8, 24);
}




void updateReadingLimits() {    
    //ledA = map(sigA, minReading[0], maxReading[0], 0.0, 1.0);
    //if ledA < 0
    //ledB = map(sigB, minReading[1], maxReading[1], 0.0, 1.0);
}

/*
 * External Interrupt INT0 (Digital pin 5)
 */
ISR(INT2_vect) {
    tau_A = TCNT1;        // Record the signal A rise time
    PORTD |= (1 << DDD5); // Fire the interrupt trigger
}

/*
 * External Interrupt INT1 (Digital pin 6)
 */
ISR(INT3_vect) {
    tau_B = TCNT1;        // Record the signal B rise time
    PORTD |= (1 << DDD6); // Fire the interrupt trigger
}

/*
 * TIMER1 Compare channel A vector
 */
ISR(TIMER1_COMPA_vect) {
    
    // Invert digital pins 9 and 10
    PORTB ^= (1 << DDB6) | (1 << DDB5);

    // Put the tau_A and tau_B readings into the cyclical buffer (add before subtracting)
    cyc_buffer_sum[0] += tau_A;
    cyc_buffer_sum[0] -= cyc_buffer[idx][0];
    cyc_buffer_sum[1] += tau_B;
    cyc_buffer_sum[1] -= cyc_buffer[idx][1];
    cyc_buffer[idx][0] = tau_A;
    cyc_buffer[idx][1] = tau_B;
    
    idx++; // Increment the buffer index and reset to zero if it reaches the end
    if (idx >= CYC_BUFF_LEN) {
        idx = 0;
        buffer_overflow++;
    }
}

/*
 * TIMER1 Compare channel B vector
 */
ISR(TIMER1_COMPB_vect) {
    // Do nothing
}

