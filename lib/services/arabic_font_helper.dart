// lib/services/arabic_font_helper.dart
//
// Arabic Font Helper
// ──────────────────
// Provides locale-aware font selection so Arabic text renders with a proper
// Arabic typeface (Noto Naskh Arabic / Cairo) instead of the default system
// font which may render with a Urdu/Nastaliq style.
//
// HOW TO USE
// ──────────
// 1. In your MaterialApp / CupertinoApp, call arabicAwareTheme(baseTheme) to
//    override the text theme when the locale is Arabic:
//
//      MaterialApp(
//        locale: currentLocale,
//        theme: ArabicFontHelper.arabicAwareTheme(ThemeData.light(), currentLocale),
//        ...
//      )
//
// 2. For individual TextStyle overrides in widgets:
//
//      Text('نص عربي', style: ArabicFontHelper.maybeArabicStyle(context, myStyle))
//
// 3. For a Directionality+font wrapper:
//
//      ArabicFontHelper.wrap(context, child: myWidget)
//
// FONTS REQUIRED IN pubspec.yaml
// ──────────────────────────────
//   flutter:
//     fonts:
//       - family: NotoNaskhArabic
//         fonts:
//           - asset: assets/fonts/NotoNaskhArabic-Regular.ttf
//             weight: 400
//           - asset: assets/fonts/NotoNaskhArabic-Medium.ttf
//             weight: 500
//           - asset: assets/fonts/NotoNaskhArabic-SemiBold.ttf
//             weight: 600
//           - asset: assets/fonts/NotoNaskhArabic-Bold.ttf
//             weight: 700
//
// Alternatively use google_fonts package:
//   dependency: google_fonts: ^6.1.0
//   Then set _kArabicFont = GoogleFonts.notoNaskhArabicTextTheme
//
// NOTE: Download Noto Naskh Arabic from fonts.google.com

import 'package:flutter/material.dart';

class ArabicFontHelper {
  ArabicFontHelper._();

  // ── Font family name — matches pubspec.yaml font family declaration ──────
  static const String _kArabicFamily = 'NotoNaskhArabic';

  // ── Fallback chain: if NotoNaskhArabic not bundled yet, use system Arabic ─
  static const List<String> _kArabicFallbacks = [
    'NotoNaskhArabic',
    'Cairo',          // Also a clean Arabic font (google_fonts)
    'Tajawal',        // Lightweight alternative
    'Arial',          // System fallback
  ];

  // ── Check if current locale is Arabic ────────────────────────────────────

  static bool isArabic(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ar';

  static bool isArabicLocale(Locale locale) =>
      locale.languageCode == 'ar';

  // ── Core style helper ─────────────────────────────────────────────────────

  /// Returns [style] with Arabic font overrides applied when locale is Arabic.
  /// Keeps all other style properties unchanged.
  static TextStyle maybeArabicStyle(BuildContext context, [TextStyle? style]) {
    if (!isArabic(context)) return style ?? const TextStyle();
    return _applyArabicFont(style ?? const TextStyle());
  }

  /// Applies Arabic font to a TextStyle unconditionally.
  static TextStyle arabicStyle([TextStyle? style]) =>
      _applyArabicFont(style ?? const TextStyle());

  static TextStyle _applyArabicFont(TextStyle style) {
    return style.copyWith(
      fontFamily: _kArabicFamily,
      fontFamilyFallback: _kArabicFallbacks,
      // Arabic text renders better with slightly increased height
      height: style.height ?? 1.5,
      // Ensure letters are not forced apart
      letterSpacing: 0,
    );
  }

  // ── TextTheme override ────────────────────────────────────────────────────

  /// Applies Arabic font to every text style in [base] TextTheme.
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

  /// Returns a [ThemeData] with the full text theme overridden for Arabic when
  /// [locale] is Arabic. Use this in MaterialApp.theme.
  ///
  /// Example:
  ///   theme: ArabicFontHelper.arabicAwareTheme(ThemeData.light(), _currentLocale),
  static ThemeData arabicAwareTheme(ThemeData base, Locale locale) {
    if (!isArabicLocale(locale)) return base;
    return base.copyWith(
      textTheme: arabicTextTheme(base.textTheme),
      primaryTextTheme: arabicTextTheme(base.primaryTextTheme),
    );
  }

  // ── Widget wrapper ────────────────────────────────────────────────────────

  /// Wraps [child] with correct RTL Directionality when locale is Arabic.
  /// Use this at screen-level if you haven't set Directionality globally.
  static Widget wrap(BuildContext context, {required Widget child}) {
    if (!isArabic(context)) return child;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: child,
    );
  }

  // ── DefaultTextStyle override ─────────────────────────────────────────────

  /// Wraps [child] with a DefaultTextStyle that uses the Arabic font.
  /// Use inside widgets that inherit text style from DefaultTextStyle.
  static Widget arabicDefaultTextStyle(
    BuildContext context, {
    required Widget child,
    TextStyle? style,
  }) {
    if (!isArabic(context)) return child;
    final inherited = DefaultTextStyle.of(context).style;
    return DefaultTextStyle(
      style: _applyArabicFont(style ?? inherited),
      child: child,
    );
  }
}
