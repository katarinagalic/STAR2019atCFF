// Block class for drawing blocks in brickbreaker type games

class Block {
  int blockX, blockY;
  int blockWidth, blockHeight;
  boolean blockVisibility = true;
  int blockColor = color(125,31,22);
  
  
  Block(int xpos, int ypos, int w, int h) {
    blockX = xpos;
    blockY= ypos;
    blockWidth = w;
    blockHeight = h;
    
  }
  
  //draws the block
  void drawBlock() {
        if (blockVisibility == true) {
          fill(blockColor);
          rectMode(CORNER);
          rect(blockX, blockY, blockWidth, blockHeight);
    }
  }
}
