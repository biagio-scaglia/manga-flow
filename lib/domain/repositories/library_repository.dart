import '../entities/library_entry.dart';
import '../entities/reading_status.dart';

abstract class LibraryRepository {
  Future<List<LibraryEntry>> getLibrary();
  Future<LibraryEntry?> getEntry(int mangaId);
  Future<void> saveEntry(LibraryEntry entry);
  Future<void> removeEntry(int mangaId);
  Future<void> updateProgress(int mangaId, int chapter);
  Future<void> updateVolumes(int mangaId, int ownedVolumes, {int? totalVolumes});
  Future<void> updateStatus(int mangaId, ReadingStatus status);
  Future<void> updateRating(int mangaId, int rating);
  Future<void> updateNotes(int mangaId, String notes);
  Future<void> toggleFavorite(int mangaId);
  Future<void> clearAllData();
  Future<int> getStorageSizeInBytes();
  Future<String> exportLibraryJson();
  Future<void> importLibraryJson(String jsonString);
}
