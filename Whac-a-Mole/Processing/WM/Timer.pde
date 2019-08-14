class Timer {

  int savedTime; //when timer starts
  int totalTime; //how long the timer should go for
  int passedTime;

  Timer(int time) {
    totalTime = time;
  }

  void startTimer() {
    savedTime = millis()/1000; //seconds
  }

  boolean isFinished() {
    passedTime = (millis()/1000) - savedTime;
    if (passedTime > totalTime) {
      return true;
    } 
    else {
      return false;
    }
  }
  
}
