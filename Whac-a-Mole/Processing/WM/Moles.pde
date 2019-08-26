

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
  
Mole(int x, int y, int w, int h ) {
    xPos = x;
    yPos = y;
    moleHeight = h;
    moleWidth= w;
    
}

void drawMole() {
  if (state == false) {
  fill(0);
  rect(xPos,yPos,moleWidth, moleHeight);
  } else {
  fill(255,0,0);
  rect(xPos,yPos,moleWidth, moleHeight); }
  
}

void validate() {
  fill(0,255,0);
  rect(xPos, yPos, moleWidth, moleHeight);
}


//  void resetTimers(){
//    // pick a random amount of time to stay in this currentMole
//    totalCurrentMoleTime = int(random(50, 600));

//    // reset our current counter
//    currentMoleTime = 0;
//  }

//  void update(){
//    // increase amount of time in our current currentMole
//    currentMoleTime++;

//    // have we gone over our total currentMole time?
//    if (currentMoleTime >= totalCurrentMoleTime)
//    {
//      // switch!
//      if (currentMole == 0) { 
//        currentMole = (int) random(0, 9);
//      }
//      else { 
//        currentMole = 0;
//      }

//      // reset timers
//      resetTimers();
//    }
//  }


//  //hits
//  void checkHit() {
//    //generic
//    if (dist(mouseX, mouseY, xPos, yPos) < 70) {
//      //if good
//      if (currentMole > 0 && currentMole < 7) {
//        currentMole = 0;
//        score++;
//      } 
//      //is evil
//      else if (currentMole == 7 || currentMole == 8) {
//        moleGameOver();
//      }
//    }
//  }


//  void moleGameOver() {
//    gameOver = true;
//  }
//}
}
