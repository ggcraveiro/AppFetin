import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';


class TreeModel {
  final String? id; // ID para deletar no Firestore
  final String? userid; // ID do usuário que adotou a árvore
  final String name;
  final String species;
  final String emoji;
  final String biome;
  final String location;
  final double progress; // 0.0 to 1.0
  final int monthsPlanted;
  final bool isEndangered;
  final int? urgentDays;
  final double latitude;  // Coordenada para o mapa
  final double longitude; // Coordenada para o mapa

  const TreeModel({
    this.id,
    this.userid,
    required this.name,
    required this.species,
    required this.emoji,
    required this.biome,
    required this.location,
    required this.progress,
    required this.monthsPlanted,
    this.isEndangered = false,
    this.urgentDays,
    this.latitude = -22.2516,  // Valor padrão no Vale do Sapucaí
    this.longitude = -45.7042, // Valor padrão no Vale do Sapucaí
  });

  // Factory constructor para ler os dados do Firestore
  factory TreeModel.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return TreeModel(
      id: doc.id,
      userid: map['userId'],
      name: map['name'] ?? '',
      species: map['species'] ?? '',
      emoji: map['emoji'] ?? '🌳',
      biome: map['biome'] ?? '',
      location: map['location'] ?? '',
      progress: (map['progress'] ?? 0.0).toDouble(),
      monthsPlanted: map['monthsPlanted'] ?? 0,
      isEndangered: map['isEndangered'] ?? false,
      urgentDays: map['urgentDays'],
      latitude: (map['latitude'] as num?)?.toDouble() ?? -22.2516,
      longitude: (map['longitude'] as num?)?.toDouble() ?? -45.7042,
    );
  }

  // Método para converter o objeto em Map ao salvar/criar no Firestore
  Map<String, dynamic> toMap() {
    return {
      if (userid != null) 'userId': userid,
      'name': name,
      'species': species,
      'emoji': emoji,
      'biome': biome,
      'location': location,
      'progress': progress,
      'monthsPlanted': monthsPlanted,
      'isEndangered': isEndangered,
      'urgentDays': urgentDays,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

// Helper para randomizar posições mantendo limites seguros
class MapLocationHelper {
  // Limites aproximados da região de Santa Rita do Sapucaí / Vale do Sapucaí
  static const double minLat = -22.2700;
  static const double maxLat = -22.2300;
  static const double minLng = -45.7200;
  static const double maxLng = -45.6800;

  /// Adiciona uma variação aleatória de ~100m a ~500m na coordenada original
  static List<double> generateJitterCoordinates(double baseLat, double baseLng) {
    final random = Random();
    
    // Variação de aproximadamente ±0.004 graus (~400 metros)
    double latOffset = (random.nextDouble() - 0.5) * 0.008;
    double lngOffset = (random.nextDouble() - 0.5) * 0.008;

    double newLat = baseLat + latOffset;
    double newLng = baseLng + lngOffset;

    // Garante que não ultrapassa os limites da cidade
    newLat = newLat.clamp(minLat, maxLat);
    newLng = newLng.clamp(minLng, maxLng);

    return [newLat, newLng];
  }
}

class AdoptTreeModel {
  final String name;
  final String species;
  final String emoji;
  final String biome;
  final List<String> tags;
  final double priceMonthly;
  final bool isEndangered;
  final double latitude;  // Coordenadas para repassar ao criar no mapa
  final double longitude; // Coordenadas para repassar ao criar no mapa
  bool adopted;

  AdoptTreeModel({
    required this.name,
    required this.species,
    required this.emoji,
    required this.biome,
    required this.tags,
    required this.priceMonthly,
    this.isEndangered = false,
    this.latitude = -22.2516,
    this.longitude = -45.7042,
    this.adopted = false,
  });
}

// Lista de adoção completa mantida com coordenadas no Vale do Sapucaí
final List<AdoptTreeModel> adoptTrees = [
  AdoptTreeModel(
    name: 'Ipê Amarelo', species: 'Handroanthus albus', emoji: '🟡',
    biome: 'Mata Atlântica', tags: ['Floração', 'Atrai aves'],
    priceMonthly: 22,
    latitude: -22.2510, longitude: -45.7050,
  ),
  AdoptTreeModel( 
    name: 'Jacarandá', species: 'Jacaranda spp.', emoji: '🪻',
    biome: 'Mata Atlântica', tags: ['Floração', 'Alimenta a fauna'],
    priceMonthly: 18, isEndangered: true,
    latitude: -22.2530, longitude: -45.7010,
  ),
  AdoptTreeModel(
    name: 'Cedro-rosa', species: 'Cedrela fissilis', emoji: '🪵',
    biome: 'Mata Atlântica', tags: ['Grande porte', 'Dispersão pelo vento'],
    priceMonthly: 25, isEndangered: true,
    latitude: -22.2480, longitude: -45.7120,
  ),
  AdoptTreeModel(
    name: 'Jequitibá-rosa', species: 'Cariniana legalis', emoji: '👑',
    biome: 'Mata Atlântica', tags: ['Grande porte', 'Longevidade'],
    priceMonthly: 20, isEndangered: true,
    latitude: -22.2560, longitude: -45.6970,
  ),
  AdoptTreeModel(
    name: 'Angico', species: 'Anadenanthera colubrina', emoji: '🌱',
    biome: 'Mata Atlântica', tags: ['Recupera o solo', 'Fixação de nitrogênio'],
    priceMonthly: 23,
    latitude: -22.2420, longitude: -45.7080,
  ),
  AdoptTreeModel(
    name: 'Jatobá', species: 'Hymenaea courbaril', emoji: '🌳',
    biome: 'Mata Atlântica', tags: ['Alimenta a fauna', 'Castanhas comestíveis', 'Resina medicinal'],
    priceMonthly: 28,
    latitude: -22.2590, longitude: -45.7020,
  ),
  AdoptTreeModel(
    name: 'Canelas', species: 'Ocotea / Nectandra spp.', emoji: '🍃',
    biome: 'Mata Atlântica', tags: ['Atrai aves', 'Folhagem aromática'],
    priceMonthly: 17,
    latitude: -22.2460, longitude: -45.6930,
  ),
  AdoptTreeModel(
    name: 'Peroba-rosa', species: 'Aspidosperma polyneuron', emoji: '🌲',
    biome: 'Mata Atlântica', tags: ['Dispersão pelo vento', 'Espécie clímax'],
    priceMonthly: 14, isEndangered: true,
    latitude: -22.2545, longitude: -45.7150,
  ),
  AdoptTreeModel(
    name: 'Aroeira-pimenteira', species: 'Schinus terebinthifolia', emoji: '🌶️',
    biome: 'Mata Atlântica', tags: ['Mata ciliar', 'Atrai aves', 'Frutos comestíveis'],
    priceMonthly: 30,
    latitude: -22.2505, longitude: -45.6990,
  ),
  AdoptTreeModel(
    name: 'Ingá', species: 'Inga spp.', emoji: '🌿',
    biome: 'Mata Atlântica', tags: ['Mata ciliar', 'Alimenta a fauna', 'Fixação de nitrogênio'],
    priceMonthly: 13,
    latitude: -22.2575, longitude: -45.7065,
  ),
  AdoptTreeModel(
    name: 'Sapucaia', species: 'Lecythis pisonis', emoji: '🌰',
    biome: 'Mata Atlântica', tags: ['Castanhas comestíveis', 'Atrai aves', 'Floração'],
    priceMonthly: 35,
    latitude: -22.2495, longitude: -45.7100,
  ),
];