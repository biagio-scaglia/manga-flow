import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:manga_library/core/theme/app_colors.dart';
import 'package:manga_library/domain/entities/manga.dart';
import 'package:manga_library/presentation/controllers/search_controller.dart';
import 'package:manga_library/presentation/screens/detail/manga_detail_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    final searchCtrl = context.watch<MangaSearchController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cerca Manga'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _textController,
              onChanged: searchCtrl.onQueryChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Cerca per titolo (es. Berserk, Naruto)...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                suffixIcon: _textController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _textController.clear();
                          searchCtrl.clearSearch();
                        },
                      )
                    : null,
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
                          const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.error),
                          const SizedBox(height: 16),
                          Text(
                            searchCtrl.errorMessage!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: searchCtrl.retry,
                            child: const Text('Riprova'),
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
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.58,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: 9,
                    itemBuilder: (context, index) => const MangaCardSkeleton(),
                  );
                }

                // Risultati di ricerca trovati
                if (searchCtrl.isSearching) {
                  if (searchCtrl.searchResults.isEmpty && !searchCtrl.isLoading) {
                    return const EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'Nessun risultato',
                      message: 'Non abbiamo trovato alcun manga corrispondente alla tua ricerca. Prova con un altro titolo.',
                    );
                  }

                  return GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.58,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: searchCtrl.searchResults.length + (searchCtrl.isLoadingMore ? 3 : 0),
                    itemBuilder: (context, index) {
                      if (index >= searchCtrl.searchResults.length) {
                        return const MangaCardSkeleton();
                      }
                      final manga = searchCtrl.searchResults[index];
                      return MangaCard(
                        manga: manga,
                        onTap: () => _navigateToDetail(manga),
                      );
                    },
                  );
                }

                // Schermata iniziale con Manga Popolari reali
                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Row(
                          children: [
                            const Icon(Icons.trending_up_rounded, size: 20, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Manga più popolari',
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (searchCtrl.isLoadingPopular && searchCtrl.popularManga.isEmpty) ...[
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.58,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 16,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => const MangaCardSkeleton(),
                            childCount: 6,
                          ),
                        ),
                      ),
                    ] else ...[
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.58,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 16,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final manga = searchCtrl.popularManga[index];
                              return MangaCard(
                                manga: manga,
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
