import 'dart:convert';
import 'pokemon.dart';

/// Coordenadas GPS y metadatos del lugar donde se guardó un equipo.
class TeamLocation {
  /// Latitud geográfica.
  final double latitude;

  /// Longitud geográfica.
  final double longitude;

  /// Nombre legible del lugar (puede ser null si no se resolvió).
  final String? placeName;

  /// Fecha y hora en que se registró la ubicación.
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

/// Representa un equipo Pokémon del entrenador.
///
/// Contiene hasta 6 slots que pueden estar vacíos (`null`) o tener un [Pokemon].
/// Se persiste localmente mediante Hive a través de [StorageService].
class Team {
  /// Identificador único generado con timestamp en milisegundos.
  final String id;

  /// Nombre del equipo asignado por el entrenador.
  String name;

  /// Slots del equipo. Siempre tiene longitud 6; un slot `null` está vacío.
  final List<Pokemon?> slots;

  /// Ubicación GPS donde se guardó el equipo. `null` si no se registró.
  TeamLocation? location;

  /// Fecha de creación del equipo.
  final DateTime createdAt;

  /// Fecha de la última modificación del equipo.
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

  /// Crea un equipo nuevo con id basado en timestamp y slots vacíos.
  factory Team.create(String name) => Team(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    name: name,
  );

  /// Número de Pokémon actualmente en el equipo.
  int get pokemonCount => slots.where((p) => p != null).length;

  /// `true` si los 6 slots están ocupados.
  bool get isFull => pokemonCount == 6;

  /// Lista de Pokémon no nulos del equipo.
  List<Pokemon> get members => slots.whereType<Pokemon>().toList();

  /// Agrega [pokemon] al primer slot vacío disponible.
  void addPokemon(Pokemon pokemon) {
    final idx = slots.indexWhere((s) => s == null);
    if (idx != -1) {
      slots[idx] = pokemon;
      updatedAt = DateTime.now();
    }
  }

  /// Elimina el Pokémon en [slotIndex] dejándolo vacío.
  void removePokemon(int slotIndex) {
    if (slotIndex >= 0 && slotIndex < 6) {
      slots[slotIndex] = null;
      updatedAt = DateTime.now();
    }
  }

  /// Intercambia los Pokémon en las posiciones [a] y [b].
  void swapSlots(int a, int b) {
    final tmp = slots[a];
    slots[a] = slots[b];
    slots[b] = tmp;
    updatedAt = DateTime.now();
  }

  /// Serializa el equipo a JSON compacto para compartir mediante QR.
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
