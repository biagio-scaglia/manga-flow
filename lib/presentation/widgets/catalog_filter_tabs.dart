import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/reading_status.dart';

class CatalogFilterTabs extends StatelessWidget {
  final ReadingStatus? selectedStatus;
  final bool showFavoritesOnly;
  final int totalCount;
  final Map<ReadingStatus, int> statusCounts;
  final ValueChanged<ReadingStatus?> onStatusSelected;
  final VoidCallback onToggleFavorites;

  const CatalogFilterTabs({
    super.key,
    required this.selectedStatus,
    required this.showFavoritesOnly,
    required this.totalCount,
    required this.statusCounts,
    required this.onStatusSelected,
    required this.onToggleFavorites,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAllSelected = selectedStatus == null && !showFavoritesOnly;

    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // Tutti
          _buildFilterItem(
            context,
            label: 'TUTTI ($totalCount)',
            isSelected: isAllSelected,
            isDark: isDark,
            onTap: () {
              onStatusSelected(null);
            },
          ),
          const SizedBox(width: 6),

          // Preferiti
          _buildFilterItem(
            context,
            label: 'PREFERITI',
            isSelected: showFavoritesOnly,
            isDark: isDark,
            accentColor: AppColors.statusFavorite,
            onTap: onToggleFavorites,
          ),
          const SizedBox(width: 6),

          // Reading Statuses
          ...ReadingStatus.values.map((status) {
            final isSelected = selectedStatus == status && !showFavoritesOnly;
            final count = statusCounts[status] ?? 0;

            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _buildFilterItem(
                context,
                label: '${status.label.toUpperCase()} ($count)',
                isSelected: isSelected,
                isDark: isDark,
                accentColor: status.color,
                onTap: () {
                  onStatusSelected(isSelected ? null : status);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterItem(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required bool isDark,
    Color? accentColor,
    required VoidCallback onTap,
  }) {
    final effectiveAccent = accentColor ?? AppColors.editorialRed;
    final borderColor = isSelected
        ? effectiveAccent
        : (isDark ? AppColors.nightBorder : AppColors.paperBorder);
    final bgColor = isSelected
        ? effectiveAccent.withValues(alpha: isDark ? 0.2 : 0.1)
        : (isDark ? AppColors.nightSurface : AppColors.paperSurface);
    final textColor = isSelected
        ? effectiveAccent
        : (isDark ? AppColors.nightInkSecondary : AppColors.inkSecondary);

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.brXs,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadii.brXs,
          border: Border.all(color: borderColor, width: isSelected ? 1.4 : 1.0),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.volumeMono(
            isDark: isDark,
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
