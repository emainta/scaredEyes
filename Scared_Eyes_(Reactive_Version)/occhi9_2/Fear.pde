import ddf.minim.*;
import ddf.minim.analysis.*;

boolean SONG_MIC=true; // true:song - false: mic

class Fear { 

  // ----- Attributes ------
  Minim minim;
  AudioPlayer song;
  AudioInput mic;  
  AgentFeature feat;
  AgentController controller;

  // Frame length
  int frameLength = 1024; //--> when this is low, it may take more to compute (use 1024)

  Frame frame;
  Pupilla pupDx, pupSx;
  Blinker bDx, bSx;
  float frameRateHz=60;
  float t = 0;
  boolean monitor;


  // ----- Constructor ------
  Fear (java.lang.Object pippo) {  
    //userData.resetTable();
    colorMode(HSB, 360, 100, 100);
    frame = new Frame();

    pupSx = new Pupilla(0.23*width, height/2);
    pupDx = new Pupilla(0.77*width, height/2);

    bSx = new Blinker(0.23*width, height/2);
    bDx = new Blinker(0.77*width, height/2);

    minim = new Minim(pippo);
    if (SONG_MIC) {
      song = minim.loadFile("../data/paura.mpeg", frameLength);  
      //song = minim.loadFile("../data/example.wav",frameLength);  
      //song = minim.loadFile("../data/dreams.mp3", frameLength);  
      //song = minim.loadFile("../data/sine.wav",frameLength);
      //song = minim.loadFile("../data/whitenoise.wav",frameLength);

      feat = new AgentFeature(song.bufferSize(), song.sampleRate());
      song.play();   
      song.loop();
    } else {
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

  // ----- Update ------
  void update() { 

    t = frameCount/frameRateHz; //t+=1/frameRateHz;
    background(0); 

    if (SONG_MIC) {
      this.feat.reasoning(song.mix);
    } else {
      this.feat.reasoning(mic.mix);
    }

    this.controller.action();

    if (monitor) audioMonitoring();
  } 


  // ----- Methods ------

  void keyPressed() {
    if (key == 's' || key == 'S')  exit();

    if ( key == 'm' || key == 'M' ) {
      if ( monitor ) monitor = false;
      else monitor = true;
    }

    if (key == 'f' || key == 'F') {
      if (frame.filterON) {
        println("FILTER OFF");
        frame.filterON = false;
      } else {
        println("FILTER ON");
        frame.filterON = true;
      }
    }
  } 

  void audioMonitoring() {
    String s = "AUDIO MONITORING";

    float leftCh, rightCh;
    if (SONG_MIC) {
      leftCh = abs(song.left.level());
      rightCh = abs(song.right.level());
    } else {
      leftCh = abs(mic.left.level());
      rightCh = abs(mic.right.level());
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
} 
