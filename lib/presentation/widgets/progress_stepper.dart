import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_typography.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasTotal = totalChapters != null && totalChapters! > 0;
    final isAtMax = hasTotal && currentChapter >= totalChapters!;
    final showCompletionPrompt = hasTotal && isAtMax && !isCompleted && onMarkCompleted != null;

    final progressFraction = hasTotal
        ? (currentChapter / totalChapters!).clamp(0.0, 1.0)
        : 0.0;
    final progressPct = hasTotal ? '${(progressFraction * 100).toInt()}%' : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.nightSurface : AppColors.paperSurface,
            borderRadius: AppRadii.brSm,
            border: Border.all(
              color: isDark ? AppColors.nightBorder : AppColors.paperBorder,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Pulsante decremento
              IconButton(
                onPressed: currentChapter > 0 ? () => onProgressChanged(currentChapter - 1) : null,
                icon: const Icon(Icons.remove_rounded),
                tooltip: 'Capitolo precedente',
                style: IconButton.styleFrom(
                  side: BorderSide(
                    color: isDark ? AppColors.nightBorder : AppColors.paperBorder,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: AppRadii.brXs),
                  padding: const EdgeInsets.all(8),
                ),
              ),

              // Contatore capitolo cliccabile
              InkWell(
                onTap: () => _showDirectInputDialog(context),
                borderRadius: AppRadii.brXs,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Column(
                    children: [
                      Text(
                        'CAPITOLO $currentChapter',
                        style: AppTypography.volumeMono(
                          isDark: isDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.editorialRed,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasTotal ? 'su $totalChapters totali' : 'Totale in corso / N/D',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),

              // Pulsante incremento
              IconButton(
                onPressed: (!isAtMax) ? () => onProgressChanged(currentChapter + 1) : null,
                icon: const Icon(Icons.add_rounded),
                tooltip: 'Capitolo successivo',
                color: AppColors.editorialRed,
                style: IconButton.styleFrom(
                  side: BorderSide(
                    color: isDark ? AppColors.nightBorder : AppColors.paperBorder,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: AppRadii.brXs),
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          ),
        ),

        // Linea di avanzamento sottile
        if (hasTotal) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 3,
                  color: isDark ? AppColors.nightSurfaceVariant : AppColors.paperSurfaceVariant,
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: progressFraction,
                    child: Container(color: AppColors.editorialRed),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                progressPct,
                style: AppTypography.volumeMono(
                  isDark: isDark,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.editorialRed,
                ),
              ),
            ],
          ),
        ],

        // Suggerimento di completamento quando si raggiunge l'ultimo capitolo
        if (showCompletionPrompt) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onMarkCompleted,
            icon: const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppColors.forestGreen),
            label: const Text(
              'OPERA CONCLUSA: SEGNA COME COMPLETATO',
              style: TextStyle(color: AppColors.forestGreen, fontSize: 11, fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.forestGreen, width: 1),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ],
      ],
    );
  }
}
