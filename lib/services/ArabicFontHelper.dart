// lib/services/arabic_font_helper.dart
//
// Arabic Font Helper — uses Cairo (Google Fonts) for crisp, modern Arabic.
// Cairo is the gold-standard Arabic sans-serif for UI/POS systems in Saudi Arabia.
// It looks clean and professional — NOT Urdu/Nastaliq style.
//
// SETUP (pubspec.yaml):
//   dependencies:
//     google_fonts: ^6.1.0
//
// OR if bundling locally:
//   flutter:
//     fonts:
//       - family: Cairo
//         fonts:
//           - asset: assets/fonts/Cairo-Regular.ttf
//             weight: 400
//           - asset: assets/fonts/Cairo-SemiBold.ttf
//             weight: 600
//           - asset: assets/fonts/Cairo-Bold.ttf
//             weight: 700
//           - asset: assets/fonts/Cairo-ExtraBold.ttf
//             weight: 800
//
// Download Cairo from: https://fonts.google.com/specimen/Cairo

import 'package:flutter/material.dart';

class ArabicFontHelper {
  ArabicFontHelper._();

  // Cairo — modern Arabic sans-serif, widely used in Saudi POS/UI systems.
  // NOT Nastaliq / NOT Urdu-style.
  static const String _kArabicFamily = 'Cairo';

  // Fallback chain: Cairo → Tajawal → system Arabic
  static const List<String> _kArabicFallbacks = [
    'Cairo',
    'Tajawal',    // Lightweight Arabic sans-serif
    'Arial',      // System fallback
  ];

  // ── Check if current locale is Arabic ─────────────────────────────────────
  static bool isArabic(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ar';

  static bool isArabicLocale(Locale locale) =>
      locale.languageCode == 'ar';

  // ── Core style helper ─────────────────────────────────────────────────────
  /// Returns [style] with Cairo font applied when locale is Arabic.
  static TextStyle maybeArabicStyle(BuildContext context, [TextStyle? style]) {
    if (!isArabic(context)) return style ?? const TextStyle();
    return _applyArabicFont(style ?? const TextStyle());
  }

  /// Applies Cairo font to a TextStyle unconditionally.
  static TextStyle arabicStyle([TextStyle? style]) =>
      _applyArabicFont(style ?? const TextStyle());

  static TextStyle _applyArabicFont(TextStyle style) {
    return style.copyWith(
      fontFamily: _kArabicFamily,
      fontFamilyFallback: _kArabicFallbacks,
      // Cairo reads well at 1.4-1.5 line height
      height: style.height ?? 1.45,
      letterSpacing: 0,
    );
  }

  // ── TextTheme override ────────────────────────────────────────────────────
  /// Applies Cairo to every text style in [base] TextTheme.
  static TextTheme arabicTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge:   _applyArabicFont(base.displayLarge  ?? const TextStyle()),
      displayMedium:  _applyArabicFont(base.displayMedium ?? const TextStyle()),
      displaySmall:   _applyArabicFont(base.displaySmall  ?? const TextStyle()),
      headlineLarge:  _applyArabicFont(base.headlineLarge ?? const TextStyle()),
      headlineMedium: _applyArabicFont(base.headlineMedium ?? const TextStyle()),
      headlineSmall:  _applyArabicFont(base.headlineSmall ?? const TextStyle()),
      titleLarge:     _applyArabicFont(base.titleLarge    ?? const TextStyle()),
      titleMedium:    _applyArabicFont(base.titleMedium   ?? const TextStyle()),
      titleSmall:     _applyArabicFont(base.titleSmall    ?? const TextStyle()),
      bodyLarge:      _applyArabicFont(base.bodyLarge     ?? const TextStyle()),
      bodyMedium:     _applyArabicFont(base.bodyMedium    ?? const TextStyle()),
      bodySmall:      _applyArabicFont(base.bodySmall     ?? const TextStyle()),
      labelLarge:     _applyArabicFont(base.labelLarge    ?? const TextStyle()),
      labelMedium:    _applyArabicFont(base.labelMedium   ?? const TextStyle()),
      labelSmall:     _applyArabicFont(base.labelSmall    ?? const TextStyle()),
    );
  }

  // ── ThemeData helper ──────────────────────────────────────────────────────
  /// Returns ThemeData with text theme using Cairo when locale is Arabic.
  ///
  /// Usage in MaterialApp:
  ///   theme: ArabicFontHelper.arabicAwareTheme(ThemeData.light(), settingsVm.locale),
  static ThemeData arabicAwareTheme(ThemeData base, Locale locale) {
    if (!isArabicLocale(locale)) return base;
    return base.copyWith(
      textTheme: arabicTextTheme(base.textTheme),
      primaryTextTheme: arabicTextTheme(base.primaryTextTheme),
    );
  }

  // ── Widget wrapper ────────────────────────────────────────────────────────
  /// Wraps [child] with RTL Directionality when locale is Arabic.
  static Widget wrap(BuildContext context, {required Widget child}) {
    if (!isArabic(context)) return child;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: child,
    );
  }
}
