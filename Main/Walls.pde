class Walls {
  
Walls() {
}

int score = 0;
int wallSpeed = 5;
int wallInterval = 1000;
float lastAddTime = 0;
int minGapHeight = 200;
int maxGapHeight = 300;
int wallWidth = 80;
color wallColors = color(0);
// This arraylist stores data of the gaps between the walls. Actuals walls are drawn accordingly.
// [gapWallX, gapWallY, gapWallWidth, gapWallHeight]
ArrayList<int[]> walls = new ArrayList<int[]>();


void wallAdder() {
  if (millis()-lastAddTime > wallInterval) {
    int randHeight = round(random(minGapHeight, maxGapHeight));
    int randY = round(random(0, height-randHeight));
    // {gapWallX, gapWallY, gapWallWidth, gapWallHeight}
    int[] randWall = {width, randY, wallWidth, randHeight, 0}; 
    walls.add(randWall);
    lastAddTime = millis();
  }
}

void wallDrawer(int index) {
  int[] wall = walls.get(index);
  // get gap wall settings 
  int gapWallX = wall[0];
  int gapWallY = wall[1];
  int gapWallWidth = wall[2];
  int gapWallHeight = wall[3];
  // draw actual walls
  rectMode(CORNER);
  fill(wallColors);
  rect(gapWallX, 0, gapWallWidth, gapWallY);
  rect(gapWallX, gapWallY+gapWallHeight, gapWallWidth, height-(gapWallY+gapWallHeight));
}
void wallMover(int index) {
  int[] wall = walls.get(index);
  wall[0] -= wallSpeed;
}
void wallRemover(int index) {
  int[] wall = walls.get(index);
  if (wall[0]+wall[2] <= 0) {
    walls.remove(index);
  }
}
void watchWallCollision(int index, int paddleX, float paddleY, int paddleWidth, int paddleHeight ) {
  int[] wall = walls.get(index);
  // get gap wall settings 
  int gapWallX = wall[0];
  int gapWallY = wall[1];
  int gapWallWidth = wall[2];
  int gapWallHeight = wall[3];
  int wallTopX = gapWallX;
  int wallTopY = 0;
  int wallTopWidth = gapWallWidth;
  int wallTopHeight = gapWallY;
  int wallBottomX = gapWallX;
  int wallBottomY = gapWallY+gapWallHeight;
  int wallBottomWidth = gapWallWidth;
  int wallBottomHeight = height-(gapWallY+gapWallHeight);

  if (
    (paddleX+(paddleWidth/2)>wallTopX) &&
    (paddleX-(paddleWidth/2)<wallTopX+wallTopWidth) &&
    (paddleY+(paddleHeight/2)>wallTopY) &&
    (paddleY-(paddleHeight/2)<wallTopY+wallTopHeight)
    ) {
    
  }
  
  if (
    (paddleX+(paddleWidth/2)>wallBottomX) &&
    (paddleX-(paddleWidth/2)<wallBottomX+wallBottomWidth) &&
    (paddleY+(paddleHeight/2)>wallBottomY) &&
    (paddleY-(paddleHeight/2)<wallBottomY+wallBottomHeight)
    ) {
    
  }
  
  int wallScored = wall[4];
  if (paddleX > gapWallX+(gapWallWidth/2) && wallScored==0) {
    wallScored=1;
    wall[4]=1;
    score();
  }
}
void score() {
  score++;
}

void printScore(){
  textAlign(CENTER);
  fill(233,175,68);
  textSize(30); 
  text(score, 50, height/2);
}
}
