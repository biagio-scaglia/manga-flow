import 'package:flutter/foundation.dart';

abstract class Migration {
  final int fromVersion;
  final int toVersion;

  const Migration({required this.fromVersion, required this.toVersion});

  Map<String, dynamic> migrate(Map<String, dynamic> data);
}

class MigrationV0ToV1 extends Migration {
  const MigrationV0ToV1() : super(fromVersion: 0, toVersion: 1);

  @override
  Map<String, dynamic> migrate(Map<String, dynamic> data) {
    if (kDebugMode) {
      debugPrint('[Migration] Esecuzione migrazione schema da v0 a v1');
    }

    final entriesRaw = data['entries'] as List<dynamic>? ?? [];
    final List<Map<String, dynamic>> migratedEntries = [];

    for (final item in entriesRaw) {
      if (item is Map<String, dynamic>) {
        final Map<String, dynamic> entry = Map<String, dynamic>.from(item);

        // Normalizzazione campi
        if (!entry.containsKey('mangaId') && entry.containsKey('id')) {
          entry['mangaId'] = entry['id'];
        }
        if (!entry.containsKey('currentChapter')) {
          entry['currentChapter'] = 0;
        }
        if (!entry.containsKey('rating')) {
          entry['rating'] = 0;
        }
        if (!entry.containsKey('notes')) {
          entry['notes'] = '';
        }
        if (!entry.containsKey('isFavorite')) {
          entry['isFavorite'] = entry['favorite'] ?? false;
        }
        if (!entry.containsKey('genres')) {
          entry['genres'] = entry['tags'] ?? <String>[];
        }
        if (!entry.containsKey('authors')) {
          entry['authors'] = <String>[];
        }
        if (!entry.containsKey('addedAt')) {
          entry['addedAt'] = DateTime.now().toIso8601String();
        }
        if (!entry.containsKey('updatedAt')) {
          entry['updatedAt'] = DateTime.now().toIso8601String();
        }
        migratedEntries.add(entry);
      }
    }

    return {
      'version': 1,
      'updatedAt': DateTime.now().toIso8601String(),
      'entries': migratedEntries,
    };
  }
}

class SchemaMigrationManager {
  final List<Migration> _migrations = [const MigrationV0ToV1()];

  Map<String, dynamic> applyMigrations(
    Map<String, dynamic> rawData,
    int targetVersion,
  ) {
    int currentVersion = rawData['version'] as int? ?? 0;

    // Se la versione è già pari o superiore al target, non eseguire migrazioni o downgrade
    if (currentVersion >= targetVersion) {
      return rawData;
    }

    Map<String, dynamic> migratedData = Map<String, dynamic>.from(rawData);

    while (currentVersion < targetVersion) {
      final migration = _migrations.firstWhere(
        (m) => m.fromVersion == currentVersion,
        orElse: () => throw Exception(
          'Nessuna migrazione disponibile dalla versione $currentVersion',
        ),
      );

      migratedData = migration.migrate(migratedData);
      currentVersion = migration.toVersion;
    }

    migratedData['version'] = targetVersion;
    migratedData['updatedAt'] = DateTime.now().toIso8601String();
    return migratedData;
  }
}
