/* --------------------
   |   FRAME OCCHI    |
   -------------------- */
float SAFE = 5;

class Frame{
  PShape frame;
  float heightFrame, widthFrame;
  float deltaH, deltaH2, deltaW;
 
  float max_blink_frame = height/6;
  float delta_blink_frame = max_blink_frame/2;

  boolean is_blinking, show_filter;

  Frame(){
    deltaH = 0; deltaH2 = 0;
    deltaW = 0;
    frame = loadShape("frame.svg"); //1080x720
    shapeMode(CENTER);

    heightFrame = height;
    widthFrame = width;
    
    this.is_blinking = false;
    this.show_filter = false;
    
    deltaH2 = 0;

  }

  void display(){
    //fillHoles copre i buchi ai margini
    this.fillHoles();
    // deltaH è il delta di blink
    // deltaH2 è il delta di spalancamento
    // deltaW è il delta di spalancamento della width
    shape(frame, width/2, height/2, widthFrame - deltaW , heightFrame - 3*deltaH - deltaH2);
    
    // White Noise sopra tutto -- Rallenta troppo
    //this.whiteNoise();
    
    if (show_filter) showFilter();
  }
  
  void fillHoles(){ //fillHoles copre i buchi ai margini
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

  void blink(){
    
    if(this.is_blinking){ // resta nel ciclo finchè non ha finito di blinkare
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
  
  void spalanca(){
    //Spalancamento in funzione inversa del raggio dell'iride
    deltaH2 = 5*(radiusI-startR)-startR*2;
    deltaW = -0.6*(radiusI-startR)-100;
  }
  
  void showFilter(){ //Triggera con audio
    
    colorMode(RGB);
    fill(#f6a6a6,50);
    rect(0,0,width*2,height*2);
    colorMode(HSB, 360, 100, 100);
    this.show_filter = false;
    //println("show filter");
}
  
  void whiteNoise(){
    loadPixels();
    for( int i = 0; i < pixels.length; i++)
    {
      if (pixels[i] == color(0))
      {
        if (random(width) > width/2) pixels[i] = color(random(0,100));
      }
    }
    updatePixels();
}
}
