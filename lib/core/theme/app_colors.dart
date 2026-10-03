import 'package:flutter/material.dart';

class AppColors {
  // Dark Theme Palette
  static const Color darkBackground = Color(0xFF090C15);
  static const Color darkSurface = Color(0xFF131826);
  static const Color darkSurfaceVariant = Color(0xFF1D2436);
  static const Color darkCard = Color(0xFF161E30);
  static const Color darkCardBorder = Color(0xFF253046);

  // Light Theme Palette
  static const Color lightBackground = Color(0xFFF7F8FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFEEF1F8);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardBorder = Color(0xFFE2E8F0);

  // Brand Accents
  static const Color primary = Color(0xFF8B5CF6); // Electric Lilac
  static const Color primaryLight = Color(0xFFA78BFA);
  static const Color primaryDark = Color(0xFF6D28D9);
  
  static const Color secondary = Color(0xFFEC4899); // Soft Magenta
  static const Color secondaryLight = Color(0xFFF472B6);
  
  static const Color accent = Color(0xFF06B6D4); // Cyan Accent

  // Reading Status Colors
  static const Color statusReading = Color(0xFF10B981); // Emerald Green
  static const Color statusPlanToRead = Color(0xFF3B82F6); // Royal Blue
  static const Color statusCompleted = Color(0xFF8B5CF6); // Purple
  static const Color statusOnHold = Color(0xFFF59E0B); // Amber
  static const Color statusDropped = Color(0xFFEF4444); // Red
  static const Color statusFavorite = Color(0xFFF43F5E); // Rose

  // Text Colors
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textMutedLight = Color(0xFF94A3B8);

  // Status & Utility
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Shimmer / Skeleton
  static const Color skeletonBaseDark = Color(0xFF1E2638);
  static const Color skeletonHighlightDark = Color(0xFF2D374D);
  static const Color skeletonBaseLight = Color(0xFFE2E8F0);
  static const Color skeletonHighlightLight = Color(0xFFF1F5F9);
}
