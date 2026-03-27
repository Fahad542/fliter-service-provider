class CurrentSessionResponse {
  final bool success;
  final bool hasOpenSession;
  final CurrentSession? session;

  CurrentSessionResponse({
    required this.success,
    required this.hasOpenSession,
    this.session,
  });

  factory CurrentSessionResponse.fromJson(Map<String, dynamic> json) {
    return CurrentSessionResponse(
      success: json['success'] ?? false,
      hasOpenSession: json['hasOpenSession'] ?? false,
      session: json['session'] != null ? CurrentSession.fromJson(json['session']) : null,
    );
  }
}

class CurrentSession {
  final String posSessionId;
  final String branchId;
  final String branchName;
  final String branchAddress;
  final String cashierName;
  final String openedAt;
  final String status;
  final String elapsedTime;

  CurrentSession({
    required this.posSessionId,
    required this.branchId,
    required this.branchName,
    required this.branchAddress,
    required this.cashierName,
    required this.openedAt,
    required this.status,
    required this.elapsedTime,
  });

  factory CurrentSession.fromJson(Map<String, dynamic> json) {
    return CurrentSession(
      posSessionId: json['posSessionId']?.toString() ?? '',
      branchId: json['branchId']?.toString() ?? '',
      branchName: json['branchName']?.toString() ?? '',
      branchAddress: json['branchAddress']?.toString() ?? '',
      cashierName: json['cashierName']?.toString() ?? '',
      openedAt: json['openedAt']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      elapsedTime: (json['duration'] ?? json['elapsedTime'])?.toString() ?? '',
    );
  }
}
