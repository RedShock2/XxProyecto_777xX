import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../services/pokeapi_service.dart';

/// Estados posibles de una operación asíncrona de carga.
enum LoadState { idle, loading, loaded, error }

/// Gestiona el estado de los Pokémon obtenidos desde la PokéAPI.
///
/// Responsabilidades:
/// - Paginación y carga incremental de la lista principal.
/// - Búsqueda por nombre y filtros por tipo y generación.
/// - Selección y comparación de Pokémon individuales con detalle completo.
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

  /// Lista de resúmenes `{name, url}` cargados con paginación.
  List<Map<String, dynamic>> get pokemonList => _pokemonList;

  /// Resultados de la última búsqueda por nombre.
  List<Pokemon> get searchResults => _searchResults;

  /// Pokémon seleccionado con detalle completo (stats, moves, evolución).
  Pokemon? get selected => _selected;

  /// Segundo Pokémon para la vista de comparación.
  Pokemon? get compareTarget => _compareTarget;

  /// Estado de carga de la lista principal.
  LoadState get listState => _listState;

  /// Estado de carga de la búsqueda.
  LoadState get searchState => _searchState;

  /// Estado de carga del detalle del Pokémon seleccionado.
  LoadState get detailState => _detailState;

  /// Mensaje de error del último fallo. Vacío si no hay error.
  String get errorMessage => _errorMessage;

  /// `true` si hay más Pokémon por cargar en la paginación.
  bool get hasMore => _hasMore;

  /// Tipo activo como filtro, vacío si no hay filtro.
  String get activeTypeFilter => _activeTypeFilter;

  /// Generación activa como filtro (1–9), 0 si no hay filtro.
  int get activeGenFilter => _activeGenFilter;

  /// Carga los siguientes 20 Pokémon en la lista paginada.
  ///
  /// No hace nada si ya hay una carga en progreso o no hay más resultados.
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

  /// Reemplaza la lista con todos los Pokémon del [type] especificado.
  ///
  /// Limpia el filtro de generación activo.
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

  /// Reemplaza la lista con todos los Pokémon de la generación [gen].
  ///
  /// Limpia el filtro de tipo activo.
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

  /// Elimina todos los filtros activos y reinicia la paginación desde el inicio.
  void clearFilters() {
    _activeTypeFilter = '';
    _activeGenFilter = 0;
    _pokemonList.clear();
    _currentOffset = 0;
    _hasMore = true;
    loadMore();
  }

  /// Busca Pokémon cuyo nombre contenga [query].
  ///
  /// Si [query] está vacío, limpia los resultados y vuelve a [LoadState.idle].
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

  /// Obtiene un Pokémon por nombre o ID sin modificar [selected].
  ///
  /// Seguro de llamar dentro de list builders sin afectar la pantalla de detalle.
  Future<Pokemon?> fetchPokemon(String nameOrId) async {
    try {
      return await _api.getPokemon(nameOrId);
    } catch (_) {
      return null;
    }
  }

  /// Carga el detalle completo de un Pokémon (stats, cadena evolutiva) y lo establece como [selected].
  ///
  /// Retorna el [Pokemon] cargado, o `null` si ocurrió un error.
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

  /// Carga un Pokémon por [nameOrId] y lo establece como [compareTarget].
  Future<void> setCompareTarget(String nameOrId) async {
    try {
      _compareTarget = await _api.getPokemon(nameOrId);
      notifyListeners();
    } catch (_) {}
  }

  /// Limpia el [compareTarget] actual.
  void clearCompare() {
    _compareTarget = null;
    notifyListeners();
  }
}
