import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ProgressStepper extends StatelessWidget {
  final int currentChapter;
  final int? totalChapters;
  final ValueChanged<int> onProgressChanged;
  final VoidCallback? onMarkCompleted;
  final bool isCompleted;

  const ProgressStepper({
    super.key,
    required this.currentChapter,
    this.totalChapters,
    required this.onProgressChanged,
    this.onMarkCompleted,
    this.isCompleted = false,
  });

  void _showDirectInputDialog(BuildContext context) {
    final controller = TextEditingController(text: currentChapter.toString());

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Modifica Capitolo'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Numero capitolo',
              hintText: 'Inserisci il capitolo corrente',
              suffixText: totalChapters != null && totalChapters! > 0 ? '/ $totalChapters' : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () {
                final parsed = int.tryParse(controller.text.trim());
                if (parsed != null && parsed >= 0) {
                  int target = parsed;
                  if (totalChapters != null && totalChapters! > 0 && target > totalChapters!) {
                    target = totalChapters!;
                  }
                  onProgressChanged(target);
                }
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Salva'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasTotal = totalChapters != null && totalChapters! > 0;
    final isAtMax = hasTotal && currentChapter >= totalChapters!;
    final showCompletionPrompt = hasTotal && isAtMax && !isCompleted && onMarkCompleted != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Pulsante decremento
              IconButton.filledTonal(
                onPressed: currentChapter > 0 ? () => onProgressChanged(currentChapter - 1) : null,
                icon: const Icon(Icons.remove_rounded),
                tooltip: 'Capitolo precedente',
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

              // Contatore capitolo cliccabile per inserimento diretto
              InkWell(
                onTap: () => _showDirectInputDialog(context),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      Text(
                        'Capitolo $currentChapter',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasTotal ? 'su $totalChapters totali' : 'Totale sconosciuto',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),

              // Pulsante incremento
              IconButton.filledTonal(
                onPressed: (!isAtMax) ? () => onProgressChanged(currentChapter + 1) : null,
                icon: const Icon(Icons.add_rounded),
                tooltip: 'Capitolo successivo',
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),

        // Barra di progresso se il totale è noto
        if (hasTotal) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (currentChapter / totalChapters!).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.statusReading),
            ),
          ),
        ],

        // Suggerimento di completamento quando si raggiunge l'ultimo capitolo
        if (showCompletionPrompt) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onMarkCompleted,
            icon: const Icon(Icons.check_circle_outline_rounded, color: AppColors.statusCompleted),
            label: const Text(
              'Hai finito i capitoli! Segna come completato',
              style: TextStyle(color: AppColors.statusCompleted, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.statusCompleted, width: 1.2),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ],
    );
  }
}
