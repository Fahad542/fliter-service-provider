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
  final double discount;
  final bool isPercent;
  final String code;
  final String? applicableStore;
  final String? applicableProducts;
  final String? validityPeriod;

  PromoData({
    required this.discount,
    required this.isPercent,
    required this.code,
    this.applicableStore,
    this.applicableProducts,
    this.validityPeriod,
  });

  factory PromoData.fromJson(Map<String, dynamic> json) {
    return PromoData(
      discount: (json['discount'] ?? 0).toDouble(),
      isPercent: json['isPercent'] ?? false,
      code: json['code'] ?? '',
      applicableStore: json['store'] ?? 'All Branches', // Default value or null
      applicableProducts: json['products'] ?? 'All Products', // Default value or null
      validityPeriod: json['period'],
    );
  }
}
