import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../colors.dart';

class IncentiveModel {
  final String title;
  final String partner;
  final String imagePath;
  final String category;
  final int requiredTrees;
  final String description;

  IncentiveModel({
    required this.title,
    required this.partner,
    required this.imagePath,
    required this.category,
    required this.requiredTrees,
    required this.description,
  });
}

// Lista inicial de incentivos por metas de árvores
final List<IncentiveModel> sampleIncentives = [
  IncentiveModel(
    title: 'Benefício A',
    partner: 'Prefeitura Municipal de Santa Rita do Sapucaí',
    imagePath: 'assets/images/govMunSantaRitadoSapucai.jpg',
    category: 'Benefício Fiscal',
    requiredTrees: 1,
    description: 'Ainda não há uma descrição.',
  ),
  IncentiveModel(
    title: 'Benefício B',
    partner: 'Governo do Estado de Minas Gerais',
    imagePath: 'assets/images/govEstMinasGerai.png',
    category: 'Benefício Fiscal',
    requiredTrees: 4,
    description: 'Ainda não há uma descrição.',
  ),
  IncentiveModel(
    title: 'Benefício C',
    partner: 'Governo do Estado de Minas Gerais',
    imagePath: 'assets/images/govEstMinasGerais.png',
    category: 'Benefício Fiscal',
    requiredTrees: 6,
    description: 'Ainda não há uma descrição.',
  ),
  IncentiveModel(
    title: 'Benefício D',
    partner: 'Governo Federal',
    imagePath: 'assets/images/govNacional.png',
    category: 'Benefício Fiscal',
    requiredTrees: 9,
    description: 'Ainda não há uma descrição.',
  ),
];

class IncentivesScreen extends StatefulWidget {
  const IncentivesScreen({super.key});

  @override
  State<IncentivesScreen> createState() => _IncentivesScreenState();
}

class _IncentivesScreenState extends State<IncentivesScreen> {
  String _activeFilter = 'Todos';

  final List<Map<String, String>> _filters = [
    {'label': 'Todos', 'value': 'Todos'},
    {'label': '📜 Impostos', 'value': 'Benefício Fiscal'},
  ];

  List<IncentiveModel> get _filtered {
    if (_activeFilter == 'Todos') return sampleIncentives;
    return sampleIncentives.where((i) => i.category == _activeFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.greenDeep,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
        builder: (context, snapshot) {
          int userTrees = 0;
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            userTrees = data['treesPlanted'] ?? 0;
          }

          return Column(
            children: [
              _buildHeader(userTrees),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final item = _filtered[i];
                    return _buildIncentiveCard(item, userTrees);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(int userTrees) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.greenDark, AppColors.greenMid],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
                      ),
                      child: const Center(
                        child: Text('←', style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Incentivos e Recompensas 🎁',
                        style: GoogleFonts.playfairDisplay(fontSize: 22, color: Colors.white),
                      ),
                      Text(
                        'Adote árvores e libere benefícios exclusivos',
                        style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.55)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters.map((f) {
                    final active = _activeFilter == f['value'];
                    return GestureDetector(
                      onTap: () => setState(() => _activeFilter = f['value']!),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                        decoration: BoxDecoration(
                          color: active ? AppColors.greenLight : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: active ? AppColors.greenLight : Colors.white.withOpacity(0.15),
                          ),
                        ),
                        child: Text(
                          f['label']!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: active ? Colors.white : Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncentiveCard(IncentiveModel item, int userTrees) {
    final bool isUnlocked = userTrees >= item.requiredTrees;
    final double progress = (userTrees / item.requiredTrees).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isUnlocked
              ? Colors.white.withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Container da imagem com tratamento de erro
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(8),
            child: Image.asset(
              item.imagePath,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Center(
                child: Text(
                  isUnlocked ? '🎁' : '🔒',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? Colors.white : Colors.white60,
                        ),
                      ),
                    ),
                    if (isUnlocked)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.greenLight.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Liberado 🎉',
                          style: TextStyle(fontSize: 10, color: AppColors.greenLight, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.partner,
                  style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5)),
                ),
                const SizedBox(height: 10),

                // Mini Barra de Progresso por Adoções
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isUnlocked
                              ? 'Objetivo alcançado!'
                              : '$userTrees de ${item.requiredTrees} árvores',
                          style: TextStyle(
                            fontSize: 10,
                            color: isUnlocked ? AppColors.greenLight : Colors.white70,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isUnlocked ? AppColors.greenLight : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isUnlocked ? AppColors.greenLight : AppColors.gold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}