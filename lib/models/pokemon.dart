class PokemonStat {
  final String name;
  final int base;

  const PokemonStat({required this.name, required this.base});

  factory PokemonStat.fromJson(Map<String, dynamic> json) {
    return PokemonStat(
      name: json['stat']['name'] as String,
      base: json['base_stat'] as int,
    );
  }
}

class PokemonMove {
  final String name;
  final String learnMethod;

  const PokemonMove({required this.name, required this.learnMethod});

  factory PokemonMove.fromJson(Map<String, dynamic> json) {
    final methods = json['version_group_details'] as List<dynamic>;
    final method = methods.isNotEmpty
        ? methods.last['move_learn_method']['name'] as String
        : 'unknown';
    return PokemonMove(
      name: json['move']['name'] as String,
      learnMethod: method,
    );
  }
}

class EvolutionNode {
  final String speciesName;
  final List<EvolutionNode> evolvesTo;

  const EvolutionNode({required this.speciesName, required this.evolvesTo});
}

class Pokemon {
  final int id;
  final String name;
  final List<String> types;
  final List<PokemonStat> stats;
  final List<PokemonMove> moves;
  final String spriteUrl;
  final String spriteShinyUrl;
  final int height;
  final int weight;
  final int baseExperience;
  EvolutionNode? evolutionChain;

  Pokemon({
    required this.id,
    required this.name,
    required this.types,
    required this.stats,
    required this.moves,
    required this.spriteUrl,
    required this.spriteShinyUrl,
    required this.height,
    required this.weight,
    required this.baseExperience,
    this.evolutionChain,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final typesList = (json['types'] as List<dynamic>)
        .map((t) => t['type']['name'] as String)
        .toList();

    final statsList = (json['stats'] as List<dynamic>)
        .map((s) => PokemonStat.fromJson(s as Map<String, dynamic>))
        .toList();

    final movesList = (json['moves'] as List<dynamic>)
        .map((m) => PokemonMove.fromJson(m as Map<String, dynamic>))
        .toList();

    final sprites = json['sprites'] as Map<String, dynamic>;

    return Pokemon(
      id: json['id'] as int,
      name: json['name'] as String,
      types: typesList,
      stats: statsList,
      moves: movesList,
      spriteUrl: sprites['front_default'] as String? ?? '',
      spriteShinyUrl: sprites['front_shiny'] as String? ?? '',
      height: json['height'] as int,
      weight: json['weight'] as int,
      baseExperience: json['base_experience'] as int? ?? 0,
    );
  }

  int get hp => stats.firstWhere((s) => s.name == 'hp', orElse: () => const PokemonStat(name: 'hp', base: 0)).base;
  int get attack => stats.firstWhere((s) => s.name == 'attack', orElse: () => const PokemonStat(name: 'attack', base: 0)).base;
  int get defense => stats.firstWhere((s) => s.name == 'defense', orElse: () => const PokemonStat(name: 'defense', base: 0)).base;
  int get spAttack => stats.firstWhere((s) => s.name == 'special-attack', orElse: () => const PokemonStat(name: 'special-attack', base: 0)).base;
  int get spDefense => stats.firstWhere((s) => s.name == 'special-defense', orElse: () => const PokemonStat(name: 'special-defense', base: 0)).base;
  int get speed => stats.firstWhere((s) => s.name == 'speed', orElse: () => const PokemonStat(name: 'speed', base: 0)).base;
  int get totalStats => stats.fold(0, (sum, s) => sum + s.base);

  String get displayName => name[0].toUpperCase() + name.substring(1);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'types': types,
    'spriteUrl': spriteUrl,
    'spriteShinyUrl': spriteShinyUrl,
    'height': height,
    'weight': weight,
    'baseExperience': baseExperience,
    'stats': stats.map((s) => {'name': s.name, 'base': s.base}).toList(),
  };

  factory Pokemon.fromSimpleJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'] as int,
      name: json['name'] as String,
      types: List<String>.from(json['types'] as List),
      stats: (json['stats'] as List<dynamic>)
          .map((s) => PokemonStat(
                name: s['name'] as String,
                base: s['base'] as int,
              ))
          .toList(),
      moves: [],
      spriteUrl: json['spriteUrl'] as String? ?? '',
      spriteShinyUrl: json['spriteShinyUrl'] as String? ?? '',
      height: json['height'] as int? ?? 0,
      weight: json['weight'] as int? ?? 0,
      baseExperience: json['baseExperience'] as int? ?? 0,
    );
  }
}
