import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Registered family names for Arabic UI glyphs (via [google_fonts]).
///
/// Applied as [TextStyle.fontFamilyFallback] after **Manrope** so Latin text
/// stays Manrope-shaped and Arabic matches the in-app POS look: **Tajawal**
/// first (inventory / retail UI), then **Almarai**, then **Cairo** for coverage.
List<String>? _arabicFallbackCache;

List<String> appArabicFontFallbacks() {
  _arabicFallbackCache ??= _computeArabicFallbacks();
  return _arabicFallbackCache!;
}

List<String> _computeArabicFallbacks() {
  final names = <String>[];

  void addUnique(String? family) {
    if (family == null || family.isEmpty) return;
    if (!names.contains(family)) names.add(family);
  }

  // Order matters: Tajawal ≈ modern POS arabic like المخزون / عناصر الطلب refs.
  addUnique(GoogleFonts.tajawal().fontFamily);
  addUnique(GoogleFonts.almarai().fontFamily);
  addUnique(GoogleFonts.cairo().fontFamily);

  return List<String>.unmodifiable(names);
}

/// Manrope styles from [GoogleFonts.manrope], with Arabic fallbacks appended.
TextStyle appManropeTextStyle({
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? height,
  double? letterSpacing,
}) {
  final base = GoogleFonts.manrope(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );
  final fb = appArabicFontFallbacks();
  if (fb.isEmpty) return base;
  return base.copyWith(fontFamilyFallback: fb);
}
