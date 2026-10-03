import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:manga_library/core/theme/app_colors.dart';
import 'package:manga_library/domain/entities/library_entry.dart';
import 'package:manga_library/domain/entities/reading_status.dart';
import 'package:manga_library/presentation/controllers/library_controller.dart';
import 'package:manga_library/presentation/screens/detail/manga_detail_screen.dart';
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'Ordina libreria per',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                ...LibrarySortOption.values.map((option) {
                  final isSelected = controller.sortOption == option;
                  return ListTile(
                    title: Text(option.label),
                    trailing: isSelected ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
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

  @override
  Widget build(BuildContext context) {
    final libraryCtrl = context.watch<LibraryController>();
    final entries = libraryCtrl.filteredEntries;

    return Scaffold(
      appBar: AppBar(
        title: _isSearchingInLibrary
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: libraryCtrl.setSearchQuery,
                decoration: const InputDecoration(
                  hintText: 'Cerca nella tua libreria...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              )
            : const Text('La Mia Libreria'),
        actions: [
          IconButton(
            icon: Icon(_isSearchingInLibrary ? Icons.close_rounded : Icons.search_rounded),
            tooltip: _isSearchingInLibrary ? 'Chiudi ricerca' : 'Cerca nella libreria',
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
            icon: Icon(libraryCtrl.isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded),
            tooltip: libraryCtrl.isGridView ? 'Vista elenco' : 'Vista griglia',
            onPressed: libraryCtrl.toggleViewMode,
          ),
          IconButton(
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Ordina',
            onPressed: () => _showSortDialog(context, libraryCtrl),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra dei Filtri per Stato e Preferiti
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Filtro Tutti
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text('Tutti (${libraryCtrl.allEntries.length})'),
                    selected: libraryCtrl.selectedStatusFilter == null && !libraryCtrl.showFavoritesOnly,
                    onSelected: (selected) {
                      if (selected) {
                        libraryCtrl.setStatusFilter(null);
                        if (libraryCtrl.showFavoritesOnly) {
                          libraryCtrl.toggleFavoritesFilter();
                        }
                      }
                    },
                  ),
                ),

                // Filtro Preferiti
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    avatar: const Icon(Icons.favorite_rounded, size: 14, color: AppColors.statusFavorite),
                    label: const Text('Preferiti'),
                    selected: libraryCtrl.showFavoritesOnly,
                    onSelected: (selected) => libraryCtrl.toggleFavoritesFilter(),
                  ),
                ),

                // Filtri per ciascuno stato di lettura
                ...ReadingStatus.values.map((status) {
                  final isSelected = libraryCtrl.selectedStatusFilter == status && !libraryCtrl.showFavoritesOnly;
                  final count = libraryCtrl.allEntries.where((e) => e.status == status).length;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      avatar: Icon(status.icon, size: 14, color: isSelected ? Colors.white : status.color),
                      label: Text('${status.label} ($count)'),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          libraryCtrl.setStatusFilter(status);
                          if (libraryCtrl.showFavoritesOnly) {
                            libraryCtrl.toggleFavoritesFilter();
                          }
                        } else {
                          libraryCtrl.setStatusFilter(null);
                        }
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Contenuto principale
          Expanded(
            child: libraryCtrl.allEntries.isEmpty
                ? EmptyState(
                    icon: Icons.auto_stories_outlined,
                    title: 'La tua libreria è vuota',
                    message: 'Trova un manga che vuoi leggere e aggiungilo alla tua collezione per iniziare.',
                    actionLabel: 'Cerca Manga',
                    onAction: widget.onNavigateToSearch,
                  )
                : entries.isEmpty
                    ? const EmptyState(
                        icon: Icons.filter_alt_off_rounded,
                        title: 'Nessun manga trovato',
                        message: 'Nessun manga corrisponde ai filtri o alla ricerca selezionata.',
                      )
                    : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: libraryCtrl.isGridView
                            ? GridView.builder(
                                key: const ValueKey('library_grid'),
                                padding: const EdgeInsets.all(16),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 0.58,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 16,
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
                                padding: const EdgeInsets.all(16),
                                itemCount: entries.length,
                                itemBuilder: (context, index) {
                                  final entry = entries[index];
                                  return MangaListTile(
                                    libraryEntry: entry,
                                    onTap: () => _navigateToDetail(entry),
                                    onQuickIncrement: entry.status == ReadingStatus.reading
                                        ? () => libraryCtrl.incrementChapter(entry.mangaId)
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
