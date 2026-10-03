import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';

class MangaCover extends StatelessWidget {
  final String coverUrl;
  final double? width;
  final double? height;
  final double aspectRatio;
  final String heroTag;
  final Widget? badge;
  final bool showSpineEffect;
  final VoidCallback? onTap;

  const MangaCover({
    super.key,
    required this.coverUrl,
    this.width,
    this.height,
    this.aspectRatio = 1 / 1.45,
    required this.heroTag,
    this.badge,
    this.showSpineEffect = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.nightBorder : AppColors.paperBorder;

    Widget imageContent = AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.nightSurfaceVariant
              : AppColors.paperSurfaceVariant,
          borderRadius: AppRadii.brXs,
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 4,
              offset: const Offset(1, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: AppRadii.brXs,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (coverUrl.isNotEmpty)
                Image.network(
                  coverUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildPlaceholder(context, isDark),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: isDark
                          ? AppColors.nightSurfaceVariant
                          : AppColors.paperSurfaceVariant,
                      child: Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark
                                  ? AppColors.nightInkMuted
                                  : AppColors.inkMuted,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                )
              else
                _buildPlaceholder(context, isDark),

              // Effetto costina/piega volume fisico a sinistra (sottile sfumatura verticale)
              if (showSpineEffect)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 6,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.22),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

              // Badge sovrapposto se presente
              if (badge != null) Positioned(top: 4, left: 4, child: badge!),
            ],
          ),
        ),
      ),
    );

    if (heroTag.isNotEmpty) {
      imageContent = Hero(tag: heroTag, child: imageContent);
    }

    if (width != null || height != null) {
      imageContent = SizedBox(
        width: width,
        height: height,
        child: imageContent,
      );
    }

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: AppRadii.brXs,
        child: imageContent,
      );
    }

    return imageContent;
  }

  Widget _buildPlaceholder(BuildContext context, bool isDark) {
    return Container(
      color: isDark
          ? AppColors.nightSurfaceVariant
          : AppColors.paperSurfaceVariant,
      padding: const EdgeInsets.all(8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 24,
              color: isDark ? AppColors.nightInkMuted : AppColors.inkMuted,
            ),
            const SizedBox(height: 4),
            Text(
              'COPERTINA\nNON DISPONIBILE',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: isDark ? AppColors.nightInkMuted : AppColors.inkMuted,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
