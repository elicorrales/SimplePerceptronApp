static final int NUM_FEATURES = 2; //limit it to 2 so we can use x,y coords visually.
//if we increase the NUM_FEATURES then the visual part is useless to us since it is only 2-D.
//but once we have established that the Perceptron essentially works, then we could increase
//the NUM_FEATURES.  however, we would also need to establish / define what is a known data point
//for our training data.

public static final int RANDOM_SAMPLES_EVEN_SPREAD = 0;
public static final int RANDOM_SAMPLES_AROUND_SLOPE = 1;
public static final int CHANGE_SLOPE = 2;
public static final int CHANGE_YOFFS = 3;
public static final int CHANGE_NUMSAMPLES = 4;
public static final int CHANGE_NUMITERATIONS = 5;
public static final int CHANGE_LEARNING = 6;

enum Parameter {
NONE,
RANDOM_SAMPLES_EVEN_SPREAD,
//RANDOM_SAMPLES_AROUND_SLOPE,
CHANGE_SLOPE,
CHANGE_YOFFS,
CHANGE_NUMSAMPLES,
CHANGE_NUMITERATIONS,
CHANGE_LEARNING
}

Perceptron perceptron;
TrainingSample[] trainingSamples;
boolean numTrainingSamplesInitialized = false;
Sample mousePoint;
int mousePointGuess = 0;
Parameter previousParam;
Parameter currentParam = Parameter.RANDOM_SAMPLES_EVEN_SPREAD;
Parameter currentRandomSpreadMode = Parameter.RANDOM_SAMPLES_EVEN_SPREAD;
boolean train = false;
boolean trainContinuous = false;
boolean increase = false;
boolean decrease = false;
float slope   = 1;
int   yOffset = 0;
int   numTrainingSamples = 1000;
float learningRate = 65;
int   iterations = 40;
boolean trained = false;
boolean newSamples = false;
boolean newWeights = false;

private Parameter getNextParameter(Parameter param)
{
  int index = param.ordinal();
  int nextIndex = index + 1;
  Parameter[] params = Parameter.values();
  nextIndex %=  params.length;
  return params[nextIndex];
}

float roundFloatValue(float value) {
  return Float.parseFloat(String.format("%.2f",value));
}


//seems to be required by Processing Environment in this main class.
void setup() {

  //set up canvas and visually show training samples
  size(1200,1000);
  textSize(30);

  perceptron = new Perceptron(NUM_FEATURES);
  perceptron.learningRate = learningRate;
  perceptron.iterations   = iterations;
  
  //this will be our test data point (moving the mouse around)
  mousePoint = new Sample(NUM_FEATURES);
}

//seems to be required by Processing Environment in this main class.
void draw() {

  background(150);  //doing this makes sure that when using mouse, only most curr point is showing.
  
  if (train && !trained) { trained = train(); train = false; }
  if (trainContinuous && !trained) { trained = train(); }
  
  //show the current mouse point, and color according to guessed classification
  switch(mousePointGuess) {
    case 1: mousePoint.drawSelf(0,0,255);break;
    case -1:mousePoint.drawSelf(255,0,0);break;
    default:mousePoint.drawSelf(100,255,100);
  }
  
  
  
  line(0,yOffset ,width, slope*width+yOffset);  //this line demarcates/separates the two classes (blue vs red)

  showTrainingSamples();  
  showParamSelection();
  showTrainingSelection();
  showPlusMinusSelection();
  showCurrentParameterValue();
  showNewWeightsButton();
  showNewSamplesButton();
  showWhenTrained();
  showWorkingBlink();
}

private void showTrainingSamples() {
  if (numTrainingSamplesInitialized) {
    for (TrainingSample sample : trainingSamples) {
      int guess = perceptron.guess(sample);
      sample.guess = guess;
      sample.draw();
    } //just show where the test data is
  }  
}

private void showNewWeightsButton() {
  fill(255);
  rect(width-200,height-30,110,20);
  fill(0);
  text("Weights",width-200,height-10);
}

private void showNewSamplesButton() {
  fill(255);
  rect(width-70,height-30,60,20);
  fill(0);
  text("New",width-70,height-10);
}

private long millisStartTraining = millis();
private long now = millis();
private void showWorkingBlink() {
  if (!trained && trainContinuous) {
    println("training...");
    now = millis();
  }
  text(round(now-millisStartTraining)/1000,3*width/4,60);
}
  
private void showWhenTrained() {
  if (trained) {
    fill(255);
    rect(width/3,height/2,width/3,30);
    fill(0);
    text("TRAINED",width/3+60,height/2+20);
  }
}

private void showCurrentParameterValue() {
  String text = "";
  switch (currentParam) {
    case CHANGE_SLOPE: text = ""+slope; break;
    case CHANGE_YOFFS: text = ""+yOffset; break;
    case CHANGE_NUMSAMPLES: text = ""+numTrainingSamples; break;
    case CHANGE_NUMITERATIONS: text = ""+perceptron.iterations; break;
    case CHANGE_LEARNING: text = ""+perceptron.learningRate; break;
  }
  fill(255);
  rect(430,height-30,100,20);
  fill(0);
  text(text,430,height-10);
}


private void showParamSelection() {
  String text = "";
  switch (currentParam) {
    case RANDOM_SAMPLES_EVEN_SPREAD:
                      text = "EVEN SPREAD";
                      if (previousParam != currentParam) {
                        previousParam = currentParam;
                        numTrainingSamplesInitialized = false; trained = false;
                        currentRandomSpreadMode = Parameter.RANDOM_SAMPLES_EVEN_SPREAD;
                      }
                      break;
/*
    case RANDOM_SAMPLES_AROUND_SLOPE:
                      text = "AROUND SLOPE";
                      if (previousParam != currentParam) {
                        previousParam = currentParam;
                        numTrainingSamplesInitialized = false; trained = false;
                        currentRandomSpreadMode = Parameter.RANDOM_SAMPLES_AROUND_SLOPE;
                      }
                      break;
*/
    case CHANGE_SLOPE:
                      text = "CHANGE_SLOPE";
                      if (previousParam != currentParam || increase || decrease) {
                        previousParam = currentParam;
                        numTrainingSamplesInitialized = false; trained = false;
                        millisStartTraining = millis();
                        if (increase) {
                          slope += 0.1; increase = false;
                        }
                        if (decrease) {
                          slope -= 0.1; decrease = false;
                        }
                        slope = roundFloatValue(slope);
                      }
                      break;
    case CHANGE_YOFFS:
                      text = "CHG_YOFFST";
                      if (previousParam != currentParam || increase || decrease) {
                        previousParam = currentParam;
                        numTrainingSamplesInitialized = false; trained = false;
                        millisStartTraining = millis();
                        if (increase) {
                          yOffset += 10; increase = false;
                        }
                        if (decrease) {
                          yOffset -= 10; decrease = false;
                        }
                      }
                      break;
    case CHANGE_NUMSAMPLES:
                      text = "CHG_NUMSAMP";
                      if (previousParam != currentParam || increase || decrease) {
                        previousParam = currentParam;
                        numTrainingSamplesInitialized = false; trained = false;
                        millisStartTraining = millis();
                        if (increase) {
                          if (numTrainingSamples<10) numTrainingSamples += 1;
                          else if (numTrainingSamples<100) numTrainingSamples +=10;
                          else numTrainingSamples +=100;
                          increase = false;
                        }
                        if (decrease) {
                          if (numTrainingSamples>0 && numTrainingSamples<10) numTrainingSamples -= 1;
                          else if (numTrainingSamples<100) numTrainingSamples -=10;
                          else numTrainingSamples -=100;
                          decrease = false;
                        }
                        if (numTrainingSamples <= 0) numTrainingSamples = 1;
                      }
                      break;
    case CHANGE_NUMITERATIONS:
                      text = "CHG_ITRATION";
                      if (previousParam != currentParam || increase || decrease) {
                        previousParam = currentParam;
                        numTrainingSamplesInitialized = false; trained = false;
                        millisStartTraining = millis();
                        if (increase) {
                          if (perceptron.iterations<10) perceptron.iterations += 1;
                          else if (perceptron.iterations<100) perceptron.iterations +=10;
                          else if (perceptron.iterations<1000) perceptron.iterations +=100;
                          else perceptron.iterations += 500;
                          increase = false;
                        }
                        if (decrease) {
                          if (perceptron.iterations>0 && perceptron.iterations<10) perceptron.iterations -= 1;
                          else if (perceptron.iterations<100) perceptron.iterations -=10;
                          else if (perceptron.iterations<1000) perceptron.iterations -=100;
                          else perceptron.iterations -= 500;
                          decrease = false;
                        }
                        if (perceptron.iterations<=0) perceptron.iterations = 1;
                      }
                      break;
    case CHANGE_LEARNING:
                      text = "CHG_LEARN";
                      if (previousParam != currentParam || increase || decrease) {
                        previousParam = currentParam;
                        numTrainingSamplesInitialized = false; trained = false;
                        millisStartTraining = millis();
                        if (increase) {
                          if (perceptron.learningRate<1) perceptron.learningRate += 0.01;
                          else if (perceptron.learningRate<10) perceptron.learningRate +=0.1;
                          else perceptron.learningRate += 1;
                          increase = false;
                        }
                        if (decrease) {
                          if (perceptron.learningRate>0 && perceptron.learningRate<1) perceptron.learningRate -= 0.01;
                          else if (perceptron.learningRate<10) perceptron.learningRate -=0.1;
                          else perceptron.learningRate -= 1;
                          decrease = false;
                        }
                        if (perceptron.learningRate<=0.01) perceptron.learningRate = 0.01;
                        perceptron.learningRate = roundFloatValue(perceptron.learningRate);
                      }
                      break;
                     
    default:
         currentParam = getNextParameter(currentParam);
  }
  fill(255);
  rect(0,height-30,230,20);
  fill(0);
  text(text,0,height-10);
}

private void showTrainingSelection() {
  String text = "";
  if (trainContinuous) {
    text = "STOP";
  } else if (train) {
    text = "TRAIN";
  } else {
    text = "TRAIN";
  }
  fill(255);
  rect(260,height-30,100,20);
  fill(0);
  text(text,260,height-10);
}

private void showPlusMinusSelection() {
  fill(255);
  rect(370,height-30,20,20);
  rect(400,height-30,20,20);
  fill(0);
  text("+",370,height-10);
  text("-",400,height-10);
}


private boolean train() {
  if (!numTrainingSamplesInitialized || newSamples) {
    trainingSamples = new TrainingSample[numTrainingSamples];
    for (int sample=0; sample<trainingSamples.length; sample++) {
      trainingSamples[sample] = new TrainingSample(currentRandomSpreadMode, NUM_FEATURES, slope, yOffset);
    }
    numTrainingSamplesInitialized = true; newSamples = false;
  }
  //trainingSamples = new TrainingSample[numTrainingSamples];
  //for (int sample=0; sample<trainingSamples.length; sample++) {
    //trainingSamples[sample] = new TrainingSample(randomSpreadMode, NUM_FEATURES, slope, yOffset);
  //}
  //numTrainingSamplesInitialized = true;
  //delay(10);
  return perceptron.train(trainingSamples);
}


private long millisPressed;
boolean pressed = false;
boolean pressedAndReleased = false;
void mousePressed() {
  pressedAndReleased = false;
  //println("pressed");
  millisPressed = millis();
  pressed = true;
  redraw();
}
void mouseReleased() {
  //println("released");
  long millisMouseButtonHeldDown = millis() - millisPressed;
  
  pressed = false;
  if (millisMouseButtonHeldDown > 500) { pressedAndReleased = true; }
  
  if (millisMouseButtonHeldDown > 500 &&
    mouseX>=260 && mouseX<=360 && mouseY>=height-30 && mouseY<=height-10) {
      //println("train continuous");
      trainContinuous = true; train = true;
      millisStartTraining = millis();
  } else {
    mousePoint.radius = 10;
  }
  redraw();
}

void mouseDragged() {
  mousePoint.radius = 20;
  mousePoint.features[0] = mouseX;
  mousePoint.features[1] = mouseY;
  mousePointGuess = perceptron.guess(mousePoint);
  redraw();
}
void mouseClicked() {
  //println("clicked");
  if (mouseX>=0 && mouseX<=230 && mouseY>=height-30 && mouseY<=height-10) {
    //println("change curr param");
    currentParam = getNextParameter(currentParam);
  } else 
  if (mouseX>=260 && mouseX<=360 && mouseY>=height-30 && mouseY<=height-10) {
    //println("train or stop");
    if (!pressedAndReleased && trainContinuous) {
      trainContinuous = false; train = false;
    } else {
      //println("train or stop");
      train = train?false:true;
    }
  } else
  if (mouseX>=370 && mouseX<=390 && mouseY>=height-30 && mouseY<=height-10) {
    //println("increase");
    increase = true;
    millisStartTraining = millis();
  } else
  if (mouseX>=400 && mouseX<=420 && mouseY>=height-30 && mouseY<=height-10) {
    //println("decrease");
    decrease = true;
    millisStartTraining = millis();
  } else 
  if (mouseX>=width-70 && mouseX<=width-10 && mouseY>=height-30 && mouseY<=height-10) {
    newSamples = true;
    trained = false;
    millisStartTraining = millis();
  } else 
  if (mouseX>=width-200 && mouseX<=width-90 && mouseY>=height-30 && mouseY<=height-10) {
    perceptron.newWeights();
    trained = false;
    millisStartTraining = millis();
    println("weights");
  } else 
  
  mousePoint.radius = 10;
  mousePoint.features[0] = mouseX;
  mousePoint.features[1] = mouseY;
  mousePointGuess = perceptron.guess(mousePoint);
  redraw();
  pressedAndReleased = false;
}
