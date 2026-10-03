import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/library_entry.dart';
import '../../domain/entities/manga.dart';
import 'manga_cover.dart';
import 'status_badge.dart';

class MangaCard extends StatelessWidget {
  final Manga? manga;
  final LibraryEntry? libraryEntry;
  final VoidCallback onTap;
  final String heroTagPrefix;

  const MangaCard({
    super.key,
    this.manga,
    this.libraryEntry,
    required this.onTap,
    this.heroTagPrefix = 'cover',
  }) : assert(
         manga != null || libraryEntry != null,
         'Deve essere fornito o manga o libraryEntry',
       );

  int get id => manga?.id ?? libraryEntry!.mangaId;
  String get title => manga?.title ?? libraryEntry!.title;
  String get coverUrl => manga?.bestCoverUrl ?? libraryEntry!.coverUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final entry = libraryEntry;

    return Semantics(
      label: 'Manga: $title',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Copertina fisica del volume
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MangaCover(
                      coverUrl: coverUrl,
                      heroTag: '$heroTagPrefix-$id',
                      showSpineEffect: true,
                      badge: entry != null
                          ? StatusBadge(status: entry.status, isCompact: true)
                          : null,
                    ),

                    // Icona Segnalibro Preferito (timbro editoriale in alto a destra)
                    if (entry != null && entry.isFavorite)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: AppColors.editorialRed,
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 3,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            size: 11,
                            color: Colors.white,
                          ),
                        ),
                      ),

                    // Barra sottile di lettura alla base della copertina
                    if (entry != null &&
                        entry.totalChapters != null &&
                        entry.totalChapters! > 0)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 3,
                          color: Colors.black45,
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: entry.progressPercentage,
                            child: Container(color: AppColors.editorialRed),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // Titolo editoriale
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 2),

              // Metadata / Progresso / Autore
              if (entry != null)
                Text(
                  'CAP. ${entry.currentChapter}${entry.totalChapters != null && entry.totalChapters! > 0 ? ' / ${entry.totalChapters}' : ''}',
                  style: AppTypography.volumeMono(
                    isDark: isDark,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.editorialRed,
                  ),
                )
              else if (manga != null)
                Text(
                  manga!.authorDisplay,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: isDark
                        ? AppColors.nightInkMuted
                        : AppColors.inkMuted,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
