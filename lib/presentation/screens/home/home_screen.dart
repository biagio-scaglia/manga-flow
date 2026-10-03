import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:manga_library/core/theme/app_colors.dart';
import 'package:manga_library/core/utils/date_formatter.dart';
import 'package:manga_library/domain/entities/library_entry.dart';
import 'package:manga_library/presentation/controllers/library_controller.dart';
import 'package:manga_library/presentation/screens/detail/manga_detail_screen.dart';
import 'package:manga_library/presentation/screens/settings/settings_screen.dart';
import 'package:manga_library/presentation/widgets/empty_state.dart';
import 'package:manga_library/presentation/widgets/manga_card.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onNavigateToSearch;
  final VoidCallback? onNavigateToLibrary;

  const HomeScreen({
    super.key,
    this.onNavigateToSearch,
    this.onNavigateToLibrary,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Buongiorno';
    } else if (hour >= 12 && hour < 18) {
      return 'Buon pomeriggio';
    } else {
      return 'Buonasera';
    }
  }

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
    final libraryCtrl = context.watch<LibraryController>();
    final continueReading = libraryCtrl.continueReadingEntries;
    final recentlyAdded = libraryCtrl.recentlyAddedEntries;
    final planToRead = libraryCtrl.planToReadEntries;
    final stats = libraryCtrl.statistics;

    final bool isLibraryEmpty = libraryCtrl.allEntries.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(),
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              'Pronto a continuare la lettura?',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
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
              icon: Icons.menu_book_rounded,
              title: 'La tua libreria è vuota',
              message: 'Cerca i tuoi manga preferiti, aggiungili alla libreria e tieni traccia dei tuoi capitoli.',
              actionLabel: 'Cerca Manga',
              onAction: onNavigateToSearch,
            )
          : RefreshIndicator(
              onRefresh: libraryCtrl.loadLibrary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sezione: Continua a leggere
                    if (continueReading.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Continua a leggere',
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            if (continueReading.length > 1)
                              Text(
                                '${continueReading.length} in corso',
                                style: theme.textTheme.bodySmall,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 190,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: continueReading.length,
                          itemBuilder: (context, index) {
                            final entry = continueReading[index];
                            return _buildContinueReadingCard(context, entry, libraryCtrl);
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Sezione: Statistiche Rapide
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Riepilogo Rapido',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildQuickStatCard(
                              context,
                              'Manga',
                              '${stats.totalManga}',
                              Icons.collections_bookmark_rounded,
                              AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildQuickStatCard(
                              context,
                              'In lettura',
                              '${stats.readingCount}',
                              Icons.auto_stories_rounded,
                              AppColors.statusReading,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildQuickStatCard(
                              context,
                              'Capitoli',
                              '${stats.totalChaptersRead}',
                              Icons.bookmark_added_rounded,
                              AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Sezione: Aggiunti di recente
                    if (recentlyAdded.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Aggiunti di recente',
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            TextButton(
                              onPressed: onNavigateToLibrary,
                              child: const Text('Vedi tutti'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 220,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: recentlyAdded.length,
                          itemBuilder: (context, index) {
                            final entry = recentlyAdded[index];
                            return Container(
                              width: 120,
                              margin: const EdgeInsets.only(right: 12),
                              child: MangaCard(
                                libraryEntry: entry,
                                onTap: () => _navigateToDetail(context, entry.mangaId),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Sezione: Da leggere
                    if (planToRead.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Da leggere',
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 220,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: planToRead.length,
                          itemBuilder: (context, index) {
                            final entry = planToRead[index];
                            return Container(
                              width: 120,
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

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildContinueReadingCard(
    BuildContext context,
    LibraryEntry entry,
    LibraryController libraryCtrl,
  ) {
    final theme = Theme.of(context);

    return Container(
      width: 290,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor, width: 1),
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(context, entry.mangaId),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Copertina
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 75,
                  height: 110,
                  child: Image.network(
                    entry.coverUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.darkSurfaceVariant,
                      child: const Icon(Icons.broken_image_rounded),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Dettagli e progresso rapido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      entry.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Capitolo ${entry.currentChapter}${entry.totalChapters != null && entry.totalChapters! > 0 ? ' / ${entry.totalChapters}' : ''}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (entry.lastReadAt != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        DateFormatter.formatRelativeDate(entry.lastReadAt),
                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                      ),
                    ],
                    const SizedBox(height: 8),

                    // Pulsante rapido +1 capitolo
                    ElevatedButton.icon(
                      onPressed: () => libraryCtrl.incrementChapter(entry.mangaId),
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('+1 Cap', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
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

  Widget _buildQuickStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
