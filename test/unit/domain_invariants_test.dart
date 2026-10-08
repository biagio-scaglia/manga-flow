import 'package:flutter_test/flutter_test.dart';
import 'package:manga_library/domain/entities/library_entry.dart';
import 'package:manga_library/domain/entities/reading_status.dart';

void main() {
  group('Regole di Business e Invarianti di Dominio (Punti 15, 16, 17)', () {
    test(
      'currentChapter non può essere negativo e rispetta il limite totalChapters',
      () {
        // Capitolo negativo corretto a 0
        final entryNeg = LibraryEntry.validated(
          mangaId: 10,
          title: 'Jujutsu Kaisen',
          coverUrl: '',
          status: ReadingStatus.reading,
          currentChapter: -5,
          totalChapters: 271,
        );
        expect(entryNeg.currentChapter, equals(0));

        // Capitolo superiore al totale limitato a totalChapters
        final entryExceeded = LibraryEntry.validated(
          mangaId: 10,
          title: 'Jujutsu Kaisen',
          coverUrl: '',
          status: ReadingStatus.reading,
          currentChapter: 300,
          totalChapters: 271,
        );
        expect(entryExceeded.currentChapter, equals(271));
      },
    );

    test('ownedVolumes non può essere negativo e non supera totalVolumes', () {
      final entry = LibraryEntry.validated(
        mangaId: 20,
        title: 'Spy x Family',
        coverUrl: '',
        status: ReadingStatus.reading,
        ownedVolumes: -2,
        totalVolumes: 14,
      );
      expect(entry.ownedVolumes, equals(0));
      expect(entry.volumesToBuy, equals(14));

      final entryMax = entry.copyWith(ownedVolumes: 20);
      expect(entryMax.ownedVolumes, equals(14));
      expect(entryMax.volumesToBuy, equals(0));
    });

    test('rating viene sempre ristretto nell\'intervallo 0..10', () {
      final entryNegRating = LibraryEntry.validated(
        mangaId: 30,
        title: 'Frieren',
        coverUrl: '',
        status: ReadingStatus.completed,
        rating: -3,
      );
      expect(entryNegRating.rating, equals(0));

      final entryHighRating = LibraryEntry.validated(
        mangaId: 30,
        title: 'Frieren',
        coverUrl: '',
        status: ReadingStatus.completed,
        rating: 15,
      );
      expect(entryHighRating.rating, equals(10));
    });

    test(
      'progressPercentage non produce mai NaN, Infinity o valori negativi',
      () {
        // TotalChapters null
        final entryNullTotal = LibraryEntry.validated(
          mangaId: 40,
          title: 'Ongoing Manga',
          coverUrl: '',
          status: ReadingStatus.reading,
          currentChapter: 15,
          totalChapters: null,
        );
        expect(entryNullTotal.progressPercentage, equals(0.0));
        expect(entryNullTotal.progressPercentage.isNaN, isFalse);
        expect(entryNullTotal.progressPercentage.isInfinite, isFalse);

        // TotalChapters 0
        final entryZeroTotal = LibraryEntry.validated(
          mangaId: 41,
          title: 'Zero Chapters Manga',
          coverUrl: '',
          status: ReadingStatus.reading,
          currentChapter: 0,
          totalChapters: 0,
        );
        expect(entryZeroTotal.progressPercentage, equals(0.0));

        // Progresso 50%
        final entryHalf = LibraryEntry.validated(
          mangaId: 42,
          title: 'Halfway Manga',
          coverUrl: '',
          status: ReadingStatus.reading,
          currentChapter: 50,
          totalChapters: 100,
        );
        expect(entryHalf.progressPercentage, equals(0.5));
      },
    );

    test('Titolo non può essere vuoto e genera fallback affidabile', () {
      final entryEmptyTitle = LibraryEntry.validated(
        mangaId: 999,
        title: '   ',
        coverUrl: '',
        status: ReadingStatus.planToRead,
      );
      expect(entryEmptyTitle.title, equals('Manga #999'));
    });
  });
}
