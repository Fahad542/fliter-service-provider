import 'package:flutter/material.dart';

import '../../../services/locker_translation_mixin.dart';
import '../More Tab/settings_view_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Raw notification model — stores the ORIGINAL English strings from the API /
// database. Never mutate these; derive translated display strings separately.
// ─────────────────────────────────────────────────────────────────────────────
class NotificationModel {
  /// Canonical English notification-type key, e.g. "order", "stock", "system".
  /// Used to look up the translated title/message via AppLocalizations.
  final String typeKey;

  /// Raw English title coming from the API / database.
  final String rawTitle;

  /// Raw English message body coming from the API / database.
  final String rawMessage;

  final String time;
  final IconData icon;
  final bool isRead;

  // Translated display fields — populated by the ViewModel.
  final String displayTitle;
  final String displayMessage;

  const NotificationModel({
    required this.typeKey,
    required this.rawTitle,
    required this.rawMessage,
    required this.time,
    required this.icon,
    this.isRead = false,
    // Default display = raw (English); overwritten after translation.
    String? displayTitle,
    String? displayMessage,
  })  : displayTitle = displayTitle ?? rawTitle,
        displayMessage = displayMessage ?? rawMessage;

  NotificationModel copyWith({
    String? displayTitle,
    String? displayMessage,
    bool? isRead,
  }) {
    return NotificationModel(
      typeKey: typeKey,
      rawTitle: rawTitle,
      rawMessage: rawMessage,
      time: time,
      icon: icon,
      isRead: isRead ?? this.isRead,
      displayTitle: displayTitle ?? this.displayTitle,
      displayMessage: displayMessage ?? this.displayMessage,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ViewModel
// ─────────────────────────────────────────────────────────────────────────────
class NotificationsViewModel extends ChangeNotifier with TranslatableMixin {
  // ── Raw API data — keep in English always ──────────────────────────────────
  final List<NotificationModel> _raw = [
    const NotificationModel(
      typeKey: 'order',
      rawTitle: 'New Order Received',
      rawMessage: 'Order #ORD-1024 has been placed by Ali Khan.',
      time: '02:45 PM',
      icon: Icons.shopping_basket_outlined,
    ),
    const NotificationModel(
      typeKey: 'stock',
      rawTitle: 'Low Stock Alert',
      rawMessage: 'Castrol Engine Oil (5L) is below threshold (5 left).',
      time: '11:20 AM',
      icon: Icons.warning_amber_rounded,
    ),
    const NotificationModel(
      typeKey: 'technician',
      rawTitle: 'Technician Assigned',
      rawMessage: 'M. Sheraz has been assigned to Order #ORD-1022.',
      time: '09:15 AM',
      icon: Icons.engineering_outlined,
      isRead: true,
    ),
    const NotificationModel(
      typeKey: 'system',
      rawTitle: 'System Update',
      rawMessage: 'A new version of the POS system is available.',
      time: 'Yesterday',
      icon: Icons.system_update_outlined,
      isRead: true,
    ),
    const NotificationModel(
      typeKey: 'promo',
      rawTitle: 'Promotion Active',
      rawMessage: 'Promo Code WELCOME20 is now active for all branches.',
      time: '05 Feb 2026',
      icon: Icons.local_offer_outlined,
      isRead: true,
    ),
  ];

  // ── Translated display list shown in the UI ────────────────────────────────
  List<NotificationModel> _translated = [];

  List<NotificationModel> get notifications => _translated;

  // ─────────────────────────────────────────────────────────────────────────
  // Constructor
  // ─────────────────────────────────────────────────────────────────────────
  NotificationsViewModel({SettingsViewModel? settingsViewModel}) {
    // Seed display list with raw English.
    _translated = List.of(_raw);

    // Bind locale change listener so translations refresh automatically when
    // the user switches language — no need to re-open the screen.
    if (settingsViewModel != null) {
      bindLocaleRetranslation(settingsViewModel, _retranslate);
    }

    // Run initial translation (no-op if locale is English).
    _retranslate();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Translation
  // ─────────────────────────────────────────────────────────────────────────

  /// Re-translates all raw notification strings and rebuilds [_translated].
  /// Called on first load and every time the locale changes.
  Future<void> _retranslate() async {
    final result = await Future.wait(
      _raw.map(_translateNotification),
    );
    _translated = result;
    notifyListeners();
  }

  Future<NotificationModel> _translateNotification(
      NotificationModel n) async {
    final title = await t(n.rawTitle);
    final message = await t(n.rawMessage);
    return n.copyWith(displayTitle: title, displayMessage: message);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Actions
  // ─────────────────────────────────────────────────────────────────────────

  void markAllAsRead() {
    _translated = _translated.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  @override
  void dispose() {
    unbindLocaleRetranslation();
    super.dispose();
  }
}