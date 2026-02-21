class WalletBalanceResponse {
  final bool success;
  final double balance;
  final String currency;
  final String? walletId;
  final String? status;
  final String message;

  WalletBalanceResponse({
    required this.success,
    required this.balance,
    required this.currency,
    this.walletId,
    this.status,
    this.message = '',
  });

  factory WalletBalanceResponse.fromJson(Map<String, dynamic> json) {
    bool isSuccess = false;
    if (json['success'] is bool) {
      isSuccess = json['success'];
    } else if (json['success'] is String) {
      isSuccess = json['success'].toString().toLowerCase() == 'true';
    }

    return WalletBalanceResponse(
      success: isSuccess,
      balance: double.tryParse(json['balance']?.toString() ?? '0') ?? 0.0,
      currency: json['currency'] ?? 'SAR',
      walletId: json['walletId']?.toString(),
      status: json['status'],
      message: json['message'] ?? '',
    );
  }
}
