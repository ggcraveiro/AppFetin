import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../colors.dart';
import '../main.dart'; // Necessário para acessar o SplashRouter
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;
  
  const ProfileScreen({super.key, this.userName = 'Usuário'});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String get firstName => widget.userName.split(' ').first;

  // Função para deslogar do aplicativo
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('raizes_name');
    
    // Desloga do Firebase também para resetar a sessão
    await FirebaseAuth.instance.signOut();
    
    if (!mounted) return;
    
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SplashRouter()),
      (route) => false,
    );
  }

  // Função para acionar o fluxo de confirmação com PIN e exclusão
  void _deleteAccount() {
    _confirmAndDeleteAccount(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greenDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white), 
        title: Text(
          'Meu Perfil',
          style: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            onPressed: () {
              // Ação para editar o perfil
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildProfileAvatar(),
            const SizedBox(height: 16),
            _buildUserInfo(),
            const SizedBox(height: 48),
            _buildActionOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 100, 
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.greenLight, AppColors.greenMain],
              begin: Alignment.topLeft, 
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.white24, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppColors.greenMain.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              firstName[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 40, 
                fontWeight: FontWeight.bold, 
                color: Colors.white,
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.greenDeep,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24, width: 1.5),
          ),
          child: const Icon(
            Icons.camera_alt, 
            color: Colors.white70, 
            size: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Column(
      children: [
        Text(
          widget.userName,
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Membro desde Agosto, 2026',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildActionOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Controle da Conta',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.greenMist,
              letterSpacing: 1.2,
            ),
          ),
        ),
        _buildListTile(
          icon: Icons.manage_accounts, 
          title: 'Alterar nome de usuário', 
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _buildListTile(
          icon: Icons.sync_lock, 
          title: 'Alterar senha', 
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _buildListTile(
          icon: Icons.logout, 
          title: 'Sair da conta', 
          onTap: _logout,
        ),
        const SizedBox(height: 12),
        _buildListTile(
          icon: Icons.delete_forever, 
          title: 'Deletar conta', 
          isDestructive: true, 
          onTap: _deleteAccount,
        ),
      ],
    );
  }

  Widget _buildListTile({
    required IconData icon, 
    required String title, 
    required VoidCallback onTap, 
    bool isDestructive = false
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDestructive ? Colors.redAccent.withOpacity(0.1) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: isDestructive ? Border.all(color: Colors.redAccent.withOpacity(0.3)) : null,
      ),
      child: ListTile(
        leading: Icon(
          icon, 
          color: isDestructive ? Colors.redAccent : Colors.white70,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.redAccent : Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

Future<void> _confirmAndDeleteAccount(BuildContext context) async {
  final String pinCode = (1000 + Random().nextInt(9000)).toString();
  final TextEditingController inputController = TextEditingController();
  bool isCodeCorrect = false;

  await showDialog(
    context: context,
    builder: (dialogCtx) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: AppColors.greenDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text(
              'Excluir Conta?',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Esta ação é irreversível e apagará todos os seus dados e árvores adotadas.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 16),
                Text(
                  'Para confirmar, digite o código abaixo:',
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                ),
                const SizedBox(height: 8),
                
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.greenLight.withOpacity(0.4)),
                  ),
                  child: Center(
                    child: Text(
                      pinCode,
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 6,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: inputController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 4),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '----',
                    hintStyle: const TextStyle(color: Colors.white30, letterSpacing: 4),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) {
                    setStateDialog(() {
                      isCodeCorrect = (val.trim() == pinCode);
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Cancelar', style: TextStyle(color: Colors.white60)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  disabledBackgroundColor: Colors.redAccent.withOpacity(0.3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: isCodeCorrect
                    ? () async {
                        Navigator.pop(dialogCtx);
                        await _deleteUserDataAndAccount(context);
                      }
                    : null,
                child: const Text('Excluir Definitivamente', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<void> _deleteUserDataAndAccount(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) return;

  // 1. Exibe o indicador de carregamento
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(
      child: CircularProgressIndicator(color: AppColors.greenLight),
    ),
  );

  try {
    final uid = user.uid;

    // 2. Apaga a subcoleção de árvores do Firestore
    final treesDocs = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('trees')
        .get();

    for (var doc in treesDocs.docs) {
      await doc.reference.delete();
    }

    // 3. Apaga o documento principal do usuário no Firestore
    await FirebaseFirestore.instance.collection('users').doc(uid).delete();

    // 4. Limpa as preferências locais
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('raizes_name');

    // 5. Deleta a conta do Firebase Auth e encerra a sessão
    await user.delete();
    await FirebaseAuth.instance.signOut();

    // 6. Encerra completamente o aplicativo
    await SystemNavigator.pop();

  } on FirebaseAuthException catch (e) {
    // Fecha o modal de carregamento caso ocorra um erro
    if (context.mounted && Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }

    if (e.code == 'requires-recent-login') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por segurança, faça login novamente antes de excluir a conta.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao apagar conta: ${e.message}')),
      );
    }
  } catch (e) {
    if (context.mounted && Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro inesperado: $e')),
    );
  }
}