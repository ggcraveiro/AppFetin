import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../colors.dart';
import '../models/tree_model.dart';
import '../widgets/adopt_tree_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';

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
    {'label': '🔴 Ameaçadas', 'value': 'Ameaçada'},
    {'label': '🏞️ Mata ciliar', 'value': 'Mata ciliar'},
    {'label': '🌼 Floração', 'value': 'Floração'},
    {'label': '🐦 Atrai aves', 'value': 'Atrai aves'},
    {'label': '🐆 Alimenta a fauna', 'value': 'Alimenta a fauna'},
    {'label': '🌳 Grande porte', 'value': 'Grande porte'},
    {'label': '🌱 Recupera o solo', 'value': 'Recupera o solo'},
    {'label': '💨 Dispersão pelo vento', 'value': 'Dispersão pelo vento'},
    {'label': '🍃 Fixação de nitrogênio', 'value': 'Fixação de nitrogênio'},
    {'label': '🌰 Castanhas comestíveis', 'value': 'Castanhas comestíveis'},
    {'label': '🥭 Frutos comestíveis', 'value': 'Frutos comestíveis'},
  ];

  List<AdoptTreeModel> get _filtered {
    if (_activeFilter == 'Todos') return adoptTrees;
    if (_activeFilter == 'Ameaçada') return adoptTrees.where((t) => t.isEndangered).toList();
    
    // Verifica se a lista de 'tags' da árvore contém o filtro selecionado
    return adoptTrees.where((t) => t.tags.contains(_activeFilter)).toList();
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

  // Abre o modal para seleção da forma de pagamento antes de efetivar a adoção
  void _showPaymentModal(BuildContext context, AdoptTreeModel tree) {
    String selectedMethod = 'pix';

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.greenDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Confirmar Adoção',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Espécie: ${tree.name} (${tree.species})',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Valor: R\$ ${tree.priceMonthly.toStringAsFixed(2)}',
                    style: const TextStyle(color: AppColors.greenLight, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 20),
                  const Text('Forma de Pagamento:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  
                  RadioListTile<String>(
                    value: 'pix',
                    groupValue: selectedMethod,
                    activeColor: AppColors.greenLight,
                    title: const Text('PIX', style: TextStyle(color: Colors.white, fontSize: 13)),
                    secondary: const Text('⚡', style: TextStyle(fontSize: 18)),
                    onChanged: (val) => setModalState(() => selectedMethod = val!),
                  ),
                  
                  RadioListTile<String>(
                    value: 'card',
                    groupValue: selectedMethod,
                    activeColor: AppColors.greenLight,
                    title: const Text('Cartão de Crédito', style: TextStyle(color: Colors.white, fontSize: 13)),
                    secondary: const Text('💳', style: TextStyle(fontSize: 18)),
                    onChanged: (val) => setModalState(() => selectedMethod = val!),
                  ),
                  
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.greenLight,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _processAdoption(tree);
                      },
                      child: const Text('Pagar e Adotar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Grava a árvore no Firestore após a confirmação do pagamento
  Future<void> _processAdoption(AdoptTreeModel tree) async {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      _showToast('⚠️ Você precisa estar logado para adotar uma árvore.');
      return;
    }

    try {
      // 1. Gera a variação aleatória baseada na coordenada original da árvore
      final coords = MapLocationHelper.generateJitterCoordinates(
        tree.latitude,
        tree.longitude,
      );

      final treeData = {
        'userId': user.uid,
        'name': tree.name,
        'species': tree.species,
        'emoji': tree.emoji,
        'biome': tree.biome,
        'location': 'Vale do Sapucaí · MG',
        'progress': 0.1,
        'monthsPlanted': 1,
        'isEndangered': tree.isEndangered,
        'latitude': coords[0], // Coordenada Única Gerada
        'longitude': coords[1], // Coordenada Única Gerada
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Restante do método mantido idêntico...
      final globalDocRef = await FirebaseFirestore.instance
          .collection('trees')
          .add(treeData);

      final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await userDocRef
          .collection('trees')
          .doc(globalDocRef.id)
          .set(treeData);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDocRef);
        if (snapshot.exists) {
          int currentTrees = snapshot.data()?['treesPlanted'] ?? 0;
          int currentScore = snapshot.data()?['score'] ?? 0;

          transaction.update(userDocRef, {
            'treesPlanted': currentTrees + 1,
            'score': currentScore + (tree.isEndangered ? 50 : 20),
          });
        }
      });

      setState(() => tree.adopted = true);
      _showToast('🌱 Pagamento confirmado! ${tree.name} foi adotada com sucesso.');
    } catch (e) {
      _showToast('Erro ao processar adoção. Tente novamente.');
    }
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
                  onAdopt: () => _showPaymentModal(context, tree),
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
                        'Adotar Árvore',
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
              ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.trackpad,
                  },
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: _filters.map((f) {
                      final active = _activeFilter == f['value'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => setState(() => _activeFilter = f['value']!),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
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
                        ),
                      );
                    }).toList(),
                  ),
                ),
              )
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
      left: 20,
      right: 20,
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
                boxShadow: [
                  BoxShadow(color: AppColors.greenLight.withOpacity(0.5), blurRadius: 30),
                ],
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