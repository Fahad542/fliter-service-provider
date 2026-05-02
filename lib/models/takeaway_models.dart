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
  /// VAT-inclusive sale price.
  final double salePrice;
  /// VAT-exclusive sale price from backend; falls back to salePrice / 1.15.
  final double salePriceBeforeVat;
  final double purchasePrice;
  final bool allowDecimalQty;
  final bool isActive;
  final double qtyOnHand;
  final TakeawayRef department;
  final TakeawayRef? category;

  TakeawayProduct({
    required this.id,
    required this.name,
    this.unit,
    required this.salePrice,
    double? salePriceBeforeVat,
    required this.purchasePrice,
    required this.allowDecimalQty,
    required this.isActive,
    required this.qtyOnHand,
    required this.department,
    this.category,
  }) : salePriceBeforeVat = salePriceBeforeVat ?? ((salePrice / 1.15 * 100).roundToDouble() / 100);

  factory TakeawayProduct.fromJson(Map<String, dynamic> json) {
    final exclVat = json['salePriceBeforeVat'] != null
        ? _takeawayDouble(json['salePriceBeforeVat'])
        : null;
    return TakeawayProduct(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      unit: json['unit']?.toString(),
      salePrice: _takeawayDouble(json['salePrice']),
      salePriceBeforeVat: exclVat,
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
  final double? beforeDiscountPrice;
  final double? afterDiscountPrice;

  const TakeawayCheckoutLinePayload({
    required this.productId,
    required this.qty,
    this.discountType,
    this.discountValue = 0,
    this.unitPrice,
    this.beforeDiscountPrice,
    this.afterDiscountPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'qty': qty,
      'discountType': (discountType ?? '').toString(),
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
  final double? amountBeforeDiscount;
  final double? amountAfterDiscount;
  final double? amountAfterPromo;
  final double? totalAmount;
  final String? paymentMethod;
  final List<Map<String, dynamic>>? payments;
  final String? invoiceDate;
  final double discountAmount;
  /// Mirrors PATCH billing / cashier order vehicle fields when supported by API.
  final String? vehicleNumber;
  final String? make;
  final String? model;
  final String? vin;
  final int? year;
  final int? odometerReading;
  final String? color;

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
    this.amountBeforeDiscount,
    this.amountAfterDiscount,
    this.amountAfterPromo,
    this.totalAmount,
    this.paymentMethod,
    this.payments,
    this.invoiceDate,
    this.discountAmount = 0,
    this.vehicleNumber,
    this.make,
    this.model,
    this.vin,
    this.year,
    this.odometerReading,
    this.color,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'customerName': customerName,
      // Keep optional string keys present to avoid undefined.trim() on backend.
      'customerMobile': (customerMobile ?? '').toString(),
      'customerTaxId': (customerTaxId ?? '').toString(),
      'items': items.map((e) => e.toJson()).toList(),
      'totalDiscountType': (totalDiscountType ?? '').toString(),
      if (totalDiscountValue > 0) 'totalDiscountValue': totalDiscountValue,
      'promoCode': (promoCode ?? '').toString(),
      'promoCodeId': (promoCodeId ?? '').toString(),
      if (amountBeforeDiscount != null)
        'amountBeforeDiscount': amountBeforeDiscount,
      if (amountAfterDiscount != null) 'amountAfterDiscount': amountAfterDiscount,
      if (amountAfterPromo != null) 'amountAfterPromo': amountAfterPromo,
      if (vatPercent != null) 'VAT': vatPercent,
      if (totalAmount != null) ...{
        // Keep both key variants for backend compatibility.
        'TotalAmount': totalAmount,
        'totalAmount': totalAmount,
      },
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (payments != null) 'payments': payments,
      if (invoiceDate != null && invoiceDate!.isNotEmpty)
        'invoiceDate': invoiceDate,
      if (discountAmount > 0) 'discountAmount': discountAmount,
    };
    final plate = (vehicleNumber ?? '').trim();
    if (plate.isNotEmpty) {
      map['vehicleNumber'] = plate;
      final mk = (make ?? '').trim();
      final md = (model ?? '').trim();
      final vn = (vin ?? '').trim();
      final cl = (color ?? '').trim();
      if (mk.isNotEmpty) map['make'] = mk;
      if (md.isNotEmpty) map['model'] = md;
      if (vn.isNotEmpty) map['vin'] = vn;
      if (cl.isNotEmpty) map['color'] = cl;
      if (year != null) map['year'] = year;
      if (odometerReading != null && odometerReading! > 0) {
        map['odometerReading'] = odometerReading;
      }
    }
    return map;
  }
}

class TakeawayCheckoutPricing {
  final double amountBeforeDiscount;
  final double amountAfterDiscount;
  final double amountAfterPromo;
  final double promoDiscountAmount;
  final double vatAmount;
  final double finalAmount;
  final double vatPercent;
  final String? totalDiscountType;
  final double totalDiscountValue;

  const TakeawayCheckoutPricing({
    this.amountBeforeDiscount = 0,
    this.amountAfterDiscount = 0,
    this.amountAfterPromo = 0,
    this.promoDiscountAmount = 0,
    this.vatAmount = 0,
    this.finalAmount = 0,
    this.vatPercent = 0,
    this.totalDiscountType,
    this.totalDiscountValue = 0,
  });

  factory TakeawayCheckoutPricing.fromJson(Map<String, dynamic> json) {
    return TakeawayCheckoutPricing(
      amountBeforeDiscount: _takeawayDouble(json['amountBeforeDiscount']),
      amountAfterDiscount: _takeawayDouble(json['amountAfterDiscount']),
      amountAfterPromo: _takeawayDouble(json['amountAfterPromo']),
      promoDiscountAmount: _takeawayDouble(json['promoDiscountAmount']),
      vatAmount: _takeawayDouble(json['vatAmount']),
      finalAmount: _takeawayDouble(json['finalAmount']),
      vatPercent: _takeawayDouble(json['vatPercent']),
      totalDiscountType: json['totalDiscountType']?.toString(),
      totalDiscountValue: _takeawayDouble(json['totalDiscountValue']),
    );
  }
}

class TakeawayCheckoutResponse {
  final bool success;
  final String message;
  final String? orderId;
  final Invoice? invoice;
  final TakeawayCheckoutPricing? pricing;

  const TakeawayCheckoutResponse({
    required this.success,
    required this.message,
    this.orderId,
    this.invoice,
    this.pricing,
  });

  factory TakeawayCheckoutResponse.fromJson(Map<String, dynamic> json) {
    return TakeawayCheckoutResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      orderId: json['orderId']?.toString(),
      invoice: json['invoice'] != null
          ? Invoice.fromJson(Map<String, dynamic>.from(json['invoice'] as Map))
          : null,
      pricing: json['pricing'] is Map
          ? TakeawayCheckoutPricing.fromJson(
              Map<String, dynamic>.from(json['pricing'] as Map),
            )
          : null,
    );
  }
}
