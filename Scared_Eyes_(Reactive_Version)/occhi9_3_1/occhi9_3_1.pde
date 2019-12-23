boolean SONG_MIC=true; // true:audiofile - false: mic
Fear fear; 

void setup() {
  fullScreen(JAVA2D, 2);
  smooth(4); // Antialiasing (oversampling): disable in presence of lags
  frameRate(30); //Use 30fps or less if you are using a screen projector
  fear = new Fear(this);
}

void draw() {
  fear.update(); 
}

void keyPressed() {
  fear.keyPressed(); 
}
