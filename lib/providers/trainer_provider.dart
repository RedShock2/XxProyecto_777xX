import 'dart:io';
import 'package:flutter/material.dart';
import '../models/trainer.dart';
import '../services/storage_service.dart';
import '../services/camera_service.dart';

class TrainerProvider extends ChangeNotifier {
  final _storage = StorageService();
  final _camera = CameraService();

  Trainer _trainer = Trainer.defaultTrainer();
  bool _loaded = false;

  Trainer get trainer => _trainer;
  bool get loaded => _loaded;
  bool get hasProfile => _trainer.profileImagePath != null;

  Future<void> load() async {
    final saved = await _storage.loadTrainer();
    _trainer = saved ?? Trainer.defaultTrainer();
    _loaded = true;
    notifyListeners();
  }

  Future<void> setName(String name) async {
    _trainer.name = name;
    await _storage.saveTrainer(_trainer);
    notifyListeners();
  }

  Future<File?> pickProfilePhoto(ImageSourceType source) async {
    final file = await _camera.pickImage(source);
    if (file == null) return null;
    _trainer.profileImagePath = file.path;
    await _storage.saveTrainer(_trainer);
    notifyListeners();
    return file;
  }

  Future<void> incrementTeams() async {
    _trainer.totalTeams++;
    await _storage.saveTrainer(_trainer);
    notifyListeners();
  }
}
