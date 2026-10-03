import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_library/data/repositories/library_repository_impl.dart';
import 'package:manga_library/data/storage/json_storage.dart';
import 'package:manga_library/domain/entities/library_entry.dart';
import 'package:manga_library/domain/entities/library_entry_merger.dart';
import 'package:manga_library/domain/entities/reading_status.dart';

void main() {
  late Directory tempDir;
  late JsonStorage storage;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('manga_dedup_test_');
    storage = JsonStorage(
      fileName: 'dedup_library.json',
      customDirectory: tempDir,
    );
  });

  tearDown(() async {
    try {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    } catch (_) {}
  });

  group('Deduplicazione e Integrità Dati (Punto 31 & 2)', () {
    test(
      'Scenario completo aggiunta, duplicati e riavvio repository',
      () async {
        final repository = LibraryRepositoryImpl(
          storage: storage,
          autosaveDebounce: Duration.zero,
        );

        // Given: manga ID 123 non presente
        final initial = await repository.getLibrary();
        expect(initial.any((m) => m.mangaId == 123), isFalse);

        // When: add manga 123
        final entry1 = LibraryEntry.validated(
          mangaId: 123,
          title: 'Chainsaw Man',
          coverUrl: 'https://example.com/csm.jpg',
          status: ReadingStatus.reading,
          currentChapter: 10,
          totalChapters: 150,
        );
        await repository.saveEntry(entry1);

        // Then: 1 entry
        var library = await repository.getLibrary();
        expect(library.length, equals(1));
        expect(library.first.mangaId, equals(123));
        expect(library.first.currentChapter, equals(10));

        // Repeat: add manga 123 di nuovo
        final entryDuplicate = LibraryEntry.validated(
          mangaId: 123,
          title: 'Chainsaw Man (Edizione Integrale)',
          coverUrl: 'https://example.com/csm.jpg',
          status: ReadingStatus.reading,
          currentChapter: 25,
          totalChapters: 150,
        );
        await repository.saveEntry(entryDuplicate);

        // Then: ancora esattamente 1 entry con capitolo aggiornato
        library = await repository.getLibrary();
        expect(library.length, equals(1));
        expect(library.first.mangaId, equals(123));
        expect(library.first.currentChapter, equals(25));

        // Repeat rapidly: add manga 123 concorrente 3 volte
        await Future.wait([
          repository.saveEntry(entry1.copyWith(currentChapter: 30)),
          repository.saveEntry(entry1.copyWith(currentChapter: 35)),
          repository.saveEntry(entry1.copyWith(currentChapter: 40)),
        ]);
        await repository.flush();

        // Then: ancora esattamente 1 entry
        library = await repository.getLibrary();
        expect(library.length, equals(1));
        expect(library.first.mangaId, equals(123));

        // Riavvia repository da disco
        final restartedRepository = LibraryRepositoryImpl(
          storage: storage,
          autosaveDebounce: Duration.zero,
        );

        // Then: ancora esattamente 1 entry persistita
        final reloadedLibrary = await restartedRepository.getLibrary();
        expect(reloadedLibrary.length, equals(1));
        expect(reloadedLibrary.first.mangaId, equals(123));

        // Carica JSON grezzo da storage per conferma fisica
        final rawData = await storage.readData();
        final rawEntries = rawData['entries'] as List<dynamic>;
        expect(rawEntries.length, equals(1));
        expect(rawEntries.first['mangaId'], equals(123));
      },
    );

    test(
      'LibraryEntryMerger esegue merge deterministico e preserva tutti i dati utente',
      () {
        final now = DateTime.now();
        final entryA = LibraryEntry.validated(
          mangaId: 456,
          title: 'Dandadan',
          coverUrl: 'https://example.com/dandadan.jpg',
          status: ReadingStatus.reading,
          currentChapter: 50,
          totalChapters: 120,
          ownedVolumes: 5,
          totalVolumes: 15,
          rating: 8,
          notes: 'Ottima serie',
          isFavorite: false,
          genres: ['Action', 'Comedy'],
          authors: ['Yukinobu Tatsu'],
          addedAt: now.subtract(const Duration(days: 10)),
          updatedAt: now.subtract(const Duration(days: 2)),
        );

        final entryB = LibraryEntry.validated(
          mangaId: 456,
          title: 'Dandadan (Serie Completa)',
          coverUrl: 'https://example.com/dandadan_hd.jpg',
          status: ReadingStatus.completed,
          currentChapter: 80,
          totalChapters: 120,
          ownedVolumes: 10,
          totalVolumes: 15,
          rating: 9,
          notes: 'Capolavoro moderno',
          isFavorite: true,
          genres: ['Supernatural', 'Sci-Fi'],
          authors: ['Yukinobu Tatsu'],
          addedAt: now.subtract(const Duration(days: 5)),
          updatedAt: now,
        );

        final merged = LibraryEntryMerger.merge(entryA, entryB);

        expect(merged.mangaId, equals(456));
        expect(merged.title, equals('Dandadan (Serie Completa)'));
        expect(merged.status, equals(ReadingStatus.completed));
        expect(merged.currentChapter, equals(80)); // Massimo
        expect(merged.ownedVolumes, equals(10)); // Massimo
        expect(merged.rating, equals(9)); // Massimo
        expect(merged.isFavorite, isTrue); // OR
        expect(merged.notes, contains('Ottima serie'));
        expect(merged.notes, contains('Capolavoro moderno'));
        expect(
          merged.genres,
          containsAll(['Action', 'Comedy', 'Supernatural', 'Sci-Fi']),
        );
        expect(merged.addedAt, equals(entryA.addedAt)); // Più antica
        expect(merged.updatedAt, equals(entryB.updatedAt)); // Più recente
      },
    );
  });
}
