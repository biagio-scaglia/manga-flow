import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:manga_library/domain/entities/library_entry.dart';
import 'package:manga_library/domain/entities/reading_status.dart';
import 'package:manga_library/domain/repositories/library_repository.dart';
import 'package:manga_library/domain/repositories/manga_repository.dart';
import 'package:manga_library/presentation/controllers/library_controller.dart';
import 'package:manga_library/presentation/controllers/settings_controller.dart';

class MockLibraryRepository implements LibraryRepository {
  final List<LibraryEntry> _list = [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<LibraryEntry>> getLibrary() async => List.unmodifiable(_list);

  @override
  Future<LibraryEntry?> getEntry(int mangaId) async {
    final idx = _list.indexWhere((e) => e.mangaId == mangaId);
    return idx >= 0 ? _list[idx] : null;
  }

  @override
  Future<void> saveEntry(LibraryEntry entry) async {
    final idx = _list.indexWhere((e) => e.mangaId == entry.mangaId);
    if (idx >= 0) {
      _list[idx] = entry;
    } else {
      _list.add(entry);
    }
  }

  @override
  Future<void> removeEntry(int mangaId) async {
    _list.removeWhere((e) => e.mangaId == mangaId);
  }

  @override
  Future<void> updateProgress(int mangaId, int chapter) async {
    final idx = _list.indexWhere((e) => e.mangaId == mangaId);
    if (idx >= 0) {
      _list[idx] = _list[idx].copyWith(currentChapter: chapter);
    }
  }

  @override
  Future<void> updateVolumes(
    int mangaId,
    int ownedVolumes, {
    int? totalVolumes,
  }) async {
    final idx = _list.indexWhere((e) => e.mangaId == mangaId);
    if (idx >= 0) {
      _list[idx] = _list[idx].copyWith(
        ownedVolumes: ownedVolumes,
        totalVolumes: totalVolumes ?? _list[idx].totalVolumes,
      );
    }
  }

  @override
  Future<void> updateStatus(int mangaId, ReadingStatus status) async {
    final idx = _list.indexWhere((e) => e.mangaId == mangaId);
    if (idx >= 0) {
      _list[idx] = _list[idx].copyWith(status: status);
    }
  }

  @override
  Future<void> updateRating(int mangaId, int rating) async {
    final idx = _list.indexWhere((e) => e.mangaId == mangaId);
    if (idx >= 0) {
      _list[idx] = _list[idx].copyWith(rating: rating);
    }
  }

  @override
  Future<void> updateNotes(int mangaId, String notes) async {
    final idx = _list.indexWhere((e) => e.mangaId == mangaId);
    if (idx >= 0) {
      _list[idx] = _list[idx].copyWith(notes: notes);
    }
  }

  @override
  Future<void> toggleFavorite(int mangaId) async {
    final idx = _list.indexWhere((e) => e.mangaId == mangaId);
    if (idx >= 0) {
      _list[idx] = _list[idx].copyWith(isFavorite: !_list[idx].isFavorite);
    }
  }

  @override
  Future<void> clearAllData() async {
    _list.clear();
  }

  @override
  Future<int> getStorageSizeInBytes() async => 1024;

  @override
  Future<void> flush() async {}
}

class MockMangaRepository implements MangaRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<int> getCacheSizeInBytes() async => 2048;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CRUD, Limite Volumi e Tutorial State', () {
    test(
      'SettingsController inizializza tutorialCompleted da SharedPreferences in modo sincrono',
      () async {
        SharedPreferences.setMockInitialValues({'tutorial_completed': true});
        final prefs = await SharedPreferences.getInstance();

        final settingsCtrl = SettingsController(
          libraryRepository: MockLibraryRepository(),
          mangaRepository: MockMangaRepository(),
          preferences: prefs,
        );

        expect(settingsCtrl.tutorialCompleted, isTrue);
      },
    );

    test(
      'Non permette di superare il totale dei volumi (es. 25 su 24 totali)',
      () async {
        final repo = MockLibraryRepository();
        final controller = LibraryController(repository: repo);
        await controller.loadLibrary();

        final entry = LibraryEntry.validated(
          mangaId: 100,
          title: 'Serie Finita',
          coverUrl: 'https://example.com/cover.jpg',
          status: ReadingStatus.reading,
          currentChapter: 1,
          totalChapters: 100,
          ownedVolumes: 24,
          totalVolumes: 24,
        );

        await controller.addOrUpdateEntry(entry);
        expect(controller.getEntry(100)?.ownedVolumes, 24);

        // Tentativo di incrementare oltre il massimo
        await controller.incrementOwnedVolume(100);
        expect(controller.getEntry(100)?.ownedVolumes, 24);

        // Tentativo di forzare 25 tramite updateVolumes
        await controller.updateVolumes(100, 25);
        expect(controller.getEntry(100)?.ownedVolumes, 24);
      },
    );

    test(
      'Toggle Favorite e aggiornamento CRUD (stato, rating, note, rimozione)',
      () async {
        final repo = MockLibraryRepository();
        final controller = LibraryController(repository: repo);
        await controller.loadLibrary();

        final entry = LibraryEntry.validated(
          mangaId: 200,
          title: 'Manga Test',
          coverUrl: 'https://example.com/cover.jpg',
          status: ReadingStatus.reading,
          isFavorite: false,
        );

        await controller.addOrUpdateEntry(entry);
        expect(controller.getEntry(200)?.isFavorite, isFalse);

        // Toggle preferito
        await controller.toggleFavorite(200);
        expect(controller.getEntry(200)?.isFavorite, isTrue);

        // Aggiorna stato
        await controller.updateStatus(200, ReadingStatus.completed);
        expect(controller.getEntry(200)?.status, ReadingStatus.completed);

        // Aggiorna rating
        await controller.updateRating(200, 9);
        expect(controller.getEntry(200)?.rating, 9);

        // Aggiorna note
        await controller.updateNotes(200, 'Capolavoro assoluto');
        expect(controller.getEntry(200)?.notes, 'Capolavoro assoluto');

        // Rimozione dalla libreria
        await controller.removeEntry(200);
        expect(controller.getEntry(200), isNull);
      },
    );
  });
}
