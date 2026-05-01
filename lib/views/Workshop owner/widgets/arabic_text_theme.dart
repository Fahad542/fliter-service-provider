import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// arabic_text_theme.dart
//
// Provides locale-aware TextStyle and Theme helpers so Arabic text renders
// with a proper Arabic typeface instead of the default fallback font that can
// look like Urdu / Nastaliq script.
//
// Recommended Google Fonts (add to pubspec.yaml):
//   google_fonts: ^6.2.1
//
// Then in your pubspec fonts section OR via google_fonts package:
//   'Noto Naskh Arabic'  → classic, very readable, correct Arabic shape
//   'Cairo'              → modern, clean, great for UI labels
//   'Tajawal'            → compact, works well at small sizes
//
// HOW TO USE — two options:
//
// OPTION A (recommended) — wrap MaterialApp with ArabicThemeWrapper:
//
//   ArabicThemeWrapper(
//     child: MaterialApp(...),
//   )
//
// OPTION B — call arabicAwareTheme() in your MaterialApp.theme:
//
//   MaterialApp(
//     theme: arabicAwareTheme(context, baseTheme: ThemeData.light()),
//   )
//
// ─────────────────────────────────────────────────────────────────────────────

/// The font family to use for Arabic text.
/// Change to 'Cairo' or 'Tajawal' if you prefer a more modern look.
const String _kArabicFontFamily = 'Noto Naskh Arabic';

/// Returns [fontFamily] only when the current locale is Arabic; otherwise null
/// (which keeps the app's existing English font intact).
String? arabicFont(BuildContext context) {
  final locale = Localizations.localeOf(context);
  return locale.languageCode == 'ar' ? _kArabicFontFamily : null;
}

/// Merges the Arabic font into a [TextTheme] when the locale is Arabic.
/// Call this inside ThemeData to apply globally.
///
/// Example:
///   ThemeData(
///     textTheme: arabicTextTheme(context),
///   )
TextTheme arabicTextTheme(BuildContext context, {TextTheme? base}) {
  final theme = base ?? Theme.of(context).textTheme;
  final font   = arabicFont(context);
  if (font == null) return theme;
  return theme.apply(fontFamily: font);
}

/// Returns a full [ThemeData] with the Arabic font merged in when in Arabic
/// locale.  Pass your existing [baseTheme] (or null to use the current theme).
///
/// Usage in MaterialApp:
///   theme: arabicAwareTheme(context),
ThemeData arabicAwareTheme(BuildContext context, {ThemeData? baseTheme}) {
  final theme = baseTheme ?? Theme.of(context);
  final font   = arabicFont(context);
  if (font == null) return theme;
  return theme.copyWith(
    textTheme: theme.textTheme.apply(fontFamily: font),
    primaryTextTheme: theme.primaryTextTheme.apply(fontFamily: font),
  );
}

/// Widget wrapper — place around [MaterialApp] or any subtree to apply the
/// Arabic font automatically based on the inherited locale.
///
///   ArabicThemeWrapper(child: MaterialApp(...))
class ArabicThemeWrapper extends StatelessWidget {
  const ArabicThemeWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final font = arabicFont(context);
    if (font == null) return child;

    // Override the default font for all Text widgets in this subtree.
    return DefaultTextStyle(
      style: DefaultTextStyle.of(context).style.copyWith(fontFamily: font),
      child: child,
    );
  }
}

/// A drop-in replacement for [Text] that automatically switches to the Arabic
/// font when the current locale is Arabic.  Use this for any label that could
/// show Arabic text.
///
///   ArabicAwareText('Hello / مرحباً', style: TextStyle(fontSize: 16))
class ArabicAwareText extends StatelessWidget {
  const ArabicAwareText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
  });

  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool? softWrap;

  @override
  Widget build(BuildContext context) {
    final font = arabicFont(context);
    final resolvedStyle = font != null
        ? (style ?? const TextStyle()).copyWith(fontFamily: font)
        : style;
    return Text(
      data,
      style: resolvedStyle,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      softWrap: softWrap,
    );
  }
}
