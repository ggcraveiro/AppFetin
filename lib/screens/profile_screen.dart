import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../colors.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;
  
  // O nome agora pode ser recebido. Coloquei um valor padrão caso você chame a tela sem passar o nome
  const ProfileScreen({super.key, this.userName = 'Dev'});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String get firstName => widget.userName.split(' ').first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greenDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        // O Flutter adiciona automaticamente o botão de voltar quando usamos o Navigator.push()
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
            const SizedBox(height: 32),
            _buildStatsCard(),
            const SizedBox(height: 32),
            _buildMenuItems(),
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

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          _buildStatItem('🌳', '4', 'Árvores'),
          _buildDivider(),
          _buildStatItem('🔥', '12', 'Dias Seguidos'),
          _buildDivider(),
          _buildStatItem('🏆', '#5', 'Ranking'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 20, 
              fontWeight: FontWeight.bold, 
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12, 
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1, 
      height: 40, 
      color: Colors.white.withOpacity(0.2),
    );
  }

  Widget _buildMenuItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configurações',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.greenMist,
          ),
        ),
        const SizedBox(height: 12),
        _buildListTile(Icons.language, 'Idioma', true),
        _buildListTile(Icons.security, 'Privacidade', true),
        _buildListTile(Icons.help_outline, 'Ajuda e Suporte', true),
        const SizedBox(height: 16),
        _buildListTile(Icons.logout, 'Sair da conta', false, isDestructive: true),
        _buildListTile(Icons.delete_forever, 'Deletar conta', false, isDestructive: true),
      ],
    );
  }

  Widget _buildListTile(IconData icon, String title, bool showTrailing, {bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(
          icon, 
          color: isDestructive ? Colors.redAccent : AppColors.greenLight,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.redAccent : Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: showTrailing 
          ? Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.4)) 
          : null,
        onTap: () {
          // Ação correspondente do item (Ex: se isDestructive for true, deslogar o usuário)
        },
      ),
    );
  }
}