import 'package:flutter/foundation.dart';
import '../../domain/entities/library_entry.dart';
import '../../domain/entities/library_entry_merger.dart';
import '../../domain/entities/library_statistics.dart';
import '../../domain/entities/reading_status.dart';
import '../../domain/repositories/library_repository.dart';

enum AddEntryResult { added, alreadyInLibrary, updated }

enum LibrarySortOption {
  lastUpdated,
  lastRead,
  title,
  rating,
  progress;

  String get label {
    switch (this) {
      case LibrarySortOption.lastUpdated:
        return 'Ultimo aggiornamento';
      case LibrarySortOption.lastRead:
        return 'Ultima lettura';
      case LibrarySortOption.title:
        return 'Titolo alfabetico';
      case LibrarySortOption.rating:
        return 'Valutazione';
      case LibrarySortOption.progress:
        return 'Progresso capitoli';
    }
  }
}

class LibraryController extends ChangeNotifier {
  final LibraryRepository _repository;

  List<LibraryEntry> _entries = [];
  bool _isLoading = true;
  String? _errorMessage;

  ReadingStatus? _selectedStatusFilter;
  bool _showFavoritesOnly = false;
  String _searchQuery = '';
  LibrarySortOption _sortOption = LibrarySortOption.lastUpdated;
  bool _isGridView = true;

  LibraryController({required LibraryRepository repository})
    : _repository = repository {
    loadLibrary();
  }

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<LibraryEntry> get allEntries => _entries;
  ReadingStatus? get selectedStatusFilter => _selectedStatusFilter;
  bool get showFavoritesOnly => _showFavoritesOnly;
  String get searchQuery => _searchQuery;
  LibrarySortOption get sortOption => _sortOption;
  bool get isGridView => _isGridView;

  LibraryStatistics get statistics => LibraryStatistics.fromEntries(_entries);

  // Lista filtrata e ordinata per la schermata Libreria
  List<LibraryEntry> get filteredEntries {
    var result = List<LibraryEntry>.from(_entries);

    // Filtro per stato
    if (_selectedStatusFilter != null) {
      result = result.where((e) => e.status == _selectedStatusFilter).toList();
    }

    // Filtro per preferiti
    if (_showFavoritesOnly) {
      result = result.where((e) => e.isFavorite).toList();
    }

    // Ricerca testuale
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      result = result.where((e) => e.title.toLowerCase().contains(q)).toList();
    }

    // Ordinamento
    switch (_sortOption) {
      case LibrarySortOption.lastUpdated:
        result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case LibrarySortOption.lastRead:
        result.sort((a, b) {
          if (a.lastReadAt == null && b.lastReadAt == null) return 0;
          if (a.lastReadAt == null) return 1;
          if (b.lastReadAt == null) return -1;
          return b.lastReadAt!.compareTo(a.lastReadAt!);
        });
        break;
      case LibrarySortOption.title:
        result.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
      case LibrarySortOption.rating:
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case LibrarySortOption.progress:
        result.sort((a, b) => b.currentChapter.compareTo(a.currentChapter));
        break;
    }

    return result;
  }

  // Manga attualmente in lettura per la sezione Continua a leggere
  List<LibraryEntry> get continueReadingEntries {
    final reading = _entries
        .where((e) => e.status == ReadingStatus.reading)
        .toList();
    reading.sort((a, b) {
      final aDate = a.lastReadAt ?? a.updatedAt;
      final bDate = b.lastReadAt ?? b.updatedAt;
      return bDate.compareTo(aDate);
    });
    return reading;
  }

  // Manga aggiunti di recente
  List<LibraryEntry> get recentlyAddedEntries {
    final list = List<LibraryEntry>.from(_entries);
    list.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return list.take(8).toList();
  }

  // Manga nella lista "Da leggere"
  List<LibraryEntry> get planToReadEntries {
    return _entries.where((e) => e.status == ReadingStatus.planToRead).toList();
  }

  // Verifica se un manga è nella libreria
  bool isInLibrary(int mangaId) {
    return _entries.any((e) => e.mangaId == mangaId);
  }

  LibraryEntry? getEntry(int mangaId) {
    try {
      return _entries.firstWhere((e) => e.mangaId == mangaId);
    } catch (_) {
      return null;
    }
  }

  // Azioni di caricamento
  Future<void> loadLibrary() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _entries = List<LibraryEntry>.from(await _repository.getLibrary());
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Impossibile caricare la libreria locale.';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filtri e visualizzazione
  void setStatusFilter(ReadingStatus? status) {
    _selectedStatusFilter = status;
    notifyListeners();
  }

  void toggleFavoritesFilter() {
    _showFavoritesOnly = !_showFavoritesOnly;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortOption(LibrarySortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  void toggleViewMode() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  // Modifiche alle voci
  Future<AddEntryResult> addOrUpdateEntry(LibraryEntry entry) async {
    final index = _entries.indexWhere((e) => e.mangaId == entry.mangaId);
    if (index >= 0) {
      final existing = _entries[index];
      final merged = LibraryEntryMerger.merge(existing, entry);
      _entries[index] = merged;
      notifyListeners();
      await _repository.saveEntry(merged);
      return AddEntryResult.alreadyInLibrary;
    } else {
      final newEntry = entry.copyWith(
        addedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _entries.add(newEntry);
      notifyListeners();
      await _repository.saveEntry(newEntry);
      return AddEntryResult.added;
    }
  }

  Future<void> removeEntry(int mangaId) async {
    _entries.removeWhere((e) => e.mangaId == mangaId);
    notifyListeners();
    await _repository.removeEntry(mangaId);
  }

  Future<void> incrementChapter(int mangaId) async {
    final entry = getEntry(mangaId);
    if (entry != null) {
      final nextChapter = entry.currentChapter + 1;
      if (entry.totalChapters != null &&
          entry.totalChapters! > 0 &&
          nextChapter > entry.totalChapters!) {
        return;
      }
      await updateProgress(mangaId, nextChapter);
    }
  }

  Future<void> decrementChapter(int mangaId) async {
    final entry = getEntry(mangaId);
    if (entry != null && entry.currentChapter > 0) {
      await updateProgress(mangaId, entry.currentChapter - 1);
    }
  }

  Future<void> updateProgress(int mangaId, int chapter) async {
    final index = _entries.indexWhere((e) => e.mangaId == mangaId);
    if (index >= 0) {
      final updated = _entries[index].copyWith(
        currentChapter: chapter < 0 ? 0 : chapter,
        lastReadAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _entries[index] = updated;
      notifyListeners();
      await _repository.updateProgress(mangaId, chapter);
    }
  }

  Future<void> incrementOwnedVolume(int mangaId) async {
    final entry = getEntry(mangaId);
    if (entry != null) {
      final next = entry.ownedVolumes + 1;
      if (entry.totalVolumes != null &&
          entry.totalVolumes! > 0 &&
          next > entry.totalVolumes!) {
        return;
      }
      await updateVolumes(mangaId, next);
    }
  }

  Future<void> decrementOwnedVolume(int mangaId) async {
    final entry = getEntry(mangaId);
    if (entry != null && entry.ownedVolumes > 0) {
      await updateVolumes(mangaId, entry.ownedVolumes - 1);
    }
  }

  Future<void> updateVolumes(
    int mangaId,
    int ownedVolumes, {
    int? totalVolumes,
  }) async {
    final index = _entries.indexWhere((e) => e.mangaId == mangaId);
    if (index >= 0) {
      final current = _entries[index];
      final targetTotal = totalVolumes ?? current.totalVolumes;
      int safeOwned = ownedVolumes < 0 ? 0 : ownedVolumes;
      if (targetTotal != null && targetTotal > 0 && safeOwned > targetTotal) {
        safeOwned = targetTotal;
      }
      final updated = current.copyWith(
        ownedVolumes: safeOwned,
        totalVolumes: targetTotal,
        updatedAt: DateTime.now(),
      );
      _entries[index] = updated;
      notifyListeners();
      await _repository.updateVolumes(
        mangaId,
        safeOwned,
        totalVolumes: targetTotal,
      );
    }
  }

  Future<void> updateStatus(int mangaId, ReadingStatus status) async {
    final index = _entries.indexWhere((e) => e.mangaId == mangaId);
    if (index >= 0) {
      final updated = _entries[index].copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      _entries[index] = updated;
      notifyListeners();
      await _repository.updateStatus(mangaId, status);
    }
  }

  Future<void> updateRating(int mangaId, int rating) async {
    final index = _entries.indexWhere((e) => e.mangaId == mangaId);
    if (index >= 0) {
      final updated = _entries[index].copyWith(
        rating: rating.clamp(0, 10),
        updatedAt: DateTime.now(),
      );
      _entries[index] = updated;
      notifyListeners();
      await _repository.updateRating(mangaId, rating);
    }
  }

  Future<void> updateNotes(int mangaId, String notes) async {
    final index = _entries.indexWhere((e) => e.mangaId == mangaId);
    if (index >= 0) {
      final updated = _entries[index].copyWith(
        notes: notes,
        updatedAt: DateTime.now(),
      );
      _entries[index] = updated;
      notifyListeners();
      await _repository.updateNotes(mangaId, notes);
    }
  }

  Future<void> toggleFavorite(int mangaId) async {
    final index = _entries.indexWhere((e) => e.mangaId == mangaId);
    if (index >= 0) {
      final updated = _entries[index].copyWith(
        isFavorite: !_entries[index].isFavorite,
        updatedAt: DateTime.now(),
      );
      _entries[index] = updated;
      notifyListeners();
      await _repository.toggleFavorite(mangaId);
    }
  }

  Future<void> clearAll() async {
    _entries.clear();
    notifyListeners();
    await _repository.clearAllData();
  }
}
