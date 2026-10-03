import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:manga_library/core/theme/app_colors.dart';
import 'package:manga_library/domain/entities/reading_status.dart';
import 'package:manga_library/presentation/controllers/library_controller.dart';
import 'package:manga_library/presentation/widgets/empty_state.dart';

class StatisticsScreen extends StatelessWidget {
  final VoidCallback? onNavigateToSearch;

  const StatisticsScreen({super.key, this.onNavigateToSearch});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final libraryCtrl = context.watch<LibraryController>();
    final stats = libraryCtrl.statistics;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiche Personali'),
      ),
      body: stats.isEmpty
          ? EmptyState(
              icon: Icons.query_stats_rounded,
              title: 'Nessuna statistica disponibile',
              message: 'Le statistiche vengono calcolate in tempo reale in base ai manga e ai capitoli presenti nella tua libreria.',
              actionLabel: 'Cerca Manga',
              onAction: onNavigateToSearch,
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Schede Panoramica Principale
                  Row(
                    children: [
                      Expanded(
                        child: _buildHeroStatCard(
                          context,
                          'Manga Totali',
                          '${stats.totalManga}',
                          Icons.collections_bookmark_rounded,
                          AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildHeroStatCard(
                          context,
                          'Capitoli Letti',
                          '${stats.totalChaptersRead}',
                          Icons.menu_book_rounded,
                          AppColors.statusReading,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildHeroStatCard(
                          context,
                          'Volumi Posseduti',
                          '${stats.totalOwnedVolumes}',
                          Icons.auto_stories_rounded,
                          AppColors.secondary,
                          subtitle: stats.totalVolumesToBuy > 0 ? '${stats.totalVolumesToBuy} da acquistare' : 'Collezione aggiornata',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildHeroStatCard(
                          context,
                          'Valutazione Media',
                          stats.ratedCount > 0 ? '${stats.averageRating} / 10' : 'N/D',
                          Icons.star_rounded,
                          AppColors.warning,
                          subtitle: stats.ratedCount > 0 ? 'su ${stats.ratedCount} valutati' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildHeroStatCard(
                          context,
                          'Preferiti',
                          '${stats.favoriteCount}',
                          Icons.favorite_rounded,
                          AppColors.statusFavorite,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildHeroStatCard(
                          context,
                          'Da Acquistare',
                          '${stats.totalVolumesToBuy}',
                          Icons.shopping_bag_outlined,
                          AppColors.accent,
                          subtitle: 'Volumi mancanti',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Distribuzione per Stato di Lettura
                  Text(
                    'Distribuzione per Stato',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.dividerColor, width: 1),
                    ),
                    child: Column(
                      children: [
                        _buildStatusRow(
                          context,
                          ReadingStatus.reading.label,
                          stats.readingCount,
                          stats.totalManga,
                          AppColors.statusReading,
                        ),
                        const SizedBox(height: 12),
                        _buildStatusRow(
                          context,
                          ReadingStatus.completed.label,
                          stats.completedCount,
                          stats.totalManga,
                          AppColors.statusCompleted,
                        ),
                        const SizedBox(height: 12),
                        _buildStatusRow(
                          context,
                          ReadingStatus.planToRead.label,
                          stats.planToReadCount,
                          stats.totalManga,
                          AppColors.statusPlanToRead,
                        ),
                        const SizedBox(height: 12),
                        _buildStatusRow(
                          context,
                          ReadingStatus.onHold.label,
                          stats.onHoldCount,
                          stats.totalManga,
                          AppColors.statusOnHold,
                        ),
                        const SizedBox(height: 12),
                        _buildStatusRow(
                          context,
                          ReadingStatus.dropped.label,
                          stats.droppedCount,
                          stats.totalManga,
                          AppColors.statusDropped,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Generi più letti
                  if (stats.topGenres.isNotEmpty) ...[
                    Text(
                      'I Tuoi Generi Più Presenti',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.dividerColor, width: 1),
                      ),
                      child: Column(
                        children: stats.topGenres.map((entry) {
                          final maxCount = stats.topGenres.first.value;
                          final double ratio = maxCount > 0 ? entry.value / maxCount : 0;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      entry.key,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '${entry.value} manga',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: ratio,
                                    minHeight: 6,
                                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildHeroStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              Icon(icon, size: 20, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusRow(
    BuildContext context,
    String label,
    int count,
    int total,
    Color color,
  ) {
    final theme = Theme.of(context);
    final percentage = total > 0 ? (count / total) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Text(
              '$count (${(percentage * 100).toStringAsFixed(0)}%)',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 6,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
