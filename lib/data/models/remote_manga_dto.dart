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
    // 1. Controllo formato Kitsu (JSON:API standard)
    if (json.containsKey('attributes') && json['attributes'] is Map<String, dynamic>) {
      final attrs = json['attributes'] as Map<String, dynamic>;
      final id = int.tryParse(json['id']?.toString() ?? '0') ?? 0;

      final titles = attrs['titles'] as Map<String, dynamic>?;
      final canonicalTitle = attrs['canonicalTitle']?.toString() ??
          titles?['en']?.toString() ??
          titles?['en_jp']?.toString() ??
          'Senza titolo';

      final posterImage = attrs['posterImage'] as Map<String, dynamic>?;
      final imgUrl = posterImage?['medium']?.toString() ??
          posterImage?['small']?.toString() ??
          posterImage?['original']?.toString() ??
          '';
      final largeImgUrl = posterImage?['large']?.toString() ??
          posterImage?['original']?.toString() ??
          imgUrl;

      // Punteggio medio Kitsu (in scala 0-100 convertito a 0-10)
      double? parsedScore;
      if (attrs['averageRating'] != null) {
        final rawScore = double.tryParse(attrs['averageRating'].toString());
        if (rawScore != null) {
          parsedScore = double.parse((rawScore / 10.0).toStringAsFixed(2));
        }
      }

      // Autore o serializzazione
      final List<String> authorsList = [];
      if (attrs['serialization'] != null && attrs['serialization'].toString().isNotEmpty) {
        authorsList.add(attrs['serialization'].toString());
      }

      // Stato di pubblicazione
      String rawStatus = attrs['status']?.toString() ?? 'Unknown';
      if (rawStatus == 'current') rawStatus = 'Publishing';
      if (rawStatus == 'finished') rawStatus = 'Finished';
      if (rawStatus == 'unreleased') rawStatus = 'Not yet published';

      return RemoteMangaDto(
        malId: id,
        title: canonicalTitle,
        titleJapanese: titles?['ja_jp']?.toString(),
        titleEnglish: titles?['en']?.toString(),
        synopsis: attrs['synopsis']?.toString() ?? attrs['description']?.toString(),
        imageUrl: imgUrl,
        largeImageUrl: largeImgUrl,
        authors: authorsList,
        genres: const [],
        status: rawStatus,
        chapters: attrs['chapterCount'] as int?,
        volumes: attrs['volumeCount'] as int?,
        score: parsedScore,
        scoredBy: attrs['userCount'] as int?,
        rank: attrs['ratingRank'] as int?,
        popularity: attrs['popularityRank'] as int?,
        publishedFrom: attrs['startDate'] != null ? DateTime.tryParse(attrs['startDate'].toString()) : null,
        publishedTo: attrs['endDate'] != null ? DateTime.tryParse(attrs['endDate'].toString()) : null,
        type: attrs['subtype']?.toString() ?? attrs['mangaType']?.toString() ?? 'Manga',
      );
    }

    // 2. Controllo formato Jikan / MyAnimeList v4 standard
    String imgUrl = '';
    String? largeImgUrl;

    if (json['images'] != null && json['images'] is Map<String, dynamic>) {
      final images = json['images'] as Map<String, dynamic>;
      final jpg = images['jpg'] as Map<String, dynamic>?;
      final webp = images['webp'] as Map<String, dynamic>?;

      imgUrl = jpg?['image_url'] ?? webp?['image_url'] ?? '';
      largeImgUrl = jpg?['large_image_url'] ?? webp?['large_image_url'] ?? imgUrl;
    }

    // Gestione autori
    final List<String> authorsList = [];
    if (json['authors'] != null && json['authors'] is List) {
      for (final author in json['authors']) {
        if (author is Map<String, dynamic> && author['name'] != null) {
          authorsList.add(author['name'].toString());
        }
      }
    }

    // Gestione generi, temi e demografiche
    final List<String> genresList = [];
    void extractNames(dynamic list) {
      if (list != null && list is List) {
        for (final item in list) {
          if (item is Map<String, dynamic> && item['name'] != null) {
            final name = item['name'].toString();
            if (!genresList.contains(name)) {
              genresList.add(name);
            }
          }
        }
      }
    }

    extractNames(json['genres']);
    extractNames(json['themes']);
    extractNames(json['demographics']);

    // Date di pubblicazione
    DateTime? fromDate;
    DateTime? toDate;
    if (json['published'] != null && json['published'] is Map<String, dynamic>) {
      final published = json['published'] as Map<String, dynamic>;
      if (published['from'] != null) {
        fromDate = DateTime.tryParse(published['from'].toString());
      }
      if (published['to'] != null) {
        toDate = DateTime.tryParse(published['to'].toString());
      }
    }

    // Punteggio sicuro
    double? parsedScore;
    if (json['score'] != null) {
      parsedScore = double.tryParse(json['score'].toString());
    }

    return RemoteMangaDto(
      malId: json['mal_id'] as int? ?? json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Senza titolo',
      titleJapanese: json['title_japanese'] as String?,
      titleEnglish: json['title_english'] as String?,
      synopsis: json['synopsis'] as String?,
      imageUrl: imgUrl,
      largeImageUrl: largeImgUrl,
      authors: authorsList,
      genres: genresList,
      status: json['status'] as String? ?? 'Unknown',
      chapters: json['chapters'] as int?,
      volumes: json['volumes'] as int?,
      score: parsedScore,
      scoredBy: json['scored_by'] as int?,
      rank: json['rank'] as int?,
      popularity: json['popularity'] as int?,
      publishedFrom: fromDate,
      publishedTo: toDate,
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
