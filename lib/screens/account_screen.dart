import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'home_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  // Chave para identificar e validar o formulário
  final _formKey = GlobalKey<FormState>();

  // Controladores para capturar o texto de cada campo
  final _userCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confPassCtrl = TextEditingController();

  @override
  void dispose() {
    // É importante limpar os controladores da memória ao sair da tela
    _userCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confPassCtrl.dispose();
    super.dispose();
  }

  void _criarConta() {
    // Valida se todos os TextFormField passaram nas regras
    if (_formKey.currentState!.validate()) {
      
      // Mostra o aviso de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conta criada com sucesso!'),
          backgroundColor: Color(0xFF52b788),
        ),
      );
      
      // Avança para a HomeScreen e passa o nome digitado
      // Usamos pushReplacement para substituir a tela atual, impedindo 
      // que o usuário volte para a tela de "Criar Conta" pelo botão de voltar do celular.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomeScreen(userName: _userCtrl.text.trim()),
        ),
      );
    }
  }

  // Estilo padronizado para as bordas das caixas de texto
  InputDecoration _buildDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF52b788)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF52b788), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF081c15), // Mantendo o fundo padrão do app
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF52b788)),
        title: Text(
          'Criar Nova Conta 🌱',
          style: GoogleFonts.playfairDisplay(color: Colors.white),
        ),
      ),
      // SingleChildScrollView previne o erro de tela estourada quando o teclado abre
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // --- 1. Nome de Usuário ---
              TextFormField(
                controller: _userCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _buildDecoration('Nome de usuário'),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira um nome de usuário.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // --- 2. Email ---
              TextFormField(
                controller: _emailCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _buildDecoration('Email'),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira um email.';
                  }
                  if (!value.contains('@')) {
                    return 'Insira um email válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // --- 3. Senha ---
              TextFormField(
                controller: _passCtrl,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _buildDecoration('Senha'),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira uma senha.';
                  }
                  if (value.length < 6) {
                    return 'A senha deve ter pelo menos 6 caracteres.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // --- 4. Confirmar Senha ---
              TextFormField(
                controller: _confPassCtrl,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _buildDecoration('Confirmar senha'),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _criarConta(), // Tenta salvar ao dar enter
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, confirme sua senha.';
                  }
                  // Aqui está a validação que exige que as senhas sejam iguais
                  if (value != _passCtrl.text) {
                    return 'As senhas não coincidem.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // --- Botão de Criar Conta ---
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF52b788),
                  foregroundColor: const Color(0xFF081c15),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _criarConta,
                child: const Text(
                  'Cadastrar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

