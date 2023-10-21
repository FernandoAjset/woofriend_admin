#include <ESP8266WiFi.h>
#include <ArduinoJson.h>

const char* ssid = "Ajset_Alvarado_TIGO_2.4";
const char* password = "0000011244";
const int externalLedPin = 12;  // Pin para el LED externo

WiFiServer server(80);
bool isFirstRequest = true;  // Bandera para indicar la primera solicitud
bool hasResponded = false;   // Bandera para indicar si se ha respondido
bool isLedOn = false;        // Bandera para indicar si el LED está encendido

int porcentajeDesdeArduino = 0;

void setup() {
  Serial.begin(9600);
  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(externalLedPin, OUTPUT);  // Configurar el LED externo como salida
  digitalWrite(externalLedPin, LOW);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.println("Conectando a WiFi...");
  }

  Serial.println("Conectado a la red WiFi");
  Serial.print("Dirección IP asignada: ");
  Serial.println(WiFi.localIP());

  server.begin();
  Serial.println("Servidor iniciado");
}

void loop() {
  WiFiClient client = server.available();

  if (client) {
    Serial.println("Nuevo cliente conectado");

    while (client.connected()) {
      if (client.available()) {
        String request = client.readStringUntil('\r');
        if (request.indexOf("GET /status") != -1) {
          sendStatusResponse(client);
        }
          if (request.indexOf("GET /deposit_capacity") != -1) {
            checkFillingLevel(client);
          } else if (request.indexOf("GET /openDoor") != -1) {
            digitalWrite(externalLedPin, HIGH);
            isLedOn = true;
            delay(2000);
            sendStatusResponse(client);
          }
          break;  // Salir del bucle después de procesar la solicitud
        }
      }

      // Lee el dato enviado desde el Arduino
      while (Serial.available()) {
        porcentajeDesdeArduino = Serial.parseInt();
      Serial.println("Llenado: ");
      Serial.println(porcentajeDesdeArduino);
      }

      client.stop();
      Serial.println("Respuesta terminada");
    }
  }

  void checkFillingLevel(WiFiClient client) {
    digitalWrite(externalLedPin, LOW);

    // Crea un objeto JSON con el porcentaje
    StaticJsonDocument<200> jsonDocument;
    jsonDocument["depositPercentage"] = porcentajeDesdeArduino;

    // Serializa el JSON en una cadena
    String jsonResponse;
    serializeJson(jsonDocument, jsonResponse);

    // Construye la respuesta HTTP con el JSON
    String response = "HTTP/1.1 200 OK\r\n"
                      "Content-Type: application/json\r\n"
                      "\r\n"
                      + jsonResponse;

    client.print(response);
  }


  void sendStatusResponse(WiFiClient client) {
    digitalWrite(externalLedPin, LOW);
    isLedOn = !isLedOn;
    String status = isLedOn ? "ON" : "OFF";
    String response = "HTTP/1.1 200 OK\r\n"
                      "Content-type: text/plain\r\n"
                      "\r\n"
                      + status;

    client.print(response);
  }
