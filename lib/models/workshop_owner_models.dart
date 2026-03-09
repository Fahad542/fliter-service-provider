import 'package:flutter/material.dart';

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
  final String status;
  final double salesMTD;

  Branch({
    required this.id,
    required this.name,
    required this.location,
    required this.vat,
    required this.cr,
    required this.status,
    required this.salesMTD,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      location: json['address'] ?? json['location'] ?? '',
      vat: json['vat'] ?? '',
      cr: json['cr'] ?? '',
      status: (json['isActive'] == true) ? 'active' : (json['status'] ?? 'active'),
      salesMTD: (json['salesMTD'] ?? 0.0).toDouble(),
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
  final String status;

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
    this.status = 'active',
  });

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
      isAvailable: json['status']?['status'] == 'online' || json['is_available'] == true,
      status: (json['isActive'] == true) ? 'active' : (json['status'] is String ? json['status'] : 'active'),
    );
  }
}

class OwnerProduct {
  final String id;
  final String name;
  final String type; // 'product', 'service'
  final String? category;
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

  OwnerProduct({
    required this.id,
    required this.name,
    required this.type,
    this.category,
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
  });

  factory OwnerProduct.fromJson(Map<String, dynamic> json) {
    return OwnerProduct(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'product',
      category: json['categoryName'] ?? json['category'] ?? '',
      departmentName: json['departmentName'],
      departmentIds: [json['departmentId']?.toString() ?? ''].where((id) => id.isNotEmpty).toList(),
      unit: json['unit'] ?? 'pcs',
      conversionFactor: (json['conversion_factor'] ?? 1.0).toDouble(),
      purchasePrice: double.tryParse(json['purchasePrice']?.toString() ?? '0') ?? (json['purchase_price_excl'] ?? 0.0).toDouble(),
      salePrice: double.tryParse(json['salePrice']?.toString() ?? '0') ?? (json['sale_price_incl'] ?? 0.0).toDouble(),
      corporateBasePrice: double.tryParse(json['corporate_price']?.toString() ?? '0') ?? 0.0,
      corporateLowerLimit: double.tryParse(json['corporate_lower_limit']?.toString() ?? '0') ?? 0.0,
      corporateUpperLimit: double.tryParse(json['corporate_upper_limit']?.toString() ?? '0') ?? 0.0,
      stockQty: double.tryParse(json['openingQty']?.toString() ?? '0') ?? (json['stock_qty'] ?? 0.0).toDouble(),
      criticalLevel: double.tryParse(json['criticalStockPoint']?.toString() ?? '0') ?? (json['critical_level'] ?? 0.0).toDouble(),
      reorderLevel: (json['reorder_level'] ?? 0.0).toDouble(),
      imageUrl: json['image_url'],
      isPriceEditable: json['is_price_editable'] ?? false,
    );
  }
}

class OwnerSubCategory {
  final String id;
  final String name;

  OwnerSubCategory({required this.id, required this.name});

  factory OwnerSubCategory.fromJson(Map<String, dynamic> json) {
    return OwnerSubCategory(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
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
  final List<String> allowedBranchIds;
  final String status;
  final String category; // e.g., 'Bronze', 'Silver', 'Gold'
  final double totalSales;
  final int vehicleCount;

  CorporateCustomer({
    required this.id,
    required this.companyName,
    required this.vatNumber,
    required this.contactName,
    required this.mobile,
    required this.email,
    this.creditLimit = 0.0,
    this.dueBalance = 0.0,
    required this.allowedBranchIds,
    this.status = 'active',
    this.category = 'Bronze',
    this.totalSales = 0.0,
    this.vehicleCount = 0,
  });

  factory CorporateCustomer.fromJson(Map<String, dynamic> json) {
    return CorporateCustomer(
      id: json['id']?.toString() ?? '',
      companyName: json['companyName'] ?? json['company_name'] ?? '',
      vatNumber: (json['customer'] != null && json['customer']['taxId'] != null)
          ? json['customer']['taxId'].toString()
          : (json['vat_number'] ?? ''),
      contactName: json['contactPerson'] ?? json['contact_name'] ?? '',
      mobile: (json['customer'] != null && json['customer']['mobile'] != null)
          ? json['customer']['mobile'].toString()
          : (json['mobile'] ?? ''),
      email: json['email'] ?? '', // Email isn't explicitly in the screenshot but good to have fallback
      creditLimit: double.tryParse(json['creditLimit']?.toString() ?? '0') ?? 0.0,
      dueBalance: double.tryParse(json['dueBalance']?.toString() ?? '0') ?? 0.0,
      allowedBranchIds: List<String>.from(json['selectedBranchIds'] ?? json['allowed_branch_ids'] ?? []),
      status: json['status'] ?? 'active',
      category: json['category'] ?? 'Bronze',
      totalSales: (json['total_sales'] ?? 0.0).toDouble(),
      vehicleCount: json['vehicle_count'] ?? 0,
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
  });

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
  final String? vatNumber;
  final double outstanding;
  final String status;

  Supplier({
    required this.id,
    required this.name,
    required this.category,
    required this.mobile,
    this.vatNumber,
    this.outstanding = 0.0,
    this.status = 'active',
  });
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
  final String status; // 'open', 'closing', 'closed'
  final double shiftSales;
  final int openOrders;
  final DateTime openedAt;
  final DateTime? closedAt;
  final double? systemTotal;
  final double? physicalTotal;

  PosCounter({
    required this.id,
    required this.cashierName,
    required this.branchName,
    required this.status,
    required this.shiftSales,
    this.openOrders = 0,
    required this.openedAt,
    this.closedAt,
    this.systemTotal,
    this.physicalTotal,
  });

  double get locker => (systemTotal ?? 0) - (physicalTotal ?? 0);
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

  AccountEntry({
    required this.id,
    required this.type,
    required this.party,
    required this.amount,
    required this.date,
    required this.reference,
    required this.status,
    this.notes,
  });
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

