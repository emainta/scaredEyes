import ddf.minim.*;
import ddf.minim.analysis.*;
int SMOOTHING_WINDOW = 10;
int NUM_FEATURES = 6;
int SENSITIVITY = 5000; //millisec 

float[] create_zero_buffer(){
  float[] buffer = new float[SMOOTHING_WINDOW];
  for (int i=0; i<SMOOTHING_WINDOW; i++){
    buffer[i]=0.;
  }
  return buffer;
}
float compute_flatness(FFT fft, float sum_of_spectrum){  
 
  // using several products will get overflow;
  // so instead of computing the harmonic mean, 
  // we compute the exponential of the average of the logarithms
   float sum_of_logs = 0;    
   float flatness;
   for(int i = 0; i < fft.specSize(); i++)
   {
     sum_of_logs += log(fft.getBand(i));      
   }
   flatness = exp(sum_of_logs/fft.specSize()) / 
                 (sum_of_spectrum/fft.specSize());
   return flatness;
}

float compute_centroid(FFT fft, float sum_of_spectrum, 
                                        float[] freqs){
   float centroid=0;
    for(int i = 0; i < fft.specSize(); i++){
      centroid += freqs[i]*fft.getBand(i);
    }
    return centroid/sum_of_spectrum;
}

float compute_spread(FFT fft, float centroid, float sum_of_bands, float[] freqs){
  float spread=0;
  for (int i=0; i<fft.specSize(); i++){
     spread+= pow(freqs[i]-centroid,2)*fft.getBand(i);
  }
  return sqrt(spread/sum_of_bands);
}

float compute_skewness(FFT fft, float centroid, float spread, float[] freqs){
  float skewness=0;
  for (int i=0; i<fft.specSize(); i++){
     skewness+= pow(freqs[i]-centroid,3)*fft.getBand(i);
  }
  return skewness/(fft.specSize()*pow(spread,3));
}

float compute_entropy(FFT fft){
  float entropy =0;
  for (int i=0; i<fft.specSize(); i++){
     entropy+= fft.getBand(i)*log(fft.getBand(i));
  }
  return entropy/log(fft.specSize());
}

float compute_sum_of_spectrum(FFT fft){
  float sum_of=0;
  for(int i = 0; i < fft.specSize(); i++)
   {
     sum_of += fft.getBand(i);      
   }
  return sum_of+1e-15; // adding a little displacement to avoid division by zero
}

float[] compute_peak_band_and_freq(FFT fft, float[] freqs){
  float val=0;
  float maxPeakVal=0;
  float maxFreqVal=0;
  float[] peak_band_freq= new float[2];
  peak_band_freq[0]=0.; // peak band
  peak_band_freq[1]=0.; // peak freq
  
  for(int i = 0; i < fft.specSize(); i++){
    val=fft.getBand(i);
    if(val>maxPeakVal){ 
      maxPeakVal=val;
      peak_band_freq[0]=1.0*i;
    }
    if(val>maxFreqVal && freqs[i]>20.){ 
      // if new max in the audible spectrum
      peak_band_freq[1]=freqs[i];
      maxFreqVal=val;
    }
  }   
  
  return peak_band_freq;
}

float get_average(float[] buffer){
  float average=0;
  for(int i=0; i<buffer.length; i++){
      average+=buffer[i];
  }
  return average/buffer.length;
}
float compute_energy(FFT fft) {    
  float energy = 0;
  for(int i = 0; i < fft.specSize(); i++){
    energy+=pow(fft.getBand(i),2);      
  }   
  return energy;
}
class AgentFeature { 
  int index_buffer=0;
  int index_spectrogram=0;
  int bufferSize;
  float sampleRate;
  int specSize;
  FFT fft;
  BeatDetect beat;
  float[] centroidBuffer;
  float[] spreadBuffer;
  float[] skewnessBuffer;
  float[] entropyBuffer;
  float[] flatnessBuffer;
  float[] energyBuffer;
  float[] sum_of_bands;  
  float[] peak_frequencyBuffer;
  float[][] spectrogram;
  float[] freqs;  
  float centroid;
  float spread;
  float energy;
  float skewness;
  float entropy;
  float flatness;
  boolean isBeat, isBeatLOW;
  
  AgentFeature(int bufferSize, float sampleRate){
    this.bufferSize=bufferSize;
    this.sampleRate=sampleRate;
    this.fft = new FFT(bufferSize, sampleRate);
    this.fft.window(FFT.HAMMING);
    this.specSize=this.fft.specSize();
    this.beat = new BeatDetect(bufferSize, sampleRate);
    this.beat.setSensitivity(SENSITIVITY);  
    
    this.sum_of_bands = create_zero_buffer();
    this.centroidBuffer = create_zero_buffer();
    this.spreadBuffer = create_zero_buffer();
    this.skewnessBuffer = create_zero_buffer();
    this.entropyBuffer = create_zero_buffer();
    this.flatnessBuffer = create_zero_buffer();
    this.energyBuffer = create_zero_buffer();
    this.peak_frequencyBuffer = create_zero_buffer();    
    this.freqs=new float[this.specSize];
        
    for(int i=0; i<this.specSize; i++){
      this.freqs[i]= 0.5*(1.0*i/this.specSize)*this.sampleRate;
    }
    
    this.spectrogram = new float[width][this.specSize];
    this.isBeat=false;
    this.isBeatLOW=false;
    this.centroid=0;
    this.spread=0;
    this.skewness=0;    
    this.entropy=0;
    this.energy=0;
  }
  void reasoning(AudioBuffer mix){
     this.fft.forward(mix);
     this.beat.detect(mix);
     this.sum_of_bands[this.index_buffer]= compute_sum_of_spectrum(this.fft);
     this.centroidBuffer[this.index_buffer] = compute_centroid(this.fft,this.sum_of_bands[this.index_buffer],this.freqs);
     this.flatnessBuffer[this.index_buffer]= compute_flatness(this.fft,
                                                             this.sum_of_bands[this.index_buffer]);
     this.spreadBuffer[this.index_buffer] = compute_spread(this.fft, this.centroidBuffer[this.index_buffer], 
                                                           this.sum_of_bands[this.index_buffer], this.freqs);                                  
     this.skewnessBuffer[this.index_buffer]= compute_skewness(this.fft, this.centroidBuffer[this.index_buffer], 
                                                              this.spreadBuffer[this.index_buffer], this.freqs);
                                                              
     this.entropyBuffer[this.index_buffer] = compute_entropy(this.fft);     
     this.energyBuffer[this.index_buffer] = compute_energy(this.fft);
     //float[] band_freq = compute_peak_band_and_freq(this.fft, this.freqs);
     
     this.index_buffer = (this.index_buffer+1)%SMOOTHING_WINDOW;
     this.centroid = get_average(this.centroidBuffer);    
     this.energy = get_average(this.energyBuffer);
     this.flatness = get_average(this.flatnessBuffer);
     this.spread = get_average(this.spreadBuffer);
     this.skewness = get_average(this.skewnessBuffer);
     this.entropy = get_average(this.entropyBuffer);
     this.isBeat = this.beat.isOnset(20); //max is 27
     this.isBeatLOW = this.beat.isKick();
  }   
} 



//probabilmente lo posso cancellare o alternativamente sostituire con un trigger dei parametri della faccia

class AgentController{
  AgentFeature feat;
  Frame fra;
  Pupilla[] pupy = new Pupilla[2];
  Blinker[] blinky = new Blinker[2];
  Iride[] iris = new Iride[2];
  
  boolean onSet, onSetLOW;
  boolean is_blinking;

  AgentController(AgentFeature feat, Frame fra, Pupilla[] pupy, Blinker[] blinky){
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

  
  void action(){
    // Aggiornamento valori feaatures
    float[] values=new float[NUM_FEATURES];
    values[0]=this.feat.energy;
    values[1]=this.feat.centroid;
    values[2]=this.feat.spread;
    values[3]=this.feat.skewness;
    values[4]=this.feat.entropy;
    values[5]=this.feat.flatness;
    //println(values[4]);
    
    onSet = this.feat.isBeat;
    onSetLOW = this.feat.isBeatLOW;
    
    if (onSet) do_blink();
    if (onSetLOW) this.fra.show_filter = true;
    
    if(this.is_blinking) blink();
    
    this.showEyes(values[0]);
    this.showFrame();
    
    // Show rain on top of everything
    this.showRain(values[0]);
    
    if(values[4] > 100 && (frameCount%30) == 0) this.getGlitch();
    
    }
    
  void showEyes(float energia){
    pupy[0].display(t,energia);
    pupy[1].display(t,energia);
  }
  
  void showFrame(){
    fra.spalanca(); 
    
    blinky[0].display();
    blinky[1].display();
    
    fra.display();
    
    this.is_blinking = frame.is_blinking || blinky[0].is_blinking || blinky[1].is_blinking;
  }

  void blink(){
    //println("blink");
    blinky[0].blink();
    blinky[1].blink();
    
    fra.blink();
}


  void do_blink(){
      this.is_blinking = true;
      this.fra.is_blinking = true;
      this.blinky[0].is_blinking = true;
      this.blinky[1].is_blinking = true;
  }
  
  void showRain(float energia){
      //println(energia);
      int energiaClippata = 200 + min((int)(energia), 300);
      for (int i=0; i<energiaClippata;i++){
        stroke(0,0, 50 + 50 *noise(t) , randomGaussian()*50+30); //randomGaussian()*10*t
        strokeWeight(3);
        float x = randomGaussian()*width;
        float y = randomGaussian()*height;
        line(x, y,x,randomGaussian()*height/2);
      }
    }
    
  void getGlitch(){
    for (int i=0; i<10; i++) {
      int x = r(width);
      int y = r(height);
      randomSeed(int(0.05*frameCount+r(15)));
      for (int j=0;j<20; j++) {
        set(x+j*2+r(width)-width/2,y+j*10,get(x,y,r(width/10),r(5)));
      }
    }
  }

int r(int a){
    return int(random(a));
  }
}
