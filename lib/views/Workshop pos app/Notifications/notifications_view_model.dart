import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/repositories/workshop_notifications_repository.dart';
import '../../../services/locker_translation_mixin.dart';
import '../../../services/session_service.dart';
import '../More Tab/settings_view_model.dart';

/// Cashier POS inbox row (GET /workshop-notifications/inbox).
/// Keeps [rawTitle] / [rawBody] from the API for re-translation when locale changes;
/// [title] / [body] getters expose localized display strings when locale is Arabic.
class PosNotificationRow {
  final String id;
  final String rawTitle;
  final String rawBody;
  final String displayTitle;
  final String displayBody;
  final DateTime createdAt;
  final bool isRead;
  final String rawType;

  PosNotificationRow({
    required this.id,
    required this.rawTitle,
    required this.rawBody,
    required this.displayTitle,
    required this.displayBody,
    required this.createdAt,
    required this.isRead,
    required this.rawType,
  });

  /// Title shown in the list (localized when app locale is Arabic).
  String get title => displayTitle;

  /// Body shown in the list (localized when app locale is Arabic).
  String get body => displayBody;

  factory PosNotificationRow.fromJson(Map<String, dynamic> j) {
    final created =
        DateTime.tryParse(j['createdAt'] as String? ?? '') ?? DateTime.now();
    final unread = j['isUnread'] == true;
    final rt = j['title'] as String? ?? '';
    final rb = j['body'] as String? ?? '';
    return PosNotificationRow(
      id: j['id']?.toString() ?? '',
      rawTitle: rt,
      rawBody: rb,
      displayTitle: rt,
      displayBody: rb,
      createdAt: created,
      isRead: !unread,
      rawType: j['type'] as String? ?? '',
    );
  }

  PosNotificationRow copyWith({
    bool? isRead,
    String? displayTitle,
    String? displayBody,
  }) {
    return PosNotificationRow(
      id: id,
      rawTitle: rawTitle,
      rawBody: rawBody,
      displayTitle: displayTitle ?? this.displayTitle,
      displayBody: displayBody ?? this.displayBody,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      rawType: rawType,
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

class NotificationsViewModel extends ChangeNotifier with TranslatableMixin {
  final SessionService sessionService = SessionService();
  final WorkshopNotificationsRepository _repo =
      WorkshopNotificationsRepository();
  final SettingsViewModel settingsViewModel;

  static const String roleParam = 'cashier_user';

  final List<PosNotificationRow> _items = [];
  List<PosNotificationRow> get notifications => List.unmodifiable(_items);

  bool isLoading = false;
  String? errorMessage;
  int totalCount = 0;

  NotificationsViewModel({required this.settingsViewModel}) {
    settingsViewModel.addListener(_onLocaleChanged);
  }

  Future<void> _onLocaleChanged() async {
    if (_items.isEmpty) return;
    await _applyTranslations();
    notifyListeners();
  }

  /// Re-applies dynamic translation using [rawTitle] / [rawBody] from each row.
  Future<void> _applyTranslations() async {
    if (_items.isEmpty) return;
    final translated = await Future.wait(
      _items.map((r) async {
        final tTitle = await t(r.rawTitle);
        final tBody = await t(r.rawBody);
        return r.copyWith(displayTitle: tTitle, displayBody: tBody);
      }),
    );
    _items
      ..clear()
      ..addAll(translated);
  }

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
      await _applyTranslations();
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

  @override
  void dispose() {
    settingsViewModel.removeListener(_onLocaleChanged);
    super.dispose();
  }
}
