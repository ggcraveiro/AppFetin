import 'package:flutter/foundation.dart'; // Importante para usar kIsWeb
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
import 'incentives_screen.dart';
import 'map_screen.dart';
import 'package:url_launcher/url_launcher.dart';

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
  String _displayName = '';

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
    _loadUserRealName();

    _heroCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroSlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutCubic));
    _heroCtrl.forward();
  }

  Future<void> _loadUserRealName() async {
    if (_displayName.isEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (user.displayName != null && user.displayName!.isNotEmpty) {
          setState(() {
            _displayName = user.displayName!;
          });
          return;
        }

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
    Widget content = Scaffold(
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

    if (kIsWeb) {
      return content;
    }

    return PopScope(
      canPop: false,
      child: content,
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
        GestureDetector(
          onTap: () {
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

    return StreamBuilder<QuerySnapshot>(
      // Escuta em tempo real a coleção de árvores do usuário
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('trees')
          .snapshots(),
      builder: (context, treesSnapshot) {
        final int realTreesCount = treesSnapshot.data?.docs.length ?? 0;

        // Mantém o campo 'treesPlanted' do documento principal sincronizado com o total real de árvores
        if (user != null && treesSnapshot.hasData) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'treesPlanted': realTreesCount});
        }

        return FutureBuilder<int>(
          future: LeaderboardService().getCurrentUserRank(),
          builder: (context, rankSnapshot) {
            String rankValue = '...';
            if (rankSnapshot.hasData) {
              rankValue = '${rankSnapshot.data}º';
            }

            return ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withOpacity(0.18)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Row(
                  children: [
                    _impactStat('🌳', '$realTreesCount', 'Árvores\nadotadas',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const MapScreen()),
                        );
                      },
                    ),
                    _impactDivider(),
                    
                    _impactStat(
                      '📊', rankValue, 'posição\nno ranking',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
                        );
                      },
                    ),
                    _impactDivider(),

                    _impactStat(
                      '🏔️', 'MG', 'Mata\nAtlântica',
                      onTap: () => _showBiomeInfoModal(context),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _impactStat(String icon, String value, String label, {VoidCallback? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
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
        ),
      ),
    );
  }

  Widget _impactDivider() {
    return Container(width: 1, height: 44, color: Colors.white.withOpacity(0.2), margin: const EdgeInsets.symmetric(horizontal: 4));
  }

  void _showBiomeInfoModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1160, maxHeight: 700),
            decoration: BoxDecoration(
              color: AppColors.greenDark,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: kIsWeb 
                    ? _buildWebBiomeContent()
                    : _buildMobileBiomeContent(),
                ),

                Positioned(
                  top: 12,
                  right: 12,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70, size: 22),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Layout WEB
  Widget _buildWebBiomeContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset(
                    'assets/images/mataAtlanticaImage.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.white.withOpacity(0.08),
                        child: const Icon(Icons.forest, color: Colors.white38, size: 48),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Serra da Bocaina, na divisa dos estados de São Paulo e Rio de Janeiro',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            child: _buildBiomeTextContent(),
          ),
        ),
      ],
    );
  }

  // Layout MOBILE
  Widget _buildMobileBiomeContent() {
    return Column(
      children: [
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'assets/images/mataAtlanticaImage.jpg',
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 160,
                color: Colors.white.withOpacity(0.08),
                child: const Icon(Icons.forest, color: Colors.white38, size: 48),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Serra da Bocaina, na divisa dos estados de SP e RJ',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.6),
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: _buildBiomeTextContent(),
          ),
        ),
      ],
    );
  }

  // Texto completo idêntico em ambas as plataformas
  Widget _buildBiomeTextContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mata Atlântica',
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'A Mata Atlântica é o principal bioma da costa leste do Brasil, abrangendo principalmente '
          'os estados da região Sudeste e Sul. É aqui que ficam as bacias dos principais rios '
          'brasileiros, e uma biodiversidade gigantesca, com milhares de espécies. No estado de '
          'Minas Gerais, estão abrigados 70% dos mamíferos de todo o bioma, além de diversos tipos '
          'de vegetação. \n\nInfelizmente, a Mata Atlântica também é um dos biomas mais ameaçados '
          'do país, sendo que resta apenas 15,3% de toda sua cobertura original no território nacional. '
          'Em Minas, a situação é ainda mais crítica, com apenas 7% da cobertura original preservada. '
          'Os principais pontos de reservas são o Vale do Rio Doce, Vale do Jequitinhonha, e a região '
          'sul do estado, próxima à Serra da Mantiqueira. \n\nNos anos de 2021 e 2022, Minas foi o '
          'estado que mais desmatou árvores do bioma. Em um mundo cada vez mais ameaçado pelas mudanças '
          'climáticas (como o El Niño que irá atingir recordes históricos nos próximos meses), é '
          'essencial que o ecossistema seja preservado e reflorestado.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.85),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () async {
                final Uri url = Uri.parse('https://pt.wikipedia.org/wiki/Mata_Atl%C3%A2ntica');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Saiba mais sobre a Mata Atlântica',
                      style: TextStyle(
                        color: AppColors.greenLight,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.open_in_new, size: 14, color: AppColors.greenLight),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Fontes: SOS Mata Atlântica, IBGE, Reserva da Biosfera da Mata Atlântica, G1',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        )
      ],
    );
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
        return FutureBuilder<int>(
          future: LeaderboardService().getCurrentUserRank(),
          builder: (context, rankSnapshot) {
            int rank = rankSnapshot.data ?? 0;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _chip('🏆 #${rank > 0 ? rank : '-'} no ranking', AppColors.gold),
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
          // 1. TRATAMENTO DE ERRO (Importante para o celular físico)
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Erro ao carregar árvores: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            );
          }

          // 2. CARREGANDO
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.greenLight),
            );
          }

          // 3. SEM ÁRBORES CADASTRADAS NO BANCO
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Nenhuma árvore encontrada para esta conta.\nClique no círculo 🌱 abaixo para cadastrar a primeira!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 13),
                ),
              ),
            );
          }

          // 4. LISTA COM CARDS
          final treeDocs = snapshot.data!.docs;

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: treeDocs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              try {
                final tree = TreeModel.fromFirestore(treeDocs[i]);

                return MyTreeCard(
                  tree: tree, 
                  delay: Duration(milliseconds: 350 + i * 80),
                );
              } catch (e) {
                // Caso ocorra erro no parse do documento no APK release
                return Container(
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(Icons.error_outline, color: Colors.orange),
                  ),
                );
              }
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
                  Text('Espécies nativas do Vale do Sapucaí',
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
      null,
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
                } else if (item['label'] == 'Mapa') {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MapScreen()),
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