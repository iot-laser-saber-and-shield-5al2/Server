
import java.util.*;
import oscP5.*;
import controlP5.*;
import static controlP5.ControlP5.*;

OscP5 osc;
ControlP5 cp;
int vie = 100 ;
//boolean combat_en_cours = true;
List<Fighters> fighters = new ArrayList();
Fighters j1 = new Fighters();
Fighters j2 = new Fighters();
class Fighters {
  int life = 100;
  String capteur;
  public void hit(){
    this.life = this.life - 20;
  }
  public String toString() {
    return "Life : " + life + "\n";
  }
}

void setup() {
  fullScreen(P3D);
  //size(1280, 600, P3D);

  smooth(8);
  hint(DISABLE_DEPTH_TEST);
  osc = new OscP5(this, 4559);
  cp = new ControlP5(this);

  float y = height-40;
  cp.addSlider("len").setPosition(20,y).setSize(200,20).setRange(0,100).setValue(50);
  cp.addToggle("x").setPosition(250,y).setSize(20,20).setValue(false);
  cp.addToggle("y").setPosition(290,y).setSize(20,20).setValue(true);
  cp.addToggle("z").setPosition(290,y).setSize(20,20).setValue(true);

  background(0);
  noStroke();
}

float rotY = 0, nrotY = 0;

void draw() {
  noStroke();
  fill(0, 255);
  rect(0, 0, width, height);
  render();
}

void mouseDragged() {
  if(mouseY < height-100) {
    nrotY += (pmouseX-mouseX)*0.01;
  }
}

boolean autoRotate = true;

void keyPressed() {
  autoRotate = !autoRotate;
}


float spacing = 4; /* spacing between each visual element */
float scl = 0.25; /* zoom factor while rendering */
int len;
List<Data> log = new ArrayList();


void render() {
  if (log.size()<=0) {
    return;
  }

  /* render visual elements into the 3D scene without
   * clearing the render buffer while the program is running.
   */
  lights();
  pushMatrix();
  translate(width/2, height/2);
  scale(scl);

  if (autoRotate)
    rotY += 0.003;
  else // back to the last position controlled by mouse:
    rotY = nrotY;

  rotateY(rotY);
  translate(-spacing*0.5*log.size(), 0);

  float t = cp.get("len").getValue() * 50;
  boolean bx = b(cp.get("x").getValue());
  boolean by = b(cp.get("y").getValue());

  for (int i=1; i<log.size(); i++) {
    Data data = log.get(i);
    translate(spacing, 0);
    pushMatrix();
    rotateZ(asin(data.ay));
    rotateY(asin(data.ax));
    fill(255, 120);

    if(bx) box(t, 4, 4);
    if(by) box(4, t, 4);

    popMatrix();
  }
  popMatrix();
}


class Data {
  float ax, ay, az;
  String name;
  public String toString() {
    return ax+"\t"+ay+"\t"+az+"\t"+ name + "\n";
  }
}



void oscEvent(OscMessage m) {

  //print("addrpattern: "+m.addrPattern());
  //println(" - floatValue: "+m.get(0).floatValue());

  if ( j1.capteur == null){
    j1.capteur =  m.get(3).toString();
    println("Joueur 1 possède le capteur " + j1.capteur);
  }
  else if(  j1.capteur != null  && j1.capteur != m.get(3).toString() &&  j2.capteur == null ){
    j2.capteur =   m.get(3).toString();
    println("Joueur 2 possède le capteur " + j2.capteur);
  }
  
  if (log.size()==800) {
    log.remove(0);
  }
  if (m.addrPattern().startsWith("/IMU")) {
    Data data = new Data();
    data.ax = m.get(0).floatValue();
    data.ay = m.get(1).floatValue();
    data.az = m.get(2).floatValue(); // not used here
    data.name = m.get(3).toString(); // not used here

    //println(data);
    log.add(data);
    
    //print("valeur absolue : " );
    //println(abs(data.ax) + abs(data.ay) + abs(data.az));
    
    if((abs(data.ax) + abs(data.ay) + abs(data.az)) >= 5)
    {
      println("---------------------------------------------------------------------------------------------------------------------------");
      if(j1.capteur.equals(data.name)){
        j2.hit();
        println(j2.life);
        if(j2.life > 0) 
          {       
            println("valeur de vie joueur 2 : " + j2.life);
          }
        else
          {
             println("Joueur 1 a gagner ");
             exit();
          }
      }
      else if (j2.capteur.equals(data.name)){  
        j1.hit();
        if(j1.life > 0) 
          {       
            println("valeur de vie joueur 1 : " + j1.life);
          }
        else
          {
             println("Joueur 2 a gagner");
             exit();
          }
      }
      
    }
  }
  
}
