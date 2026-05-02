class CashierCorporateAccountsResponse {
  final bool success;
  final List<CashierCorporateAccount> accounts;

  CashierCorporateAccountsResponse({
    required this.success,
    required this.accounts,
  });

  factory CashierCorporateAccountsResponse.fromJson(Map<String, dynamic> json) {
    return CashierCorporateAccountsResponse(
      success: json['success'] ?? false,
      accounts: (json['accounts'] as List?)
              ?.map((a) => CashierCorporateAccount.fromJson(a))
              .toList() ??
          [],
    );
  }
}

class CashierCorporateAccount {
  final String id;
  final String companyName;
  final double creditLimit;
  final double dueBalance;
  final String? address;
  final String? billingAddress;
  final String contactPerson;
  final String? vatNumber;
  final String? taxId;
  final String? preferredPaymentMethod;
  final CashierCorporateAccountCustomer? customer;

  CashierCorporateAccount({
    required this.id,
    required this.companyName,
    required this.creditLimit,
    required this.dueBalance,
    this.address,
    this.billingAddress,
    required this.contactPerson,
    this.vatNumber,
    this.taxId,
    this.preferredPaymentMethod,
    this.customer,
  });

  String? get effectiveVatNumber {
    final candidates = [vatNumber, taxId, customer?.taxId, customer?.vatNumber];
    return candidates.firstWhere(
      (v) => v != null && v.isNotEmpty,
      orElse: () => null,
    );
  }

  factory CashierCorporateAccount.fromJson(Map<String, dynamic> json) {
    return CashierCorporateAccount(
      id: json['id']?.toString() ?? '',
      companyName: json['companyName'] ?? 'Unknown',
      creditLimit: (json['creditLimit'] as num?)?.toDouble() ?? 0.0,
      dueBalance: (json['dueBalance'] as num?)?.toDouble() ?? 0.0,
      address: json['address']?.toString(),
      billingAddress: json['billingAddress']?.toString(),
      contactPerson: json['contactPerson']?.toString() ?? 'N/A',
      vatNumber: json['vatNumber']?.toString(),
      taxId: json['taxId']?.toString(),
      preferredPaymentMethod:
          _pickFirstNonEmptyString(json, const [
            'preferredPaymentMethod',
            'defaultPaymentMethod',
            'paymentMethod',
            'billingType',
            'paymentPreference',
          ]),
      customer: json['customer'] != null
          ? CashierCorporateAccountCustomer.fromJson(json['customer'])
          : null,
    );
  }
}

String? _pickFirstNonEmptyString(
  Map<String, dynamic> json,
  List<String> keys,
) {
  for (final key in keys) {
    final value = json[key]?.toString().trim();
    if (value != null && value.isNotEmpty) return value;
  }
  return null;
}

class CashierCorporateAccountCustomer {
  final String name;
  final String? mobile;
  final String? taxId;
  final String? vatNumber;

  CashierCorporateAccountCustomer({
    required this.name,
    this.mobile,
    this.taxId,
    this.vatNumber,
  });

  factory CashierCorporateAccountCustomer.fromJson(Map<String, dynamic> json) {
    return CashierCorporateAccountCustomer(
      name: json['name'] ?? 'Unknown',
      mobile: json['mobile']?.toString(),
      taxId: json['taxId']?.toString(),
      vatNumber: json['vatNumber']?.toString(),
    );
  }
}
