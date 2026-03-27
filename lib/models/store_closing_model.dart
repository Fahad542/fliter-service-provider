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

  // Physical Counts
  final double physicalCash;
  final double physicalBank;
  final double physicalCorporate;
  final double physicalTamara;
  final double physicalTabby;

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
    required this.physicalCash,
    required this.physicalBank,
    required this.physicalCorporate,
    required this.physicalTamara,
    required this.physicalTabby,
  });

  double get cashDiff => physicalCash - systemCash;
  double get bankDiff => physicalBank - systemBank;
  double get corporateDiff => physicalCorporate - systemCorporate;
  double get tamaraDiff => physicalTamara - systemTamara;
  double get tabbyDiff => physicalTabby - systemTabby;
  double get netDifference => cashDiff + bankDiff + corporateDiff + tamaraDiff + tabbyDiff;
  
  double get physicalTotal => physicalCash + physicalBank + physicalCorporate + physicalTamara + physicalTabby;
}
