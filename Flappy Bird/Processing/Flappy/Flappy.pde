import processing.serial.*;

Serial sp;                               // Serial port object
Walls walls;

int lf = 10;                             // ASCII linefeed
String delimiter = " ";                  // String delimiter
String str;                              // Serial output string
float[] data = new float[6];             // Serial data buffer
public float press;                      // Paddle pressure
int paddleX = 500;
float paddleY = height/2;
int paddleWidth = 10;
int paddleHeight = 60;
float scale = 10;

float gravity = .981;                    // Gravity constant
float paddlevy = 0;                      // Paddle velocity  in Y
public int screenvalue = 0;              // Screen value; 0 for game and changed to 1 for game over


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
  size(1000, 500);                       // Set the processing window size
  
  sp = new Serial(this, "COM4", 115200); // Initialize the serial port to the current processing instance ("this") with an address of "COM4" (change this) and a baud rate of 115200 BPS
  sp.clear();                            // Clear/flush the serial port
  str = sp.readStringUntil(lf);          // Read and discard any malformed data in the serial buffer
  str = null;                            // Clear the string
  
  walls = new Walls();                   // instantiating the wall object
}

void draw() {
  background(230);                       // Render the background at 90% gray (clears the window)
  if (screenvalue == 0) {                // if the current screen is game screen
  while (sp.available() > 0) {           // Read while the serial port contains data
    str = sp.readStringUntil(lf);        // Write the string 
  }
  
  try {
  if (str != null) {                                                             // If the string is not null ...
    data = float(split(str, delimiter));                                         // Separate the string by the delimiter
    press = data[5];                                                             // Save the position as the fourth element of the array
    applyForces(-0.25*(.1*press-gravity));                                       // allows paddle to move 
    drawpaddle(paddleY);                                                         // Draw the paddle in the center of the screen 
    keepInScreen();                                                              // keeps paddle in screen
    walls.wallAdder();                                                           // adds walls as bird moves
    wallHandler();
    walls.printScore();                                                          // prints score
  }
  } catch (ArrayIndexOutOfBoundsException e) {
    println("Caught it");                                                        // prints caught it when flappy falls
    draw();
  }
  } else if (screenvalue == 1) {                                                 // game over screen
    textAlign(CENTER);
    fill(233,175,68);
    textSize(30); 
    text("Game over", width/2, height/2-100);
    text("Score: "+str(walls.score), width/2, height/2-50);
    fill(0);
    rectMode(CENTER);
    rect(width/2, height/2, 200, 80);
    fill(233,175,68);
    textAlign(CENTER);
    text("Exit game", width/2, height/2);
    exitGame();
    }
}
    
 //<>//
// Paddle methods, drawing and applying forces to go up and down
void drawpaddle(float press) {                                                   // draws paddle from center 
  fill(233,175,68);
  noStroke();                           
  rectMode(CENTER);
  rect(paddleX, press, paddleWidth, paddleHeight, 5);
}

void applyForces(float num) {                                                    // changes paddle Y position based on paddle velocity
  paddlevy += num;
  paddleY += paddlevy;
}

//Keeps ball in the screen bounds
void keepInScreen() {
 if ((paddleY+(paddleHeight/2) > height) || (paddleY-(paddleHeight/2) < 0)){     // if paddle leaves screen 
    screenvalue=1;                                                                      // exit program
  }
}
void wallHandler() {                                                             
  for (int i = 0; i < walls.walls.size(); i++) {                                 
    walls.wallRemover(i);                                                        //removes walls 
    walls.wallMover(i);                                                          //moves walls horizontally at in -xdirection
    walls.wallDrawer(i);                                                         //draws walls from top and bottom of different lengths
    walls.watchWallCollision(i, paddleX, paddleY, paddleWidth, paddleHeight);    //watches for collision between Flappy and any walls; exits screen
  }
}
// exits the game if exit button is pressed
void exitGame() {
  if ((mouseX > (width/2-100)) && (mouseX < (width/2+100)) && 
  (mouseY > (height/2-40)) && (mouseY < (height/2+40)) && mousePressed) {
    exit();
  }}
  
