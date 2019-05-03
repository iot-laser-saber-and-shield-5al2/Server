
import java.util.*;
import oscP5.*;
import controlP5.*;
import static controlP5.ControlP5.*;
import processing.serial.*;
import processing.sound.*;

SoundFile fight_sound;
SoundFile starwars_music;
SoundFile light_saber_music;
OscP5 osc;
ControlP5 cp;

int vie = 400 ;
//boolean combat_en_cours = true;
List<Fighters> fighters = new ArrayList();
Fighters j1 = new Fighters();
Fighters j2 = new Fighters();
class Fighters {
  int life = 400;
  String capteur;
  List<Data> datas = new ArrayList();
  public void hit(){
    this.life = this.life - 20;
  }
  public String toString() {
    return "Life : " + life + "\n";
  }
}

void setup() {
  fullScreen(P3D);

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
  
  // music
  fight_sound = new SoundFile(this, "fight_sound.mp3");
  starwars_music = new SoundFile(this, "starwars_music.mp3");
  light_saber_music = new SoundFile(this, "LightSaberContact.wav");
  fight_sound.play();
  starwars_music.play();
  light_saber_music.play();
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
  int hours, minutes, seconds;
  boolean isChoc = false;
  public String toString() {
    return ax+"\t"+ay+"\t"+az+"\t"+ name + "\n";
  }
}

boolean isThreshold(Data data)
{
  return (abs(data.ax) + abs(data.ay) + abs(data.az)) >= 4;
}

void oscEvent(OscMessage m) {

  if ( j1.capteur == null){
    j1.capteur = m.get(3).toString();
    println("Player 1 got the captor " + j1.capteur);
  }
  else if(j1.capteur != null  && j1.capteur != m.get(3).toString() &&  j2.capteur == null ){
    j2.capteur = m.get(3).toString();
    println("Player 2 got the captor " + j2.capteur);
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
    data.hours = hour();
    data.minutes = minute();
    data.seconds = second();
    
    log.add(data);
    
    if(isThreshold(data))
    {
      //fight_sound.play();
      light_saber_music.play();
      data.isChoc = true;
      println("---------------------------------------------------------------------------------------------------------------------------");
      boolean isSwordFight = false;
      if(j1.capteur.equals(data.name)){
        List<Data> subj2Data = j2.datas.subList(j2.datas.size() -6, j2.datas.size() -1);
        for(Data dataj2 : subj2Data)
        {
          if(dataj2.isChoc)
          {
             println("Sword Contact! ");
             isSwordFight = true;
             fight_sound.play();
             break;
          }
        }
        if(isSwordFight)
        {
          exit();
        }
        j2.hit();
        println("P1: " + j1.life);
        if(j2.life > 0) 
        {       
          println("Life of player 2 : " + j2.life);
        }
        else
        {
           println("Player 1 won");
           exit();
        }
      }
      else if (j2.capteur.equals(data.name)){
        List<Data> subj1Data = j1.datas.subList(j1.datas.size() -6, j1.datas.size() -1);
        for(Data dataj1 : subj1Data)
        {
          if(dataj1.isChoc)
          {
             println("Sword Contact! ");
             isSwordFight = true;
             fight_sound.play();
             exit();
          }
        }
        
        if(isSwordFight)
        {
          exit();
        }
        
        j1.hit();
        println("P2: " + j2.life);
        if(j1.life > 0) 
        {       
          println("Life of player 1 : " + j1.life);
        }
        else
        {
           println("Player 2 won");
           exit();
        }
      }   
    }
    
    if(j1.capteur.equals(data.name))
    {
      j1.datas.add(data);
    }
    else if (j2.capteur.equals(data.name))
    {
      j2.datas.add(data);
    }
  }
  
}
