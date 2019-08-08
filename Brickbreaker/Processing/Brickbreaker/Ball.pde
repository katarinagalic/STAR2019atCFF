//Ball class that implements a bouncing ball

class Ball {

  int ballX, ballY;                        //Center coordinates
  int ballSize = 30;                       //Ball diameter
  int ballColor = color(0);                //Ball color

  float gravity = 0.65;                    //Gravity constant
  float ballvy = 0;                        //Vertical speed
  float ballvx = 3;                        //Horizontal speed 

  boolean ballVisibility = true;
  //Constructor
  Ball() {
    
  }
  
  //Draws ball in window
  void drawBall() {
    if (ballVisibility == true) {
    fill(ballColor);
    ellipse(ballX, ballY, ballSize, ballSize); 
    }
  }

  //Applies gravity
  void applyGravity() {
    ballvy += 0.3*gravity;
    ballY += ballvy;
    ballX += ballvx;
  }
  
  //Bounce functions
  void makeBounceBottom(int surface) {
    ballY = surface-(ballSize/2);
    ballvy*=-1;
  }
  void makeBounceTop(int surface) {
    ballY = surface+(ballSize/2);
    ballvy*=-1;
  }
  void makeBounceLeft(int surface) {  
    ballX = surface+(ballSize/2);
    ballvx*=-1;
  } 
  void makeBounceRight(int surface) {
    ballX = surface-(ballSize/2);
    ballvx*=-1; 
  }

  //Keeps ball in the screen bounds
  void keepInScreen() {
    // ball hits floor
    if (ballY+(ballSize/2) > height) { 
      makeBounceBottom(height);
    }
    // ball hits ceiling
    if (ballY-(ballSize/2) < 0) {
      makeBounceTop(0);
    }
    //ball hits right side
    if (ballX+(ballSize/2) > width) {
      makeBounceRight(width);
    }
    // ball hits left side
    if (ballX-(ballSize/2) < 0) {
      makeBounceLeft(0);
    }
    
}
}
