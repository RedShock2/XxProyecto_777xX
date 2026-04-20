// Pokémon type effectiveness chart (Gen 6+)
class TypeChart {
  static const List<String> allTypes = [
    'normal', 'fire', 'water', 'electric', 'grass', 'ice',
    'fighting', 'poison', 'ground', 'flying', 'psychic', 'bug',
    'rock', 'ghost', 'dragon', 'dark', 'steel', 'fairy',
  ];

  // effectiveness[attackingType][defendingType] = multiplier
  static const Map<String, Map<String, double>> _chart = {
    'normal':   {'rock': 0.5, 'ghost': 0, 'steel': 0.5},
    'fire':     {'fire': 0.5, 'water': 0.5, 'grass': 2, 'ice': 2, 'bug': 2, 'rock': 0.5, 'dragon': 0.5, 'steel': 2},
    'water':    {'fire': 2, 'water': 0.5, 'grass': 0.5, 'ground': 2, 'rock': 2, 'dragon': 0.5},
    'electric': {'water': 2, 'electric': 0.5, 'grass': 0.5, 'ground': 0, 'flying': 2, 'dragon': 0.5},
    'grass':    {'fire': 0.5, 'water': 2, 'grass': 0.5, 'poison': 0.5, 'ground': 2, 'flying': 0.5, 'bug': 0.5, 'rock': 2, 'dragon': 0.5, 'steel': 0.5},
    'ice':      {'water': 0.5, 'grass': 2, 'ice': 0.5, 'ground': 2, 'flying': 2, 'dragon': 2, 'steel': 0.5},
    'fighting': {'normal': 2, 'ice': 2, 'poison': 0.5, 'flying': 0.5, 'psychic': 0.5, 'bug': 0.5, 'rock': 2, 'ghost': 0, 'dark': 2, 'steel': 2, 'fairy': 0.5},
    'poison':   {'grass': 2, 'poison': 0.5, 'ground': 0.5, 'rock': 0.5, 'ghost': 0.5, 'steel': 0, 'fairy': 2},
    'ground':   {'fire': 2, 'electric': 2, 'grass': 0.5, 'poison': 2, 'flying': 0, 'bug': 0.5, 'rock': 2, 'steel': 2},
    'flying':   {'electric': 0.5, 'grass': 2, 'fighting': 2, 'bug': 2, 'rock': 0.5, 'steel': 0.5},
    'psychic':  {'fighting': 2, 'poison': 2, 'psychic': 0.5, 'dark': 0, 'steel': 0.5},
    'bug':      {'fire': 0.5, 'grass': 2, 'fighting': 0.5, 'poison': 0.5, 'flying': 0.5, 'psychic': 2, 'ghost': 0.5, 'dark': 2, 'steel': 0.5, 'fairy': 0.5},
    'rock':     {'fire': 2, 'ice': 2, 'fighting': 0.5, 'ground': 0.5, 'flying': 2, 'bug': 2, 'steel': 0.5},
    'ghost':    {'normal': 0, 'psychic': 2, 'ghost': 2, 'dark': 0.5},
    'dragon':   {'dragon': 2, 'steel': 0.5, 'fairy': 0},
    'dark':     {'fighting': 0.5, 'psychic': 2, 'ghost': 2, 'dark': 0.5, 'fairy': 0.5},
    'steel':    {'fire': 0.5, 'water': 0.5, 'electric': 0.5, 'ice': 2, 'rock': 2, 'steel': 0.5, 'fairy': 2},
    'fairy':    {'fire': 0.5, 'fighting': 2, 'poison': 0.5, 'dragon': 2, 'dark': 2, 'steel': 0.5},
  };

  static double getEffectiveness(String attackType, String defenseType) {
    return _chart[attackType]?[defenseType] ?? 1.0;
  }

  static double getDefensiveMultiplier(
    String attackType,
    List<String> defenderTypes,
  ) {
    return defenderTypes.fold(
      1.0,
      (mult, t) => mult * getEffectiveness(attackType, t),
    );
  }

  // Returns map of type -> multiplier for all attacking types against the given defender types
  static Map<String, double> getFullWeaknessMap(List<String> defenderTypes) {
    final result = <String, double>{};
    for (final attack in allTypes) {
      result[attack] = getDefensiveMultiplier(attack, defenderTypes);
    }
    return result;
  }

  // Returns team-wide weakness analysis
  static Map<String, int> getTeamWeaknessCount(
    List<List<String>> allMemberTypes,
  ) {
    final counts = <String, int>{};
    for (final attack in allTypes) {
      int weak = 0;
      for (final memberTypes in allMemberTypes) {
        final mult = getDefensiveMultiplier(attack, memberTypes);
        if (mult > 1) weak++;
      }
      counts[attack] = weak;
    }
    return counts;
  }
}
