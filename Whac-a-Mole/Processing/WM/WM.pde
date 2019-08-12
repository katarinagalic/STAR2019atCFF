
import processing.serial.*;

Serial sp;                               // Serial port object
Mole moles;

int lf = 10;                             // ASCII linefeed
String delimiter = " ";                  // String delimiter
String str;                              // Serial output string
float[] data = new float[6];             // Serial data buffer
public float press;                               // Paddle position
float scale = 10;

int moleHeight = 100;
int moleWidth = 70;
int xCoord[] = {45, 115, 185, 255, 325, 395, 465, 535, 605, 675, 745, 815, 885};
int yCoord[] = {350, 250, 150, 50};

Mole[] moleslist = new Mole[13];


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
  
  sp = new Serial(this, "COM6", 115200); // Initialize the serial port to the current processing instance ("this") with an address of "COM4" (change this) and a baud rate of 115200 BPS
  sp.clear();                            // Clear/flush the serial port
  str = sp.readStringUntil(lf);          // Read and discard any malformed data in the serial buffer
  str = null;                            // Clear the string
   moleslist[0] = new Mole(xCoord[0], yCoord[0], moleWidth, moleHeight); 
   moleslist[1] = new Mole(xCoord[1], yCoord[1], moleWidth, moleHeight);
   moleslist[2] = new Mole(xCoord[2], yCoord[2], moleWidth, moleHeight);
   moleslist[3] = new Mole(xCoord[3], yCoord[3], moleWidth, moleHeight);
   moleslist[4] = new Mole(xCoord[4], yCoord[2], moleWidth, moleHeight);
   moleslist[5] = new Mole(xCoord[5], yCoord[1], moleWidth, moleHeight);
   moleslist[6] = new Mole(xCoord[6], yCoord[0], moleWidth, moleHeight);
   moleslist[7] = new Mole(xCoord[7], yCoord[1], moleWidth, moleHeight);
   moleslist[8] = new Mole(xCoord[8], yCoord[2], moleWidth, moleHeight);
   moleslist[9] = new Mole(xCoord[9], yCoord[3], moleWidth, moleHeight);
   moleslist[10] = new Mole(xCoord[10], yCoord[2], moleWidth, moleHeight);
   moleslist[11] = new Mole(xCoord[11], yCoord[1], moleWidth, moleHeight);
   moleslist[12] = new Mole(xCoord[12], yCoord[0], moleWidth, moleHeight);

}

void draw() {
  background(230); 
  
  while (sp.available() > 0) {           // Read while the serial port contains data
    str = sp.readStringUntil(lf);        // Write the string 
  }
  
  if (str != null) {                     // If the string is not null ...
    data = float(split(str, delimiter)); // Separate the string by the delimiter
    press = data[5];                     // Save the position as the fourth element of the array
    drawMoles();
}
} //<>//

void drawMoles() {
  for (int i=0; i<moleslist.length; i++){
    moleslist[i].drawMole();
  }
}

void mousePressed() {
  int rand = (int) random (0,13);
  moleslist[rand].state = !moleslist[rand].state;
  
}