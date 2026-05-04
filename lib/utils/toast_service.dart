import 'dart:async';
import 'package:flutter/material.dart';

import '../services/locker_translation_mixin.dart';

/// Toasts via a managed [OverlayEntry] on the **same** [Navigator] [Overlay] that
/// hosts [showDialog] routes — so the banner paints **above** modals. Prefer the
/// caller [BuildContext] (still mounted) for lookup: [scaffoldMessengerKey] sits
/// **above** [Navigator] and has **no** [Overlay] ancestor, so using only that
/// context falls back to [SnackBar] and draws **behind** dialogs.
class ToastService {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// Max toast width as a fraction of screen width (slightly under half).
  static const double _maxWidthFraction = 0.46;
  static const double _horizontalInset = 22;

  static OverlayEntry? _overlayEntry;
  static Timer? _overlayTimer;
  static int _overlayGen = 0;

  static void showSuccess(
    BuildContext context,
    String message, {
    bool messageOnly = false,
    String? title,
  }) {
    _show(
      context,
      message,
      title ?? 'Success',
      Colors.green.shade800,
      messageOnly: messageOnly,
    );
  }

  static void showError(
    BuildContext context,
    String message, {
    String? title,
  }) {
    _show(context, message, title ?? 'Error', const Color(0xFFB71C1C));
  }

  static void showInfo(
    BuildContext context,
    String message, {
    String? title,
  }) {
    _show(context, message, title ?? 'Info', Colors.blue.shade800);
  }

  static List<Widget> _toastContentWidgets(
    String message,
    String title,
    Color titleColor, {
    required bool messageOnly,
  }) {
    if (messageOnly) {
      return [
        Text(
          message,
          style: TextStyle(
            color: titleColor,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
      ];
    }
    return [
      Text(
        title,
        style: TextStyle(
          color: titleColor,
          fontWeight: FontWeight.w900,
          fontSize: 16,
          letterSpacing: -0.2,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        message,
        style: const TextStyle(
          color: Color(0xFF23262D),
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    ];
  }

  static void _showSnackBarFallback(
    BuildContext layoutCtx,
    String message,
    String title,
    Color titleColor, {
    required bool messageOnly,
  }) {
    final h = MediaQuery.sizeOf(layoutCtx).height;
    final w = MediaQuery.sizeOf(layoutCtx).width;
    final topPad = MediaQuery.paddingOf(layoutCtx).top;
    final reservedHeight = messageOnly ? 120.0 : 200.0;
    // Narrow bar, right-aligned: w − left − right ≈ [_maxWidthFraction] × w.
    final leftGutter =
        (w * (1 - _maxWidthFraction) - _horizontalInset).clamp(8.0, double.infinity);
    final margin = EdgeInsets.fromLTRB(
      leftGutter,
      topPad + 10,
      _horizontalInset,
      (h - topPad - 10 - reservedHeight).clamp(0.0, double.infinity),
    );

    final bar = SnackBar(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _toastContentWidgets(message, title, titleColor,
            messageOnly: messageOnly),
      ),
      backgroundColor: const Color(0xFFFFF9E7),
      elevation: 8,
      behavior: SnackBarBehavior.floating,
      margin: margin,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      duration: const Duration(seconds: 3),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      dismissDirection: DismissDirection.up,
    );

    final root = scaffoldMessengerKey.currentState;
    if (root != null) {
      root.showSnackBar(bar);
      return;
    }
    ScaffoldMessenger.maybeOf(layoutCtx)?.showSnackBar(bar);
  }

  /// Overlay that hosts modal routes for this [context] (nearest navigator first).
  static OverlayState? _navigatorOverlay(BuildContext ctx) {
    return Navigator.maybeOf(ctx, rootNavigator: false)?.overlay ??
        Navigator.maybeOf(ctx, rootNavigator: true)?.overlay ??
        Overlay.maybeOf(ctx);
  }

  static void _insertRootOverlayBanner(
    BuildContext layoutCtx,
    String message,
    String title,
    Color titleColor, {
    required bool messageOnly,
  }) {
    final overlay = _navigatorOverlay(layoutCtx);
    if (overlay == null) {
      _showSnackBarFallback(
        layoutCtx,
        message,
        title,
        titleColor,
        messageOnly: messageOnly,
      );
      return;
    }

    _overlayTimer?.cancel();
    final previous = _overlayEntry;
    _overlayEntry = null;
    previous?.remove();

    final gen = ++_overlayGen;
    final topPad = MediaQuery.paddingOf(layoutCtx).top;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) {
        final screenW = MediaQuery.sizeOf(ctx).width;
        final toastW = screenW * _maxWidthFraction;
        return Positioned(
          top: topPad + 10,
          right: _horizontalInset,
          width: toastW,
          child: Material(
            elevation: 16,
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFFFFF9E7),
            shadowColor: Colors.black38,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _toastContentWidgets(
                  message,
                  title,
                  titleColor,
                  messageOnly: messageOnly,
                ),
              ),
            ),
          ),
        );
      },
    );

    _overlayEntry = entry;
    overlay.insert(entry);

    _overlayTimer = Timer(const Duration(seconds: 3), () {
      if (gen != _overlayGen) return;
      entry.remove();
      if (_overlayEntry == entry) _overlayEntry = null;
    });
  }


  static Future<String> _localizedToastText(
    BuildContext layoutCtx,
    String text,
  ) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return text;

    final langCode = Localizations.localeOf(layoutCtx).languageCode;

    // Keep English exactly as supplied. For Arabic, use the same app-wide
    // dynamic translation service used by API/database text so existing toast
    // calls do not need to be changed screen-by-screen.
    if (langCode != 'ar') {
      return AppTranslationService.localizeDigitsForLanguage(text, langCode);
    }

    try {
      return await AppTranslationService.localizedDynamicValueForLanguage(
        text,
        langCode,
      );
    } catch (_) {
      // Never block toast rendering because translation failed.
      return AppTranslationService.localizeDigitsForLanguage(text, langCode);
    }
  }

  static Future<({String message, String title})> _localizedToastPayload(
    BuildContext layoutCtx, {
    required String message,
    required String title,
  }) async {
    final localizedTitle = await _localizedToastText(layoutCtx, title);
    final localizedMessage = await _localizedToastText(layoutCtx, message);
    return (message: localizedMessage, title: localizedTitle);
  }

  static void _show(
    BuildContext context,
    String message,
    String title,
    Color titleColor, {
    bool messageOnly = false,
  }) {
    // Let nested routes (e.g. printer dialog pop) finish before touching overlay.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Caller context (e.g. under [InvoiceDialog]) has an [Overlay] ancestor;
        // [scaffoldMessengerKey.currentContext] does not — overlay would be null.
        final layoutCtx =
            (context.mounted ? context : null) ??
                scaffoldMessengerKey.currentContext;
        if (layoutCtx == null) return;

        final localized = await _localizedToastPayload(
          layoutCtx,
          message: message,
          title: title,
        );

        if (!layoutCtx.mounted) return;
        _insertRootOverlayBanner(
          layoutCtx,
          localized.message,
          localized.title,
          titleColor,
          messageOnly: messageOnly,
        );
      });
    });
  }
}
