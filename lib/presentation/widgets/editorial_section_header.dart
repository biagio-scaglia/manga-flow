import 'package:flutter/material.dart';
import 'package:manga_library/core/theme/app_colors.dart';
import 'package:manga_library/core/theme/app_typography.dart';

class EditorialSectionHeader extends StatelessWidget {
  final String index; // Es. "01", "02"
  final String title; // Es. "CONTINUA LA LETTURA"
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  const EditorialSectionHeader({
    super.key,
    required this.index,
    required this.title,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Numero indice (es. "01 /")
              Text(
                '$index / ',
                style: AppTypography.sectionIndex(isDark: isDark),
              ),
              // Titolo editoriale in maiuscolo
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
            ),
          ],
          const SizedBox(height: 6),
          // Linea sottile divisoria editoriale
          Container(
            height: 1,
            color: isDark ? AppColors.nightBorder : AppColors.paperBorder,
          ),
        ],
      ),
    );
  }
}
