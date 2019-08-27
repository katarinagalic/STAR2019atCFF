import processing.sound.*; //<>//
import processing.serial.*;
import java.io.FileWriter;
import java.io.BufferedWriter;

//variables

Serial sp;                               // Serial port object
Mole moles;
Timer timer;
SoundFile tone;
PrintWriter out;
BufferedReader reader;
String currentHigh;

int lf = 10;                             // ASCII linefeed
String delimiter = " ";                  // String delimiter
String str;                              // Serial output string
float[] data = new float[6];             // Serial data buffer
public float press;                      // Paddle position
float scale = 10;
int waitFrames = 100;
int score = 0;
float hp;
float avg;
float sum;
String line;
String newline;

int moleHeight = 80;
int moleWidth = 80;
int xCoord[] = {190, 280, 370, 460, 550, 640, 730};
int yCoord[] = {100,210,320};

Mole[] moleslist = new Mole[7];


//functions 

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

  
  //initiating the timer
  timer = new Timer(45);
  timer.startTimer();
  
  tone = new SoundFile(this, "whack.mp3");
  
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
  background(230); 
  
  while (sp.available() > 0) {           // Read while the serial port contains data
    str = sp.readStringUntil(lf);        // Write the string 
  }
  
  try {
  if (str != null) {                     // If the string is not null ...
    data = float(split(str, delimiter)); // Separate the string by the delimiter
    press = data[4];                     // Get button number
    hp= data[1];
    
    
  if (frameCount % waitFrames == 0) {
    waitFrames--;
    int rand = (int) random (0,7);
  moleslist[rand].state = !moleslist[rand].state; }
  
  drawMoles();
  checkHit();
  printTime();
  println(printavg());
  determineHighScore();
  endGame();
  }
} catch (ArrayIndexOutOfBoundsException e) {
    println("Caught it");                                                        // prints caught it when flappy falls
    draw();
  }
}

void drawMoles() {
  for (int i=0; i<moleslist.length; i++){
    moleslist[i].drawMole();
  }
}

void checkHit() {

  if (hp > 60) {

    if ((press>-0.8) && (press<-0.60)) {
      changeState(0);  
    }
     if ((press>-.55) && (press<-0.45)) {
      changeState(1);  
    }
    if ((press>-0.35) && (press<-0.25)) {
      changeState(2);  
    }
    if ((press>-.20) && (press<-0.05)) {
      changeState(3); 
    }
    if ((press>0.0) && (press<.15)) {
      changeState(4);  
    }
    if ((press>.18) && (press<.33)) {
      changeState(5);  
    }
    if ((press>.35) && (press<.5)) {
      changeState(6); 
    }
}
}

void endGame() {
if (timer.isFinished() == true) {
  out.println(str(score));
  text("High score: "+currentHigh,65,70);
  out.flush();
  out.flush();
  out.flush();
  out.close();
  exit();
}
} 
void changeState(int num) {
  if (moleslist[num].state == true) {
    moleslist[num].state = false;
    moleslist[num].validate();
    tone.play();
    score++; }
}
void printTime() {
  textAlign(CENTER);
  fill(0);
  textSize(18); 
  text("Time left: "+ str(timer.totalTime - timer.passedTime), 65, 30);
  text("Score: "+str(score),65,50);
  
}

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
