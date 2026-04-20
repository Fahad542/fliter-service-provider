import 'package:flutter/material.dart';

/// Lets nested tab bodies (which use their own [Scaffold]) open the shell drawer.
///
/// Each [PosShell] registers its own [GlobalKey] while mounted so we never attach
/// one key to two widgets during navigation (e.g. [Navigator.pushAndRemoveUntil]).
class PosShellScaffoldRegistry {
  static GlobalKey<ScaffoldState>? _activeKey;

  static void attach(GlobalKey<ScaffoldState> key) {
    _activeKey = key;
  }

  static void detach(GlobalKey<ScaffoldState> key) {
    if (_activeKey == key) _activeKey = null;
  }

  static void openDrawer() {
    _activeKey?.currentState?.openDrawer();
  }
}
