import 'package:flutter/foundation.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/debouncer.dart';
import '../../domain/entities/manga.dart';
import '../../domain/repositories/manga_repository.dart';

class MangaSearchController extends ChangeNotifier {
  final MangaRepository _repository;
  final Debouncer _debouncer = Debouncer(
    delay: const Duration(milliseconds: 500),
  );

  String _currentQuery = '';
  List<Manga> _searchResults = [];
  List<Manga> _popularManga = [];

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isLoadingPopular = false;

  String? _errorMessage;
  int _currentPage = 1;
  bool _hasNextPage = false;
  bool _isFromCache = false;
  bool _isStale = false;
  int _activeRequestId = 0;

  MangaSearchController({required MangaRepository repository})
    : _repository = repository {
    loadPopularManga();
  }

  // Getters
  String get currentQuery => _currentQuery;
  List<Manga> get searchResults => _searchResults;
  List<Manga> get popularManga => _popularManga;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isLoadingPopular => _isLoadingPopular;
  String? get errorMessage => _errorMessage;
  bool get hasNextPage => _hasNextPage;
  bool get isFromCache => _isFromCache;
  bool get isStale => _isStale;
  bool get isSearching => _currentQuery.trim().length >= 2;

  void onQueryChanged(String query) {
    _currentQuery = query;
    _errorMessage = null;

    if (query.trim().length < 2) {
      _activeRequestId++; // Invalida richieste in volo
      _debouncer.cancel();
      _searchResults = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    _debouncer.run(() {
      _performSearch(query, isNewSearch: true);
    });
  }

  Future<void> _performSearch(String query, {bool isNewSearch = true}) async {
    final requestId = ++_activeRequestId;

    if (isNewSearch) {
      _currentPage = 1;
      _isLoading = true;
      _errorMessage = null;
    } else {
      _isLoadingMore = true;
    }
    notifyListeners();

    try {
      final result = await _repository.searchManga(
        query: query,
        page: _currentPage,
        limit: 20,
      );

      // Protezione Race Condition: scarta se una richiesta più recente è stata emessa nel frattempo
      if (requestId != _activeRequestId) {
        return;
      }

      if (isNewSearch) {
        _searchResults = result.items;
      } else {
        _searchResults.addAll(result.items);
      }

      _hasNextPage = result.hasNextPage;
      _currentPage = result.currentPage;
      _isFromCache = result.isFromCache;
      _isStale = result.isStale;
      _isLoading = false;
      _isLoadingMore = false;
      _errorMessage = null;
      notifyListeners();
    } on Failure catch (failure) {
      if (requestId != _activeRequestId) return;
      _errorMessage = failure.message;
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    } catch (e) {
      if (requestId != _activeRequestId) return;
      _errorMessage = 'Errore imprevisto durante la ricerca. Riprova.';
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasNextPage || !isSearching) return;
    _currentPage++;
    await _performSearch(_currentQuery, isNewSearch: false);
  }

  Future<void> retry() async {
    if (isSearching) {
      await _performSearch(_currentQuery, isNewSearch: true);
    } else {
      await loadPopularManga();
    }
  }

  Future<void> loadPopularManga() async {
    if (_popularManga.isNotEmpty) return;
    final requestId = ++_activeRequestId;
    _isLoadingPopular = true;
    notifyListeners();

    try {
      final result = await _repository.getTopManga(page: 1, limit: 12);
      if (requestId != _activeRequestId) return;
      _popularManga = result.items;
      _isLoadingPopular = false;
      notifyListeners();
    } catch (e) {
      if (requestId != _activeRequestId) return;
      // Fallback a ricerca generica dei manga principali se l'endpoint top ha problemi temporanei di server
      try {
        final fallbackResult = await _repository.searchManga(
          query: 'a',
          page: 1,
          limit: 12,
        );
        if (requestId != _activeRequestId) return;
        _popularManga = fallbackResult.items;
      } catch (_) {}
      _isLoadingPopular = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _activeRequestId++; // Invalida immediatamente tutte le richieste pendenti
    _currentQuery = '';
    _searchResults = [];
    _errorMessage = null;
    _isLoading = false;
    _debouncer.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _activeRequestId++;
    _debouncer.dispose();
    super.dispose();
  }
}
