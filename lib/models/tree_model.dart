import 'package:cloud_firestore/cloud_firestore.dart';

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

// Lista de teste local mantida e atualizada com coordenadas
final List<TreeModel> myTrees = [
  const TreeModel(
    name: 'Ipê Amarelo', species: 'Handroanthus chrysotrichus',
    emoji: '🌸', biome: 'Serra', location: 'Rio Sapucaí · MG',
    progress: 0.73, monthsPlanted: 8,
    latitude: -22.2520, longitude: -45.7030,
  ),
  const TreeModel(
    name: 'Sapucaia', species: 'Lecythis pisonis',
    emoji: '🌰', biome: 'Mata Ciliar', location: 'Mata Ciliar · MG',
    progress: 0.17, monthsPlanted: 14,
    isEndangered: true, urgentDays: 5,
    latitude: -22.2350, longitude: -45.6900,
  ),
  const TreeModel(
    name: 'Cedro', species: 'Cedrela fissilis',
    emoji: '🪵', biome: 'Serra', location: 'Serra Fina · MG',
    progress: 0.90, monthsPlanted: 3,
    latitude: -22.2600, longitude: -45.7100,
  ),
  const TreeModel(
    name: 'Copaíba', species: 'Copaifera langsdorffii',
    emoji: '🌿', biome: 'Mata Ciliar', location: 'Vale do Sapucaí · MG',
    progress: 0.47, monthsPlanted: 11,
    latitude: -22.2450, longitude: -45.6980,
  ),
];

// Lista de adoção completa mantida com coordenadas no Vale do Sapucaí
final List<AdoptTreeModel> adoptTrees = [
  AdoptTreeModel(
    name: 'Sapucaia', species: 'Lecythis pisonis', emoji: '🌰',
    biome: 'Mata Ciliar', tags: ['Mata Ciliar', 'Rio Sapucaí'],
    priceMonthly: 22, isEndangered: true,
    latitude: -22.2510, longitude: -45.7050,
  ),
  AdoptTreeModel(
    name: 'Ipê Amarelo', species: 'Handroanthus chrysotrichus', emoji: '🌸',
    biome: 'Serra', tags: ['Serra', 'Encosta', '~80 anos'],
    priceMonthly: 18,
    latitude: -22.2530, longitude: -45.7010,
  ),
  AdoptTreeModel(
    name: 'Cedro', species: 'Cedrela fissilis', emoji: '🪵',
    biome: 'Serra', tags: ['Serra', 'Floresta Montana'],
    priceMonthly: 25, isEndangered: true,
    latitude: -22.2480, longitude: -45.7120,
  ),
  AdoptTreeModel(
    name: 'Copaíba', species: 'Copaifera langsdorffii', emoji: '🌿',
    biome: 'Mata Ciliar', tags: ['Mata Ciliar', 'Medicinal', '~400 anos'],
    priceMonthly: 20,
    latitude: -22.2560, longitude: -45.6970,
  ),
  AdoptTreeModel(
    name: 'Canela-preta', species: 'Ocotea catharinensis', emoji: '🌲',
    biome: 'Serra', tags: ['Serra', 'Floresta Densa'],
    priceMonthly: 23, isEndangered: true,
    latitude: -22.2420, longitude: -45.7080,
  ),
  AdoptTreeModel(
    name: 'Jequitibá Branco', species: 'Cariniana estrellensis', emoji: '🌳',
    biome: 'Várzea', tags: ['Várzea', 'Gigante nativa'],
    priceMonthly: 28, isEndangered: true,
    latitude: -22.2590, longitude: -45.7020,
  ),
  AdoptTreeModel(
    name: 'Ipê Roxo', species: 'Handroanthus impetiginosus', emoji: '💜',
    biome: 'Mata Ciliar', tags: ['Mata Ciliar', 'Encosta', '~60 anos'],
    priceMonthly: 17,
    latitude: -22.2460, longitude: -45.6930,
  ),
  AdoptTreeModel(
    name: 'Canafístula', species: 'Peltophorum dubium', emoji: '🌼',
    biome: 'Várzea', tags: ['Várzea', 'Pioneira', 'Restauração'],
    priceMonthly: 14,
    latitude: -22.2545, longitude: -45.7150,
  ),
  AdoptTreeModel(
    name: 'Pau-brasil', species: 'Paubrasilia echinata', emoji: '🪵',
    biome: 'Mata Atlântica', tags: ['Mata Atlântica', 'Símbolo do Brasil'],
    priceMonthly: 30, isEndangered: true,
    latitude: -22.2505, longitude: -45.6990,
  ),
  AdoptTreeModel(
    name: 'Embaúba', species: 'Cecropia pachystachya', emoji: '🌿',
    biome: 'Mata Atlântica', tags: ['Mata Atlântica', 'Pioneira', 'Restauração'],
    priceMonthly: 13,
    latitude: -22.2575, longitude: -45.7065,
  )
];