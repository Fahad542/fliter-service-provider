import 'package:flutter/material.dart';

import 'locker_translation_mixin.dart';

/// Text widget for dynamic strings coming from API/database.
///
/// It translates only for Arabic locale and returns raw text for English,
/// numbers, IDs, references, phone numbers, dates, money, and already-Arabic text.
/// Because it reads [Localizations.localeOf(context)], it re-runs automatically
/// on locale switch without comparing translated strings in business logic.
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
  final bool uppercase;

  @override
  Widget build(BuildContext context) {
    final activeLocale = Localizations.localeOf(context);
    final raw = text;
    return FutureBuilder<String>(
      key: ValueKey<String>('${activeLocale.languageCode}::$raw::$uppercase'),
      future: AppTranslationService.localizedTextForLanguage(
        raw,
        activeLocale.languageCode,
      ),
      initialData: raw,
      builder: (context, snapshot) {
        final resolved = uppercase
            ? (snapshot.data ?? raw).toUpperCase()
            : (snapshot.data ?? raw);
        return Text(
          resolved,
          style: style,
          strutStyle: strutStyle,
          textAlign: textAlign,
          textDirection: textDirection,
          locale: locale,
          softWrap: softWrap,
          overflow: overflow,
          textScaleFactor: textScaleFactor,
          maxLines: maxLines,
          semanticsLabel: semanticsLabel,
          textWidthBasis: textWidthBasis,
          textHeightBehavior: textHeightBehavior,
          selectionColor: selectionColor,
        );
      },
    );
  }
}
