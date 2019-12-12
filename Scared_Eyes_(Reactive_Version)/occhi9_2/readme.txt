TO DO

5 Linka stessa feature  [Energia -> Pioggia e spalancamento]

6 

Pulire codice 
- Togliere Feature inutili
- Togliere Radius i come var globale
- Github

Test MIC



ALTRO
- Flashes di immagini
- Linear interpolation (spalancamento)

DONE
Tremolio occhio
Fullscreen e proporzioni
Rendere più fluido il Blinking
Rendere impaurito
Collegare ad audio Features
Spalancamento con radius linearmente
Linee di rumore (pioggia)
Blood Vessels background
Noise su nero  (fatto , ma rallenta)
Trigger Filtro (isKick, ma ha senso?)
Trigger Glitches (si o no)


OLD SPALANCA
    
    //if(radiusI < 80) {
    //  this.is_spalancato = true;
    //  bibbi = true;
    //}
    
    //if(radiusI > 80) bibbi = false;
    
    //if (deltaSpal !=0) deltaTemp = deltaSpal;
    
    //if(this.is_spalancato){
      
    //   deltaH2 -= deltaSpal;
  
    //  if ( (-deltaH2) >= 1.5*max_blink_frame ) {
    //   if(bibbi) {
    //     deltaSpal = 0;
    //     println("entrato1");
    //   }else{
    //     if(deltaSpal==0) { deltaSpal = -deltaTemp;
    //     println("entrato2");}
    //       //deltaSpal *= -1;
    //   }
    //  }
    //  if ( (-deltaH2) <= 0 ) {
    //    deltaH2 = 0;
    //    deltaSpal *= -1;
    //    this.is_spalancato = false;
    //    println("entrato3"); 
    //  }
    //}
