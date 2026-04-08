class TechnicianAssignedOrdersResponse {
  final bool success;
  final int total;
  final int limit;
  final int offset;
  final List<AssignedOrder> orders;

  TechnicianAssignedOrdersResponse({
    required this.success,
    required this.total,
    required this.limit,
    required this.offset,
    required this.orders,
  });

  factory TechnicianAssignedOrdersResponse.fromJson(Map<String, dynamic> json) {
    return TechnicianAssignedOrdersResponse(
      success: json['success'] ?? false,
      total: json['total'] ?? 0,
      limit: json['limit'] ?? 100,
      offset: json['offset'] ?? 0,
      orders: json['orders'] != null
          ? (json['orders'] as List).map((i) => AssignedOrder.fromJson(i)).toList()
          : [],
    );
  }
}

class AssignedOrder {
  final String jobId;
  final String orderId;
  final String status;
  final String customerName;
  final String vehicle;
  final String plateNo;
  final String department;
  final double value;
  final double commission;
  final String assignmentStatus;
  final String source;
  final String submittedAt;
  final String orderDateTime;
  final String orderDate;
  final String orderTime;

  AssignedOrder({
    required this.jobId,
    required this.orderId,
    required this.status,
    required this.customerName,
    required this.vehicle,
    required this.plateNo,
    required this.department,
    required this.value,
    required this.commission,
    required this.assignmentStatus,
    this.source = '',
    this.submittedAt = '',
    this.orderDateTime = '',
    this.orderDate = '',
    this.orderTime = '',
  });

  factory AssignedOrder.fromJson(Map<String, dynamic> json) {
    return AssignedOrder(
      jobId: json['jobId']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      status: json['status'] ?? '',
      customerName: json['customerName'] ?? '',
      vehicle: json['vehicle'] ?? '',
      plateNo: json['plateNo'] ?? '',
      department: json['department'] ?? '',
      value: (json['value'] ?? 0).toDouble(),
      commission: (json['commission'] ?? 0).toDouble(),
      assignmentStatus: json['assignmentStatus'] ?? '',
      source: json['source']?.toString() ?? '',
      submittedAt: json['submittedAt']?.toString() ?? '',
      orderDateTime: json['orderDateTime']?.toString() ?? '',
      orderDate: json['orderDate']?.toString() ?? '',
      orderTime: json['orderTime']?.toString() ?? '',
    );
  }

  String get displayDate {
    if (orderDate.isNotEmpty) return orderDate;
    final iso = submittedAt.isNotEmpty ? submittedAt
        : orderDateTime.isNotEmpty ? orderDateTime : '';
    if (iso.isEmpty) return '';
    try {
      return DateTime.parse(iso).toLocal().toIso8601String().split('T')[0];
    } catch (_) {
      return iso.split('T')[0];
    }
  }

  String get displayTime {
    if (orderTime.isNotEmpty) {
      return orderTime.length >= 5 ? orderTime.substring(0, 5) : orderTime;
    }
    final iso = submittedAt.isNotEmpty ? submittedAt
        : orderDateTime.isNotEmpty ? orderDateTime : '';
    if (iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) {
      return '';
    }
  }
}
