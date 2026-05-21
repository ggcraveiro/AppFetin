import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const RaizesApp());
}

class RaizesApp extends StatelessWidget {
  const RaizesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Raízes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.dmSansTextTheme().apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF52b788),
          surface: const Color(0xFF081c15),
        ),
      ),
      home: const SplashRouter(),
    );
  }
}

class SplashRouter extends StatefulWidget {
  const SplashRouter({super.key});

  @override
  State<SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<SplashRouter> {
  @override
  void initState() {
    super.initState();
    _checkName();
  }

  Future<void> _checkName() async {
    final prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString('raizes_name');
    if (!mounted) return;
    if (name == null || name.isEmpty) {
      final result = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const _NameDialog(),
      );
      name = result ?? 'Visitante';
      await prefs.setString('raizes_name', name);
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomeScreen(userName: name!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF081c15),
      body: Center(child: CircularProgressIndicator(color: Color(0xFF52b788))),
    );
  }
}

class _NameDialog extends StatefulWidget {
  const _NameDialog();

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1b4332),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Bem-vindo ao Raízes 🌱',
        style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 18),
      ),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Qual o seu nome?',
          hintStyle: TextStyle(color: Colors.white38),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF52b788)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF52b788), width: 2),
          ),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: _submit,
          child: const Text('Entrar', style: TextStyle(color: Color(0xFF52b788))),
        ),
      ],
    );
  }

  void _submit() {
    Navigator.of(context).pop(_ctrl.text.trim().isEmpty ? 'Visitante' : _ctrl.text.trim());
  }
}
