import 'package:flutter/material.dart';

class NotificationModel {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final bool isRead;

  NotificationModel({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    this.isRead = false,
  });
}

class NotificationsViewModel extends ChangeNotifier {
  final List<NotificationModel> _notifications = [
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

  List<NotificationModel> get notifications => _notifications;

  void markAllAsRead() {
    // Logic to mark all as read could go here
    notifyListeners();
  }
}
