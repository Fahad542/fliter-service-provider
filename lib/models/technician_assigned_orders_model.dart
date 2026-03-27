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
    );
  }
}
