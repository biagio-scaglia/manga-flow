import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import 'migrations/migration.dart';

class JsonStorage {
  final String fileName;
  final int schemaVersion;
  final SchemaMigrationManager migrationManager;
  final Directory? customDirectory;

  Completer<void>? _writeLock;

  JsonStorage({
    this.fileName = AppConstants.libraryFileName,
    this.schemaVersion = AppConstants.currentSchemaVersion,
    SchemaMigrationManager? migrationManager,
    this.customDirectory,
  }) : migrationManager = migrationManager ?? SchemaMigrationManager();

  Future<File> _getFile() async {
    final dir = customDirectory ?? await getApplicationDocumentsDirectory();
    return File('${dir.path}/$fileName');
  }

  Future<File> _getTempFile() async {
    final dir = customDirectory ?? await getApplicationDocumentsDirectory();
    return File('${dir.path}/$fileName.tmp');
  }

  Future<Map<String, dynamic>> readData() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) {
        if (kDebugMode) {
          debugPrint('[JsonStorage] File $fileName non trovato. Restituzione schema iniziale vuoto.');
        }
        return {
          'version': schemaVersion,
          'updatedAt': DateTime.now().toIso8601String(),
          'entries': <Map<String, dynamic>>[],
        };
      }

      final content = await file.readAsString();
      if (content.trim().isEmpty) {
        return {
          'version': schemaVersion,
          'updatedAt': DateTime.now().toIso8601String(),
          'entries': <Map<String, dynamic>>[],
        };
      }

      final dynamic decoded = jsonDecode(content);
      Map<String, dynamic> rawMap;

      if (decoded is List) {
        // Schema v0 grezzo (lista diretta di elementi)
        rawMap = {
          'version': 0,
          'entries': decoded,
        };
      } else if (decoded is Map<String, dynamic>) {
        rawMap = decoded;
      } else {
        throw StorageException('Contenuto JSON non valido nel file $fileName');
      }

      final migrated = migrationManager.applyMigrations(rawMap, schemaVersion);
      return migrated;
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('[JsonStorage] Errore di lettura: $e\n$stack');
      }
      throw StorageException('Impossibile leggere il file di archiviazione: $e');
    }
  }

  Future<void> writeData(Map<String, dynamic> data) async {
    // Attendi l'eventuale lock di scrittura precedente
    while (_writeLock != null) {
      await _writeLock!.future;
    }

    _writeLock = Completer<void>();

    try {
      final file = await _getFile();
      final tempFile = await _getTempFile();

      // Assicurati che i metadati di versione e timestamp siano presenti
      final payload = Map<String, dynamic>.from(data);
      payload['version'] = schemaVersion;
      payload['updatedAt'] = DateTime.now().toIso8601String();

      // 1. Serializzazione in memoria
      final jsonString = const JsonEncoder.withIndent('  ').convert(payload);

      // 2. Scrittura su file temporaneo
      await tempFile.writeAsString(jsonString, flush: true);

      // 3. Verifica del file temporaneo
      if (!await tempFile.exists()) {
        throw StorageException('Scrittura del file temporaneo fallita');
      }
      final verifiedContent = await tempFile.readAsString();
      if (verifiedContent.length < jsonString.length * 0.9) {
        throw StorageException('File temporaneo incompleto o corrotto');
      }

      // 4. Sostituzione atomica
      if (await file.exists()) {
        await file.delete();
      }
      await tempFile.rename(file.path);

      if (kDebugMode) {
        debugPrint('[JsonStorage] Salvataggio atomico completato con successo in ${file.path}');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('[JsonStorage] Errore di scrittura atomica: $e\n$stack');
      }
      throw StorageException('Impossibile salvare i dati su disco in modo sicuro: $e');
    } finally {
      final lock = _writeLock;
      _writeLock = null;
      lock?.complete();
    }
  }

  Future<int> getFileSizeInBytes() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> deleteStorage() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        await file.delete();
      }
      final tempFile = await _getTempFile();
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    } catch (e) {
      throw StorageException('Errore durante la cancellazione dello storage: $e');
    }
  }

  Future<String> exportJson() async {
    final data = await readData();
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Future<void> importJson(String jsonString) async {
    try {
      final dynamic decoded = jsonDecode(jsonString);
      Map<String, dynamic> rawMap;
      if (decoded is List) {
        rawMap = {'version': 0, 'entries': decoded};
      } else if (decoded is Map<String, dynamic>) {
        rawMap = decoded;
      } else {
        throw StorageException('File di importazione non valido.');
      }

      final migrated = migrationManager.applyMigrations(rawMap, schemaVersion);
      await writeData(migrated);
    } catch (e) {
      throw StorageException('Importazione fallita: formato non valido.');
    }
  }
}
