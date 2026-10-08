import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  String get _webPrefKey => 'json_storage_$fileName';
  String get _webPrefBackupKey => 'json_storage_${fileName}_bak';

  Future<File> _getFile() async {
    final dir = customDirectory ?? await getApplicationDocumentsDirectory();
    return File('${dir.path}/$fileName');
  }

  Future<File> _getBackupFile() async {
    final dir = customDirectory ?? await getApplicationDocumentsDirectory();
    return File('${dir.path}/$fileName.bak');
  }

  Future<File> _getTempFile() async {
    final dir = customDirectory ?? await getApplicationDocumentsDirectory();
    return File('${dir.path}/$fileName.tmp');
  }

  Future<Map<String, dynamic>> readData() async {
    try {
      String content = '';

      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        content = prefs.getString(_webPrefKey) ?? '';
      } else {
        final file = await _getFile();
        if (await file.exists()) {
          content = await file.readAsString();
        }
      }

      if (content.trim().isEmpty) {
        if (kDebugMode) {
          debugPrint(
            '[JsonStorage] File $fileName vuoto o non presente. Restituzione schema iniziale.',
          );
        }
        return {
          'version': schemaVersion,
          'updatedAt': DateTime.now().toIso8601String(),
          'entries': <Map<String, dynamic>>[],
        };
      }

      try {
        final dynamic decoded = jsonDecode(content);
        Map<String, dynamic> rawMap;

        if (decoded is List) {
          rawMap = {'version': 0, 'entries': decoded};
        } else if (decoded is Map<String, dynamic>) {
          rawMap = decoded;
        } else {
          throw StorageException(
            'Contenuto JSON non valido nel file $fileName',
          );
        }

        final migrated = migrationManager.applyMigrations(
          rawMap,
          schemaVersion,
        );
        return migrated;
      } catch (parseError, parseStack) {
        // STRATEGIA DI RECOVERY DA BACKUP IN CASO DI FILE CORROTTO
        if (kDebugMode) {
          debugPrint(
            '[JsonStorage] Errore di parsing nel file principale: $parseError. Tentativo recovery da backup...',
          );
        }

        final recoveredData = await _attemptRecovery();
        if (recoveredData != null) {
          return recoveredData;
        }

        if (kDebugMode) {
          debugPrint(
            '[JsonStorage] Recovery non riuscita: $parseError\n$parseStack',
          );
        }
        throw StorageException(
          'Impossibile leggere il file di archiviazione corrotto: $parseError',
        );
      }
    } catch (e, stack) {
      if (e is StorageException) rethrow;
      if (kDebugMode) {
        debugPrint('[JsonStorage] Errore di lettura: $e\n$stack');
      }
      throw StorageException(
        'Impossibile leggere il file di archiviazione: $e',
      );
    }
  }

  Future<Map<String, dynamic>?> _attemptRecovery() async {
    try {
      String backupContent = '';
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        backupContent = prefs.getString(_webPrefBackupKey) ?? '';
      } else {
        final backupFile = await _getBackupFile();
        if (await backupFile.exists()) {
          backupContent = await backupFile.readAsString();
        }
      }

      if (backupContent.trim().isNotEmpty) {
        final dynamic decodedBackup = jsonDecode(backupContent);
        if (decodedBackup is Map<String, dynamic>) {
          if (kDebugMode) {
            debugPrint(
              '[JsonStorage] Dati recuperati con successo dal file di backup!',
            );
          }
          final migrated = migrationManager.applyMigrations(
            decodedBackup,
            schemaVersion,
          );
          // Ripristina il file principale
          await writeData(migrated);
          return migrated;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[JsonStorage] Fallimento durante il tentativo di ripristino da backup: $e',
        );
      }
    }
    return null;
  }

  Future<void> writeData(Map<String, dynamic> data) async {
    while (_writeLock != null) {
      await _writeLock!.future;
    }

    _writeLock = Completer<void>();

    try {
      final payload = Map<String, dynamic>.from(data);
      payload['version'] = schemaVersion;
      payload['updatedAt'] = DateTime.now().toIso8601String();

      final jsonString = const JsonEncoder.withIndent('  ').convert(payload);

      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        // Salva backup dello stato precedente se presente
        final current = prefs.getString(_webPrefKey);
        if (current != null && current.isNotEmpty) {
          await prefs.setString(_webPrefBackupKey, current);
        }
        await prefs.setString(_webPrefKey, jsonString);
        if (kDebugMode) {
          debugPrint(
            '[JsonStorage] Salvataggio web localStorage completato con successo',
          );
        }
      } else {
        final file = await _getFile();
        final backupFile = await _getBackupFile();
        final tempFile = await _getTempFile();

        // 1. Scrittura su file temporaneo
        await tempFile.writeAsString(jsonString, flush: true);

        // 2. Verifica del file temporaneo
        if (!await tempFile.exists()) {
          throw StorageException('Scrittura del file temporaneo fallita');
        }
        final verifiedContent = await tempFile.readAsString();
        if (verifiedContent.length < jsonString.length * 0.9) {
          throw StorageException('File temporaneo incompleto o corrotto');
        }

        // 3. Creazione/Aggiornamento file di backup del file valido esistente
        if (await file.exists()) {
          try {
            await file.copy(backupFile.path);
          } catch (_) {}
          await file.delete();
        }

        // 4. Sostituzione atomica con il file temporaneo validato
        await tempFile.rename(file.path);

        if (kDebugMode) {
          debugPrint(
            '[JsonStorage] Salvataggio atomico completato con successo in ${file.path}',
          );
        }
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('[JsonStorage] Errore di scrittura atomica: $e\n$stack');
      }
      throw StorageException(
        'Impossibile salvare i dati su disco in modo sicuro: $e',
      );
    } finally {
      final lock = _writeLock;
      _writeLock = null;
      lock?.complete();
    }
  }

  Future<int> getFileSizeInBytes() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(_webPrefKey)?.length ?? 0;
      }
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
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_webPrefKey);
        return;
      }
      final file = await _getFile();
      if (await file.exists()) {
        await file.delete();
      }
      final tempFile = await _getTempFile();
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    } catch (e) {
      throw StorageException(
        'Errore durante la cancellazione dello storage: $e',
      );
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
