import 'package:flutter/material.dart';
import 'package:manga_library/core/theme/app_colors.dart';
import 'package:manga_library/domain/entities/library_entry.dart';
import 'package:manga_library/domain/entities/manga.dart';
import 'package:manga_library/presentation/widgets/status_badge.dart';

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
  }) : assert(manga != null || libraryEntry != null, 'Deve essere fornito o manga o libraryEntry');

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Copertina con rapporto di forma 3:4 o 2:3
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: theme.dividerColor,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Hero(
                          tag: '$heroTagPrefix-$id',
                          child: Image.network(
                            coverUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.darkSurfaceVariant,
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported_rounded,
                                    size: 32,
                                    color: AppColors.textMutedDark,
                                  ),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: AppColors.darkSurfaceVariant,
                                child: const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    // Badge di stato (se presente in libreria)
                    if (entry != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: StatusBadge(status: entry.status, isCompact: true),
                      ),

                    // Icona Preferito
                    if (entry != null && entry.isFavorite)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            size: 14,
                            color: AppColors.statusFavorite,
                          ),
                        ),
                      ),

                    // Barra di progresso inferiore per voci in libreria
                    if (entry != null && entry.totalChapters != null && entry.totalChapters! > 0)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                          child: LinearProgressIndicator(
                            value: entry.progressPercentage,
                            minHeight: 4,
                            backgroundColor: Colors.black.withValues(alpha: 0.5),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.statusReading),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Titolo
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 2),

              // Info progresso o autore
              if (entry != null)
                Text(
                  'Capitolo ${entry.currentChapter}${entry.totalChapters != null && entry.totalChapters! > 0 ? ' / ${entry.totalChapters}' : ''}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                )
              else if (manga != null)
                Text(
                  manga!.authorDisplay,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
