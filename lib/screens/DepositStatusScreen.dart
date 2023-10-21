import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DepositStatusScreen extends StatefulWidget {
  const DepositStatusScreen({super.key});

  @override
  _DepositStatusScreenState createState() => _DepositStatusScreenState();
}

class _DepositStatusScreenState extends State<DepositStatusScreen> {
  double depositPercentage = 0.0; // Porcentaje de llenado

  Future<void> fetchDepositStatus() async {
    try {
      final response = await http.get(Uri.parse('deposit_capacity'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          depositPercentage = data[
              'depositPercentage']; // Asume que Arduino envía el porcentaje
        });
      } else {
        // En caso de que la solicitud no sea exitosa, muestra un mensaje de error
        showErrorDialog(
            'No se pudo consultar el nivel de llenado. Intente más tarde.');
      }
    } catch (error) {
      // En caso de un error de red u otro error, muestra un mensaje de error
      showErrorDialog('Ocurrió un error. Intente más tarde.');
    }
  }

  void showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
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

  @override
  void initState() {
    super.initState();
    fetchDepositStatus(); // Realiza la solicitud al ingresar a la pantalla
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estado del Depósito'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Nivel de llenado del depósito',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: depositPercentage / 100, // Normaliza el valor entre 0 y 1
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              backgroundColor: Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              '$depositPercentage%', // Muestra el porcentaje actual
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
