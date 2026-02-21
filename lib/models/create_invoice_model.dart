class CreateInvoiceRequest {
  final String orderId;
  final double discountAmount;
  final String invoicedDate;

  CreateInvoiceRequest({
    required this.orderId,
    this.discountAmount = 0,
    required this.invoicedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'discountAmount': discountAmount,
      'invoicedDate': invoicedDate,
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
      invoice: json['invoice'] != null ? Invoice.fromJson(json['invoice']) : null,
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
  final List<InvoiceItem> items;
  final String customerName;
  final String vehicleInfo;
  final String plateNo;
  final String? branchName;
  final String? cashierName;

  Invoice({
    required this.id,
    required this.invoiceNo,
    required this.invoiceDate,
    required this.subtotal,
    required this.vatAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.paymentStatus,
    required this.items,
    required this.customerName,
    required this.vehicleInfo,
    required this.plateNo,
    this.branchName,
    this.cashierName,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    var salesOrder = json['salesOrder'] ?? {};
    var itemsList = salesOrder['items'] as List? ?? [];
    var customer = salesOrder['customer'] ?? {};
    var vehicle = salesOrder['vehicle'] ?? {};
    var branch = json['branch'] ?? {};
    var createdByUser = json['createdByUser'] ?? {};

    return Invoice(
      id: json['id']?.toString() ?? '',
      invoiceNo: json['invoiceNo'] ?? '',
      invoiceDate: json['invoiceDate'] ?? '',
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0,
      vatAmount: double.tryParse(json['vatAmount']?.toString() ?? '0') ?? 0,
      discountAmount: double.tryParse(json['discountAmount']?.toString() ?? '0') ?? 0,
      totalAmount: double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0,
      paymentStatus: json['paymentStatus'] ?? '',
      items: itemsList.map((i) => InvoiceItem.fromJson(i)).toList(),
      customerName: customer['name'] ?? 'Unknown',
      vehicleInfo: '${vehicle['make'] ?? ""} ${vehicle['model'] ?? ""}'.trim(),
      plateNo: vehicle['plateNo'] ?? '',
      branchName: branch['name'],
      cashierName: createdByUser['name'],
    );
  }
}

class InvoiceItem {
  final String id;
  final String productName;
  final double qty;
  final double unitPrice;
  final double lineTotal;

  InvoiceItem({
    required this.id,
    required this.productName,
    required this.qty,
    required this.unitPrice,
    required this.lineTotal,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id']?.toString() ?? '',
      productName: json['productName'] ?? '',
      qty: double.tryParse(json['qty']?.toString() ?? '0') ?? 0,
      unitPrice: double.tryParse(json['unitPrice']?.toString() ?? '0') ?? 0,
      lineTotal: double.tryParse(json['lineTotal']?.toString() ?? '0') ?? 0,
    );
  }
}
