import 'create_invoice_model.dart';

double _takeawayDouble(dynamic v) =>
    double.tryParse(v?.toString() ?? '0') ?? 0.0;

class TakeawayRef {
  final String id;
  final String name;

  const TakeawayRef({required this.id, required this.name});

  factory TakeawayRef.fromJson(dynamic json) {
    if (json is! Map) {
      return const TakeawayRef(id: '', name: '');
    }
    final m = Map<String, dynamic>.from(json);
    return TakeawayRef(
      id: m['id']?.toString() ?? '',
      name: m['name']?.toString() ?? '',
    );
  }
}

class TakeawayProduct {
  final String id;
  final String name;
  final String? unit;
  final double salePrice;
  final double purchasePrice;
  final bool allowDecimalQty;
  final bool isActive;
  final double qtyOnHand;
  final TakeawayRef department;
  final TakeawayRef? category;

  const TakeawayProduct({
    required this.id,
    required this.name,
    this.unit,
    required this.salePrice,
    required this.purchasePrice,
    required this.allowDecimalQty,
    required this.isActive,
    required this.qtyOnHand,
    required this.department,
    this.category,
  });

  factory TakeawayProduct.fromJson(Map<String, dynamic> json) {
    return TakeawayProduct(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      unit: json['unit']?.toString(),
      salePrice: _takeawayDouble(json['salePrice']),
      purchasePrice: _takeawayDouble(json['purchasePrice']),
      allowDecimalQty: json['allowDecimalQty'] == true,
      isActive: json['isActive'] != false,
      qtyOnHand: _takeawayDouble(json['qtyOnHand']),
      department: TakeawayRef.fromJson(json['department']),
      category: json['category'] == null
          ? null
          : TakeawayRef.fromJson(json['category']),
    );
  }
}

class TakeawayDepartment {
  final String id;
  final String name;

  const TakeawayDepartment({required this.id, required this.name});

  factory TakeawayDepartment.fromJson(Map<String, dynamic> json) {
    return TakeawayDepartment(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

class TakeawayCategoryGroup {
  final String id;
  final String name;
  final List<TakeawayProduct> products;

  const TakeawayCategoryGroup({
    required this.id,
    required this.name,
    required this.products,
  });

  factory TakeawayCategoryGroup.fromJson(Map<String, dynamic> json) {
    final raw = json['products'] as List? ?? [];
    return TakeawayCategoryGroup(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      products: raw
          .whereType<Map>()
          .map((e) => TakeawayProduct.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

/// Parsed body of GET /cashier/takeaway/products-catalog.
class TakeawayCatalogData {
  final String currency;
  final double vatPercentDefault;
  final List<TakeawayDepartment> departments;
  final List<TakeawayCategoryGroup> categories;
  final List<TakeawayProduct> uncategorizedProducts;

  const TakeawayCatalogData({
    required this.currency,
    required this.vatPercentDefault,
    required this.departments,
    required this.categories,
    required this.uncategorizedProducts,
  });

  factory TakeawayCatalogData.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> root = json;
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      root = data;
    }

    final mergedCategories = <TakeawayCategoryGroup>[];
    final mergedUncategorized = <TakeawayProduct>[];

    final deptList = root['departments'] as List? ?? [];
    final departments = deptList
        .whereType<Map>()
        .map((e) => TakeawayDepartment.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    // Backend often nests categories + uncategorizedProducts under each department.
    for (final raw in deptList.whereType<Map>()) {
      final m = Map<String, dynamic>.from(raw);
      final nestedCats = m['categories'] as List? ?? [];
      for (final c in nestedCats.whereType<Map>()) {
        mergedCategories.add(
          TakeawayCategoryGroup.fromJson(Map<String, dynamic>.from(c)),
        );
      }
      final nestedUnc = m['uncategorizedProducts'] as List? ?? [];
      for (final p in nestedUnc.whereType<Map>()) {
        mergedUncategorized.add(
          TakeawayProduct.fromJson(Map<String, dynamic>.from(p)),
        );
      }
    }

    // Also support flat root-level categories (older/alternate API shape).
    final topCats = root['categories'] as List? ?? [];
    for (final c in topCats.whereType<Map>()) {
      mergedCategories.add(
        TakeawayCategoryGroup.fromJson(Map<String, dynamic>.from(c)),
      );
    }
    final topUnc = root['uncategorizedProducts'] as List? ?? [];
    for (final p in topUnc.whereType<Map>()) {
      mergedUncategorized.add(
        TakeawayProduct.fromJson(Map<String, dynamic>.from(p)),
      );
    }

    return TakeawayCatalogData(
      currency: root['currency']?.toString() ?? 'SAR',
      vatPercentDefault: _takeawayDouble(root['vatPercentDefault']),
      departments: departments,
      categories: mergedCategories,
      uncategorizedProducts: mergedUncategorized,
    );
  }
}

class TakeawayCheckoutLinePayload {
  final String productId;
  final double qty;
  final String? discountType;
  final double discountValue;
  final double? unitPrice;

  const TakeawayCheckoutLinePayload({
    required this.productId,
    required this.qty,
    this.discountType,
    this.discountValue = 0,
    this.unitPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'qty': qty,
      if (discountType != null && discountType!.isNotEmpty)
        'discountType': discountType,
      if (discountValue > 0) 'discountValue': discountValue,
      if (unitPrice != null) 'unitPrice': unitPrice,
    };
  }
}

class TakeawayCheckoutRequest {
  final String customerName;
  final String? customerMobile;
  final String? customerTaxId;
  final List<TakeawayCheckoutLinePayload> items;
  final String? totalDiscountType;
  final double totalDiscountValue;
  final String? promoCode;
  final String? promoCodeId;
  final double? vatPercent;
  final String paymentMethod;
  final String? invoiceDate;
  final double discountAmount;

  const TakeawayCheckoutRequest({
    required this.customerName,
    this.customerMobile,
    this.customerTaxId,
    required this.items,
    this.totalDiscountType,
    this.totalDiscountValue = 0,
    this.promoCode,
    this.promoCodeId,
    this.vatPercent,
    required this.paymentMethod,
    this.invoiceDate,
    this.discountAmount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'customerName': customerName,
      if (customerMobile != null && customerMobile!.isNotEmpty)
        'customerMobile': customerMobile,
      if (customerTaxId != null && customerTaxId!.isNotEmpty)
        'customerTaxId': customerTaxId,
      'items': items.map((e) => e.toJson()).toList(),
      if (totalDiscountType != null && totalDiscountType!.isNotEmpty)
        'totalDiscountType': totalDiscountType,
      if (totalDiscountValue > 0) 'totalDiscountValue': totalDiscountValue,
      if (promoCode != null && promoCode!.isNotEmpty) 'promoCode': promoCode,
      if (promoCodeId != null && promoCodeId!.isNotEmpty)
        'promoCodeId': promoCodeId,
      if (vatPercent != null) 'VAT': vatPercent,
      'paymentMethod': paymentMethod,
      if (invoiceDate != null && invoiceDate!.isNotEmpty)
        'invoiceDate': invoiceDate,
      if (discountAmount > 0) 'discountAmount': discountAmount,
    };
  }
}

class TakeawayCheckoutResponse {
  final bool success;
  final String message;
  final String? orderId;
  final Invoice? invoice;

  const TakeawayCheckoutResponse({
    required this.success,
    required this.message,
    this.orderId,
    this.invoice,
  });

  factory TakeawayCheckoutResponse.fromJson(Map<String, dynamic> json) {
    return TakeawayCheckoutResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      orderId: json['orderId']?.toString(),
      invoice: json['invoice'] != null
          ? Invoice.fromJson(Map<String, dynamic>.from(json['invoice'] as Map))
          : null,
    );
  }
}
