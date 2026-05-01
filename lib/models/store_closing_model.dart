class ReconciliationBucket {
  final double system;
  final double physical;
  final double difference;

  ReconciliationBucket({
    required this.system,
    required this.physical,
    required this.difference,
  });

  factory ReconciliationBucket.fromJson(Map<String, dynamic> json) {
    return ReconciliationBucket(
      system: (json['system'] ?? 0).toDouble(),
      physical: (json['physical'] ?? 0).toDouble(),
      difference: (json['difference'] ?? 0).toDouble(),
    );
  }
}

class StoreClosingReport {
  final String id;
  final DateTime timestamp;
  final String branch;
  final String cashierName;

  // System Totals
  final double systemSales;
  final double systemCash;
  final double systemBank;
  final double systemCorporate;
  final double systemTamara;
  final double systemTabby;
  final double systemOthers;

  // Physical Counts
  final double physicalCash;
  final double physicalBank;
  final double physicalCorporate;
  final double physicalTamara;
  final double physicalTabby;

  // API-provided differences (system - physical)
  final double? apiCashDiff;
  final double? apiBankDiff;
  final double? apiCorporateDiff;
  final double? apiTamaraDiff;
  final double? apiTabbyDiff;
  final double? apiTotalDifference;

  StoreClosingReport({
    required this.id,
    required this.timestamp,
    required this.branch,
    required this.cashierName,
    required this.systemSales,
    required this.systemCash,
    required this.systemBank,
    required this.systemCorporate,
    required this.systemTamara,
    required this.systemTabby,
    this.systemOthers = 0,
    required this.physicalCash,
    required this.physicalBank,
    required this.physicalCorporate,
    required this.physicalTamara,
    required this.physicalTabby,
    this.apiCashDiff,
    this.apiBankDiff,
    this.apiCorporateDiff,
    this.apiTamaraDiff,
    this.apiTabbyDiff,
    this.apiTotalDifference,
  });

  double get cashDiff => apiCashDiff ?? (systemCash - physicalCash);
  double get bankDiff => apiBankDiff ?? (systemBank - physicalBank);
  double get corporateDiff => apiCorporateDiff ?? (systemCorporate - physicalCorporate);
  double get tamaraDiff => apiTamaraDiff ?? (systemTamara - physicalTamara);
  double get tabbyDiff => apiTabbyDiff ?? (systemTabby - physicalTabby);
  double get netDifference => apiTotalDifference ?? (cashDiff + bankDiff + corporateDiff + tamaraDiff + tabbyDiff);

  double get physicalTotal =>
      physicalCash + physicalBank + physicalCorporate + physicalTamara + physicalTabby;

  double get systemPaymentsTotalShown =>
      systemCash +
          systemBank +
          systemCorporate +
          systemTamara +
          systemTabby +
          systemOthers;

  factory StoreClosingReport.fromApiResponse({
    required String closingId,
    required String branch,
    required String cashierName,
    required Map<String, dynamic> json,
  }) {
    final rec = json['reconciliation'] as Map<String, dynamic>? ?? {};

    ReconciliationBucket bucket(String key) {
      final raw = rec[key];
      if (raw is Map<String, dynamic>) return ReconciliationBucket.fromJson(raw);
      return ReconciliationBucket(system: 0, physical: 0, difference: 0);
    }

    final cash = bucket('physicalCash');
    final bank = bucket('bankCardSlips');
    final corp = bucket('corporateInvoice');
    final tamara = bucket('tamaraCredits');
    final tabby = bucket('tabbyCredits');

    return StoreClosingReport(
      id: closingId,
      timestamp: DateTime.now(),
      branch: branch,
      cashierName: cashierName,
      systemSales: (json['systemTotalSales'] ?? 0).toDouble(),
      systemCash: cash.system,
      systemBank: bank.system,
      systemCorporate: corp.system,
      systemTamara: tamara.system,
      systemTabby: tabby.system,
      systemOthers: (json['othersAmount'] ?? 0).toDouble(),
      physicalCash: cash.physical,
      physicalBank: bank.physical,
      physicalCorporate: corp.physical,
      physicalTamara: tamara.physical,
      physicalTabby: tabby.physical,
      apiCashDiff: cash.difference,
      apiBankDiff: bank.difference,
      apiCorporateDiff: corp.difference,
      apiTamaraDiff: tamara.difference,
      apiTabbyDiff: tabby.difference,
      apiTotalDifference: (json['totalDifference'] ?? 0).toDouble(),
    );
  }
}

/// System totals fetched from GET store-closing summary before submitting
class StoreClosingSummary {
  final double systemCash;
  final double systemBank;
  final double systemCorporate;
  final double systemTamara;
  final double systemTabby;
  final double systemOthers;
  final double totalAmount;
  final int totalInvoices;
  final double? grossInvoiceTotal;
  final double? salesReturnsTotal;

  StoreClosingSummary({
    required this.systemCash,
    required this.systemBank,
    required this.systemCorporate,
    required this.systemTamara,
    required this.systemTabby,
    required this.systemOthers,
    required this.totalAmount,
    required this.totalInvoices,
    this.grossInvoiceTotal,
    this.salesReturnsTotal,
  });

  double get netPaymentsTotalShown =>
      systemCash +
          systemBank +
          systemCorporate +
          systemTamara +
          systemTabby +
          systemOthers;

  factory StoreClosingSummary.fromJson(Map<String, dynamic> json) {
    final totals = json['paymentCategoryTotals'] as Map<String, dynamic>? ?? {};
    double? optionalDouble(dynamic v) =>
        v == null ? null : (v is num ? v.toDouble() : double.tryParse('$v'));

    return StoreClosingSummary(
      systemCash: (totals['cash'] ?? json['cashAmount'] ?? 0).toDouble(),
      systemBank: (totals['bankCardSlips'] ?? json['bankAmount'] ?? 0).toDouble(),
      systemCorporate: (totals['corporateInvoice'] ?? json['corporateAmount'] ?? 0).toDouble(),
      systemTamara: (totals['tamaraCredits'] ?? 0).toDouble(),
      systemTabby: (totals['tabbyCredits'] ?? 0).toDouble(),
      systemOthers: (totals['others'] ?? json['othersAmount'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      totalInvoices: switch (json['totalInvoices']) {
        final int x => x,
        final num x => x.toInt(),
        _ => int.tryParse('${json['totalInvoices']}') ?? 0,
      },
      grossInvoiceTotal: optionalDouble(json['grossInvoiceTotal']),
      salesReturnsTotal: optionalDouble(json['salesReturnsTotal']),
    );
  }
}