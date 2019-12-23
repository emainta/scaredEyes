import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class occhi5 extends PApplet {

Frame frame;
Pupilla pupDx, pupSx;
Blinker bDx, bSx;
float t = 0;
float frameRateHz=60;

public void setup() {
  
  //size(1080, 720);
  frame = new Frame();

  pupSx = new Pupilla(0.25f*width ,height/2);
  pupDx = new Pupilla(0.75f*width ,height/2);

  bSx = new Blinker(0.25f*width ,height/2);
  bDx = new Blinker(0.75f*width ,height/2);

}

public void draw(){

  t+=1/frameRateHz;
  background(20); //Sarà 0 nella versione finale

  showEyes();
  showFrame();


}

public void showEyes(){
  pupDx.display(t);
  pupSx.display(t);

  if(mousePressed){
    bDx.action();
    bSx.action();

    frame.blink();
  }

}

public void mouseReleased() {
  bDx.reset();
  bSx.reset();

  frame.reset();
}

public void showFrame(){
  frame.display();
}
boolean is_blinking = false;
float b_amt = 0;
float delta_blink = 3;
float max_blink;

class Blinker{
  float xPos, yPos;
  float h, l;
  int c;

  Blinker(float xPos, float yPos){
    max_blink = height / 6;
    this.xPos = xPos;
    this.yPos = yPos - max_blink;

    c = color(250);
    l = width/2;
    h = height/3;

  }

  public void action(){

    b_amt = b_amt + delta_blink;

    if ( b_amt >= max_blink ) {
      b_amt = max_blink;
      delta_blink *= -1;
    }
    if ( b_amt <= 0 ) {
      b_amt = 0;
      delta_blink *= -1;
      is_blinking = false;
    }

    this.display();
  }

  public void display(){
    fill(c);
    noStroke();

    ellipseMode(CENTER);
    ellipse(xPos, yPos + b_amt, l, h);
  }

  public void reset(){
    b_amt = 0;
  }






}
float delta_blink_frame = 4;
float MAX_BLINK_FRAME = 210;

class Frame{
  PShape frame;
  float heightFrame, widthFrame;
  float deltaH, deltaW;



  Frame(){
    frame = loadShape("frame.svg"); //1080x720
    shapeMode(CENTER);

    heightFrame = height;
    widthFrame = width;

    deltaH =0;
    deltaW = 0;
  }

  public void display(){
    shape(frame, width/2, height/2, widthFrame + deltaW , heightFrame - 3*deltaH);
  }

  public void blink(){
    deltaH += delta_blink;

    if ( deltaH >= MAX_BLINK_FRAME ) {
      delta_blink *= -1;
    }
    if ( deltaH <= 0 ) {
      deltaH = 0;
      delta_blink *= -1;
      //is_blinking = false;
    }




  }

  public void reset(){
    //delta_blink *=-1;
    deltaH = 0;
    //deltaW = 0;
  }
















}

class Iride{
  
  PImage ir;


  Iride(){
    ir = loadImage("iride.png");
    
  }
  
  public void display(float xx, float yy, float radius){
    imageMode(CENTER);
    image(ir, xx, yy, radius, radius);
    imageMode(CORNER);
  }


}
float pi=(float)Math.PI;

class Pupilla {

  int c, backC;
  float xPos, yPos, centerX, centerY;
  float omegaX, omegaY, phiX, phiY;
  float radius, radiusI, startR, dist;
  float ampTremoX, ampTremoY, shakiness;

  Iride iride;

  //Constructor:
  Pupilla(float xPos, float yPos){
     this.xPos = xPos;
     this.yPos = yPos;

     this.centerX = xPos;
     this.centerY = yPos;

     iride = new Iride();
     radius = 180;
     this.radiusI = radius/3;
     this.startR = radiusI;
     dist = 50;

     ampTremoX = 30;
     ampTremoY = 10;
     shakiness = 1;

     c = color(90,110,255);
     backC = color(240, 230, 255);


    this.omegaX = 1.f/10*2*pi;
    this.omegaY = 1.f/7*2*pi;

    this.phiX= 1.f/2*2*pi;
    this.phiY= 1.f/3*2*pi;


  }

  public void variations(float t){
    // this.xPos=this.centerX + this.dist*(float)Math.cos(Math.cos(t*0.3)*t*this.omegaX+this.phiX);
    // this.yPos=this.centerY + this.dist*0.3*(float)Math.sin(t*this.omegaY+this.phiY);
    this.tremolio(t);
    this.radiusI=this.startR + 5*(float)Math.sin(t*2*this.omegaX+this.phiY);


  }

  public void display(float t){
    displayRect();
    variations(t);

    noStroke();
    fill(c);
    circle(xPos, yPos, radius);

    iride.display(xPos, yPos, radiusI);
  }

  public void displayRect(){
    rectMode(CENTER);
    noStroke();
    fill(backC);

    rect(centerX, centerY, width/2, height/3);
  }

  public void tremolio(float t){
    this.xPos=this.centerX + map(noise(shakiness*3*t), 0,1, -ampTremoX, ampTremoX);
    this.yPos=this.centerY + map(noise(shakiness*t), 0,1, -ampTremoY, ampTremoY);
  }


}
  public void settings() {  fullScreen(JAVA2D, 2); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--present", "--window-color=#666666", "--stop-color=#cccccc", "occhi5" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
