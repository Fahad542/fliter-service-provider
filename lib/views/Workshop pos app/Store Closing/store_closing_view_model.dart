import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/store_closing_model.dart';
import '../../../../models/pos_order_model.dart';
import '../../../../utils/toast_service.dart';
import '../../../../data/repositories/pos_repository.dart';
import '../../../../services/session_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
class StoreClosingViewModel extends ChangeNotifier {
  final PosRepository posRepository = PosRepository();
  final SessionService sessionService = SessionService();

  final cashController = TextEditingController();
  final bankController = TextEditingController();
  final corporateController = TextEditingController();
  final tamaraController = TextEditingController();
  final tabbyController = TextEditingController();

  bool _isReconciled = false;
  bool get isReconciled => _isReconciled;

  StoreClosingReport? _report;
  StoreClosingReport? get report => _report;

  bool _isGeneratingReport = false;
  bool get isGeneratingReport => _isGeneratingReport;

  bool _isReconciling = false;
  bool get isReconciling => _isReconciling;

  double get physicalTotal {
    final cash = double.tryParse(cashController.text) ?? 0;
    final bank = double.tryParse(bankController.text) ?? 0;
    final corporate = double.tryParse(corporateController.text) ?? 0;
    final tamara = double.tryParse(tamaraController.text) ?? 0;
    final tabby = double.tryParse(tabbyController.text) ?? 0;
    return cash + bank + corporate + tamara + tabby;
  }

  void updatePhysicalCount() {
    notifyListeners();
  }

  Future<void> reconcile(List<PosOrder> orders, String branchName, String cashierName, BuildContext context) async {
    _isReconciling = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken();
      if (token == null) throw Exception('Token not found');

      final user = await sessionService.getUser();
      final workshopId = user?.workshopId ?? '';
      final todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final apiResponse = await posRepository.getStoreClosing(token, todayDate, workshopId);

      final sysReport = getStoreClosingSystemTotals(orders, branchName, cashierName);

      _report = StoreClosingReport(
        id: 'CLOSE-${DateTime.now().millisecondsSinceEpoch}',
        timestamp: DateTime.now(),
        branch: branchName,
        cashierName: cashierName,
        systemSales: apiResponse.totalAmount, // Using API data
        systemCash: apiResponse.cashAmount > 0 ? apiResponse.cashAmount : sysReport.systemCash,
        systemBank: apiResponse.bankAmount > 0 ? apiResponse.bankAmount : sysReport.systemBank,
        systemCorporate: apiResponse.corporateAmount > 0 ? apiResponse.corporateAmount : sysReport.systemCorporate,
        systemTamara: sysReport.systemTamara,
        systemTabby: sysReport.systemTabby,
        physicalCash: double.tryParse(cashController.text) ?? 0,
        physicalBank: double.tryParse(bankController.text) ?? 0,
        physicalCorporate: double.tryParse(corporateController.text) ?? 0,
        physicalTamara: double.tryParse(tamaraController.text) ?? 0,
        physicalTabby: double.tryParse(tabbyController.text) ?? 0,
      );
      _isReconciled = true;
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, 'Failed to fetch reconciliation data: $e');
      }
    } finally {
      _isReconciling = false;
      notifyListeners();
    }
  }

  Future<void> buildReport(BuildContext context) async {
    if (_report == null) return;
    
    _isGeneratingReport = true;
    notifyListeners();
    
    try {
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context ctx) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Store Closing Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.Text('Branch: ${_report!.branch}'),
                pw.Text('Cashier: ${_report!.cashierName}'),
                pw.Text('Date: ${DateFormat('dd MMM, yyyy hh:mm a').format(_report!.timestamp)}'),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(child: pw.Text('Category', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.SizedBox(width: 80, child: pw.Text('System', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.SizedBox(width: 80, child: pw.Text('Physical', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.SizedBox(width: 80, child: pw.Text('Difference', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Divider(),
                pw.SizedBox(height: 10),
                _buildPdfRow('Cash Account', _report!.systemCash, _report!.physicalCash, _report!.cashDiff),
                _buildPdfRow('Bank / Cards', _report!.systemBank, _report!.physicalBank, _report!.bankDiff),
                _buildPdfRow('Corporate', _report!.systemCorporate, _report!.physicalCorporate, _report!.corporateDiff),
                _buildPdfRow('Tamara', _report!.systemTamara, _report!.physicalTamara, _report!.tamaraDiff),
                _buildPdfRow('Tabby', _report!.systemTabby, _report!.physicalTabby, _report!.tabbyDiff),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Net Difference to Posted:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                    pw.Text('SAR ${_report!.netDifference.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Store_Closing_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
      );
      
      if (context.mounted) {
        ToastService.showSuccess(context, 'Reconciliation Report PDF Generated!');
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, 'Failed to generate PDF: $e');
      }
    } finally {
      _isGeneratingReport = false;
      notifyListeners();
    }
  }

  pw.Widget _buildPdfRow(String label, double system, double physical, double diff) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(child: pw.Text(label)),
          pw.SizedBox(width: 80, child: pw.Text(system.toStringAsFixed(2), textAlign: pw.TextAlign.right)),
          pw.SizedBox(width: 80, child: pw.Text(physical.toStringAsFixed(2), textAlign: pw.TextAlign.right)),
          pw.SizedBox(width: 80, child: pw.Text(diff.toStringAsFixed(2), textAlign: pw.TextAlign.right)),
        ],
      ),
    );
  }

  void reset() {
    _isReconciled = false;
    _report = null;
    cashController.clear();
    bankController.clear();
    corporateController.clear();
    tamaraController.clear();
    tabbyController.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    cashController.dispose();
    bankController.dispose();
    corporateController.dispose();
    tamaraController.dispose();
    tabbyController.dispose();
    super.dispose();
  }

  StoreClosingReport getStoreClosingSystemTotals(
    List<PosOrder> orders,
    String branchName,
    String cashierName,
  ) {
    double cash = 0, bank = 0, corporate = 0, tamara = 0, tabby = 0;
    
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
      systemSales: cash + bank + corporate + tamara + tabby,
      systemCash: cash,
      systemBank: bank,
      systemCorporate: corporate,
      systemTamara: tamara,
      systemTabby: tabby,
      physicalCash: 0,
      physicalBank: 0,
      physicalCorporate: 0,
      physicalTamara: 0,
      physicalTabby: 0,
    );
  }

  void submitStoreClosing(StoreClosingReport report) {
    // API logic for submitting store closing goes here
    notifyListeners();
  }
}
