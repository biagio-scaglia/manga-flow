import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:manga_library/core/theme/app_colors.dart';
import 'package:manga_library/core/theme/app_typography.dart';
import 'package:manga_library/domain/entities/manga.dart';
import 'package:manga_library/presentation/controllers/library_controller.dart';
import 'package:manga_library/presentation/controllers/search_controller.dart';
import 'package:manga_library/presentation/screens/detail/manga_detail_screen.dart';
import 'package:manga_library/presentation/widgets/editorial_section_header.dart';
import 'package:manga_library/presentation/widgets/empty_state.dart';
import 'package:manga_library/presentation/widgets/manga_card.dart';
import 'package:manga_library/presentation/widgets/skeleton_loader.dart';
import 'package:manga_library/presentation/widgets/stale_banner.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      context.read<MangaSearchController>().loadMore();
    }
  }

  void _navigateToDetail(Manga manga) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MangaDetailScreen(
          mangaId: manga.id,
          initialManga: manga,
        ),
      ),
    );
  }

  int _calculateColumns(double screenWidth) {
    if (screenWidth >= 1200) return 5;
    if (screenWidth >= 900) return 4;
    if (screenWidth >= 600) return 3;
    return 2; // Mobile: 2 colonne per copertine verticali nitide
  }

  @override
  Widget build(BuildContext context) {
    final searchCtrl = context.watch<MangaSearchController>();
    final libraryCtrl = context.watch<LibraryController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final columns = _calculateColumns(screenWidth);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'CERCA MANGA',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              'CATALOGO TITOLI E AUTORI • 検索',
              style: AppTypography.volumeMono(
                isDark: isDark,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.nightInkMuted : AppColors.inkMuted,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              controller: _textController,
              onChanged: searchCtrl.onQueryChanged,
              textInputAction: TextInputAction.search,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Cerca titolo, autore o serie (es. Berserk, Nana)...',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.nightInkMuted : AppColors.inkMuted,
                  fontSize: 13,
                ),
                prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.editorialRed),
                suffixIcon: _textController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 16),
                        onPressed: () {
                          _textController.clear();
                          searchCtrl.clearSearch();
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Stale banner se offline o da cache
          if (searchCtrl.isStale)
            StaleBanner(onRefresh: searchCtrl.retry),

          Expanded(
            child: Builder(
              builder: (context) {
                // Errore
                if (searchCtrl.errorMessage != null && searchCtrl.searchResults.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.wifi_off_rounded, size: 36, color: AppColors.editorialRed),
                          const SizedBox(height: 12),
                          Text(
                            searchCtrl.errorMessage!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: searchCtrl.retry,
                            child: const Text('RIPROVA'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // In ricerca attiva con caricamento iniziale
                if (searchCtrl.isLoading && searchCtrl.searchResults.isEmpty) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      childAspectRatio: 0.62,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 18,
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) => const MangaCardSkeleton(),
                  );
                }

                // Risultati di ricerca trovati
                if (searchCtrl.isSearching) {
                  if (searchCtrl.searchResults.isEmpty && !searchCtrl.isLoading) {
                    return const EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'Nessun volume trovato',
                      japaneseSub: '見つかりませんでした',
                      message: 'Non abbiamo trovato alcun manga corrispondente alla tua ricerca. Prova a verificare l\'ortografia o cerca il titolo internazionale.',
                    );
                  }

                  return CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverToBoxAdapter(
                        child: EditorialSectionHeader(
                          index: '01',
                          title: 'RISULTATI (${searchCtrl.searchResults.length})',
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        sliver: SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            childAspectRatio: 0.62,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 18,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index >= searchCtrl.searchResults.length) {
                                return const MangaCardSkeleton();
                              }
                              final manga = searchCtrl.searchResults[index];
                              return MangaCard(
                                manga: manga,
                                libraryEntry: libraryCtrl.getEntry(manga.id),
                                onTap: () => _navigateToDetail(manga),
                              );
                            },
                            childCount: searchCtrl.searchResults.length + (searchCtrl.isLoadingMore ? 2 : 0),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                // Schermata iniziale con Manga Popolari dal catalogo
                return CustomScrollView(
                  slivers: [
                    const SliverToBoxAdapter(
                      child: EditorialSectionHeader(
                        index: '01',
                        title: 'CATALOGO IN EVIDENZA',
                        subtitle: 'I manga più amati e richiesti dai lettori',
                      ),
                    ),
                    if (searchCtrl.isLoadingPopular && searchCtrl.popularManga.isEmpty) ...[
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        sliver: SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            childAspectRatio: 0.62,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 18,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => const MangaCardSkeleton(),
                            childCount: 6,
                          ),
                        ),
                      ),
                    ] else ...[
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        sliver: SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            childAspectRatio: 0.62,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 18,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final manga = searchCtrl.popularManga[index];
                              return MangaCard(
                                manga: manga,
                                libraryEntry: libraryCtrl.getEntry(manga.id),
                                onTap: () => _navigateToDetail(manga),
                              );
                            },
                            childCount: searchCtrl.popularManga.length,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
