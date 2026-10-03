import 'reading_status.dart';

class LibraryEntry {
  final int mangaId;
  final String title;
  final String coverUrl;
  final ReadingStatus status;
  final int currentChapter;
  final int? totalChapters;
  final int ownedVolumes;
  final int? totalVolumes;
  final int rating; // 0 = non valutato, 1-10
  final String notes;
  final bool isFavorite;
  final List<String> genres;
  final List<String> authors;
  final DateTime addedAt;
  final DateTime updatedAt;
  final DateTime? lastReadAt;

  const LibraryEntry({
    required this.mangaId,
    required this.title,
    required this.coverUrl,
    required this.status,
    this.currentChapter = 0,
    this.totalChapters,
    this.ownedVolumes = 0,
    this.totalVolumes,
    this.rating = 0,
    this.notes = '',
    this.isFavorite = false,
    this.genres = const [],
    this.authors = const [],
    required this.addedAt,
    required this.updatedAt,
    this.lastReadAt,
  });

  double get progressPercentage {
    if (totalChapters == null || totalChapters! <= 0) return 0.0;
    return (currentChapter / totalChapters!).clamp(0.0, 1.0);
  }

  int get volumesToBuy {
    if (totalVolumes == null || totalVolumes! <= 0) return 0;
    final diff = totalVolumes! - ownedVolumes;
    return diff > 0 ? diff : 0;
  }

  bool get isCompleted =>
      status == ReadingStatus.completed ||
      (totalChapters != null && totalChapters! > 0 && currentChapter >= totalChapters!);

  LibraryEntry copyWith({
    int? mangaId,
    String? title,
    String? coverUrl,
    ReadingStatus? status,
    int? currentChapter,
    int? totalChapters,
    int? ownedVolumes,
    int? totalVolumes,
    int? rating,
    String? notes,
    bool? isFavorite,
    List<String>? genres,
    List<String>? authors,
    DateTime? addedAt,
    DateTime? updatedAt,
    DateTime? lastReadAt,
  }) {
    return LibraryEntry(
      mangaId: mangaId ?? this.mangaId,
      title: title ?? this.title,
      coverUrl: coverUrl ?? this.coverUrl,
      status: status ?? this.status,
      currentChapter: currentChapter ?? this.currentChapter,
      totalChapters: totalChapters ?? this.totalChapters,
      ownedVolumes: ownedVolumes ?? this.ownedVolumes,
      totalVolumes: totalVolumes ?? this.totalVolumes,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
      genres: genres ?? this.genres,
      authors: authors ?? this.authors,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastReadAt: lastReadAt ?? this.lastReadAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibraryEntry &&
          runtimeType == other.runtimeType &&
          mangaId == other.mangaId &&
          status == other.status &&
          currentChapter == other.currentChapter &&
          ownedVolumes == other.ownedVolumes &&
          rating == other.rating &&
          notes == other.notes &&
          isFavorite == other.isFavorite &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => mangaId.hashCode;
}
