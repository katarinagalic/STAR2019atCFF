import processing.core.PApplet;
import processing.serial.*;

public class Whack {

//variables
//PApplet game3;
//Serial sp;                               // Serial port object
Mole moles;
Timer timer;

//int lf = 10;                             // ASCII linefeed
//String delimiter = " ";                  // String delimiter
//String str;                              // Serial output string
//float[] data = new float[6];             // Serial data buffer
public float press;                               // Paddle position
float scale = 10;
int waitFrames = 100;
int score = 0;

int moleHeight = 100;
int moleWidth = 70;
int xCoord[] = {45, 115, 185, 255, 325, 395, 465, 535, 605, 675, 745, 815, 885};
int yCoord[] = {350, 250, 150, 50};

Mole[] moleslist = new Mole[13];

Whack( //PApplet wm
) {
  //game3 = wm; 
}
//functions 

void setup() {
  size(1000, 500); // Set the processing window size
  
  //sp = new Serial(game3, "COM6", 115200); // Initialize the serial port to the current processing instance ("this") with an address of "COM4" (change this) and a baud rate of 115200 BPS
  //sp.clear();                            // Clear/flush the serial port
  //str = sp.readStringUntil(lf);          // Read and discard any malformed data in the serial buffer
  //str = null;                            // Clear the string
  
  //creating moles
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
  
  //initiating the timer
  timer = new Timer(45);
  timer.startTimer();
}

void draw() {
  background(230); 
  
  while (sp.available() > 0) {           // Read while the serial port contains data
    str = sp.readStringUntil(lf);        // Write the string 
  }
  
  //if (str != null) {                     // If the string is not null ...
    data = float(split(str, delimiter)); // Separate the string by the delimiter
    press = data[4];                     // Get button number 
  if (frameCount % waitFrames == 0) {
    waitFrames--;
    int rand = (int) random (0,13);
  moleslist[rand].state = !moleslist[rand].state; }
  
  drawMoles();
  checkHit();
  endGame();
  printTime();
  
//}
}

void drawMoles() {
  for (int i=0; i<moleslist.length; i++){
    moleslist[i].drawMole();
  }
}

//void mousePressed() {
//  int rand = (int) random (0,13);
//  moleslist[rand].state = !moleslist[rand].state;
  
//}

void checkHit() {
    if ((press>1.2) && (press<1.4)) {
      moleslist[0].state = false; 
    }
}

void endGame() {
if (timer.isFinished() == true) {
  screenval=0;
  //sp.clear();
  //sp.stop();
}
} 

void printTime() {
  textAlign(CENTER);
  fill(0);
  textSize(18); 
  text("Time left: "+ str(timer.totalTime - timer.passedTime), 65, 30);
}
}
