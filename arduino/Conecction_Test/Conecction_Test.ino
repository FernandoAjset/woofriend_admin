#include <ESP8266WiFi.h>

const char* ssid = "Ajset_Alvarado_TIGO_2.4";
const char* password = "0000011244";
const int externalLedPin = 12;         // Pin para el LED externo

WiFiServer server(80);
bool isFirstRequest = true; // Bandera para indicar la primera solicitud
bool hasResponded = false;  // Bandera para indicar si se ha respondido
bool isLedOn = false;       // Bandera para indicar si el LED está encendido

void setup() {
  Serial.begin(9600);
  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(externalLedPin, OUTPUT); // Configurar el LED externo como salida


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
      } else if (request.indexOf("GET /toggleLed?state=ON") != -1) {
        digitalWrite(externalLedPin, HIGH);
        isLedOn = true;
        sendStatusResponse(client);
      } else if (request.indexOf("GET /toggleLed?state=OFF") != -1) {
        digitalWrite(externalLedPin, LOW); // Apagar el LED externo
        isLedOn = false;
        sendStatusResponse(client);
      }
        break; // Salir del bucle después de procesar la solicitud
      }
    }
    
    client.stop();
    Serial.println("Respuesta terminada");

  }
}



void sendStatusResponse(WiFiClient client) {
  String status = isLedOn ? "LED is ON" : "LED is OFF";
  String response = "HTTP/1.1 200 OK\r\n"
                    "Content-type: text/plain\r\n"
                    "\r\n"
                    + status;

  client.print(response);
}
