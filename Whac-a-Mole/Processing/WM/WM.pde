import processing.sound.*; //<>//
import processing.serial.*;
import java.io.FileWriter;
import java.io.BufferedWriter;

//variables

Serial sp;                               // Serial port object
Mole moles;                              // Moles object
Timer timer;                             // Timer object
SoundFile tone;                          // tone for the whack sound
PrintWriter out;                         // writer to the txt file storing the scores
BufferedReader reader;                   // reader for the txt file storing the scores
String currentHigh;                      // stores the previous high score

int lf = 10;                             // ASCII linefeed
String delimiter = " ";                  // String delimiter
String str;                              // Serial output string
float[] data = new float[6];             // Serial data buffer
public float press;                      // Paddle position        
int waitFrames = 100;                    // delay for activating moles
int score = 0;                           // score variable / mole hit count
float filter;                            // determines if a press event occured
float avg;                               // average value of readings
float sum;                               // sum of readings
String line;                             // tracking the score reader
String newline;                          // tracking the scpre reader


//mole variables
int moleHeight = 80;
int moleWidth = 80;
int xCoord[] = {190, 280, 370, 460, 550, 640, 730};
int yCoord[] = {100,210,320};

//list of mole objects
Mole[] moleslist = new Mole[7];


void setup() {
  size(1000, 500); // Set the processing window size
  
  sp = new Serial(this, "COM6", 115200); // Initialize the serial port to the current processing instance ("this") with an address of "COM4" (change this) and a baud rate of 115200 BPS
  sp.clear();                            // Clear/flush the serial port
  str = sp.readStringUntil(lf);          // Read and discard any malformed data in the serial buffer
  str = null;                            // Clear the string
  
  //creating moles
   moleslist[0] = new Mole(xCoord[0], yCoord[0], moleWidth, moleHeight); 
   moleslist[1] = new Mole(xCoord[1], yCoord[1], moleWidth, moleHeight);
   moleslist[2] = new Mole(xCoord[2], yCoord[2], moleWidth, moleHeight);
   moleslist[3] = new Mole(xCoord[3], yCoord[1], moleWidth, moleHeight);
   moleslist[4] = new Mole(xCoord[4], yCoord[0], moleWidth, moleHeight);
   moleslist[5] = new Mole(xCoord[5], yCoord[1], moleWidth, moleHeight);
   moleslist[6] = new Mole(xCoord[6], yCoord[2], moleWidth, moleHeight);

  
  //instantiating the timer
  timer = new Timer(45);
  timer.startTimer();
  
  //instantiating the sound effect
  tone = new SoundFile(this, "whack.mp3");
  
  //instantiating writer and reader
    try {
    File f = dataFile("test.txt");    
    out = new PrintWriter(new BufferedWriter(new FileWriter(f, true)));    
  }
  catch (IOException e) { 
    println(e);
  }
  reader = createReader("test.txt");
}



void draw() {
  background(230);                       // clears the background
  
  while (sp.available() > 0) {           // Read while the serial port contains data
    str = sp.readStringUntil(lf);        // Write the string 
  }
  
  try {
  if (str != null) {                     // If the string is not null ...
    data = float(split(str, delimiter)); // Separate the string by the delimiter
    press = data[4];                     // Get button number
    filter= data[1];
    
  //activating the moles  
  if (frameCount % waitFrames == 0) {
    waitFrames--;
    int rand = (int) random (0,7);
  moleslist[rand].state = !moleslist[rand].state; }
  
  drawMoles();                           // draws the moles
  checkHit();                            // checks what has been pressed
  printTime();                           // prints the remaining time
  println(printavg());                   // prints the average of readings to the console
  determineHighScore();                  // calculates high score from file readings              
  endGame();                             // ends game 
  }
} catch (ArrayIndexOutOfBoundsException e) {
    println("Caught it");                // Exception handling for the port
    draw();
  }
}

//draw mole function
void drawMoles() {
  for (int i=0; i<moleslist.length; i++){
    moleslist[i].drawMole();
  }
}

//checks if the mole has been hit based off of the range of average readings
void checkHit() {
  if (filter > 60) { //filter of raw readings
    if ((press>-0.8) && (press<-0.6)) {
      changeState(0);  
    }
     if ((press>-0.55) && (press<-0.45)) {
      changeState(1);  
    }
    if ((press>-0.35) && (press<-0.25)) {
      changeState(2);  
    }
    if ((press>-0.20) && (press<-0.05)) {
      changeState(3); 
    }
    if ((press>0.0) && (press<0.15)) {
      changeState(4);  
    }
    if ((press>0.18) && (press<0.33)) {
      changeState(5);  
    }
    if ((press>0.35) && (press<0.5)) {
      changeState(6); 
    }
}
}

//end of the game function
void endGame() {
  if (timer.isFinished() == true) {      // if timer is done
  out.println(str(score));               // print the current score to the list of scores
  text("High score: "+currentHigh,65,70);// prints the determined high score
  out.flush();                           // flushes the remaining output to the file
  out.flush();
  out.flush();
  out.close();                           // closes the file 
  exit();                                // exits out of the window
}
} 

//changes the state of the mole once its been hit
void changeState(int num) {
  if (moleslist[num].state == true) {
    moleslist[num].state = false;
    moleslist[num].validate();
    tone.play();
    score++; }
}

//prints the time and current score
void printTime() {
  textAlign(CENTER);
  fill(0);
  textSize(18); 
  text("Time left: "+ str(timer.totalTime - timer.passedTime), 65, 30);
  text("Score: "+str(score),65,50);
  
}

//calculates average of the readings
float printavg() {
  sum=0;
  if (frameCount %60==0) {
    for (int i=0; i<100; i++){
      sum+=press;
    }
   avg = sum/100;
  }
  return avg;
}

//determines the high score based off of reading the score file
void determineHighScore() {
  try {
  line = reader.readLine();
  if (line != null) {
  currentHigh = line;
  while (line != null) {
    newline = reader.readLine();
    if (newline != null) {
      if (int(newline) > int(currentHigh)) {
        currentHigh = newline;
      } 
    }
    line=newline;
  } 
  }
  }catch (IOException e) {
    println(e);
  }
}
