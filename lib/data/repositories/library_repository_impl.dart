import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:manga_library/core/constants/app_constants.dart';
import 'package:manga_library/core/errors/failures.dart';
import 'package:manga_library/core/utils/debouncer.dart';
import 'package:manga_library/domain/entities/library_entry.dart';
import 'package:manga_library/domain/entities/reading_status.dart';
import 'package:manga_library/domain/repositories/library_repository.dart';
import 'package:manga_library/data/models/library_entry_dto.dart';
import 'package:manga_library/data/storage/json_storage.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final JsonStorage storage;
  final Debouncer _autosaveDebouncer;
  final List<LibraryEntry> _entries = [];
  bool _isLoaded = false;
  final Completer<void> _initCompleter = Completer<void>();

  LibraryRepositoryImpl({
    required this.storage,
    Duration autosaveDebounce = AppConstants.autosaveDebounce,
  }) : _autosaveDebouncer = Debouncer(delay: autosaveDebounce) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final data = await storage.readData();
      final entriesRaw = data['entries'] as List<dynamic>? ?? [];
      
      _entries.clear();
      for (final item in entriesRaw) {
        if (item is Map<String, dynamic>) {
          try {
            final dto = LibraryEntryDto.fromJson(item);
            _entries.add(dto.toDomain());
          } catch (e) {
            if (kDebugMode) {
              debugPrint('[LibraryRepository] Voce saltata a causa di errore di parsing: $e');
            }
          }
        }
      }
      _isLoaded = true;
      if (!_initCompleter.isCompleted) {
        _initCompleter.complete();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LibraryRepository] Errore caricamento libreria da storage: $e');
      }
      _isLoaded = true;
      if (!_initCompleter.isCompleted) {
        _initCompleter.complete();
      }
    }
  }

  Future<void> _ensureLoaded() async {
    if (!_isLoaded) {
      await _initCompleter.future;
    }
  }

  void _scheduleAutosave() {
    _autosaveDebouncer.run(() async {
      await _persistToDisk();
    });
  }

  Future<void> _persistToDisk() async {
    try {
      final dtos = _entries.map((entry) => LibraryEntryDto.fromDomain(entry).toJson()).toList();
      await storage.writeData({
        'version': AppConstants.currentSchemaVersion,
        'updatedAt': DateTime.now().toIso8601String(),
        'entries': dtos,
      });
      if (kDebugMode) {
        debugPrint('[LibraryRepository] Autosave completato con successo (${_entries.length} manga)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LibraryRepository] Errore durante il salvataggio su disco: $e');
      }
    }
  }

  @override
  Future<List<LibraryEntry>> getLibrary() async {
    await _ensureLoaded();
    return List.unmodifiable(_entries);
  }

  @override
  Future<LibraryEntry?> getEntry(int mangaId) async {
    await _ensureLoaded();
    try {
      return _entries.firstWhere((e) => e.mangaId == mangaId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveEntry(LibraryEntry entry) async {
    await _ensureLoaded();
    final index = _entries.indexWhere((e) => e.mangaId == entry.mangaId);
    if (index >= 0) {
      _entries[index] = entry.copyWith(updatedAt: DateTime.now());
    } else {
      _entries.add(entry.copyWith(
        addedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }
    _scheduleAutosave();
  }

  @override
  Future<void> removeEntry(int mangaId) async {
    await _ensureLoaded();
    _entries.removeWhere((e) => e.mangaId == mangaId);
    _scheduleAutosave();
  }

  @override
  Future<void> updateProgress(int mangaId, int chapter) async {
    await _ensureLoaded();
    final index = _entries.indexWhere((e) => e.mangaId == mangaId);
    if (index >= 0) {
      final current = _entries[index];
      final safeChapter = chapter < 0 ? 0 : chapter;
      
      _entries[index] = current.copyWith(
        currentChapter: safeChapter,
        lastReadAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _scheduleAutosave();
    }
  }

  @override
  Future<void> updateVolumes(int mangaId, int ownedVolumes, {int? totalVolumes}) async {
    await _ensureLoaded();
    final index = _entries.indexWhere((e) => e.mangaId == mangaId);
    if (index >= 0) {
      final current = _entries[index];
      final safeOwned = ownedVolumes < 0 ? 0 : ownedVolumes;
      _entries[index] = current.copyWith(
        ownedVolumes: safeOwned,
        totalVolumes: totalVolumes ?? current.totalVolumes,
        updatedAt: DateTime.now(),
      );
      _scheduleAutosave();
    }
  }

  @override
  Future<void> updateStatus(int mangaId, ReadingStatus status) async {
    await _ensureLoaded();
    final index = _entries.indexWhere((e) => e.mangaId == mangaId);
    if (index >= 0) {
      final current = _entries[index];
      _entries[index] = current.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      _scheduleAutosave();
    }
  }

  @override
  Future<void> updateRating(int mangaId, int rating) async {
    await _ensureLoaded();
    final index = _entries.indexWhere((e) => e.mangaId == mangaId);
    if (index >= 0) {
      final current = _entries[index];
      _entries[index] = current.copyWith(
        rating: rating.clamp(0, 10),
        updatedAt: DateTime.now(),
      );
      _scheduleAutosave();
    }
  }

  @override
  Future<void> updateNotes(int mangaId, String notes) async {
    await _ensureLoaded();
    final index = _entries.indexWhere((e) => e.mangaId == mangaId);
    if (index >= 0) {
      final current = _entries[index];
      _entries[index] = current.copyWith(
        notes: notes,
        updatedAt: DateTime.now(),
      );
      _scheduleAutosave();
    }
  }

  @override
  Future<void> toggleFavorite(int mangaId) async {
    await _ensureLoaded();
    final index = _entries.indexWhere((e) => e.mangaId == mangaId);
    if (index >= 0) {
      final current = _entries[index];
      _entries[index] = current.copyWith(
        isFavorite: !_entries[index].isFavorite,
        updatedAt: DateTime.now(),
      );
      _scheduleAutosave();
    }
  }

  @override
  Future<void> clearAllData() async {
    await _ensureLoaded();
    _entries.clear();
    await storage.deleteStorage();
  }

  @override
  Future<int> getStorageSizeInBytes() async {
    return await storage.getFileSizeInBytes();
  }

  @override
  Future<String> exportLibraryJson() async {
    await _ensureLoaded();
    return await storage.exportJson();
  }

  @override
  Future<void> importLibraryJson(String jsonString) async {
    try {
      await storage.importJson(jsonString);
      await _loadFromStorage();
    } catch (e) {
      throw StorageFailure(e.toString());
    }
  }
}
