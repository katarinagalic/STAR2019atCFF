
import processing.serial.*;

Serial sp;                               // Serial port object
Moles moles;

int lf = 10;                             // ASCII linefeed
String delimiter = " ";                  // String delimiter
String str;                              // Serial output string
float[] data = new float[6];             // Serial data buffer
public float press;                               // Paddle position
float scale = 10;



/*
 * Serial data from CTS slave device
 * Baud rate: 
 
 * Message format: "{tau_A} {tau_B} {highpass_A} {highpass_B} {position} {pressure}\n"
 *                  data[0] data[1]   data[2]      data[3]      data[4]   data[5]
 *    Space-delimited ASCII string Where all values are returned as floats (0.2f)
 */

/*
 * Window axes
 *     0     x->        1000
 *   0 +------------------+
 *     |                  |
 *  y  |                  |
 *  |  |                  |
 *  v  |                  |
 *     |                  |
 * 500 +------------------+
 */

void setup() {
  size(1000, 500); // Set the processing window size
  
  //sp = new Serial(this, "COM6", 115200); // Initialize the serial port to the current processing instance ("this") with an address of "COM4" (change this) and a baud rate of 115200 BPS
  //sp.clear();                            // Clear/flush the serial port
  //str = sp.readStringUntil(lf);          // Read and discard any malformed data in the serial buffer
  //str = null;                            // Clear the string
  moles = new Moles();
}

void draw() {
  background(230); 
  //rect(45,350,70,100);
  //rect(115,250,70,100);
  //rect(185,150,70,100);
  //rect(255,50,70,100);
  //rect(325,150,70,100);
  //rect(395,250,70,100);
  //rect(465,350,70,100);
  //rect(535,250,70,100);
  //rect(605,150,70,100);
  //rect(675,50,70,100);
  //rect(745,150,70,100);
  //rect(815,250,70,100);
  //rect(885,350,70,100);
  
  //while (sp.available() > 0) {           // Read while the serial port contains data
  //  str = sp.readStringUntil(lf);        // Write the string 
  //}
  
  //if (str != null) {                     // If the string is not null ...
  //  data = float(split(str, delimiter)); // Separate the string by the delimiter
  //  press = data[5];                     // Save the position as the fourth element of the array
    moles.drawMoles();
//}
} //<>//
