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
      final queryParams = <String, String>{
        'q': query,
        'page': page.toString(),
        'limit': limit.toString(),
        'order_by': 'popularity',
        'sort': 'asc',
        'sfw': 'true',
      };

      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await apiClient.get('/manga', queryParams: queryParams);
      final data = response.data;

      final pagination = data['pagination'] as Map<String, dynamic>?;
      final bool hasNextPage = pagination?['has_next_page'] as bool? ?? false;
      final int currentPage = pagination?['current_page'] as int? ?? page;
      final int lastVisiblePage = pagination?['last_visible_page'] as int? ?? page;

      final itemsRaw = data['data'] as List<dynamic>? ?? [];
      final List<Manga> mangas = itemsRaw
          .whereType<Map<String, dynamic>>()
          .map((json) => RemoteMangaDto.fromJson(json).toDomain())
          .toList();

      return MangaSearchResult(
        items: mangas,
        hasNextPage: hasNextPage,
        currentPage: currentPage,
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
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        'sfw': 'true',
      };

      if (filter != null && filter.isNotEmpty) {
        queryParams['filter'] = filter;
      }

      final response = await apiClient.get('/top/manga', queryParams: queryParams);
      final data = response.data;

      final pagination = data['pagination'] as Map<String, dynamic>?;
      final bool hasNextPage = pagination?['has_next_page'] as bool? ?? false;
      final int currentPage = pagination?['current_page'] as int? ?? page;
      final int lastVisiblePage = pagination?['last_visible_page'] as int? ?? page;

      final itemsRaw = data['data'] as List<dynamic>? ?? [];
      final List<Manga> mangas = itemsRaw
          .whereType<Map<String, dynamic>>()
          .map((json) => RemoteMangaDto.fromJson(json).toDomain())
          .toList();

      return MangaSearchResult(
        items: mangas,
        hasNextPage: hasNextPage,
        currentPage: currentPage,
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
      final response = await apiClient.get('/manga/$id/full');
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
