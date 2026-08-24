import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../colors.dart';
import '../models/tree_model.dart';
import '../widgets/adopt_tree_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  

class AdoptScreen extends StatefulWidget {
  const AdoptScreen({super.key});

  @override
  State<AdoptScreen> createState() => _AdoptScreenState();
}

class _AdoptScreenState extends State<AdoptScreen> {
  String _activeFilter = 'Todos';
  OverlayEntry? _toastEntry;

  final List<Map<String, String>> _filters = [
    {'label': 'Todas', 'value': 'Todos'},
    {'label': '🏞️ Mata Ciliar', 'value': 'Mata Ciliar'},
    {'label': '🌳 Mata Atlântica', 'value': 'Mata Atlântica'},
    {'label': '⛰️ Serra', 'value': 'Serra'},
    {'label': '💧 Várzea', 'value': 'Várzea'},
    {'label': '🔴 Ameaçadas', 'value': 'Ameaçada'},
  ];

  List<AdoptTreeModel> get _filtered {
    if (_activeFilter == 'Todos') return adoptTrees;
    if (_activeFilter == 'Ameaçada') return adoptTrees.where((t) => t.isEndangered).toList();
    return adoptTrees.where((t) => t.biome == _activeFilter).toList();
  }

  void _showToast(String msg) {
    _toastEntry?.remove();
    _toastEntry = OverlayEntry(
      builder: (_) => _ToastWidget(message: msg),
    );
    Overlay.of(context).insert(_toastEntry!);
    Future.delayed(const Duration(milliseconds: 3500), () {
      _toastEntry?.remove();
      _toastEntry = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greenDeep,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final tree = _filtered[i];
                return AdoptTreeCardWidget(
                  tree: tree,
                  delay: Duration(milliseconds: 40 + i * 60),
                  onAdopt: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    
                    if (user == null) {
                      _showToast('⚠️ Você precisa estar logado para adotar uma árvore.');
                      return;
                    }

                    try {
                      final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
                      
                      // Executamos as operações em batch ou sequencialmente:
                      // 1. Adiciona a árvore na subcoleção de árvores do usuário
                      await userDocRef.collection('trees').add({
                        'name': tree.name,
                        'species': tree.species,
                        'emoji': tree.emoji,
                        'biome': tree.biome,
                        'location': 'Vale do Sapucaí · MG',
                        'progress': 0.1, // Começa com progresso inicial
                        'monthsPlanted': 1,
                        'isEndangered': tree.isEndangered,
                        'createdAt': FieldValue.serverTimestamp(),
                      });

                      // 2. Incrementa o contador de árvores plantadas e atualiza o ranking no documento do usuário
                      await FirebaseFirestore.instance.runTransaction((transaction) async {
                        final snapshot = await transaction.get(userDocRef);
                        if (snapshot.exists) {
                          int currentTrees = snapshot.data()?['treesPlanted'] ?? 0;
                          // Opcional: Se você usa um campo de 'score' ou 'points' para o ranking, pode somar aqui também
                          int currentScore = snapshot.data()?['score'] ?? 0;

                          transaction.update(userDocRef, {
                            'treesPlanted': currentTrees + 1,
                            'score': currentScore + (tree.isEndangered ? 50 : 20), // Ex: árvores ameaçadas dão mais pontos no ranking
                          });
                        }
                      });

                      setState(() => tree.adopted = true);
                      _showToast('🌱 ${tree.name} adotada(o)! Sua floresta e ranking foram atualizados.');
                    } catch (e) {
                      _showToast('Erro ao adotar árvore. Tente novamente.');
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 38, height: 38,
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
                        'Adotar Árvore 🌿',
                        style: GoogleFonts.playfairDisplay(fontSize: 22, color: Colors.white),
                      ),
                      Text(
                        'Espécies nativas do Vale do Sapucaí · Sul de Minas',
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
                            fontSize: 11, fontWeight: FontWeight.w600,
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
}

class _ToastWidget extends StatefulWidget {
  final String message;
  const _ToastWidget({required this.message});

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100,
      left: 20, right: 20,
      child: Material(
        color: Colors.transparent,
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.greenLight,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppColors.greenLight.withOpacity(0.5), blurRadius: 30)],
              ),
              child: Text(
                widget.message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
