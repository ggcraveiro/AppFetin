import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../colors.dart';
import '../models/tree_model.dart';
import '../services/app_language.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LatLng _centroVale = const LatLng(-22.2516, -45.7042);

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.greenDeep,
      appBar: AppBar(
        backgroundColor: AppColors.greenDark,
        elevation: 0,
        title: Text(
          AppLanguage.get(context, 'mapTitle'),
          style: GoogleFonts.playfairDisplay(fontSize: 20, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('trees').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '${AppLanguage.get(context, 'mapLoadError')} ${snapshot.error}',
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.greenLight),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          final trees = docs.map((doc) => TreeModel.fromFirestore(doc)).toList();

          final markers = trees.map((tree) {
            final isMyTree = currentUserId != null && tree.userid == currentUserId;
            return _buildMarker(tree, isMyTree: isMyTree);
          }).toList();

          final myTreesCount = trees.where((t) => currentUserId != null && t.userid == currentUserId).length;

          return Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: _centroVale,
                  initialZoom: 13.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.raizes',
                  ),
                  MarkerLayer(markers: markers),
                ],
              ),

              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.greenDark.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.nature_people, color: AppColors.greenLight, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLanguage.get(context, 'mapLocationHeader'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  '${trees.length} ${AppLanguage.get(context, 'mapTreesMapped')} ($myTreesCount ${AppLanguage.get(context, 'mapYourTreesCount')}).',
                                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: Colors.white12, height: 1),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildLegendItem(AppColors.gold, AppLanguage.get(context, 'legendMyTrees')),
                          _buildLegendItem(AppColors.greenMid, AppLanguage.get(context, 'legendCommunity')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  Marker _buildMarker(TreeModel tree, {required bool isMyTree}) {
    final markerColor = isMyTree ? AppColors.gold : AppColors.greenMid;
    final borderColor = isMyTree ? Colors.amberAccent : Colors.white;

    return Marker(
      point: LatLng(tree.latitude, tree.longitude),
      width: isMyTree ? 56 : 48,
      height: isMyTree ? 56 : 48,
      child: GestureDetector(
        onTap: () => _showTreeDetailsModal(tree, isMyTree: isMyTree),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: markerColor,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: isMyTree ? 3 : 2),
                boxShadow: [
                  BoxShadow(
                    color: isMyTree ? AppColors.gold.withOpacity(0.5) : Colors.black26,
                    blurRadius: isMyTree ? 8 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  tree.emoji.isNotEmpty ? tree.emoji : '🌳',
                  style: TextStyle(fontSize: isMyTree ? 24 : 20),
                ),
              ),
            ),
            if (isMyTree)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.star, size: 10, color: Colors.black),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showTreeDetailsModal(TreeModel tree, {required bool isMyTree}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.greenDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(tree.emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                tree.name,
                                style: GoogleFonts.playfairDisplay(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (isMyTree) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.gold),
                                ),
                                child: Text(
                                  AppLanguage.get(context, 'yourTreeBadge'),
                                  style: const TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          tree.species,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white24, height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${AppLanguage.get(context, 'biomeLabel')}: ${tree.biome}', style: const TextStyle(color: Colors.white70)),
                  Text('${AppLanguage.get(context, 'locationLabel')}: ${tree.location}', style: const TextStyle(color: Colors.white70)),
                ],
              ),
              const SizedBox(height: 16),

              if (isMyTree && tree.id != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withOpacity(0.2),
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    label: Text(
                      AppLanguage.get(context, 'removeTreeBtn'),
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                    onPressed: () async {
                      final uid = FirebaseAuth.instance.currentUser?.uid;
                      if (uid == null || tree.id == null) return;

                      try {
                        await FirebaseFirestore.instance
                          .collection('trees')
                          .doc(tree.id)
                          .delete();

                        await FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .collection('trees')
                          .doc(tree.id)
                          .delete();

                        await FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .update({
                            'treesPlanted': FieldValue.increment(-1),
                          });

                        if (!mounted) return;
                        Navigator.pop(ctx);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${tree.name} ${AppLanguage.get(context, 'treeRemovedSuccess')}'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${AppLanguage.get(context, 'treeRemoveError')} $e'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}