import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class PokeApiService {
  static const String _base = 'https://pokeapi.co/api/v2';
  static const int _timeout = 10;

  static final PokeApiService _instance = PokeApiService._();
  factory PokeApiService() => _instance;
  PokeApiService._();

  final Map<String, Pokemon> _cache = {};

  Future<Pokemon> getPokemon(String nameOrId) async {
    final key = nameOrId.toLowerCase();
    if (_cache.containsKey(key)) return _cache[key]!;

    final res = await http
        .get(Uri.parse('$_base/pokemon/$key'))
        .timeout(const Duration(seconds: _timeout));

    if (res.statusCode != 200) {
      throw Exception('Pokémon "$nameOrId" no encontrado (${res.statusCode})');
    }

    final pokemon = Pokemon.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    _cache[key] = pokemon;
    return pokemon;
  }

  Future<List<Map<String, dynamic>>> getPokemonList({
    int limit = 20,
    int offset = 0,
  }) async {
    final res = await http
        .get(Uri.parse('$_base/pokemon?limit=$limit&offset=$offset'))
        .timeout(const Duration(seconds: _timeout));

    if (res.statusCode != 200) throw Exception('Error al listar Pokémon');

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(data['results'] as List);
  }

  Future<List<Map<String, dynamic>>> getPokemonByType(String type) async {
    final res = await http
        .get(Uri.parse('$_base/type/$type'))
        .timeout(const Duration(seconds: _timeout));

    if (res.statusCode != 200) throw Exception('Tipo "$type" no encontrado');

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final entries = data['pokemon'] as List<dynamic>;
    return entries
        .take(50)
        .map((e) => e['pokemon'] as Map<String, dynamic>)
        .toList();
  }

  Future<List<Map<String, dynamic>>> getPokemonByGeneration(int gen) async {
    final res = await http
        .get(Uri.parse('$_base/generation/$gen'))
        .timeout(const Duration(seconds: _timeout));

    if (res.statusCode != 200) throw Exception('Generación $gen no encontrada');

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(data['pokemon_species'] as List);
  }

  Future<EvolutionNode?> getEvolutionChain(String speciesName) async {
    final speciesRes = await http
        .get(Uri.parse('$_base/pokemon-species/$speciesName'))
        .timeout(const Duration(seconds: _timeout));

    if (speciesRes.statusCode != 200) return null;

    final speciesData = jsonDecode(speciesRes.body) as Map<String, dynamic>;
    final chainUrl = speciesData['evolution_chain']['url'] as String;

    final chainRes = await http
        .get(Uri.parse(chainUrl))
        .timeout(const Duration(seconds: _timeout));

    if (chainRes.statusCode != 200) return null;

    final chainData = jsonDecode(chainRes.body) as Map<String, dynamic>;
    return _parseEvolutionChain(chainData['chain'] as Map<String, dynamic>);
  }

  EvolutionNode _parseEvolutionChain(Map<String, dynamic> chain) {
    final speciesName = chain['species']['name'] as String;
    final evolvesTo = (chain['evolves_to'] as List<dynamic>)
        .map((e) => _parseEvolutionChain(e as Map<String, dynamic>))
        .toList();
    return EvolutionNode(speciesName: speciesName, evolvesTo: evolvesTo);
  }

  Future<List<Map<String, dynamic>>> searchPokemon(String query) async {
    if (query.isEmpty) return [];
    try {
      final pokemon = await getPokemon(query.toLowerCase());
      return [
        {'name': pokemon.name, 'url': '$_base/pokemon/${pokemon.id}'}
      ];
    } catch (_) {
      final allRes = await http
          .get(Uri.parse('$_base/pokemon?limit=1000'))
          .timeout(const Duration(seconds: _timeout));
      if (allRes.statusCode != 200) return [];
      final data = jsonDecode(allRes.body) as Map<String, dynamic>;
      final results = (data['results'] as List<dynamic>)
          .where((p) =>
              (p['name'] as String).contains(query.toLowerCase()))
          .cast<Map<String, dynamic>>()
          .take(20)
          .toList();
      return results;
    }
  }
}
