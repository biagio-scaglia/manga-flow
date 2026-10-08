import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_library/data/storage/json_storage.dart';
import 'package:manga_library/data/storage/migrations/migration.dart';

void main() {
  late Directory tempDir;
  late JsonStorage storage;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('manga_test_');
    storage = JsonStorage(
      fileName: 'test_library.json',
      customDirectory: tempDir,
    );
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('Salvataggio e lettura atomica corretta dei dati JSON', () async {
    final testData = {
      'version': 1,
      'entries': [
        {
          'mangaId': 13,
          'title': 'One Piece',
          'coverUrl': 'https://example.com/op.jpg',
          'status': 'reading',
          'currentChapter': 1050,
          'totalChapters': 0,
          'rating': 10,
          'notes': 'Ottimo',
          'isFavorite': true,
          'genres': ['Action', 'Adventure'],
          'authors': ['Eiichiro Oda'],
          'addedAt': '2026-01-01T00:00:00.000',
          'updatedAt': '2026-01-02T00:00:00.000',
        },
      ],
    };

    await storage.writeData(testData);
    final read = await storage.readData();

    expect(read['version'], equals(1));
    final entries = read['entries'] as List<dynamic>;
    expect(entries.length, equals(1));
    expect(entries.first['title'], equals('One Piece'));
    expect(entries.first['currentChapter'], equals(1050));
  });

  test(
    'Migrazione automatica schema da versione 0 grezza a versione 1',
    () async {
      final migrationManager = SchemaMigrationManager();
      final v0Raw = {
        'version': 0,
        'entries': [
          {'id': 42, 'title': 'Berserk', 'status': 'reading'},
        ],
      };

      final migrated = migrationManager.applyMigrations(v0Raw, 1);
      expect(migrated['version'], equals(1));
      final entries = migrated['entries'] as List<dynamic>;
      expect(entries.first['mangaId'], equals(42));
      expect(entries.first['currentChapter'], equals(0));
      expect(entries.first['isFavorite'], isFalse);
      expect(entries.first['rating'], equals(0));
    },
  );
}
