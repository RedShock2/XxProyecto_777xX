import 'package:flutter/material.dart';
import '../models/team.dart';
import '../models/pokemon.dart';
import '../services/storage_service.dart';
import '../services/location_service.dart';

/// Gestiona el estado de los equipos Pokémon del entrenador.
///
/// Responsabilidades:
/// - Cargar y persistir equipos en Hive via [StorageService].
/// - Mantener el equipo activo durante la sesión.
/// - Operaciones CRUD sobre equipos y slots.
class TeamProvider extends ChangeNotifier {
  final _storage = StorageService();
  final _location = LocationService();

  final List<Team> _teams = [];
  Team? _activeTeam;
  bool _loading = false;

  /// Lista inmutable de todos los equipos guardados.
  List<Team> get teams => List.unmodifiable(_teams);

  /// Equipo actualmente seleccionado para edición.
  Team? get activeTeam => _activeTeam;

  /// `true` mientras se cargan equipos desde almacenamiento.
  bool get loading => _loading;

  /// Carga todos los equipos desde Hive y notifica a los listeners.
  Future<void> loadTeams() async {
    _loading = true;
    notifyListeners();
    _teams
      ..clear()
      ..addAll(await _storage.loadTeams());
    _loading = false;
    notifyListeners();
  }

  /// Crea un equipo nuevo con [name], lo establece como activo y lo persiste.
  ///
  /// Retorna el equipo creado para navegación inmediata al TeamBuilder.
  Future<Team> createTeam(String name) async {
    final team = Team.create(name);
    _teams.add(team);
    _activeTeam = team;
    await _persist();
    notifyListeners();
    return team;
  }

  /// Establece [team] como el equipo activo sin persistir cambios.
  void setActive(Team team) {
    _activeTeam = team;
    notifyListeners();
  }

  /// Agrega [pokemon] al primer slot vacío del equipo activo.
  ///
  /// No hace nada si no hay equipo activo o si el equipo está lleno.
  Future<void> addPokemonToActive(Pokemon pokemon) async {
    if (_activeTeam == null || _activeTeam!.isFull) return;
    _activeTeam!.addPokemon(pokemon);
    await _persist();
    notifyListeners();
  }

  /// Elimina el Pokémon en [slotIndex] del equipo activo.
  Future<void> removePokemonFromActive(int slotIndex) async {
    _activeTeam?.removePokemon(slotIndex);
    await _persist();
    notifyListeners();
  }

  /// Intercambia los Pokémon en las posiciones [a] y [b] del equipo activo.
  Future<void> swapSlots(int a, int b) async {
    _activeTeam?.swapSlots(a, b);
    await _persist();
    notifyListeners();
  }

  /// Obtiene la ubicación GPS actual y la asocia al [team].
  ///
  /// No hace nada si el GPS no está disponible.
  Future<void> attachLocation(Team team) async {
    final loc = await _location.getCurrentLocation();
    if (loc == null) return;
    team.location = TeamLocation(
      latitude: loc.latitude,
      longitude: loc.longitude,
      savedAt: DateTime.now(),
    );
    await _persist();
    notifyListeners();
  }

  /// Elimina el equipo con [id] de la lista y del almacenamiento.
  Future<void> deleteTeam(String id) async {
    _teams.removeWhere((t) => t.id == id);
    if (_activeTeam?.id == id) _activeTeam = null;
    await _persist();
    notifyListeners();
  }

  /// Agrega [team] importado (desde QR) a la lista y lo persiste.
  Future<void> importTeam(Team team) async {
    _teams.add(team);
    await _persist();
    notifyListeners();
  }

  /// Renombra el equipo con [id] a [newName] y persiste el cambio.
  Future<void> renameTeam(String id, String newName) async {
    final team = _teams.firstWhere((t) => t.id == id);
    team.name = newName;
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() => _storage.saveTeams(_teams);
}
