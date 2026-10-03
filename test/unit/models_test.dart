import 'package:flutter_test/flutter_test.dart';
import 'package:manga_library/data/models/library_entry_dto.dart';
import 'package:manga_library/data/models/remote_manga_dto.dart';
import 'package:manga_library/domain/entities/reading_status.dart';

void main() {
  test('RemoteMangaDto parse da JSON reale Kitsu', () {
    final kitsuJson = {
      'id': '13737',
      'type': 'manga',
      'attributes': {
        'canonicalTitle': 'Berserk',
        'titles': {
          'en': 'Berserk',
          'ja_jp': 'ベルセルク',
        },
        'synopsis': 'Guts, a former mercenary...',
        'posterImage': {
          'medium': 'https://example.com/berserk_medium.jpg',
          'large': 'https://example.com/berserk_large.jpg',
        },
        'status': 'current',
        'chapterCount': 375,
        'averageRating': '88.74',
        'serialization': 'Young Animal',
      }
    };

    final dto = RemoteMangaDto.fromJson(kitsuJson);
    final domain = dto.toDomain();

    expect(domain.id, equals(13737));
    expect(domain.title, equals('Berserk'));
    expect(domain.publicationStatusItalian, equals('In corso'));
    expect(domain.score, equals(8.87));
    expect(domain.totalChapters, equals(375));
    expect(domain.authors.first, equals('Young Animal'));
  });

  test('LibraryEntryDto serializzazione e deserializzazione corretta', () {
    final originalJson = {
      'mangaId': 99,
      'title': 'Fullmetal Alchemist',
      'coverUrl': 'https://example.com/fma.jpg',
      'status': 'completed',
      'currentChapter': 108,
      'totalChapters': 108,
      'rating': 10,
      'notes': 'Capolavoro',
      'isFavorite': true,
      'genres': ['Action', 'Adventure', 'Drama'],
      'authors': ['Hiromu Arakawa'],
      'addedAt': '2026-03-01T10:00:00.000',
      'updatedAt': '2026-03-02T10:00:00.000',
      'lastReadAt': '2026-03-02T10:00:00.000',
    };

    final dto = LibraryEntryDto.fromJson(originalJson);
    final domain = dto.toDomain();

    expect(domain.mangaId, equals(99));
    expect(domain.status, equals(ReadingStatus.completed));
    expect(domain.isCompleted, isTrue);

    final backToDto = LibraryEntryDto.fromDomain(domain);
    final exportedJson = backToDto.toJson();

    expect(exportedJson['mangaId'], equals(99));
    expect(exportedJson['status'], equals('completed'));
    expect(exportedJson['isFavorite'], isTrue);
  });
}
