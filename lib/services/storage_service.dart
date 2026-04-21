import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/team.dart';
import '../models/trainer.dart';

class StorageService {
  static const _teamsBox = 'teams';
  static const _trainerBox = 'trainer';
  static const _teamsKey = 'teams';
  static const _trainerKey = 'trainer';

  static final StorageService _instance = StorageService._();
  factory StorageService() => _instance;
  StorageService._();

  Box<String> get _teams => Hive.box<String>(_teamsBox);
  Box<String> get _trainer => Hive.box<String>(_trainerBox);

  Future<List<Team>> loadTeams() async {
    final raw = _teams.get(_teamsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((t) => Team.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveTeams(List<Team> teams) async {
    await _teams.put(
      _teamsKey,
      jsonEncode(teams.map((t) => t.toJson()).toList()),
    );
  }

  Future<Trainer?> loadTrainer() async {
    final raw = _trainer.get(_trainerKey);
    if (raw == null) return null;
    return Trainer.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveTrainer(Trainer trainer) async {
    await _trainer.put(_trainerKey, jsonEncode(trainer.toJson()));
  }
}
