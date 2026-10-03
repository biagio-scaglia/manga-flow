import 'package:flutter_test/flutter_test.dart';
import 'package:manga_library/data/models/library_entry_dto.dart';
import 'package:manga_library/data/models/remote_manga_dto.dart';
import 'package:manga_library/domain/entities/reading_status.dart';

void main() {
  test('RemoteMangaDto parse da JSON reale Jikan', () {
    final jikanJson = {
      'mal_id': 13,
      'title': 'One Piece',
      'title_japanese': 'ONE PIECE',
      'images': {
        'jpg': {
          'image_url': 'https://example.com/onepiece.jpg',
          'large_image_url': 'https://example.com/onepiece_large.jpg',
        }
      },
      'status': 'Publishing',
      'chapters': 1100,
      'score': 9.22,
      'authors': [
        {'mal_id': 1881, 'name': 'Oda, Eiichiro'}
      ],
      'genres': [
        {'mal_id': 1, 'name': 'Action'},
        {'mal_id': 2, 'name': 'Adventure'}
      ]
    };

    final dto = RemoteMangaDto.fromJson(jikanJson);
    final domain = dto.toDomain();

    expect(domain.id, equals(13));
    expect(domain.title, equals('One Piece'));
    expect(domain.publicationStatusItalian, equals('In corso'));
    expect(domain.authors.first, equals('Oda, Eiichiro'));
    expect(domain.genres, contains('Action'));
    expect(domain.genres, contains('Adventure'));
    expect(domain.score, equals(9.22));
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
