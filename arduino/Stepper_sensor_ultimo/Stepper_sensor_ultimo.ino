#include <NewPing.h>
#include <CheapStepper.h>
#include <SoftwareSerial.h>

#define TRIGGER_PIN 2
#define ECHO_PIN 3
#define MAX_DISTANCE 200

#define trigPin 6
#define echoPin 7

const int trigPinCheckFillLevel = 12;
const int echoPinPinCheckFillLevel = 13;
const int esp8266PinCheckFillLevel = 5;
SoftwareSerial esp8266Serial(2, 5); // RX, TX - Crea un puerto serial virtual en los pines 2 (RX) y 5 (TX)

NewPing sonar(TRIGGER_PIN, ECHO_PIN, MAX_DISTANCE);

unsigned long startTime = 0;
CheapStepper stepper(8, 9, 10, 11);
int timeDelay = 30;
bool isBussy = false;

const int pinRemoto = 4;

void setup() {
  Serial.begin(9600);
  esp8266Serial.begin(9600); // Inicializa la comunicación serial con el ESP8266

  pinMode(TRIGGER_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);

  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);

  pinMode(trigPinCheckFillLevel, OUTPUT);
  pinMode(echoPinPinCheckFillLevel, INPUT);
  pinMode(esp8266PinCheckFillLevel, OUTPUT);

  pinMode(pinRemoto, INPUT);
  stepper.setRpm(12);
  stepper.moveDegreesCW(0);
}

void loop() {
  delay(1500);
  sendCheckFillLevel();

  digitalWrite(TRIGGER_PIN, LOW);
  delayMicroseconds(2);

  digitalWrite(TRIGGER_PIN, HIGH);
  delayMicroseconds(10);

  digitalWrite(TRIGGER_PIN, LOW);
  unsigned int distanceObject = sonar.ping_cm();

  int distanceFillDish = distanceFilDish();
  int estadoRemoto = digitalRead(pinRemoto);

  if ((estadoRemoto == HIGH && !isBussy) && (distanceFillDish >= 8)) {
    Serial.println("Servir desde remoto");
    openDoor();
  } else if ((distanceObject > 0 && distanceObject <= 30) && (distanceFillDish >= 8)) {
    Serial.print("Objeto a: ");
    Serial.print(distanceObject);
    Serial.println(" cm");

    if ((millis() - startTime >= 5000) && !isBussy) {
      openDoor();
      startTime = millis();
    }
  } else {
    startTime = millis();
  }
}

void openDoor() {
  isBussy = true;
  stepper.move(false, 1024);
  Serial.println("Sirviendo comida");
  delay(timeDelay);
  stepper.move(true, 1024);
  isBussy = false;
}

int distanceFilDish() {
  long duration;
  int distance;

  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);

  duration = pulseIn(echoPin, HIGH);

  return distance = duration * 0.034 / 2;
}

void sendCheckFillLevel() {
  long duration;
  int porcentaje;

  digitalWrite(trigPinCheckFillLevel, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPinCheckFillLevel, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPinCheckFillLevel, LOW);

  duration = pulseIn(echoPinPinCheckFillLevel, HIGH);

  float distancia_cm = duration * 0.034 / 2;

  // Calcula el porcentaje lleno del depósito
  porcentaje = map(distancia_cm, 50, 0, 0, 100);

  Serial.print("Porcentaje: ");
  Serial.println(porcentaje);

  // Envía el porcentaje al ESP8266 a través de la comunicación serial virtual
  esp8266Serial.print(porcentaje);
  esp8266Serial.print('\n'); // Agrega una nueva línea para indicar el final del dato

  delay(1000);
}

