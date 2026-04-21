import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/team.dart';
import '../providers/team_provider.dart';
import '../services/location_service.dart';
import '../services/preferences_service.dart';
import '../utils/region_mapper.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _mapCtrl = MapController();
  final _locationSvc = LocationService();

  LatLng? _currentPos;
  bool _loadingPos = true;
  RegionInfo? _region;
  double _nearbyRadius = 2.0;

  @override
  void initState() {
    super.initState();
    _loadRadius();
    _initLocation();
  }

  Future<void> _loadRadius() async {
    final saved = await PreferencesService.getMapRadius();
    if (mounted) setState(() => _nearbyRadius = saved);
  }

  Future<void> _initLocation() async {
    setState(() => _loadingPos = true);
    final loc = await _locationSvc.getCurrentLocation();
    if (!mounted) return;

    if (loc != null) {
      final pos = LatLng(loc.latitude, loc.longitude);
      final region = RegionMapper.getRegionByCoords(loc.latitude, loc.longitude);
      setState(() {
        _currentPos = pos;
        _region = region;
        _loadingPos = false;
      });
      _mapCtrl.move(pos, 12);
    } else {
      setState(() => _loadingPos = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final teams = context.watch<TeamProvider>().teams;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa GPS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _initLocation,
            tooltip: 'Mi ubicación',
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_currentPos != null)
            FlutterMap(
              mapController: _mapCtrl,
              options: MapOptions(
                initialCenter: _currentPos!,
                initialZoom: 12,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.xxproyecto.app',
                ),
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _currentPos!,
                      radius: _nearbyRadius * 1000,
                      useRadiusInMeter: true,
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderColor: Colors.blue,
                      borderStrokeWidth: 1,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    // Marcador de posición actual
                    Marker(
                      point: _currentPos!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_pin,
                        color: Color(0xFFCC0000),
                        size: 40,
                      ),
                    ),
                    // Marcadores de equipos guardados con GPS
                    ...teams
                        .where((t) => t.location != null)
                        .map(
                          (team) => Marker(
                            point: LatLng(
                              team.location!.latitude,
                              team.location!.longitude,
                            ),
                            width: 40,
                            height: 40,
                            child: GestureDetector(
                              onTap: () => _showTeamInfo(context, team),
                              child: const Icon(
                                Icons.catching_pokemon,
                                color: Colors.orange,
                                size: 36,
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
              ],
            )
          else if (_loadingPos)
            const Center(child: CircularProgressIndicator())
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, size: 64, color: Colors.white38),
                  const SizedBox(height: 16),
                  const Text(
                    'Sin acceso al GPS',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _initLocation,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          if (_region != null)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: _RegionCard(region: _region!),
            ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _RadiusSlider(
              value: _nearbyRadius,
              onChanged: (v) {
                setState(() => _nearbyRadius = v);
                PreferencesService.setMapRadius(v);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showTeamInfo(BuildContext context, Team team) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16213E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              team.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${team.pokemonCount} Pokémon · '
              '${team.location!.savedAt.toLocal().toString().substring(0, 10)}',
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/team-builder', arguments: team);
              },
              icon: const Icon(Icons.edit),
              label: const Text('Ver equipo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCC0000),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegionCard extends StatelessWidget {
  final RegionInfo region;
  const _RegionCard({required this.region});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.catching_pokemon, color: Color(0xFFCC0000)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Región ${region.name}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    region.game,
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  Text(
                    region.description,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadiusSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  const _RadiusSlider({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.radar, color: Colors.white70, size: 18),
            const SizedBox(width: 8),
            Text(
              'Radio: ${value.toStringAsFixed(1)} km',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
            Expanded(
              child: Slider(
                value: value,
                min: 1,
                max: 5,
                divisions: 8,
                activeColor: const Color(0xFFCC0000),
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
