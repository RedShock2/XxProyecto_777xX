import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/team_provider.dart';
import '../services/location_service.dart';
import '../utils/region_mapper.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapCtrl;
  final _locationSvc = LocationService();

  LatLng? _currentPos;
  bool _loadingPos = true;
  RegionInfo? _region;
  double _nearbyRadius = 2.0; // km
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
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
      _buildMarkers();
      _mapCtrl?.animateCamera(CameraUpdate.newLatLngZoom(pos, 12));
    } else {
      setState(() => _loadingPos = false);
    }
  }

  void _buildMarkers() {
    final teams = context.read<TeamProvider>().teams;
    final markers = <Marker>{};
    final circles = <Circle>{};

    if (_currentPos != null) {
      markers.add(Marker(
        markerId: const MarkerId('me'),
        position: _currentPos!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Mi ubicación'),
      ));
      circles.add(Circle(
        circleId: const CircleId('nearby'),
        center: _currentPos!,
        radius: _nearbyRadius * 1000,
        fillColor: Colors.blue.withOpacity(0.1),
        strokeColor: Colors.blue,
        strokeWidth: 1,
      ));
    }

    for (final team in teams) {
      if (team.location != null) {
        final pos = LatLng(team.location!.latitude, team.location!.longitude);
        markers.add(Marker(
          markerId: MarkerId('team_${team.id}'),
          position: pos,
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(
            title: team.name,
            snippet:
                '${team.pokemonCount} Pokémon • ${team.location!.savedAt.toLocal().toString().substring(0, 10)}',
          ),
          onTap: () => Navigator.pushNamed(
            context,
            '/team-builder',
            arguments: team,
          ),
        ));
      }
    }

    setState(() {
      _markers = markers;
      _circles = circles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa GPS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _initLocation,
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_currentPos != null)
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPos!,
                zoom: 12,
              ),
              onMapCreated: (c) => _mapCtrl = c,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              markers: _markers,
              circles: _circles,
              mapType: MapType.normal,
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
          // Region info card
          if (_region != null)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: _RegionCard(region: _region!),
            ),
          // Radius slider
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _RadiusSlider(
              value: _nearbyRadius,
              onChanged: (v) {
                setState(() => _nearbyRadius = v);
                _buildMarkers();
              },
            ),
          ),
        ],
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
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  Text(
                    region.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
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
