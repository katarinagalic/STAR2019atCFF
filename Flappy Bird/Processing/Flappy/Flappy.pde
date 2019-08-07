
import processing.serial.*;

Serial sp;                               // Serial port object
Walls walls;

int lf = 10;                             // ASCII linefeed
String delimiter = " ";                  // String delimiter
String str;                              // Serial output string
float[] data = new float[6];             // Serial data buffer
public float press;                               // Paddle position
int paddleX = 500;
float paddleY = height/2;
int paddleWidth = 10;
int paddleHeight = 60;
float scale = 10;

float gravity = .981;                    //Gravity constant
float paddlevy = 0; 
int screenvalue = 0;


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
  //fullScreen();
  
  sp = new Serial(this, "COM6", 115200); // Initialize the serial port to the current processing instance ("this") with an address of "COM4" (change this) and a baud rate of 115200 BPS
  sp.clear();                            // Clear/flush the serial port
  str = sp.readStringUntil(lf);          // Read and discard any malformed data in the serial buffer
  str = null;                            // Clear the string
  
  walls = new Walls();
}

void draw() {
  background(230);                       // Render the background at 90% gray (clears the window)
  while (sp.available() > 0) {           // Read while the serial port contains data
    str = sp.readStringUntil(lf);        // Write the string 
  }
  
  try {
  if (str != null) {                     // If the string is not null ...
    data = float(split(str, delimiter)); // Separate the string by the delimiter
    press = data[5];                     // Save the position as the fourth element of the array
    applyForces(-0.25*(.5*press-gravity));
    paddle(paddleY);                     // Draw the paddle in the center of the screen 
    keepInScreen();
    walls.wallAdder();
    wallHandler();
    walls.printScore();
  }
  } catch (ArrayIndexOutOfBoundsException e) {
    println("Caught it");
    draw();
  }
}

 //<>//
// Paddle methods
void paddle(float press) {
  fill(233,175,68);
  noStroke();
  rectMode(CENTER);
  rect(paddleX, press, paddleWidth, paddleHeight, 5);
}

void applyForces(float num) {
  paddlevy += num;
  paddleY += paddlevy;
}

//Keeps ball in the screen bounds
void keepInScreen() {
 if ((paddleY+(paddleHeight/2) > height) || (paddleY-(paddleHeight/2) < 0)){ 
    exit();
  }
}
void wallHandler() {
  for (int i = 0; i < walls.walls.size(); i++) {
    walls.wallRemover(i);
    walls.wallMover(i);
    walls.wallDrawer(i);
    walls.watchWallCollision(i, paddleX, paddleY, paddleWidth, paddleHeight);
  }
}

void scoreTracker() {
  
}
