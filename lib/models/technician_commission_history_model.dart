class CommissionHistoryResponse {
  final bool success;
  final int month;
  final int year;
  final int total;
  final int limit;
  final int offset;
  final List<CommissionEntry> entries;

  CommissionHistoryResponse({
    required this.success,
    required this.month,
    required this.year,
    required this.total,
    required this.limit,
    required this.offset,
    required this.entries,
  });

  factory CommissionHistoryResponse.fromJson(Map<String, dynamic> json) {
    return CommissionHistoryResponse(
      success: json['success'] ?? false,
      month: json['month'] ?? 0,
      year: json['year'] ?? 0,
      total: json['total'] ?? 0,
      limit: json['limit'] ?? 50,
      offset: json['offset'] ?? 0,
      entries: (json['entries'] as List<dynamic>?)
              ?.map((e) => CommissionEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

class CommissionEntry {
  final String orderId;
  final double commission;
  final String date;
  final String status;

  CommissionEntry({
    required this.orderId,
    required this.commission,
    required this.date,
    required this.status,
  });

  factory CommissionEntry.fromJson(Map<String, dynamic> json) {
    return CommissionEntry(
      orderId: 'ORD-${json['orderId']?.toString().replaceAll(RegExp(r'^ORD-'), '') ?? ''}',
      commission: (json['commission'] ?? 0.0).toDouble(),
      date: json['date'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
    );
  }
}
