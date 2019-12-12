Fear fear; // come da esempio

void setup() {
  fullScreen(JAVA2D, 2); // <-- Utile perchè usa il secondo schermo (se c'è)
  fear = new Fear(this); // <-- mi serve 
}

void draw() {
  fear.update(); // come da esempio
}

void keyPressed() {
  fear.keyPressed(); //<-- serve per l'audio monitoring, serve per debug, serve per attivare i filtri
}
