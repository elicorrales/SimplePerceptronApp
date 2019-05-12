class Perceptron {
 int numFeatures;
 float[] weights;
 float   learningRate = 0.1;
 int     iterations = 1;
 float   biasWeight; //assumes bias (or another single input of 1, in addition to all the other sample inputs)
 
 Perceptron(int numFeatures) {
   this.numFeatures = numFeatures;
   newWeights();
 }
  
  void newWeights() {
   weights = new float[numFeatures];
   for (int i=0; i<weights.length; i++) { weights[i] = random(-1,1); }
   biasWeight = random(-1,1);      
  }
  
  private float sumSampleFeaturesTimesWeights(Sample sample) {
    float sum = 0;
    for (int i=0; i<sample.features.length; i++) {
      sum += sample.features[i] * weights[i];
    }
    //now we have to add in the bias input (a "1") times its bias weight
    sum += (1 * biasWeight);
    return sum;
  }
  

  private int signActivationFunction(float sum) {
    return sum>=0?1:-1;
  }
  
  int guess(Sample testSample) {
    
    if (testSample.features.length != this.weights.length) {
      throw new RuntimeException("Test Sample Wrong Number Of Features");
    }
    
    float sum = sumSampleFeaturesTimesWeights(testSample);
    return signActivationFunction(sum);
  }
 
  private void adjustWeightsAccordingToErrorAndInputs(int error, float[] inputs) {
    for (int w=0; w<weights.length; w++) {
      weights[w] += error * inputs[w] * learningRate;
      //println("w:"+weights[w]+", err:"+error+", in:"+inputs[w]+", lern:"+learningRate);
    }
    //now we have to adjust the biasWeight as well
    //biasWeight += error * 1  * learningRate;  // "1" is the bias Input
  }
  
  private void adjustBiasWeightAccordingToErrorAndInputs(int error, float[] inputs) {
    //now we have to adjust the biasWeight as well
    biasWeight += error * 1  * learningRate;  // "1" is the bias Input
  }
  
  private int trainFromSingleSample(TrainingSample sample) {
    int guess = guess(sample);
    int error = sample.answer - guess;
    sample.guess = guess;
    adjustWeightsAccordingToErrorAndInputs(error,sample.features);
    guess = guess(sample);
    error = sample.answer - guess;
    sample.guess = guess;
    adjustBiasWeightAccordingToErrorAndInputs(error,sample.features);
    return error;
  }

  boolean train(TrainingSample[] samples) {
    int errSum = 0;
    for (int i=0; i<iterations; i++) {
      for (TrainingSample sample : samples) {
        int error = trainFromSingleSample(sample);
        errSum += error;
      }
    }
    //println("\n\nerrSum:"+errSum + ", w0:"+weights[0] + ", w1:"+weights[1]);
    return errSum==0;
  }
}
