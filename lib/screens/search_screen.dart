import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pokemon_provider.dart';
import '../providers/team_provider.dart';
import '../models/pokemon.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/weakness_grid.dart';
import '../widgets/stat_bar.dart';
import '../widgets/type_badge.dart';
import '../utils/type_chart.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  late TabController _tabCtrl;

  final List<String> _types = TypeChart.allTypes;
  String? _selectedType;
  int _selectedGen = 0;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<PokemonProvider>().pokemonList.isEmpty) {
        context.read<PokemonProvider>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Pokémon'),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: const Color(0xFFCC0000),
          tabs: const [
            Tab(text: 'Lista'),
            Tab(text: 'Comparar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _ListTab(
            searchCtrl: _searchCtrl,
            types: _types,
            selectedType: _selectedType,
            selectedGen: _selectedGen,
            onTypeSelected: (t) {
              setState(() => _selectedType = t);
              if (t != null) {
                context.read<PokemonProvider>().filterByType(t);
              } else {
                context.read<PokemonProvider>().clearFilters();
              }
            },
            onGenSelected: (g) {
              setState(() => _selectedGen = g);
              if (g > 0) {
                context.read<PokemonProvider>().filterByGeneration(g);
              } else {
                context.read<PokemonProvider>().clearFilters();
              }
            },
            onSearch: (q) => context.read<PokemonProvider>().search(q),
          ),
          const _CompareTab(),
        ],
      ),
    );
  }
}

class _ListTab extends StatelessWidget {
  final TextEditingController searchCtrl;
  final List<String> types;
  final String? selectedType;
  final int selectedGen;
  final ValueChanged<String?> onTypeSelected;
  final ValueChanged<int> onGenSelected;
  final ValueChanged<String> onSearch;

  const _ListTab({
    required this.searchCtrl,
    required this.types,
    required this.selectedType,
    required this.selectedGen,
    required this.onTypeSelected,
    required this.onGenSelected,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<PokemonProvider>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: searchCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Buscar por nombre o número...',
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              filled: true,
              fillColor: Colors.white10,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () {
                        searchCtrl.clear();
                        onSearch('');
                      },
                    )
                  : null,
            ),
            onChanged: onSearch,
          ),
        ),
        // Type filter chips
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _FilterChip(
                label: 'Todos',
                selected: selectedType == null && selectedGen == 0,
                onTap: () {
                  onTypeSelected(null);
                  onGenSelected(0);
                },
              ),
              ...types.map((t) => _FilterChip(
                    label: t,
                    selected: selectedType == t,
                    onTap: () => onTypeSelected(t),
                  )),
            ],
          ),
        ),
        // Gen filter
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
            children: List.generate(
              9,
              (i) => _FilterChip(
                label: i == 0 ? 'Gen' : 'Gen $i',
                selected: selectedGen == i,
                onTap: () => onGenSelected(i),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: _buildList(context, prov),
        ),
      ],
    );
  }

  Widget _buildList(BuildContext context, PokemonProvider prov) {
    if (prov.searchState == LoadState.loading ||
        prov.listState == LoadState.loading && prov.pokemonList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final isSearching = searchCtrl.text.isNotEmpty;
    final items = isSearching ? prov.searchResults : null;

    if (isSearching && prov.searchState == LoadState.loaded) {
      if (items!.isEmpty) {
        return const Center(
          child: Text('Sin resultados', style: TextStyle(color: Colors.white54)),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: PokemonCard(
            pokemon: items[i],
            onTap: () => _openDetail(context, items[i]),
            onAdd: () => _addToTeam(context, items[i]),
          ),
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
          context.read<PokemonProvider>().loadMore();
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: prov.pokemonList.length + (prov.hasMore ? 1 : 0),
        itemBuilder: (ctx, i) {
          if (i == prov.pokemonList.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final name = prov.pokemonList[i]['name'] as String;
          return _PokemonListItem(
            name: name,
            onTap: (p) => _openDetail(ctx, p),
            onAdd: (p) => _addToTeam(ctx, p),
          );
        },
      ),
    );
  }

  void _openDetail(BuildContext context, Pokemon pokemon) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF16213E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PokemonDetailSheet(pokemon: pokemon),
    );
  }

  void _addToTeam(BuildContext context, Pokemon pokemon) {
    final teamProv = context.read<TeamProvider>();
    if (teamProv.activeTeam == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero crea o selecciona un equipo'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (teamProv.activeTeam!.isFull) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El equipo está lleno (máx. 6)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    teamProv.addPokemonToActive(pokemon);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${pokemon.displayName} añadido al equipo'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

// Loads a single pokemon by name without touching global provider state
class _PokemonListItem extends StatefulWidget {
  final String name;
  final void Function(Pokemon) onTap;
  final void Function(Pokemon) onAdd;

  const _PokemonListItem({
    required this.name,
    required this.onTap,
    required this.onAdd,
  });

  @override
  State<_PokemonListItem> createState() => _PokemonListItemState();
}

class _PokemonListItemState extends State<_PokemonListItem> {
  Pokemon? _pokemon;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await context.read<PokemonProvider>().fetchPokemon(widget.name);
    if (mounted) setState(() { _pokemon = p; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 80,
        child: Center(child: LinearProgressIndicator()),
      );
    }
    if (_pokemon == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PokemonCard(
        pokemon: _pokemon!,
        onTap: () => widget.onTap(_pokemon!),
        onAdd: () => widget.onAdd(_pokemon!),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFCC0000) : Colors.white10,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white60,
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _PokemonDetailSheet extends StatelessWidget {
  final Pokemon pokemon;
  const _PokemonDetailSheet({required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, ctrl) => ListView(
        controller: ctrl,
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Image.network(pokemon.spriteUrl, width: 100, height: 100),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${pokemon.id.toString().padLeft(3, '0')}',
                      style: const TextStyle(color: Colors.white54),
                    ),
                    Text(
                      pokemon.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      children: pokemon.types.map((t) => TypeBadge(type: t)).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Estadísticas Base',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          StatBar(label: 'HP', value: pokemon.hp, color: Colors.green),
          StatBar(label: 'Ataque', value: pokemon.attack, color: Colors.red),
          StatBar(label: 'Defensa', value: pokemon.defense, color: Colors.blue),
          StatBar(label: 'Sp. Ataque', value: pokemon.spAttack, color: Colors.purple),
          StatBar(label: 'Sp. Defensa', value: pokemon.spDefense, color: Colors.cyan),
          StatBar(label: 'Velocidad', value: pokemon.speed, color: Colors.orange),
          const SizedBox(height: 16),
          const Text('Debilidades',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          WeaknessGrid(types: pokemon.types),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<TeamProvider>().addPokemonToActive(pokemon);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${pokemon.displayName} añadido'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Añadir al equipo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCC0000),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompareTab extends StatefulWidget {
  const _CompareTab();

  @override
  State<_CompareTab> createState() => _CompareTabState();
}

class _CompareTabState extends State<_CompareTab> {
  final _ctrl1 = TextEditingController();
  final _ctrl2 = TextEditingController();
  Pokemon? _p1;
  Pokemon? _p2;
  bool _loading = false;

  @override
  void dispose() {
    _ctrl1.dispose();
    _ctrl2.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final prov = context.read<PokemonProvider>();
    final results = await Future.wait([
      prov.selectPokemon(_ctrl1.text.toLowerCase()),
      prov.selectPokemon(_ctrl2.text.toLowerCase()),
    ]);
    setState(() {
      _p1 = results[0];
      _p2 = results[1];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SearchField(
                  ctrl: _ctrl1,
                  hint: 'Pokémon 1',
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('vs', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
              Expanded(
                child: _SearchField(ctrl: _ctrl2, hint: 'Pokémon 2'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _load,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCC0000),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('Comparar'),
          ),
          const SizedBox(height: 16),
          if (_loading) const CircularProgressIndicator(),
          if (_p1 != null && _p2 != null) _CompareView(p1: _p1!, p2: _p2!),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  const _SearchField({required this.ctrl, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _CompareView extends StatelessWidget {
  final Pokemon p1;
  final Pokemon p2;
  const _CompareView({required this.p1, required this.p2});

  @override
  Widget build(BuildContext context) {
    final statNames = ['HP', 'ATK', 'DEF', 'SP.ATK', 'SP.DEF', 'SPD'];
    final stats1 = [p1.hp, p1.attack, p1.defense, p1.spAttack, p1.spDefense, p1.speed];
    final stats2 = [p2.hp, p2.attack, p2.defense, p2.spAttack, p2.spDefense, p2.speed];

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _PokemonHeader(pokemon: p1)),
            Expanded(child: _PokemonHeader(pokemon: p2)),
          ],
        ),
        const SizedBox(height: 16),
        ...List.generate(6, (i) {
          final winner = stats1[i] >= stats2[i] ? 0 : 1;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: _StatCompareTile(
                    value: stats1[i],
                    isWinner: winner == 0,
                    align: TextAlign.right,
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    statNames[i],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                ),
                Expanded(
                  child: _StatCompareTile(
                    value: stats2[i],
                    isWinner: winner == 1,
                    align: TextAlign.left,
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _TotalTile(
                label: p1.displayName,
                total: p1.totalStats,
                isWinner: p1.totalStats >= p2.totalStats,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _TotalTile(
                label: p2.displayName,
                total: p2.totalStats,
                isWinner: p2.totalStats > p1.totalStats,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PokemonHeader extends StatelessWidget {
  final Pokemon pokemon;
  const _PokemonHeader({required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.network(pokemon.spriteUrl, height: 80),
        Text(pokemon.displayName,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 4,
          children: pokemon.types.map((t) => TypeBadge(type: t, fontSize: 9)).toList(),
        ),
      ],
    );
  }
}

class _StatCompareTile extends StatelessWidget {
  final int value;
  final bool isWinner;
  final TextAlign align;
  const _StatCompareTile({
    required this.value,
    required this.isWinner,
    required this.align,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      value.toString(),
      textAlign: align,
      style: TextStyle(
        color: isWinner ? Colors.greenAccent : Colors.white54,
        fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
        fontSize: 16,
      ),
    );
  }
}

class _TotalTile extends StatelessWidget {
  final String label;
  final int total;
  final bool isWinner;
  const _TotalTile({
    required this.label,
    required this.total,
    required this.isWinner,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isWinner
            ? Colors.green.withOpacity(0.2)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWinner ? Colors.greenAccent : Colors.white12,
        ),
      ),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                color: isWinner ? Colors.greenAccent : Colors.white54,
                fontSize: 12,
              )),
          Text('BST $total',
              style: TextStyle(
                color: isWinner ? Colors.greenAccent : Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              )),
          if (isWinner)
            const Icon(Icons.emoji_events, color: Colors.amber, size: 18),
        ],
      ),
    );
  }
}
