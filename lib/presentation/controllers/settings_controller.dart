import 'package:flutter/material.dart';
import 'package:manga_library/domain/repositories/library_repository.dart';
import 'package:manga_library/domain/repositories/manga_repository.dart';

class SettingsController extends ChangeNotifier {
  final LibraryRepository _libraryRepository;
  final MangaRepository _mangaRepository;

  ThemeMode _themeMode = ThemeMode.dark;
  bool _reduceAnimations = false;
  bool _tutorialCompleted = false;
  int _cacheSizeBytes = 0;
  int _storageSizeBytes = 0;

  SettingsController({
    required LibraryRepository libraryRepository,
    required MangaRepository mangaRepository,
  })  : _libraryRepository = libraryRepository,
        _mangaRepository = mangaRepository {
    refreshSizes();
  }

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get reduceAnimations => _reduceAnimations;
  bool get tutorialCompleted => _tutorialCompleted;
  int get cacheSizeBytes => _cacheSizeBytes;
  int get storageSizeBytes => _storageSizeBytes;

  String get cacheSizeFormatted => _formatBytes(_cacheSizeBytes);
  String get storageSizeFormatted => _formatBytes(_storageSizeBytes);

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void toggleReduceAnimations(bool value) {
    _reduceAnimations = value;
    notifyListeners();
  }

  void setTutorialCompleted(bool completed) {
    _tutorialCompleted = completed;
    notifyListeners();
  }

  void resetTutorial() {
    _tutorialCompleted = false;
    notifyListeners();
  }

  Future<void> refreshSizes() async {
    try {
      _cacheSizeBytes = await _mangaRepository.getCacheSizeInBytes();
      _storageSizeBytes = await _libraryRepository.getStorageSizeInBytes();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> clearCache() async {
    await _mangaRepository.clearCache();
    await refreshSizes();
  }

  Future<void> clearAllData() async {
    await _libraryRepository.clearAllData();
    await refreshSizes();
  }

  Future<String> exportLibrary() async {
    return await _libraryRepository.exportLibraryJson();
  }

  Future<void> importLibrary(String jsonString) async {
    await _libraryRepository.importLibraryJson(jsonString);
    await refreshSizes();
  }
}
