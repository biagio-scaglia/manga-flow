import 'package:flutter_test/flutter_test.dart';
import 'package:manga_library/data/models/library_entry_dto.dart';
import 'package:manga_library/data/models/remote_manga_dto.dart';
import 'package:manga_library/domain/entities/reading_status.dart';

void main() {
  test('RemoteMangaDto parse da AniList GraphQL', () {
    final aniListJson = {
      'id': 30002,
      'title': {
        'romaji': 'Berserk',
        'english': 'Berserk',
        'native': 'ベルセルク',
      },
      'description': 'Guts, a former mercenary...',
      'coverImage': {
        'large': 'https://example.com/berserk_large.jpg',
        'extraLarge': 'https://example.com/berserk_extra.jpg',
      },
      'genres': ['Action', 'Adventure', 'Drama', 'Fantasy'],
      'staff': {
        'nodes': [
          {
            'name': {'full': 'Kentarou Miura'}
          }
        ]
      },
      'status': 'RELEASING',
      'chapters': 375,
      'volumes': 41,
      'averageScore': 92,
      'popularity': 180000,
    };

    final dto = RemoteMangaDto.fromJson(aniListJson);
    final domain = dto.toDomain();

    expect(domain.id, equals(30002));
    expect(domain.title, equals('Berserk'));
    expect(domain.publicationStatusItalian, equals('In corso'));
    expect(domain.score, equals(9.2));
    expect(domain.totalChapters, equals(375));
    expect(domain.totalVolumes, equals(41));
    expect(domain.authors.first, equals('Kentarou Miura'));
    expect(domain.genres, contains('Action'));
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
