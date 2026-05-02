class PromoCodeResponse {
  final bool success;
  final bool valid;
  final String message;
  final PromoData? promoCode;

  PromoCodeResponse({
    required this.success,
    required this.valid,
    required this.message,
    this.promoCode,
  });

  factory PromoCodeResponse.fromJson(Map<String, dynamic> json) {
    return PromoCodeResponse(
      success: json['success'] ?? false,
      valid: json['valid'] ?? false,
      message: json['message'] ?? '',
      promoCode: json['promoCode'] != null ? PromoData.fromJson(json['promoCode']) : null,
    );
  }
}

class PromoData {
  final String? id;
  final double discount;
  final bool isPercent;
  final String code;
  final String? applicableStore;
  final String? applicableProducts;
  final String? validityPeriod;
  final String? description;
  final String? discountLabel;

  PromoData({
    this.id,
    required this.discount,
    required this.isPercent,
    required this.code,
    this.applicableStore,
    this.applicableProducts,
    this.validityPeriod,
    this.description,
    this.discountLabel,
  });

  factory PromoData.fromJson(Map<String, dynamic> json) {
    bool isPercentValue = false;
    if (json['discountType'] != null) {
      isPercentValue = json['discountType'].toString().toLowerCase() == 'percent';
    } else {
      isPercentValue = json['isPercent'] ?? false;
    }

    String? validity;
    if (json['validTo'] != null) {
      validity = 'Until ${json['validTo']}';
    } else {
      validity = json['period'];
    }

    return PromoData(
      id: json['id']?.toString() ?? json['promoCodeId']?.toString(),
      discount: double.tryParse(json['discountValue']?.toString() ?? json['discount']?.toString() ?? '0') ?? 0.0,
      isPercent: isPercentValue,
      code: json['code'] ?? '',
      applicableStore: json['store'] ?? 'All Branches',
      applicableProducts: json['products'] ?? 'All Products',
      validityPeriod: validity,
      description: json['description'],
      discountLabel: json['discountLabel'],
    );
  }
}

class PromoCodeListResponse {
  final bool success;
  final List<PromoData>? promoCodes;

  PromoCodeListResponse({required this.success, this.promoCodes});

  factory PromoCodeListResponse.fromJson(Map<String, dynamic> json) {
    return PromoCodeListResponse(
      success: json['success'] ?? false,
      promoCodes: json['promoCodes'] != null
          ? (json['promoCodes'] as List).map((i) => PromoData.fromJson(i)).toList()
          : null,
    );
  }
}
