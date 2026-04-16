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
  final int waitingForCorporateApproval;
  final int corporateApproved;
  final int rejectedByCorporate;

  OrderStats({
    required this.total,
    required this.draft,
    required this.inProgress,
    required this.readyForInvoice,
    required this.invoiced,
    required this.cancelled,
    this.waitingForCorporateApproval = 0,
    this.corporateApproved = 0,
    this.rejectedByCorporate = 0,
  });

  static int _statInt(Map<String, dynamic> json, Object key) {
    final v = json[key.toString()];
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '0') ?? 0;
  }

  factory OrderStats.fromJson(Map<String, dynamic> json) {
    return OrderStats(
      total: _statInt(json, 'total'),
      draft: _statInt(json, 'draft'),
      inProgress: _statInt(json, 'in progress') != 0
          ? _statInt(json, 'in progress')
          : _statInt(json, 'in_progress'),
      readyForInvoice: _statInt(json, 'ready_for_invoice'),
      invoiced: _statInt(json, 'invoiced') != 0
          ? _statInt(json, 'invoiced')
          : _statInt(json, 'completed'),
      cancelled: _statInt(json, 'cancelled'),
      waitingForCorporateApproval: _statInt(json, 'waiting for corporate approval'),
      corporateApproved: _statInt(json, 'corporate approved'),
      rejectedByCorporate: _statInt(json, 'rejected by corporate'),
    );
  }

  factory OrderStats.empty() => OrderStats(
        total: 0,
        draft: 0,
        inProgress: 0,
        readyForInvoice: 0,
        invoiced: 0,
        cancelled: 0,
        waitingForCorporateApproval: 0,
        corporateApproved: 0,
        rejectedByCorporate: 0,
      );
}

double _parseJobTotalAmount(Map<String, dynamic> json) {
  for (final key in [
    'totalAmount',
    'total_amount',
    'grandTotal',
    'grand_total',
    'finalTotal',
    'final_total',
  ]) {
    final raw = json[key];
    if (raw == null) continue;
    final v = double.tryParse(raw.toString());
    if (v != null && v > 0) return v;
  }
  return double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0.0;
}

double _parseJobDoubleField(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final raw = json[key];
    if (raw == null) continue;
    final v = double.tryParse(raw.toString());
    if (v != null) return v;
  }
  return 0.0;
}

class PosOrderJob {
  final String id;
  final String status;
  final String department;
  /// Backend department id when provided (speeds up cashier flows).
  final String? departmentId;
  final List<PosOrderJobItem> items;
  final List<JobTechnician> technicians;
  
  // Job-level API pricing (GET /cashier/orders is authoritative).
  // All amounts are now VAT-exclusive from the backend.
  /// Gross excl. VAT (before any discounts).
  final double amountBeforeDiscount;
  /// After line discounts (excl. VAT).
  final double amountAfterDiscount;
  /// Total taxable amount (after all discounts, before VAT).
  final double amountAfterPromo;
  final double totalAmount;
  final double vatAmount;
  final double vatPercent;
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
    this.departmentId,
    this.items = const [],
    this.technicians = const [],
    this.amountBeforeDiscount = 0.0,
    this.amountAfterDiscount = 0.0,
    this.amountAfterPromo = 0.0,
    this.totalAmount = 0.0,
    this.vatAmount = 0.0,
    this.vatPercent = 15.0,
    this.promoCodeId,
    this.promoCodeName,
    this.promoDiscountType,
    this.promoDiscountValue = 0.0,
    this.promoDiscountAmount = 0.0,
    this.totalDiscountType,
    this.totalDiscountValue = 0.0,
  });

  /// Technicians still assigned to this job (excludes cancelled / historical rows from API).
  List<JobTechnician> get activeTechnicians =>
      technicians.where((t) => t.isActiveAssignment).toList();

  bool get isCancelledJob {
    final s = status.trim().toLowerCase();
    return s == 'cancelled' || s == 'canceled';
  }

  factory PosOrderJob.fromJson(Map<String, dynamic> json) {
    final jobId = json['id']?.toString() ?? '';
    final rawDept = json['department'];
    final deptObj = rawDept is Map ? Map<String, dynamic>.from(rawDept) : null;
    final parsedDeptName =
        deptObj?['name']?.toString() ??
        json['departmentName']?.toString() ??
        (rawDept is String ? rawDept : '');
    final parsedDeptId =
        deptObj?['id']?.toString() ??
        json['departmentId']?.toString() ??
        json['department_id']?.toString();
    return PosOrderJob(
      id: jobId,
      status: json['status'] ?? '',
      department: parsedDeptName,
      departmentId: parsedDeptId,
      amountBeforeDiscount: _parseJobDoubleField(json, [
        'amountBeforeDiscount',
        'amount_before_discount',
      ]),
      amountAfterDiscount: _parseJobDoubleField(json, [
        'amountAfterDiscount',
        'amount_after_discount',
      ]),
      amountAfterPromo: _parseJobDoubleField(json, [
        'amountAfterPromo',
        'amount_after_promo',
      ]),
      totalAmount: _parseJobTotalAmount(json),
      vatAmount: double.tryParse(json['vatAmount']?.toString() ?? json['vat_amount']?.toString() ?? '0') ?? 0.0,
      vatPercent: double.tryParse(json['vatPercent']?.toString() ?? '15') ?? 15.0,
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
  /// Assignment row id when present; may differ from [employeeId].
  final String id;
  /// Employee id for cashier catalog / POST `employeeIds` (from assign or orders payload).
  final String? employeeId;
  final String name;
  final double commissionPercent;
  final double commissionAmount;
  final String? status;

  JobTechnician({
    required this.id,
    this.employeeId,
    required this.name,
    required this.commissionPercent,
    required this.commissionAmount,
    this.status,
  });

  /// Id used to match [PosTechnician.id] in the assign-technician picker.
  String get pickerEmployeeId {
    final e = employeeId?.trim();
    if (e != null && e.isNotEmpty) return e;
    return id.trim();
  }

  /// `false` when API keeps a row after unassign (e.g. [status] `cancelled`).
  bool get isActiveAssignment {
    final s = (status ?? '').trim().toLowerCase();
    if (s.isEmpty) return true;
    if (s == 'cancelled' || s == 'canceled') return false;
    if (s == 'removed' || s == 'rejected') return false;
    return true;
  }

  factory JobTechnician.fromJson(Map<String, dynamic> json) {
    return JobTechnician(
      id: json['id']?.toString() ?? '',
      employeeId: json['employeeId']?.toString() ?? json['employee_id']?.toString(),
      name: json['name']?.toString() ??
          json['employeeName']?.toString() ??
          '',
      commissionPercent:
          double.tryParse(
            json['commissionPercent']?.toString() ??
                json['commission_percent']?.toString() ??
                json['commissionPct']?.toString() ??
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
      status: json['status']?.toString() ?? json['assignmentStatus']?.toString() ?? '',
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
    final rawDept = json['department'];
    final deptObj = rawDept is Map ? Map<String, dynamic>.from(rawDept) : null;
    return PosOrderJobItem(
      id: json['id']?.toString() ?? '',
      itemType: json['itemType'] ?? '',
      productId: json['productId']?.toString() ?? '',
      productName: json['productName'] ?? '',
      departmentId:
          json['departmentId']?.toString() ??
          json['department_id']?.toString() ??
          deptObj?['id']?.toString() ??
          '',
      departmentName:
          json['departmentName']?.toString() ??
          deptObj?['name']?.toString() ??
          '',
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
  final String submittedAt;
  final String orderDateTime;
  final String orderDate;
  final String orderTime;
  final OrderCustomer? customer;
  final OrderVehicle? vehicle;
  final int jobsCount;
  final String assignedTo;
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

  final String? corporateAccountId;
  final String? corporateCompanyName;
  final String? corporateApprovalRejectionReason;
  final List<dynamic> pendingDepartments;

  PosOrder({
    required this.id,
    required this.status,
    required this.source,
    required this.odometerReading,
    required this.createdAt,
    this.submittedAt = '',
    this.orderDateTime = '',
    this.orderDate = '',
    this.orderTime = '',
    this.customer,
    this.vehicle,
    required this.jobsCount,
    this.assignedTo = '',
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
    this.corporateAccountId,
    this.corporateCompanyName,
    this.corporateApprovalRejectionReason,
    this.pendingDepartments = const [],
  });

  factory PosOrder.fromJson(Map<String, dynamic> json) {
    final parsedJobs =
        (json['jobs'] as List?)?.map((j) => PosOrderJob.fromJson(j)).toList() ??
        [];
    return PosOrder(
      id: json['id']?.toString() ?? '',
      status: json['status'] ?? '',
      source: json['source'] ?? '',
      odometerReading: json['odometerReading'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      submittedAt: json['submittedAt']?.toString() ?? '',
      orderDateTime: json['orderDateTime']?.toString() ?? '',
      orderDate: json['orderDate']?.toString() ?? '',
      orderTime: json['orderTime']?.toString() ?? '',
      customer: json['customer'] != null
          ? OrderCustomer.fromJson(json['customer'])
          : null,
      vehicle: json['vehicle'] != null
          ? OrderVehicle.fromJson(json['vehicle'])
          : null,
      jobsCount:
          (json['jobsCount'] as num?)?.toInt() ??
          parsedJobs.length,
      assignedTo: json['assignedTo']?.toString() ?? '',
      jobs: parsedJobs,
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
      corporateAccountId: json['corporateAccountId']?.toString(),
      corporateCompanyName: json['corporateCompanyName']?.toString(),
      corporateApprovalRejectionReason: json['corporateApprovalRejectionReason']?.toString(),
      pendingDepartments: json['pendingDepartments'] is List
          ? List<dynamic>.from(json['pendingDepartments'] as List)
          : const [],
    );
  }

  PosOrder copyWith({
    String? id,
    String? status,
    String? source,
    int? odometerReading,
    String? createdAt,
    String? submittedAt,
    String? orderDateTime,
    String? orderDate,
    String? orderTime,
    OrderCustomer? customer,
    OrderVehicle? vehicle,
    int? jobsCount,
    String? assignedTo,
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
    String? corporateAccountId,
    String? corporateCompanyName,
    String? corporateApprovalRejectionReason,
    List<dynamic>? pendingDepartments,
  }) {
    return PosOrder(
      id: id ?? this.id,
      status: status ?? this.status,
      source: source ?? this.source,
      odometerReading: odometerReading ?? this.odometerReading,
      createdAt: createdAt ?? this.createdAt,
      submittedAt: submittedAt ?? this.submittedAt,
      orderDateTime: orderDateTime ?? this.orderDateTime,
      orderDate: orderDate ?? this.orderDate,
      orderTime: orderTime ?? this.orderTime,
      customer: customer ?? this.customer,
      vehicle: vehicle ?? this.vehicle,
      jobsCount: jobsCount ?? this.jobsCount,
      assignedTo: assignedTo ?? this.assignedTo,
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
      corporateAccountId: corporateAccountId ?? this.corporateAccountId,
      corporateCompanyName: corporateCompanyName ?? this.corporateCompanyName,
      corporateApprovalRejectionReason:
          corporateApprovalRejectionReason ?? this.corporateApprovalRejectionReason,
      pendingDepartments: pendingDepartments ?? this.pendingDepartments,
    );
  }

  bool get isCorporateWalkIn =>
      source.toLowerCase() == 'walk_in_corporate' ||
      (corporateAccountId != null && corporateAccountId!.isNotEmpty);

  /// Order grand total from GET; fall back to Σ job.totalAmount if order rollup missing.
  double get draftPosOrderTotalDisplay {
    if (totalAmount > 0) return totalAmount;
    return jobs.fold<double>(0, (s, j) => s + j.totalAmount);
  }

  String get customerName => customer?.name ?? 'Unknown';
  String get carModel => '${vehicle?.make ?? ""} ${vehicle?.model ?? ""}'.trim();
  String get plateNumber => vehicle?.plateNo ?? '';
  /// Best-available date string (YYYY-MM-DD), device-local parse from ISO timestamp
  String get date {
    if (orderDate.isNotEmpty) return orderDate;
    final iso = submittedAt.isNotEmpty ? submittedAt
        : orderDateTime.isNotEmpty ? orderDateTime
        : createdAt;
    if (iso.isEmpty) return '';
    try {
      return DateTime.parse(iso).toLocal().toIso8601String().split('T')[0];
    } catch (_) {
      return iso.split('T')[0];
    }
  }

  /// Best-available time string (HH:mm), device-local
  String get time {
    if (orderTime.isNotEmpty) {
      return orderTime.length >= 5 ? orderTime.substring(0, 5) : orderTime;
    }
    final iso = submittedAt.isNotEmpty ? submittedAt
        : orderDateTime.isNotEmpty ? orderDateTime
        : createdAt;
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

  String get displayJobStatus {
    return _latestJobStatus;
  }

  /// All departments done (completed / invoiced) → COMPLETED; any other job state → PENDING; no jobs → DRAFT.
  String get jobsAggregateBadgeLabel {
    if (jobs.isEmpty) return 'DRAFT';
    final active = jobs.where((j) => !j.isCancelledJob).toList();
    if (active.isEmpty) return 'PENDING';
    final allDone = active.every((j) {
      final s = j.status.toLowerCase();
      return s == 'completed' || s == 'invoiced' || s == 'edited';
    });
    return allDone ? 'COMPLETED' : 'PENDING';
  }

  String get normalizedJobStatus {
    return _normalizeStatus(_latestJobStatus);
  }

  String get assignedTechnicianNames {
    final techs = latestJob?.activeTechnicians ?? const <JobTechnician>[];
    final names = techs
        .map((t) => t.name.trim())
        .where((n) => n.isNotEmpty)
        .toList();
    if (names.isEmpty) return '';
    return names.join(', ');
  }

  Color get statusColor {
    String currentStatus = normalizedJobStatus;
    switch (currentStatus.toLowerCase()) {
      case 'invoiced':
      case 'completed':
        return const Color(0xFF27AE60);
      case 'edited':
        return const Color(0xFF3949AB);
      case 'draft':
      case 'pending':
      case 'waiting_for_technician_acception':
      case 'waiting for technician acception':
      case 'waiting for technician acceptance':
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
    if (job != null && job.activeTechnicians.length > 1) {
      final completedCount = job.activeTechnicians
          .where((t) => t.status?.toLowerCase() == 'completed')
          .length;
      // If at least one has completed, but not all of them
      if (completedCount > 0 &&
          completedCount < job.activeTechnicians.length) {
        return 'COMPLETED BY $completedCount TECHNICIAN${completedCount > 1 ? 'S' : ''} STILL PENDING';
      }
    }

    String currentStatus = normalizedJobStatus;

    if (currentStatus.isEmpty) return 'Unknown';

    // Replace underscores with spaces and uppercase the string
    return currentStatus.replaceAll('_', ' ').toUpperCase();
  }

  String _normalizeStatus(String raw) {
    final status = raw.trim().toLowerCase();
    if (status == 'waiting for technician acception' ||
        status == 'waiting_for_technician_acception') {
      return 'waiting for technician';
    }
    if (status == 'waiting for technician acceptance' ||
        status == 'waiting_for_technician_acceptance') {
      return 'waiting for technician';
    }
    if (status == 'edited' || status == 'job_edited') {
      return 'edited';
    }
    return raw;
  }
}

class OrderCustomer {
  final String id;
  final String name;
  final String mobile;
  final String vatNumber;

  OrderCustomer({
    required this.id,
    required this.name,
    required this.mobile,
    this.vatNumber = '',
  });

  factory OrderCustomer.fromJson(Map<String, dynamic> json) {
    return OrderCustomer(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      mobile: json['mobile'] ?? '',
      vatNumber:
          json['vatNumber']?.toString() ??
          json['taxId']?.toString() ??
          json['vat']?.toString() ??
          json['vatNo']?.toString() ??
          '',
    );
  }
}

class OrderVehicle {
  final String id;
  final String plateNo;
  final String make;
  final String model;
  final String? year;
  final String? color;
  final String? vin;

  OrderVehicle({
    required this.id,
    required this.plateNo,
    required this.make,
    required this.model,
    this.year,
    this.color,
    this.vin,
  });

  factory OrderVehicle.fromJson(Map<String, dynamic> json) {
    return OrderVehicle(
      id: json['id']?.toString() ?? '',
      plateNo: json['plateNo']?.toString() ?? '',
      make: json['make']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      year: json['year']?.toString(),
      color: json['color']?.toString(),
      vin: json['vin']?.toString() ?? json['carNo']?.toString(),
    );
  }
}
