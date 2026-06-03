import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'menu1_page.dart';
import 'menu2_page.dart';
import 'menu3_page.dart';
import 'menu4_page.dart';
import 'menu5_page.dart';
import 'settings_page.dart';
import 'about_page.dart';
import 'logout_page.dart';
import '../providers/theme_provider.dart';

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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
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
                  if (value == 'settings') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsPage()),
                    );
                  } else if (value == 'about') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AboutPage()),
                    );
                  } else if (value == 'logout') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LogoutPage()),
                    );
                  }
                },
              ),
            ],
          ),
          body: _pages[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: themeProvider.isDarkMode ? const Color(0xFF121212) : Colors.white,
            selectedItemColor: Colors.lightGreen,
            unselectedItemColor: themeProvider.isDarkMode ? const Color(0xFFE0E0E0) : Colors.black,
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
      },
    );
  }
}
