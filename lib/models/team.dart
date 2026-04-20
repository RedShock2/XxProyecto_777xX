import 'dart:convert';
import 'pokemon.dart';

class TeamLocation {
  final double latitude;
  final double longitude;
  final String? placeName;
  final DateTime savedAt;

  const TeamLocation({
    required this.latitude,
    required this.longitude,
    this.placeName,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'placeName': placeName,
    'savedAt': savedAt.toIso8601String(),
  };

  factory TeamLocation.fromJson(Map<String, dynamic> json) => TeamLocation(
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    placeName: json['placeName'] as String?,
    savedAt: DateTime.parse(json['savedAt'] as String),
  );
}

class Team {
  final String id;
  String name;
  final List<Pokemon?> slots; // max 6 slots
  TeamLocation? location;
  final DateTime createdAt;
  DateTime updatedAt;

  Team({
    required this.id,
    required this.name,
    List<Pokemon?>? slots,
    this.location,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : slots = slots ?? List.filled(6, null),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Team.create(String name) => Team(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    name: name,
  );

  int get pokemonCount => slots.where((p) => p != null).length;
  bool get isFull => pokemonCount == 6;
  List<Pokemon> get members => slots.whereType<Pokemon>().toList();

  void addPokemon(Pokemon pokemon) {
    final idx = slots.indexWhere((s) => s == null);
    if (idx != -1) {
      slots[idx] = pokemon;
      updatedAt = DateTime.now();
    }
  }

  void removePokemon(int slotIndex) {
    if (slotIndex >= 0 && slotIndex < 6) {
      slots[slotIndex] = null;
      updatedAt = DateTime.now();
    }
  }

  void swapSlots(int a, int b) {
    final tmp = slots[a];
    slots[a] = slots[b];
    slots[b] = tmp;
    updatedAt = DateTime.now();
  }

  String toQrJson() => jsonEncode(toJson());

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slots': slots.map((p) => p?.toJson()).toList(),
    'location': location?.toJson(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Team.fromJson(Map<String, dynamic> json) {
    final rawSlots = json['slots'] as List<dynamic>;
    final slots = rawSlots
        .map((s) => s != null ? Pokemon.fromSimpleJson(s as Map<String, dynamic>) : null)
        .toList()
        .cast<Pokemon?>();

    return Team(
      id: json['id'] as String,
      name: json['name'] as String,
      slots: slots,
      location: json['location'] != null
          ? TeamLocation.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
