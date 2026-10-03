import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../controllers/settings_controller.dart';

class TutorialStep {
  final String title;
  final String description;
  final IconData icon;

  const TutorialStep({
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
      title: 'Benvenuto in MangaFlow',
      description: 'La tua libreria personale di manga per tracciare letture, capitoli, voti e note in modo semplice e offline-first.',
      icon: Icons.menu_book_rounded,
    ),
    TutorialStep(
      title: 'Cerca Nuovi Manga',
      description: 'Usa la scheda Cerca per esplorare migliaia di titoli reali, leggere le trame e visualizzare i dettagli completi.',
      icon: Icons.search_rounded,
    ),
    TutorialStep(
      title: 'Organizza la Libreria',
      description: 'Aggiungi manga alla tua collezione, seleziona lo stato (In lettura, Da leggere, Completato) e aggiorna i capitoli letti.',
      icon: Icons.collections_bookmark_rounded,
    ),
    TutorialStep(
      title: 'Statistiche in Tempo Reale',
      description: 'Monitora i tuoi progressi, i capitoli letti e la distribuzione dei tuoi generi preferiti senza dati fittizi.',
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
    final step = TutorialDialog.steps[_currentStepIndex];
    final isLastStep = _currentStepIndex == TutorialDialog.steps.length - 1;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icona del passaggio
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(step.icon, size: 32, color: AppColors.primary),
            ),
            const SizedBox(height: 20),

            // Titolo
            Text(
              step.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),

            // Descrizione
            Text(
              step.description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 24),

            // Indicatori a punti dei passaggi
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(TutorialDialog.steps.length, (index) {
                final isActive = index == _currentStepIndex;
                return Container(
                  width: isActive ? 20 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : theme.dividerColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // Pulsanti di navigazione
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!isLastStep)
                  TextButton(
                    onPressed: _finish,
                    child: const Text('Salta'),
                  )
                else
                  const SizedBox.shrink(),

                ElevatedButton(
                  onPressed: _nextStep,
                  child: Text(isLastStep ? 'Inizia' : 'Avanti'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
