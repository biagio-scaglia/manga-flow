class Manga {
  final int id;
  final String title;
  final String? titleJapanese;
  final String? titleEnglish;
  final String? synopsis;
  final String coverUrl;
  final String? largeCoverUrl;
  final List<String> authors;
  final List<String> genres;
  final String status;
  final int? totalChapters;
  final int? totalVolumes;
  final double? score;
  final int? scoredBy;
  final int? rank;
  final int? popularity;
  final DateTime? publishedFrom;
  final DateTime? publishedTo;
  final String type;

  const Manga({
    required this.id,
    required this.title,
    this.titleJapanese,
    this.titleEnglish,
    this.synopsis,
    required this.coverUrl,
    this.largeCoverUrl,
    this.authors = const [],
    this.genres = const [],
    this.status = 'Unknown',
    this.totalChapters,
    this.totalVolumes,
    this.score,
    this.scoredBy,
    this.rank,
    this.popularity,
    this.publishedFrom,
    this.publishedTo,
    this.type = 'Manga',
  });

  String get publicationStatusItalian {
    switch (status.toLowerCase()) {
      case 'publishing':
      case 'currently publishing':
        return 'In corso';
      case 'finished':
      case 'completed':
        return 'Concluso';
      case 'on_hiatus':
      case 'hiatus':
        return 'In pausa editoriale';
      case 'discontinued':
        return 'Interrotto';
      case 'not_yet_published':
      case 'upcoming':
        return 'Non ancora pubblicato';
      default:
        return 'Stato sconosciuto';
    }
  }

  String get authorDisplay {
    if (authors.isEmpty) return 'Autore sconosciuto';
    return authors.join(', ');
  }

  String get bestCoverUrl => largeCoverUrl ?? coverUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Manga && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
