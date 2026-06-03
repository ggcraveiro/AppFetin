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
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'settings',
                  child: Text('Configurações'),
                ),
                const PopupMenuItem(
                  value: 'about',
                  child: Text('Sobre'),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Text('Fazer logout'),
                ),
              ];
            },
            onSelected: (String value) {
              // Handle menu item selection
              if (value == 'settings') {
                // Handle settings
              } else if (value == 'about') {
                // Handle about
              } else if (value == 'logout') {
                // Handle logout
              }
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF26592E),
        unselectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
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
