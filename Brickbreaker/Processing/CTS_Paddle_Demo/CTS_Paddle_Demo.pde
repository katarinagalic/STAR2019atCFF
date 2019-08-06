
import processing.serial.*;

Serial sp;                               // Serial port object
Ball myBall;
Block block;

int lf = 10;                             // ASCII linefeed
String delimiter = " ";                  // String delimiter
String str;                              // Serial output string
float[] data = new float[6];             // Serial data buffer
float pos;                               // Paddle position
float paddleX;
int paddleY = 400;
int paddleWidth = 100;
int paddleHeight = 10;
float scale = 200.0;

public int p = 0;

Block[] blocks;

/*
 * Serial data from CTS slave device
 * Baud rate: 
 
 * Message format: "{tau_A} {tau_B} {highpass_A} {highpass_B} {position} {pressure}\n"
 *                  data[0] data[1]   data[2]      data[3]      data[4]   data[5]
 *    Space-delimited ASCII string Where all values are returned as floats (0.2f)
 */

void setup() {
  size(1000, 500); // Set the processing window size
  //fullScreen();
  
  sp = new Serial(this, "COM6", 115200); // Initialize the serial port to the current processing instance ("this") with an address of "COM4" (change this) and a baud rate of 115200 BPS
  sp.clear();                            // Clear/flush the serial port
  str = sp.readStringUntil(lf);          // Read and discard any malformed data in the serial buffer
  str = null; // Clear the string

  myBall = new Ball();
  myBall.ballX=width/2;
  myBall.ballY=height/2;
  
  int numBlocks=50;
  blocks = new Block[numBlocks];
  
}

void draw() {
  background(230);                       // Render the background at 90% gray (clears the window)
  while (sp.available() > 0) {           // Read while the serial port contains data
    str = sp.readStringUntil(lf);        // Write the string 
  }
  
  blockarray();
  if (str != null) {                     // If the string is not null ...
    data = float(split(str, delimiter)); // Separate the string by the delimiter
    pos = data[4];                       // Save the position as the fourth element of the array
    paddle((-scale*pos+width/2));        // Draw the paddle in the center of the screen (500) and scale the position by -100 pixels
    drawarray();
    myBall.drawBall();                   // Draws the ball 
    myBall.applyGravity();               // Applies gravity to the ball
    gameover();                          // Calls the gameover function
    myBall.keepInScreen();               // Bounces the ball off the game window edges
    paddleCollision();                   // Calls the collision function
    blockCollision();
  }
}

// Method to draw the paddle
void paddle(float pos) {
  fill(255,0,125);
  rectMode(CENTER);
  rect(paddleX=pos, paddleY, paddleWidth, paddleHeight, 5); // Draw a 100 x 10 pixel rectangle with a 5-pixel round at x = pos-50 and y = 400
}

void blockarray(){
  while (p<blocks.length){
    for (int i = 0; i<10; i++) {
      for (int j=0; j<5; j++) {
          blocks[p] = new Block(i*100,j*20, 100,20);
          p+=1;
      }
    }
  }
} //<>//

void drawarray(){
  for (int i=0; i<blocks.length; i++){
    blocks[i].drawBlock();
  }
}

// Checks for collision between ball and paddle, makes ball bounce off paddle and deals with horizontal variance in bouncing
void paddleCollision(){ 
  if ((myBall.ballX+(myBall.ballSize/2) > paddleX-(paddleWidth/2)) && (myBall.ballX-(myBall.ballSize/2) < paddleX+(paddleWidth/2))) {
      if (dist(myBall.ballX, myBall.ballY, myBall.ballX, paddleY)<=(myBall.ballSize/2)) {
        myBall.makeBounceBottom(paddleY);
        myBall.ballvx = (myBall.ballX - paddleX)/10;
      }
    }
}

//Checks for collision between ball and individual blocks, makes ball bounce off block bottom and deals with horizontal variance in bouncing
void blockCollision() {
  for (int i=0; i<blocks.length; i++){
    if (blocks[i].blockVisibility){
      if ((myBall.ballX+(myBall.ballSize/2) > blocks[i].blockX-(blocks[i].blockWidth)) && (myBall.ballX-(myBall.ballSize/2) < blocks[i].blockX+(blocks[i].blockWidth))) {
          if (dist(myBall.ballX, myBall.ballY, myBall.ballX, blocks[i].blockY)<=(myBall.ballSize/2)) {
            blocks[i].blockVisibility = false;
            myBall.makeBounceTop(blocks[i].blockY+20);
            myBall.ballvx = (myBall.ballX - blocks[i].blockX)/10;
        }
      }
    }
  }
}

//Returns the ball back to top if it hits the bottom
void gameover() {
  if (myBall.ballY + myBall.ballSize/2 > 498){
    myBall.ballX=width/2;
    myBall.ballY=height/5;
    myBall.ballvy = 0;
    myBall.ballvx = 1;
  }
}
