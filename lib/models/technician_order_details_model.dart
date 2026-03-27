class TechnicianOrderDetailsResponse {
  final bool success;
  final OrderDetailsData? order;

  TechnicianOrderDetailsResponse({
    required this.success,
    this.order,
  });

  factory TechnicianOrderDetailsResponse.fromJson(Map<String, dynamic> json) {
    return TechnicianOrderDetailsResponse(
      success: json['success'] ?? false,
      order: json['order'] != null ? OrderDetailsData.fromJson(json['order']) : null,
    );
  }
}

class OrderDetailsData {
  final String jobId;
  final String orderId;
  final String status;
  final String customerName;
  final String customerMobile;
  final String vehicle;
  final String plateNo;
  final String department;
  final String serviceType;
  final String arrivalTime;
  final double value;
  final double commission;
  final String? completedAt;
  final List<TechOrderDepartment> departments;

  OrderDetailsData({
    required this.jobId,
    required this.orderId,
    required this.status,
    required this.customerName,
    required this.customerMobile,
    required this.vehicle,
    required this.plateNo,
    required this.department,
    required this.serviceType,
    required this.arrivalTime,
    required this.value,
    required this.commission,
    this.completedAt,
    this.departments = const [],
  });

  factory OrderDetailsData.fromJson(Map<String, dynamic> json) {
    return OrderDetailsData(
      jobId: json['jobId']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      status: json['status'] ?? '',
      customerName: json['customerName'] ?? '',
      customerMobile: json['customerMobile'] ?? '',
      vehicle: json['vehicle'] ?? '',
      plateNo: json['plateNo'] ?? '',
      department: json['department'] ?? '',
      serviceType: json['serviceType'] ?? '',
      arrivalTime: json['arrivalTime']?.toString() ?? '',
      value: (json['value'] ?? 0).toDouble(),
      commission: (json['commission'] ?? 0).toDouble(),
      completedAt: json['completedAt']?.toString(),
      departments: (json['departments'] as List<dynamic>?)
              ?.map((d) => TechOrderDepartment.fromJson(d))
              .toList() ??
          [],
    );
  }
}

class TechOrderDepartment {
  final String name;
  final List<TechOrderItem> items;

  TechOrderDepartment({
    required this.name,
    this.items = const [],
  });

  factory TechOrderDepartment.fromJson(Map<String, dynamic> json) {
    return TechOrderDepartment(
      name: json['name'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((i) => TechOrderItem.fromJson(i))
              .toList() ??
          [],
    );
  }
}

class TechOrderItem {
  final String name;
  final String type;
  final num qty;
  final double price;

  TechOrderItem({
    required this.name,
    required this.type,
    required this.qty,
    required this.price,
  });

  factory TechOrderItem.fromJson(Map<String, dynamic> json) {
    return TechOrderItem(
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      qty: json['qty'] ?? 0,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
    );
  }
}
