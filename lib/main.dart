import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart';
import 'providers/theme_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'EcoMind',
            theme: ThemeData(
              primarySwatch: Colors.lightGreen,
              brightness: Brightness.light,
              scaffoldBackgroundColor: Colors.white,
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: Colors.black),
                bodyMedium: TextStyle(color: Colors.black),
                bodySmall: TextStyle(color: Colors.black),
              ),
            ),
            darkTheme: ThemeData(
              primarySwatch: Colors.lightGreen,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF121212),
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: Color(0xFFE0E0E0)),
                bodyMedium: TextStyle(color: Color(0xFFE0E0E0)),
                bodySmall: TextStyle(color: Color(0xFFE0E0E0)),
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF121212),
                foregroundColor: Color(0xFFE0E0E0),
              ),
              listTileTheme: const ListTileThemeData(
                textColor: Color(0xFFE0E0E0),
              ),
              dividerColor: const Color(0xFF333333),
            ),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const HomePage(),
          );
        },
      ),
    );
  }
}
