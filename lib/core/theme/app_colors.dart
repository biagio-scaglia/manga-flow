import 'package:flutter/material.dart';

class AppColors {
  // Light Mode - Stampa & Carta Editoriale
  static const Color paperBackground = Color(0xFFF6F3EC);
  static const Color paperSurface = Color(0xFFFFFFFF);
  static const Color paperSurfaceWarm = Color(0xFFFAF7F2);
  static const Color paperSurfaceVariant = Color(0xFFECE7DE);
  static const Color paperBorder = Color(0xFFD8D2C5);
  static const Color paperBorderStrong = Color(0xFFB8B0A2);

  // Ink Tones
  static const Color inkBlack = Color(0xFF141416);
  static const Color inkSecondary = Color(0xFF45423E);
  static const Color inkMuted = Color(0xFF78736B);
  static const Color inkSubtle = Color(0xFFA39E95);

  // Editorial Accents
  static const Color editorialRed = Color(0xFFD9272E);
  static const Color deepRed = Color(0xFFA71920);
  static const Color editorialRedLight = Color(0xFFFDECEE);
  static const Color editorialRedDark = Color(0xFF851117);

  // Print Accents
  static const Color paperGold = Color(0xFFC59216);
  static const Color navyInk = Color(0xFF18232C);
  static const Color forestGreen = Color(0xFF246A4A);
  static const Color warmWhite = Color(0xFFFFFCF7);

  // Dark Mode - "Night Bookstore" (Libreria Notturna)
  static const Color nightBackground = Color(0xFF121316);
  static const Color nightSurface = Color(0xFF1A1C20);
  static const Color nightSurfaceVariant = Color(0xFF24262C);
  static const Color nightBorder = Color(0xFF31333B);
  static const Color nightBorderStrong = Color(0xFF474A55);

  static const Color nightInk = Color(0xFFF6F3EC);
  static const Color nightInkSecondary = Color(0xFFABA69D);
  static const Color nightInkMuted = Color(0xFF736F68);

  // Compatibilità e Alias di Sistema
  static const Color primary = editorialRed;
  static const Color primaryLight = Color(0xFFE8545A);
  static const Color primaryDark = deepRed;
  static const Color secondary = navyInk;
  static const Color secondaryLight = Color(0xFF2E3D4D);
  static const Color accent = paperGold;

  // Reading Statuses - Bollini / Etichette Editoriali
  static const Color statusReading = editorialRed;
  static const Color statusPlanToRead = navyInk;
  static const Color statusCompleted = forestGreen;
  static const Color statusOnHold = paperGold;
  static const Color statusDropped = inkMuted;
  static const Color statusFavorite = deepRed;

  // Text Colors
  static const Color textPrimaryDark = nightInk;
  static const Color textSecondaryDark = nightInkSecondary;
  static const Color textMutedDark = nightInkMuted;

  static const Color textPrimaryLight = inkBlack;
  static const Color textSecondaryLight = inkSecondary;
  static const Color textMutedLight = inkMuted;

  // Dark Theme Aliases for theme backward compatibility
  static const Color darkBackground = nightBackground;
  static const Color darkSurface = nightSurface;
  static const Color darkSurfaceVariant = nightSurfaceVariant;
  static const Color darkCard = nightSurface;
  static const Color darkCardBorder = nightBorder;

  // Light Theme Aliases
  static const Color lightBackground = paperBackground;
  static const Color lightSurface = paperSurface;
  static const Color lightSurfaceVariant = paperSurfaceVariant;
  static const Color lightCard = paperSurface;
  static const Color lightCardBorder = paperBorder;

  // Utility
  static const Color success = forestGreen;
  static const Color warning = paperGold;
  static const Color error = editorialRed;
  static const Color info = navyInk;

  // Skeleton / Shimmer
  static const Color skeletonBaseDark = Color(0xFF22242B);
  static const Color skeletonHighlightDark = Color(0xFF2E313A);
  static const Color skeletonBaseLight = Color(0xFFE5E0D5);
  static const Color skeletonHighlightLight = Color(0xFFF0EBE0);
}
