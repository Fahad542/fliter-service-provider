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
  final String contactPerson;
  final CashierCorporateAccountCustomer? customer;

  CashierCorporateAccount({
    required this.id,
    required this.companyName,
    required this.creditLimit,
    required this.dueBalance,
    this.address,
    required this.contactPerson,
    this.customer,
  });

  factory CashierCorporateAccount.fromJson(Map<String, dynamic> json) {
    return CashierCorporateAccount(
      id: json['id']?.toString() ?? '',
      companyName: json['companyName'] ?? 'Unknown',
      creditLimit: (json['creditLimit'] as num?)?.toDouble() ?? 0.0,
      dueBalance: (json['dueBalance'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] as String?,
      contactPerson: json['contactPerson'] ?? 'N/A',
      customer: json['customer'] != null
          ? CashierCorporateAccountCustomer.fromJson(json['customer'])
          : null,
    );
  }
}

class CashierCorporateAccountCustomer {
  final String name;
  final String? mobile;

  CashierCorporateAccountCustomer({
    required this.name,
    this.mobile,
  });

  factory CashierCorporateAccountCustomer.fromJson(Map<String, dynamic> json) {
    return CashierCorporateAccountCustomer(
      name: json['name'] ?? 'Unknown',
      mobile: json['mobile'] as String?,
    );
  }
}
