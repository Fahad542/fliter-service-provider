import 'package:flutter/material.dart';
import '../../../../models/store_closing_model.dart';
import '../../../../models/pos_order_model.dart';
import '../../../../utils/toast_service.dart';

class StoreClosingViewModel extends ChangeNotifier {
  final cashController = TextEditingController();
  final bankController = TextEditingController();
  final corporateController = TextEditingController();

  bool _isReconciled = false;
  bool get isReconciled => _isReconciled;

  StoreClosingReport? _report;
  StoreClosingReport? get report => _report;

  bool _isGeneratingReport = false;
  bool get isGeneratingReport => _isGeneratingReport;

  double get physicalTotal {
    final cash = double.tryParse(cashController.text) ?? 0;
    final bank = double.tryParse(bankController.text) ?? 0;
    final corporate = double.tryParse(corporateController.text) ?? 0;
    return cash + bank + corporate;
  }

  void updatePhysicalCount() {
    notifyListeners();
  }

  void reconcile(List<PosOrder> orders, String branchName, String cashierName) {
    final sysReport = getStoreClosingSystemTotals(orders, branchName, cashierName);

    _report = StoreClosingReport(
      id: sysReport.id,
      timestamp: DateTime.now(),
      branch: sysReport.branch,
      cashierName: sysReport.cashierName,
      systemSales: sysReport.systemSales,
      systemCash: sysReport.systemCash,
      systemBank: sysReport.systemBank,
      systemCorporate: sysReport.systemCorporate,
      physicalCash: double.tryParse(cashController.text) ?? 0,
      physicalBank: double.tryParse(bankController.text) ?? 0,
      physicalCorporate: double.tryParse(corporateController.text) ?? 0,
    );
    _isReconciled = true;
    notifyListeners();
  }

  Future<void> buildReport(BuildContext context) async {
    _isGeneratingReport = true;
    notifyListeners();
    
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));
    
    _isGeneratingReport = false;
    notifyListeners();
    
    if (context.mounted) {
      ToastService.showSuccess(context, 'Reconciliation Report PDF Generated!');
    }
  }

  void reset() {
    _isReconciled = false;
    _report = null;
    cashController.clear();
    bankController.clear();
    corporateController.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    cashController.dispose();
    bankController.dispose();
    corporateController.dispose();
    super.dispose();
  }

  StoreClosingReport getStoreClosingSystemTotals(
    List<PosOrder> orders,
    String branchName,
    String cashierName,
  ) {
    double cash = 0, bank = 0, corporate = 0;
    
    for (var order in orders) {
      if (order.status.toLowerCase() == 'invoiced' || order.status.toLowerCase() == 'completed') {
        // Mock distribution
        if (order.id.endsWith('1')) {
          cash += order.totalAmount;
        } else if (order.id.endsWith('2')) {
          bank += order.totalAmount;
        } else {
          corporate += order.totalAmount;
        }
      }
    }

    return StoreClosingReport(
      id: 'CLOSE-${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      branch: branchName,
      cashierName: cashierName,
      systemSales: cash + bank + corporate,
      systemCash: cash,
      systemBank: bank,
      systemCorporate: corporate,
      physicalCash: 0,
      physicalBank: 0,
      physicalCorporate: 0,
    );
  }

  void submitStoreClosing(StoreClosingReport report) {
    // API logic for submitting store closing goes here
    notifyListeners();
  }
}
