import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/manga.dart';
import '../../domain/repositories/manga_repository.dart';
import '../api/jikan_api_client.dart';
import '../cache/http_cache_manager.dart';
import '../models/remote_manga_dto.dart';

class MangaRepositoryImpl implements MangaRepository {
  final JikanApiClient apiClient;
  final HttpCacheManager cacheManager;

  MangaRepositoryImpl({
    required this.apiClient,
    required this.cacheManager,
  });

  @override
  Future<MangaSearchResult> searchManga({
    required String query,
    int page = 1,
    int limit = 20,
    String? type,
    String? status,
  }) async {
    try {
      final offset = (page - 1) * limit;
      final queryParams = <String, String>{
        'filter[text]': query,
        'page[limit]': limit.toString(),
        'page[offset]': offset.toString(),
      };

      if (type != null && type.isNotEmpty) {
        queryParams['filter[subtype]'] = type.toLowerCase();
      }
      if (status != null && status.isNotEmpty) {
        queryParams['filter[status]'] = status.toLowerCase();
      }

      final response = await apiClient.get('/manga', queryParams: queryParams);
      final data = response.data;

      final itemsRaw = data['data'] as List<dynamic>? ?? [];
      final List<Manga> mangas = itemsRaw
          .whereType<Map<String, dynamic>>()
          .map((json) => RemoteMangaDto.fromJson(json).toDomain())
          .toList();

      final meta = data['meta'] as Map<String, dynamic>?;
      final totalCount = meta?['count'] as int? ?? mangas.length;
      final bool hasNextPage = (offset + mangas.length) < totalCount;
      final int lastVisiblePage = (totalCount / limit).ceil();

      return MangaSearchResult(
        items: mangas,
        hasNextPage: hasNextPage,
        currentPage: page,
        lastVisiblePage: lastVisiblePage,
        isFromCache: response.isFromCache,
        isStale: response.isStale,
      );
    } on RateLimitException catch (e) {
      throw RateLimitFailure(e.message, e.retryAfterSeconds);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw ServerFailure('Errore durante la ricerca dei manga: $e');
    }
  }

  @override
  Future<MangaSearchResult> getTopManga({
    int page = 1,
    int limit = 20,
    String? filter,
  }) async {
    try {
      final offset = (page - 1) * limit;
      final queryParams = <String, String>{
        'page[limit]': limit.toString(),
        'page[offset]': offset.toString(),
        'sort': 'popularityRank',
      };

      final response = await apiClient.get('/manga', queryParams: queryParams);
      final data = response.data;

      final itemsRaw = data['data'] as List<dynamic>? ?? [];
      final List<Manga> mangas = itemsRaw
          .whereType<Map<String, dynamic>>()
          .map((json) => RemoteMangaDto.fromJson(json).toDomain())
          .toList();

      final meta = data['meta'] as Map<String, dynamic>?;
      final totalCount = meta?['count'] as int? ?? mangas.length;
      final bool hasNextPage = (offset + mangas.length) < totalCount;
      final int lastVisiblePage = (totalCount / limit).ceil();

      return MangaSearchResult(
        items: mangas,
        hasNextPage: hasNextPage,
        currentPage: page,
        lastVisiblePage: lastVisiblePage,
        isFromCache: response.isFromCache,
        isStale: response.isStale,
      );
    } on RateLimitException catch (e) {
      throw RateLimitFailure(e.message, e.retryAfterSeconds);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw ServerFailure('Errore nel recupero dei manga in evidenza: $e');
    }
  }

  @override
  Future<Manga> getMangaDetails(int id) async {
    try {
      final response = await apiClient.get('/manga/$id');
      final data = response.data;
      final mangaJson = data['data'] as Map<String, dynamic>?;

      if (mangaJson == null) {
        throw const ServerFailure('Dettagli manga non disponibili.', statusCode: 404);
      }

      return RemoteMangaDto.fromJson(mangaJson).toDomain();
    } on RateLimitException catch (e) {
      throw RateLimitFailure(e.message, e.retryAfterSeconds);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Errore nel recupero dei dettagli: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    await cacheManager.clear();
  }

  @override
  Future<int> getCacheSizeInBytes() async {
    return await cacheManager.getSizeBytes();
  }
}
