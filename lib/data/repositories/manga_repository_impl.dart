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

  MangaRepositoryImpl({required this.apiClient, required this.cacheManager});

  static const String _mangaFields = '''
    id
    title {
      romaji
      english
      native
    }
    description(asHtml: false)
    coverImage {
      extraLarge
      large
      medium
    }
    genres
    staff {
      nodes {
        name {
          full
        }
      }
    }
    status
    chapters
    volumes
    averageScore
    popularity
    startDate {
      year
      month
      day
    }
    format
''';

  @override
  Future<MangaSearchResult> searchManga({
    required String query,
    int page = 1,
    int limit = 20,
    String? type,
    String? status,
  }) async {
    try {
      const graphQLQuery =
          '''
        query (\$search: String, \$page: Int, \$perPage: Int) {
          Page(page: \$page, perPage: \$perPage) {
            pageInfo {
              hasNextPage
              currentPage
              lastPage
            }
            media(search: \$search, type: MANGA, sort: POPULARITY_DESC) {
              $_mangaFields
            }
          }
        }
      ''';

      final response = await apiClient.postGraphQL(
        query: graphQLQuery,
        variables: {'search': query, 'page': page, 'perPage': limit},
      );

      final data = response.data['data'] as Map<String, dynamic>?;
      final pageData = data?['Page'] as Map<String, dynamic>?;
      final pageInfo = pageData?['pageInfo'] as Map<String, dynamic>?;

      final itemsRaw = pageData?['media'] as List<dynamic>? ?? [];
      final List<Manga> mangas = itemsRaw
          .whereType<Map<String, dynamic>>()
          .map((json) => RemoteMangaDto.fromJson(json).toDomain())
          .toList();

      final bool hasNextPage = pageInfo?['hasNextPage'] as bool? ?? false;
      final int currentPage = pageInfo?['currentPage'] as int? ?? page;
      final int lastVisiblePage = pageInfo?['lastPage'] as int? ?? page;

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
      const graphQLQuery =
          '''
        query (\$page: Int, \$perPage: Int) {
          Page(page: \$page, perPage: \$perPage) {
            pageInfo {
              hasNextPage
              currentPage
              lastPage
            }
            media(type: MANGA, sort: POPULARITY_DESC) {
              $_mangaFields
            }
          }
        }
      ''';

      final response = await apiClient.postGraphQL(
        query: graphQLQuery,
        variables: {'page': page, 'perPage': limit},
      );

      final data = response.data['data'] as Map<String, dynamic>?;
      final pageData = data?['Page'] as Map<String, dynamic>?;
      final pageInfo = pageData?['pageInfo'] as Map<String, dynamic>?;

      final itemsRaw = pageData?['media'] as List<dynamic>? ?? [];
      final List<Manga> mangas = itemsRaw
          .whereType<Map<String, dynamic>>()
          .map((json) => RemoteMangaDto.fromJson(json).toDomain())
          .toList();

      final bool hasNextPage = pageInfo?['hasNextPage'] as bool? ?? false;
      final int currentPage = pageInfo?['currentPage'] as int? ?? page;
      final int lastVisiblePage = pageInfo?['lastPage'] as int? ?? page;

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
      const graphQLQuery =
          '''
        query (\$id: Int) {
          Media(id: \$id, type: MANGA) {
            $_mangaFields
          }
        }
      ''';

      final response = await apiClient.postGraphQL(
        query: graphQLQuery,
        variables: {'id': id},
      );

      final data = response.data['data'] as Map<String, dynamic>?;
      final mangaJson = data?['Media'] as Map<String, dynamic>?;

      if (mangaJson == null) {
        throw const ServerFailure(
          'Dettagli manga non disponibili.',
          statusCode: 404,
        );
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
