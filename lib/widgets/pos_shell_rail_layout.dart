import 'package:flutter/material.dart';

/// When tablet landscape shell shows a left overlay rail, body content is
/// padded so it does not sit under the rail (AppBar stays full width).
class PosShellRailLayout extends InheritedWidget {
  final double bodyLeftPadding;

  const PosShellRailLayout({
    super.key,
    required this.bodyLeftPadding,
    required super.child,
  });

  /// Extra left padding for [Scaffold.body] (0 when rail inactive).
  static double bodyLeftOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<PosShellRailLayout>()
            ?.bodyLeftPadding ??
        0;
  }

  @override
  bool updateShouldNotify(PosShellRailLayout oldWidget) =>
      oldWidget.bodyLeftPadding != bodyLeftPadding;
}

/// Pads [child] when shell landscape rail is active.
Widget wrapPosShellRailBody(BuildContext context, Widget child) {
  final left = PosShellRailLayout.bodyLeftOf(context);
  if (left <= 0) return child;
  return Padding(padding: EdgeInsets.only(left: left), child: child);
}
