class Sample {
  float[] features;
  int     radius = 10;
  
  Sample(int numFeatures) {
    this.features = new float[numFeatures];
  }
  
  Sample(int numFeatures, float x, float y) {
    this.features = new float[numFeatures];
    this.features[0] = x;
    this.features[1] = y;
  }
  protected void drawSelf(int r, int g, int b) {
    if (features.length == 2) {
      fill(r,g,b);
      circle(features[0],features[1],radius);
    }
    else {
      for (float feature : features) {
        print(feature + ", ");
      }
      //println("");
    }
  }
}
