import 'package:flutter/material.dart';
import 'locker_translation_mixin.dart';

/// Text widget for dynamic strings coming from API/database.
///
/// WHY THIS EXISTS
/// ───────────────
/// Static l10n strings use AppLocalizations (ARB keys). Dynamic strings from
/// the API/database arrive in English and must be translated on the fly.
/// This widget handles that transparently:
///   • Shows the raw string instantly (initialData) — no loading flicker.
///   • Translates asynchronously and updates when done.
///   • Re-translates automatically when the locale changes (key includes
///     languageCode), so there is no stale Arabic/English text after a switch.
///
/// KEY FIX: locale is read from Localizations.localeOf(context) — NOT from
/// SessionService — so it always reflects the live widget-tree locale.
/// The FutureBuilder key changes on locale switch, which cancels the old
/// future and immediately shows initialData (raw) then the new translation.
///
/// USAGE
/// ─────
///   LocalizedApiText(
///     employee.name,
///     style: AppTextStyles.bodyMedium,
///     overflow: TextOverflow.ellipsis,
///   )
class LocalizedApiText extends StatelessWidget {
  const LocalizedApiText(
    this.text, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.uppercase = false,
  });

  final String text;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final double? textScaleFactor;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;

  /// When true, applies .toUpperCase() to the resolved string.
  /// Arabic text is NOT upper-cased even when [uppercase] is true —
  /// Arabic has no concept of casing, and toUpperCase() on Arabic is a no-op,
  /// but this guard prevents surprises if the locale changes mid-session.
  final bool uppercase;

  @override
  Widget build(BuildContext context) {
    // Read locale from widget tree — always current, no async needed.
    final langCode = Localizations.localeOf(context).languageCode;
    final raw = text;

    return FutureBuilder<String>(
      // Key change on locale switch cancels the old future immediately and
      // shows initialData (the raw string) while the new translation loads.
      key: ValueKey<String>('$langCode::$raw::$uppercase'),
      future: AppTranslationService.localizedTextForLanguage(raw, langCode),
      initialData: raw,
      builder: (context, snapshot) {
        final resolved = snapshot.data ?? raw;
        // Never toUpperCase Arabic text — it has no casing.
        final display = (uppercase && langCode != 'ar')
            ? resolved.toUpperCase()
            : resolved;
        return Text(
          display,
          style:              style,
          strutStyle:         strutStyle,
          textAlign:          textAlign,
          textDirection:      textDirection,
          locale:             locale,
          softWrap:           softWrap,
          overflow:           overflow,
          textScaleFactor:    textScaleFactor,
          maxLines:           maxLines,
          semanticsLabel:     semanticsLabel,
          textWidthBasis:     textWidthBasis,
          textHeightBehavior: textHeightBehavior,
          selectionColor:     selectionColor,
        );
      },
    );
  }
}

/// Nullable variant — renders an empty string when [text] is null.
class LocalizedApiTextNullable extends StatelessWidget {
  const LocalizedApiTextNullable(
    this.text, {
    super.key,
    this.style,
    this.overflow,
    this.maxLines,
    this.textAlign,
  });

  final String? text;
  final TextStyle? style;
  final TextOverflow? overflow;
  final int? maxLines;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    if (text == null || text!.isEmpty) return const SizedBox.shrink();
    return LocalizedApiText(
      text!,
      style:     style,
      overflow:  overflow,
      maxLines:  maxLines,
      textAlign: textAlign,
    );
  }
}
