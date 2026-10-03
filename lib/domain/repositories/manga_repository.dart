import '../entities/manga.dart';

class MangaSearchResult {
  final List<Manga> items;
  final bool hasNextPage;
  final int currentPage;
  final int lastVisiblePage;
  final bool isFromCache;
  final bool isStale;

  const MangaSearchResult({
    required this.items,
    required this.hasNextPage,
    required this.currentPage,
    required this.lastVisiblePage,
    this.isFromCache = false,
    this.isStale = false,
  });
}

abstract class MangaRepository {
  Future<MangaSearchResult> searchManga({
    required String query,
    int page = 1,
    int limit = 20,
    String? type,
    String? status,
  });

  Future<MangaSearchResult> getTopManga({
    int page = 1,
    int limit = 20,
    String? filter,
  });

  Future<Manga> getMangaDetails(int id);

  Future<void> clearCache();

  Future<int> getCacheSizeInBytes();
}
