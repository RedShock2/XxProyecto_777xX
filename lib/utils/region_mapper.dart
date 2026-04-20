class RegionInfo {
  final String name;
  final String game;
  final int genStart;
  final int genEnd;
  final String description;
  final List<String> starterTypes;

  const RegionInfo({
    required this.name,
    required this.game,
    required this.genStart,
    required this.genEnd,
    required this.description,
    required this.starterTypes,
  });
}

class RegionMapper {
  static const _regions = [
    RegionInfo(
      name: 'Kanto',
      game: 'Rojo/Azul',
      genStart: 1,
      genEnd: 151,
      description: 'La región original, hogar del Profesor Oak.',
      starterTypes: ['fire', 'water', 'grass'],
    ),
    RegionInfo(
      name: 'Johto',
      game: 'Oro/Plata',
      genStart: 152,
      genEnd: 251,
      description: 'Región con fuertes tradiciones y el Pokémon Sagrado.',
      starterTypes: ['fire', 'water', 'grass'],
    ),
    RegionInfo(
      name: 'Hoenn',
      game: 'Rubí/Zafiro',
      genStart: 252,
      genEnd: 386,
      description: 'Región tropical con mucho mar y naturaleza.',
      starterTypes: ['fire', 'water', 'grass'],
    ),
    RegionInfo(
      name: 'Sinnoh',
      game: 'Diamante/Perla',
      genStart: 387,
      genEnd: 493,
      description: 'Región montañosa con mitos del origen del universo.',
      starterTypes: ['fire', 'water', 'grass'],
    ),
    RegionInfo(
      name: 'Unova',
      game: 'Negro/Blanco',
      genStart: 494,
      genEnd: 649,
      description: 'Región cosmopolita inspirada en Nueva York.',
      starterTypes: ['fire', 'water', 'grass'],
    ),
    RegionInfo(
      name: 'Kalos',
      game: 'X/Y',
      genStart: 650,
      genEnd: 721,
      description: 'Región inspirada en Francia, cuna de la Mega Evolución.',
      starterTypes: ['fire', 'water', 'grass'],
    ),
    RegionInfo(
      name: 'Alola',
      game: 'Sol/Luna',
      genStart: 722,
      genEnd: 809,
      description: 'Islas tropicales inspiradas en Hawái.',
      starterTypes: ['fire', 'water', 'grass'],
    ),
    RegionInfo(
      name: 'Galar',
      game: 'Espada/Escudo',
      genStart: 810,
      genEnd: 898,
      description: 'Región inspirada en Gran Bretaña con Dynamax.',
      starterTypes: ['grass', 'fire', 'water'],
    ),
    RegionInfo(
      name: 'Paldea',
      game: 'Escarlata/Violeta',
      genStart: 899,
      genEnd: 1025,
      description: 'Región de mundo abierto inspirada en España.',
      starterTypes: ['grass', 'fire', 'water'],
    ),
  ];

  // Rough geographic bounding boxes: [minLat, maxLat, minLon, maxLon]
  static const _geoMap = {
    'Kanto':  [35.0,  45.0,  130.0, 145.0],  // Japan
    'Johto':  [35.0,  45.0,  125.0, 140.0],  // Japan west
    'Hoenn':  [-10.0, 5.0,   110.0, 135.0],  // SE Asia / Indonesia
    'Sinnoh': [55.0,  70.0,  10.0,  40.0],   // Scandinavia
    'Unova':  [40.0,  45.0,  -80.0, -70.0],  // New York area
    'Kalos':  [42.0,  51.0,  -5.0,  10.0],   // France
    'Alola':  [18.0,  23.0,  -162.0,-154.0], // Hawaii
    'Galar':  [50.0,  59.0,  -8.0,  2.0],    // UK
    'Paldea': [36.0,  44.0,  -10.0, 4.0],    // Spain
  };

  static RegionInfo getRegionByCoords(double lat, double lon) {
    for (final entry in _geoMap.entries) {
      final box = entry.value;
      if (lat >= box[0] && lat <= box[1] && lon >= box[2] && lon <= box[3]) {
        return _regions.firstWhere((r) => r.name == entry.key);
      }
    }
    // Mexico / Central America special region → Paldea
    if (lat >= 14.0 && lat <= 33.0 && lon >= -120.0 && lon <= -85.0) {
      return _regions.firstWhere((r) => r.name == 'Paldea');
    }
    // Latin America → Hoenn
    if (lat >= -55.0 && lat <= 13.0 && lon >= -85.0 && lon <= -30.0) {
      return _regions.firstWhere((r) => r.name == 'Hoenn');
    }
    return _regions.first; // Default Kanto
  }

  static List<String> getSuggestedPokemonIds(RegionInfo region) {
    final perRegion = <String, List<String>>{
      'Kanto':  ['1', '4', '7', '25', '133', '143'],
      'Johto':  ['152', '155', '158', '175', '196', '197'],
      'Hoenn':  ['252', '255', '258', '280', '302', '373'],
      'Sinnoh': ['387', '390', '393', '448', '442', '445'],
      'Unova':  ['495', '498', '501', '532', '570', '612'],
      'Kalos':  ['650', '653', '656', '669', '700', '716'],
      'Alola':  ['722', '725', '728', '789', '791', '792'],
      'Galar':  ['810', '813', '816', '854', '888', '889'],
      'Paldea': ['906', '909', '912', '935', '987', '1000'],
    };
    return perRegion[region.name] ?? perRegion['Kanto']!;
  }

  static List<RegionInfo> get allRegions => _regions;
}
