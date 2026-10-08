import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:manga_library/core/theme/app_colors.dart';
import 'package:manga_library/core/theme/app_typography.dart';
import 'package:manga_library/domain/entities/library_entry.dart';
import 'package:manga_library/domain/entities/reading_status.dart';
import 'package:manga_library/presentation/controllers/library_controller.dart';
import 'package:manga_library/presentation/screens/detail/manga_detail_screen.dart';
import 'package:manga_library/presentation/widgets/catalog_filter_tabs.dart';
import 'package:manga_library/presentation/widgets/empty_state.dart';
import 'package:manga_library/presentation/widgets/manga_card.dart';
import 'package:manga_library/presentation/widgets/manga_list_tile.dart';

class LibraryScreen extends StatefulWidget {
  final VoidCallback? onNavigateToSearch;

  const LibraryScreen({super.key, this.onNavigateToSearch});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchingInLibrary = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToDetail(LibraryEntry entry) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MangaDetailScreen(mangaId: entry.mangaId),
      ),
    );
  }

  void _showSortDialog(BuildContext context, LibraryController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.nightSurface : AppColors.paperSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (bottomContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ORDINA CATALOGO PER',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                      ),
                      const Text(
                        '並び替え',
                        style: TextStyle(fontSize: 10, letterSpacing: 1.0),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 1,
                  color: isDark ? AppColors.nightBorder : AppColors.paperBorder,
                  margin: const EdgeInsets.only(bottom: 8),
                ),
                ...LibrarySortOption.values.map((option) {
                  final isSelected = controller.sortOption == option;
                  return ListTile(
                    dense: true,
                    title: Text(
                      option.label.toUpperCase(),
                      style: AppTypography.volumeMono(
                        isDark: isDark,
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: isSelected ? AppColors.editorialRed : null,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: AppColors.editorialRed,
                            size: 18,
                          )
                        : null,
                    onTap: () {
                      controller.setSortOption(option);
                      Navigator.of(bottomContext).pop();
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  int _calculateColumns(double screenWidth) {
    if (screenWidth >= 1200) return 5;
    if (screenWidth >= 900) return 4;
    if (screenWidth >= 600) return 3;
    return 2; // Smartphone: 2 colonne per dare risalto alle copertine
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final libraryCtrl = context.watch<LibraryController>();
    final entries = libraryCtrl.filteredEntries;
    final screenWidth = MediaQuery.of(context).size.width;
    final columns = _calculateColumns(screenWidth);

    final statusCounts = <ReadingStatus, int>{};
    for (final s in ReadingStatus.values) {
      statusCounts[s] = libraryCtrl.allEntries
          .where((e) => e.status == s)
          .length;
    }

    return Scaffold(
      appBar: AppBar(
        title: _isSearchingInLibrary
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: libraryCtrl.setSearchQuery,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'Cerca per titolo nella libreria...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.nightInkMuted
                        : AppColors.inkMuted,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'LA MIA LIBRERIA',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    '${libraryCtrl.allEntries.length} TITOLI IN CATALOGO',
                    style: AppTypography.volumeMono(
                      isDark: isDark,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.nightInkMuted
                          : AppColors.inkMuted,
                    ),
                  ),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearchingInLibrary
                  ? Icons.close_rounded
                  : Icons.search_rounded,
              size: 20,
            ),
            tooltip: _isSearchingInLibrary
                ? 'Chiudi ricerca'
                : 'Cerca nella libreria',
            onPressed: () {
              setState(() {
                _isSearchingInLibrary = !_isSearchingInLibrary;
                if (!_isSearchingInLibrary) {
                  _searchController.clear();
                  libraryCtrl.setSearchQuery('');
                }
              });
            },
          ),
          IconButton(
            icon: Icon(
              libraryCtrl.isGridView
                  ? Icons.view_list_rounded
                  : Icons.grid_view_rounded,
              size: 20,
            ),
            tooltip: libraryCtrl.isGridView ? 'Vista elenco' : 'Vista griglia',
            onPressed: libraryCtrl.toggleViewMode,
          ),
          IconButton(
            icon: const Icon(Icons.sort_rounded, size: 20),
            tooltip: 'Ordina',
            onPressed: () => _showSortDialog(context, libraryCtrl),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          // Selettori di stato / Segmented Editorial Tabs
          CatalogFilterTabs(
            selectedStatus: libraryCtrl.selectedStatusFilter,
            showFavoritesOnly: libraryCtrl.showFavoritesOnly,
            totalCount: libraryCtrl.allEntries.length,
            statusCounts: statusCounts,
            onStatusSelected: libraryCtrl.setStatusFilter,
            onToggleFavorites: libraryCtrl.toggleFavoritesFilter,
          ),

          const SizedBox(height: 8),

          // Contenuto principale griglia o lista
          Expanded(
            child: libraryCtrl.allEntries.isEmpty
                ? EmptyState(
                    icon: Icons.auto_stories_outlined,
                    title: 'La libreria è vuota',
                    japaneseSub: '目録は空です',
                    message:
                        'Il primo volume deve ancora arrivare. Aggiungi i manga che stai leggendo o vuoi collezionare.',
                    actionLabel: 'Cerca Manga',
                    onAction: widget.onNavigateToSearch,
                  )
                : entries.isEmpty
                ? const EmptyState(
                    icon: Icons.filter_alt_off_rounded,
                    title: 'Nessun volume trovato',
                    japaneseSub: '該当なし',
                    message:
                        'Nessun manga corrisponde al filtro o al criterio di ricerca selezionato.',
                  )
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: libraryCtrl.isGridView
                        ? GridView.builder(
                            key: const ValueKey('library_grid'),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  childAspectRatio: 0.62,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 18,
                                ),
                            itemCount: entries.length,
                            itemBuilder: (context, index) {
                              final entry = entries[index];
                              return MangaCard(
                                libraryEntry: entry,
                                onTap: () => _navigateToDetail(entry),
                              );
                            },
                          )
                        : ListView.builder(
                            key: const ValueKey('library_list'),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            itemCount: entries.length,
                            itemBuilder: (context, index) {
                              final entry = entries[index];
                              return MangaListTile(
                                libraryEntry: entry,
                                onTap: () => _navigateToDetail(entry),
                                onQuickIncrement:
                                    entry.status == ReadingStatus.reading
                                    ? () => libraryCtrl.incrementChapter(
                                        entry.mangaId,
                                      )
                                    : null,
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
