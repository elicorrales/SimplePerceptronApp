class TrainingSample extends Sample {
  int   answer;
  int   guess;
  boolean initialized = false;
  
 TrainingSample(Parameter randomSpreadMode, int numFeatures, float slope, float yOffset) {
   super(numFeatures);
   while (!initialized) initializeSample(randomSpreadMode,slope,yOffset);
 }

  private void initializeSample(Parameter randomSpreadMode, float slope, float yOffset) {
   float tempX=0,tempY=0;
   switch (randomSpreadMode) {
   case RANDOM_SAMPLES_EVEN_SPREAD:
        tempX = random(width); tempY = random(height);
        break;
/*
    case RANDOM_SAMPLES_AROUND_SLOPE:
        tempX = random(width); tempY = slope*tempX + 100 - random(200) + yOffset;
        break;
*/
    default:
   }
   features[0] = tempX; features[1] = tempY;
   if (features[0]>=0 && features[0]<=width && features[1]>=0 && features[1]<=height) {
     initialized = true;
   }
   answer = (slope * features[0]) >= (features[1] - yOffset) ? 1 : -1;
  }
  
  void draw() {
   if (features.length == 2) {
     if (answer != guess) {
       radius = 15;
       drawSelf(100,100,100);
     } else {
       radius = 10;
       switch (answer) {
         case 1:
           drawSelf(255,255,0);
           break;
         case -1:
           drawSelf(255,0,255);
           break;
       }
     }
   }
      
   if (features.length != 2) {
     println("");
   }
   
 }
 
}
