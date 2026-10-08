import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_typography.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? japaneseSub;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.japaneseSub,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.nightSurface : AppColors.paperSurface,
            borderRadius: AppRadii.brSm,
            border: Border.all(
              color: isDark ? AppColors.nightBorder : AppColors.paperBorder,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.editorialRed.withValues(
                    alpha: isDark ? 0.15 : 0.08,
                  ),
                  borderRadius: AppRadii.brXs,
                  border: Border.all(
                    color: AppColors.editorialRed.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(icon, size: 26, color: AppColors.editorialRed),
              ),
              const SizedBox(height: 16),
              Text(
                title.toUpperCase(),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              if (japaneseSub != null) ...[
                const SizedBox(height: 2),
                Text(
                  japaneseSub!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.nightInkSecondary
                      : AppColors.inkSecondary,
                  height: 1.4,
                ),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: onAction,
                  child: Text(
                    actionLabel!.toUpperCase(),
                    style: AppTypography.volumeMono(
                      isDark: isDark,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
