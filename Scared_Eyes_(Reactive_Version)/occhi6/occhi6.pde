import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
boolean song_mic=false; // true:song - false: mic
AudioPlayer song;
AudioInput mic;
// Frame length
int frameLength = 512; //--> when this is low, it may take more to compute (use 1024)

AgentFeature feat;
AgentController controller;

Frame frame;
Pupilla pupDx, pupSx;
Blinker bDx, bSx;
float t = 0;
float frameRateHz=60;
boolean monitor;

void setup() {
  //frameRate(5);
  fullScreen(JAVA2D, 2);
  colorMode(HSB, 360, 100, 100);
  //size(1080, 720);
  //smooth(4); //Eliminare se rallenta troppo
  frame = new Frame();

  pupSx = new Pupilla(0.23*width ,height/2);
  pupDx = new Pupilla(0.77*width ,height/2);

  bSx = new Blinker(0.23*width ,height/2);
  bDx = new Blinker(0.77*width ,height/2);
  
  minim = new Minim(this);
  if(song_mic){   
    song = minim.loadFile("../data/example.wav",frameLength);  
    //song = minim.loadFile("../data/dreams.mp3",frameLength);  
    //song = minim.loadFile("../data/sine.wav",frameLength);
    //song = minim.loadFile("../data/whitenoise.wav",frameLength);
    
    feat = new AgentFeature(song.bufferSize(), song.sampleRate());
    song.play();   
    song.loop();
  }
  else{
    // Mic input    
    mic = minim.getLineIn(Minim.MONO, frameLength);
    feat = new AgentFeature(mic.bufferSize(), mic.sampleRate());
  }
  monitor = false;
  
  
  //Class obj[]= new Class[array_length]
  Pupilla pupArray[] = new Pupilla[]{pupSx, pupDx};
  Blinker blinkArray[] = new Blinker[]{bSx, bDx};
  controller = new AgentController(feat, frame, pupArray, blinkArray);

}

void draw(){
 
  t+=1/frameRateHz;
  background(0); //Sarà 0 nella versione finale
  
  if(song_mic){
    feat.reasoning(song.mix);
  }
  else{
    feat.reasoning(mic.mix);
  }
  
  controller.action();
  
  if (monitor) audioMonitoring();
}

void keyPressed(){
  if (key == 's' || key == 'S')  exit();
  
  if ( key == 'm' || key == 'M' ) {
    if ( monitor ) monitor = false;
    else monitor = true;
    }
  
} 

void audioMonitoring(){
  String s = "AUDIO MONITORING";
  
  float leftCh, rightCh;
  if(song_mic) {
    leftCh = song.left.level();
    rightCh = song.right.level();
  } else{
   leftCh = mic.left.level();
   rightCh = mic.right.level();
}
  rectMode(CENTER);
  stroke(100, 255, 255);
  noFill();
  rect(0, height/5 +51, width, 210);
  noStroke();
  fill(255);

  rect( 0, height/5, leftCh*width, 100 );
  rect( 0, height/5 + 102, rightCh*width, 100 ); 
  textSize(32);
  text(s, 3, height/5 -64);
}
