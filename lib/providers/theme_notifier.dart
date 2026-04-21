import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

/// Gestiona y persiste la preferencia de [ThemeMode] de la aplicación.
///
/// Integrado en el árbol de [MultiProvider] de [main.dart].
class ThemeNotifier extends ChangeNotifier {
  ThemeMode _mode;

  ThemeNotifier(this._mode);

  /// Modo de tema activo: [ThemeMode.dark] o [ThemeMode.light].
  ThemeMode get mode => _mode;

  /// Alterna entre modo oscuro y claro, y persiste la elección.
  void toggle() {
    _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    PreferencesService.setThemeMode(
        _mode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }
}
