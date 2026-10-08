import 'dart:math';
import 'package:flutter/foundation.dart';
import 'library_entry.dart';
import 'reading_status.dart';

/// Gestore deterministico per la deduplicazione e la fusione sicura delle voci della libreria
class LibraryEntryMerger {
  const LibraryEntryMerger._();

  /// Scansiona la lista di voci, rileva duplicati per [mangaId] ed esegue un merge sicuro e conservativo
  static List<LibraryEntry> deduplicateAndMerge(List<LibraryEntry> entries) {
    if (entries.isEmpty) return const [];

    final Map<int, LibraryEntry> map = {};
    bool duplicatesFound = false;

    for (final entry in entries) {
      if (entry.mangaId <= 0) continue; // Scarta ID non validi

      if (!map.containsKey(entry.mangaId)) {
        map[entry.mangaId] = entry;
      } else {
        duplicatesFound = true;
        final existing = map[entry.mangaId]!;
        final merged = merge(existing, entry);
        map[entry.mangaId] = merged;
        if (kDebugMode) {
          debugPrint(
            '[LibraryEntryMerger] Duplicato rilevato e fuso per manga #${entry.mangaId} ("${entry.title}")',
          );
        }
      }
    }

    if (duplicatesFound && kDebugMode) {
      debugPrint(
        '[LibraryEntryMerger] Deduplicazione completata: ${entries.length} -> ${map.length} voci',
      );
    }

    return map.values.toList();
  }

  /// Esegue la fusione deterministica di due entry con lo stesso [mangaId]
  /// preservando il massimo livello di progresso e informazioni registrate dall'utente
  static LibraryEntry merge(LibraryEntry a, LibraryEntry b) {
    assert(
      a.mangaId == b.mangaId,
      'I manga da fondere devono avere lo stesso ID',
    );

    // 1. Titolo migliore (più completo/lungo non vuoto)
    final title = b.title.trim().length > a.title.trim().length
        ? b.title.trim()
        : a.title.trim();

    // 2. Copertina migliore non vuota
    final coverUrl = b.coverUrl.trim().isNotEmpty
        ? b.coverUrl.trim()
        : a.coverUrl.trim();

    // 3. Stato di lettura: se uno dei due è completed ha priorità, altrimenti reading, altrimenti il più recente
    ReadingStatus status;
    if (a.status == ReadingStatus.completed ||
        b.status == ReadingStatus.completed) {
      status = ReadingStatus.completed;
    } else if (a.status == ReadingStatus.reading ||
        b.status == ReadingStatus.reading) {
      status = ReadingStatus.reading;
    } else {
      status = a.updatedAt.isAfter(b.updatedAt) ? a.status : b.status;
    }

    // 4. Progresso capitoli: conserva il progresso massimo raggiunto
    final currentChapter = max(a.currentChapter, b.currentChapter);
    final totalChapters = b.totalChapters ?? a.totalChapters;

    // 5. Volumi posseduti: conserva il massimo
    final ownedVolumes = max(a.ownedVolumes, b.ownedVolumes);
    final totalVolumes = b.totalVolumes ?? a.totalVolumes;

    // 6. Rating: conserva il voto più alto assegnato
    final rating = max(a.rating, b.rating);

    // 7. Note: se diverse e non vuote, unisci le note
    String notes;
    final noteA = a.notes.trim();
    final noteB = b.notes.trim();
    if (noteA.isEmpty) {
      notes = noteB;
    } else if (noteB.isEmpty || noteA == noteB) {
      notes = noteA;
    } else if (noteA.contains(noteB)) {
      notes = noteA;
    } else if (noteB.contains(noteA)) {
      notes = noteB;
    } else {
      notes = '$noteA\n$noteB';
    }

    // 8. Preferiti: true se almeno uno è preferito
    final isFavorite = a.isFavorite || b.isFavorite;

    // 9. Generi e Autori: unione univoca
    final Set<String> genresSet = {...a.genres, ...b.genres};
    final Set<String> authorsSet = {...a.authors, ...b.authors};

    // 10. Date: data di aggiunta più antica, data di aggiornamento più recente
    final addedAt = a.addedAt.isBefore(b.addedAt) ? a.addedAt : b.addedAt;
    final updatedAt = a.updatedAt.isAfter(b.updatedAt)
        ? a.updatedAt
        : b.updatedAt;

    // 11. Ultima lettura: data più recente non null
    DateTime? lastReadAt;
    if (a.lastReadAt != null && b.lastReadAt != null) {
      lastReadAt = a.lastReadAt!.isAfter(b.lastReadAt!)
          ? a.lastReadAt
          : b.lastReadAt;
    } else {
      lastReadAt = a.lastReadAt ?? b.lastReadAt;
    }

    return LibraryEntry.validated(
      mangaId: a.mangaId,
      title: title,
      coverUrl: coverUrl,
      status: status,
      currentChapter: currentChapter,
      totalChapters: totalChapters,
      ownedVolumes: ownedVolumes,
      totalVolumes: totalVolumes,
      rating: rating,
      notes: notes,
      isFavorite: isFavorite,
      genres: genresSet.toList(),
      authors: authorsSet.toList(),
      addedAt: addedAt,
      updatedAt: updatedAt,
      lastReadAt: lastReadAt,
    );
  }
}
