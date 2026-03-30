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
      orders:
          (json['orders'] as List?)
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
      inProgress: json['in progress'] ?? json['in_progress'] ?? 0,
      readyForInvoice: json['ready_for_invoice'] ?? 0,
      invoiced: json['invoiced'] ?? json['completed'] ?? 0,
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

class PosOrderJob {
  final String id;
  final String status;
  final String department;
  final List<PosOrderJobItem> items;
  final List<JobTechnician> technicians;
  
  // Job-level API pricing
  final double totalAmount;
  final double vatAmount;
  final String? promoCodeId;
  final String? promoCodeName;
  final String? promoDiscountType;
  final double promoDiscountValue;
  final double promoDiscountAmount;
  final String? totalDiscountType;
  final double totalDiscountValue;

  PosOrderJob({
    required this.id,
    required this.status,
    required this.department,
    this.items = const [],
    this.technicians = const [],
    this.totalAmount = 0.0,
    this.vatAmount = 0.0,
    this.promoCodeId,
    this.promoCodeName,
    this.promoDiscountType,
    this.promoDiscountValue = 0.0,
    this.promoDiscountAmount = 0.0,
    this.totalDiscountType,
    this.totalDiscountValue = 0.0,
  });

  factory PosOrderJob.fromJson(Map<String, dynamic> json) {
    final jobId = json['id']?.toString() ?? '';
    return PosOrderJob(
      id: jobId,
      status: json['status'] ?? '',
      department: json['department'] ?? '',
      totalAmount: double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0.0,
      vatAmount: double.tryParse(json['vatAmount']?.toString() ?? '0') ?? 0.0,
      promoCodeId: json['promoCodeId']?.toString(),
      promoCodeName: json['promoCodeName']?.toString(),
      promoDiscountType: json['promoDiscountType']?.toString(),
      promoDiscountValue: double.tryParse(json['promoDiscountValue']?.toString() ?? '0') ?? 0.0,
      promoDiscountAmount: double.tryParse(json['promoDiscountAmount']?.toString() ?? '0') ?? 0.0,
      totalDiscountType: json['totalDiscountType']?.toString(),
      totalDiscountValue: double.tryParse(json['totalDiscountValue']?.toString() ?? '0') ?? 0.0,
      items:
          (json['items'] as List?)
              ?.map((i) => PosOrderJobItem.fromJson(i))
              .where((item) => item.jobId == null || item.jobId == jobId)
              .toList() ??
          [],
      technicians:
          (json['technicians'] as List?)
              ?.map((t) => JobTechnician.fromJson(t))
              .toList() ??
          [],
    );
  }
}

class JobTechnician {
  final String id;
  final String name;
  final double commissionPercent;
  final double commissionAmount;
  final String? status;

  JobTechnician({
    required this.id,
    required this.name,
    required this.commissionPercent,
    required this.commissionAmount,
    this.status,
  });

  factory JobTechnician.fromJson(Map<String, dynamic> json) {
    return JobTechnician(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      commissionPercent:
          double.tryParse(
            json['commissionPercent']?.toString() ??
                json['commission_percent']?.toString() ??
                '0',
          ) ??
          0.0,
      commissionAmount:
          double.tryParse(
            json['commissionAmount']?.toString() ??
                json['commission_amount']?.toString() ??
                json['commission']?.toString() ??
                '0',
          ) ??
          0.0,
      status: json['status'] ?? json['assignmentStatus'] ?? '',
    );
  }
}

class PosOrderJobItem {
  final String id;
  final String itemType;
  final String productId;
  final String productName;
  final String departmentId;
  final String departmentName;
  final double qty;
  final double unitPrice;
  final double lineTotal;
  final String? jobId;
  final String? discountType;
  final double? discountValue;

  PosOrderJobItem({
    required this.id,
    required this.itemType,
    required this.productId,
    required this.productName,
    required this.departmentId,
    required this.departmentName,
    required this.qty,
    required this.unitPrice,
    required this.lineTotal,
    this.jobId,
    this.discountType,
    this.discountValue = 0.0,
  });

  factory PosOrderJobItem.fromJson(Map<String, dynamic> json) {
    return PosOrderJobItem(
      id: json['id']?.toString() ?? '',
      itemType: json['itemType'] ?? '',
      productId: json['productId']?.toString() ?? '',
      productName: json['productName'] ?? '',
      departmentId: json['departmentId']?.toString() ?? '',
      departmentName: json['departmentName'] ?? '',
      qty: double.tryParse(json['qty']?.toString() ?? '0') ?? 0.0,
      unitPrice: double.tryParse(json['unitPrice']?.toString() ?? '0') ?? 0.0,
      lineTotal: double.tryParse(json['lineTotal']?.toString() ?? '0') ?? 0.0,
      jobId: json['jobId']?.toString() ?? json['job_id']?.toString(),
      discountType: json['discountType']?.toString(),
      discountValue: double.tryParse(json['discountValue']?.toString() ?? '0') ?? 0.0,
    );
  }
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
  final List<PosOrderJob> jobs;
  final List<dynamic> items;

  final String? totalDiscountType;
  final double? totalDiscountValue;
  final String? invoiceNo;
  final String? promoCodeId;
  final String? promoCodeName;
  final double? promoDiscountAmount;
  final String? promoDiscountType;
  final double? promoDiscountValue;
  
  // Aggregate fields from backend
  final double totalAmount;
  final double subtotal;

  PosOrder({
    required this.id,
    required this.status,
    required this.source,
    required this.odometerReading,
    required this.createdAt,
    this.customer,
    this.vehicle,
    required this.jobsCount,
    this.jobs = const [],
    this.items = const [],
    this.totalDiscountType,
    this.totalDiscountValue,
    this.invoiceNo,
    this.promoCodeId,
    this.promoCodeName,
    this.promoDiscountAmount,
    this.promoDiscountType,
    this.promoDiscountValue,
    this.totalAmount = 0.0,
    this.subtotal = 0.0,
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
      jobs:
          (json['jobs'] as List?)
              ?.map((j) => PosOrderJob.fromJson(j))
              .toList() ??
          [],
      items: json['items'] ?? json['products'] ?? [],
      totalDiscountType: json['totalDiscountType']?.toString(),
      totalDiscountValue: double.tryParse(json['totalDiscountValue']?.toString() ?? '0') ?? 0.0,
      invoiceNo: json['invoiceNo']?.toString() ?? json['invoice_no']?.toString() ?? json['invoiceId']?.toString() ?? json['invoice_id']?.toString(),
      promoCodeId: json['promoCodeId']?.toString(),
      promoCodeName: json['promoCodeName']?.toString(),
      promoDiscountAmount: double.tryParse(json['promoDiscountAmount']?.toString() ?? '0') ?? 0.0,
      promoDiscountType: json['promoDiscountType']?.toString(),
      promoDiscountValue: double.tryParse(json['promoDiscountValue']?.toString() ?? '0') ?? 0.0,
      totalAmount: double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0.0,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
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
    List<PosOrderJob>? jobs,
    List<dynamic>? items,
    String? totalDiscountType,
    double? totalDiscountValue,
    String? invoiceNo,
    String? promoCodeId,
    String? promoCodeName,
    double? promoDiscountAmount,
    String? promoDiscountType,
    double? promoDiscountValue,
    double? totalAmount,
    double? subtotal,
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
      jobs: jobs ?? this.jobs,
      items: items ?? this.items,
      totalDiscountType: totalDiscountType ?? this.totalDiscountType,
      totalDiscountValue: totalDiscountValue ?? this.totalDiscountValue,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      promoCodeId: promoCodeId ?? this.promoCodeId,
      promoCodeName: promoCodeName ?? this.promoCodeName,
      promoDiscountAmount: promoDiscountAmount ?? this.promoDiscountAmount,
      promoDiscountType: promoDiscountType ?? this.promoDiscountType,
      promoDiscountValue: promoDiscountValue ?? this.promoDiscountValue,
      totalAmount: totalAmount ?? this.totalAmount,
      subtotal: subtotal ?? this.subtotal,
    );
  }

  String get customerName => customer?.name ?? 'Unknown';
  String get carModel => '${vehicle?.make ?? ""} ${vehicle?.model ?? ""}'.trim();
  String get plateNumber => vehicle?.plateNo ?? '';
  String get date => createdAt.isNotEmpty ? createdAt.split('T')[0] : '';

  List<String> get services => []; // API doesn't provide services in this list

  String get activeDepartmentName {
    if (jobs.isEmpty) return '';
    try {
      final activeJob = jobs.firstWhere(
        (j) => j.status == 'in_progress' || j.status == 'accepted',
        orElse: () => latestJob!,
      );
      return activeJob.department;
    } catch (_) {
      return '';
    }
  }

  PosOrderJob? get latestJob {
    if (jobs.isEmpty) return null;
    return jobs.reduce((a, b) {
      int idA = int.tryParse(a.id) ?? 0;
      int idB = int.tryParse(b.id) ?? 0;
      return idA > idB ? a : b;
    });
  }

  String get _latestJobStatus {
    return latestJob?.status ?? status;
  }

  Color get statusColor {
    String currentStatus = _latestJobStatus;
    switch (currentStatus.toLowerCase()) {
      case 'invoiced':
      case 'completed':
        return const Color(0xFF27AE60);
      case 'draft':
      case 'pending':
      case 'waiting_for_technician_acception':
        return const Color(0xFFF2994A);
      case 'in_progress':
      case 'ready_for_invoice':
      case 'accepted_by_technician':
        return const Color(0xFF2D9CDB); // Professional blue
      case 'cancelled':
      case 'rejected_by_technician':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get statusText {
    final job = latestJob;
    if (job != null && job.technicians.length > 1) {
      final completedCount = job.technicians
          .where((t) => t.status?.toLowerCase() == 'completed')
          .length;
      // If at least one has completed, but not all of them
      if (completedCount > 0 && completedCount < job.technicians.length) {
        return 'COMPLETED BY $completedCount TECHNICIAN${completedCount > 1 ? 'S' : ''} STILL PENDING';
      }
    }

    String currentStatus = _latestJobStatus;

    if (currentStatus.isEmpty) return 'Unknown';

    // Replace underscores with spaces and uppercase the string
    return currentStatus.replaceAll('_', ' ').toUpperCase();
  }
}

class OrderCustomer {
  final String id;
  final String name;
  final String mobile;

  OrderCustomer({required this.id, required this.name, required this.mobile});

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
