import 'package:flutter/material.dart';

class CashierOrdersResponse {
  final bool success;
  final OrderStats stats;
  final int total;
  final int limit;
  final int offset;
  final List<PosOrder> orders;

  CashierOrdersResponse({
    required this.success,
    required this.stats,
    required this.total,
    required this.limit,
    required this.offset,
    required this.orders,
  });

  factory CashierOrdersResponse.fromJson(Map<String, dynamic> json) {
    return CashierOrdersResponse(
      success: json['success'] ?? false,
      stats: OrderStats.fromJson(json['stats'] ?? {}),
      total: json['total'] ?? 0,
      limit: json['limit'] ?? 50,
      offset: json['offset'] ?? 0,
      orders: (json['orders'] as List?)
              ?.map((o) => PosOrder.fromJson(o))
              .toList() ??
          [],
    );
  }
}

class OrderStats {
  final int total;
  final int draft;
  final int inProgress;
  final int readyForInvoice;
  final int invoiced;
  final int cancelled;

  OrderStats({
    required this.total,
    required this.draft,
    required this.inProgress,
    required this.readyForInvoice,
    required this.invoiced,
    required this.cancelled,
  });

  factory OrderStats.fromJson(Map<String, dynamic> json) {
    return OrderStats(
      total: json['total'] ?? 0,
      draft: json['draft'] ?? 0,
      inProgress: json['in_progress'] ?? 0,
      readyForInvoice: json['ready_for_invoice'] ?? 0,
      invoiced: json['invoiced'] ?? 0,
      cancelled: json['cancelled'] ?? 0,
    );
  }

  factory OrderStats.empty() => OrderStats(
        total: 0,
        draft: 0,
        inProgress: 0,
        readyForInvoice: 0,
        invoiced: 0,
        cancelled: 0,
      );
}

class PosOrder {
  final String id;
  final String status;
  final String source;
  final int odometerReading;
  final String createdAt;
  final OrderCustomer? customer;
  final OrderVehicle? vehicle;
  final int jobsCount;

  PosOrder({
    required this.id,
    required this.status,
    required this.source,
    required this.odometerReading,
    required this.createdAt,
    this.customer,
    this.vehicle,
    required this.jobsCount,
  });

  factory PosOrder.fromJson(Map<String, dynamic> json) {
    return PosOrder(
      id: json['id']?.toString() ?? '',
      status: json['status'] ?? '',
      source: json['source'] ?? '',
      odometerReading: json['odometerReading'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      customer: json['customer'] != null
          ? OrderCustomer.fromJson(json['customer'])
          : null,
      vehicle: json['vehicle'] != null
          ? OrderVehicle.fromJson(json['vehicle'])
          : null,
      jobsCount: json['jobsCount'] ?? 0,
    );
  }

  PosOrder copyWith({
    String? id,
    String? status,
    String? source,
    int? odometerReading,
    String? createdAt,
    OrderCustomer? customer,
    OrderVehicle? vehicle,
    int? jobsCount,
  }) {
    return PosOrder(
      id: id ?? this.id,
      status: status ?? this.status,
      source: source ?? this.source,
      odometerReading: odometerReading ?? this.odometerReading,
      createdAt: createdAt ?? this.createdAt,
      customer: customer ?? this.customer,
      vehicle: vehicle ?? this.vehicle,
      jobsCount: jobsCount ?? this.jobsCount,
    );
  }

  String get customerName => customer?.name ?? 'Unknown';
  String get carModel => '${vehicle?.make ?? ""} ${vehicle?.model ?? ""}'.trim();
  String get plateNumber => vehicle?.plateNo ?? '';
  String get date => createdAt.isNotEmpty 
      ? createdAt.split('T')[0] 
      : '';
  double get totalAmount => 0.0; // API doesn't provide total in this list
  List<String> get services => []; // API doesn't provide services in this list

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'invoiced':
      case 'completed':
        return const Color(0xFF27AE60);
      case 'draft':
        return const Color(0xFFF2994A);
      case 'in_progress':
      case 'ready_for_invoice':
        return const Color(0xFF2D9CDB); // Professional blue
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get statusText {
    final s = status.toLowerCase();
    if (s == 'draft') return 'Draft';
    if (s == 'in_progress') return 'In Progress';
    if (s == 'ready_for_invoice') return 'Ready for Invoice';
    if (s == 'invoiced' || s == 'completed') return 'Completed';
    return status.replaceAll('_', ' ').toUpperCase();
  }
}

class OrderCustomer {
  final String id;
  final String name;
  final String mobile;

  OrderCustomer({
    required this.id,
    required this.name,
    required this.mobile,
  });

  factory OrderCustomer.fromJson(Map<String, dynamic> json) {
    return OrderCustomer(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      mobile: json['mobile'] ?? '',
    );
  }
}

class OrderVehicle {
  final String id;
  final String plateNo;
  final String make;
  final String model;

  OrderVehicle({
    required this.id,
    required this.plateNo,
    required this.make,
    required this.model,
  });

  factory OrderVehicle.fromJson(Map<String, dynamic> json) {
    return OrderVehicle(
      id: json['id']?.toString() ?? '',
      plateNo: json['plateNo'] ?? '',
      make: json['make'] ?? '',
      model: json['model'] ?? '',
    );
  }
}
