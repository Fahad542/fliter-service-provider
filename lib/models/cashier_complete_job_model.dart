class CashierCompleteJobResponse {
  final bool success;
  final String message;
  final Commission? commission;

  CashierCompleteJobResponse({
    required this.success,
    required this.message,
    this.commission,
  });

  factory CashierCompleteJobResponse.fromJson(Map<String, dynamic> json) {
    return CashierCompleteJobResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      commission: json['commission'] != null
          ? Commission.fromJson(json['commission'])
          : null,
    );
  }
}

class Commission {
  final String technicianId;
  final String technicianName;
  final double commissionAmount;

  Commission({
    required this.technicianId,
    required this.technicianName,
    required this.commissionAmount,
  });

  factory Commission.fromJson(Map<String, dynamic> json) {
    return Commission(
      technicianId: json['technicianId']?.toString() ?? '',
      technicianName: json['technicianName'] ?? '',
      commissionAmount: (json['commissionAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
