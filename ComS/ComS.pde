import processing.serial.*;

Serial port;
int data;

void setup() {
  size (500, 500);
  port = new Serial(this, Serial.list()[0], 9600);
}

void draw () {
  if(port.available() > 0) {
    data = port.read();
  }
}
