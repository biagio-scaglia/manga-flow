import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:manga_library/core/theme/app_colors.dart';
import 'package:manga_library/core/theme/app_radii.dart';
import 'package:manga_library/core/theme/app_typography.dart';
import 'package:manga_library/presentation/controllers/settings_controller.dart';

class TutorialStep {
  final String index;
  final String title;
  final String description;
  final IconData icon;

  const TutorialStep({
    required this.index,
    required this.title,
    required this.description,
    required this.icon,
  });
}

class TutorialDialog extends StatefulWidget {
  final VoidCallback onComplete;

  const TutorialDialog({super.key, required this.onComplete});

  static const List<TutorialStep> steps = [
    TutorialStep(
      index: '01',
      title: 'Benvenuto in MangaFlow',
      description: 'Il tuo catalogo editoriale personale di manga per tracciare letture, volumi fisici posseduti, voti e note in locale offline-first.',
      icon: Icons.menu_book_rounded,
    ),
    TutorialStep(
      index: '02',
      title: 'Esplora il Catalogo',
      description: 'Cerca tra migliaia di serie reali con dati ufficiali su autori, volumi totali, capitoli e trame complete.',
      icon: Icons.search_rounded,
    ),
    TutorialStep(
      index: '03',
      title: 'Organizza la Libreria',
      description: 'Segna i volumi che possiedi fisicamente, quelli da acquistare e tieni traccia del capitolo a cui sei arrivato.',
      icon: Icons.collections_bookmark_rounded,
    ),
    TutorialStep(
      index: '04',
      title: 'Statistiche Reali',
      description: 'Monitora l\'avanzamento della tua collezione, la media voto e la distribuzione dei tuoi generi preferiti.',
      icon: Icons.insights_rounded,
    ),
  ];

  @override
  State<TutorialDialog> createState() => _TutorialDialogState();
}

class _TutorialDialogState extends State<TutorialDialog> {
  int _currentStepIndex = 0;

  void _nextStep() {
    if (_currentStepIndex < TutorialDialog.steps.length - 1) {
      setState(() {
        _currentStepIndex++;
      });
    } else {
      _finish();
    }
  }

  void _finish() {
    context.read<SettingsController>().setTutorialCompleted(true);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final step = TutorialDialog.steps[_currentStepIndex];
    final isLastStep = _currentStepIndex == TutorialDialog.steps.length - 1;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.brSm,
        side: BorderSide(
          color: isDark ? AppColors.nightBorder : AppColors.paperBorder,
          width: 1,
        ),
      ),
      backgroundColor: isDark ? AppColors.nightSurface : AppColors.paperSurface,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Numero e timbro
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'GUIDA CATALOGO • ${step.index}',
                  style: AppTypography.sectionIndex(isDark: isDark),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.editorialRed.withValues(alpha: 0.12),
                    borderRadius: AppRadii.brXs,
                    border: Border.all(color: AppColors.editorialRed, width: 0.8),
                  ),
                  child: Text(
                    '${_currentStepIndex + 1} / ${TutorialDialog.steps.length}',
                    style: AppTypography.volumeMono(
                      isDark: isDark,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: AppColors.editorialRed,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 1,
              color: isDark ? AppColors.nightBorder : AppColors.paperBorder,
            ),
            const SizedBox(height: 20),

            // Icona del passaggio
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.editorialRed.withValues(alpha: isDark ? 0.18 : 0.08),
                borderRadius: AppRadii.brXs,
                border: Border.all(color: AppColors.editorialRed.withValues(alpha: 0.4)),
              ),
              child: Icon(step.icon, size: 26, color: AppColors.editorialRed),
            ),
            const SizedBox(height: 16),

            // Titolo
            Text(
              step.title.toUpperCase(),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 8),

            // Descrizione
            Text(
              step.description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.45,
                color: isDark ? AppColors.nightInkSecondary : AppColors.inkSecondary,
              ),
            ),
            const SizedBox(height: 20),

            // Indicatori a trattini
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(TutorialDialog.steps.length, (index) {
                final isActive = index == _currentStepIndex;
                return Container(
                  width: isActive ? 18 : 6,
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.editorialRed : (isDark ? AppColors.nightBorder : AppColors.paperBorder),
                    borderRadius: BorderRadius.circular(1),
                  ),
                );
              }),
            ),
            const SizedBox(height: 22),

            // Pulsanti di navigazione
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!isLastStep)
                  TextButton(
                    onPressed: _finish,
                    child: Text(
                      'SALTA',
                      style: AppTypography.volumeMono(
                        isDark: isDark,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),

                ElevatedButton(
                  onPressed: _nextStep,
                  child: Text(
                    isLastStep ? 'INIZIA CATALOGO' : 'AVANTI',
                    style: AppTypography.volumeMono(
                      isDark: isDark,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
