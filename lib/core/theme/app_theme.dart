import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radii.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get darkTheme {
    final textTheme = AppTypography.textTheme(true);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.nightBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.editorialRed,
        onPrimary: Colors.white,
        primaryContainer: AppColors.deepRed,
        onPrimaryContainer: Colors.white,
        secondary: AppColors.navyInk,
        onSecondary: Colors.white,
        surface: AppColors.nightSurface,
        onSurface: AppColors.nightInk,
        error: AppColors.error,
        onError: Colors.white,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.nightBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineSmall?.copyWith(
          color: AppColors.nightInk,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: AppColors.nightInk, size: 20),
        shape: const Border(
          bottom: BorderSide(color: AppColors.nightBorder, width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.nightSurface,
        elevation: 0,
        height: 60,
        indicatorColor: AppColors.editorialRed.withValues(alpha: 0.15),
        indicatorShape: RoundedRectangleBorder(borderRadius: AppRadii.brSm),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(
              color: AppColors.editorialRed,
              fontWeight: FontWeight.w700,
            );
          }
          return textTheme.labelSmall?.copyWith(color: AppColors.nightInkMuted);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.editorialRed, size: 20);
          }
          return const IconThemeData(color: AppColors.nightInkMuted, size: 20);
        }),
      ),
      cardTheme: CardThemeData(
        color: AppColors.nightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.brSm,
          side: const BorderSide(color: AppColors.nightBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.nightSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.nightInkMuted,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadii.brSm,
          borderSide: const BorderSide(color: AppColors.nightBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.brSm,
          borderSide: const BorderSide(color: AppColors.nightBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.brSm,
          borderSide: const BorderSide(
            color: AppColors.editorialRed,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.brSm,
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.nightSurfaceVariant,
        selectedColor: AppColors.editorialRed.withValues(alpha: 0.2),
        labelStyle: textTheme.labelMedium?.copyWith(
          color: AppColors.nightInkSecondary,
        ),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: AppColors.editorialRed,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.brXs,
          side: const BorderSide(color: AppColors.nightBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.editorialRed,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.brSm),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.nightInk,
          side: const BorderSide(color: AppColors.nightBorder, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.brSm),
          textStyle: textTheme.labelLarge,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.nightSurfaceVariant,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.nightInk,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.brSm,
          side: const BorderSide(color: AppColors.nightBorder),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.nightBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get lightTheme {
    final textTheme = AppTypography.textTheme(false);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.paperBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.editorialRed,
        onPrimary: Colors.white,
        primaryContainer: AppColors.editorialRedLight,
        onPrimaryContainer: AppColors.deepRed,
        secondary: AppColors.navyInk,
        onSecondary: Colors.white,
        surface: AppColors.paperSurface,
        onSurface: AppColors.inkBlack,
        error: AppColors.error,
        onError: Colors.white,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.paperBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineSmall?.copyWith(
          color: AppColors.inkBlack,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: AppColors.inkBlack, size: 20),
        shape: const Border(
          bottom: BorderSide(color: AppColors.paperBorder, width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.paperSurfaceWarm,
        elevation: 0,
        height: 60,
        indicatorColor: AppColors.editorialRed.withValues(alpha: 0.12),
        indicatorShape: RoundedRectangleBorder(borderRadius: AppRadii.brSm),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(
              color: AppColors.editorialRed,
              fontWeight: FontWeight.w700,
            );
          }
          return textTheme.labelSmall?.copyWith(color: AppColors.inkMuted);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.editorialRed, size: 20);
          }
          return const IconThemeData(color: AppColors.inkMuted, size: 20);
        }),
      ),
      cardTheme: CardThemeData(
        color: AppColors.paperSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.brSm,
          side: const BorderSide(color: AppColors.paperBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.paperSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.inkMuted),
        border: OutlineInputBorder(
          borderRadius: AppRadii.brSm,
          borderSide: const BorderSide(color: AppColors.paperBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.brSm,
          borderSide: const BorderSide(color: AppColors.paperBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.brSm,
          borderSide: const BorderSide(
            color: AppColors.editorialRed,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.brSm,
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.paperSurfaceVariant,
        selectedColor: AppColors.editorialRed.withValues(alpha: 0.12),
        labelStyle: textTheme.labelMedium?.copyWith(
          color: AppColors.inkSecondary,
        ),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: AppColors.editorialRed,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.brXs,
          side: const BorderSide(color: AppColors.paperBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.editorialRed,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.brSm),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.inkBlack,
          side: const BorderSide(color: AppColors.paperBorder, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.brSm),
          textStyle: textTheme.labelLarge,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.paperSurfaceVariant,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.inkBlack,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.brSm,
          side: const BorderSide(color: AppColors.paperBorder),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.paperBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
