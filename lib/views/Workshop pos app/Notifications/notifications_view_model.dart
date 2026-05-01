import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/repositories/workshop_notifications_repository.dart';
import '../../../services/session_service.dart';

/// Cashier POS inbox item (from GET /workshop-notifications/inbox).
class PosNotificationRow {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final String rawType;

  PosNotificationRow({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
    required this.rawType,
  });

  factory PosNotificationRow.fromJson(Map<String, dynamic> j) {
    final created =
        DateTime.tryParse(j['createdAt'] as String? ?? '') ?? DateTime.now();
    final unread = j['isUnread'] == true;
    return PosNotificationRow(
      id: j['id']?.toString() ?? '',
      title: j['title'] as String? ?? '',
      body: j['body'] as String? ?? '',
      createdAt: created,
      isRead: !unread,
      rawType: j['type'] as String? ?? '',
    );
  }

  IconData get icon {
    if (rawType.contains('invoiced')) return Icons.receipt_long_rounded;
    if (rawType.contains('job_accepted')) return Icons.engineering_outlined;
    return Icons.notifications_active_outlined;
  }

  String get timeLabel =>
      DateFormat('MMM d, yyyy · HH:mm').format(createdAt.toLocal());
}

class NotificationsViewModel extends ChangeNotifier {
  final SessionService sessionService = SessionService();
  final WorkshopNotificationsRepository _repo =
      WorkshopNotificationsRepository();

  static const String roleParam = 'cashier_user';

  final List<PosNotificationRow> _items = [];
  List<PosNotificationRow> get notifications => List.unmodifiable(_items);

  bool isLoading = false;
  String? errorMessage;
  int totalCount = 0;

  Future<void> refresh() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final token = await sessionService.getToken(role: 'cashier');
      if (token == null) {
        _items.clear();
        errorMessage = 'Not signed in';
        return;
      }
      final res = await _repo.listInbox(
        token: token,
        roleParam: roleParam,
        page: 1,
        limit: 100,
      );
      totalCount = (res['totalCount'] as num?)?.toInt() ?? 0;
      final raw = res['items'];
      _items
        ..clear()
        ..addAll((raw is List ? raw : const [])
            .map((e) => PosNotificationRow.fromJson(
                Map<String, dynamic>.from(e as Map)))
            .toList());
    } catch (e) {
      errorMessage = '$e';
      _items.clear();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markRead(String id) async {
    final token = await sessionService.getToken(role: 'cashier');
    if (token == null) return;
    try {
      await _repo.markRead(
        token: token,
        notificationId: id,
        roleParam: roleParam,
      );
      await refresh();
    } catch (_) {}
  }

  Future<void> deleteOne(String id) async {
    final token = await sessionService.getToken(role: 'cashier');
    if (token == null) return;
    try {
      await _repo.deleteOne(
        token: token,
        notificationId: id,
        roleParam: roleParam,
      );
      _items.removeWhere((e) => e.id == id);
      totalCount = (_items.length).clamp(0, totalCount);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> clearAll() async {
    final token = await sessionService.getToken(role: 'cashier');
    if (token == null) return;
    try {
      await _repo.clearAll(token: token, roleParam: roleParam);
      _items.clear();
      totalCount = 0;
      notifyListeners();
    } catch (_) {}
  }
}
