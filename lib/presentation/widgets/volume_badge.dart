import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_typography.dart';

class VolumeBadge extends StatelessWidget {
  final String label;
  final bool isHighlight;

  const VolumeBadge({super.key, required this.label, this.isHighlight = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: isHighlight
            ? AppColors.editorialRed
            : (isDark
                  ? AppColors.nightSurfaceVariant
                  : AppColors.paperSurfaceVariant),
        borderRadius: AppRadii.brXs,
        border: Border.all(
          color: isHighlight
              ? AppColors.editorialRed
              : (isDark ? AppColors.nightBorder : AppColors.paperBorder),
          width: 0.8,
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.volumeMono(
          isDark: isDark,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: isHighlight
              ? Colors.white
              : (isDark ? AppColors.nightInk : AppColors.inkBlack),
        ),
      ),
    );
  }
}
