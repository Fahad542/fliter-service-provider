import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../services/locker_translation_mixin.dart';

class NotificationModel {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final bool isRead;

  const NotificationModel({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    this.isRead = false,
  });

  NotificationModel copyWith({
    String? title,
    String? message,
    String? time,
    IconData? icon,
    bool? isRead,
  }) {
    return NotificationModel(
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      icon: icon ?? this.icon,
      isRead: isRead ?? this.isRead,
    );
  }
}

class NotificationsViewModel extends ChangeNotifier with TranslatableMixin {
  final List<NotificationModel> _rawNotifications = const [
    NotificationModel(
      title: 'New Order Received',
      message: 'Order #ORD-1024 has been placed by Ali Khan.',
      time: '02:45 PM',
      icon: Icons.shopping_basket_outlined,
    ),
    NotificationModel(
      title: 'Low Stock Alert',
      message: 'Castrol Engine Oil (5L) is below threshold (5 left).',
      time: '11:20 AM',
      icon: Icons.warning_amber_rounded,
    ),
    NotificationModel(
      title: 'Technician Assigned',
      message: 'M. Sheraz has been assigned to Order #ORD-1022.',
      time: '09:15 AM',
      icon: Icons.engineering_outlined,
      isRead: true,
    ),
    NotificationModel(
      title: 'System Update',
      message: 'A new version of the POS system is available.',
      time: 'Yesterday',
      icon: Icons.system_update_outlined,
      isRead: true,
    ),
    NotificationModel(
      title: 'Promotion Active',
      message: 'Promo Code WELCOME20 is now active for all branches.',
      time: '05 Feb 2026',
      icon: Icons.local_offer_outlined,
      isRead: true,
    ),
  ];

  List<NotificationModel> _notifications = const [];
  int _translationGeneration = 0;

  NotificationsViewModel() {
    _notifications = List<NotificationModel>.from(_rawNotifications);
    retranslate();
  }

  List<NotificationModel> get notifications => _notifications;

  /// Bind this ViewModel from the screen/provider that owns SettingsViewModel.
  /// Example: vm.bindSettingsViewModel(context.read<SettingsViewModel>());
  void bindSettingsViewModel(Listenable settingsViewModel) {
    bindLocaleRetranslation(settingsViewModel, retranslate);
  }

  Future<void> retranslate() async {
    final generation = ++_translationGeneration;
    final translated = await Future.wait(
      _rawNotifications.map((notification) async {
        return notification.copyWith(
          title: await t(notification.title),
          message: await t(notification.message),
          time: await t(notification.time),
        );
      }),
    );
    if (generation != _translationGeneration) return;
    _notifications = translated;
    notifyListeners();
  }

  void markAllAsRead() {
    _notifications = _notifications
        .map((notification) => notification.copyWith(isRead: true))
        .toList(growable: false);
    notifyListeners();
  }

  @override
  void dispose() {
    unbindLocaleRetranslation();
    super.dispose();
  }
}
