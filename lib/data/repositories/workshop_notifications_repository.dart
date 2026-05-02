import '../network/api_constants.dart';
import '../network/base_api_service.dart';

/// Workshop POS + technician in-app notifications (`/workshop-notifications/*`).
class WorkshopNotificationsRepository {
  final BaseApiService _api = BaseApiService();

  Map<String, String> _headers(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  String _qp(Map<String, String> q) {
    if (q.isEmpty) return '';
    final u = Uri(queryParameters: q);
    return '?${u.query}';
  }

  Future<Map<String, dynamic>> listInbox({
    required String token,
    required String roleParam,
    int page = 1,
    int limit = 50,
    bool unreadOnly = false,
  }) async {
    final endpoint =
        '${ApiConstants.workshopNotificationsInbox}${_qp({
      'role': roleParam,
      'page': '$page',
      'limit': '$limit',
      if (unreadOnly) 'unreadOnly': 'true',
    })}';
    final res = await _api.get(endpoint, headers: _headers(token));
    return Map<String, dynamic>.from(res as Map);
  }

  Future<void> markRead({
    required String token,
    required String notificationId,
    required String roleParam,
  }) async {
    final endpoint =
        '${ApiConstants.workshopNotificationMarkRead(notificationId)}${_qp({'role': roleParam})}';
    await _api.patch(endpoint, {}, headers: _headers(token));
  }

  Future<void> deleteOne({
    required String token,
    required String notificationId,
    required String roleParam,
  }) async {
    final endpoint =
        '${ApiConstants.workshopNotificationDeleteOne(notificationId)}${_qp({'role': roleParam})}';
    await _api.delete(endpoint, headers: _headers(token));
  }

  Future<Map<String, dynamic>> clearAll({
    required String token,
    required String roleParam,
  }) async {
    final endpoint =
        '${ApiConstants.workshopNotificationsClearAll}${_qp({'role': roleParam})}';
    final res = await _api.delete(endpoint, headers: _headers(token));
    return Map<String, dynamic>.from(res as Map);
  }
}