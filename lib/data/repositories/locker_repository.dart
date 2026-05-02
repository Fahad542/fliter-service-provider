import '../../models/locker_financial_models.dart';
import '../../models/locker_models.dart';
import '../network/api_constants.dart';
import '../network/base_api_service.dart';

export '../../models/locker_models.dart' show LockerBranch, LockerVarianceApproval;

/// Locker portal API wrapper (dashboard, requests, financials, notifications).
class LockerRepository {
  final BaseApiService _apiService = BaseApiService();

  Map<String, String> _auth(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  Map<String, dynamic> _asJsonMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    throw FetchDataException('Unexpected response shape');
  }

  /// Prefer `data` when the backend wraps payloads.
  Map<String, dynamic> _preferData(Map<String, dynamic> root) {
    final data = root['data'];
    if (data is Map<String, dynamic>) return data;
    return root;
  }

  List<dynamic> _extractList(dynamic raw) {
    if (raw is List<dynamic>) return raw;
    if (raw is Map<String, dynamic>) {
      final nested = raw['data'];
      if (nested is List<dynamic>) return nested;
      final items = raw['items'] ??
          raw['branches'] ??
          raw['approvals'] ??
          raw['officers'];
      if (items is List<dynamic>) return items;
    }
    return const [];
  }

  Future<LockerDashboardData> getDashboard({
    required String view,
    required String token,
  }) async {
    final raw = await _apiService.getWithQueryParams(
      ApiConstants.lockerDashboardEndpoint,
      {'view': view},
      token,
    );
    return LockerDashboardData.fromJson(_preferData(_asJsonMap(raw)));
  }

  Future<LockerRequestsPage> getCollectionRequests({
    required String token,
    required String view,
    String? status,
    String? search,
    required int page,
    required int limit,
  }) async {
    final params = <String, String>{
      'view': view,
      'page': '$page',
      'limit': '$limit',
    };
    if (status != null && status.isNotEmpty) params['status'] = status;
    if (search != null && search.isNotEmpty) params['search'] = search;

    final raw = await _apiService.getWithQueryParams(
      ApiConstants.lockerCollectionRequestsEndpoint,
      params,
      token,
    );
    return LockerRequestsPage.fromJson(_preferData(_asJsonMap(raw)));
  }

  Future<LockerRequestDetail> getRequestDetail({
    required String token,
    required String requestId,
  }) async {
    final raw = await _apiService.get(
      ApiConstants.lockerCollectionRequestById(requestId),
      headers: _auth(token),
    );
    return LockerRequestDetail.fromJson(_preferData(_asJsonMap(raw)));
  }

  Future<String> assignOfficer({
    required String token,
    required String requestId,
    required String officerUserId,
  }) async {
    final raw = await _apiService.post(
      ApiConstants.lockerAssignOfficerEndpoint(requestId),
      {'officerUserId': officerUserId},
      headers: _auth(token),
    );
    final map = _preferData(_asJsonMap(raw));
    final returned =
        map['assignedOfficerId'] ?? map['officerUserId'] ?? map['officerId'];
    return returned?.toString() ?? officerUserId;
  }

  Future<CollectionResult> recordCollection({
    required String token,
    required String requestId,
    required double receivedAmount,
    required String notes,
    required String proofUrl,
  }) async {
    final raw = await _apiService.post(
      ApiConstants.lockerRecordCollectionEndpoint,
      {
        'requestId': requestId,
        'receivedAmount': receivedAmount,
        'notes': notes,
        'proofUrl': proofUrl,
      },
      headers: _auth(token),
    );
    return CollectionResult.fromJson(_preferData(_asJsonMap(raw)));
  }

  Future<void> approveDifference({
    required String token,
    required String collectionId,
    required String status,
    required String rejectionReason,
  }) async {
    await _apiService.post(
      ApiConstants.lockerApproveDifferenceEndpoint,
      {
        'collectionId': collectionId,
        'status': status,
        'rejectionReason': rejectionReason,
      },
      headers: _auth(token),
    );
  }

  Future<AuditLogPage> getFinancialHistory({
    required String token,
    String? search,
    String? branchId,
    DateTime? from,
    DateTime? to,
    required int page,
    required int limit,
  }) async {
    final params = <String, String>{
      'page': '$page',
      'limit': '$limit',
    };
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (branchId != null && branchId.isNotEmpty) params['branchId'] = branchId;
    if (from != null) params['from'] = from.toUtc().toIso8601String();
    if (to != null) params['to'] = to.toUtc().toIso8601String();

    final raw = await _apiService.getWithQueryParams(
      ApiConstants.lockerFinancialHistoryEndpoint,
      params,
      token,
    );
    return AuditLogPage.fromJson(_preferData(_asJsonMap(raw)));
  }

  Future<LockerAnalyticsData> getFinancialAnalytics({
    required String token,
    DateTime? from,
    DateTime? to,
  }) async {
    final params = <String, String>{};
    if (from != null) params['from'] = from.toUtc().toIso8601String();
    if (to != null) params['to'] = to.toUtc().toIso8601String();

    final raw = await _apiService.getWithQueryParams(
      ApiConstants.lockerFinancialAnalyticsEndpoint,
      params,
      token,
    );
    return LockerAnalyticsData.fromJson(_preferData(_asJsonMap(raw)));
  }

  Future<List<LockerBranch>> getBranches({required String token}) async {
    final raw = await _apiService.get(
      ApiConstants.lockerBranchesEndpoint,
      headers: _auth(token),
    );
    final list = _extractList(raw);
    return list
        .map((e) => LockerBranch.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<LockerVarianceApproval>> getApprovals(
      {required String token}) async {
    final raw = await _apiService.get(
      ApiConstants.lockerApprovalsEndpoint,
      headers: _auth(token),
    );
    final list = _extractList(raw);
    return list
        .map((e) =>
        LockerVarianceApproval.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<LockerNotificationsPage> getNotifications({
    required String token,
    required int page,
    int limit = 20,
  }) async {
    final endpoint = ApiConstants.lockerGetNotificationsEndpoint(page, limit);
    final raw = await _apiService.get(endpoint, headers: _auth(token));
    return LockerNotificationsPage.fromJson(_preferData(_asJsonMap(raw)));
  }

  Future<void> markNotificationRead({
    required String token,
    required String notificationId,
  }) async {
    await _apiService.post(
      ApiConstants.lockerNotificationsMarkReadEndpoint,
      {'notificationId': notificationId},
      headers: _auth(token),
    );
  }

  Future<List<LockerOfficer>> getFieldOfficers({required String token}) async {
    final raw = await _apiService.get(
      ApiConstants.lockerFieldOfficersEndpoint,
      headers: _auth(token),
    );
    final list = _extractList(raw);
    return list
        .map((e) => LockerOfficer.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}