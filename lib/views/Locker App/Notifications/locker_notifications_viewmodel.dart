import 'package:flutter/material.dart';

import '../../../data/network/api_response.dart';
import '../../../data/repositories/locker_repository.dart';
import '../../../models/locker_models.dart';
import '../../../services/locker_translation_mixin.dart';

class LockerNotificationsViewModel extends ChangeNotifier
    with LockerTranslatableMixin {
  final String token;

  LockerNotificationsViewModel({required this.token});

  final LockerRepository _repository = LockerRepository();

  // ── State ─────────────────────────────────────────────────────────────────

  ApiResponse<List<LockerNotification>> _state = ApiResponse.loading();
  ApiResponse<List<LockerNotification>> get state => _state;

  List<LockerNotification> _notifications = [];
  List<LockerNotification> get notifications =>
      List.unmodifiable(_notifications);

  // Prefer the server-supplied unread count when available (page.unreadCount),
  // fall back to counting locally.
  int _serverUnreadCount = 0;
  int get unreadCount =>
      _serverUnreadCount > 0
          ? _serverUnreadCount
          : _notifications.where((n) => n.isUnread).length;

  String? get errorMessage => _state.message;

  bool _loadingMore = false;
  bool get isLoadingMore => _loadingMore;

  int _page = 1;
  bool _hasMore = true;

  // ── Public API ────────────────────────────────────────────────────────────

  Future<void> fetchNotifications() async {
    _page = 1;
    _hasMore = true;
    _notifications = [];
    _serverUnreadCount = 0;
    _state = ApiResponse.loading();
    notifyListeners();

    try {
      // Repository returns LockerNotificationsPage, not a raw List
      final page = await _repository.getNotifications(
        token: token,
        page: _page,
      );

      _serverUnreadCount = page.unreadCount;
      _hasMore = _notifications.length + page.items.length < page.total;

      // Translate title + body for every notification
      final translated = await _translateAll(page.items);
      _notifications = translated;
      _state = ApiResponse.completed(_notifications);
    } catch (e) {
      _state = ApiResponse.error(e.toString());
    }

    notifyListeners();
  }

  Future<void> refresh() => fetchNotifications();

  Future<void> loadMore() async {
    if (_loadingMore || !_hasMore) return;
    _loadingMore = true;
    notifyListeners();

    try {
      final page = await _repository.getNotifications(
        token: token,
        page: _page + 1,
      );

      if (page.items.isEmpty) {
        _hasMore = false;
      } else {
        final translated = await _translateAll(page.items);
        _notifications = [..._notifications, ...translated];
        _page++;
        _hasMore = _notifications.length < page.total;
      }
    } catch (_) {
      // Silently ignore load-more errors; existing list stays visible.
    }

    _loadingMore = false;
    notifyListeners();
  }

  /// Marks a notification read optimistically; reverts on network failure.
  Future<void> markOneRead(String notificationId) async {
    final idx =
    _notifications.indexWhere((n) => n.id == notificationId);
    if (idx == -1 || !_notifications[idx].isUnread) return;

    // Optimistic update — model provides markRead() instead of copyWith()
    _notifications[idx] = _notifications[idx].markRead();
    if (_serverUnreadCount > 0) _serverUnreadCount--;
    notifyListeners();

    try {
      await _repository.markNotificationRead(
          token: token, notificationId: notificationId);
    } catch (_) {
      // Revert: restore the isUnread flag by rebuilding the item
      _notifications[idx] = LockerNotification(
        id      : _notifications[idx].id,
        title   : _notifications[idx].title,
        body    : _notifications[idx].body,
        time    : _notifications[idx].time,
        type    : _notifications[idx].type,
        isUnread: true,
        translatedTitle: _notifications[idx].translatedTitle,
        translatedBody : _notifications[idx].translatedBody,
      );
      _serverUnreadCount++;
      notifyListeners();
    }
  }

  // ── Translation helpers ───────────────────────────────────────────────────

  /// Translates title + body of each notification via LockerTranslatableMixin.
  /// Uses translatedTitle / translatedBody fields that already exist on the model.
  Future<List<LockerNotification>> _translateAll(
      List<LockerNotification> items) async {
    return Future.wait(items.map(_translateOne));
  }

  Future<LockerNotification> _translateOne(LockerNotification n) async {
    final translatedTitle = await t(n.title);
    final translatedBody  = await t(n.body);

    // Rebuild with translated fields — model has no copyWith, use constructor
    return LockerNotification(
      id      : n.id,
      title   : translatedTitle,   // display field overwritten with translation
      body    : translatedBody,
      time    : n.time,
      type    : n.type,
      isUnread: n.isUnread,
      translatedTitle: translatedTitle,
      translatedBody : translatedBody,
    );
  }
}