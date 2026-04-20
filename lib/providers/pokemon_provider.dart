import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../services/pokeapi_service.dart';

enum LoadState { idle, loading, loaded, error }

class PokemonProvider extends ChangeNotifier {
  final _api = PokeApiService();

  final List<Map<String, dynamic>> _pokemonList = [];
  final List<Pokemon> _searchResults = [];
  Pokemon? _selected;
  Pokemon? _compareTarget;

  LoadState _listState = LoadState.idle;
  LoadState _searchState = LoadState.idle;
  LoadState _detailState = LoadState.idle;

  String _errorMessage = '';
  String _activeTypeFilter = '';
  int _activeGenFilter = 0;
  int _currentOffset = 0;
  bool _hasMore = true;

  List<Map<String, dynamic>> get pokemonList => _pokemonList;
  List<Pokemon> get searchResults => _searchResults;
  Pokemon? get selected => _selected;
  Pokemon? get compareTarget => _compareTarget;
  LoadState get listState => _listState;
  LoadState get searchState => _searchState;
  LoadState get detailState => _detailState;
  String get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  String get activeTypeFilter => _activeTypeFilter;
  int get activeGenFilter => _activeGenFilter;

  Future<void> loadMore() async {
    if (_listState == LoadState.loading || !_hasMore) return;
    _listState = LoadState.loading;
    notifyListeners();

    try {
      final results = await _api.getPokemonList(
        limit: 20,
        offset: _currentOffset,
      );
      if (results.isEmpty) {
        _hasMore = false;
      } else {
        _pokemonList.addAll(results);
        _currentOffset += results.length;
      }
      _listState = LoadState.loaded;
    } catch (e) {
      _listState = LoadState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> filterByType(String type) async {
    _activeTypeFilter = type;
    _activeGenFilter = 0;
    _listState = LoadState.loading;
    _pokemonList.clear();
    notifyListeners();

    try {
      final results = await _api.getPokemonByType(type);
      _pokemonList.addAll(results);
      _hasMore = false;
      _listState = LoadState.loaded;
    } catch (e) {
      _listState = LoadState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> filterByGeneration(int gen) async {
    _activeGenFilter = gen;
    _activeTypeFilter = '';
    _listState = LoadState.loading;
    _pokemonList.clear();
    notifyListeners();

    try {
      final results = await _api.getPokemonByGeneration(gen);
      _pokemonList.addAll(results);
      _hasMore = false;
      _listState = LoadState.loaded;
    } catch (e) {
      _listState = LoadState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  void clearFilters() {
    _activeTypeFilter = '';
    _activeGenFilter = 0;
    _pokemonList.clear();
    _currentOffset = 0;
    _hasMore = true;
    loadMore();
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      _searchResults.clear();
      _searchState = LoadState.idle;
      notifyListeners();
      return;
    }
    _searchState = LoadState.loading;
    notifyListeners();

    try {
      final rawResults = await _api.searchPokemon(query);
      final pokemons = await Future.wait(
        rawResults.map((r) => _api.getPokemon(r['name'] as String)),
      );
      _searchResults
        ..clear()
        ..addAll(pokemons);
      _searchState = LoadState.loaded;
    } catch (e) {
      _searchState = LoadState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  // Fetches without touching _selected state — safe to call inside list builders
  Future<Pokemon?> fetchPokemon(String nameOrId) async {
    try {
      return await _api.getPokemon(nameOrId);
    } catch (_) {
      return null;
    }
  }

  Future<Pokemon?> selectPokemon(String nameOrId) async {
    _detailState = LoadState.loading;
    notifyListeners();

    try {
      final pokemon = await _api.getPokemon(nameOrId);
      try {
        pokemon.evolutionChain = await _api.getEvolutionChain(pokemon.name);
      } catch (_) {}
      _selected = pokemon;
      _detailState = LoadState.loaded;
      notifyListeners();
      return pokemon;
    } catch (e) {
      _detailState = LoadState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> setCompareTarget(String nameOrId) async {
    try {
      _compareTarget = await _api.getPokemon(nameOrId);
      notifyListeners();
    } catch (_) {}
  }

  void clearCompare() {
    _compareTarget = null;
    notifyListeners();
  }
}
