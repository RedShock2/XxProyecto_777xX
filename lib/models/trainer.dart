/// Representa el perfil del entrenador Pokémon del usuario.
///
/// Se persiste localmente mediante Hive a través de [StorageService].
class Trainer {
  /// Nombre del entrenador elegido en el setup inicial.
  String name;

  /// Ruta local a la foto de perfil. `null` si no se ha seleccionado foto.
  String? profileImagePath;

  /// Fecha en que el entrenador se registró en la app por primera vez.
  final DateTime joinedAt;

  /// Total de equipos creados por el entrenador.
  int totalTeams;

  /// Total de batallas registradas.
  int totalBattles;

  Trainer({
    required this.name,
    this.profileImagePath,
    DateTime? joinedAt,
    this.totalTeams = 0,
    this.totalBattles = 0,
  }) : joinedAt = joinedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'name': name,
    'profileImagePath': profileImagePath,
    'joinedAt': joinedAt.toIso8601String(),
    'totalTeams': totalTeams,
    'totalBattles': totalBattles,
  };

  factory Trainer.fromJson(Map<String, dynamic> json) => Trainer(
    name: json['name'] as String,
    profileImagePath: json['profileImagePath'] as String?,
    joinedAt: DateTime.parse(json['joinedAt'] as String),
    totalTeams: json['totalTeams'] as int? ?? 0,
    totalBattles: json['totalBattles'] as int? ?? 0,
  );

  /// Crea un entrenador con valores por defecto para el primer lanzamiento.
  factory Trainer.defaultTrainer() => Trainer(name: 'Entrenador');
}
