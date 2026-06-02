import 'package:flutter/material.dart';

class Menu1Page extends StatelessWidget {
  const Menu1Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Este é o menu principal do aplicativo EcoMind. Funcionalidades serão adicionadas aqui!'),
          const SizedBox(height: 80), // Space to position button below center
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            onPressed: () {
              // Add button action here
            },
            child: const Text(
              'Home Menu Button',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
