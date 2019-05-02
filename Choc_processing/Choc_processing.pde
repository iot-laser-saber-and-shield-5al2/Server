List<Fighters> fighters = new ArrayList();
Fighters f1 = new Fighters();

class Fighters {
  int life = 100;
  public void hit(){
    this.life = this.life - 20;
  }
  public String toString() {
<<<<<<< HEAD
    return "Life : " + life + "\n";
=======
    return ax+"\t"+ay+"\t"+az+"\t"+ name + "\n";
  }
}



void oscEvent(OscMessage m) {

  print("addrpattern: "+m.addrPattern());
  println(" - floatValue: "+m.get(0).floatValue());

  if (log.size()==800) {
    log.remove(0);
  }
  if (m.addrPattern().startsWith("/IMU")) {
    Data data = new Data();
    data.ax = m.get(0).floatValue();
    data.ay = m.get(1).floatValue();
    data.az = m.get(2).floatValue(); // not used here
    data.name = m.get(3).toString(); // not used here
    println(data);
    log.add(data);
>>>>>>> parent of 63d8e10... Choc coté serveur ok
  }
}
