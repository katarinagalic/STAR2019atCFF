class Block {
  int blockX, blockY;
  int blockWidth, blockHeight;
  
  Block(int xpos, int ypos, int w, int h) {
    blockX = xpos;
    blockY= ypos;
    blockWidth = w;
    blockHeight = h;
    
  } 
  void drawBlock() {
          fill(255);
          rectMode(CORNER);
          rect(blockX, blockY, blockWidth, blockHeight);
    }
}

class Moles {

int moleHeight = 100;
int moleWidth = 70;
int xCoord[] = {45, 115, 185, 255, 325, 395, 465, 535, 605, 675, 745, 815, 885};
int yCoord[] = {350, 250, 150, 50};


Moles() {
}

Block[] moles = new Block[13];

void populateMoles() {
   moles[0] = new Block(xCoord[0], yCoord[0], moleWidth, moleHeight); 
   moles[1] = new Block(xCoord[1], yCoord[1], moleWidth, moleHeight);
   moles[2] = new Block(xCoord[2], yCoord[2], moleWidth, moleHeight);
   moles[3] = new Block(xCoord[3], yCoord[3], moleWidth, moleHeight);
   moles[4] = new Block(xCoord[4], yCoord[2], moleWidth, moleHeight);
   moles[5] = new Block(xCoord[5], yCoord[1], moleWidth, moleHeight);
   moles[6] = new Block(xCoord[6], yCoord[0], moleWidth, moleHeight);
   moles[7] = new Block(xCoord[7], yCoord[1], moleWidth, moleHeight);
   moles[8] = new Block(xCoord[8], yCoord[2], moleWidth, moleHeight);
   moles[9] = new Block(xCoord[9], yCoord[3], moleWidth, moleHeight);
   moles[10] = new Block(xCoord[10], yCoord[2], moleWidth, moleHeight);
   moles[11] = new Block(xCoord[11], yCoord[1], moleWidth, moleHeight);
   moles[12] = new Block(xCoord[12], yCoord[0], moleWidth, moleHeight);
}

void drawMoles() {
  for (int i =0; i<moles.length; i++) {
    moles[i].drawBlock();
  }
  
  //rect(45,350,70,100);
  //rect(115,250,70,100);
  //rect(185,150,70,100);
  //rect(255,50,70,100);
  //rect(325,150,70,100);
  //rect(395,250,70,100);
  //rect(465,350,70,100);
  //rect(535,250,70,100);
  //rect(605,150,70,100);
  //rect(675,50,70,100);
  //rect(745,150,70,100);
  //rect(815,250,70,100);
  //rect(885,350,70,100);
}  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
}
