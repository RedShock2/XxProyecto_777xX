import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/team.dart';
import '../models/pokemon.dart';
import '../utils/type_chart.dart';
import '../utils/type_colors.dart';
import '../widgets/weakness_grid.dart';
import '../widgets/stat_bar.dart';
import '../widgets/type_badge.dart';

class TeamSummaryScreen extends StatelessWidget {
  final Team team;
  const TeamSummaryScreen({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    final members = team.members;

    return Scaffold(
      appBar: AppBar(
        title: Text('Análisis: ${team.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: () => Navigator.pushNamed(
              context,
              '/qr',
              arguments: {'teamJson': team.toQrJson()},
            ),
          ),
        ],
      ),
      body: members.isEmpty
          ? const Center(
              child: Text(
                'El equipo está vacío',
                style: TextStyle(color: Colors.white54),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const _SectionHeader(title: 'Gráfica de Stats BST', icon: Icons.show_chart),
                const SizedBox(height: 8),
                _TeamRadarChart(members: members),
                const SizedBox(height: 24),
                const _SectionHeader(title: 'Stats individuales', icon: Icons.bar_chart),
                const SizedBox(height: 8),
                ...members.map((p) => _PokemonStatCard(pokemon: p)),
                const SizedBox(height: 24),
                const _SectionHeader(
                  title: 'Debilidades del equipo completo',
                  icon: Icons.shield,
                ),
                const SizedBox(height: 8),
                _TeamWeaknessSection(members: members),
                const SizedBox(height: 24),
                const _SectionHeader(
                  title: 'Cobertura de tipos ofensivos',
                  icon: Icons.flash_on,
                ),
                const SizedBox(height: 8),
                _TypeCoverageSection(members: members),
              ],
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFCC0000), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _TeamRadarChart extends StatelessWidget {
  final List<Pokemon> members;
  const _TeamRadarChart({required this.members});

  @override
  Widget build(BuildContext context) {
    const statLabels = ['HP', 'ATK', 'DEF', 'SpA', 'SpD', 'SPD'];
    final colors = [
      Colors.red, Colors.blue, Colors.green,
      Colors.orange, Colors.purple, Colors.cyan,
    ];

    return Container(
      height: 260,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: RadarChart(
        RadarChartData(
          dataSets: members.asMap().entries.map((e) {
            final p = e.value;
            final stats = [
              p.hp.toDouble(),
              p.attack.toDouble(),
              p.defense.toDouble(),
              p.spAttack.toDouble(),
              p.spDefense.toDouble(),
              p.speed.toDouble(),
            ];
            return RadarDataSet(
              dataEntries: stats.map((s) => RadarEntry(value: s)).toList(),
              fillColor: colors[e.key % colors.length].withOpacity(0.2),
              borderColor: colors[e.key % colors.length],
              borderWidth: 2,
            );
          }).toList(),
          radarBorderData: const BorderSide(color: Colors.white12),
          gridBorderData: const BorderSide(color: Colors.white12),
          tickBorderData: const BorderSide(color: Colors.transparent),
          ticksTextStyle:
              const TextStyle(color: Colors.transparent, fontSize: 0),
          radarBackgroundColor: Colors.transparent,
          titleTextStyle: const TextStyle(color: Colors.white60, fontSize: 11),
          getTitle: (i, _) => RadarChartTitle(text: statLabels[i]),
          tickCount: 4,
        ),
      ),
    );
  }
}

class _PokemonStatCard extends StatelessWidget {
  final Pokemon pokemon;
  const _PokemonStatCard({required this.pokemon});

  @override
  Widget build(BuildContext context) {
    final primaryColor = TypeColors.of(pokemon.types.first);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.network(pokemon.spriteUrl, height: 52),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pokemon.displayName,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 4,
                      children: pokemon.types
                          .map((t) => TypeBadge(type: t, fontSize: 9))
                          .toList(),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'BST ${pokemon.totalStats}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          StatBar(label: 'HP', value: pokemon.hp, color: Colors.green),
          StatBar(label: 'Ataque', value: pokemon.attack, color: Colors.red),
          StatBar(label: 'Defensa', value: pokemon.defense, color: Colors.blue),
          StatBar(label: 'Sp.Ataque', value: pokemon.spAttack, color: Colors.purple),
          StatBar(label: 'Sp.Defensa', value: pokemon.spDefense, color: Colors.cyan),
          StatBar(label: 'Velocidad', value: pokemon.speed, color: Colors.orange),
        ],
      ),
    );
  }
}

class _TeamWeaknessSection extends StatelessWidget {
  final List<Pokemon> members;
  const _TeamWeaknessSection({required this.members});

  @override
  Widget build(BuildContext context) {
    final allTypes = members.expand((p) => p.types).toList();
    final weakCounts = TypeChart.getTeamWeaknessCount(
      members.map((p) => p.types).toList(),
    );

    final sorted = weakCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WeaknessGrid(types: allTypes.toSet().toList()),
        const SizedBox(height: 12),
        const Text(
          'Pokémon del equipo débiles a:',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 8),
        ...sorted.where((e) => e.value > 0).map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  TypeBadge(type: e.key, fontSize: 10),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: e.value / members.length,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation(
                        e.value >= 3 ? Colors.red : Colors.orange,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${e.value}/${members.length}',
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

class _TypeCoverageSection extends StatelessWidget {
  final List<Pokemon> members;
  const _TypeCoverageSection({required this.members});

  @override
  Widget build(BuildContext context) {
    final offensiveTypes = members.expand((p) => p.types).toSet().toList();

    final coverage = <String, double>{};
    for (final defType in TypeChart.allTypes) {
      final best = offensiveTypes.fold(
        1.0,
        (best, atkType) {
          final eff = TypeChart.getEffectiveness(atkType, defType);
          return eff > best ? eff : best;
        },
      );
      coverage[defType] = best;
    }

    final superEff = coverage.entries.where((e) => e.value >= 2).toList();
    final neutral = coverage.entries.where((e) => e.value == 1).toList();
    final notEff = coverage.entries.where((e) => e.value < 1).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CoverageGroup(
          label: 'Super efectivo (${superEff.length} tipos)',
          entries: superEff,
          color: Colors.green,
        ),
        const SizedBox(height: 8),
        _CoverageGroup(
          label: 'Neutral (${neutral.length} tipos)',
          entries: neutral,
          color: Colors.blue,
        ),
        const SizedBox(height: 8),
        _CoverageGroup(
          label: 'Poco efectivo (${notEff.length} tipos)',
          entries: notEff,
          color: Colors.red,
        ),
      ],
    );
  }
}

class _CoverageGroup extends StatelessWidget {
  final String label;
  final List<MapEntry<String, double>> entries;
  final Color color;
  const _CoverageGroup({
    required this.label,
    required this.entries,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: color, fontSize: 13)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: entries.map((e) => TypeBadge(type: e.key)).toList(),
        ),
      ],
    );
  }
}
