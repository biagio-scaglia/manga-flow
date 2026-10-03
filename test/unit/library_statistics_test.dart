import 'package:flutter_test/flutter_test.dart';
import 'package:manga_library/domain/entities/library_entry.dart';
import 'package:manga_library/domain/entities/library_statistics.dart';
import 'package:manga_library/domain/entities/reading_status.dart';

void main() {
  test('Calcolo corretto delle statistiche da voci reali della libreria', () {
    final entries = [
      LibraryEntry(
        mangaId: 1,
        title: 'Manga A',
        coverUrl: 'url',
        status: ReadingStatus.reading,
        currentChapter: 50,
        totalChapters: 100,
        rating: 8,
        isFavorite: true,
        genres: ['Action', 'Fantasy'],
        addedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      LibraryEntry(
        mangaId: 2,
        title: 'Manga B',
        coverUrl: 'url',
        status: ReadingStatus.completed,
        currentChapter: 30,
        totalChapters: 30,
        rating: 10,
        isFavorite: false,
        genres: ['Action', 'Sci-Fi'],
        addedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      LibraryEntry(
        mangaId: 3,
        title: 'Manga C',
        coverUrl: 'url',
        status: ReadingStatus.planToRead,
        currentChapter: 0,
        totalChapters: 20,
        rating: 0,
        isFavorite: false,
        genres: ['Romance'],
        addedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    final stats = LibraryStatistics.fromEntries(entries);

    expect(stats.totalManga, equals(3));
    expect(stats.readingCount, equals(1));
    expect(stats.completedCount, equals(1));
    expect(stats.planToReadCount, equals(1));
    expect(stats.favoriteCount, equals(1));
    expect(stats.totalChaptersRead, equals(80));
    expect(stats.averageRating, equals(9.0));
    expect(stats.ratedCount, equals(2));
    expect(stats.topGenres.first.key, equals('Action'));
    expect(stats.topGenres.first.value, equals(2));
  });

  test('Statistiche vuote per libreria senza elementi', () {
    final stats = LibraryStatistics.fromEntries([]);
    expect(stats.isEmpty, isTrue);
    expect(stats.totalManga, equals(0));
    expect(stats.totalChaptersRead, equals(0));
  });
}
