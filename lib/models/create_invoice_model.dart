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

  factory CreateInvoiceResponse.fromJson(Map<String, dynamic> json) {
    return CreateInvoiceResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      invoice: json['invoice'] != null
          ? Invoice.fromJson(json['invoice'])
          : null,
      statusCode: json['statusCode'],
    );
  }
}

class Invoice {
  final String id;
  final String invoiceNo;
  final String invoiceDate;
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
  final String vehicleInfo;
  final String vehicleMake;
  final String vehicleModel;
  final String plateNo;
  final String? branchName;
  final String? branchAddress;
  final String? cashierName;
  final String? cashierEmail;
  final String? cashierMobile;
  final String salesOrderId;
  final String salesOrderStatus;
  final String salesOrderSource;
  final String salesOrderCreatedAt;
  final String customerId;

  Invoice({
    required this.id,
    required this.invoiceNo,
    required this.invoiceDate,
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
    required this.vehicleInfo,
    this.vehicleMake = '',
    this.vehicleModel = '',
    required this.plateNo,
    this.branchName,
    this.branchAddress,
    this.cashierName,
    this.cashierEmail,
    this.cashierMobile,
    this.salesOrderId = '',
    this.salesOrderStatus = '',
    this.salesOrderSource = '',
    this.salesOrderCreatedAt = '',
    this.customerId = '',
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    var salesOrder = json['salesOrder'] ?? {};
    var branch = json['branch'] ?? {};
    var createdByUser = json['createdByUser'] ?? {};
    var customer = salesOrder['customer'] ?? {};
    var vehicle = salesOrder['vehicle'] ?? {};

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
      odometerReading: int.tryParse(
        salesOrder['odometerReading']?.toString() ?? '',
      ),
      vehicleInfo: '${vehicle['make'] ?? ""} ${vehicle['model'] ?? ""}'.trim(),
      vehicleMake: vehicle['make']?.toString() ?? '',
      vehicleModel: vehicle['model']?.toString() ?? '',
      plateNo: vehicle['plateNo'] ?? '',
      branchName: branch['name'],
      branchAddress: branch['address']?.toString(),
      cashierName: createdByUser['name'],
      cashierEmail: createdByUser['email']?.toString(),
      cashierMobile: createdByUser['mobile']?.toString(),
      salesOrderId: salesOrder['id']?.toString() ?? '',
      salesOrderStatus: salesOrder['status']?.toString() ?? '',
      salesOrderSource: salesOrder['source']?.toString() ?? '',
      salesOrderCreatedAt: salesOrder['createdAt']?.toString() ?? '',
      customerId: customer['id']?.toString() ?? '',
    );
  }
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

  InvoiceItem({
    required this.id,
    this.itemType = '',
    this.productId = '',
    required this.productName,
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
