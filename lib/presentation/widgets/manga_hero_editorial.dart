import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/entities/library_entry.dart';
import 'manga_cover.dart';

class MangaHeroEditorial extends StatelessWidget {
  final LibraryEntry entry;
  final VoidCallback onTap;
  final VoidCallback onIncrement;

  const MangaHeroEditorial({
    super.key,
    required this.entry,
    required this.onTap,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final progressPct = entry.totalChapters != null && entry.totalChapters! > 0
        ? '${(entry.progressPercentage * 100).toInt()}%'
        : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.nightSurface : AppColors.paperSurface,
        borderRadius: AppRadii.brSm,
        border: Border.all(
          color: isDark ? AppColors.nightBorder : AppColors.paperBorder,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.brSm,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Copertina grande protagonista
              SizedBox(
                width: 95,
                child: MangaCover(
                  coverUrl: entry.coverUrl,
                  heroTag: 'hero-continue-${entry.mangaId}',
                  showSpineEffect: true,
                ),
              ),

              const SizedBox(width: 14),

              // Layout editoriale compositivo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timbro superiore
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.editorialRed.withValues(
                              alpha: isDark ? 0.2 : 0.1,
                            ),
                            borderRadius: AppRadii.brXs,
                            border: Border.all(
                              color: AppColors.editorialRed,
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            'IN LETTURA',
                            style: AppTypography.volumeMono(
                              isDark: isDark,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.editorialRed,
                            ),
                          ),
                        ),
                        if (entry.lastReadAt != null)
                          Text(
                            DateFormatter.formatRelativeDate(entry.lastReadAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Titolo Manga
                    Text(
                      entry.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Indicatore Volume / Capitolo
                    Row(
                      children: [
                        if (entry.ownedVolumes > 0 ||
                            entry.totalVolumes != null) ...[
                          Text(
                            'VOL. ${entry.ownedVolumes > 0 ? entry.ownedVolumes : 1}',
                            style: AppTypography.volumeMono(
                              isDark: isDark,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text(' • '),
                        ],
                        Text(
                          'CAP. ${entry.currentChapter}${entry.totalChapters != null && entry.totalChapters! > 0 ? ' / ${entry.totalChapters}' : ''}',
                          style: AppTypography.volumeMono(
                            isDark: isDark,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.editorialRed,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Barra editoriale di avanzamento sottile
                    if (entry.totalChapters != null &&
                        entry.totalChapters! > 0) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(1),
                              child: LinearProgressIndicator(
                                value: entry.progressPercentage,
                                minHeight: 3,
                                backgroundColor: isDark
                                    ? AppColors.nightSurfaceVariant
                                    : AppColors.paperSurfaceVariant,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.editorialRed,
                                ),
                              ),
                            ),
                          ),
                          if (progressPct != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              progressPct,
                              style: AppTypography.volumeMono(
                                isDark: isDark,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColors.editorialRed,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],

                    // Pulsante Rapido Avanzamento
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: onIncrement,
                          icon: const Icon(Icons.add_rounded, size: 14),
                          label: const Text(
                            '+1 CAPITOLO',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            foregroundColor: AppColors.editorialRed,
                            side: const BorderSide(
                              color: AppColors.editorialRed,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadii.brXs,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
