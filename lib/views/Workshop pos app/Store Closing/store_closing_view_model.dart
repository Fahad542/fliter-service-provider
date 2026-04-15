import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/store_closing_model.dart';
import '../../../utils/toast_service.dart';
import '../../../data/repositories/pos_repository.dart';
import '../../../services/session_service.dart';
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
  final notesController = TextEditingController();

  bool _isReconciled = false;
  bool get isReconciled => _isReconciled;

  StoreClosingReport? _report;
  StoreClosingReport? get report => _report;

  StoreClosingSummary? _summary;
  StoreClosingSummary? get summary => _summary;

  String? _closingId;
  String? get closingId => _closingId;

  bool _isLoadingSummary = false;
  bool get isLoadingSummary => _isLoadingSummary;

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

  /// Fetch system totals from GET endpoint so user can see expected amounts.
  /// Uses raw JSON so `paymentCategoryTotals` (split payment buckets) are
  /// forwarded to [StoreClosingSummary.fromJson].
  Future<void> loadSummary() async {
    _isLoadingSummary = true;
    notifyListeners();
    try {
      final token = await sessionService.getToken();
      if (token == null) return;
      final user = await sessionService.getUser();
      final workshopId = user?.workshopId ?? '';
      final todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final raw = await posRepository.getStoreClosingRaw(token, todayDate, workshopId);
      _summary = StoreClosingSummary.fromJson(raw);
    } catch (_) {
      // summary is optional, silently ignore
    } finally {
      _isLoadingSummary = false;
      notifyListeners();
    }
  }

  Future<void> reconcile(String branchName, String cashierName, BuildContext context) async {
    _isReconciling = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken();
      if (token == null) throw Exception('Token not found');

      final body = <String, dynamic>{
        'physicalCash': double.tryParse(cashController.text) ?? 0,
        if (bankController.text.isNotEmpty)
          'physicalBank': double.tryParse(bankController.text) ?? 0,
        if (corporateController.text.isNotEmpty)
          'physicalCorporate': double.tryParse(corporateController.text) ?? 0,
        if (tamaraController.text.isNotEmpty)
          'physicalTamara': double.tryParse(tamaraController.text) ?? 0,
        if (tabbyController.text.isNotEmpty)
          'physicalTabby': double.tryParse(tabbyController.text) ?? 0,
        if (notesController.text.trim().isNotEmpty)
          'notes': notesController.text.trim(),
      };

      final response = await posRepository.submitCounterClosing(token, body);

      if (response['success'] == true) {
        _closingId = response['closingId']?.toString();
        _report = StoreClosingReport.fromApiResponse(
          closingId: _closingId ?? '',
          branch: branchName,
          cashierName: cashierName,
          json: response,
        );
        _isReconciled = true;
        if (context.mounted) {
          ToastService.showSuccess(context, 'Shift closed successfully!');
        }
      } else {
        throw Exception(response['message'] ?? 'Counter closing failed');
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, 'Failed to close shift: $e');
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
                pw.Text('Store Closing Report',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.Text('Branch: ${_report!.branch}'),
                pw.Text('Cashier: ${_report!.cashierName}'),
                pw.Text('Date: ${DateFormat('dd MMM, yyyy hh:mm a').format(_report!.timestamp)}'),
                if (_closingId != null) pw.Text('Closing ID: $_closingId'),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(child: pw.Text('Category',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.SizedBox(
                        width: 80,
                        child: pw.Text('System',
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.SizedBox(
                        width: 80,
                        child: pw.Text('Physical',
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.SizedBox(
                        width: 80,
                        child: pw.Text('Difference',
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
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
                    pw.Text('Total Difference:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                    pw.Text('SAR ${_report!.netDifference.toStringAsFixed(2)}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('System Total Sales:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                    pw.Text('SAR ${_report!.systemSales.toStringAsFixed(2)}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
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
    _closingId = null;
    cashController.clear();
    bankController.clear();
    corporateController.clear();
    tamaraController.clear();
    tabbyController.clear();
    notesController.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    cashController.dispose();
    bankController.dispose();
    corporateController.dispose();
    tamaraController.dispose();
    tabbyController.dispose();
    notesController.dispose();
    super.dispose();
  }
}
