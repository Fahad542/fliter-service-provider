class SubmitSalesReturnRequest {
  final String invoiceId;
  final String orderId;
  final String customerId;
  final String? proofUrl;
  final List<SalesReturnItem> items;

  SubmitSalesReturnRequest({
    required this.invoiceId,
    required this.orderId,
    required this.customerId,
    this.proofUrl,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'invoiceId': invoiceId,
      'orderId': orderId,
      'customerId': customerId,
      if (proofUrl != null) 'proofUrl': proofUrl,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

class SalesReturnItem {
  final String salesOrderItemId;
  final double qty;
  final String reason;

  SalesReturnItem({
    required this.salesOrderItemId,
    required this.qty,
    required this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'salesOrderItemId': salesOrderItemId,
      'qty': qty,
      'reason': reason,
    };
  }
}

class SubmitSalesReturnResponse {
  final bool success;
  final String message;

  SubmitSalesReturnResponse({
    required this.success,
    required this.message,
  });

  factory SubmitSalesReturnResponse.fromJson(Map<String, dynamic> json) {
    return SubmitSalesReturnResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}
