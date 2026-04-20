import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/team.dart';
import '../providers/team_provider.dart';
import '../widgets/team_slot_widget.dart';
import '../widgets/weakness_grid.dart';

class TeamBuilderScreen extends StatefulWidget {
  final Team? team;
  const TeamBuilderScreen({super.key, this.team});

  @override
  State<TeamBuilderScreen> createState() => _TeamBuilderScreenState();
}

class _TeamBuilderScreenState extends State<TeamBuilderScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.team != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<TeamProvider>().setActive(widget.team!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamProv = context.watch<TeamProvider>();
    final team = teamProv.activeTeam ?? widget.team;

    if (team == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Constructor de Equipo')),
        body: const Center(
          child: Text('Sin equipo activo',
              style: TextStyle(color: Colors.white54)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(team.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: () => _attachLocation(context, team),
            tooltip: 'Guardar ubicación GPS',
          ),
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: () => Navigator.pushNamed(
              context,
              '/qr',
              arguments: {'teamJson': team.toQrJson()},
            ),
            tooltip: 'Compartir QR',
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () =>
                Navigator.pushNamed(context, '/team-summary', arguments: team),
            tooltip: 'Análisis del equipo',
          ),
        ],
      ),
      body: Column(
        children: [
          _TeamHeader(team: team),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemCount: 6,
                itemBuilder: (_, i) => TeamSlotWidget(
                  index: i,
                  pokemon: team.slots[i],
                  onTap: team.slots[i] == null
                      ? () => Navigator.pushNamed(context, '/search')
                      : null,
                  onRemove: team.slots[i] != null
                      ? () => context
                          .read<TeamProvider>()
                          .removePokemonFromActive(i)
                      : null,
                ),
              ),
            ),
          ),
          if (team.members.isNotEmpty) ...[
            const Divider(color: Colors.white12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Debilidades del equipo',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _TeamWeaknessRow(team: team),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/search'),
        backgroundColor: const Color(0xFFCC0000),
        icon: const Icon(Icons.add),
        label: const Text('Añadir Pokémon'),
      ),
    );
  }

  Future<void> _attachLocation(BuildContext context, Team team) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Obteniendo ubicación GPS...')),
    );
    await context.read<TeamProvider>().attachLocation(team);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ubicación GPS guardada'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

class _TeamHeader extends StatelessWidget {
  final Team team;
  const _TeamHeader({required this.team});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white.withValues(alpha: 0.05),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${team.pokemonCount}/6 Pokémon',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          if (team.location != null)
            const Icon(Icons.location_on, color: Colors.greenAccent, size: 18),
          const SizedBox(width: 4),
          Text(
            'BST promedio: ${team.members.isEmpty ? 0 : (team.members.fold(0, (s, p) => s + p.totalStats) / team.members.length).round()}',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _TeamWeaknessRow extends StatelessWidget {
  final Team team;
  const _TeamWeaknessRow({required this.team});

  @override
  Widget build(BuildContext context) {
    if (team.members.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 120,
      child: SingleChildScrollView(
        child: WeaknessGrid(
          types: team.members.expand((p) => p.types).toSet().toList(),
        ),
      ),
    );
  }
}
