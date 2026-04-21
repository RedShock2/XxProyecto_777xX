import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/team_provider.dart';
import 'providers/pokemon_provider.dart';
import 'providers/trainer_provider.dart';
import 'providers/theme_notifier.dart';
import 'services/preferences_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<String>('teams');
  await Hive.openBox<String>('trainer');

  final setupDone = await PreferencesService.getSetupDone();
  final savedTheme = await PreferencesService.getThemeMode();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TrainerProvider()),
        ChangeNotifierProvider(create: (_) => PokemonProvider()),
        ChangeNotifierProvider(create: (_) => TeamProvider()),
        ChangeNotifierProvider(
          create: (_) => ThemeNotifier(
            savedTheme == 'light' ? ThemeMode.light : ThemeMode.dark,
          ),
        ),
      ],
      child: XxProyecto777xX(
        initialRoute: setupDone ? '/home' : '/splash',
      ),
    ),
  );
}
