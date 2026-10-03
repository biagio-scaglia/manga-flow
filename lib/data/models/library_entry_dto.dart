import '../../domain/entities/library_entry.dart';
import '../../domain/entities/reading_status.dart';

class LibraryEntryDto {
  final int mangaId;
  final String title;
  final String coverUrl;
  final String status;
  final int currentChapter;
  final int? totalChapters;
  final int ownedVolumes;
  final int? totalVolumes;
  final int rating;
  final String notes;
  final bool isFavorite;
  final List<String> genres;
  final List<String> authors;
  final String addedAt;
  final String updatedAt;
  final String? lastReadAt;

  const LibraryEntryDto({
    required this.mangaId,
    required this.title,
    required this.coverUrl,
    required this.status,
    required this.currentChapter,
    this.totalChapters,
    this.ownedVolumes = 0,
    this.totalVolumes,
    required this.rating,
    required this.notes,
    required this.isFavorite,
    required this.genres,
    required this.authors,
    required this.addedAt,
    required this.updatedAt,
    this.lastReadAt,
  });

  factory LibraryEntryDto.fromJson(Map<String, dynamic> json) {
    return LibraryEntryDto(
      mangaId: json['mangaId'] as int? ?? json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Senza titolo',
      coverUrl: json['coverUrl'] as String? ?? '',
      status: json['status'] as String? ?? 'plan_to_read',
      currentChapter: json['currentChapter'] as int? ?? 0,
      totalChapters: json['totalChapters'] as int?,
      ownedVolumes: json['ownedVolumes'] as int? ?? 0,
      totalVolumes: json['totalVolumes'] as int?,
      rating: json['rating'] as int? ?? 0,
      notes: json['notes'] as String? ?? '',
      isFavorite: json['isFavorite'] as bool? ?? json['favorite'] as bool? ?? false,
      genres: (json['genres'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      authors: (json['authors'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      addedAt: json['addedAt'] as String? ?? DateTime.now().toIso8601String(),
      updatedAt: json['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
      lastReadAt: json['lastReadAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mangaId': mangaId,
      'title': title,
      'coverUrl': coverUrl,
      'status': status,
      'currentChapter': currentChapter,
      'totalChapters': totalChapters,
      'ownedVolumes': ownedVolumes,
      'totalVolumes': totalVolumes,
      'rating': rating,
      'notes': notes,
      'isFavorite': isFavorite,
      'genres': genres,
      'authors': authors,
      'addedAt': addedAt,
      'updatedAt': updatedAt,
      'lastReadAt': lastReadAt,
    };
  }

  factory LibraryEntryDto.fromDomain(LibraryEntry entry) {
    return LibraryEntryDto(
      mangaId: entry.mangaId,
      title: entry.title,
      coverUrl: entry.coverUrl,
      status: entry.status.toStorageKey(),
      currentChapter: entry.currentChapter,
      totalChapters: entry.totalChapters,
      ownedVolumes: entry.ownedVolumes,
      totalVolumes: entry.totalVolumes,
      rating: entry.rating,
      notes: entry.notes,
      isFavorite: entry.isFavorite,
      genres: entry.genres,
      authors: entry.authors,
      addedAt: entry.addedAt.toIso8601String(),
      updatedAt: entry.updatedAt.toIso8601String(),
      lastReadAt: entry.lastReadAt?.toIso8601String(),
    );
  }

  LibraryEntry toDomain() {
    return LibraryEntry(
      mangaId: mangaId,
      title: title,
      coverUrl: coverUrl,
      status: ReadingStatus.fromStorageKey(status),
      currentChapter: currentChapter,
      totalChapters: totalChapters,
      ownedVolumes: ownedVolumes,
      totalVolumes: totalVolumes,
      rating: rating,
      notes: notes,
      isFavorite: isFavorite,
      genres: genres,
      authors: authors,
      addedAt: DateTime.tryParse(addedAt) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(updatedAt) ?? DateTime.now(),
      lastReadAt: lastReadAt != null ? DateTime.tryParse(lastReadAt!) : null,
    );
  }
}
