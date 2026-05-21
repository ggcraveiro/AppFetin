class TreeModel {
  final String name;
  final String species;
  final String emoji;
  final String biome;
  final String location;
  final double co2kg;
  final double progress; // 0.0 to 1.0
  final int monthsPlanted;
  final bool isEndangered;
  final int? urgentDays;

  const TreeModel({
    required this.name,
    required this.species,
    required this.emoji,
    required this.biome,
    required this.location,
    required this.co2kg,
    required this.progress,
    required this.monthsPlanted,
    this.isEndangered = false,
    this.urgentDays,
  });
}

class AdoptTreeModel {
  final String name;
  final String species;
  final String emoji;
  final String biome;
  final List<String> tags;
  final double priceMonthly;
  final bool isEndangered;
  bool adopted;

  AdoptTreeModel({
    required this.name,
    required this.species,
    required this.emoji,
    required this.biome,
    required this.tags,
    required this.priceMonthly,
    this.isEndangered = false,
    this.adopted = false,
  });
}

final List<TreeModel> myTrees = [
  TreeModel(
    name: 'Ipê Amarelo', species: 'Handroanthus chrysotrichus',
    emoji: '🌸', biome: 'Serra', location: 'Rio Sapucaí · MG',
    co2kg: 12.4, progress: 0.73, monthsPlanted: 8,
  ),
  TreeModel(
    name: 'Sapucaia', species: 'Lecythis pisonis',
    emoji: '🌰', biome: 'Mata Ciliar', location: 'Mata Ciliar · MG',
    co2kg: 18.7, progress: 0.17, monthsPlanted: 14,
    isEndangered: true, urgentDays: 5,
  ),
  TreeModel(
    name: 'Cedro', species: 'Cedrela fissilis',
    emoji: '🪵', biome: 'Serra', location: 'Serra Fina · MG',
    co2kg: 9.3, progress: 0.90, monthsPlanted: 3,
  ),
  TreeModel(
    name: 'Copaíba', species: 'Copaifera langsdorffii',
    emoji: '🌿', biome: 'Mata Ciliar', location: 'Vale do Sapucaí · MG',
    co2kg: 15.9, progress: 0.47, monthsPlanted: 11,
  ),
];

final List<AdoptTreeModel> adoptTrees = [
  AdoptTreeModel(
    name: 'Sapucaia', species: 'Lecythis pisonis', emoji: '🌰',
    biome: 'Mata Ciliar', tags: ['Mata Ciliar', 'Rio Sapucaí'],
    priceMonthly: 22, isEndangered: true,
  ),
  AdoptTreeModel(
    name: 'Ipê Amarelo', species: 'Handroanthus chrysotrichus', emoji: '🌸',
    biome: 'Serra', tags: ['Serra', 'Encosta', '~80 anos'],
    priceMonthly: 18,
  ),
  AdoptTreeModel(
    name: 'Cedro', species: 'Cedrela fissilis', emoji: '🪵',
    biome: 'Serra', tags: ['Serra', 'Floresta Montana'],
    priceMonthly: 25, isEndangered: true,
  ),
  AdoptTreeModel(
    name: 'Copaíba', species: 'Copaifera langsdorffii', emoji: '🌿',
    biome: 'Mata Ciliar', tags: ['Mata Ciliar', 'Medicinal', '~400 anos'],
    priceMonthly: 20,
  ),
  AdoptTreeModel(
    name: 'Canela-preta', species: 'Ocotea catharinensis', emoji: '🌲',
    biome: 'Serra', tags: ['Serra', 'Floresta Densa'],
    priceMonthly: 23, isEndangered: true,
  ),
  AdoptTreeModel(
    name: 'Jequitibá Branco', species: 'Cariniana estrellensis', emoji: '🌳',
    biome: 'Várzea', tags: ['Várzea', 'Gigante nativa'],
    priceMonthly: 28, isEndangered: true,
  ),
  AdoptTreeModel(
    name: 'Ipê Roxo', species: 'Handroanthus impetiginosus', emoji: '💜',
    biome: 'Mata Ciliar', tags: ['Mata Ciliar', 'Encosta', '~60 anos'],
    priceMonthly: 17,
  ),
  AdoptTreeModel(
    name: 'Canafístula', species: 'Peltophorum dubium', emoji: '🌼',
    biome: 'Várzea', tags: ['Várzea', 'Pioneira', 'Restauração'],
    priceMonthly: 14,
  ),
];
