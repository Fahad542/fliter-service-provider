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
      category: json['category'],
      departmentIds: List<String>.from(json['department_ids'] ?? []),
      unit: json['unit'] ?? '',
      conversionFactor: (json['conversion_factor'] ?? 1.0).toDouble(),
      purchasePrice: (json['purchase_price_excl'] ?? 0.0).toDouble(),
      salePrice: (json['sale_price_incl'] ?? 0.0).toDouble(),
      corporateBasePrice: (json['corporate_price'] ?? 0.0).toDouble(),
      corporateLowerLimit: (json['corporate_lower_limit'] ?? 0.0).toDouble(),
      corporateUpperLimit: (json['corporate_upper_limit'] ?? 0.0).toDouble(),
      stockQty: (json['stock_qty'] ?? 0.0).toDouble(),
      criticalLevel: (json['critical_level'] ?? 0.0).toDouble(),
      reorderLevel: (json['reorder_level'] ?? 0.0).toDouble(),
      imageUrl: json['image_url'],
      isPriceEditable: json['is_price_editable'] ?? false,
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
    required this.allowedBranchIds,
    this.status = 'active',
    this.category = 'Bronze',
    this.totalSales = 0.0,
    this.vehicleCount = 0,
  });

  factory CorporateCustomer.fromJson(Map<String, dynamic> json) {
    return CorporateCustomer(
      id: json['id']?.toString() ?? '',
      companyName: json['company_name'] ?? '',
      vatNumber: json['vat_number'] ?? '',
      contactName: json['contact_name'] ?? '',
      mobile: json['mobile'] ?? '',
      email: json['email'] ?? '',
      allowedBranchIds: List<String>.from(json['allowed_branch_ids'] ?? []),
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

