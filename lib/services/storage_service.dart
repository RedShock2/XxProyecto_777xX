import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/team.dart';
import '../models/trainer.dart';

class StorageService {
  static const _teamsKey = 'teams';
  static const _trainerKey = 'trainer';

  static final StorageService _instance = StorageService._();
  factory StorageService() => _instance;
  StorageService._();

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<List<Team>> loadTeams() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_teamsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((t) => Team.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveTeams(List<Team> teams) async {
    final prefs = await _prefs;
    await prefs.setString(
      _teamsKey,
      jsonEncode(teams.map((t) => t.toJson()).toList()),
    );
  }

  Future<Trainer?> loadTrainer() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_trainerKey);
    if (raw == null) return null;
    return Trainer.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveTrainer(Trainer trainer) async {
    final prefs = await _prefs;
    await prefs.setString(_trainerKey, jsonEncode(trainer.toJson()));
  }
}
