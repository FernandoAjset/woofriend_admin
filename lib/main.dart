import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Woofriend Control',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String arduinoIPAddress = '';
  bool isConnecting = false;
  bool isConnected = false;
  bool isLedOn = false;

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
      });

      if (isConnected) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Conexión Exitosa'),
              content: Text(
                  'Se ha conectado al Arduino correctamente.\n\nRespuesta: ${response.body}'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cerrar'),
                ),
              ],
            );
          },
        );

        setState(() {
          isLedOn = response.body.contains('ON');
        });
      }
    } catch (error) {
      print(error);
      setState(() {
        isConnecting = false;
        isConnected = false;
      });
    }
  }

  void toggleLed(bool isOn) async {
    final response = await http.get(Uri.http(
        arduinoIPAddress, 'toggleLed', {'state': isOn ? 'ON' : 'OFF'}));

    if (response.statusCode == 200) {
      setState(() {
        isLedOn = isOn;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Woofriend Control'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Administrador: Woofriend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              onChanged: (value) {
                arduinoIPAddress = value;
              },
              decoration: InputDecoration(
                labelText: 'Dirección IP del Arduino',
                hintText: 'Ej. 192.168.1.100',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isConnecting ? null : connectToArduino,
              child:
                  isConnecting ? CircularProgressIndicator() : Text('Conectar'),
            ),
            SizedBox(height: 20),
            if (isConnected)
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () => toggleLed(true),
                    child: Text('Encender LED'),
                  ),
                  ElevatedButton(
                    onPressed: () => toggleLed(false),
                    child: Text('Apagar LED'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
