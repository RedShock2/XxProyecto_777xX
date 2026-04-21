import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/team_provider.dart';
import 'providers/pokemon_provider.dart';
import 'providers/trainer_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<String>('teams');
  await Hive.openBox<String>('trainer');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TrainerProvider()),
        ChangeNotifierProvider(create: (_) => PokemonProvider()),
        ChangeNotifierProvider(create: (_) => TeamProvider()),
      ],
      child: const XxProyecto777xX(),
    ),
  );
}
