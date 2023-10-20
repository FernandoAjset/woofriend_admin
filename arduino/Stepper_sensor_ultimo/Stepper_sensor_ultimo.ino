#include <NewPing.h>
#include <CheapStepper.h>
#define TRIGGER_PIN  2
#define ECHO_PIN     3
#define MAX_DISTANCE 50

NewPing sonar(TRIGGER_PIN, ECHO_PIN, MAX_DISTANCE);
unsigned long startTime = 0;
CheapStepper stepper(8,9,10,11);
  int timeDelay = 30;

void setup() {
  Serial.begin(9600);
  pinMode(TRIGGER_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
  stepper.setRpm(12);
  stepper.moveDegreesCW(0);
}

void loop() {
  delay(500);

  digitalWrite(TRIGGER_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIGGER_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIGGER_PIN, LOW);

  unsigned int distance = sonar.ping_cm();

  
  if (distance > 0 && distance <= 10) {
    Serial.println("Objeto detectado a menos de 10 cm.");

    Serial.print("Distancia: ");
    Serial.print(distance);
    Serial.println(" cm");

    if (millis() - startTime >= 5000) {      
      stepper.move(false, 1024);
      Serial.println("Objeto detectado durante 5 segundos. Inclinando el motor ");
      delay(timeDelay); // Espera 5 segundos para inclinar el motor
      stepper.move(true, 1024);

      startTime = millis(); // Reinicia el tiempo de inicio
    }
  } else {
    startTime = millis(); // Reinicia el tiempo de inicio si no se detecta un objeto
  }
}