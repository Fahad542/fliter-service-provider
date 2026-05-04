import 'order_payment_method_draft.dart';
import 'pos_payment_method.dart';

bool _invoiceAsBool(dynamic value) {
  if (value == true || value == 1) return true;
  final s = value?.toString().trim().toLowerCase() ?? '';
  return s == 'true' || s == '1' || s == 'yes';
}

int? _invoiceOptionalInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value.toString().trim());
}

String? _invoicePickFirstNonEmpty(Iterable<dynamic> candidates) {
  for (final v in candidates) {
    final s = v?.toString().trim() ?? '';
    if (s.isNotEmpty) return s;
  }
  return null;
}

String _invoiceFirstStringAcross(
  List<Map<String, dynamic>> buckets,
  Iterable<String> keys,
) {
  for (final k in keys) {
    for (final m in buckets) {
      final s = m[k]?.toString().trim() ?? '';
      if (s.isNotEmpty) return s;
    }
  }
  return '';
}

List<Map<String, dynamic>> _invoiceLookupBuckets({
  required Map<String, dynamic> vehicle,
  required Map<String, dynamic> salesOrder,
  required Map<String, dynamic> root,
  required Map<String, dynamic> customer,
}) {
  final custV = customer['vehicle'] is Map
      ? Map<String, dynamic>.from(customer['vehicle'] as Map)
      : <String, dynamic>{};
  return [vehicle, custV, salesOrder, customer, root];
}

String _invoicePickVinBuckets(List<Map<String, dynamic>> buckets) {
  const keys = [
    'vin',
    'VIN',
    'carNo',
    'vinNumber',
    'chassisNumber',
    'chassisNo',
    'chassis',
  ];
  return _invoiceFirstStringAcross(buckets, keys);
}

String _invoicePickYearBuckets(List<Map<String, dynamic>> buckets) {
  const keys = [
    'year',
    'Year',
    'modelYear',
    'vehicleYear',
    'carYear',
    'yr',
  ];
  return _invoiceFirstStringAcross(buckets, keys);
}

int? _invoicePickOdometerBuckets(List<Map<String, dynamic>> buckets) {
  const keys = [
    'odometerReading',
    'odometer',
    'mileage',
    'mileageReading',
    'odo',
    'odometer_reading',
  ];
  for (final k in keys) {
    for (final b in buckets) {
      final raw = b[k];
      if (raw == null) continue;
      final n = raw is num
          ? raw.toInt()
          : int.tryParse(raw.toString().replaceAll(RegExp(r'[^0-9-]'), ''));
      if (n != null && n > 0) return n;
    }
  }
  return null;
}

List<bool>? _invoiceParseMaintenanceChecksMap(dynamic raw) {
  if (raw == null || raw is! Map) return null;
  final c = raw['checks'];
  if (c is! List || c.length != 6) return null;
  return List<bool>.generate(6, (i) {
    final v = c[i];
    return v == true || v == 1 || '${v}' == '1' || '${v}'.toLowerCase() == 'true';
  });
}

List<bool>? _invoiceParseMaintenanceChecksList(dynamic raw) {
  if (raw == null || raw is! List || raw.length != 6) return null;
  return List<bool>.generate(6, (i) {
    final v = raw[i];
    return v == true || v == 1 || '${v}' == '1' || '${v}'.toLowerCase() == 'true';
  });
}

/// Invoice root, nested `data.invoice`, or `salesOrder` maintenance payloads.
List<bool>? _invoiceMaintenanceChecksFromPayload(
  Map<String, dynamic> json,
  Map<String, dynamic> salesOrder,
) {
  List<bool>? fromAny(dynamic raw) =>
      _invoiceParseMaintenanceChecksMap(raw) ??
      _invoiceParseMaintenanceChecksList(raw);

  final rootData = json['data'];
  final Map<String, dynamic>? dataInvoice =
      rootData is Map && (rootData['invoice'] ?? rootData['Invoice']) is Map
          ? Map<String, dynamic>.from(
              (rootData['invoice'] ?? rootData['Invoice']) as Map)
          : null;

  return fromAny(json['maintenanceChecklist']) ??
      fromAny(json['maintenance_checklist']) ??
      fromAny(json['maintenanceChecks']) ??
      fromAny(json['maintenance_checks']) ??
      fromAny(salesOrder['maintenanceChecklist']) ??
      fromAny(salesOrder['maintenance_checklist']) ??
      fromAny(salesOrder['maintenanceChecks']) ??
      fromAny(salesOrder['maintenance_checks']) ??
      (dataInvoice == null
          ? null
          : (fromAny(dataInvoice['maintenanceChecklist']) ??
              fromAny(dataInvoice['maintenanceChecks'])));
}

class CreateInvoiceRequest {
  final String orderId;
  final double discountAmount;
  final String invoiceDate;
  final String? paymentMethod;
  final List<Map<String, dynamic>>? payments;
  final bool? isCorporate;

  CreateInvoiceRequest({
    required this.orderId,
    this.discountAmount = 0,
    required this.invoiceDate,
    this.paymentMethod,
    this.payments,
    this.isCorporate,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'discountAmount': discountAmount,
      'invoiceDate': invoiceDate,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (payments != null) 'payments': payments,
      if (isCorporate != null) 'isCorporate': isCorporate,
    };
  }
}

class CreateInvoiceResponse {
  final bool success;
  final String message;
  final Invoice? invoice;
  final int? statusCode;

  CreateInvoiceResponse({
    required this.success,
    required this.message,
    this.invoice,
    this.statusCode,
  });

  /// Resolves `invoice` from `invoice`, `data.invoice`, or `data` (when it looks like an invoice).
  static Invoice? _parseInvoiceField(Map<String, dynamic> json) {
    dynamic raw = json['invoice'];
    if (raw == null && json['data'] != null) {
      final data = json['data'];
      if (data is Map<String, dynamic>) {
        raw = data['invoice'] ?? data;
      }
    }
    if (raw is! Map) return null;
    try {
      return Invoice.fromJson(Map<String, dynamic>.from(raw));
    } catch (_) {
      return null;
    }
  }

  factory CreateInvoiceResponse.fromJson(Map<String, dynamic> json) {
    return CreateInvoiceResponse(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      invoice: _parseInvoiceField(json),
      statusCode: json['statusCode'] is int
          ? json['statusCode'] as int
          : int.tryParse(json['statusCode']?.toString() ?? ''),
    );
  }
}

class Invoice {
  final String id;
  final String invoiceNo;
  final String invoiceDate;
  /// When the invoice record was issued (for “Time:” on PDF / dialog). Optional for legacy APIs.
  final String? issuedAt;
  final double subtotal;
  final double vatAmount;
  final double discountAmount;
  final double totalAmount;
  final String paymentStatus;
  final String? paymentMethod;
  final String? promoCodeName;
  final List<InvoiceItem> items;
  final List<InvoiceDepartment> departments;
  final List<InvoicePayment> payments;
  final String customerName;
  final String customerType;
  final String? customerMobile;
  final String? customerTaxId;
  final int? odometerReading;
  /// Entered odometer + oil product `kmTypeValue` (km); full invoice customer block only.
  final int? nextOilChangeKm;
  final String vehicleInfo;
  final String vehicleMake;
  final String vehicleModel;
  final String plateNo;
  /// Vehicle identification number (when present on order/invoice payload).
  final String vehicleVin;
  /// Model year as shown on invoice (string to preserve API formatting).
  final String vehicleYear;
  final String? branchName;
  final String? branchAddress;
  /// Branch VAT registration when set (preferred over [workshopTaxId] on print).
  final String? branchVatId;
  final String? cashierName;
  final String? cashierEmail;
  final String? cashierMobile;
  /// Legal / display name from workshop (may be Arabic).
  final String? workshopName;
  final String? workshopTaxId;
  final String? workshopAddress;
  final String salesOrderId;
  final String salesOrderStatus;
  final String salesOrderSource;
  final String salesOrderCreatedAt;
  final String customerId;
  /// Six booleans for bilingual maintenance checklist (invoice print).
  final List<bool>? maintenanceChecklistChecks;

  /// Cashier PAYMENT‑METHOD PATCH draft hint (`individual` vs `corporate`, or `employee` when sent).
  final String? posCustomerKind;
  /// Corporate account / order linkage when present on invoice or nested sales order.
  final String? orderCorporateAccountId;
  final String? corporateOrderId;
  final String? corporateCompanyName;
  /// Explicit `isCorporate` on invoice or sales order payloads.
  final bool isCorporateInvoiceFlag;

  Invoice({
    required this.id,
    required this.invoiceNo,
    required this.invoiceDate,
    this.issuedAt,
    required this.subtotal,
    required this.vatAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.paymentStatus,
    this.paymentMethod,
    this.promoCodeName,
    required this.items,
    required this.departments,
    required this.payments,
    required this.customerName,
    required this.customerType,
    this.customerMobile,
    this.customerTaxId,
    this.odometerReading,
    this.nextOilChangeKm,
    required this.vehicleInfo,
    this.vehicleMake = '',
    this.vehicleModel = '',
    required this.plateNo,
    this.vehicleVin = '',
    this.vehicleYear = '',
    this.branchName,
    this.branchAddress,
    this.branchVatId,
    this.cashierName,
    this.cashierEmail,
    this.cashierMobile,
    this.workshopName,
    this.workshopTaxId,
    this.workshopAddress,
    this.salesOrderId = '',
    this.salesOrderStatus = '',
    this.salesOrderSource = '',
    this.salesOrderCreatedAt = '',
    this.customerId = '',
    this.maintenanceChecklistChecks,
    this.posCustomerKind,
    this.orderCorporateAccountId,
    this.corporateOrderId,
    this.corporateCompanyName,
    this.isCorporateInvoiceFlag = false,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    final salesOrder = json['salesOrder'] is Map
        ? Map<String, dynamic>.from(json['salesOrder'] as Map)
        : <String, dynamic>{};
    var branch = json['branch'] ?? {};
    var createdByUser = json['createdByUser'] ?? {};
    var workshopRaw = json['workshop'];
    final workshopMap = workshopRaw is Map
        ? Map<String, dynamic>.from(workshopRaw)
        : <String, dynamic>{};
    final customer = salesOrder['customer'] is Map
        ? Map<String, dynamic>.from(salesOrder['customer'] as Map)
        : <String, dynamic>{};
    final corporateMap = json['corporate'] is Map
        ? Map<String, dynamic>.from(json['corporate'] as Map)
        : <String, dynamic>{};

    final posCustomerKindParsed = _invoicePickFirstNonEmpty([
      json['posCustomerKind'],
      json['pos_customer_kind'],
      salesOrder['posCustomerKind'],
      salesOrder['pos_customer_kind'],
      customer['posCustomerKind'],
      customer['pos_customer_kind'],
      customer['customerKind'],
      salesOrder['customerKind'],
    ]);
    final orderCorporateAccountId = _invoicePickFirstNonEmpty([
      json['corporateAccountId'],
      json['corporate_account_id'],
      corporateMap['accountId'],
      salesOrder['corporateAccountId'],
      salesOrder['corporate_account_id'],
    ]);
    final corporateCompanyName = _invoicePickFirstNonEmpty([
      json['corporateCompanyName'],
      corporateMap['companyName'],
      salesOrder['corporateCompanyName'],
    ]);
    final corporateOrderId = _invoicePickFirstNonEmpty([
      json['corporateOrderId'],
      json['corporate_order_id'],
      salesOrder['corporateOrderId'],
      salesOrder['corporate_order_id'],
    ]);
    final isCorporateInvoiceFlag = _invoiceAsBool(json['isCorporate']) ||
        _invoiceAsBool(salesOrder['isCorporate']);
    var vehicle = salesOrder['vehicle'] is Map
        ? Map<String, dynamic>.from(salesOrder['vehicle'] as Map)
        : <String, dynamic>{};
    if (json['vehicle'] is Map) {
      vehicle = {
        ...vehicle,
        ...Map<String, dynamic>.from(json['vehicle'] as Map),
      };
    }

    final lookupBuckets = _invoiceLookupBuckets(
      vehicle: vehicle,
      salesOrder: salesOrder,
      root: json,
      customer: customer,
    );

    final vehicleMake = _invoiceFirstStringAcross(lookupBuckets, const [
      'make',
      'Make',
      'carMake',
      'vehicleMake',
      'brand',
      'carBrand',
    ]);
    final vehicleModel = _invoiceFirstStringAcross(lookupBuckets, const [
      'model',
      'Model',
      'carModel',
      'vehicleModel',
    ]);
    final plateNo = _invoiceFirstStringAcross(lookupBuckets, const [
      'plateNo',
      'plate',
      'Plate',
      'vehicleNumber',
      'vehicle_registration',
      'registrationNumber',
    ]);
    final mergedVehicleInfo = '${vehicleMake} ${vehicleModel}'.trim();
    // Parse Departments from jobs array or fallback to departments
    var departmentsList =
        salesOrder['jobs'] as List? ?? salesOrder['departments'] as List? ?? [];
    List<InvoiceDepartment> parsedDepartments = departmentsList
        .map((d) => InvoiceDepartment.fromJson(d))
        .toList();

    // Fallback for legacy flat items
    var flatItemsList = salesOrder['items'] as List? ?? [];
    if (parsedDepartments.isEmpty && flatItemsList.isNotEmpty) {
      parsedDepartments.add(
        InvoiceDepartment(
          jobId: '',
          jobStatus: '',
          departmentId: 'legacy',
          departmentName: 'General Items',
          subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0,
          amountBeforeDiscount: 0,
          amountAfterDiscount: 0,
          amountAfterPromo: 0,
          vatPercent: 0,
          vatAmount: 0,
          totalAmount: 0,
          commissions: [],
          items: flatItemsList.map((i) => InvoiceItem.fromJson(i)).toList(),
        ),
      );
    }

    // Preserve flat items list for legacy widgets
    List<InvoiceItem> allItems = [];
    for (var d in parsedDepartments) {
      allItems.addAll(d.items);
    }

    // Parse Payments
    var paymentsList = json['payments'] as List? ?? [];
    List<InvoicePayment> parsedPayments = paymentsList
        .map((p) => InvoicePayment.fromJson(p))
        .toList();

    return Invoice(
      id: json['id']?.toString() ?? '',
      invoiceNo: json['invoiceNo'] ?? '',
      invoiceDate: json['invoiceDate'] ?? '',
      issuedAt: json['issuedAt']?.toString() ?? json['issued_at']?.toString(),
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0,
      vatAmount: double.tryParse(json['vatAmount']?.toString() ?? '0') ?? 0,
      discountAmount: [
        double.tryParse(json['discountAmount']?.toString() ?? '0') ?? 0,
        double.tryParse(json['totalDiscountValue']?.toString() ?? '0') ?? 0,
        double.tryParse(salesOrder['discountAmount']?.toString() ?? '0') ?? 0,
        double.tryParse(salesOrder['totalDiscountValue']?.toString() ?? '0') ?? 0,
      ].reduce((a, b) => a > b ? a : b),
      totalAmount: double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0,
      paymentStatus: json['paymentStatus'] ?? '',
      paymentMethod: json['paymentMethod'],
      promoCodeName: json['promoCodeName']?.toString() ?? salesOrder['promoCodeName']?.toString(),
      items: allItems,
      departments: parsedDepartments,
      payments: parsedPayments,
      customerName: customer['name'] ?? 'Unknown',
      customerType:
          customer['customerType']?.toString() ??
          customer['type']?.toString() ??
          'Individual',
      customerMobile: customer['mobile']?.toString(),
      customerTaxId: customer['taxId']?.toString(),
      odometerReading: _invoicePickOdometerBuckets(lookupBuckets),
      nextOilChangeKm: _invoiceOptionalInt(
        salesOrder['nextOilChangeKm'] ?? json['nextOilChangeKm'],
      ),
      vehicleInfo: mergedVehicleInfo,
      vehicleMake: vehicleMake,
      vehicleModel: vehicleModel,
      plateNo: plateNo,
      vehicleVin: _invoicePickVinBuckets(lookupBuckets),
      vehicleYear: _invoicePickYearBuckets(lookupBuckets),
      branchName: branch['name'],
      branchAddress: branch['address']?.toString(),
      branchVatId: branch['vatId']?.toString(),
      cashierName: createdByUser['name'],
      cashierEmail: createdByUser['email']?.toString(),
      cashierMobile: createdByUser['mobile']?.toString(),
      salesOrderId: salesOrder['id']?.toString() ?? '',
      salesOrderStatus: salesOrder['status']?.toString() ?? '',
      salesOrderSource: salesOrder['source']?.toString() ?? '',
      salesOrderCreatedAt: salesOrder['createdAt']?.toString() ?? '',
      customerId: customer['id']?.toString() ?? '',
      workshopName: workshopMap['name']?.toString(),
      workshopTaxId: workshopMap['taxId']?.toString(),
      workshopAddress: workshopMap['address']?.toString(),
      maintenanceChecklistChecks: _invoiceMaintenanceChecksFromPayload(json, salesOrder),
      posCustomerKind: posCustomerKindParsed,
      orderCorporateAccountId: orderCorporateAccountId,
      corporateOrderId: corporateOrderId,
      corporateCompanyName: corporateCompanyName,
      isCorporateInvoiceFlag: isCorporateInvoiceFlag,
    );
  }
}

/// Thermal receipt: manual walk‑in → Normal; payroll / employee tender → Employee; corporate → Corporate.
String resolveThermalInvoiceCustomerTypeLabel(Invoice invoice) {
  if (_thermalInvoiceTreatsAsCorporateCustomer(invoice)) return 'Corporate';
  if (_thermalInvoiceTreatsAsEmployeeCustomer(invoice)) return 'Employee';
  return 'Normal';
}

extension InvoiceThermalCustomerTypeLabels on Invoice {
  String get thermalDisplayedCustomerType =>
      resolveThermalInvoiceCustomerTypeLabel(this);
}

bool _thermalInvoiceTreatsAsCorporateCustomer(Invoice invoice) {
  if (invoice.isCorporateInvoiceFlag) return true;
  final kind = invoice.posCustomerKind?.trim().toLowerCase() ?? '';
  if (kind == 'corporate') return true;
  if ((invoice.orderCorporateAccountId ?? '').trim().isNotEmpty) return true;
  if ((invoice.corporateOrderId ?? '').trim().isNotEmpty) return true;
  if ((invoice.corporateCompanyName ?? '').trim().isNotEmpty) return true;

  final src = invoice.salesOrderSource.toLowerCase().replaceAll('_', '').trim();
  if (src.contains('corporate')) return true;

  final ctApi = invoice.customerType.toLowerCase().trim();
  if (ctApi.contains('corporate') || ctApi == 'company') return true;

  if (invoice.paymentMethod != null && invoice.paymentMethod!.trim().isNotEmpty) {
    if (parsePaymentMethodFromDraftApiLabel(invoice.paymentMethod!) ==
        PaymentMethod.monthlyBilling) {
      return true;
    }
  }
  for (final p in invoice.payments) {
    if (parsePaymentMethodFromDraftApiLabel(p.method) ==
        PaymentMethod.monthlyBilling) {
      return true;
    }
  }
  return false;
}

bool _thermalInvoiceTreatsAsEmployeeCustomer(Invoice invoice) {
  final kind = invoice.posCustomerKind?.trim().toLowerCase() ?? '';
  if (kind.contains('employee')) return true;

  final ctApi = invoice.customerType.toLowerCase().trim();
  if (ctApi.contains('employee')) return true;

  if (invoice.paymentMethod != null && invoice.paymentMethod!.trim().isNotEmpty) {
    if (parsePaymentMethodFromDraftApiLabel(invoice.paymentMethod!) ==
        PaymentMethod.employees) {
      return true;
    }
  }
  for (final p in invoice.payments) {
    if (parsePaymentMethodFromDraftApiLabel(p.method) ==
        PaymentMethod.employees) {
      return true;
    }
  }
  return false;
}

class InvoiceItem {
  final String id;
  final String itemType;
  final String productId;
  final String productName;
  final double qty;
  final double unitPrice;
  final double lineTotal;
  final String? discountType;
  final double? discountValue;
  final double beforeDiscountPrice;
  final double afterDiscountPrice;
  /// Arabic product/service title for bilingual thermal receipts when API sends it.
  final String? productNameArabic;

  InvoiceItem({
    required this.id,
    this.itemType = '',
    this.productId = '',
    required this.productName,
    this.productNameArabic,
    required this.qty,
    required this.unitPrice,
    required this.lineTotal,
    this.discountType,
    this.discountValue,
    this.beforeDiscountPrice = 0,
    this.afterDiscountPrice = 0,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id']?.toString() ?? '',
      itemType: json['itemType']?.toString() ?? '',
      productId: json['productId']?.toString() ?? json['serviceId']?.toString() ?? '',
      productName: json['productName'] ?? json['name'] ?? '',
      productNameArabic:
          json['productNameArabic']?.toString() ??
          json['nameAr']?.toString() ??
          json['arabicName']?.toString() ??
          json['name_ar']?.toString(),
      qty: double.tryParse(json['qty']?.toString() ?? '0') ?? 0,
      unitPrice: double.tryParse(json['unitPrice']?.toString() ?? '0') ?? 0,
      lineTotal: double.tryParse(json['lineTotal']?.toString() ?? '0') ?? 0,
      discountType: json['discountType']?.toString(),
      discountValue: double.tryParse(json['discountValue']?.toString() ?? '0') ?? 0.0,
      beforeDiscountPrice:
          double.tryParse(json['beforeDiscountPrice']?.toString() ?? '0') ?? 0,
      afterDiscountPrice:
          double.tryParse(json['afterDiscountPrice']?.toString() ?? '0') ?? 0,
    );
  }
}

class InvoiceDepartment {
  final String jobId;
  final String jobStatus;
  final String departmentId;
  final String departmentName;
  final double subtotal;
  final double amountBeforeDiscount;
  final double amountAfterDiscount;
  final double amountAfterPromo;
  final double vatPercent;
  final double vatAmount;
  final double totalAmount;
  final String? totalDiscountType;
  final double totalDiscountValue;
  final double promoDiscountAmount;
  final String? promoCodeName;
  final List<InvoiceCommission> commissions;
  final List<InvoiceItem> items;

  InvoiceDepartment({
    required this.jobId,
    required this.jobStatus,
    required this.departmentId,
    required this.departmentName,
    required this.subtotal,
    required this.amountBeforeDiscount,
    required this.amountAfterDiscount,
    required this.amountAfterPromo,
    required this.vatPercent,
    required this.vatAmount,
    required this.totalAmount,
    this.totalDiscountType,
    this.totalDiscountValue = 0,
    this.promoDiscountAmount = 0,
    this.promoCodeName,
    required this.commissions,
    required this.items,
  });

  factory InvoiceDepartment.fromJson(Map<String, dynamic> json) {
    var commissionsList =
        json['technicians'] as List? ?? json['commissions'] as List? ?? [];
    var itemsList = json['items'] as List? ?? [];

    return InvoiceDepartment(
      jobId: json['id']?.toString() ?? json['jobId']?.toString() ?? '',
      jobStatus: json['status']?.toString() ?? '',
      departmentId: json['departmentId']?.toString() ?? '',
      departmentName: json['department'] ?? json['departmentName'] ?? '',
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0,
      amountBeforeDiscount:
          double.tryParse(json['amountBeforeDiscount']?.toString() ?? '0') ?? 0,
      amountAfterDiscount:
          double.tryParse(json['amountAfterDiscount']?.toString() ?? '0') ?? 0,
      amountAfterPromo:
          double.tryParse(json['amountAfterPromo']?.toString() ?? '0') ?? 0,
      vatPercent: double.tryParse(json['vatPercent']?.toString() ?? '0') ?? 0,
      vatAmount: double.tryParse(json['vatAmount']?.toString() ?? '0') ?? 0,
      totalAmount: double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0,
      totalDiscountType: json['totalDiscountType']?.toString(),
      totalDiscountValue:
          double.tryParse(json['totalDiscountValue']?.toString() ?? '0') ?? 0,
      promoDiscountAmount:
          double.tryParse(json['promoDiscountAmount']?.toString() ?? '0') ?? 0,
      promoCodeName: json['promoCodeName']?.toString(),
      commissions: commissionsList
          .map((c) => InvoiceCommission.fromJson(c))
          .toList(),
      items: itemsList.map((i) => InvoiceItem.fromJson(i)).toList(),
    );
  }
}

class InvoiceCommission {
  final String technicianName;
  final double commissionAmount;
  final double commissionPercent;

  InvoiceCommission({
    required this.technicianName,
    required this.commissionAmount,
    this.commissionPercent = 0,
  });

  factory InvoiceCommission.fromJson(Map<String, dynamic> json) {
    return InvoiceCommission(
      technicianName: json['name'] ?? json['technicianName'] ?? '',
      commissionAmount:
          double.tryParse(json['commissionAmount']?.toString() ?? '0') ?? 0,
      commissionPercent:
          double.tryParse(json['commissionPercent']?.toString() ?? '0') ?? 0,
    );
  }
}

class InvoicePayment {
  final String id;
  final String paidAt;
  final String method;
  final double amount;
  final String? receivedBy;

  InvoicePayment({
    required this.id,
    required this.paidAt,
    required this.method,
    required this.amount,
    this.receivedBy,
  });

  factory InvoicePayment.fromJson(Map<String, dynamic> json) {
    var receivedByUser = json['receivedByUser'] ?? {};
    return InvoicePayment(
      id: json['id']?.toString() ?? '',
      paidAt: json['paidAt'] ?? '',
      method: json['method'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      receivedBy: receivedByUser['name'],
    );
  }
}
