import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';

class MangaCover extends StatelessWidget {
  final String coverUrl;
  final String? title;
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
    this.title,
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

    Widget imageWidget;
    final cleanUrl = coverUrl.trim();

    if (cleanUrl.isEmpty) {
      imageWidget = _buildPlaceholder(context, isDark);
    } else if (cleanUrl.startsWith('assets/')) {
      imageWidget = Image.asset(
        cleanUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildPlaceholder(context, isDark),
      );
    } else {
      imageWidget = Image.network(
        cleanUrl,
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
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? AppColors.nightInkMuted : AppColors.inkMuted,
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

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
              imageWidget,

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
                          Colors.black.withValues(alpha: 0.25),
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
    final displayTitle = title?.trim() ?? '';

    return Container(
      color: isDark
          ? AppColors.nightSurfaceVariant
          : AppColors.paperSurfaceVariant,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Timbro superiore
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.editorialRed.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: AppColors.editorialRed.withValues(alpha: 0.4),
                  width: 0.8,
                ),
              ),
              child: const Text(
                'MANGA',
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: AppColors.editorialRed,
                ),
              ),
            ),
          ),

          // Icona centrale o Titolo tipografico
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_stories_outlined,
                  size: 26,
                  color: isDark ? AppColors.nightInkMuted : AppColors.inkMuted,
                ),
                if (displayTitle.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    displayTitle,
                    maxLines: 3,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                      letterSpacing: 0.2,
                      color: isDark ? AppColors.nightInk : AppColors.inkBlack,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Timbro inferiore
          Text(
            'EDIZIONE UFFICIALE',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: isDark ? AppColors.nightInkMuted : AppColors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}
