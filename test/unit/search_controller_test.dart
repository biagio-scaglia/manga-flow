import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_library/domain/entities/manga.dart';
import 'package:manga_library/domain/repositories/manga_repository.dart';
import 'package:manga_library/presentation/controllers/search_controller.dart';

class FakeMangaRepository implements MangaRepository {
  Completer<MangaSearchResult>? pendingSearchCompleter;
  String? lastSearchQuery;

  @override
  Future<MangaSearchResult> searchManga({
    required String query,
    int page = 1,
    int limit = 20,
    String? type,
    String? status,
  }) async {
    lastSearchQuery = query;
    if (pendingSearchCompleter != null) {
      return await pendingSearchCompleter!.future;
    }
    return MangaSearchResult(
      items: [
        Manga(
          id: query.hashCode.abs(),
          title: 'Result for $query',
          coverUrl: '',
          authors: ['Author'],
          genres: ['Genre'],
          status: 'Publishing',
        ),
      ],
      hasNextPage: false,
      currentPage: 1,
      lastVisiblePage: 1,
    );
  }

  @override
  Future<MangaSearchResult> getTopManga({
    int page = 1,
    int limit = 20,
    String? filter,
  }) async {
    return const MangaSearchResult(
      items: [],
      hasNextPage: false,
      currentPage: 1,
      lastVisiblePage: 1,
    );
  }

  @override
  Future<Manga> getMangaDetails(int id) async {
    return Manga(
      id: id,
      title: 'Manga $id',
      coverUrl: '',
      authors: [],
      genres: [],
      status: 'Publishing',
    );
  }

  @override
  Future<void> clearCache() async {}

  @override
  Future<int> getCacheSizeInBytes() async => 0;
}

void main() {
  group('Search Controller e Stale Response Prevention (Punti 11, 12)', () {
    test(
      'Risposta stale di una query precedente viene scartata e non sovrascrive la ricerca più recente',
      () async {
        final fakeRepo = FakeMangaRepository();
        final controller = MangaSearchController(repository: fakeRepo);

        // Simula ricerca 1 ("naruto") che resta in sospeso
        final completer1 = Completer<MangaSearchResult>();
        fakeRepo.pendingSearchCompleter = completer1;

        controller.onQueryChanged('naruto');
        // Attendi il debounce di 500ms
        await Future.delayed(const Duration(milliseconds: 550));
        expect(fakeRepo.lastSearchQuery, equals('naruto'));

        // Nel frattempo l'utente cambia query in "one piece"
        final completer2 = Completer<MangaSearchResult>();
        fakeRepo.pendingSearchCompleter = completer2;

        controller.onQueryChanged('one piece');
        await Future.delayed(const Duration(milliseconds: 550));
        expect(fakeRepo.lastSearchQuery, equals('one piece'));

        // La richiesta 2 ("one piece") risponde PRIMA
        completer2.complete(
          const MangaSearchResult(
            items: [
              Manga(
                id: 1,
                title: 'One Piece',
                coverUrl: '',
                authors: [],
                genres: [],
                status: 'Publishing',
              ),
            ],
            hasNextPage: false,
            currentPage: 1,
            lastVisiblePage: 1,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 50));

        expect(controller.searchResults.length, equals(1));
        expect(controller.searchResults.first.title, equals('One Piece'));

        // Successivamente risponde la vecchia richiesta 1 ("naruto")
        completer1.complete(
          const MangaSearchResult(
            items: [
              Manga(
                id: 2,
                title: 'Naruto',
                coverUrl: '',
                authors: [],
                genres: [],
                status: 'Publishing',
              ),
            ],
            hasNextPage: false,
            currentPage: 1,
            lastVisiblePage: 1,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 50));

        // VERIFICA: I risultati devono rimanere "One Piece", la risposta stale di "Naruto" è stata scartata!
        expect(controller.searchResults.length, equals(1));
        expect(controller.searchResults.first.title, equals('One Piece'));

        controller.dispose();
      },
    );

    test('clearSearch invalida immediatamente le ricerche in volo', () async {
      final fakeRepo = FakeMangaRepository();
      final controller = MangaSearchController(repository: fakeRepo);

      final completer = Completer<MangaSearchResult>();
      fakeRepo.pendingSearchCompleter = completer;

      controller.onQueryChanged('bleach');
      await Future.delayed(const Duration(milliseconds: 550));

      controller.clearSearch();
      expect(controller.searchResults, isEmpty);
      expect(controller.currentQuery, isEmpty);

      // La richiesta in volo risponde dopo la cancellazione
      completer.complete(
        const MangaSearchResult(
          items: [
            Manga(
              id: 3,
              title: 'Bleach',
              coverUrl: '',
              authors: [],
              genres: [],
              status: 'Publishing',
            ),
          ],
          hasNextPage: false,
          currentPage: 1,
          lastVisiblePage: 1,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 50));

      // Risultati devono rimanere vuoti
      expect(controller.searchResults, isEmpty);

      controller.dispose();
    });
  });
}
