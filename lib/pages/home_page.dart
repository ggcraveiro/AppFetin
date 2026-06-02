import 'package:flutter/material.dart';
import 'menu1_page.dart';
import 'menu2_page.dart';
import 'menu3_page.dart';
import 'menu4_page.dart';
import 'menu5_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Menu1Page(),
    const Menu2Page(),
    const Menu3Page(),
    const Menu4Page(),
    const Menu5Page(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoMind'),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.lightGreen,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.nature), label: 'Árvores'),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Incentivos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Seu perfil'),
        ],
      ),
    );
  }
}
