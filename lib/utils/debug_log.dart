import 'package:flutter/foundation.dart';

/// Lightweight wrapper around [debugPrint] that is compiled out in release
/// builds automatically (because [debugPrint] is a no-op in release mode).
///
/// Usage:
///   debugLog('[MyVM] Something happened: $value');
void debugLog(String message) => debugPrint(message);
