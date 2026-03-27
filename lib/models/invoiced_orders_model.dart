class InvoicedOrderResponse {
  final bool success;
  final List<InvoicedOrder> orders;

  InvoicedOrderResponse({required this.success, required this.orders});

  factory InvoicedOrderResponse.fromJson(Map<String, dynamic> json) {
    return InvoicedOrderResponse(
      success: json['success'] ?? false,
      orders: (json['orders'] as List<dynamic>?)
              ?.map((e) => InvoicedOrder.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class InvoicedOrder {
  final String id;
  final String invoiceId;
  final String invoiceNo;
  final String status;
  final String totalDiscountType;
  final double totalDiscountValue;
  final String? promoCodeId;
  final String? promoCodeName;
  final double totalAmount;
  final String createdAt;
  final List<InvoicedOrderItem> items;

  InvoicedOrder({
    required this.id,
    required this.invoiceId,
    required this.invoiceNo,
    required this.status,
    required this.totalDiscountType,
    required this.totalDiscountValue,
    this.promoCodeId,
    this.promoCodeName,
    required this.totalAmount,
    required this.createdAt,
    required this.items,
  });

  factory InvoicedOrder.fromJson(Map<String, dynamic> json) {
    return InvoicedOrder(
      id: json['id']?.toString() ?? json['order_id']?.toString() ?? '',
      invoiceId: json['invoice_id']?.toString() ?? json['invoiceId']?.toString() ?? '',
      invoiceNo: json['invoiceNo']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      totalDiscountType: json['totalDiscountType']?.toString() ?? '',
      totalDiscountValue:
          double.tryParse(json['totalDiscountValue']?.toString() ?? '0') ?? 0,
      promoCodeId: json['promoCodeId']?.toString(),
      promoCodeName: json['promoCodeName']?.toString(),
      totalAmount: double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0,
      createdAt: json['createdAt']?.toString() ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) =>
                  InvoicedOrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class InvoicedOrderItem {
  final String id;
  final String itemType;
  final String productId;
  final String productName;
  final String departmentId;
  final String departmentName;
  final double qty;
  final double unitPrice;
  final String discountType;
  final double discountValue;
  final double lineTotal;

  InvoicedOrderItem({
    required this.id,
    required this.itemType,
    required this.productId,
    required this.productName,
    required this.departmentId,
    required this.departmentName,
    required this.qty,
    required this.unitPrice,
    required this.discountType,
    required this.discountValue,
    required this.lineTotal,
  });

  factory InvoicedOrderItem.fromJson(Map<String, dynamic> json) {
    return InvoicedOrderItem(
      id: json['id']?.toString() ?? '',
      itemType: json['itemType']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      productName: json['productName']?.toString() ?? '',
      departmentId: json['departmentId']?.toString() ?? '',
      departmentName: json['departmentName']?.toString() ?? '',
      qty: double.tryParse(json['qty']?.toString() ?? '0') ?? 0,
      unitPrice: double.tryParse(json['unitPrice']?.toString() ?? '0') ?? 0,
      discountType: json['discountType']?.toString() ?? '',
      discountValue:
          double.tryParse(json['discountValue']?.toString() ?? '0') ?? 0,
      lineTotal: double.tryParse(json['lineTotal']?.toString() ?? '0') ?? 0,
    );
  }
}
