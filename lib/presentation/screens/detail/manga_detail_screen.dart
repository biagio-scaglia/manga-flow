import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:manga_library/core/theme/app_colors.dart';
import 'package:manga_library/core/theme/app_radii.dart';
import 'package:manga_library/core/theme/app_typography.dart';
import 'package:manga_library/core/utils/date_formatter.dart';
import 'package:manga_library/domain/entities/library_entry.dart';
import 'package:manga_library/domain/entities/manga.dart';
import 'package:manga_library/domain/entities/reading_status.dart';
import 'package:manga_library/domain/repositories/manga_repository.dart';
import 'package:manga_library/presentation/controllers/library_controller.dart';
import 'package:manga_library/presentation/widgets/editorial_section_header.dart';
import 'package:manga_library/presentation/widgets/manga_cover.dart';
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
    if (_manga != null &&
        _manga!.synopsis != null &&
        _manga!.synopsis!.isNotEmpty) {
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

  void _showAddDialog(
    BuildContext context,
    LibraryController libraryController,
  ) {
    ReadingStatus selectedStatus = ReadingStatus.reading;
    int initialOwnedVolumes = 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.nightSurface : AppColors.paperSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).viewInsets.bottom + 28,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'AGGIUNGI AL CATALOGO',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                      ),
                      const Text(
                        '登録',
                        style: TextStyle(fontSize: 10, letterSpacing: 1.0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 1,
                    color: isDark
                        ? AppColors.nightBorder
                        : AppColors.paperBorder,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'STATO INIZIALE DI LETTURA:',
                    style: AppTypography.volumeMono(
                      isDark: isDark,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: ReadingStatus.values.map((status) {
                      final isSelected = selectedStatus == status;
                      return InkWell(
                        onTap: () =>
                            setModalState(() => selectedStatus = status),
                        borderRadius: AppRadii.brXs,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? status.color.withValues(
                                    alpha: isDark ? 0.25 : 0.12,
                                  )
                                : (isDark
                                      ? AppColors.nightSurfaceVariant
                                      : AppColors.paperSurfaceVariant),
                            borderRadius: AppRadii.brXs,
                            border: Border.all(
                              color: isSelected
                                  ? status.color
                                  : (isDark
                                        ? AppColors.nightBorder
                                        : AppColors.paperBorder),
                              width: isSelected ? 1.4 : 1.0,
                            ),
                          ),
                          child: Text(
                            status.label.toUpperCase(),
                            style: AppTypography.volumeMono(
                              isDark: isDark,
                              fontSize: 10,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isSelected ? status.color : null,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'VOLUMI FISICI POSSEDUTI:',
                            style: AppTypography.volumeMono(
                              isDark: isDark,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            _manga?.totalVolumes != null &&
                                    _manga!.totalVolumes! > 0
                                ? 'Totale serie: ${_manga!.totalVolumes} volumi'
                                : 'Totale non specificato',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(fontSize: 10),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_rounded, size: 18),
                            onPressed: initialOwnedVolumes > 0
                                ? () =>
                                      setModalState(() => initialOwnedVolumes--)
                                : null,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.nightSurfaceVariant
                                  : AppColors.paperSurfaceVariant,
                              borderRadius: AppRadii.brXs,
                              border: Border.all(
                                color: isDark
                                    ? AppColors.nightBorder
                                    : AppColors.paperBorder,
                              ),
                            ),
                            child: Text(
                              '$initialOwnedVolumes',
                              style: AppTypography.volumeMono(
                                isDark: isDark,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_rounded, size: 18),
                            onPressed:
                                (_manga?.totalVolumes != null &&
                                    _manga!.totalVolumes! > 0 &&
                                    initialOwnedVolumes >=
                                        _manga!.totalVolumes!)
                                ? null
                                : () => setModalState(
                                    () => initialOwnedVolumes++,
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  ElevatedButton(
                    onPressed: () async {
                      final newEntry = LibraryEntry.validated(
                        mangaId: widget.mangaId,
                        title: _manga?.title ?? 'Manga #${widget.mangaId}',
                        coverUrl: _manga?.bestCoverUrl ?? '',
                        status: selectedStatus,
                        currentChapter: 0,
                        totalChapters: _manga?.totalChapters,
                        ownedVolumes: initialOwnedVolumes,
                        totalVolumes: _manga?.totalVolumes,
                        genres: _manga?.genres ?? [],
                        authors: _manga?.authors ?? [],
                      );
                      final result = await libraryController.addOrUpdateEntry(
                        newEntry,
                      );
                      if (!context.mounted) return;
                      Navigator.of(bottomSheetContext).pop();

                      final message = result == AddEntryResult.alreadyInLibrary
                          ? 'Volume già presente: scheda catalogo aggiornata a "${selectedStatus.label}"'
                          : 'Volume aggiunto a "${selectedStatus.label}"';
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(message)));
                    },
                    child: const Text('CONFERMA E AGGIUNGI'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditVolumesDialog(
    BuildContext context,
    LibraryController libraryController,
    LibraryEntry entry,
  ) {
    final ownedCtrl = TextEditingController(text: '${entry.ownedVolumes}');
    final totalCtrl = TextEditingController(
      text: entry.totalVolumes != null ? '${entry.totalVolumes}' : '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Gestione Volumi Fisici'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ownedCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Volumi posseduti / acquistati',
                  hintText: 'Es. 5',
                  prefixIcon: Icon(
                    Icons.collections_bookmark_rounded,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: totalCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Totale volumi dell\'opera',
                  hintText: 'Es. 34 (opzionale)',
                  prefixIcon: Icon(Icons.library_books_rounded, size: 18),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () {
                final parsedOwned =
                    int.tryParse(ownedCtrl.text.trim()) ?? entry.ownedVolumes;
                final parsedTotal = int.tryParse(totalCtrl.text.trim());
                final targetTotal = parsedTotal != null && parsedTotal > 0
                    ? parsedTotal
                    : entry.totalVolumes;
                int safeOwned = parsedOwned < 0 ? 0 : parsedOwned;
                if (targetTotal != null &&
                    targetTotal > 0 &&
                    safeOwned > targetTotal) {
                  safeOwned = targetTotal;
                }

                libraryController.updateVolumes(
                  widget.mangaId,
                  safeOwned,
                  totalVolumes: targetTotal,
                );
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Volumi aggiornati con successo'),
                  ),
                );
              },
              child: const Text('Salva'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(
    BuildContext context,
    LibraryController libraryController,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Rimuovi dal catalogo'),
          content: const Text(
            'Sei sicuro di voler rimuovere questo manga dalla tua libreria personale?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.editorialRed,
              ),
              onPressed: () {
                libraryController.removeEntry(widget.mangaId);
                Navigator.of(dialogContext).pop();
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
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
    final isDark = theme.brightness == Brightness.dark;
    final libraryController = context.watch<LibraryController>();
    final entry = libraryController.getEntry(widget.mangaId);
    final bool isInLibrary = entry != null;

    final title = _manga?.title ?? entry?.title ?? 'Dettaglio Manga';
    final coverUrl = _manga?.bestCoverUrl ?? entry?.coverUrl ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SCHEDA CATALOGO',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              (isInLibrary && entry.isFavorite)
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: (isInLibrary && entry.isFavorite)
                  ? AppColors.editorialRed
                  : null,
              size: 22,
            ),
            tooltip: (isInLibrary && entry.isFavorite)
                ? 'Rimuovi dai preferiti'
                : 'Aggiungi ai preferiti',
            onPressed: () async {
              if (isInLibrary) {
                final willBeFavorite = !entry.isFavorite;
                await libraryController.toggleFavorite(widget.mangaId);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      willBeFavorite
                          ? 'Aggiunto ai preferiti'
                          : 'Rimosso dai preferiti',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else {
                final newEntry = LibraryEntry.validated(
                  mangaId: widget.mangaId,
                  title: _manga?.title ?? 'Manga #${widget.mangaId}',
                  coverUrl: _manga?.bestCoverUrl ?? '',
                  status: ReadingStatus.reading,
                  currentChapter: 0,
                  totalChapters: _manga?.totalChapters,
                  ownedVolumes: 0,
                  totalVolumes: _manga?.totalVolumes,
                  genres: _manga?.genres ?? [],
                  authors: _manga?.authors ?? [],
                  isFavorite: true,
                );
                await libraryController.addOrUpdateEntry(newEntry);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Manga aggiunto alla libreria e nei preferiti!',
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PRESENTAZIONE EDITORIALE ASIMMETRICA: COPERTINA + TITOLO + AUTORE
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Copertina fisica volume
                SizedBox(
                  width: 125,
                  child: MangaCover(
                    coverUrl: coverUrl,
                    title: title,
                    heroTag: 'cover-${widget.mangaId}',
                    showSpineEffect: true,
                  ),
                ),

                const SizedBox(width: 16),

                // Testata del volume
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isInLibrary) ...[
                        StatusBadge(status: entry.status),
                        const SizedBox(height: 8),
                      ],

                      // Titolo Principale
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),

                      // Titolo Originale Giapponese
                      if (_manga?.titleJapanese != null &&
                          _manga!.titleJapanese!.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          _manga!.titleJapanese!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            letterSpacing: 0.5,
                            color: isDark
                                ? AppColors.nightInkSecondary
                                : AppColors.inkSecondary,
                          ),
                        ),
                      ],

                      const SizedBox(height: 8),

                      // Autore
                      Text(
                        'AUTORE: ${_manga?.authorDisplay ?? (entry != null && entry.authors.isNotEmpty ? entry.authors.join(', ') : 'Sconosciuto')}'
                            .toUpperCase(),
                        style: AppTypography.volumeMono(
                          isDark: isDark,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.editorialRed,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Valutazione punteggio MAL
                      if (_manga?.score != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.nightSurfaceVariant
                                : AppColors.paperSurfaceVariant,
                            borderRadius: AppRadii.brXs,
                            border: Border.all(
                              color: isDark
                                  ? AppColors.nightBorder
                                  : AppColors.paperBorder,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 14,
                                color: AppColors.paperGold,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_manga!.score!.toStringAsFixed(2)} MAL',
                                style: AppTypography.volumeMono(
                                  isDark: isDark,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // MATRICE METADATI EDITORIALI (4 Caselle)
            Container(
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
                  _buildMetadataCell(
                    context,
                    label: 'PUBBLICAZIONE',
                    value:
                        _manga?.publicationStatusItalian.toUpperCase() ??
                        'IN CORSO',
                    isDark: isDark,
                  ),
                  _buildCellDivider(isDark),
                  _buildMetadataCell(
                    context,
                    label: 'CAPITOLI',
                    value:
                        _manga?.totalChapters != null &&
                            _manga!.totalChapters! > 0
                        ? '${_manga!.totalChapters} CAP'
                        : 'IN CORSO',
                    isDark: isDark,
                  ),
                  _buildCellDivider(isDark),
                  _buildMetadataCell(
                    context,
                    label: 'VOLUMI',
                    value:
                        (_manga?.totalVolumes != null &&
                                _manga!.totalVolumes! > 0) ||
                            (entry?.totalVolumes != null &&
                                entry!.totalVolumes! > 0)
                        ? '${entry?.totalVolumes ?? _manga?.totalVolumes} VOL'
                        : 'N/D',
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // SEZIONE 01: SCHEDA LETTURA E PROGRESSO (Se presente in Libreria)
            if (isInLibrary) ...[
              const EditorialSectionHeader(
                index: '01',
                title: 'LA TUA LETTURA',
                subtitle: 'Avanzamento capitoli e volumi collezionati',
              ),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.nightSurface
                      : AppColors.paperSurface,
                  borderRadius: AppRadii.brSm,
                  border: Border.all(
                    color: isDark
                        ? AppColors.nightBorder
                        : AppColors.paperBorder,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selettore Rapido Stato
                    Text(
                      'CAMBIA STATO DI LETTURA:',
                      style: AppTypography.volumeMono(
                        isDark: isDark,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ReadingStatus.values.map((status) {
                          final isSelected = entry.status == status;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: InkWell(
                              onTap: () => libraryController.updateStatus(
                                widget.mangaId,
                                status,
                              ),
                              borderRadius: AppRadii.brXs,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? status.color.withValues(
                                          alpha: isDark ? 0.25 : 0.12,
                                        )
                                      : (isDark
                                            ? AppColors.nightSurfaceVariant
                                            : AppColors.paperSurfaceVariant),
                                  borderRadius: AppRadii.brXs,
                                  border: Border.all(
                                    color: isSelected
                                        ? status.color
                                        : (isDark
                                              ? AppColors.nightBorder
                                              : AppColors.paperBorder),
                                    width: isSelected ? 1.4 : 1.0,
                                  ),
                                ),
                                child: Text(
                                  status.label.toUpperCase(),
                                  style: AppTypography.volumeMono(
                                    isDark: isDark,
                                    fontSize: 9,
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: isSelected ? status.color : null,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Tracker Progresso Capitolo
                    Text(
                      'PROGRESSO CAPITOLI:',
                      style: AppTypography.volumeMono(
                        isDark: isDark,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ProgressStepper(
                      currentChapter: entry.currentChapter,
                      totalChapters:
                          entry.totalChapters ?? _manga?.totalChapters,
                      isCompleted: entry.status == ReadingStatus.completed,
                      onProgressChanged: (newChapter) {
                        libraryController.updateProgress(
                          widget.mangaId,
                          newChapter,
                        );
                      },
                      onMarkCompleted: () {
                        libraryController.updateStatus(
                          widget.mangaId,
                          ReadingStatus.completed,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Manga segnato come completato!'),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 18),

                    // Tracker Collezione Volumi Fisici
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'COLLEZIONE VOLUMI FISICI:',
                          style: AppTypography.volumeMono(
                            isDark: isDark,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextButton(
                          onPressed: () => _showEditVolumesDialog(
                            context,
                            libraryController,
                            entry,
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'MODIFICA',
                            style: AppTypography.volumeMono(
                              isDark: isDark,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.editorialRed,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.nightSurfaceVariant
                            : AppColors.paperSurfaceVariant,
                        borderRadius: AppRadii.brXs,
                        border: Border.all(
                          color: isDark
                              ? AppColors.nightBorder
                              : AppColors.paperBorder,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_rounded,
                                      size: 18,
                                    ),
                                    tooltip: 'Rimuovi volume',
                                    onPressed: entry.ownedVolumes > 0
                                        ? () => libraryController
                                              .decrementOwnedVolume(
                                                widget.mangaId,
                                              )
                                        : null,
                                  ),
                                  InkWell(
                                    onTap: () => _showEditVolumesDialog(
                                      context,
                                      libraryController,
                                      entry,
                                    ),
                                    borderRadius: AppRadii.brXs,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppColors.nightSurface
                                            : AppColors.paperSurface,
                                        borderRadius: AppRadii.brXs,
                                        border: Border.all(
                                          color: isDark
                                              ? AppColors.nightBorder
                                              : AppColors.paperBorder,
                                        ),
                                      ),
                                      child: Text(
                                        'VOL. ${entry.ownedVolumes}${entry.totalVolumes != null && entry.totalVolumes! > 0 ? ' / ${entry.totalVolumes}' : ''}',
                                        style: AppTypography.volumeMono(
                                          isDark: isDark,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.add_rounded,
                                      size: 18,
                                    ),
                                    tooltip: 'Aggiungi volume',
                                    color: AppColors.editorialRed,
                                    onPressed:
                                        (entry.totalVolumes != null &&
                                            entry.totalVolumes! > 0 &&
                                            entry.ownedVolumes >=
                                                entry.totalVolumes!)
                                        ? null
                                        : () => libraryController
                                              .incrementOwnedVolume(
                                                widget.mangaId,
                                              ),
                                  ),
                                ],
                              ),
                              if (entry.totalVolumes != null &&
                                  entry.totalVolumes! > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: entry.volumesToBuy == 0
                                        ? AppColors.forestGreen.withValues(
                                            alpha: 0.15,
                                          )
                                        : AppColors.editorialRed.withValues(
                                            alpha: 0.15,
                                          ),
                                    borderRadius: AppRadii.brXs,
                                    border: Border.all(
                                      color: entry.volumesToBuy == 0
                                          ? AppColors.forestGreen
                                          : AppColors.editorialRed,
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    entry.volumesToBuy == 0
                                        ? 'COMPLETA'
                                        : '-${entry.volumesToBuy} DA COMPRARE',
                                    style: AppTypography.volumeMono(
                                      isDark: isDark,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: entry.volumesToBuy == 0
                                          ? AppColors.forestGreen
                                          : AppColors.editorialRed,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (entry.totalVolumes != null &&
                              entry.totalVolumes! > 0) ...[
                            const SizedBox(height: 8),
                            Container(
                              height: 3,
                              color: isDark
                                  ? AppColors.nightSurface
                                  : AppColors.paperSurface,
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor:
                                    (entry.ownedVolumes / entry.totalVolumes!)
                                        .clamp(0.0, 1.0),
                                child: Container(
                                  color: entry.volumesToBuy == 0
                                      ? AppColors.forestGreen
                                      : AppColors.editorialRed,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Valutazione personale
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'LA TUA VALUTAZIONE:',
                          style: AppTypography.volumeMono(
                            isDark: isDark,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          entry.rating > 0
                              ? '${entry.rating} / 10'
                              : 'NON VALUTATO',
                          style: AppTypography.volumeMono(
                            isDark: isDark,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: entry.rating > 0
                                ? AppColors.paperGold
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    RatingStars(
                      rating: entry.rating,
                      iconSize: 24,
                      onRatingChanged: (newRating) {
                        libraryController.updateRating(
                          widget.mangaId,
                          newRating,
                        );
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Valutazione aggiornata: $newRating / 10',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 18),

                    // Note personali
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'NOTE EDITORIALI PERSONALI:',
                          style: AppTypography.volumeMono(
                            isDark: isDark,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (!_isEditingNotes)
                          TextButton(
                            onPressed: () {
                              _notesController.text = entry.notes;
                              setState(() => _isEditingNotes = true);
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'MODIFICA',
                              style: AppTypography.volumeMono(
                                isDark: isDark,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.editorialRed,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (_isEditingNotes) ...[
                      const SizedBox(height: 8),
                      TextField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText:
                              'Aggiungi una recensione o promemoria del volume...',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () =>
                                setState(() => _isEditingNotes = false),
                            child: const Text('Annulla'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              libraryController.updateNotes(
                                widget.mangaId,
                                _notesController.text.trim(),
                              );
                              setState(() => _isEditingNotes = false);
                              ScaffoldMessenger.of(
                                context,
                              ).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Note personali salvate'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            child: const Text('SALVA'),
                          ),
                        ],
                      ),
                    ] else if (entry.notes.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.nightSurfaceVariant
                              : AppColors.paperSurfaceVariant,
                          borderRadius: AppRadii.brXs,
                          border: Border(
                            left: BorderSide(
                              color: AppColors.editorialRed,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Text(
                          entry.notes,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 4),
                      Text(
                        'Nessuna nota personale registrata.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],

                    const SizedBox(height: 14),
                    Container(
                      height: 1,
                      color: isDark
                          ? AppColors.nightBorder
                          : AppColors.paperBorder,
                    ),
                    const SizedBox(height: 10),

                    // Date & Rimuovi
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'REGISTRATO: ${DateFormatter.formatShortDate(entry.addedAt)}'
                              .toUpperCase(),
                          style: AppTypography.volumeMono(
                            isDark: isDark,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () =>
                              _confirmDelete(context, libraryController),
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 14,
                            color: AppColors.editorialRed,
                          ),
                          label: Text(
                            'RIMUOVI',
                            style: AppTypography.volumeMono(
                              isDark: isDark,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.editorialRed,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ] else ...[
              // Pulsante grande di aggiunta
              ElevatedButton.icon(
                onPressed: () => _showAddDialog(context, libraryController),
                icon: const Icon(Icons.bookmark_add_rounded, size: 18),
                label: const Text('AGGIUNGI ALLA TUA LIBRERIA'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // SEZIONE GENERI E TEMATICHE
            if (_manga?.genres != null && _manga!.genres.isNotEmpty) ...[
              EditorialSectionHeader(
                index: isInLibrary ? '02' : '01',
                title: 'GENERI E TEMATICHE',
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _manga!.genres.map((genre) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.nightSurface
                          : AppColors.paperSurface,
                      borderRadius: AppRadii.brXs,
                      border: Border.all(
                        color: isDark
                            ? AppColors.nightBorder
                            : AppColors.paperBorder,
                      ),
                    ),
                    child: Text(
                      genre.toUpperCase(),
                      style: AppTypography.volumeMono(
                        isDark: isDark,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.nightInk : AppColors.inkBlack,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // SEZIONE TRAMA DELL'OPERA (Sinossi in stile retro copertina)
            EditorialSectionHeader(
              index: isInLibrary
                  ? (_manga?.genres != null && _manga!.genres.isNotEmpty
                        ? '03'
                        : '02')
                  : (_manga?.genres != null && _manga!.genres.isNotEmpty
                        ? '02'
                        : '01'),
              title: 'TRAMA DELL\'OPERA',
              subtitle: 'Sinossi editoriale',
            ),
            const SizedBox(height: 8),

            if (_isLoadingDetails) ...[
              const SkeletonLoader(width: double.infinity, height: 14),
              const SizedBox(height: 6),
              const SkeletonLoader(width: double.infinity, height: 14),
              const SizedBox(height: 6),
              const SkeletonLoader(width: 220, height: 14),
            ] else if (_manga?.synopsis != null &&
                _manga!.synopsis!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.nightSurface
                      : AppColors.paperSurface,
                  borderRadius: AppRadii.brSm,
                  border: Border.all(
                    color: isDark
                        ? AppColors.nightBorder
                        : AppColors.paperBorder,
                    width: 1,
                  ),
                ),
                child: Text(
                  _manga!.synopsis!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                    fontSize: 13,
                  ),
                ),
              ),
            ] else ...[
              Text(
                'Sinossi e descrizione non disponibili per questo volume.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: isDark ? AppColors.nightInkMuted : AppColors.inkMuted,
                ),
              ),
            ],

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataCell(
    BuildContext context, {
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.volumeMono(
                isDark: isDark,
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.nightInkMuted : AppColors.inkMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.volumeMono(
                isDark: isDark,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.nightInk : AppColors.inkBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCellDivider(bool isDark) {
    return Container(
      width: 1,
      height: 32,
      color: isDark ? AppColors.nightBorder : AppColors.paperBorder,
    );
  }
}
