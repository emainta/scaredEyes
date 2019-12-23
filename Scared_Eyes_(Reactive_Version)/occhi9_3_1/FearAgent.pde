import ddf.minim.*;
import ddf.minim.analysis.*;

// ------------- AUDIO FEATURES EXTRACTION CONSTANTS
static int SMOOTHING_WINDOW = 10;
static int SENSITIVITY = 5000; //of the onset, millisec
static float GLITCH_THRESHOLD = 60;
static float ENERGY_RANGE = 0.5; // lower for high volumes

// ------------- AUDIO FEATURES EXTRACTION FUNCTIONS

float[] create_zero_buffer() {
  float[] buffer = new float[SMOOTHING_WINDOW];
  for (int i=0; i<SMOOTHING_WINDOW; i++) {
    buffer[i]=0.;
  }
  return buffer;
}

float compute_entropy(FFT fft) {
  float entropy =0;
  for (int i=0; i<fft.specSize(); i++) {
    entropy+= fft.getBand(i)*log(fft.getBand(i));
  }
  return entropy/log(fft.specSize());
}

float get_average(float[] buffer) {
  float average=0;
  for (int i=0; i<buffer.length; i++) {
    average+=buffer[i];
  }
  return average/buffer.length;
}

float compute_energy(FFT fft) {    
  float energy = 0;
  for (int i = 0; i < fft.specSize(); i++) {
    energy+=pow(fft.getBand(i), 2);
  }   
  return energy;
}

/* ----------------------
 |   AGENT FEATURE    |
 ---------------------- */

class AgentFeature { 
  int index_buffer=0;
  int index_spectrogram=0;
  int bufferSize;
  float sampleRate;
  int specSize;
  FFT fft;
  BeatDetect beat;
  float[] entropyBuffer;
  float[] energyBuffer;
  float[] freqs;  
  float energy;
  float entropy;
  boolean isBeat, isBeatLOW;

  AgentFeature(int bufferSize, float sampleRate) {
    this.bufferSize=bufferSize;
    this.sampleRate=sampleRate;
    this.fft = new FFT(bufferSize, sampleRate);
    this.fft.window(FFT.HAMMING);
    this.specSize=this.fft.specSize();
    this.beat = new BeatDetect(bufferSize, sampleRate);
    this.beat.setSensitivity(SENSITIVITY);  

    this.entropyBuffer = create_zero_buffer();
    this.energyBuffer = create_zero_buffer();
    this.freqs=new float[this.specSize];

    for (int i=0; i<this.specSize; i++) {
      this.freqs[i]= 0.5*(1.0*i/this.specSize)*this.sampleRate;
    }

    this.isBeat=false;
    this.isBeatLOW=false;   
    this.entropy=0;
    this.energy=0;
  }
  void reasoning(AudioBuffer mix) {
    this.fft.forward(mix);
    this.beat.detect(mix);

    this.entropyBuffer[this.index_buffer] = compute_entropy(this.fft);     
    this.energyBuffer[this.index_buffer] = compute_energy(this.fft);

    this.index_buffer = (this.index_buffer+1)%SMOOTHING_WINDOW;
    this.energy = get_average(this.energyBuffer);
    this.entropy = get_average(this.entropyBuffer);
    this.isBeat = this.beat.isOnset(20); //max is 27
    this.isBeatLOW = this.beat.isKick();
  }
} 

/* -------------------------
 |   AGENT CONTROLLER    |
 -------------------------*/

class AgentController {
  AgentFeature feat;
  Frame fra;
  Pupilla[] pupy = new Pupilla[2];
  Blinker[] blinky = new Blinker[2];
  Iride[] iris = new Iride[2];

  boolean onSet, onSetLOW;
  boolean is_blinking;

  float t = 0;

  AgentController(AgentFeature feat, Frame fra, Pupilla[] pupy, Blinker[] blinky) {
    this.feat = feat;
    this.fra = fra;
    this.pupy = pupy; 
    this.blinky = blinky;
    this.iris[0] = pupy[0].iride;
    this.iris[1] = pupy[1].iride;

    this.onSet = false;
    this.onSetLOW = false;

    this.is_blinking = false;
  }


  void action() {
    t = frameCount/frameRate;
    // Aggiornamento valori feaatures
    float energy = this.feat.energy;
    float entropy = this.feat.entropy;

    onSet = this.feat.isBeat;
    onSetLOW = this.feat.isBeatLOW;

    // trigger blink and filter
    if (onSet) do_blink();
    if (onSetLOW) this.fra.show_filter = true;

    if (this.is_blinking) blink();

    // display eyes and frame
    this.showEyes(energy);
    this.showFrame();

    // Show rain on top of everything
    this.showRain(energy);

    // Show glitches sometimes
    if (entropy> GLITCH_THRESHOLD && (frameCount%30) == 0) this.getGlitch();
  }

  void showEyes(float energia) {
    float energiaClippata = min(energia, 10000+3000*noise(t));
    
    pupy[0].display(t, ENERGY_RANGE*energiaClippata);
    pupy[1].display(t, ENERGY_RANGE*energiaClippata);
  }

  void showFrame() {
    fra.spalanca(); 

    blinky[0].display();
    blinky[1].display();

    fra.display();

    this.is_blinking = fra.is_blinking || blinky[0].is_blinking || blinky[1].is_blinking;
  }

  void blink() {
    blinky[0].blink();
    blinky[1].blink();

    fra.blink();
  }


  void do_blink() {
    this.is_blinking = true;
    this.fra.is_blinking = true;
    this.blinky[0].is_blinking = true;
    this.blinky[1].is_blinking = true;
  }

  void showRain(float energia) {
    int energiaClippata = 10 + (min((int)(energia), 350));
    for (int i=0; i<energiaClippata; i++) {
      stroke(0, 0, 50 + 50 *noise(t), randomGaussian()*50+30); //randomGaussian()*10*t
      strokeWeight(3);
      float x = randomGaussian()*width;
      float y = randomGaussian()*height;
      line(x, y, x, randomGaussian()*height/2);
    }
  }

  void getGlitch() {
    for (int i=0; i<10; i++) {
      int x = r(width);
      int y = r(height);
      randomSeed(int(0.05*frameCount+r(15)));
      for (int j=0; j<20; j++) {
        set(x+j*2+r(width)-width/2, y+j*10, get(x, y, r(width/10), r(5)));
      }
    }
  }

  int r(int a) {
    return int(random(a));
  }
}
