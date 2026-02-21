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

  // Physical Counts
  final double physicalCash;
  final double physicalBank;
  final double physicalCorporate;

  StoreClosingReport({
    required this.id,
    required this.timestamp,
    required this.branch,
    required this.cashierName,
    required this.systemSales,
    required this.systemCash,
    required this.systemBank,
    required this.systemCorporate,
    required this.physicalCash,
    required this.physicalBank,
    required this.physicalCorporate,
  });

  double get cashDiff => physicalCash - systemCash;
  double get bankDiff => physicalBank - systemBank;
  double get corporateDiff => physicalCorporate - systemCorporate;
  double get netDifference => cashDiff + bankDiff + corporateDiff;
  
  double get physicalTotal => physicalCash + physicalBank + physicalCorporate;
}
