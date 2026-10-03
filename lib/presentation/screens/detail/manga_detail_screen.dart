import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:manga_library/core/theme/app_colors.dart';
import 'package:manga_library/core/utils/date_formatter.dart';
import 'package:manga_library/domain/entities/library_entry.dart';
import 'package:manga_library/domain/entities/manga.dart';
import 'package:manga_library/domain/entities/reading_status.dart';
import 'package:manga_library/domain/repositories/manga_repository.dart';
import 'package:manga_library/presentation/controllers/library_controller.dart';
import 'package:manga_library/presentation/widgets/progress_stepper.dart';
import 'package:manga_library/presentation/widgets/rating_stars.dart';
import 'package:manga_library/presentation/widgets/skeleton_loader.dart';
import 'package:manga_library/presentation/widgets/status_badge.dart';

class MangaDetailScreen extends StatefulWidget {
  final int mangaId;
  final Manga? initialManga;

  const MangaDetailScreen({
    super.key,
    required this.mangaId,
    this.initialManga,
  });

  @override
  State<MangaDetailScreen> createState() => _MangaDetailScreenState();
}

class _MangaDetailScreenState extends State<MangaDetailScreen> {
  Manga? _manga;
  bool _isLoadingDetails = false;
  late TextEditingController _notesController;
  bool _isEditingNotes = false;

  @override
  void initState() {
    super.initState();
    _manga = widget.initialManga;
    _notesController = TextEditingController();
    _fetchDetailsIfNeeded();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetailsIfNeeded() async {
    if (_manga != null && _manga!.synopsis != null && _manga!.synopsis!.isNotEmpty) {
      return;
    }

    setState(() {
      _isLoadingDetails = true;
    });

    try {
      final repository = context.read<MangaRepository>();
      final fullDetails = await repository.getMangaDetails(widget.mangaId);
      if (mounted) {
        setState(() {
          _manga = fullDetails;
          _isLoadingDetails = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingDetails = false;
        });
      }
    }
  }

  void _showAddDialog(BuildContext context, LibraryController libraryController) {
    ReadingStatus selectedStatus = ReadingStatus.reading;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Aggiungi alla Libreria',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  Text('Seleziona lo stato iniziale:', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ReadingStatus.values.map((status) {
                      final isSelected = selectedStatus == status;
                      return ChoiceChip(
                        label: Text(status.label),
                        selected: isSelected,
                        avatar: Icon(status.icon, size: 16, color: isSelected ? Colors.white : status.color),
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() => selectedStatus = status);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      final newEntry = LibraryEntry(
                        mangaId: widget.mangaId,
                        title: _manga?.title ?? 'Manga #${widget.mangaId}',
                        coverUrl: _manga?.bestCoverUrl ?? '',
                        status: selectedStatus,
                        currentChapter: 0,
                        totalChapters: _manga?.totalChapters,
                        genres: _manga?.genres ?? [],
                        authors: _manga?.authors ?? [],
                        addedAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      );
                      libraryController.addOrUpdateEntry(newEntry);
                      Navigator.of(bottomSheetContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Aggiunto a "${selectedStatus.label}"')),
                      );
                    },
                    child: const Text('Conferma e aggiungi'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, LibraryController libraryController) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Rimuovi dalla libreria'),
          content: const Text('Sei sicuro di voler rimuovere questo manga dalla tua libreria personale?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () {
                libraryController.removeEntry(widget.mangaId);
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Manga rimosso dalla libreria')),
                );
              },
              child: const Text('Rimuovi'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final libraryController = context.watch<LibraryController>();
    final entry = libraryController.getEntry(widget.mangaId);
    final bool isInLibrary = entry != null;

    final title = _manga?.title ?? entry?.title ?? 'Dettaglio Manga';
    final coverUrl = _manga?.bestCoverUrl ?? entry?.coverUrl ?? '';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar con Copertina Espansa
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            stretch: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              if (isInLibrary)
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      entry.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: entry.isFavorite ? AppColors.statusFavorite : Colors.white,
                      size: 20,
                    ),
                  ),
                  onPressed: () => libraryController.toggleFavorite(widget.mangaId),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Sfondo sfocato o scuro
                  if (coverUrl.isNotEmpty)
                    Image.network(
                      coverUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(color: AppColors.darkSurface),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.black.withValues(alpha: 0.8),
                          theme.scaffoldBackgroundColor,
                        ],
                      ),
                    ),
                  ),
                  // Immagine centrale nitida in Hero
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40, bottom: 20),
                      child: Hero(
                        tag: 'cover-${widget.mangaId}',
                        child: Container(
                          width: 140,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: coverUrl.isNotEmpty
                                ? Image.network(coverUrl, fit: BoxFit.cover)
                                : Container(color: AppColors.darkSurfaceVariant),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contenuto informativo
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titolo e Autore
                  Text(
                    title,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (_manga?.titleJapanese != null && _manga!.titleJapanese!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      _manga!.titleJapanese!,
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 13),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    _manga?.authorDisplay ?? (entry != null && entry.authors.isNotEmpty ? entry.authors.join(', ') : 'Autore sconosciuto'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Pillole informative rapide (Punteggio, Stato pubblicazione, Capitoli)
                  Row(
                    children: [
                      if (_manga?.score != null) ...[
                        _buildInfoChip(
                          context,
                          Icons.star_rounded,
                          '${_manga!.score!.toStringAsFixed(2)} MAL',
                          AppColors.warning,
                        ),
                        const SizedBox(width: 8),
                      ],
                      _buildInfoChip(
                        context,
                        Icons.info_outline_rounded,
                        _manga?.publicationStatusItalian ?? 'Pubblicazione',
                        AppColors.accent,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        context,
                        Icons.menu_book_rounded,
                        _manga?.totalChapters != null && _manga!.totalChapters! > 0
                            ? '${_manga!.totalChapters} cap.'
                            : 'Capitoli N/D',
                        AppColors.statusReading,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // SEZIONE GESTIONE LIBRERIA PERSONALE
                  if (!isInLibrary) ...[
                    ElevatedButton.icon(
                      onPressed: () => _showAddDialog(context, libraryController),
                      icon: const Icon(Icons.bookmark_add_rounded),
                      label: const Text('Aggiungi alla Libreria'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                    ),
                  ] else ...[
                    // Scheda di gestione della voce presente
                    Container(
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
                                'La tua lettura',
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              StatusBadge(status: entry.status),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Selettore Rapido Stato
                          Text('Cambia stato:', style: theme.textTheme.labelMedium),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: ReadingStatus.values.map((status) {
                                final isSelected = entry.status == status;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: FilterChip(
                                    label: Text(status.label, style: const TextStyle(fontSize: 12)),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      if (selected) {
                                        libraryController.updateStatus(widget.mangaId, status);
                                      }
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Tracker Progresso Capitolo
                          Text('Progresso di lettura:', style: theme.textTheme.labelMedium),
                          const SizedBox(height: 8),
                          ProgressStepper(
                            currentChapter: entry.currentChapter,
                            totalChapters: entry.totalChapters ?? _manga?.totalChapters,
                            isCompleted: entry.status == ReadingStatus.completed,
                            onProgressChanged: (newChapter) {
                              libraryController.updateProgress(widget.mangaId, newChapter);
                            },
                            onMarkCompleted: () {
                              libraryController.updateStatus(widget.mangaId, ReadingStatus.completed);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Manga segnato come completato!')),
                              );
                            },
                          ),

                          const SizedBox(height: 20),

                          // Valutazione personale
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('La tua valutazione:', style: theme.textTheme.labelMedium),
                              Text(
                                entry.rating > 0 ? '${entry.rating} / 10' : 'Non valutato',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: entry.rating > 0 ? AppColors.warning : null,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          RatingStars(
                            rating: entry.rating,
                            iconSize: 28,
                            onRatingChanged: (newRating) {
                              libraryController.updateRating(widget.mangaId, newRating);
                            },
                          ),

                          const SizedBox(height: 20),

                          // Note personali
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Note personali:', style: theme.textTheme.labelMedium),
                              if (!_isEditingNotes)
                                TextButton(
                                  onPressed: () {
                                    _notesController.text = entry.notes;
                                    setState(() => _isEditingNotes = true);
                                  },
                                  child: const Text('Modifica note'),
                                ),
                            ],
                          ),
                          if (_isEditingNotes) ...[
                            const SizedBox(height: 8),
                            TextField(
                              controller: _notesController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                hintText: 'Aggiungi un promemoria o una recensione...',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => setState(() => _isEditingNotes = false),
                                  child: const Text('Annulla'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    libraryController.updateNotes(widget.mangaId, _notesController.text.trim());
                                    setState(() => _isEditingNotes = false);
                                  },
                                  child: const Text('Salva nota'),
                                ),
                              ],
                            ),
                          ] else if (entry.notes.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                entry.notes,
                                style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                              ),
                            ),
                          ] else ...[
                            Text(
                              'Nessuna nota aggiunta.',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],

                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 12),

                          // Date e pulsante eliminazione
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Aggiunto: ${DateFormatter.formatShortDate(entry.addedAt)}',
                                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                                  ),
                                  if (entry.lastReadAt != null)
                                    Text(
                                      'Ultima lettura: ${DateFormatter.formatRelativeDate(entry.lastReadAt)}',
                                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                                    ),
                                ],
                              ),
                              TextButton.icon(
                                onPressed: () => _confirmDelete(context, libraryController),
                                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                                label: const Text('Rimuovi', style: TextStyle(color: AppColors.error, fontSize: 13)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Generi
                  if (_manga?.genres != null && _manga!.genres.isNotEmpty) ...[
                    Text(
                      'Generi e Tematiche',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _manga!.genres.map((genre) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            genre,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Trama / Descrizione
                  Text(
                    'Trama',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),

                  if (_isLoadingDetails) ...[
                    const SkeletonLoader(width: double.infinity, height: 16),
                    const SizedBox(height: 6),
                    const SkeletonLoader(width: double.infinity, height: 16),
                    const SizedBox(height: 6),
                    const SkeletonLoader(width: 200, height: 16),
                  ] else if (_manga?.synopsis != null && _manga!.synopsis!.isNotEmpty) ...[
                    Text(
                      _manga!.synopsis!,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                    ),
                  ] else ...[
                    Text(
                      'Descrizione non disponibile per questo manga.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppColors.textMutedDark,
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
