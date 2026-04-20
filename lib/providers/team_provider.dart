import 'package:flutter/material.dart';
import '../models/team.dart';
import '../models/pokemon.dart';
import '../services/storage_service.dart';
import '../services/location_service.dart';

class TeamProvider extends ChangeNotifier {
  final _storage = StorageService();
  final _location = LocationService();

  final List<Team> _teams = [];
  Team? _activeTeam;
  bool _loading = false;

  List<Team> get teams => List.unmodifiable(_teams);
  Team? get activeTeam => _activeTeam;
  bool get loading => _loading;

  Future<void> loadTeams() async {
    _loading = true;
    notifyListeners();
    _teams
      ..clear()
      ..addAll(await _storage.loadTeams());
    _loading = false;
    notifyListeners();
  }

  Future<Team> createTeam(String name) async {
    final team = Team.create(name);
    _teams.add(team);
    _activeTeam = team;
    await _persist();
    notifyListeners();
    return team;
  }

  void setActive(Team team) {
    _activeTeam = team;
    notifyListeners();
  }

  Future<void> addPokemonToActive(Pokemon pokemon) async {
    if (_activeTeam == null || _activeTeam!.isFull) return;
    _activeTeam!.addPokemon(pokemon);
    await _persist();
    notifyListeners();
  }

  Future<void> removePokemonFromActive(int slotIndex) async {
    _activeTeam?.removePokemon(slotIndex);
    await _persist();
    notifyListeners();
  }

  Future<void> swapSlots(int a, int b) async {
    _activeTeam?.swapSlots(a, b);
    await _persist();
    notifyListeners();
  }

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

  Future<void> deleteTeam(String id) async {
    _teams.removeWhere((t) => t.id == id);
    if (_activeTeam?.id == id) _activeTeam = null;
    await _persist();
    notifyListeners();
  }

  Future<void> importTeam(Team team) async {
    _teams.add(team);
    await _persist();
    notifyListeners();
  }

  Future<void> renameTeam(String id, String newName) async {
    final team = _teams.firstWhere((t) => t.id == id);
    team.name = newName;
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() => _storage.saveTeams(_teams);
}
