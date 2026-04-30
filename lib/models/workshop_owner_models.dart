import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class WorkshopRegistration {
  final String workshopName;
  final String branch;
  final String vatId;
  final String crNo;
  final String manualAddress;
  final double? latitude;
  final double? longitude;
  final String? logoUrl;
  final String? frontPhotoUrl;
  final String? crAttachmentUrl;
  final String ownerName;
  final String contactPerson;
  final String? referralPerson;
  final double investmentAmount;

  WorkshopRegistration({
    required this.workshopName,
    required this.branch,
    required this.vatId,
    required this.crNo,
    required this.manualAddress,
    this.latitude,
    this.longitude,
    this.logoUrl,
    this.frontPhotoUrl,
    this.crAttachmentUrl,
    required this.ownerName,
    required this.contactPerson,
    this.referralPerson,
    required this.investmentAmount,
  });
}

class Branch {
  final String id;
  final String name;
  final String location;
  final String vat;
  final String cr;
  final double? gpsLat;
  final double? gpsLng;
  final String status;
  final double salesMTD;

  /// Translated display fields — set by the ViewModel after fetching,
  /// never populated from JSON.
  final String? translatedName;
  final String? translatedLocation;

  Branch({
    required this.id,
    required this.name,
    required this.location,
    required this.vat,
    required this.cr,
    this.gpsLat,
    this.gpsLng,
    required this.status,
    required this.salesMTD,
    this.translatedName,
    this.translatedLocation,
  });

  Branch copyWith({
    String? id,
    String? name,
    String? location,
    String? vat,
    String? cr,
    double? gpsLat,
    double? gpsLng,
    String? status,
    double? salesMTD,
    String? translatedName,
    String? translatedLocation,
  }) {
    return Branch(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      vat: vat ?? this.vat,
      cr: cr ?? this.cr,
      gpsLat: gpsLat ?? this.gpsLat,
      gpsLng: gpsLng ?? this.gpsLng,
      status: status ?? this.status,
      salesMTD: salesMTD ?? this.salesMTD,
      translatedName: translatedName ?? this.translatedName,
      translatedLocation: translatedLocation ?? this.translatedLocation,
    );
  }

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      location: json['address'] ?? json['location'] ?? '',
      vat: json['vat'] ?? '',
      cr: json['cr'] ?? '',
      gpsLat: double.tryParse(json['gpsLat']?.toString() ?? ''),
      gpsLng: double.tryParse(json['gpsLng']?.toString() ?? ''),
      status: (json['isActive'] == true || (json['isActive'] == null && json['status'] == 'active')) ? 'active' : 'inactive',
      salesMTD: (json['salesMTD'] ?? 0.0).toDouble(),
    );
  }
}

class EmployeeSlots {
  final int total;
  final int active;
  final int available;

  EmployeeSlots({
    required this.total,
    required this.active,
    required this.available,
  });

  factory EmployeeSlots.fromJson(Map<String, dynamic> json) {
    return EmployeeSlots(
      total: int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      active: int.tryParse(json['active']?.toString() ?? '0') ?? 0,
      available: int.tryParse(json['available']?.toString() ?? '0') ?? 0,
    );
  }
}

class OwnerEmployee {
  final String id;
  final String name;
  final String mobile;
  final String branchId;
  final String? email;
  final String role;
  final List<String> departmentIds;
  final double? basicSalary;
  final double commissionPercent;
  final String? technicianType; // 'workshop', 'oncall', 'both'
  final bool workshopDuty;
  final bool onCallAvailable;
  final bool? isAvailable;
  final String technicianStatus;
  /// Account / employment active flag from API (`isActive` / `active`).
  final bool isActive;
  final String status;
  final String lastSeenAt;
  final String? userId; // Added userId
  final EmployeeSlots? slots;
  final String? branchName;

  bool get isOnline => isAvailable == true;
  bool get isTechnicianAvailable =>
      technicianStatus.toLowerCase() == 'available' ||
          technicianStatus.toLowerCase() == 'online';

  /// Raw English label — used only where l10n context is unavailable.
  String get technicianStatusLabel {
    final s = technicianStatus.trim().toLowerCase();
    if (s == 'available') return 'AVAILABLE';
    if (s == 'online') return 'ONLINE';
    if (s == 'busy') return 'BUSY';
    if (s == 'offline') return 'OFFLINE';
    return isTechnicianAvailable ? 'AVAILABLE' : 'OFFLINE';
  }

  /// Localized technician status label.
  String localizedTechnicianStatusLabel(AppLocalizations l10n) {
    final s = technicianStatus.trim().toLowerCase();
    if (s == 'available') return l10n.empStatusAvailable;
    if (s == 'online') return l10n.empStatusOnline;
    if (s == 'busy') return l10n.empStatusBusy;
    if (s == 'offline') return l10n.empStatusOffline;
    return isTechnicianAvailable ? l10n.empStatusAvailable : l10n.empStatusOffline;
  }

  /// Raw English last-seen — used only where l10n context is unavailable.
  String get formattedLastSeen {
    if (lastSeenAt.isEmpty) return 'Never';
    try {
      final dateTime = DateTime.parse(lastSeenAt);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) return 'Just now';
      if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
      if (difference.inHours < 24) return '${difference.inHours}h ago';
      if (difference.inDays < 7) return '${difference.inDays}d ago';

      return lastSeenAt.split('T')[0];
    } catch (e) {
      return '';
    }
  }

  /// Localized last-seen string.
  String localizedFormattedLastSeen(AppLocalizations l10n) {
    if (lastSeenAt.isEmpty) return l10n.empLastSeenNever;
    try {
      final dateTime = DateTime.parse(lastSeenAt);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) return l10n.empLastSeenJustNow;
      if (difference.inMinutes < 60) return l10n.empLastSeenMinutes(difference.inMinutes);
      if (difference.inHours < 24) return l10n.empLastSeenHours(difference.inHours);
      if (difference.inDays < 7) return l10n.empLastSeenDays(difference.inDays);
      return lastSeenAt.split('T')[0];
    } catch (e) {
      return '';
    }
  }

  /// Localized display role (e.g. "فني" in Arabic, "TECHNICIAN" in English).
  String localizedRole(AppLocalizations l10n) {
    final r = role.trim().toLowerCase();
    if (r == 'technician') return l10n.empRoleTechnician;
    if (r == 'cashier') return l10n.empRoleCashier;
    if (r == 'supplier') return l10n.empRoleSupplier;
    return role.toUpperCase();
  }

  /// Localized technician type badge.
  String localizedTechType(AppLocalizations l10n) {
    final t = (technicianType ?? '').trim().toLowerCase();
    if (t == 'workshop') return l10n.empTechTypeWorkshop;
    if (t == 'both') return l10n.empTechTypeBoth;
    if (t == 'oncall') return l10n.empTechTypeOnCall;
    return (technicianType ?? l10n.empMgmtInfoUnknown).toUpperCase();
  }

  OwnerEmployee({
    required this.id,
    required this.name,
    required this.mobile,
    required this.branchId,
    this.email,
    required this.role,
    required this.departmentIds,
    this.basicSalary,
    required this.commissionPercent,
    this.technicianType,
    this.workshopDuty = false,
    this.onCallAvailable = false,
    this.isAvailable,
    this.technicianStatus = '',
    this.isActive = true,
    this.status = 'active',
    this.lastSeenAt = '',
    this.userId,
    this.slots,
    this.branchName,
  });

  // Alias for commissionPercent used in some views
  double get techCommission => commissionPercent;

  factory OwnerEmployee.fromJson(Map<String, dynamic> json) {
    return OwnerEmployee(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['full_name'] ?? '',
      mobile: json['mobile'] ?? '',
      branchId: json['branchId']?.toString() ?? json['branch_id']?.toString() ?? '',
      email: json['email'],
      role: json['employeeType'] ?? json['role'] ?? '',
      departmentIds: (json['departments'] as List?)?.map((d) => d['id'].toString()).toList() ?? List<String>.from(json['department_ids'] ?? []),
      basicSalary: double.tryParse(json['basicSalary']?.toString() ?? '0') ?? (json['basic_salary'] ?? 0.0).toDouble(),
      commissionPercent: double.tryParse(json['commissionPercent']?.toString() ?? '0') ?? (json['commission_percent'] ?? 0.0).toDouble(),
      technicianType: json['technicianType'] ?? json['technician_type'],
      workshopDuty: json['workshop_duty'] ?? false,
      onCallAvailable: json['oncall_available'] ?? false,
      isAvailable: json['technicianStatus']?['status'] == 'online' ||
          json['technicianStatus']?['status'] == 'available' ||
          json['status']?['status'] == 'online' ||
          json['status']?['status'] == 'available' ||
          json['is_available'] == true,
      technicianStatus: (json['technicianStatus']?['status'] ??
          json['status']?['status'] ??
          '')
          .toString(),
      lastSeenAt: json['technicianStatus']?['lastSeenAt'] ?? json['status']?['lastSeenAt'] ?? '',
      isActive: () {
        if (json['isActive'] == false || json['active'] == false) return false;
        final st = json['status']?.toString().toLowerCase();
        if (st == 'inactive' || st == 'disabled') return false;
        return true;
      }(),
      status: (json['isActive'] == false || json['active'] == false)
          ? 'inactive'
          : (json['status'] is String ? json['status'] as String : 'active'),
      userId: json['userId']?.toString() ??
          json['user_id']?.toString() ??
          json['cashierUserId']?.toString(),
      branchName: json['branch']?['name'],
      slots: json['slots'] != null ? EmployeeSlots.fromJson(json['slots']) : null,
    );
  }
}

class OwnerProduct {
  final String id;
  final String name;
  final String type; // 'product', 'service'
  final String? category;
  final String? subCategoryName;
  final String? departmentName;
  final List<String> departmentIds;
  final String unit;
  final double conversionFactor;
  final double purchasePrice;
  final double salePrice;
  final double? corporateBasePrice;
  final double? corporateLowerLimit;
  final double? corporateUpperLimit;
  final double stockQty;
  final double criticalLevel;
  final double reorderLevel;
  final String? imageUrl;
  final bool isPriceEditable;
  final int kmTypeValue;
  final bool allowDecimalQty;
  final bool isActive;

  // Aliases for consistency with views
  double get stock => stockQty;
  double get criticalStockPoint => criticalLevel;
  double? get minPriceCorporate => corporateLowerLimit;
  double? get maxPriceCorporate => corporateUpperLimit;

  OwnerProduct({
    required this.id,
    required this.name,
    required this.type,
    this.category,
    this.subCategoryName,
    this.departmentName,
    required this.departmentIds,
    required this.unit,
    this.conversionFactor = 1.0,
    required this.purchasePrice,
    required this.salePrice,
    this.corporateBasePrice,
    this.corporateLowerLimit,
    this.corporateUpperLimit,
    required this.stockQty,
    required this.criticalLevel,
    required this.reorderLevel,
    this.imageUrl,
    this.isPriceEditable = false,
    this.kmTypeValue = 0,
    this.allowDecimalQty = false,
    this.isActive = true,
  });

  OwnerProduct copyWith({
    String? id,
    String? name,
    String? type,
    String? category,
    String? subCategoryName,
    String? departmentName,
    List<String>? departmentIds,
    String? unit,
    double? conversionFactor,
    double? purchasePrice,
    double? salePrice,
    double? corporateBasePrice,
    double? corporateLowerLimit,
    double? corporateUpperLimit,
    double? stockQty,
    double? criticalLevel,
    double? reorderLevel,
    String? imageUrl,
    bool? isPriceEditable,
    int? kmTypeValue,
    bool? allowDecimalQty,
    bool? isActive,
  }) {
    return OwnerProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      category: category ?? this.category,
      subCategoryName: subCategoryName ?? this.subCategoryName,
      departmentName: departmentName ?? this.departmentName,
      departmentIds: departmentIds ?? this.departmentIds,
      unit: unit ?? this.unit,
      conversionFactor: conversionFactor ?? this.conversionFactor,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      salePrice: salePrice ?? this.salePrice,
      corporateBasePrice: corporateBasePrice ?? this.corporateBasePrice,
      corporateLowerLimit: corporateLowerLimit ?? this.corporateLowerLimit,
      corporateUpperLimit: corporateUpperLimit ?? this.corporateUpperLimit,
      stockQty: stockQty ?? this.stockQty,
      criticalLevel: criticalLevel ?? this.criticalLevel,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      imageUrl: imageUrl ?? this.imageUrl,
      isPriceEditable: isPriceEditable ?? this.isPriceEditable,
      kmTypeValue: kmTypeValue ?? this.kmTypeValue,
      allowDecimalQty: allowDecimalQty ?? this.allowDecimalQty,
      isActive: isActive ?? this.isActive,
    );
  }

  factory OwnerProduct.fromJson(Map<String, dynamic> json) {
    return OwnerProduct(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'product',
      category: json['categoryName'] ?? json['category'] ?? '',
      subCategoryName: json['subCategoryName'],
      departmentName: json['departmentName'],
      departmentIds: [json['departmentId']?.toString() ?? ''].where((id) => id.isNotEmpty).toList(),
      unit: json['unit'] ?? 'pcs',
      conversionFactor: (json['conversion_factor'] ?? 1.0).toDouble(),
      purchasePrice: double.tryParse(json['purchasePrice']?.toString() ?? '0') ?? (json['purchase_price_excl'] ?? 0.0).toDouble(),
      salePrice: double.tryParse(json['salePrice']?.toString() ?? json['sellingPrice']?.toString() ?? '0') ?? (json['sale_price_incl'] ?? 0.0).toDouble(),
      corporateBasePrice: double.tryParse(json['corporate_price']?.toString() ?? '0') ?? 0.0,
      corporateLowerLimit: double.tryParse(json['corporate_lower_limit']?.toString() ?? json['minPriceCorporate']?.toString() ?? '0') ?? 0.0,
      corporateUpperLimit: double.tryParse(json['corporate_upper_limit']?.toString() ?? json['maxPriceCorporate']?.toString() ?? '0') ?? 0.0,
      stockQty: double.tryParse(json['openingQty']?.toString() ?? '0') ?? (json['stock_qty'] ?? 0.0).toDouble(),
      criticalLevel: double.tryParse(json['criticalStockPoint']?.toString() ?? '0') ?? (json['critical_level'] ?? 0.0).toDouble(),
      reorderLevel: (json['reorder_level'] ?? 0.0).toDouble(),
      imageUrl: json['image_url'],
      isPriceEditable: json['isPriceEditable'] == true ||
          json['is_price_editable'] == true,
      kmTypeValue: int.tryParse(json['kmTypeValue']?.toString() ?? '0') ?? (json['km_type_value'] ?? 0),
      allowDecimalQty: json['allowDecimalQty'] ?? json['allow_decimal_qty'] ?? false,
      isActive: json['isActive'] ?? json['active'] ?? true,
    );
  }
}

class OwnerSubCategory {
  final String id;
  final String name;
  final String? departmentId;
  final String? departmentName;

  OwnerSubCategory({
    required this.id,
    required this.name,
    this.departmentId,
    this.departmentName,
  });

  factory OwnerSubCategory.fromJson(Map<String, dynamic> json) {
    return OwnerSubCategory(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      departmentId: json['departmentId']?.toString(),
      departmentName: json['departmentName']?.toString(),
    );
  }
}

class OwnerCategory {
  final String id;
  final String name;
  final String type;
  final String workshopId;
  final List<OwnerSubCategory> subCategories;

  OwnerCategory({
    required this.id,
    required this.name,
    required this.type,
    required this.workshopId,
    this.subCategories = const [],
  });

  factory OwnerCategory.fromJson(Map<String, dynamic> json) {
    return OwnerCategory(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      workshopId: json['workshopId']?.toString() ?? '',
      subCategories: (json['subCategories'] as List?)
          ?.map((e) => OwnerSubCategory.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class CorporateCustomer {
  final String id;
  final String companyName;
  final String vatNumber;
  final String contactName;
  final String mobile;
  final String email;
  final double creditLimit;
  final double dueBalance;
  final List<String> selectedBranchIds;
  final String status;
  final String category;
  final double totalSales;
  final int vehicleCount;
  final String address;
  final String contactPerson;

  CorporateCustomer({
    required this.id,
    required this.companyName,
    required this.vatNumber,
    required this.contactName,
    required this.mobile,
    required this.email,
    this.creditLimit = 0.0,
    this.dueBalance = 0.0,
    required this.selectedBranchIds,
    this.status = 'active',
    this.category = 'Bronze',
    this.totalSales = 0.0,
    this.vehicleCount = 0,
    this.address = '',
    this.contactPerson = '',
  });

  factory CorporateCustomer.fromJson(Map<String, dynamic> json) {
    return CorporateCustomer(
      id: json['id']?.toString() ?? '',
      companyName: json['companyName'] ?? json['company_name'] ?? '',
      vatNumber: (json['customer'] != null && json['customer']['taxId'] != null)
          ? json['customer']['taxId'].toString()
          : (json['vatNumber'] ?? json['vat_number'] ?? ''),
      contactName: json['contactPerson'] ?? json['contact_name'] ?? '',
      mobile: (json['customer'] != null && json['customer']['mobile'] != null)
          ? json['customer']['mobile'].toString()
          : (json['mobile'] ?? ''),
      email: json['email'] ?? '',
      creditLimit: double.tryParse(json['creditLimit']?.toString() ?? '0') ?? 0.0,
      dueBalance: double.tryParse(json['dueBalance']?.toString() ?? '0') ?? 0.0,
      selectedBranchIds: List<String>.from(json['selectedBranchIds'] ?? json['allowed_branch_ids'] ?? []),
      status: json['status'] ?? 'active',
      category: json['category'] ?? 'Bronze',
      totalSales: (json['total_sales'] ?? json['totalSales'] ?? 0.0).toDouble(),
      vehicleCount: json['vehicle_count'] ?? json['vehicleCount'] ?? 0,
      address: json['address'] ?? '',
      contactPerson: json['contactPerson'] ?? '',
    );
  }
}

class MonthlyBill {
  final String id;
  final String corporateCustomerId;
  final String customerName;
  final int month;
  final int year;
  final double totalAmount;
  final double paidAmount;
  final DateTime dueDate;
  final String status; // 'Pending', 'Partially Paid', 'Paid', 'Overdue'
  final String? pdfUrl;

  /// Translated display fields — set by the ViewModel after fetching,
  /// never populated from JSON.
  final String? translatedCustomerName;
  final String? translatedStatus;

  MonthlyBill({
    required this.id,
    required this.corporateCustomerId,
    required this.customerName,
    required this.month,
    required this.year,
    required this.totalAmount,
    this.paidAmount = 0.0,
    required this.dueDate,
    this.status = 'Pending',
    this.pdfUrl,
    this.translatedCustomerName,
    this.translatedStatus,
  });

  MonthlyBill copyWith({
    String? id,
    String? corporateCustomerId,
    String? customerName,
    int? month,
    int? year,
    double? totalAmount,
    double? paidAmount,
    DateTime? dueDate,
    String? status,
    String? pdfUrl,
    String? translatedCustomerName,
    String? translatedStatus,
  }) {
    return MonthlyBill(
      id: id ?? this.id,
      corporateCustomerId: corporateCustomerId ?? this.corporateCustomerId,
      customerName: customerName ?? this.customerName,
      month: month ?? this.month,
      year: year ?? this.year,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      translatedCustomerName: translatedCustomerName ?? this.translatedCustomerName,
      translatedStatus: translatedStatus ?? this.translatedStatus,
    );
  }

  factory MonthlyBill.fromJson(Map<String, dynamic> json) {
    int parsedMonth = 1;
    int parsedYear = 2026;

    final periodStr = json['billingPeriod']?.toString() ?? '';
    // Expected format: "Month: 2/2025"
    if (periodStr.contains('/')) {
      final parts = periodStr.replaceAll('Month:', '').trim().split('/');
      if (parts.length == 2) {
        parsedMonth = int.tryParse(parts[0]) ?? 1;
        parsedYear = int.tryParse(parts[1]) ?? 2026;
      }
    }

    // Capitalize status
    String statusStr = json['status']?.toString() ?? 'Pending';
    if (statusStr.isNotEmpty) {
      statusStr = statusStr[0].toUpperCase() + statusStr.substring(1);
    }

    return MonthlyBill(
      id: json['invoiceId']?.toString() ?? '',
      corporateCustomerId: '', // Not provided directly in this list API
      customerName: json['customerName'] ?? 'Unknown Customer',
      month: parsedMonth,
      year: parsedYear,
      totalAmount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      paidAmount: statusStr.toLowerCase() == 'paid' ? (double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0) : 0.0,
      dueDate: json['invoiceDate'] != null ? DateTime.tryParse(json['invoiceDate']) ?? DateTime.now() : DateTime.now(),
      status: statusStr,
    );
  }

  double get outstandingAmount => totalAmount - paidAmount;
}

class MonthlyBillPayment {
  final String id;
  final String billId;
  final double amount;
  final DateTime date;
  final String method; // 'Bank Transfer', 'Cash', 'Cheque', 'Online'
  final String? reference;
  final String? proofUrl;

  MonthlyBillPayment({
    required this.id,
    required this.billId,
    required this.amount,
    required this.date,
    required this.method,
    this.reference,
    this.proofUrl,
  });
}

// ─── Supplier ───────────────────────────────────────
class Supplier {
  final String id;
  final String name;
  final String category;
  final String mobile;
  final String? email;
  final String? address;
  final String? vatNumber;
  final double outstanding;
  final double openingBalance;
  final String status;

  Supplier({
    required this.id,
    required this.name,
    required this.category,
    required this.mobile,
    this.email,
    this.address,
    this.vatNumber,
    this.outstanding = 0.0,
    this.openingBalance = 0.0,
    this.status = 'active',
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? 'Parts', // Defaulting as category isn't in JSON
      mobile: json['mobile'] ?? '',
      email: json['email'],
      address: json['address'],
      vatNumber: json['vatNumber'], // Assuming it might be added later
      outstanding: double.tryParse(json['outstanding']?.toString() ?? '0') ?? 0.0,
      openingBalance: double.tryParse(json['openingBalance']?.toString() ?? '0') ?? 0.0,
      status: (json['isActive'] == true) ? 'active' : 'inactive',
    );
  }
}

class PurchaseItem {
  final String productName;
  final double qty;
  final String unit;
  final double unitPrice;
  double get total => qty * unitPrice;

  PurchaseItem({
    required this.productName,
    required this.qty,
    required this.unit,
    required this.unitPrice,
  });
}

class PurchaseInvoice {
  final String id;
  final String supplierId;
  final String supplierName;
  final DateTime date;
  final List<PurchaseItem> items;
  final String status; // 'pending', 'approved', 'rejected'
  final bool isInternal;

  PurchaseInvoice({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.date,
    required this.items,
    this.status = 'pending',
    this.isInternal = false,
  });

  double get totalAmount => items.fold(0, (sum, i) => sum + i.total);
}

// ─── POS Monitoring ────────────────────────────────
class PosCounter {
  final String id;
  final String cashierName;
  final String branchName;
  final String status;
  final double shiftSales;
  final int openOrders;
  final DateTime openedAt;
  final DateTime? closedAt;

  // Per-category system totals
  final double systemCash;
  final double systemBank;
  final double systemCorporate;
  final double systemTamara;
  final double systemTabby;
  final double systemOthers;
  final double systemTotalSales;

  // Per-category physical totals
  final double physicalCash;
  final double physicalBank;
  final double physicalCorporate;
  final double physicalTamara;
  final double physicalTabby;
  final double physicalOthers;

  // Per-category diffs (physical − system, same sign as DB)
  final double diffCash;
  final double diffBank;
  final double diffCorporate;
  final double diffTamara;
  final double diffTabby;
  final double diffOthers;

  // Overall reconciliation difference (system − physical)
  final double reconciliationTotalDifference;
  final String? closingId;
  final int schemaVersion; // closingReportSchemaVersion: 1 legacy, 2 full breakdown, 3 + start/end times

  // Backend-computed summary fields (v2+)
  final double systemSummary;    // json['system'] = systemTotalSales headline
  final double physicalSummary;  // json['physicalTotal'] = sum of all physical buckets
  final double lockerDiff;       // json['lockerDiff'] = system − physicalTotal

  /// ISO timestamp from [`startTime`]; same instant as [openedAt] when API sends schema v3+.
  final DateTime? startTime;

  /// Session/counter close instant; **null while shift is OPEN** (live counters).
  final DateTime? endTime;

  PosCounter({
    required this.id,
    required this.cashierName,
    required this.branchName,
    required this.status,
    required this.shiftSales,
    this.openOrders = 0,
    required this.openedAt,
    this.closedAt,
    this.startTime,
    this.endTime,
    this.systemCash = 0,
    this.systemBank = 0,
    this.systemCorporate = 0,
    this.systemTamara = 0,
    this.systemTabby = 0,
    this.systemOthers = 0,
    this.systemTotalSales = 0,
    this.physicalCash = 0,
    this.physicalBank = 0,
    this.physicalCorporate = 0,
    this.physicalTamara = 0,
    this.physicalTabby = 0,
    this.physicalOthers = 0,
    this.diffCash = 0,
    this.diffBank = 0,
    this.diffCorporate = 0,
    this.diffTamara = 0,
    this.diffTabby = 0,
    this.diffOthers = 0,
    this.reconciliationTotalDifference = 0,
    this.closingId,
    this.schemaVersion = 1,
    this.systemSummary = 0,
    this.physicalSummary = 0,
    this.lockerDiff = 0,
  });

  /// True when the backend returned the full v2 breakdown payload
  bool get isV2 => schemaVersion >= 2;

  /// Prefer explicit `startTime`, else legacy [`openedAt`].
  DateTime get sessionStart => startTime ?? openedAt;

  /// Prefer API [`endTime`], else legacy [`closedAt`] (OPEN shifts omit both ends).
  DateTime? get sessionEnd => endTime ?? closedAt;

  /// The single "SYSTEM" headline: prefer backend-computed summary, else sum of categories
  double get effectiveSystemTotal =>
      systemSummary > 0 ? systemSummary : systemTotalSales;

  /// The single "PHYSICAL" headline: prefer backend-computed total, else sum of categories
  double get effectivePhysicalTotal {
    if (physicalSummary > 0) return physicalSummary;
    return physicalCash + physicalBank + physicalCorporate + physicalTamara + physicalTabby + physicalOthers;
  }

  /// The single "DIFF" headline: prefer lockerDiff, else reconciliationTotalDifference
  double get effectiveDiff =>
      lockerDiff != 0 ? lockerDiff : reconciliationTotalDifference;

  static double _d(dynamic v) =>
      double.tryParse(v?.toString() ?? '0') ?? 0.0;

  static DateTime? _parseDt(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    final p = DateTime.tryParse(s);
    if (p != null) return p;
    return null;
  }

  /// UTC instant from backend millis (preferred over parsing zoned ISO strings on the client).
  static DateTime? _fromEpochMs(dynamic v) {
    if (v == null) return null;
    final n = v is int ? v : int.tryParse(v.toString());
    if (n == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(n, isUtc: true);
  }

  factory PosCounter.fromJson(Map<String, dynamic> json) {
    final schemaVersion =
        int.tryParse(json['closingReportSchemaVersion']?.toString() ?? '1') ?? 1;

    final openEpoch = _fromEpochMs(json['openedAtEpochMs']);
    final closeEpoch = _fromEpochMs(json['closedAtEpochMs']);

    final startT = _parseDt(json['startTime']);
    final endT = _parseDt(json['endTime']);

    final legacyOpened =
        _parseDt(json['openedAt'] ??
            json['shiftStartedAt'] ??
            json['startedAt'] ??
            json['openTime']);
    final openedFinal = openEpoch ?? legacyOpened ?? startT ?? DateTime.now();

    final legacyClosed =
        _parseDt(json['closedAt'] ??
            json['shiftEndedAt'] ??
            json['endedAt'] ??
            json['closingTime']);

    final startResolved = openEpoch ?? startT;
    final endResolved = closeEpoch ?? endT;
    final closedResolved = closeEpoch ?? legacyClosed ?? endT;

    final sysCash = _d(json['systemCash']);
    final sysBank = _d(json['systemBank']);
    final sysCorp = _d(json['systemCorporate']);
    final sysTamara = _d(json['systemTamara']);
    final sysTabby = _d(json['systemTabby']);
    final sysOthers = _d(
        json['systemOthers'] ?? json['systemOthersTotal']);
    // v2: 'system' = systemTotalSales headline. v1 fallback: shiftSales
    final sysTotalSales = _d(
        json['systemTotalSales'] ?? json['system'] ?? json['shiftSales']);

    final phyCash = _d(json['physicalCash']);
    final phyBank = _d(json['physicalBank']);
    final phyCorp = _d(json['physicalCorporate']);
    final phyTamara = _d(json['physicalTamara']);
    final phyTabby = _d(json['physicalTabby']);
    final phyOthers = _d(
        json['physicalOthers'] ?? json['physical_others']);

    // v2 summary fields
    final systemSummary = _d(json['system'] ?? json['systemTotalSales']);
    final physicalSummary = _d(json['physicalTotal']);
    final lockerDiff = _d(json['lockerDiff']);

    // Per-category diffs: prefer explicit fields, fall back to computing
    final dCash = json['diffCash'] != null ? _d(json['diffCash']) : sysCash - phyCash;
    final dBank = json['diffBank'] != null ? _d(json['diffBank']) : sysBank - phyBank;
    final dCorp = json['diffCorporate'] != null ? _d(json['diffCorporate']) : sysCorp - phyCorp;
    final dTamara = json['diffTamara'] != null ? _d(json['diffTamara']) : sysTamara - phyTamara;
    final dTabby = json['diffTabby'] != null ? _d(json['diffTabby']) : sysTabby - phyTabby;
    final dOthers = json['diffOthers'] != null
        ? _d(json['diffOthers'])
        : json['othersDiff'] != null
            ? _d(json['othersDiff'])
            : sysOthers - phyOthers;

    // Prefer explicit reconciliation total, then lockerDiff, then compute
    final reconTotal = json['reconciliationTotalDifference'] != null
        ? _d(json['reconciliationTotalDifference'])
        : (json['lockerDiff'] != null
        ? _d(json['lockerDiff'])
        : dCash + dBank + dCorp + dTamara + dTabby + dOthers);

    return PosCounter(
      id: json['posSessionId']?.toString() ?? '',
      cashierName: json['cashierName'] ?? '',
      branchName: json['branchName'] ?? '',
      status: json['shiftStatus']?.toString().toLowerCase() ?? 'open',
      shiftSales: _d(json['shiftSales']),
      openOrders: int.tryParse(json['shiftOpenOrders']?.toString() ?? '0') ?? 0,
      openedAt: openedFinal,
      closedAt: closedResolved,
      startTime: startResolved,
      endTime: endResolved,
      systemCash: sysCash,
      systemBank: sysBank,
      systemCorporate: sysCorp,
      systemTamara: sysTamara,
      systemTabby: sysTabby,
      systemOthers: sysOthers,
      systemTotalSales: sysTotalSales,
      physicalCash: phyCash,
      physicalBank: phyBank,
      physicalCorporate: phyCorp,
      physicalTamara: phyTamara,
      physicalTabby: phyTabby,
      physicalOthers: phyOthers,
      diffCash: dCash,
      diffBank: dBank,
      diffCorporate: dCorp,
      diffTamara: dTamara,
      diffTabby: dTabby,
      diffOthers: dOthers,
      reconciliationTotalDifference: reconTotal,
      closingId: json['closingId']?.toString(),
      schemaVersion: schemaVersion,
      systemSummary: systemSummary,
      physicalSummary: physicalSummary,
      lockerDiff: lockerDiff,
    );
  }
}

/// Echo of UTC [`from`] / [`to`] (`YYYY-MM-DD`) when a filtered POS monitoring request succeeded.
class PosMonitoringDateRangeEcho {
  final String? from;
  final String? to;

  PosMonitoringDateRangeEcho({this.from, this.to});

  factory PosMonitoringDateRangeEcho.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return PosMonitoringDateRangeEcho();
    return PosMonitoringDateRangeEcho(
      from: json['from']?.toString(),
      to: json['to']?.toString(),
    );
  }
}

class PosMonitoringResponse {
  final bool success;
  final int liveCountersCount;
  final int openOrdersCount;
  final double todaySales;
  final List<PosCounter> liveCounters;
  final List<PosCounter> closingReports;

  /// Total invoice sales in UTC range when [`from`] / [`to`] query was sent (exclusive of unscoped todaySales semantics).
  final double? salesInDateRange;

  /// Present when backend echoes the applied UTC date filter strings.
  final PosMonitoringDateRangeEcho? dateRangeFilter;

  PosMonitoringResponse({
    required this.success,
    required this.liveCountersCount,
    required this.openOrdersCount,
    required this.todaySales,
    required this.liveCounters,
    required this.closingReports,
    this.salesInDateRange,
    this.dateRangeFilter,
  });

  factory PosMonitoringResponse.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? rangeMap;
    final rawRange = json['dateRangeFilter'];
    if (rawRange is Map<String, dynamic>) {
      rangeMap = rawRange;
    } else if (rawRange is Map) {
      rangeMap = Map<String, dynamic>.from(rawRange);
    }

    return PosMonitoringResponse(
      success: json['success'] ?? false,
      liveCountersCount: int.tryParse(json['liveCountersCount']?.toString() ?? '0') ?? 0,
      openOrdersCount: int.tryParse(json['openOrdersCount']?.toString() ?? '0') ?? 0,
      todaySales: double.tryParse(json['todaySales']?.toString() ?? '0') ?? 0.0,
      liveCounters: (json['liveCounters'] as List?)
          ?.map((e) => PosCounter.fromJson(e))
          .toList() ??
          [],
      closingReports: (json['closingReports'] as List?)
          ?.map((e) => PosCounter.fromJson(e))
          .toList() ??
          [],
      salesInDateRange: json['salesInDateRange'] == null
          ? null
          : double.tryParse(json['salesInDateRange'].toString()),
      dateRangeFilter:
          rangeMap != null ? PosMonitoringDateRangeEcho.fromJson(rangeMap) : null,
    );
  }
}

// ─── Reports & Analytics ─────────────────────────────
class DailyRevenue {
  final String day;
  final String date;
  final double amount;

  DailyRevenue({required this.day, required this.date, required this.amount});

  factory DailyRevenue.fromJson(Map<String, dynamic> json) {
    return DailyRevenue(
      day: json['day'] ?? '',
      date: json['date'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class FinancialOverview {
  final double totalRevenue;
  final double revenueChangePercent;
  final List<DailyRevenue> dailyRevenue;

  FinancialOverview({
    required this.totalRevenue,
    required this.revenueChangePercent,
    required this.dailyRevenue,
  });

  factory FinancialOverview.fromJson(Map<String, dynamic> json) {
    return FinancialOverview(
      totalRevenue: double.tryParse(json['totalRevenue']?.toString() ?? '0') ?? 0.0,
      revenueChangePercent: double.tryParse(json['revenueChangePercent']?.toString() ?? '0') ?? 0.0,
      dailyRevenue: (json['dailyRevenue'] as List?)
          ?.map((e) => DailyRevenue.fromJson(e))
          .toList() ?? [],
    );
  }
}

class OperationalPerformance {
  final String employeeId;
  final String name;
  final int totalJobs;
  final double commission;

  OperationalPerformance({
    required this.employeeId,
    required this.name,
    required this.totalJobs,
    required this.commission,
  });

  factory OperationalPerformance.fromJson(Map<String, dynamic> json) {
    return OperationalPerformance(
      employeeId: json['employeeId']?.toString() ?? '',
      name: json['name'] ?? '',
      totalJobs: int.tryParse(json['totalJobs']?.toString() ?? '0') ?? 0,
      commission: double.tryParse(json['commission']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class InventoryValuation {
  final double stockValueCost;
  final double potentialProfit;
  final int activeSkus;

  InventoryValuation({
    required this.stockValueCost,
    required this.potentialProfit,
    required this.activeSkus,
  });

  factory InventoryValuation.fromJson(Map<String, dynamic> json) {
    return InventoryValuation(
      stockValueCost: double.tryParse(json['stockValueCost']?.toString() ?? '0') ?? 0.0,
      potentialProfit: double.tryParse(json['potentialProfit']?.toString() ?? '0') ?? 0.0,
      activeSkus: int.tryParse(json['activeSkus']?.toString() ?? '0') ?? 0,
    );
  }
}

class ReportsAnalyticsResponse {
  final FinancialOverview financialOverview;
  final List<OperationalPerformance> operationalPerformance;
  final InventoryValuation inventoryValuation;

  ReportsAnalyticsResponse({
    required this.financialOverview,
    required this.operationalPerformance,
    required this.inventoryValuation,
  });

  factory ReportsAnalyticsResponse.fromJson(Map<String, dynamic> json) {
    return ReportsAnalyticsResponse(
      financialOverview: FinancialOverview.fromJson(json['financialOverview'] ?? {}),
      operationalPerformance: (json['operationalPerformance'] as List?)
          ?.map((e) => OperationalPerformance.fromJson(e))
          .toList() ?? [],
      inventoryValuation: InventoryValuation.fromJson(json['inventoryValuation'] ?? {}),
    );
  }
}

// ─── Promo Codes ────────────────────────────────────
class PromoCode {
  final String id;
  final String workshopId;
  final String code;
  final String discountType;
  final double discountValue;
  final String validFrom;
  final String validTo;
  final int usageLimit;
  final int usageCount;
  final double minOrderAmount;
  final String description;
  final bool isActive;
  final String createdAt;

  PromoCode({
    required this.id,
    required this.workshopId,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.validFrom,
    required this.validTo,
    required this.usageLimit,
    required this.usageCount,
    required this.minOrderAmount,
    required this.description,
    required this.isActive,
    required this.createdAt,
  });

  factory PromoCode.fromJson(Map<String, dynamic> json) {
    return PromoCode(
      id: json['id']?.toString() ?? '',
      workshopId: json['workshopId']?.toString() ?? '',
      code: json['code'] ?? '',
      discountType: json['discountType'] ?? '',
      discountValue: double.tryParse(json['discountValue']?.toString() ?? '0') ?? 0.0,
      validFrom: json['validFrom'] ?? '',
      validTo: json['validTo'] ?? '',
      usageLimit: int.tryParse(json['usageLimit']?.toString() ?? '0') ?? 0,
      usageCount: int.tryParse(json['usageCount']?.toString() ?? '0') ?? 0,
      minOrderAmount: double.tryParse(json['minOrderAmount']?.toString() ?? '0') ?? 0.0,
      description: json['description'] ?? '',
      isActive: json['isActive'] ?? false,
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class PromoCodesResponse {
  final bool success;
  final int total;
  final int limit;
  final int offset;
  final List<PromoCode> promoCodes;

  PromoCodesResponse({
    required this.success,
    required this.total,
    required this.limit,
    required this.offset,
    required this.promoCodes,
  });

  factory PromoCodesResponse.fromJson(Map<String, dynamic> json) {
    return PromoCodesResponse(
      success: json['success'] ?? false,
      total: json['total'] ?? 0,
      limit: json['limit'] ?? 20,
      offset: json['offset'] ?? 0,
      promoCodes: (json['promoCodes'] as List?)
          ?.map((e) => PromoCode.fromJson(e))
          .toList() ?? [],
    );
  }
}

// ─── Approvals ─────────────────────────────────────
class OwnerApproval {
  final String id;
  final String type; // 'Expense', 'Payment', 'Advance', 'Locker', 'PurchaseInvoice', 'PhysicalCount'
  final String submittedBy;
  final String branchName;
  final double amount;
  final DateTime date;
  final String description;
  String status; // 'pending', 'approved', 'rejected'

  OwnerApproval({
    required this.id,
    required this.type,
    required this.submittedBy,
    required this.branchName,
    required this.amount,
    required this.date,
    required this.description,
    this.status = 'pending',
  });
}

// ─── Accounting ────────────────────────────────────
class AccountEntry {
  final String id;
  final String type; // 'payable', 'receivable', 'expense', 'payment', 'advance'
  final String party;
  final double amount;
  final DateTime date;
  final String reference;
  final String status; // 'pending', 'settled', 'overdue'
  final String? notes;

  /// Translated display fields — set by the ViewModel after fetching,
  /// never populated from JSON.
  final String? translatedParty;
  final String? translatedStatus;

  AccountEntry({
    required this.id,
    required this.type,
    required this.party,
    required this.amount,
    required this.date,
    required this.reference,
    required this.status,
    this.notes,
    this.translatedParty,
    this.translatedStatus,
  });

  AccountEntry copyWith({
    String? id,
    String? type,
    String? party,
    double? amount,
    DateTime? date,
    String? reference,
    String? status,
    String? notes,
    String? translatedParty,
    String? translatedStatus,
  }) {
    return AccountEntry(
      id: id ?? this.id,
      type: type ?? this.type,
      party: party ?? this.party,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      reference: reference ?? this.reference,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      translatedParty: translatedParty ?? this.translatedParty,
      translatedStatus: translatedStatus ?? this.translatedStatus,
    );
  }

  factory AccountEntry.fromJson(Map<String, dynamic> json) {
    return AccountEntry(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? 'payable',
      party: json['name'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      date: json['date'] != null ? DateTime.tryParse(json['date']) ?? DateTime.now() : DateTime.now(),
      reference: json['ref'] ?? '',
      status: json['status']?.toString().toLowerCase() ?? 'pending',
      notes: json['notes'],
    );
  }
}

// ─── Notifications ─────────────────────────────────
class OwnerNotification {
  final String id;
  final String title;
  final String message;
  final String type; // 'expense', 'invoice', 'stock', 'payment', 'locker'
  final DateTime timestamp;
  bool isRead;

  OwnerNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });
}

// ─── Dashboard ─────────────────────────────────────
class BranchPerformance {
  final String id;
  final String name;
  final String address;
  final double monthlySales;

  BranchPerformance({
    required this.id,
    required this.name,
    required this.address,
    required this.monthlySales,
  });

  factory BranchPerformance.fromJson(Map<String, dynamic> json) {
    return BranchPerformance(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      monthlySales: double.tryParse(json['monthlySales']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class OwnerDashboardResponse {
  final bool success;
  final String dataScope;
  final String dataScopeLabel;
  final String? branchId;
  final double totalSalesToday;
  final double totalSalesThisMonth;
  final int pendingInvoicesCount;
  final int lowStockAlertsCount;
  final List<BranchPerformance> branchPerformance;

  OwnerDashboardResponse({
    required this.success,
    required this.dataScope,
    required this.dataScopeLabel,
    this.branchId,
    required this.totalSalesToday,
    required this.totalSalesThisMonth,
    required this.pendingInvoicesCount,
    required this.lowStockAlertsCount,
    required this.branchPerformance,
  });

  factory OwnerDashboardResponse.fromJson(Map<String, dynamic> json) {
    return OwnerDashboardResponse(
      success: json['success'] ?? false,
      dataScope: json['dataScope'] ?? '',
      dataScopeLabel: json['dataScopeLabel'] ?? '',
      branchId: json['branchId']?.toString(),
      totalSalesToday: double.tryParse(json['totalSalesToday']?.toString() ?? '0') ?? 0.0,
      totalSalesThisMonth: double.tryParse(json['totalSalesThisMonth']?.toString() ?? '0') ?? 0.0,
      pendingInvoicesCount: int.tryParse(json['pendingInvoicesCount']?.toString() ?? '0') ?? 0,
      lowStockAlertsCount: int.tryParse(json['lowStockAlertsCount']?.toString() ?? '0') ?? 0,
      branchPerformance: (json['branchPerformance'] as List?)
          ?.map((e) => BranchPerformance.fromJson(e))
          .toList() ??
          [],
    );
  }
}

// ─── Supplier Stats ────────────────────────────────
class SupplierStatsResponse {
  final bool success;
  final int totalSuppliers;
  final double totalOutstanding;
  final int pendingPurchaseOrders;
  final String currencyCode;

  SupplierStatsResponse({
    required this.success,
    required this.totalSuppliers,
    required this.totalOutstanding,
    required this.pendingPurchaseOrders,
    required this.currencyCode,
  });

  factory SupplierStatsResponse.fromJson(Map<String, dynamic> json) {
    return SupplierStatsResponse(
      success: json['success'] ?? false,
      totalSuppliers: json['totalSuppliers'] ?? 0,
      totalOutstanding: double.tryParse(json['totalOutstanding']?.toString() ?? '0') ?? 0.0,
      pendingPurchaseOrders: json['pendingPurchaseOrders'] ?? 0,
      currencyCode: json['currencyCode'] ?? 'SAR',
    );
  }
}

class AccountingSummary {
  final double payables;
  final double receivables;
  final double overdue;

  AccountingSummary({
    required this.payables,
    required this.receivables,
    required this.overdue,
  });

  factory AccountingSummary.fromJson(Map<String, dynamic> json) {
    return AccountingSummary(
      payables: double.tryParse(json['payables']?.toString() ?? '0') ?? 0.0,
      receivables: double.tryParse(json['receivables']?.toString() ?? '0') ?? 0.0,
      overdue: double.tryParse(json['overdue']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class AccountingSummaryResponse {
  final bool success;
  final String currency;
  final AccountingSummary summary;

  AccountingSummaryResponse({
    required this.success,
    required this.currency,
    required this.summary,
  });

  factory AccountingSummaryResponse.fromJson(Map<String, dynamic> json) {
    return AccountingSummaryResponse(
      success: json['success'] ?? false,
      currency: json['currency'] ?? 'SAR',
      summary: json['summary'] != null
          ? AccountingSummary.fromJson(json['summary'])
          : AccountingSummary(payables: 0, receivables: 0, overdue: 0),
    );
  }
}

class PettyCashRequestItem {
  final String id;
  final double amount;
  final String reason;
  final String status;
  final DateTime? requestedAt;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final String branchId;
  final String branchName;
  final String cashierId;
  final String cashierName;
  final String? approvedBy;
  /// `fund_request` | `expense` (workshop petty-cash queue).
  final String? kind;
  final String? categoryLabel;
  final String? employeeName;
  final String? proofUrl;

  /// Translated display fields — set by the ViewModel after fetching,
  /// never populated from JSON.
  final String? translatedPartyName;
  final String? translatedBranchName;
  final String? translatedCashierName;
  final String? translatedStatus;
  final String? translatedReason;
  final String? translatedCategoryLabel;
  final String? translatedEmployeeName;
  final String? translatedRejectionReason;

  /// Alias used by ApprovalsViewModel for the request party name.
  /// Falls back to [cashierName] since petty-cash requests have no separate
  /// party — the cashier is the requesting party.
  String? get partyName => cashierName.isNotEmpty ? cashierName : null;

  PettyCashRequestItem({
    required this.id,
    required this.amount,
    required this.reason,
    required this.status,
    this.requestedAt,
    this.approvedAt,
    this.rejectionReason,
    required this.branchId,
    required this.branchName,
    required this.cashierId,
    required this.cashierName,
    this.approvedBy,
    this.kind,
    this.categoryLabel,
    this.employeeName,
    this.proofUrl,
    this.translatedPartyName,
    this.translatedBranchName,
    this.translatedCashierName,
    this.translatedStatus,
    this.translatedReason,
    this.translatedCategoryLabel,
    this.translatedEmployeeName,
    this.translatedRejectionReason,
  });

  PettyCashRequestItem copyWith({
    String? id,
    double? amount,
    String? reason,
    String? status,
    DateTime? requestedAt,
    DateTime? approvedAt,
    String? rejectionReason,
    String? branchId,
    String? branchName,
    String? cashierId,
    String? cashierName,
    String? approvedBy,
    String? kind,
    String? categoryLabel,
    String? employeeName,
    String? proofUrl,
    String? translatedPartyName,
    String? translatedBranchName,
    String? translatedCashierName,
    String? translatedStatus,
    String? translatedReason,
    String? translatedCategoryLabel,
    String? translatedEmployeeName,
    String? translatedRejectionReason,
  }) {
    return PettyCashRequestItem(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      cashierId: cashierId ?? this.cashierId,
      cashierName: cashierName ?? this.cashierName,
      approvedBy: approvedBy ?? this.approvedBy,
      kind: kind ?? this.kind,
      categoryLabel: categoryLabel ?? this.categoryLabel,
      employeeName: employeeName ?? this.employeeName,
      proofUrl: proofUrl ?? this.proofUrl,
      translatedPartyName: translatedPartyName ?? this.translatedPartyName,
      translatedBranchName: translatedBranchName ?? this.translatedBranchName,
      translatedCashierName: translatedCashierName ?? this.translatedCashierName,
      translatedStatus: translatedStatus ?? this.translatedStatus,
      translatedReason: translatedReason ?? this.translatedReason,
      translatedCategoryLabel: translatedCategoryLabel ?? this.translatedCategoryLabel,
      translatedEmployeeName: translatedEmployeeName ?? this.translatedEmployeeName,
      translatedRejectionReason: translatedRejectionReason ?? this.translatedRejectionReason,
    );
  }

  bool get isExpenseKind {
    final k = kind?.toLowerCase() ?? '';
    return k == 'expense';
  }

  factory PettyCashRequestItem.fromJson(Map<String, dynamic> json) {
    final branch = (json['branch'] as Map<String, dynamic>?) ?? {};
    final cashier = (json['cashier'] as Map<String, dynamic>?) ?? {};

    String? categoryLabel;
    final cat = json['category'];
    if (cat is Map<String, dynamic>) {
      categoryLabel = cat['name']?.toString() ?? cat['id']?.toString();
    } else if (cat is String) {
      categoryLabel = cat;
    }

    String? employeeName;
    final emp = json['employee'];
    if (emp is Map<String, dynamic>) {
      employeeName = emp['name']?.toString() ?? emp['fullName']?.toString();
    } else {
      employeeName = json['employeeName']?.toString();
    }

    final reasonText = json['reason']?.toString() ??
        json['description']?.toString() ??
        json['notes']?.toString() ??
        '';

    return PettyCashRequestItem(
      id: json['id']?.toString() ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      reason: reasonText,
      status: json['status']?.toString() ?? 'pending',
      requestedAt: json['requestedAt'] != null
          ? DateTime.tryParse(json['requestedAt'].toString())
          : null,
      approvedAt: json['approvedAt'] != null
          ? DateTime.tryParse(json['approvedAt'].toString())
          : null,
      rejectionReason: json['rejectionReason']?.toString(),
      branchId: branch['id']?.toString() ?? json['branchId']?.toString() ?? '',
      branchName: branch['name']?.toString() ?? 'Unknown Branch',
      cashierId: cashier['id']?.toString() ?? '',
      cashierName: cashier['name']?.toString() ?? 'Unknown Cashier',
      approvedBy: json['approvedBy']?.toString(),
      kind: json['kind']?.toString(),
      categoryLabel: categoryLabel,
      employeeName: employeeName,
      proofUrl: json['proofUrl']?.toString() ?? json['proof']?.toString(),
    );
  }
}

class PettyCashRequestsResponse {
  final bool success;
  final String currency;
  final int total;
  final int limit;
  final int offset;
  final List<PettyCashRequestItem> requests;

  PettyCashRequestsResponse({
    required this.success,
    required this.currency,
    required this.total,
    required this.limit,
    required this.offset,
    required this.requests,
  });

  factory PettyCashRequestsResponse.fromJson(Map<String, dynamic> json) {
    return PettyCashRequestsResponse(
      success: json['success'] == true,
      currency: json['currency']?.toString() ?? 'SAR',
      total: int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      limit: int.tryParse(json['limit']?.toString() ?? '20') ?? 20,
      offset: int.tryParse(json['offset']?.toString() ?? '0') ?? 0,
      requests: ((json['requests'] as List?) ?? [])
          .whereType<Map<String, dynamic>>()
          .map(PettyCashRequestItem.fromJson)
          .toList(),
    );
  }
}