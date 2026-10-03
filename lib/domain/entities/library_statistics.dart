import 'library_entry.dart';
import 'reading_status.dart';

class LibraryStatistics {
  final int totalManga;
  final int readingCount;
  final int completedCount;
  final int planToReadCount;
  final int onHoldCount;
  final int droppedCount;
  final int favoriteCount;
  final int totalChaptersRead;
  final double averageRating;
  final int ratedCount;
  final Map<String, int> genreDistribution;
  final List<MapEntry<String, int>> topGenres;

  const LibraryStatistics({
    required this.totalManga,
    required this.readingCount,
    required this.completedCount,
    required this.planToReadCount,
    required this.onHoldCount,
    required this.droppedCount,
    required this.favoriteCount,
    required this.totalChaptersRead,
    required this.averageRating,
    required this.ratedCount,
    required this.genreDistribution,
    required this.topGenres,
  });

  bool get isEmpty => totalManga == 0;

  factory LibraryStatistics.fromEntries(List<LibraryEntry> entries) {
    if (entries.isEmpty) {
      return const LibraryStatistics(
        totalManga: 0,
        readingCount: 0,
        completedCount: 0,
        planToReadCount: 0,
        onHoldCount: 0,
        droppedCount: 0,
        favoriteCount: 0,
        totalChaptersRead: 0,
        averageRating: 0.0,
        ratedCount: 0,
        genreDistribution: {},
        topGenres: [],
      );
    }

    int reading = 0;
    int completed = 0;
    int planToRead = 0;
    int onHold = 0;
    int dropped = 0;
    int favorites = 0;
    int chaptersRead = 0;
    int totalRatingSum = 0;
    int rated = 0;
    final Map<String, int> genres = {};

    for (final entry in entries) {
      switch (entry.status) {
        case ReadingStatus.reading:
          reading++;
          break;
        case ReadingStatus.completed:
          completed++;
          break;
        case ReadingStatus.planToRead:
          planToRead++;
          break;
        case ReadingStatus.onHold:
          onHold++;
          break;
        case ReadingStatus.dropped:
          dropped++;
          break;
      }

      if (entry.isFavorite) {
        favorites++;
      }

      chaptersRead += entry.currentChapter;

      if (entry.rating > 0) {
        totalRatingSum += entry.rating;
        rated++;
      }

      for (final genre in entry.genres) {
        final cleanGenre = genre.trim();
        if (cleanGenre.isNotEmpty) {
          genres[cleanGenre] = (genres[cleanGenre] ?? 0) + 1;
        }
      }
    }

    final avgRating = rated > 0 ? (totalRatingSum / rated) : 0.0;
    final sortedGenres = genres.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return LibraryStatistics(
      totalManga: entries.length,
      readingCount: reading,
      completedCount: completed,
      planToReadCount: planToRead,
      onHoldCount: onHold,
      droppedCount: dropped,
      favoriteCount: favorites,
      totalChaptersRead: chaptersRead,
      averageRating: double.parse(avgRating.toStringAsFixed(1)),
      ratedCount: rated,
      genreDistribution: genres,
      topGenres: sortedGenres.take(6).toList(),
    );
  }
}
