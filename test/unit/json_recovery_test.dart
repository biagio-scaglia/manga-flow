import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_library/data/storage/json_storage.dart';
import 'package:manga_library/data/storage/migrations/migration.dart';

void main() {
  late Directory tempDir;
  late JsonStorage storage;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('manga_recovery_test_');
    storage = JsonStorage(
      fileName: 'recovery_test.json',
      customDirectory: tempDir,
    );
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Data Recovery e Robustezza Storage (Punti 6, 7, 38)', () {
    test(
      'Recupero automatico da file di backup .bak in caso di corruzione del JSON principale',
      () async {
        // 1. Scrivi dati validi
        final validData = {
          'version': 1,
          'entries': [
            {
              'mangaId': 77,
              'title': 'Monster',
              'coverUrl': 'https://example.com/monster.jpg',
              'status': 'completed',
              'currentChapter': 162,
              'rating': 10,
            },
          ],
        };
        await storage.writeData(validData);

        // 2. Scrivi un secondo aggiornamento valido per generare il file .bak
        final updatedData = {
          'version': 1,
          'entries': [
            {
              'mangaId': 77,
              'title': 'Monster (Naoki Urasawa)',
              'coverUrl': 'https://example.com/monster.jpg',
              'status': 'completed',
              'currentChapter': 162,
              'rating': 10,
            },
          ],
        };
        await storage.writeData(updatedData);

        final mainFile = File('${tempDir.path}/recovery_test.json');
        final backupFile = File('${tempDir.path}/recovery_test.json.bak');

        expect(await mainFile.exists(), isTrue);
        expect(await backupFile.exists(), isTrue);

        // 3. Simula corruzione improvvisa del file principale (scrittura parziale / byte spazzatura)
        await mainFile.writeAsString(
          '{"version": 1, "entries": [{"mangaId": 77, "title": "Monste',
        );

        // 4. Leggi i dati: JsonStorage deve intercettare la corruzione e recuperare dal backup .bak
        final recovered = await storage.readData();

        expect(recovered['version'], equals(1));
        final entries = recovered['entries'] as List<dynamic>;
        expect(entries.length, equals(1));
        expect(entries.first['mangaId'], equals(77));
      },
    );

    test(
      'SchemaMigrationManager non effettua downgrade di versioni future',
      () {
        final migrationManager = SchemaMigrationManager();
        final futureData = {
          'version': 99,
          'custom_future_field': 'value',
          'entries': <dynamic>[],
        };

        final result = migrationManager.applyMigrations(futureData, 1);
        expect(
          result['version'],
          equals(99),
        ); // Versione futura preservata intatta
        expect(result['custom_future_field'], equals('value'));
      },
    );
  });
}
