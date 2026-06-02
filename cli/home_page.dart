import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoMind'),
        // O verde (lightGreen) definido no main.dart será aplicado aqui automaticamente
      ),
      body: const Center(
        child: Text('Bem-vindo ao EcoMind! A base está pronta.'),
      ),
    );
  }
}
