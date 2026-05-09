import 'package:flutter/material.dart';

import 'app_arabic_font_fallbacks.dart';

class AppTextStyles {
  static TextStyle get h1 => appManropeTextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get h2 => appManropeTextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get h3 => appManropeTextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      );

  // Body Text
  static TextStyle get bodyLarge => appManropeTextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get bodyMedium => appManropeTextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get bodySmall => appManropeTextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
      );

  // Button Text
  static TextStyle get button => appManropeTextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      );

  // Custom Colors helper
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
}
