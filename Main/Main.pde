// Code for the cts game controller
import processing.core.PApplet;

//var definitions

public int screenval = 0;

Flappy flappy;
Whack whack;
public Serial sp;
public int lf = 10;                             // ASCII linefeed
public String delimiter = " ";                  // String delimiter
public String str;
public float[] data = new float[6];


void setup() {
  size(1000,500);
  //fullScreen();

  sp = new Serial(this, "COM6", 115200); // Initialize the serial port to the current processing instance ("this") with an address of "COM4" (change this) and a baud rate of 115200 BPS
  sp.clear();                            // Clear/flush the serial port
  str = sp.readStringUntil(10);          // Read and discard any malformed data in the serial buffer
  str = null;

  flappy = new Flappy();
  whack = new Whack();
}

/* Draw block, screen logic */

void draw() {
  background(127);
  if (screenval == 0){
    startScreen();
  } else if (screenval == 1) {
    game1();
  } else if (screenval == 2) {
    game2();
  } else if (screenval == 3) {
    game3();
  } else if (screenval == 4) {
    gameover();
  }
}

/* Screens */

void startScreen() {
  background(230, 0, 66);
  textAlign(CENTER);
  textSize(26);

  text("Pick a game to start", width/2, height/2);
  rectMode(CENTER);
  rect(width*0.25, (height*0.65), 100, 100, 7); //100
  rectMode(CENTER);
  rect(width*0.5, (height*0.65), 100, 100, 7);  //350
  rectMode(CENTER);
  rect(width*0.75, (height*0.65), 100, 100, 7); //600

}

void game1() {
  // game screen 1
}
void game2() {
  // game screen 2
  //flappy.setup();
  flappy.draw();
}
void game3() {
  // game screen 3
  //whack.setup();
  whack.draw();
}
void gameover() {
  // game over screen
}

/* Input options */

public void mousePressed() {
  if (screenval==0) {
    if (((mouseX > width*0.25-150)&&(mouseX< width*0.25+150))&&((mouseY>height*0.65-50)&&(mouseY<height*0.65+50))){
      screenval=1;
    }
    else if (((mouseX > width*0.5-150)&&(mouseX< width*0.5+150))&&((mouseY>height*0.65-50)&&(mouseY<height*0.65+50))){
      screenval=2;
    }
    else if (((mouseX > width*0.75-150)&&(mouseX< width*0.75+150))&&((mouseY>height*0.65-50)&&(mouseY<height*0.65+50))){
      screenval=3;
    }
  }
  else if (screenval==1){
    //game 1 mouse inputs
  }
  else if (screenval==2){
    //game 2 mouse inputs
  }
  else if (screenval==3){
    //game 3 mouse inputs
  }
  else if (screenval==4){
    //game over mouse inputs
  }
}
