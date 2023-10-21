#include <NewPing.h>
#include <CheapStepper.h>
#define TRIGGER_PIN 2
#define ECHO_PIN 3
#define MAX_DISTANCE 200


#define trigPin 6
#define echoPin 7

NewPing sonar(TRIGGER_PIN, ECHO_PIN, MAX_DISTANCE);


unsigned long startTime = 0;
CheapStepper stepper(8, 9, 10, 11);
int timeDelay = 30;
bool isBussy = false;

const int pinRemoto = 4;

void setup() {
  Serial.begin(9600);
  pinMode(TRIGGER_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);

  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);

  pinMode(pinRemoto, INPUT);
  stepper.setRpm(12);
  stepper.moveDegreesCW(0);
}

void loop() {
  delay(1500);

  digitalWrite(TRIGGER_PIN, LOW);
  delayMicroseconds(2);

  digitalWrite(TRIGGER_PIN, HIGH);
  delayMicroseconds(10);

  digitalWrite(TRIGGER_PIN, LOW);


  unsigned int distanceObject = sonar.ping_cm();
  int distanceFillDish = distanceFilDish();

  if (distanceFillDish >= 8 && distanceFillDish <= 12) {
    Serial.println("Distancia al plato: ");
    Serial.println(distanceFillDish);
  } else {
    Serial.println("Plato lleno");
    Serial.println(distanceFillDish);
    return;
  }


  int estadoRemoto = digitalRead(pinRemoto);
  if (estadoRemoto == HIGH && !isBussy) {
    Serial.println("Servir desde remoto");
    openDoor();
  }
  if (distanceObject > 0 && distanceObject <= 30) {
    Serial.print("Objeto a: ");
    Serial.print(distanceObject);
    Serial.println(" cm");

    if ((millis() - startTime >= 5000) && !isBussy) {
      openDoor();
      startTime = millis();  // Reinicia el tiempo de inicio
    }
  } else {
    startTime = millis();  // Reinicia el tiempo de inicio si no se detecta un objeto
  }
}

void openDoor() {
  isBussy = true;
  stepper.move(false, 1024);
  Serial.println("Sirviendo comida");
  delay(timeDelay);  // Espera 5 segundos para inclinar el motor
  stepper.move(true, 1024);
  isBussy = false;
}


int distanceFilDish() {
  long duration;
  int distance;

  // Envía un pulso ultrasónico
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);

  // Lee el tiempo de viaje del eco
  duration = pulseIn(echoPin, HIGH);

  // Calcula la distancia en centímetros
  return distance = duration * 0.034 / 2;
}
