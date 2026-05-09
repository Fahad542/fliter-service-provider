import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_arabic_font_fallbacks.dart';
import 'app_colors.dart';

/// Adds [fontFamilyFallback] per style so glyphs missing from Manrope (Arabic script)
/// render from Almarai / Tajawal without changing the Latin fontFamily.
TextTheme _manropeThemeWithArabicFallback(TextTheme manropeTheme) {
  final fb = appArabicFontFallbacks();
  if (fb.isEmpty) return manropeTheme;

  TextStyle? merge(TextStyle? s) {
    if (s == null) return null;
    return s.copyWith(fontFamilyFallback: fb);
  }

  return manropeTheme.copyWith(
    displayLarge: merge(manropeTheme.displayLarge),
    displayMedium: merge(manropeTheme.displayMedium),
    displaySmall: merge(manropeTheme.displaySmall),
    headlineLarge: merge(manropeTheme.headlineLarge),
    headlineMedium: merge(manropeTheme.headlineMedium),
    headlineSmall: merge(manropeTheme.headlineSmall),
    titleLarge: merge(manropeTheme.titleLarge),
    titleMedium: merge(manropeTheme.titleMedium),
    titleSmall: merge(manropeTheme.titleSmall),
    bodyLarge: merge(manropeTheme.bodyLarge),
    bodyMedium: merge(manropeTheme.bodyMedium),
    bodySmall: merge(manropeTheme.bodySmall),
    labelLarge: merge(manropeTheme.labelLarge),
    labelMedium: merge(manropeTheme.labelMedium),
    labelSmall: merge(manropeTheme.labelSmall),
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    final base = ThemeData.light();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primaryLight,
        onPrimary: AppColors.onPrimaryLight,
        secondary: AppColors.secondaryLight,
        onSecondary: AppColors.onSecondaryLight,
        error: AppColors.errorLight,
        onError: AppColors.onErrorLight,
        background: AppColors.backgroundLight,
        onBackground: AppColors.onBackgroundLight,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.onSurfaceLight,
      ),
      fontFamilyFallback: appArabicFontFallbacks(),
      textTheme:
      _manropeThemeWithArabicFallback(GoogleFonts.manropeTextTheme(base.textTheme)),
      primaryTextTheme: _manropeThemeWithArabicFallback(
        GoogleFonts.manropeTextTheme(base.primaryTextTheme),
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.onPrimaryLight,
      ),
      // ── Global: disable background-color change on button press ──────
      // Loading icon still shows; only the ripple/grey flash is removed.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          splashFactory: NoSplash.splashFactory,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          splashFactory: NoSplash.splashFactory,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          splashFactory: NoSplash.splashFactory,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          splashFactory: NoSplash.splashFactory,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          splashFactory: NoSplash.splashFactory,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.primaryDark,
        onPrimary: AppColors.onPrimaryDark,
        secondary: AppColors.secondaryDark,
        onSecondary: AppColors.onSecondaryDark,
        error: AppColors.errorDark,
        onError: AppColors.onErrorDark,
        background: AppColors.backgroundDark,
        onBackground: AppColors.onBackgroundDark,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.onSurfaceDark,
      ),
      fontFamilyFallback: appArabicFontFallbacks(),
      textTheme:
      _manropeThemeWithArabicFallback(GoogleFonts.manropeTextTheme(base.textTheme)),
      primaryTextTheme: _manropeThemeWithArabicFallback(
        GoogleFonts.manropeTextTheme(base.primaryTextTheme),
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.onPrimaryLight, // Dark text/icons on Yellow Bar
      ),
      // ── Global: disable background-color change on button press ──────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          splashFactory: NoSplash.splashFactory,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          splashFactory: NoSplash.splashFactory,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          splashFactory: NoSplash.splashFactory,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          splashFactory: NoSplash.splashFactory,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          splashFactory: NoSplash.splashFactory,
        ),
      ),
    );
  }
}