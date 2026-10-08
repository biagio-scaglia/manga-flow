import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static TextTheme textTheme(bool isDark) {
    final textColor = isDark ? AppColors.nightInk : AppColors.inkBlack;
    final textSecondary = isDark
        ? AppColors.nightInkSecondary
        : AppColors.inkSecondary;
    final textMuted = isDark ? AppColors.nightInkMuted : AppColors.inkMuted;

    return TextTheme(
      displayLarge: GoogleFonts.spaceGrotesk(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: -0.6,
        height: 1.15,
      ),
      displayMedium: GoogleFonts.spaceGrotesk(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: -0.4,
        height: 1.2,
      ),
      displaySmall: GoogleFonts.spaceGrotesk(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: -0.2,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: 0.2,
      ),
      headlineSmall: GoogleFonts.spaceGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: 0.4,
      ),
      titleLarge: GoogleFonts.spaceGrotesk(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: 0.3,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.3,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textSecondary,
        height: 1.3,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textColor,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.45,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: textMuted,
        height: 1.35,
      ),
      labelLarge: GoogleFonts.spaceGrotesk(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: 0.5,
      ),
      labelMedium: GoogleFonts.spaceGrotesk(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: textSecondary,
        letterSpacing: 0.6,
      ),
      labelSmall: GoogleFonts.spaceGrotesk(
        fontSize: 9,
        fontWeight: FontWeight.w600,
        color: textMuted,
        letterSpacing: 0.8,
      ),
    );
  }

  // Stile speciale per codici volume e metadati (es. "VOL. 01", "CAP. 83")
  static TextStyle volumeMono({
    required bool isDark,
    double fontSize = 11,
    FontWeight fontWeight = FontWeight.w700,
    Color? color,
  }) {
    return GoogleFonts.spaceMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: 0.6,
      color:
          color ??
          (isDark ? AppColors.nightInkSecondary : AppColors.inkSecondary),
    );
  }

  // Stile per l'indice delle sezioni editoriali (es. "01 / CONTINUA LA LETTURA")
  static TextStyle sectionIndex({required bool isDark, Color? color}) {
    return GoogleFonts.spaceGrotesk(
      fontSize: 11,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.2,
      color: color ?? AppColors.editorialRed,
    );
  }
}
