List<Fighters> fighters = new ArrayList();
Fighters f1 = new Fighters();

class Fighters {
  int life = 100;
  public void hit(){
    this.life = this.life - 20;
  }
  public String toString() {
    return "Life : " + life + "\n";
  }
}
