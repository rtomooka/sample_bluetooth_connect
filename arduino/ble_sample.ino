int data = 0;
int led = 13; // Arduino本体のLEDを光らせるので13番にしています

void setup() {
  pinMode(led, OUTPUT);
  Serial.begin(9600);
  Serial.println("Connect your device with 1234 as Paring Key\n");
}

void loop() {
  if (Serial.available() > 0) {
    data = Serial.read();
    if (data == '1') {//1が送られてきたらLEDをON
      digitalWrite(led, HIGH); // LED点灯
      Serial.println("ON");
    } else if (data == '0') {//0が送られてきたらLEDをOFF
      digitalWrite(led, LOW);
      Serial.println("OFF"); // LED消灯
    }
    delay(10);
  }
}