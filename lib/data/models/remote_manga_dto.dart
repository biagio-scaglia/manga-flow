import '../../domain/entities/manga.dart';

class RemoteMangaDto {
  final int malId;
  final String title;
  final String? titleJapanese;
  final String? titleEnglish;
  final String? synopsis;
  final String imageUrl;
  final String? largeImageUrl;
  final List<String> authors;
  final List<String> genres;
  final String status;
  final int? chapters;
  final int? volumes;
  final double? score;
  final int? scoredBy;
  final int? rank;
  final int? popularity;
  final DateTime? publishedFrom;
  final DateTime? publishedTo;
  final String type;

  const RemoteMangaDto({
    required this.malId,
    required this.title,
    this.titleJapanese,
    this.titleEnglish,
    this.synopsis,
    required this.imageUrl,
    this.largeImageUrl,
    this.authors = const [],
    this.genres = const [],
    this.status = 'Unknown',
    this.chapters,
    this.volumes,
    this.score,
    this.scoredBy,
    this.rank,
    this.popularity,
    this.publishedFrom,
    this.publishedTo,
    this.type = 'Manga',
  });

  factory RemoteMangaDto.fromJson(Map<String, dynamic> json) {
    // 1. Controllo formato AniList GraphQL
    if (json.containsKey('title') && json['title'] is Map<String, dynamic>) {
      final id = json['id'] as int? ?? 0;
      final titles = json['title'] as Map<String, dynamic>;
      final canonicalTitle = titles['romaji']?.toString() ??
          titles['english']?.toString() ??
          titles['native']?.toString() ??
          'Senza titolo';

      final coverImages = json['coverImage'] as Map<String, dynamic>?;
      final imgUrl = coverImages?['medium']?.toString() ??
          coverImages?['large']?.toString() ??
          '';
      final largeImgUrl = coverImages?['extraLarge']?.toString() ??
          coverImages?['large']?.toString() ??
          imgUrl;

      // Generi
      final List<String> genresList = [];
      if (json['genres'] != null && json['genres'] is List) {
        for (final g in json['genres']) {
          if (g != null) genresList.add(g.toString());
        }
      }

      // Autori dallo staff
      final List<String> authorsList = [];
      if (json['staff'] != null && json['staff'] is Map<String, dynamic>) {
        final nodes = json['staff']['nodes'] as List<dynamic>?;
        if (nodes != null) {
          for (final node in nodes) {
            if (node is Map<String, dynamic> && node['name'] != null) {
              final nameMap = node['name'] as Map<String, dynamic>;
              final fullName = nameMap['full']?.toString();
              if (fullName != null && fullName.isNotEmpty && !authorsList.contains(fullName)) {
                authorsList.add(fullName);
              }
            }
          }
        }
      }

      // Stato normalizzato
      final rawStatus = json['status']?.toString() ?? 'RELEASING';
      String status = 'Publishing';
      if (rawStatus == 'FINISHED') status = 'Finished';
      if (rawStatus == 'NOT_YET_RELEASED') status = 'Not yet published';
      if (rawStatus == 'HIATUS') status = 'On Hiatus';
      if (rawStatus == 'CANCELLED') status = 'Discontinued';

      // Score (0-100 a 0-10)
      double? parsedScore;
      if (json['averageScore'] != null) {
        final raw = double.tryParse(json['averageScore'].toString());
        if (raw != null) {
          parsedScore = double.parse((raw / 10.0).toStringAsFixed(1));
        }
      }

      // Pulizia descrizione da tag HTML
      String? cleanDesc = json['description']?.toString();
      if (cleanDesc != null) {
        cleanDesc = cleanDesc.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ').replaceAll('  ', ' ').trim();
      }

      // Date di inizio
      DateTime? fromDate;
      if (json['startDate'] != null && json['startDate'] is Map<String, dynamic>) {
        final start = json['startDate'] as Map<String, dynamic>;
        final y = start['year'] as int?;
        final m = start['month'] as int? ?? 1;
        final d = start['day'] as int? ?? 1;
        if (y != null) {
          fromDate = DateTime(y, m, d);
        }
      }

      return RemoteMangaDto(
        malId: id,
        title: canonicalTitle,
        titleJapanese: titles['native']?.toString(),
        titleEnglish: titles['english']?.toString(),
        synopsis: cleanDesc,
        imageUrl: imgUrl,
        largeImageUrl: largeImgUrl,
        authors: authorsList,
        genres: genresList,
        status: status,
        chapters: json['chapters'] as int?,
        volumes: json['volumes'] as int?,
        score: parsedScore,
        popularity: json['popularity'] as int?,
        publishedFrom: fromDate,
        type: json['format']?.toString() ?? 'Manga',
      );
    }

    // 2. Fallback per formati alternativi (Jikan / DTO interno)
    String imgUrl = '';
    String? largeImgUrl;

    if (json['images'] != null && json['images'] is Map<String, dynamic>) {
      final images = json['images'] as Map<String, dynamic>;
      final jpg = images['jpg'] as Map<String, dynamic>?;
      imgUrl = jpg?['image_url'] ?? '';
      largeImgUrl = jpg?['large_image_url'] ?? imgUrl;
    } else {
      imgUrl = json['image_url']?.toString() ?? '';
      largeImgUrl = json['large_image_url']?.toString() ?? imgUrl;
    }

    return RemoteMangaDto(
      malId: json['mal_id'] as int? ?? json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Senza titolo',
      titleJapanese: json['title_japanese'] as String?,
      titleEnglish: json['title_english'] as String?,
      synopsis: json['synopsis'] as String?,
      imageUrl: imgUrl,
      largeImageUrl: largeImgUrl,
      authors: (json['authors'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      genres: (json['genres'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      status: json['status'] as String? ?? 'Publishing',
      chapters: json['chapters'] as int?,
      volumes: json['volumes'] as int?,
      score: double.tryParse(json['score']?.toString() ?? ''),
      popularity: json['popularity'] as int?,
      type: json['type'] as String? ?? 'Manga',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mal_id': malId,
      'title': title,
      'title_japanese': titleJapanese,
      'title_english': titleEnglish,
      'synopsis': synopsis,
      'image_url': imageUrl,
      'large_image_url': largeImageUrl,
      'authors': authors,
      'genres': genres,
      'status': status,
      'chapters': chapters,
      'volumes': volumes,
      'score': score,
      'scored_by': scoredBy,
      'rank': rank,
      'popularity': popularity,
      'published_from': publishedFrom?.toIso8601String(),
      'published_to': publishedTo?.toIso8601String(),
      'type': type,
    };
  }

  Manga toDomain() {
    return Manga(
      id: malId,
      title: title,
      titleJapanese: titleJapanese,
      titleEnglish: titleEnglish,
      synopsis: synopsis,
      coverUrl: imageUrl,
      largeCoverUrl: largeImageUrl,
      authors: authors,
      genres: genres,
      status: status,
      totalChapters: chapters,
      totalVolumes: volumes,
      score: score,
      scoredBy: scoredBy,
      rank: rank,
      popularity: popularity,
      publishedFrom: publishedFrom,
      publishedTo: publishedTo,
      type: type,
    );
  }
}
