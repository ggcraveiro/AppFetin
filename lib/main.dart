import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoMind',
      theme: ThemeData(primarySwatch: Colors.lightGreen),
      home: HomePage(), // Referência à sua primeira tela
    );
  }
}
