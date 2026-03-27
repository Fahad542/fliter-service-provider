class SubmitSalesReturnRequest {
  final String invoiceId;
  final String reason;
  final String? proofUrl;
  final List<SalesReturnItem> items;

  SubmitSalesReturnRequest({
    required this.invoiceId,
    required this.reason,
    this.proofUrl,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'invoiceId': invoiceId,
      'reason': reason,
      if (proofUrl != null) 'proofUrl': proofUrl,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

class SalesReturnItem {
  final String salesOrderItemId;
  final double qty;

  SalesReturnItem({
    required this.salesOrderItemId,
    required this.qty,
  });

  Map<String, dynamic> toJson() {
    return {
      'salesOrderItemId': salesOrderItemId,
      'qty': qty,
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
