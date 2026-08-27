import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../colors.dart';
import '../models/tree_model.dart';
import '../widgets/floating_leaf.dart';
import '../widgets/my_tree_card.dart';
import 'adopt_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import '../services/leaderboard_service.dart';
import 'leaderboard_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'incentives_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
late AnimationController _heroCtrl;
  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;

  int _navIndex = 0;
  
  // Criamos uma variável de estado para armazenar o nome real do usuário
  String _displayName = '';

  // O getter firstName agora verifica se temos o nome buscado, senão usa o widget.userName ou um padrão
  String get firstName {
    if (_displayName.isNotEmpty) {
      return _displayName.split(' ').first;
    }
    if (widget.userName.isNotEmpty) {
      return widget.userName.split(' ').first;
    }
    return 'Explorador';
  }

  @override
  void initState() {
    super.initState();
    _displayName = widget.userName;
    _loadUserRealName(); // <--- Busca o nome caso venha vazio do login por email

    _heroCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroSlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutCubic));
    _heroCtrl.forward();
  }

  // Função que busca o nome no Firestore se o widget.userName estiver vazio
  Future<void> _loadUserRealName() async {
    if (_displayName.isEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Tenta pegar pelo displayName do Auth primeiro
        if (user.displayName != null && user.displayName!.isNotEmpty) {
          setState(() {
            _displayName = user.displayName!;
          });
          return;
        }

        // Se não tiver, busca no documento do Firestore
        try {
          final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
          if (doc.exists && doc.data() != null) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['name'] != null) {
              setState(() {
                _displayName = data['name'];
              });
            }
          }
        } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    super.dispose();
  }

  void _goToAdopt() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => const AdoptScreen(),
        transitionsBuilder: (_, anim, __, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greenDeep,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHero()),
                SliverToBoxAdapter(child: _buildBody()),
              ],
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.greenDark, AppColors.greenMid, AppColors.greenMain],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Decorative glow
          Positioned(
            top: -60, right: -60,
            child: Container(
              width: 220, height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.greenLight.withOpacity(0.25),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          // Floating leaves
          const FloatingLeaf(emoji: '🍃', leftFraction: 0.15, delay: Duration.zero, size: 14),
          const FloatingLeaf(emoji: '🌿', leftFraction: 0.50, delay: Duration(seconds: 2), size: 18),
          const FloatingLeaf(emoji: '🍀', leftFraction: 0.75, delay: Duration(seconds: 4), size: 12),
          const FloatingLeaf(emoji: '🍃', leftFraction: 0.30, delay: Duration(seconds: 1), size: 16),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
              child: FadeTransition(
                opacity: _heroFade,
                child: SlideTransition(
                  position: _heroSlide,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroTop(),
                      const SizedBox(height: 24),
                      _buildImpactCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroTop() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🌱 EcoMind · Sul de Minas',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 2.5,
                  color: AppColors.greenPale,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Olá, seja bem-vindo(a)! 👋',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        // Adicionamos o GestureDetector aqui envolvendo a Stack
        GestureDetector(
          onTap: () {
            // Navega para a tela de perfil quando clicado
            Navigator.of(context).push(
              MaterialPageRoute(
              builder: (_) => ProfileScreen(userName: widget.userName), 
              ),
            );
          },
          child: Stack(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.greenLight, AppColors.greenMain],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.white24, width: 2),
                ),
                child: Center(
                  child: Text(
                    firstName[0].toUpperCase(),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
              Positioned(
                top: 0, right: 0,
                child: Container(
                  width: 13, height: 13,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.greenDark, width: 2.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

Widget _buildImpactCard() {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      // Ouve em tempo real as mudanças no documento do usuário logado no Firestore
      stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
      builder: (context, userSnapshot) {
        int treesCount = 0;
        
        if (userSnapshot.hasData && userSnapshot.data!.exists) {
          final data = userSnapshot.data!.data() as Map<String, dynamic>;
          treesCount = data['treesPlanted'] ?? 0;
        }

        return FutureBuilder<int>(
          future: LeaderboardService().getCurrentUserRank(),
          builder: (context, rankSnapshot) {
            String rankValue = '...';
            if (rankSnapshot.hasData) {
              rankValue = '${rankSnapshot.data}º';
            }

            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white.withOpacity(0.18)),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Árvores adotadas dinâmicas
                      _impactStat('🌳', '$treesCount', 'Árvores\nadotadas'),
                      _impactDivider(),
                      // Posição no ranking dinâmica
                      _impactStat('📊', rankValue, 'posição\nno ranking'),
                      _impactDivider(),
                      _impactStat('🏔️', 'MG', 'Mata\nAtlântica'),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _impactStat(String icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.playfairDisplay(
              fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.65), height: 1.3),
          ),
        ],
      ),
    );
  }

  Widget _impactDivider() {
    return Container(width: 1, height: 44, color: Colors.white.withOpacity(0.2), margin: const EdgeInsets.symmetric(horizontal: 4));
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        _buildChips(),
        const SizedBox(height: 28),
        _buildSectionHeader('Suas Árvores', 'Ver todas', _goToAdopt),
        const SizedBox(height: 14),
        _buildTreeScroll(),
        const SizedBox(height: 8),
        _buildAdoptBanner(),
        const SizedBox(height: 24),
      ],
    );
  }

Widget _buildChips() {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
      builder: (context, snapshot) {
        int streak = 0;
        
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          streak = data['streak'] ?? 0; // Puxa a sequência salva no Firestore
        }

        return FutureBuilder<int>(
          future: LeaderboardService().getCurrentUserRank(),
          builder: (context, rankSnapshot) {
            int rank = rankSnapshot.data ?? 0;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Chip de Rank dinâmico
                  _chip('🏆 Rank #${rank > 0 ? rank : '-'}', AppColors.gold),
                  const SizedBox(width: 8),
                  // Chip de Sequência dinâmico
                  _chip('🔥 $streak dias seguidos', AppColors.coral),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.33)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildSectionHeader(String title, String link, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.playfairDisplay(fontSize: 19, color: AppColors.greenMist)),
          GestureDetector(
            onTap: onTap,
            child: Text(
              link,
              style: const TextStyle(
                fontSize: 12, color: AppColors.greenLight,
                fontWeight: FontWeight.w600, decoration: TextDecoration.underline,
                decorationColor: AppColors.greenLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildTreeScroll() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text('Faça login para ver suas árvores.', style: TextStyle(color: Colors.white70)),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('trees')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.greenLight),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Sua floresta está limpa e pronta para começar! Adote sua primeira árvore abaixo. 🌱',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 13),
                ),
              ),
            );
          }

          final treeDocs = snapshot.data!.docs;

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: treeDocs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, i) {
              final treeData = treeDocs[i].data() as Map<String, dynamic>;
              final tree = TreeModel.fromMap(treeData);

              return MyTreeCard(
                tree: tree, 
                delay: Duration(milliseconds: 350 + i * 80),
              );
            },
          );
        },
      ),
    );
  }
  
  Widget _buildAdoptBanner() {
    return GestureDetector(
      onTap: _goToAdopt,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.greenMid, AppColors.greenMain],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.greenLight.withOpacity(0.35)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 14, offset: const Offset(0, 6))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🌿 Reflorestamento local',
                    style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.65), letterSpacing: 1.5)),
                  const SizedBox(height: 5),
                  Text('Adotar uma Árvore',
                    style: GoogleFonts.playfairDisplay(fontSize: 18, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text('8 espécies nativas do Vale do Sapucaí',
                    style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6))),
                ],
              ),
            ),
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
              ),
              child: const Center(child: Text('→', style: TextStyle(fontSize: 20, color: Colors.white))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': '🌳', 'label': 'Floresta'},
      {'icon': '🗺️', 'label': 'Mapa'},
      null, // FAB placeholder
      {'icon': '💰', 'label': 'Incentivos'},
      {'icon': '⚙️', 'label': 'Configurações'},
    ];

    return Container(
      height: 82,
      decoration: BoxDecoration(
        color: AppColors.greenDark,
        border: Border(top: BorderSide(color: AppColors.greenLight.withOpacity(0.15))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ...items.asMap().entries.map((e) {
            final i = e.key;
            final item = e.value;
            
            if (item == null) {
              // Botão central (FAB)
              return GestureDetector(
                onTap: _goToAdopt,
                child: Transform.translate(
                  offset: const Offset(0, -18),
                  child: Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.greenLight, AppColors.greenMain],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      boxShadow: [BoxShadow(color: AppColors.greenLight.withOpacity(0.45), blurRadius: 24, spreadRadius: 2)],
                    ),
                    child: const Center(child: Text('🌱', style: TextStyle(fontSize: 26))),
                  ),
                ),
              );
            }

            final navI = i > 2 ? i - 1 : i;
            final active = _navIndex == navI;
            
            return GestureDetector(
              onTap: () {
                if (item['label'] == 'Configurações') {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                } else if (item['label'] == 'Incentivos') {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const IncentivesScreen()),
                  );
                } else {
                  setState(() => _navIndex = navI);
                }
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
                decoration: BoxDecoration(
                  color: active ? AppColors.greenLight.withOpacity(0.18) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(item['icon']!, style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 3),
                    Text(
                      item['label']!,
                      style: TextStyle(
                        fontSize: 9, fontWeight: FontWeight.w600,
                        color: active ? AppColors.greenLight : AppColors.greenMain,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
