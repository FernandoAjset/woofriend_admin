import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'config/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
      title: 'Woofriend Control',
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  String arduinoIPAddress = ''; // Cambio en el valor por defecto
  bool isConnecting = false;
  bool isConnected = false;
  bool isLedOn = false;
  bool isTextFieldEnabled =
      true; // Bandera para habilitar o deshabilitar el TextField
  bool showLedControls =
      false; // Bandera para mostrar u ocultar controles de LED

  void connectToArduino() async {
    setState(() {
      isConnecting = true;
    });

    if (arduinoIPAddress.isEmpty) {
      setState(() {
        isConnecting = false;
      });
      return;
    }

    try {
      final response = await http.get(Uri.http(arduinoIPAddress, 'status'));

      setState(() {
        isConnecting = false;
        isConnected = response.statusCode == 200;
        isTextFieldEnabled = !isConnected;
        showLedControls = isConnected;
      });

      if (isConnected) {
        showSuccessDialog(response.body);
        setState(() {
          isLedOn = response.body.contains('ON');
        });
      }
    } catch (error) {
      setState(() {
        isConnecting = false;
        isConnected = false;
        isTextFieldEnabled = true;
        showLedControls = false;
      });
    }
  }

  void showSuccessDialog(String response) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Conexión Exitosa'),
          content: Text(
            'Se ha conectado al Arduino correctamente.\n\nRespuesta: $response',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void disconnectToArduino() {
    setState(() {
      isConnected = false;
      showLedControls = false;
      isTextFieldEnabled = true;
    });
  }

  void toggleLed(bool isOn) async {
    final response = await http.get(Uri.http(
        arduinoIPAddress, 'toggleLed', {'state': isOn ? 'ON' : 'OFF'}));

    if (response.statusCode == 200) {
      isOn = response.body.contains('ON');
      setState(() {
        isLedOn = isOn;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Woofriend Control')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Administrador: Woofriend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              onChanged: (value) {
                arduinoIPAddress = value;
              },
              enabled:
                  isTextFieldEnabled, // Habilitar o deshabilitar el TextField
              decoration: const InputDecoration(
                labelText: 'Dirección IP del Arduino',
                hintText: 'Ej. 192.168.1.100',
              ),
            ),
            const SizedBox(height: 20),
            isConnected
                ? FilledButton.icon(
                    onPressed: isConnecting ? null : disconnectToArduino,
                    icon: const Icon(Icons.power_off_rounded),
                    label: isConnecting
                        ? const CircularProgressIndicator()
                        : const Text('Desconectar'),
                  )
                : FilledButton.icon(
                    onPressed: isConnecting ? null : connectToArduino,
                    icon: const Icon(Icons.power_outlined),
                    label: isConnecting
                        ? const CircularProgressIndicator()
                        : const Text('Conectar'),
                  ),
            const SizedBox(height: 20),
            if (showLedControls) // Mostrar controles de LED si está conectado
              Column(
                children: [
                  Switch(
                    value: isLedOn,
                    onChanged: toggleLed,
                  ),
                  Icon(
                    isLedOn ? Icons.lightbulb : Icons.lightbulb_outline,
                    size: 50,
                    color: isLedOn ? Colors.orange : Colors.grey,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
