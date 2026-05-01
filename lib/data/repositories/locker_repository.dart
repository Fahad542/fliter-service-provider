import '../network/api_constants.dart';
import '../network/base_api_service.dart';
import '../../models/locker_models.dart';
import '../../models/locker_financial_models.dart';

class LockerRepository {
  final BaseApiService _apiService = BaseApiService();

  // ── Dashboard ──────────────────────────────────────────────────────────────

  Future<LockerDashboardData> getDashboard({
    required String view,
    required String token,
  }) async {
    final response = await _apiService.get(
      '${ApiConstants.lockerDashboardEndpoint}?view=$view',
      headers: _authHeaders(token),
    );
    return LockerDashboardData.fromJson(response as Map<String, dynamic>);
  }

  // ── Collection requests list ───────────────────────────────────────────────

  Future<LockerRequestsPage> getCollectionRequests({
    required String token,
    String? view,
    String? status,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, String>{
      'page': '$page',
      'limit': '$limit',
      if (view != null && view.isNotEmpty) 'view': view,
      if (status != null && status.isNotEmpty) 'status': status,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.lockerCollectionRequestsEndpoint}',
    ).replace(queryParameters: params);

    debugLog('[LockerRepo] GET $uri');

    final response = await _apiService.get(
      '${ApiConstants.lockerCollectionRequestsEndpoint}?${uri.query}',
      headers: _authHeaders(token),
    );

    return LockerRequestsPage.fromJson(response as Map<String, dynamic>);
  }

  // ── Single request detail ──────────────────────────────────────────────────

  Future<LockerRequestDetail> getRequestDetail({
    required String token,
    required String requestId,
  }) async {
    final endpoint =
        '${ApiConstants.lockerCollectionRequestsEndpoint}/$requestId';
    debugLog('[LockerRepo] GET $endpoint');
    final response = await _apiService.get(
      endpoint,
      headers: _authHeaders(token),
    );
    return LockerRequestDetail.fromJson(response as Map<String, dynamic>);
  }

  // ── Field officers ─────────────────────────────────────────────────────────

  Future<List<LockerOfficer>> getFieldOfficers({
    required String token,
  }) async {
    debugLog('[LockerRepo] GET ${ApiConstants.lockerFieldOfficersEndpoint}');
    final response = await _apiService.get(
      ApiConstants.lockerFieldOfficersEndpoint,
      headers: _authHeaders(token),
    );
    final json = response as Map<String, dynamic>;
    final rawList = json['officers'] as List<dynamic>? ?? [];
    return rawList
        .map((e) => LockerOfficer.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Assign officer ─────────────────────────────────────────────────────────

  Future<String> assignOfficer({
    required String token,
    required String requestId,
    required String officerUserId,
  }) async {
    final endpoint =
        '${ApiConstants.lockerCollectionRequestsEndpoint}/$requestId/assign';
    debugLog('[LockerRepo] PATCH $endpoint  officerUserId=$officerUserId');
    final response = await _apiService.patch(
      endpoint,
      {'officerUserId': officerUserId},
      headers: _authHeaders(token),
    );
    final json = response as Map<String, dynamic>;
    if (json['success'] != true) {
      throw Exception(json['message'] ?? 'Assignment failed');
    }
    return json['assignedOfficerId']?.toString() ?? officerUserId;
  }

  // ── Record collection ──────────────────────────────────────────────────────

  Future<CollectionResult> recordCollection({
    required String token,
    required String requestId,
    required double receivedAmount,
    String notes = '',
    String proofUrl = '',
  }) async {
    debugLog(
      '[LockerRepo] POST ${ApiConstants.lockerRecordCollectionEndpoint} '
          'requestId=$requestId receivedAmount=$receivedAmount',
    );
    final response = await _apiService.post(
      ApiConstants.lockerRecordCollectionEndpoint,
      {
        'requestId': requestId,
        'receivedAmount': receivedAmount,
        'notes': notes,
        'proofUrl': proofUrl,
      },
      headers: _authHeaders(token),
    );
    final json = response as Map<String, dynamic>;
    if (json['success'] != true) {
      throw Exception(json['message'] ?? 'Collection recording failed');
    }
    return CollectionResult.fromJson(json);
  }

  // ── Variance approvals list ────────────────────────────────────────────────

  Future<List<LockerVarianceApproval>> getApprovals({
    required String token,
  }) async {
    debugLog('[LockerRepo] GET ${ApiConstants.lockerApprovalsEndpoint}');
    final response = await _apiService.get(
      ApiConstants.lockerApprovalsEndpoint,
      headers: _authHeaders(token),
    );
    final json = response as Map<String, dynamic>;
    if (json['success'] != true) {
      throw Exception(json['message'] ?? 'Failed to load approvals');
    }
    final rawList = json['approvals'] as List<dynamic>? ?? [];
    return rawList
        .map((e) => LockerVarianceApproval.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Approve / reject variance ──────────────────────────────────────────────

  Future<LockerApprovalResult> approveDifference({
    required String token,
    required String collectionId,
    required String status,
    String rejectionReason = '',
  }) async {
    assert(status == 'approved' || status == 'rejected',
    'status must be "approved" or "rejected"');
    debugLog(
      '[LockerRepo] POST ${ApiConstants.lockerApproveDifferenceEndpoint} '
          'collectionId=$collectionId status=$status',
    );
    final response = await _apiService.post(
      ApiConstants.lockerApproveDifferenceEndpoint,
      {
        'collectionId': collectionId,
        'status': status,
        'rejectionReason': rejectionReason,
      },
      headers: _authHeaders(token),
    );
    final json = response as Map<String, dynamic>;
    if (json['success'] != true) {
      throw Exception(json['message'] ?? 'Operation failed');
    }
    return LockerApprovalResult.fromJson(json);
  }

  // ── Branches list ──────────────────────────────────────────────────────────

  Future<List<LockerBranch>> getBranches({
    required String token,
  }) async {
    debugLog('[LockerRepo] GET ${ApiConstants.lockerBranchesEndpoint}');
    final response = await _apiService.get(
      ApiConstants.lockerBranchesEndpoint,
      headers: _authHeaders(token),
    );
    final json = response as Map<String, dynamic>;
    final rawList = json['branches'] as List<dynamic>? ?? [];
    return rawList
        .map((e) => LockerBranch.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Financial history ──────────────────────────────────────────────────────

  Future<AuditLogPage> getFinancialHistory({
    required String token,
    String? search,
    String? branchId,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, String>{
      'page': '$page',
      'limit': '$limit',
      if (search != null && search.isNotEmpty) 'search': search,
      'branchId': (branchId != null && branchId.isNotEmpty) ? branchId : 'all',
      if (from != null) 'from': _fmtDate(from),
      if (to != null) 'to': _fmtDate(to),
    };

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.lockerFinancialHistoryEndpoint}',
    ).replace(queryParameters: params);

    debugLog('[LockerRepo] GET $uri');

    final response = await _apiService.get(
      '${ApiConstants.lockerFinancialHistoryEndpoint}?${uri.query}',
      headers: _authHeaders(token),
    );

    return AuditLogPage.fromJson(response as Map<String, dynamic>);
  }

  // ── Financial analytics ────────────────────────────────────────────────────

  Future<LockerAnalyticsData> getFinancialAnalytics({
    required String token,
    DateTime? from,
    DateTime? to,
  }) async {
    final params = <String, String>{
      if (from != null) 'from': _fmtDate(from),
      if (to != null) 'to': _fmtDate(to),
    };

    String endpoint = ApiConstants.lockerFinancialAnalyticsEndpoint;
    if (params.isNotEmpty) {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint')
          .replace(queryParameters: params);
      endpoint = '$endpoint?${uri.query}';
    }

    debugLog('[LockerRepo] GET ${ApiConstants.baseUrl}$endpoint');

    final response = await _apiService.get(
      endpoint,
      headers: _authHeaders(token),
    );

    return LockerAnalyticsData.fromJson(response as Map<String, dynamic>);
  }

  // ── Notifications ──────────────────────────────────────────────────────────

  /// GET /locker/get_notifications/:page/:limit[?unreadOnly=true]
  ///
  /// Uses path-based pagination. Pass [unreadOnly] = true to filter to unread
  /// notifications only (maps to ?unreadOnly=true query param).
  Future<LockerNotificationsPage> getNotifications({
    required String token,
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    // Build path: /locker/get_notifications/:page/:limit
    String endpoint = ApiConstants.lockerGetNotificationsEndpoint(page, limit);

    // Append optional query param
    if (unreadOnly) {
      endpoint = '$endpoint?unreadOnly=true';
    }

    final fullUrl = '${ApiConstants.baseUrl}$endpoint';
    debugLog('[LockerRepo] GET $fullUrl  unreadOnly=$unreadOnly');

    final response = await _apiService.get(
      endpoint,
      headers: _authHeaders(token),
    );

    final json = response as Map<String, dynamic>;

    if (json['success'] == false) {
      // Server explicitly returned a failure payload
      final msg = json['message'] as String? ?? 'Failed to load notifications';
      debugLog('[LockerRepo] getNotifications server error: $msg');
      throw FetchDataException(msg);
    }

    return LockerNotificationsPage.fromJson(json);
  }

  /// POST /locker/notifications/mark-read
  ///
  /// Marks all notifications as read on the server.
  /// Returns true on success.
  Future<bool> markAllNotificationsRead({
    required String token,
  }) async {
    debugLog(
        '[LockerRepo] POST ${ApiConstants.lockerNotificationsMarkReadEndpoint}');
    final response = await _apiService.post(
      ApiConstants.lockerNotificationsMarkReadEndpoint,
      <String, dynamic>{},
      headers: _authHeaders(token),
    );
    final json = response as Map<String, dynamic>;
    return json['success'] as bool? ?? false;
  }

  /// POST /locker/notifications/:id/mark-read
  ///
  /// Marks a single notification as read. Returns true on success.
  Future<bool> markNotificationRead({
    required String token,
    required String notificationId,
  }) async {
    final endpoint =
        '${ApiConstants.lockerNotificationsEndpoint}/$notificationId/mark-read';
    debugLog('[LockerRepo] POST $endpoint');
    final response = await _apiService.post(
      endpoint,
      <String, dynamic>{},
      headers: _authHeaders(token),
    );
    final json = response as Map<String, dynamic>;
    return json['success'] as bool? ?? false;
  }

  // ── Shared ─────────────────────────────────────────────────────────────────

  Map<String, String> _authHeaders(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  String _fmtDate(DateTime dt) => dt.toUtc().toIso8601String();
}

/// Thin debug logger — stripped from release builds automatically.
void debugLog(String msg) {
  assert(() {
    // ignore: avoid_print
    print(msg);
    return true;
  }());
}

// ── New models for variance approvals ─────────────────────────────────────────

class LockerVarianceApproval {
  final String id;
  final String branchName;
  final String cashierName;
  final String officerName;
  final double expectedAmount;
  final double receivedAmount;
  final double difference;
  final String varianceStatus;
  final String notes;
  final DateTime date;

  const LockerVarianceApproval({
    required this.id,
    required this.branchName,
    required this.cashierName,
    required this.officerName,
    required this.expectedAmount,
    required this.receivedAmount,
    required this.difference,
    required this.varianceStatus,
    required this.notes,
    required this.date,
  });

  factory LockerVarianceApproval.fromJson(Map<String, dynamic> j) {
    return LockerVarianceApproval(
      id             : j['id']?.toString() ?? '',
      branchName     : j['branchName']  as String? ?? '',
      cashierName    : j['cashierName'] as String? ?? '',
      officerName    : j['officerName'] as String? ?? '',
      expectedAmount : double.tryParse(j['expectedAmount']?.toString() ?? '0') ?? 0,
      receivedAmount : double.tryParse(j['receivedAmount']?.toString() ?? '0') ?? 0,
      difference     : double.tryParse(j['difference']?.toString()     ?? '0') ?? 0,
      varianceStatus : j['status'] as String? ?? '',
      notes          : j['notes']  as String? ?? '',
      date           : DateTime.tryParse(j['date'] as String? ?? '') ?? DateTime.now(),
    );
  }

  bool get isShort => varianceStatus == 'short';
  bool get isOver  => varianceStatus == 'over';
}

class LockerBranch {
  final String id;
  final String name;
  final String address;
  final String? branchCode;

  const LockerBranch({
    required this.id,
    required this.name,
    required this.address,
    this.branchCode,
  });

  factory LockerBranch.fromJson(Map<String, dynamic> j) {
    return LockerBranch(
      id        : j['id']?.toString() ?? '',
      name      : j['name']       as String? ?? '',
      address   : j['address']    as String? ?? '',
      branchCode: j['branchCode'] as String?,
    );
  }

  @override
  String toString() => name;
}

class LockerApprovalResult {
  final bool success;
  final String message;
  final String collectionId;
  final String status;

  const LockerApprovalResult({
    required this.success,
    required this.message,
    required this.collectionId,
    required this.status,
  });

  factory LockerApprovalResult.fromJson(Map<String, dynamic> j) {
    return LockerApprovalResult(
      success      : j['success']      as bool?   ?? false,
      message      : j['message']      as String? ?? '',
      collectionId : j['collectionId']?.toString() ?? '',
      status       : j['status']       as String? ?? '',
    );
  }
}