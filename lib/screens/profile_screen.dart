import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../colors.dart';
import '../main.dart'; // Necessário para acessar o SplashRouter

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
    // Acessa o armazenamento local
    final prefs = await SharedPreferences.getInstance();
    
    // Remove o nome salvo para que o app exija login novamente
    await prefs.remove('raizes_name');
    
    if (!mounted) return;
    
    // pushAndRemoveUntil limpa todo o histórico de navegação para que o 
    // usuário não possa voltar ao perfil clicando no botão "voltar" do celular
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SplashRouter()),
      (route) => false,
    );
  }

  // Função para deletar a conta (com confirmação)
  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1b4332),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Deletar Conta', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Tem certeza que deseja deletar sua conta permanentemente? Esta ação não pode ser desfeita.', 
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(), // Apenas fecha o aviso
            child: const Text('Cancelar', style: TextStyle(color: AppColors.greenLight)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              // Por enquanto, deletar a conta faz o mesmo que o logout.
              // Futuramente você pode adicionar a lógica de apagar do banco de dados aqui.
              _logout(); 
            },
            child: const Text('Deletar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
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
            const SizedBox(height: 48), // Espaço extra antes da área de perigo
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

  // Área com os botões de controle da conta
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
          onTap: _logout,
        ),
        const SizedBox(height: 12),
        _buildListTile(
          icon: Icons.sync_lock, 
          title: 'Alterar senha', 
          onTap: _logout,
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

  // Componente reutilizável para os botões do final
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