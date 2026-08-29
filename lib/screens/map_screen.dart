import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../colors.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Coordenadas do Vale do Sapucaí (Santa Rita do Sapucaí / Pouso Alegre)
  final LatLng _centroVale = const LatLng(-22.2516, -45.7042);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greenDeep,
      appBar: AppBar(
        backgroundColor: AppColors.greenDark,
        elevation: 0,
        title: Text(
          'Mapa de Reflorestamento 🗺️',
          style: GoogleFonts.playfairDisplay(fontSize: 20, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Renderizador do OpenStreetMap
          FlutterMap(
            options: MapOptions(
              initialCenter: _centroVale,
              initialZoom: 13.0,
            ),
            children: [
              // Camada visual do mapa (OpenStreetMap gratuito)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.raizes',
              ),
              // Camada de Marcadores (Árvores e Áreas de Plantio)
              MarkerLayer(
                markers: [
                  _buildMarker(
                    point: const LatLng(-22.256843, -45.696427),
                    title: 'Teremos uma árvore aqui!',
                    trees: '? árvores',
                  ),
                  _buildMarker(
                    point: const LatLng(-22.258263, -45.703426),
                    title: 'Teremos uma árvore aqui!',
                    trees: '? árvores',
                  ),
                ],
              ),
            ],
          ),

          // Card Informativo Flutuante no Topo
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
              child: const Row(
                children: [
                  Icon(Icons.nature_people, color: AppColors.greenLight, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Santa Rita do Sapucaí - MG',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Toque nos ícones para ver os locais de plantio.',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper para criar os marcadores no mapa
  Marker _buildMarker({
    required LatLng point,
    required String title,
    required String trees,
  }) {
    return Marker(
      point: point,
      width: 50,
      height: 50,
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title — $trees'),
              backgroundColor: AppColors.greenMid,
              duration: const Duration(seconds: 3),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.greenMid,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.park,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }
}