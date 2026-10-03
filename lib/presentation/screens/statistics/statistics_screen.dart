import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:manga_library/core/theme/app_colors.dart';
import 'package:manga_library/core/theme/app_radii.dart';
import 'package:manga_library/core/theme/app_typography.dart';
import 'package:manga_library/domain/entities/reading_status.dart';
import 'package:manga_library/presentation/controllers/library_controller.dart';
import 'package:manga_library/presentation/widgets/editorial_section_header.dart';
import 'package:manga_library/presentation/widgets/empty_state.dart';

class StatisticsScreen extends StatelessWidget {
  final VoidCallback? onNavigateToSearch;

  const StatisticsScreen({super.key, this.onNavigateToSearch});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final libraryCtrl = context.watch<LibraryController>();
    final stats = libraryCtrl.statistics;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'STATISTICHE CATALOGO',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              'DATI REALI DELLA TUA LIBRERIA • 統計',
              style: AppTypography.volumeMono(
                isDark: isDark,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.nightInkMuted : AppColors.inkMuted,
              ),
            ),
          ],
        ),
      ),
      body: stats.isEmpty
          ? EmptyState(
              icon: Icons.query_stats_rounded,
              title: 'Nessuna statistica registrata',
              japaneseSub: 'データなし',
              message: 'Le statistiche vengono calcolate in tempo reale in base ai manga e ai capitoli presenti nel tuo catalogo personale.',
              actionLabel: 'Cerca Manga',
              onAction: onNavigateToSearch,
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SEZIONE 01: RIEPILOGO CATALOGO
                  const EditorialSectionHeader(
                    index: '01',
                    title: 'RIEPILOGO CATALOGO',
                    subtitle: 'Indicatori principali della collezione',
                  ),
                  const SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildEditorialStatTile(
                                context,
                                label: 'MANGA TOTALI',
                                value: '${stats.totalManga}',
                                sub: 'OPERE IN CATALOGO',
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildEditorialStatTile(
                                context,
                                label: 'CAPITOLI LETTI',
                                value: '${stats.totalChaptersRead}',
                                sub: 'TOTALI AVANZATI',
                                isDark: isDark,
                                isRed: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildEditorialStatTile(
                                context,
                                label: 'VOLUMI POSSEDUTI',
                                value: '${stats.totalOwnedVolumes}',
                                sub: stats.totalVolumesToBuy > 0
                                    ? '${stats.totalVolumesToBuy} DA ACQUISTARE'
                                    : 'COLLEZIONE COMPLETA',
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildEditorialStatTile(
                                context,
                                label: 'MEDIA VOTO',
                                value: stats.ratedCount > 0 ? '${stats.averageRating} / 10' : 'N/D',
                                sub: stats.ratedCount > 0 ? 'SU ${stats.ratedCount} VALUTATI' : 'NESSUN VOTO',
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // SEZIONE 02: STATO DELLE OPERE
                  const EditorialSectionHeader(
                    index: '02',
                    title: 'DISTRIBUZIONE PER STATO',
                    subtitle: 'Percentuale avanzamento catalogo',
                  ),
                  const SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.nightSurface : AppColors.paperSurface,
                        borderRadius: AppRadii.brSm,
                        border: Border.all(
                          color: isDark ? AppColors.nightBorder : AppColors.paperBorder,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildStatusRow(
                            context,
                            ReadingStatus.reading.label.toUpperCase(),
                            stats.readingCount,
                            stats.totalManga,
                            AppColors.statusReading,
                            isDark,
                          ),
                          const SizedBox(height: 10),
                          _buildStatusRow(
                            context,
                            ReadingStatus.completed.label.toUpperCase(),
                            stats.completedCount,
                            stats.totalManga,
                            AppColors.statusCompleted,
                            isDark,
                          ),
                          const SizedBox(height: 10),
                          _buildStatusRow(
                            context,
                            ReadingStatus.planToRead.label.toUpperCase(),
                            stats.planToReadCount,
                            stats.totalManga,
                            AppColors.statusPlanToRead,
                            isDark,
                          ),
                          const SizedBox(height: 10),
                          _buildStatusRow(
                            context,
                            ReadingStatus.onHold.label.toUpperCase(),
                            stats.onHoldCount,
                            stats.totalManga,
                            AppColors.statusOnHold,
                            isDark,
                          ),
                          const SizedBox(height: 10),
                          _buildStatusRow(
                            context,
                            ReadingStatus.dropped.label.toUpperCase(),
                            stats.droppedCount,
                            stats.totalManga,
                            AppColors.statusDropped,
                            isDark,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // SEZIONE 03: GENERI PIÙ PRESENTI
                  if (stats.topGenres.isNotEmpty) ...[
                    const EditorialSectionHeader(
                      index: '03',
                      title: 'GENERI PIÙ PRESENTI',
                      subtitle: 'Tematiche dominanti nella tua libreria',
                    ),
                    const SizedBox(height: 8),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.nightSurface : AppColors.paperSurface,
                          borderRadius: AppRadii.brSm,
                          border: Border.all(
                            color: isDark ? AppColors.nightBorder : AppColors.paperBorder,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: stats.topGenres.map((entry) {
                            final maxCount = stats.topGenres.first.value;
                            final double ratio = maxCount > 0 ? entry.value / maxCount : 0;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        entry.key.toUpperCase(),
                                        style: AppTypography.volumeMono(
                                          isDark: isDark,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        '${entry.value} VOLUMI',
                                        style: AppTypography.volumeMono(
                                          isDark: isDark,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? AppColors.nightInkMuted : AppColors.inkMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    height: 3,
                                    color: isDark ? AppColors.nightSurfaceVariant : AppColors.paperSurfaceVariant,
                                    alignment: Alignment.centerLeft,
                                    child: FractionallySizedBox(
                                      widthFactor: ratio.clamp(0.0, 1.0),
                                      child: Container(color: AppColors.editorialRed),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 36),
                ],
              ),
            ),
    );
  }

  Widget _buildEditorialStatTile(
    BuildContext context, {
    required String label,
    required String value,
    required String sub,
    required bool isDark,
    bool isRed = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.nightSurface : AppColors.paperSurface,
        borderRadius: AppRadii.brSm,
        border: Border.all(
          color: isDark ? AppColors.nightBorder : AppColors.paperBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.volumeMono(
              isDark: isDark,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.nightInkMuted : AppColors.inkMuted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.volumeMono(
              isDark: isDark,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: isRed ? AppColors.editorialRed : (isDark ? AppColors.nightInk : AppColors.inkBlack),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: AppTypography.volumeMono(
              isDark: isDark,
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.nightInkSecondary : AppColors.inkSecondary,
            ),
          ),
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
    bool isDark,
  ) {
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
                  width: 6,
                  height: 6,
                  color: color,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: AppTypography.volumeMono(
                    isDark: isDark,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Text(
              '$count (${(percentage * 100).toStringAsFixed(0)}%)',
              style: AppTypography.volumeMono(
                isDark: isDark,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.nightInkMuted : AppColors.inkMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 3,
          color: isDark ? AppColors.nightSurfaceVariant : AppColors.paperSurfaceVariant,
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: percentage.clamp(0.0, 1.0),
            child: Container(color: color),
          ),
        ),
      ],
    );
  }
}
