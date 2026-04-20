import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/team_provider.dart';
import '../providers/trainer_provider.dart';
import '../models/team.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeamProvider>().loadTeams();
    });
  }

  @override
  Widget build(BuildContext context) {
    final trainer = context.watch<TrainerProvider>().trainer;
    final teamProv = context.watch<TeamProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (trainer.profileImagePath != null)
              CircleAvatar(
                radius: 18,
                backgroundImage: FileImage(File(trainer.profileImagePath!)),
              )
            else
              const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFCC0000),
                child: Icon(Icons.person, color: Colors.white, size: 18),
              ),
            const SizedBox(width: 10),
            Text(trainer.name),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () => Navigator.pushNamed(context, '/map'),
            tooltip: 'Mapa GPS',
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => Navigator.pushNamed(context, '/qr'),
            tooltip: 'Escáner QR',
          ),
        ],
      ),
      body: teamProv.loading
          ? const Center(child: CircularProgressIndicator())
          : teamProv.teams.isEmpty
              ? _EmptyState(onCreate: () => _createTeam(context))
              : _TeamList(teams: teamProv.teams),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createTeam(context),
        backgroundColor: const Color(0xFFCC0000),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo equipo'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF16213E),
        selectedItemColor: const Color(0xFFCC0000),
        unselectedItemColor: Colors.white54,
        currentIndex: 0,
        onTap: (i) {
          if (i == 1) Navigator.pushNamed(context, '/search');
          if (i == 2) Navigator.pushNamed(context, '/map');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Equipos'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
        ],
      ),
    );
  }

  Future<void> _createTeam(BuildContext context) async {
    final name = await _askTeamName(context);
    if (name == null || name.isEmpty) return;
    if (!context.mounted) return;
    final team = await context.read<TeamProvider>().createTeam(name);
    if (context.mounted) {
      Navigator.pushNamed(context, '/team-builder', arguments: team);
    }
  }

  Future<String?> _askTeamName(BuildContext context) {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text('Nombre del equipo',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Ej: Dream Team',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: Colors.white10,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCC0000)),
            child: const Text('Crear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.catching_pokemon, size: 96, color: Colors.white24),
          const SizedBox(height: 16),
          const Text(
            'Sin equipos todavía',
            style: TextStyle(color: Colors.white54, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Crea tu primer equipo Pokémon',
            style: TextStyle(color: Colors.white38, fontSize: 13),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Crear equipo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCC0000),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamList extends StatelessWidget {
  final List<Team> teams;
  const _TeamList({required this.teams});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: teams.length,
      itemBuilder: (_, i) => _TeamCard(team: teams[i]),
    );
  }
}

class _TeamCard extends StatelessWidget {
  final Team team;
  const _TeamCard({required this.team});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () =>
            Navigator.pushNamed(context, '/team-builder', arguments: team),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      team.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${team.pokemonCount}/6',
                    style: const TextStyle(color: Colors.white54),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.bar_chart, color: Colors.white70),
                    onPressed: () => Navigator.pushNamed(
                      context,
                      '/team-summary',
                      arguments: team,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _confirmDelete(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _PokemonRow(members: team.members),
              if (team.location != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.white38),
                    const SizedBox(width: 4),
                    Text(
                      team.location!.placeName ??
                          '${team.location!.latitude.toStringAsFixed(2)}, '
                          '${team.location!.longitude.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text('Eliminar equipo',
            style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Eliminar "${team.name}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<TeamProvider>().deleteTeam(team.id);
    }
  }
}

class _PokemonRow extends StatelessWidget {
  final List members;
  const _PokemonRow({required this.members});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: List.generate(6, (i) {
          if (i < members.length) {
            final p = members[i];
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Image.network(
                  p.spriteUrl,
                  height: 48,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.catching_pokemon,
                    size: 24,
                    color: Colors.white38,
                  ),
                ),
              ),
            );
          }
          return Expanded(
            child: Container(
              height: 48,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }),
      ),
    );
  }
}
