import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:manga_library/core/theme/app_colors.dart';
import 'package:manga_library/core/theme/app_radii.dart';
import 'package:manga_library/core/theme/app_typography.dart';
import 'package:manga_library/presentation/controllers/library_controller.dart';
import 'package:manga_library/presentation/screens/detail/manga_detail_screen.dart';
import 'package:manga_library/presentation/screens/settings/settings_screen.dart';
import 'package:manga_library/presentation/widgets/editorial_section_header.dart';
import 'package:manga_library/presentation/widgets/empty_state.dart';
import 'package:manga_library/presentation/widgets/manga_card.dart';
import 'package:manga_library/presentation/widgets/manga_hero_editorial.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onNavigateToSearch;
  final VoidCallback? onNavigateToLibrary;

  const HomeScreen({
    super.key,
    this.onNavigateToSearch,
    this.onNavigateToLibrary,
  });

  void _navigateToDetail(BuildContext context, int mangaId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MangaDetailScreen(mangaId: mangaId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final libraryCtrl = context.watch<LibraryController>();
    final continueReading = libraryCtrl.continueReadingEntries;
    final recentlyAdded = libraryCtrl.recentlyAddedEntries;
    final planToRead = libraryCtrl.planToReadEntries;
    final stats = libraryCtrl.statistics;

    final bool isLibraryEmpty = libraryCtrl.allEntries.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: AppRadii.brXs,
              child: Image.asset(
                'assets/icons/app_logo.png',
                width: 28,
                height: 28,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  color: AppColors.editorialRed,
                  child: const Text('MF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'MANGAFLOW',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'CATALOGO EDITORIALE • 漫画目録',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 9,
                    letterSpacing: 0.8,
                    color: isDark ? AppColors.nightInkMuted : AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, size: 20),
            tooltip: 'Impostazioni',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: isLibraryEmpty
          ? EmptyState(
              icon: Icons.auto_stories_outlined,
              title: 'La libreria è vuota',
              japaneseSub: '目録は空です',
              message: 'Il primo volume deve ancora arrivare. Cerca un manga per iniziare la tua collezione.',
              actionLabel: 'Cerca Manga',
              onAction: onNavigateToSearch,
            )
          : RefreshIndicator(
              onRefresh: libraryCtrl.loadLibrary,
              color: AppColors.editorialRed,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SEZIONE 01: CONTINUA LA LETTURA
                    if (continueReading.isNotEmpty) ...[
                      const EditorialSectionHeader(
                        index: '01',
                        title: 'CONTINUA LA LETTURA',
                        subtitle: 'Riprendi dal tuo ultimo capitolo aperto',
                      ),
                      const SizedBox(height: 8),
                      // Hero principale
                      MangaHeroEditorial(
                        entry: continueReading.first,
                        onTap: () => _navigateToDetail(context, continueReading.first.mangaId),
                        onIncrement: () => libraryCtrl.incrementChapter(continueReading.first.mangaId),
                      ),
                      // Se ci sono altri manga in lettura, mostra scaffale orizzontale
                      if (continueReading.length > 1) ...[
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'ALTRI IN CORSO (${continueReading.length - 1})',
                            style: AppTypography.volumeMono(
                              isDark: isDark,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.nightInkMuted : AppColors.inkMuted,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 195,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: continueReading.length - 1,
                            itemBuilder: (context, index) {
                              final entry = continueReading[index + 1];
                              return Container(
                                width: 110,
                                margin: const EdgeInsets.only(right: 12),
                                child: MangaCard(
                                  libraryEntry: entry,
                                  onTap: () => _navigateToDetail(context, entry.mangaId),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                    ],

                    // SEZIONE 02: ULTIMI AGGIUNTI
                    if (recentlyAdded.isNotEmpty) ...[
                      EditorialSectionHeader(
                        index: continueReading.isNotEmpty ? '02' : '01',
                        title: 'ULTIMI AGGIUNTI',
                        trailing: TextButton(
                          onPressed: onNavigateToLibrary,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'VEDI TUTTI',
                            style: AppTypography.volumeMono(
                              isDark: isDark,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.editorialRed,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: recentlyAdded.length,
                          itemBuilder: (context, index) {
                            final entry = recentlyAdded[index];
                            return Container(
                              width: 112,
                              margin: const EdgeInsets.only(right: 12),
                              child: MangaCard(
                                libraryEntry: entry,
                                onTap: () => _navigateToDetail(context, entry.mangaId),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // SEZIONE 03: DA LEGGERE
                    if (planToRead.isNotEmpty) ...[
                      EditorialSectionHeader(
                        index: continueReading.isNotEmpty ? '03' : '02',
                        title: 'DA LEGGERE',
                        subtitle: 'Volumi in lista d\'attesa',
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: planToRead.length,
                          itemBuilder: (context, index) {
                            final entry = planToRead[index];
                            return Container(
                              width: 112,
                              margin: const EdgeInsets.only(right: 12),
                              child: MangaCard(
                                libraryEntry: entry,
                                onTap: () => _navigateToDetail(context, entry.mangaId),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // SEZIONE 04: STATO COLLEZIONE (Riepilogo Editoriale)
                    EditorialSectionHeader(
                      index: continueReading.isNotEmpty ? (planToRead.isNotEmpty ? '04' : '03') : '02',
                      title: 'STATO COLLEZIONE',
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
                        child: Row(
                          children: [
                            _buildEditorialStatCounter(
                              context,
                              value: '${stats.totalManga}',
                              label: 'OPERE',
                              sub: 'IN CATALOGO',
                              isDark: isDark,
                            ),
                            _buildStatDivider(isDark),
                            _buildEditorialStatCounter(
                              context,
                              value: '${stats.totalChaptersRead}',
                              label: 'CAPITOLI',
                              sub: 'LETTI',
                              isDark: isDark,
                            ),
                            _buildStatDivider(isDark),
                            _buildEditorialStatCounter(
                              context,
                              value: '${stats.totalOwnedVolumes}',
                              label: 'VOLUMI',
                              sub: 'POSSEDUTI',
                              isDark: isDark,
                              isHighlight: true,
                            ),
                            _buildStatDivider(isDark),
                            _buildEditorialStatCounter(
                              context,
                              value: '${stats.completedCount}',
                              label: 'SERIE',
                              sub: 'CONCLUSE',
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEditorialStatCounter(
    BuildContext context, {
    required String value,
    required String label,
    required String sub,
    required bool isDark,
    bool isHighlight = false,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.volumeMono(
              isDark: isDark,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isHighlight ? AppColors.editorialRed : (isDark ? AppColors.nightInk : AppColors.inkBlack),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.volumeMono(
              isDark: isDark,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.nightInkSecondary : AppColors.inkSecondary,
            ),
          ),
          Text(
            sub,
            style: AppTypography.volumeMono(
              isDark: isDark,
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.nightInkMuted : AppColors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider(bool isDark) {
    return Container(
      width: 1,
      height: 36,
      color: isDark ? AppColors.nightBorder : AppColors.paperBorder,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
