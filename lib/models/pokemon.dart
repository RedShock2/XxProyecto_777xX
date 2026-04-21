/// Representa una estadística base de un Pokémon (ej. hp, attack).
class PokemonStat {
  /// Nombre de la estadística según la PokéAPI (ej. `'hp'`, `'attack'`).
  final String name;

  /// Valor base de la estadística.
  final int base;

  const PokemonStat({required this.name, required this.base});

  /// Construye un [PokemonStat] desde el formato JSON de la PokéAPI.
  factory PokemonStat.fromJson(Map<String, dynamic> json) {
    return PokemonStat(
      name: json['stat']['name'] as String,
      base: json['base_stat'] as int,
    );
  }
}

/// Representa un movimiento que un Pokémon puede aprender.
class PokemonMove {
  /// Nombre del movimiento.
  final String name;

  /// Método de aprendizaje (ej. `'level-up'`, `'machine'`).
  final String learnMethod;

  const PokemonMove({required this.name, required this.learnMethod});

  /// Construye un [PokemonMove] desde el formato JSON de la PokéAPI.
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

/// Nodo en la cadena evolutiva de una especie Pokémon.
class EvolutionNode {
  /// Nombre de la especie en este nodo.
  final String speciesName;

  /// Lista de evoluciones posibles desde este nodo.
  final List<EvolutionNode> evolvesTo;

  const EvolutionNode({required this.speciesName, required this.evolvesTo});
}

/// Representa un Pokémon con todos sus datos de combate y visualización.
///
/// Se obtiene desde la PokéAPI y puede serializarse para almacenamiento local.
class Pokemon {
  /// ID numérico nacional del Pokémon.
  final int id;

  /// Nombre en minúsculas según la PokéAPI (ej. `'bulbasaur'`).
  final String name;

  /// Lista de tipos del Pokémon (ej. `['fire', 'flying']`).
  final List<String> types;

  /// Estadísticas base: hp, attack, defense, special-attack, special-defense, speed.
  final List<PokemonStat> stats;

  /// Movimientos que puede aprender este Pokémon.
  final List<PokemonMove> moves;

  /// URL del sprite frontal normal.
  final String spriteUrl;

  /// URL del sprite frontal shiny.
  final String spriteShinyUrl;

  /// Altura en decímetros.
  final int height;

  /// Peso en hectogramos.
  final int weight;

  /// Experiencia base al derrotarlo.
  final int baseExperience;

  /// Cadena evolutiva. `null` si no se ha cargado aún.
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

  /// Construye un [Pokemon] desde la respuesta completa de la PokéAPI.
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

  /// Valor de HP.
  int get hp => stats.firstWhere((s) => s.name == 'hp', orElse: () => const PokemonStat(name: 'hp', base: 0)).base;
  /// Valor de Ataque.
  int get attack => stats.firstWhere((s) => s.name == 'attack', orElse: () => const PokemonStat(name: 'attack', base: 0)).base;
  /// Valor de Defensa.
  int get defense => stats.firstWhere((s) => s.name == 'defense', orElse: () => const PokemonStat(name: 'defense', base: 0)).base;
  /// Valor de Ataque Especial.
  int get spAttack => stats.firstWhere((s) => s.name == 'special-attack', orElse: () => const PokemonStat(name: 'special-attack', base: 0)).base;
  /// Valor de Defensa Especial.
  int get spDefense => stats.firstWhere((s) => s.name == 'special-defense', orElse: () => const PokemonStat(name: 'special-defense', base: 0)).base;
  /// Valor de Velocidad.
  int get speed => stats.firstWhere((s) => s.name == 'speed', orElse: () => const PokemonStat(name: 'speed', base: 0)).base;
  /// Suma de todas las estadísticas base.
  int get totalStats => stats.fold(0, (sum, s) => sum + s.base);

  /// Nombre con la primera letra en mayúscula para mostrar en UI.
  String get displayName => name[0].toUpperCase() + name.substring(1);

  /// Serializa los campos esenciales para almacenamiento local (sin moves ni evolutionChain).
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

  /// Construye un [Pokemon] desde el JSON simplificado guardado en Hive.
  /// Los moves se omiten para reducir tamaño de almacenamiento.
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
