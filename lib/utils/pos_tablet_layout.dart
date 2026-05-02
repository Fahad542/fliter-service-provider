import 'package:flutter/material.dart';

/// Workshop POS density for ~11" tablets: readable type without oversized chrome.
abstract final class PosTabletLayout {
  PosTabletLayout._();

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width > 600;

  /// Replaces legacy 1.4× shell scaling.
  static double textScale(BuildContext context) =>
      isTablet(context) ? 1.08 : 1.0;

  static TextScaler textScaler(BuildContext context) =>
      TextScaler.linear(textScale(context));

  /// PosAppBar / PosScreenAppBar / shell rail offset.
  static const double appBarHeight = 72;

  static const double appBarIconBox = 46;
  static const double appBarIconGlyph = 24;
  static const double appBarTitleSize = 16;
  static const double appBarBackIcon = 28;
  static const double appBarBottomRadius = 26;
  static const double appBarLogoHeight = 30;

  static const double menuIconBox = 44;
  static const double menuIconGlyph = 24;
}
