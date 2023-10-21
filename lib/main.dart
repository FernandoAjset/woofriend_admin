import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'config/theme/app_theme.dart';
import 'screens/DepositStatusScreen.dart';

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
  bool isOpenDoor = false;
  bool isTextFieldEnabled =
      true; // Bandera para habilitar o deshabilitar el TextField
  bool showControls = false; // Bandera para mostrar u ocultar controles.

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
        showControls = isConnected;
      });

      if (isConnected) {
        showSuccessDialog(response.body);
        setState(() {
          isOpenDoor = response.body.contains('ON');
        });
      }
    } catch (error) {
      setState(() {
        isConnecting = false;
        isConnected = false;
        isTextFieldEnabled = true;
        showControls = false;
      });
    }
  }

  void showSuccessDialog(String response) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Conexión Exitosa'),
          content: const Text(
            'Se ha conectado al Arduino correctamente.',
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
      showControls = false;
      isTextFieldEnabled = true;
    });
  }

  void serveFood() async {
    final response = await http.get(Uri.http(arduinoIPAddress, 'openDoor'));

    if (response.statusCode == 200) {
      isOpenDoor = response.body.contains('OFF');
      setState(() {
        isOpenDoor = !isOpenDoor;
      });
    }
  }

void navigateToDepositStatusScreen() {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => const DepositStatusScreen(),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Woofriend Control')),
        actions: [
          IconButton(
            onPressed: isConnected?navigateToDepositStatusScreen:null,
            icon: const Icon(Icons.storage),
          ),
        ],
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
            if (showControls) // Mostrar controles de LED si está conectado
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed:
                        serveFood, // Deshabilita el botón si isOpenDoor es true
                    icon: const Icon(
                      Icons.kitchen, // Icono de cocina
                      size: 50,
                      color: Colors.blueAccent,
                    ),
                    label: Text(
                      'Servir Comida',
                      style: TextStyle(
                        color: isOpenDoor ? Colors.blueAccent : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
