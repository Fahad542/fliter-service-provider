/// GET /cashier/inventory-sales?from=&to= — cashier product quantity sold per day.
class InventorySaleLine {
  const InventorySaleLine({
    required this.productName,
    required this.quantitySold,
    required this.soldOn,
    this.productId,
    this.sku,
  });

  final String productName;
  final String? productId;
  final String? sku;
  final DateTime soldOn;
  final num quantitySold;

  String quantityDisplay({int fractionDigits = 2}) {
    final v = quantitySold;
    if (v == v.roundToDouble()) return v.round().toString();
    return v.toDouble().toStringAsFixed(fractionDigits);
  }

  factory InventorySaleLine.fromJson(Map<String, dynamic> json) {
    final rawName = json['productName'] ??
        json['name'] ??
        json['product_name'] ??
        json['title'] ??
        '';
    final qty = _parseQty(
      json['quantitySold'] ??
          json['qty'] ??
          json['quantity'] ??
          json['soldQty'] ??
          json['sold_qty'],
    );
    final sold = _parseDate(
      json['soldDate'] ??
          json['saleDate'] ??
          json['date'] ??
          json['soldOn'] ??
          json['sold_on'],
    );

    return InventorySaleLine(
      productName: rawName.toString().trim().isEmpty
          ? 'Unknown'
          : rawName.toString().trim(),
      productId: json['productId']?.toString() ?? json['product_id']?.toString(),
      sku: json['sku']?.toString() ?? json['SKU']?.toString(),
      soldOn: sold ?? DateTime.now(),
      quantitySold: qty,
    );
  }

  static num _parseQty(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    return num.tryParse(v.toString()) ?? 0;
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return DateTime(v.year, v.month, v.day);
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    try {
      final d = DateTime.parse(s);
      return DateTime(d.year, d.month, d.day);
    } catch (_) {
      return null;
    }
  }
}

class InventorySalesResponse {
  const InventorySalesResponse({
    required this.lines,
    this.success = true,
    this.message,
  });

  final bool success;
  final String? message;
  final List<InventorySaleLine> lines;

  factory InventorySalesResponse.fromJson(Map<String, dynamic> json) {
    final success = json['success'] == true || json['success'] == null;
    final message = json['message']?.toString();

    dynamic raw = json['sales'] ??
        json['entries'] ??
        json['items'] ??
        json['data'] ??
        json['lines'];
    if (raw is! List) raw = <dynamic>[];

    final lines = <InventorySaleLine>[];
    for (final e in raw) {
      if (e is Map<String, dynamic>) {
        lines.add(InventorySaleLine.fromJson(e));
      } else if (e is Map) {
        lines.add(InventorySaleLine.fromJson(Map<String, dynamic>.from(e)));
      }
    }

    return InventorySalesResponse(
      success: success,
      message: message,
      lines: lines,
    );
  }
}
