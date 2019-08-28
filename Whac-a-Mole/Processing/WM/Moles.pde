class Mole {
  int xPos;
  int yPos;
  int moleHeight;
  int moleWidth;
  boolean state;
  

  // how long to stay in this currentMole
  int totalCurrentMoleTime;

  // how long have we been in this currentMole?
  int currentMoleTime;

//constructor
Mole(int x, int y, int w, int h ) {
    xPos = x;
    yPos = y;
    moleHeight = h;
    moleWidth= w;
    
}

//draws the mole
void drawMole() {
  if (state == false) {
  fill(0);
  rect(xPos,yPos,moleWidth, moleHeight);
  } else {
  fill(255,0,0);
  rect(xPos,yPos,moleWidth, moleHeight); }
  
}

//green validation button
void validate() {
  fill(0,255,0);
  rect(xPos, yPos, moleWidth, moleHeight);
}

}
