import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class StaleBanner extends StatelessWidget {
  final VoidCallback? onRefresh;

  const StaleBanner({super.key, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.paperGold.withValues(alpha: isDark ? 0.18 : 0.12),
        border: Border(
          bottom: BorderSide(
            color: AppColors.paperGold.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.offline_bolt_outlined, size: 14, color: AppColors.paperGold),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'CATALOGO OFFLINE: STAI CONSULTANDO I DATI IN CACHE',
              style: AppTypography.volumeMono(
                isDark: isDark,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.paperGold,
              ),
            ),
          ),
          if (onRefresh != null) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: onRefresh,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  'RICARICA',
                  style: AppTypography.volumeMono(
                    isDark: isDark,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: AppColors.paperGold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
