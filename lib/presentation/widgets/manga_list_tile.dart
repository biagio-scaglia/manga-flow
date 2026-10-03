import 'package:flutter/material.dart';
import 'package:manga_library/core/theme/app_colors.dart';
import 'package:manga_library/core/utils/date_formatter.dart';
import 'package:manga_library/domain/entities/library_entry.dart';
import 'package:manga_library/domain/entities/manga.dart';
import 'package:manga_library/presentation/widgets/rating_stars.dart';
import 'package:manga_library/presentation/widgets/status_badge.dart';

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
    final entry = libraryEntry;

    return Semantics(
      label: 'Manga: $title',
      button: true,
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // Copertina
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 60,
                    height: 85,
                    child: Image.network(
                      coverUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.darkSurfaceVariant,
                        child: const Icon(Icons.broken_image_rounded, size: 20),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Info
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
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (entry != null && entry.isFavorite) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.favorite_rounded,
                              size: 16,
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
                              RatingStars(rating: entry.rating, iconSize: 12),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Capitolo ${entry.currentChapter}${entry.totalChapters != null && entry.totalChapters! > 0 ? ' / ${entry.totalChapters}' : ''}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
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
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                manga!.publicationStatusItalian,
                                style: const TextStyle(fontSize: 10, color: AppColors.primaryLight),
                              ),
                            ),
                            if (manga!.score != null) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.star_rounded, size: 12, color: AppColors.warning),
                              const SizedBox(width: 2),
                              Text(
                                manga!.score!.toStringAsFixed(2),
                                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Pulsante rapido incremento capitolo se in lettura
                if (entry != null && onQuickIncrement != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onQuickIncrement,
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    tooltip: 'Incrementa capitolo',
                    color: AppColors.primary,
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
