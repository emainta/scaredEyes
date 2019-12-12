float startR, newR;
static float SHRINK_FACTOR = 0.4; // For the iris shrinking
static float SAFE = 5; //Used for the frame
static float MIN_RADIUS = 25;

/* --------------------
 |   FRAME OCCHI    |
 -------------------- */


class Frame {
  PShape frame;
  float heightFrame, widthFrame;
  float deltaH, deltaH2, deltaW;

  float max_blink_frame = height/6;
  float delta_blink_frame = max_blink_frame/2;

  boolean is_blinking, show_filter, filterON;

  Frame() {
    deltaH = 0; 
    deltaH2 = 0;
    deltaW = 0;
    frame = loadShape("frame.svg"); //1080x720
    shapeMode(CENTER);

    heightFrame = height;
    widthFrame = width;

    this.is_blinking = false;
    this.show_filter = false;
    this.filterON = false;

    deltaH2 = 0;
  }

  // Display FRAME
  void display() {
    //fillHoles copre i buchi ai margini
    this.fillHoles();

    // deltaH è il delta di blink
    // deltaH2 è il delta di spalancamento
    // deltaW è il delta di spalancamento della width
    shape(frame, width/2, height/2, widthFrame - deltaW, heightFrame - 3*deltaH - deltaH2);

    // White Noise sopra tutto -- Rallenta troppo
    // this.whiteNoise();

    // Fitro triggerato da audio
    if (show_filter && filterON) {
      this.whiteNoise();
      this.showFilter();
    }
  }

  void fillHoles() { //fillHoles copre i buchi ai margini
    fill(0);

    beginShape();
    // Exterior part of shape, clockwise winding
    vertex(0, 0);
    vertex(width, 0);
    vertex(width, height);
    vertex(0, height);
    // Interior part of shape, counter-clockwise winding
    beginContour();
    vertex(deltaW+SAFE, (3*deltaH + deltaH2)+SAFE );
    vertex(deltaW, height - (3*deltaH + deltaH2));
    vertex(width-deltaW-SAFE, height - (3*deltaH + deltaH2));
    vertex(width-deltaW-SAFE, (3*deltaH + deltaH2)+SAFE);
    endContour();
    endShape(CLOSE);
  }

  void blink() {

    if (this.is_blinking) { // resta nel ciclo finchè non ha finito di blinkare
      deltaH += delta_blink_frame;

      if ( deltaH >= max_blink_frame ) { //bottom limit
        delta_blink_frame *= -1;
      }
      if ( deltaH <= 0 ) { //top limit
        deltaH = 0;
        delta_blink_frame *= -1;
        this.is_blinking = false;
      }
    }
  }

  void spalanca() {
    //Spalancamento in funzione inversa del raggio dell'iride
    deltaH2 = 5*(newR-startR)-startR*2;
    deltaW = -0.6*(newR-startR)-100;
  }

  void showFilter() { //Triggerato con onSetLow

    colorMode(RGB);
    fill(#f6a6a6, 50);
    rect(0, 0, width*2, height*2);
    colorMode(HSB, 360, 100, 100);
    this.show_filter = false;
    //println("show filter");
  }

  void whiteNoise() {
    loadPixels();
    for ( int i = 0; i < pixels.length; i++)
    {
      if (pixels[i] == color(0))
      {
        if (random(width) > width/2) pixels[i] = color(random(0, 100));
      }
    }
    updatePixels();
  }
}



/* ----------------
 |   PUPILLA    |
 ---------------- */

class Pupilla {

  color c, backC;
  float xPos, yPos, centerX, centerY;
  float omegaX, omegaY, phiX, phiY;
  float radius, dist;
  float ampTremoX, ampTremoY, shakiness;
  PImage veins;

  Iride iride;

  float radiusI, startRI; 

  // ---------- Constructor
  Pupilla(float xPos, float yPos) {
    this.xPos = xPos;
    this.yPos = yPos;

    this.centerX = xPos;
    this.centerY = yPos;

    this.iride = new Iride();
    this.radius = height*0.17;
    this.radiusI = 0.5*radius;
    newR = radiusI;
    this.startRI = radiusI; 
    startR = startRI;
    this.dist = 50;

    this.ampTremoX = 50;
    this.ampTremoY = 10;
    this.shakiness = 1;

    this.c = color(208, 5, 35);
    this.backC = color(0, 0, 90);

    veins = loadImage("veins.png");

    this.omegaX = 1./10*2*PI;
    this.omegaY = 1./7*2*PI;

    this.phiX= 1./2*2*PI;
    this.phiY= 1./3*2*PI;
  }

  void variations(float t, float shrinkF) {
    this.tremolio(t);
    this.shrinkIride(t, shrinkF);
  }

  // display pupilla
  void display(float t, float shrinkF) {
    displayRect();
    variations(t, shrinkF);

    this.displayVeins();

    noStroke();
    fill(this.c);
    circle(this.xPos, this.yPos, this.radius);

    iride.display(this.xPos, this.yPos, this.radiusI);
  }

  void displayVeins() {
    imageMode(CENTER);
    image(veins, xPos, yPos + 35, 0.5*veins.width, 0.5*veins.height);
  }

  void displayRect() {
    rectMode(CENTER);
    noStroke();
    fill(backC);

    rect(centerX, centerY, width/2, height/3);
  }

  void tremolio(float t) {
    this.xPos=this.centerX + map(noise(shakiness*(0.5+(float)Math.cos(t))*t), 0, 1, -ampTremoX, ampTremoX);
    this.yPos=this.centerY + map(noise(shakiness*3*t+100), 0, 1, -ampTremoY, ampTremoY);
  }

  void shrinkIride(float t, float shrinkF) {
    shrinkF = 2*sqrt(shrinkF); //too much variation in the energy feature
    radiusI=max(MIN_RADIUS, startRI - SHRINK_FACTOR*shrinkF+ startRI*0.05*cos(10*t*this.omegaX)*noise(2*t));
    newR = radiusI; //update global variable
  }
}

/* --------------
 |   IRIDE    |
 -------------- */

class Iride {

  PImage ir;

  Iride() {
    this.ir = loadImage("iride.png"); //using a png due to bad behaviour of the svg version
  }

  // Display IRIDE
  void display(float xx, float yy, float radius) { 
    imageMode(CENTER);
    image(ir, xx, yy, radius, radius);
    imageMode(CORNER);
  }
}


/* ----------------
 |   BLINKER    |
 ---------------- */

class Blinker {
  float xPos, yPos;
  float h, l;
  color c;

  float b_amt = 0;
  float delta_blink;
  float max_blink;

  boolean is_blinking;

  Blinker(float xPos, float yPos) {
    this.max_blink = height /4;
    this.delta_blink = max_blink/2.5;
    this.xPos = xPos;
    this.yPos = yPos - 1.3*max_blink;

    this.c = color(0, 0, 95);
    this.l = width/2;
    this.h = height/3;

    this.is_blinking = false;
  }

  void blink() {

    if (this.is_blinking) {
      b_amt = b_amt + delta_blink;

      if ( b_amt >= max_blink ) {
        b_amt = max_blink;
        delta_blink *= -1;
      }
      if ( b_amt <= 0 ) {
        b_amt = 0;
        delta_blink *= -1;
        this.is_blinking = false;
      }
    }
  }

  // Display blinker
  void display() {
    fill(c);
    noStroke();

    ellipseMode(CENTER);
    ellipse(xPos, yPos + b_amt, l, h);
  }
}
