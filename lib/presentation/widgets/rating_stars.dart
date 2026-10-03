import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class RatingStars extends StatelessWidget {
  final int rating; // 0 to 10
  final ValueChanged<int>? onRatingChanged;
  final double iconSize;

  const RatingStars({
    super.key,
    required this.rating,
    this.onRatingChanged,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    final bool isInteractive = onRatingChanged != null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = (index + 1) * 2;
        final isFull = rating >= starValue;
        final isHalf = rating == starValue - 1;

        IconData icon;
        Color color;

        if (isFull) {
          icon = Icons.star_rounded;
          color = AppColors.warning;
        } else if (isHalf) {
          icon = Icons.star_half_rounded;
          color = AppColors.warning;
        } else {
          icon = Icons.star_outline_rounded;
          color = Colors.grey.withValues(alpha: 0.4);
        }

        final starWidget = Icon(icon, size: iconSize, color: color);

        if (!isInteractive) {
          return starWidget;
        }

        return GestureDetector(
          onTap: () {
            if (rating == starValue) {
              // Se tocca di nuovo la stessa stella piena, imposta a mezza stella o rimuovi
              onRatingChanged?.call(starValue - 1);
            } else if (rating == starValue - 1) {
              onRatingChanged?.call(0);
            } else {
              onRatingChanged?.call(starValue);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: starWidget,
          ),
        );
      }),
    );
  }
}
