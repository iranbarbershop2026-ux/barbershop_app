import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Color Palette ────────────────────────────────────────────────────────────

abstract class AppColors {
  // Backgrounds
  static const bg = Color(0xFF0E0E0E);
  static const surface = Color(0xFF181818);
  static const surfaceElevated = Color(0xFF222222);

  // Gold accent — warm, premium
  static const gold = Color(0xFFC9A96E);
  static const goldLight = Color(0xFFDDBF8A);
  static const goldDim = Color(0xFF8A6E44);

  // Text
  static const textPrimary = Color(0xFFF2F2F2);
  static const textSecondary = Color(0xFF9A9A9A);
  static const textHint = Color(0xFF555555);

  // Dividers / borders
  static const border = Color(0xFF2A2A2A);
  static const borderGold = Color(0xFF3A3020);

  // Transparent overlays
  static const overlay20 = Color(0x33000000);
  static const overlay50 = Color(0x80000000);
}

// ── Typography ────────────────────────────────────────────────────────────────

abstract class AppTextStyles {
  static const String _font = 'Vazirmatn';

  static const TextTheme textTheme = TextTheme(
    // Large display — برند
    displayLarge: TextStyle(
      fontFamily: _font,
      fontSize: 32,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
      letterSpacing: 1.2,
      height: 1.2,
    ),
    displayMedium: TextStyle(
      fontFamily: _font,
      fontSize: 26,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: 0.5,
      height: 1.3,
    ),
    // Headlines
    headlineLarge: TextStyle(
      fontFamily: _font,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      height: 1.3,
    ),
    headlineMedium: TextStyle(
      fontFamily: _font,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      height: 1.4,
    ),
    headlineSmall: TextStyle(
      fontFamily: _font,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      height: 1.4,
    ),
    // Body
    bodyLarge: TextStyle(
      fontFamily: _font,
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
      height: 1.6,
    ),
    bodyMedium: TextStyle(
      fontFamily: _font,
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontFamily: _font,
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: AppColors.textHint,
      height: 1.5,
    ),
    // Labels
    labelLarge: TextStyle(
      fontFamily: _font,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: 0.5,
    ),
    labelMedium: TextStyle(
      fontFamily: _font,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
      letterSpacing: 0.3,
    ),
    labelSmall: TextStyle(
      fontFamily: _font,
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: AppColors.textHint,
      letterSpacing: 1.2,
    ),
  );
}

// ── Theme ─────────────────────────────────────────────────────────────────────

abstract class AppTheme {
  static const String _font = 'Vazirmatn';

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: _font,
        scaffoldBackgroundColor: AppColors.bg,
        textTheme: AppTextStyles.textTheme,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.gold,
          onPrimary: AppColors.bg,
          secondary: AppColors.goldLight,
          onSecondary: AppColors.bg,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          outline: AppColors.border,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
          titleTextStyle: TextStyle(
            fontFamily: _font,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.gold,
            letterSpacing: 3,
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 1,
          space: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.bg,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontFamily: _font,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
          ),
          hintStyle: const TextStyle(
            fontFamily: _font,
            color: AppColors.textHint,
            fontSize: 13,
          ),
          labelStyle: const TextStyle(
            fontFamily: _font,
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      );

  // ── System UI overlay ────────────────────────────────────────────────────
  static const systemOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.bg,
    systemNavigationBarIconBrightness: Brightness.light,
  );
}
