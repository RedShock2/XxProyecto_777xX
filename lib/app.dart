import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_notifier.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/team_builder_screen.dart';
import 'screens/team_summary_screen.dart';
import 'screens/map_screen.dart';
import 'screens/qr_screen.dart';
import 'models/team.dart';

class XxProyecto777xX extends StatelessWidget {
  /// Ruta inicial: `/splash` si es primer lanzamiento, `/home` si ya hizo setup.
  final String initialRoute;

  const XxProyecto777xX({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
    return MaterialApp(
      title: 'PokéForge',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: themeNotifier.mode,
      initialRoute: initialRoute,
      onGenerateRoute: _generateRoute,
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFCC0000),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF1A1A2E),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF16213E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF16213E),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      fontFamily: 'Roboto',
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFCC0000),
        brightness: Brightness.light,
      ),
      fontFamily: 'Roboto',
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/search':
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      case '/team-builder':
        final team = settings.arguments as Team?;
        return MaterialPageRoute(
          builder: (_) => TeamBuilderScreen(team: team),
        );
      case '/team-summary':
        final team = settings.arguments as Team;
        return MaterialPageRoute(
          builder: (_) => TeamSummaryScreen(team: team),
        );
      case '/map':
        return MaterialPageRoute(builder: (_) => const MapScreen());
      case '/qr':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => QrScreen(teamJson: args?['teamJson']),
        );
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
