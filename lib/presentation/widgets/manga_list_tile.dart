import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/entities/library_entry.dart';
import '../../domain/entities/manga.dart';
import 'manga_cover.dart';
import 'rating_stars.dart';
import 'status_badge.dart';

class MangaListTile extends StatelessWidget {
  final Manga? manga;
  final LibraryEntry? libraryEntry;
  final VoidCallback onTap;
  final VoidCallback? onQuickIncrement;

  const MangaListTile({
    super.key,
    this.manga,
    this.libraryEntry,
    required this.onTap,
    this.onQuickIncrement,
  }) : assert(manga != null || libraryEntry != null);

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
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.nightSurface : AppColors.paperSurface,
          borderRadius: AppRadii.brXs,
          border: Border.all(
            color: isDark ? AppColors.nightBorder : AppColors.paperBorder,
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.brXs,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Copertina formato compatto
                SizedBox(
                  width: 52,
                  child: MangaCover(
                    coverUrl: coverUrl,
                    heroTag: 'list-cover-$id',
                    showSpineEffect: true,
                  ),
                ),

                const SizedBox(width: 12),

                // Info editoriale
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          if (entry != null && entry.isFavorite) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.favorite_rounded,
                              size: 14,
                              color: AppColors.statusFavorite,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),

                      if (entry != null) ...[
                        Row(
                          children: [
                            StatusBadge(status: entry.status, isCompact: true),
                            const SizedBox(width: 8),
                            if (entry.rating > 0)
                              RatingStars(rating: entry.rating, iconSize: 11),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'CAP. ${entry.currentChapter}${entry.totalChapters != null && entry.totalChapters! > 0 ? ' / ${entry.totalChapters}' : ''}',
                              style: AppTypography.volumeMono(
                                isDark: isDark,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.editorialRed,
                              ),
                            ),
                            if (entry.lastReadAt != null)
                              Text(
                                DateFormatter.formatRelativeDate(entry.lastReadAt),
                                style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                              ),
                          ],
                        ),
                      ] else if (manga != null) ...[
                        Text(
                          manga!.authorDisplay,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.nightSurfaceVariant : AppColors.paperSurfaceVariant,
                                borderRadius: AppRadii.brXs,
                                border: Border.all(
                                  color: isDark ? AppColors.nightBorder : AppColors.paperBorder,
                                ),
                              ),
                              child: Text(
                                manga!.publicationStatusItalian.toUpperCase(),
                                style: AppTypography.volumeMono(
                                  isDark: isDark,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.nightInkSecondary : AppColors.inkSecondary,
                                ),
                              ),
                            ),
                            if (manga!.score != null) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.star_rounded, size: 12, color: AppColors.paperGold),
                              const SizedBox(width: 2),
                              Text(
                                manga!.score!.toStringAsFixed(2),
                                style: AppTypography.volumeMono(
                                  isDark: isDark,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Pulsante rapido +1 capitolo se in lettura
                if (entry != null && onQuickIncrement != null) ...[
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: onQuickIncrement,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    tooltip: 'Incrementa capitolo',
                    color: AppColors.editorialRed,
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(6),
                      minimumSize: const Size(32, 32),
                      side: BorderSide(
                        color: isDark ? AppColors.nightBorder : AppColors.paperBorder,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: AppRadii.brXs),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
