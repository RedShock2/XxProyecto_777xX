class Trainer {
  String name;
  String? profileImagePath;
  final DateTime joinedAt;
  int totalTeams;
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

  factory Trainer.defaultTrainer() => Trainer(name: 'Entrenador');
}
