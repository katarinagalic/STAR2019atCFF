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


void wallAdder() {                                                                      //adds walls to wall[] to be drawn
  if (millis()-lastAddTime > wallInterval) {                                            //walls appear at equal time intervals
    int randHeight = round(random(minGapHeight, maxGapHeight));                         //finds random height between min&max height range
    int randY = round(random(0, height-randHeight));                                    //sets height for wall
    // {gapWallX, gapWallY, gapWallWidth, gapWallHeight}
    int[] randWall = {width, randY, wallWidth, randHeight, 0};                           
    walls.add(randWall);                                                                //adds randWall to list wall[]
    lastAddTime = millis();                                                             //increments time that last wall was added
  }
}

void wallDrawer(int index) {                                                            //draws walls
  int[] wall = walls.get(index);
  // get gap wall settings                                                              //sets gap wall w/ inputs from wall[] 
  int gapWallX = wall[0];
  int gapWallY = wall[1];
  int gapWallWidth = wall[2];
  int gapWallHeight = wall[3];
  // draw actual walls
  rectMode(CORNER);
  fill(wallColors);
  rect(gapWallX, 0, gapWallWidth, gapWallY);                                                    //draws first wall from top of screen
  rect(gapWallX, gapWallY+gapWallHeight, gapWallWidth, height-(gapWallY+gapWallHeight));        //draws second wall from bottom of screen
}
void wallMover(int index) {                                                                     //moves walls across screen in -xdirection
  int[] wall = walls.get(index);                                                                
  wall[0] -= wallSpeed;
}
void wallRemover(int index) {                                                                   //removes walls from wall[]
  int[] wall = walls.get(index);
  if (wall[0]+wall[2] <= 0) {
    walls.remove(index);
  }
}
void watchWallCollision(int index, int paddleX, float paddleY, int paddleWidth, int paddleHeight ) {        //watches for collision between walls and paddle
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

  if (                                                                                  //if paddle collides with upper wall -> exit window
    (paddleX+(paddleWidth/2)>wallTopX) &&                                                     
    (paddleX-(paddleWidth/2)<wallTopX+wallTopWidth) &&
    (paddleY+(paddleHeight/2)>wallTopY) &&
    (paddleY-(paddleHeight/2)<wallTopY+wallTopHeight)
    ) {
    screenvalue = 1;
    
  }
  
  if (                                                                                  //if paddle collides with lower wall -> exit window
    (paddleX+(paddleWidth/2)>wallBottomX) &&
    (paddleX-(paddleWidth/2)<wallBottomX+wallBottomWidth) &&
    (paddleY+(paddleHeight/2)>wallBottomY) &&
    (paddleY-(paddleHeight/2)<wallBottomY+wallBottomHeight)
    ) {
    screenvalue = 1;
  }
  
  int wallScored = wall[4];
  if (paddleX > gapWallX+(gapWallWidth/2) && wallScored==0) {                           //adds 1 to score if paddle successfully passes through walls
    wallScored=1;
    wall[4]=1;
    score();
  }
}
void score() {                                                                          //increments score by 1
  score++;
}

void printScore(){                                                                      //prints score while playing game
  textAlign(CENTER);
  fill(233,175,68);
  textSize(30); 
  text(score, 50, height/2);
}
}
