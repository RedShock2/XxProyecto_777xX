import 'package:shared_preferences/shared_preferences.dart';

/// Acceso centralizado a [SharedPreferences] para preferencias simples de la app.
///
/// Cada clave tiene un método getter y setter tipados.
/// Usa valores por defecto seguros cuando la clave no existe aún.
class PreferencesService {
  static Future<SharedPreferences> get _prefs =>
      SharedPreferences.getInstance();

  // ── setup_done ────────────────────────────────────────────────────────────

  /// Marca si el entrenador ya completó el setup inicial (nombre + perfil).
  static Future<void> setSetupDone(bool value) async =>
      (await _prefs).setBool('setup_done', value);

  /// Retorna `true` si el usuario ya completó el setup inicial.
  static Future<bool> getSetupDone() async =>
      (await _prefs).getBool('setup_done') ?? false;

  // ── theme_mode ────────────────────────────────────────────────────────────

  /// Guarda la preferencia de tema: `'dark'` o `'light'`.
  static Future<void> setThemeMode(String value) async =>
      (await _prefs).setString('theme_mode', value);

  /// Retorna `'dark'` o `'light'`. Por defecto `'dark'`.
  static Future<String> getThemeMode() async =>
      (await _prefs).getString('theme_mode') ?? 'dark';

  // ── map_radius ────────────────────────────────────────────────────────────

  /// Guarda el radio de búsqueda en el mapa (en kilómetros).
  static Future<void> setMapRadius(double value) async =>
      (await _prefs).setDouble('map_radius', value);

  /// Retorna el radio guardado. Por defecto `2.0` km.
  static Future<double> getMapRadius() async =>
      (await _prefs).getDouble('map_radius') ?? 2.0;
}
