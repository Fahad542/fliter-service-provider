import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/store_closing_model.dart';
import '../../../utils/toast_service.dart';
import '../../../data/repositories/pos_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/locker_translation_mixin.dart';
import '../../../services/session_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class StoreClosingViewModel extends ChangeNotifier with TranslatableMixin {
  final PosRepository posRepository = PosRepository();
  final SessionService sessionService = SessionService();

  final cashController = TextEditingController();
  final bankController = TextEditingController();
  final corporateController = TextEditingController();
  final tamaraController = TextEditingController();
  final tabbyController = TextEditingController();
  final othersController = TextEditingController();
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

  bool _isReconciling = false;
  bool get isReconciling => _isReconciling;

  double get physicalTotal {
    final cash = double.tryParse(cashController.text) ?? 0;
    final bank = double.tryParse(bankController.text) ?? 0;
    final corporate = double.tryParse(corporateController.text) ?? 0;
    final tamara = double.tryParse(tamaraController.text) ?? 0;
    final tabby = double.tryParse(tabbyController.text) ?? 0;
    final others = double.tryParse(othersController.text) ?? 0;
    return cash + bank + corporate + tamara + tabby + others;
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
      if (token == null) throw Exception(AppLocalizations.of(context)!.posSalesReturnTokenNotFound);

      final body = <String, dynamic>{
        'physicalCash': double.tryParse(cashController.text) ?? 0,
        'clientClosedAt': DateTime.now().toIso8601String(),
        if (bankController.text.isNotEmpty)
          'physicalBank': double.tryParse(bankController.text) ?? 0,
        if (corporateController.text.isNotEmpty)
          'physicalCorporate': double.tryParse(corporateController.text) ?? 0,
        if (tamaraController.text.isNotEmpty)
          'physicalTamara': double.tryParse(tamaraController.text) ?? 0,
        if (tabbyController.text.isNotEmpty)
          'physicalTabby': double.tryParse(tabbyController.text) ?? 0,
        if (othersController.text.isNotEmpty)
          'physicalOthers': double.tryParse(othersController.text) ?? 0,
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
          ToastService.showSuccess(context, AppLocalizations.of(context)!.posStoreClosingVmSuccess);
        }
      } else {
        throw Exception(response['message'] ?? AppLocalizations.of(context)!.posStoreClosingVmCounterFailed);
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, AppLocalizations.of(context)!.posStoreClosingVmFailed(e.toString()));
      }
    } finally {
      _isReconciling = false;
      notifyListeners();
    }
  }

  String get closingReportPdfFileName =>
      'Store_Closing_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';

  /// Same PDF bytes used by the store‑closing preview dialog and [Printing.layoutPdf].
  Future<Uint8List> buildClosingReportPdfBytes() async {
    if (_report == null) {
      throw StateError('No closing report to export.');
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Store Closing Report',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Branch: ${_report!.branch}'),
              pw.Text('Cashier: ${_report!.cashierName}'),
              pw.Text(
                  'Date: ${DateFormat('dd MMM, yyyy hh:mm a').format(_report!.timestamp)}'),
              if (_closingId != null) pw.Text('Closing ID: $_closingId'),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                      child: pw.Text('Category',
                          style:
                              pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.SizedBox(
                      width: 80,
                      child: pw.Text('System',
                          textAlign: pw.TextAlign.right,
                          style:
                              pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.SizedBox(
                      width: 80,
                      child: pw.Text('Physical',
                          textAlign: pw.TextAlign.right,
                          style:
                              pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.SizedBox(
                      width: 80,
                      child: pw.Text('Difference',
                          textAlign: pw.TextAlign.right,
                          style:
                              pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.SizedBox(height: 10),
              _buildPdfRow('Cash Account', _report!.systemCashGross,
                  _report!.physicalCash, _report!.cashDiff),
              _buildPdfRow('Bank / Cards', _report!.systemBankGross,
                  _report!.physicalBank, _report!.bankDiff),
              _buildPdfRow('Corporate', _report!.systemCorporateGross,
                  _report!.physicalCorporate, _report!.corporateDiff),
              _buildPdfRow('Tamara', _report!.systemTamaraGross,
                  _report!.physicalTamara, _report!.tamaraDiff),
              _buildPdfRow('Tabby', _report!.systemTabbyGross,
                  _report!.physicalTabby, _report!.tabbyDiff),
              _buildPdfRow('Others (Employees)', _report!.systemOthersGross,
                  _report!.physicalOthers, _report!.othersDiff),
              pw.SizedBox(height: 12),
              pw.Divider(),
              pw.SizedBox(height: 10),
              _buildPdfTotalsFooter(_report!),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildPdfTotalsFooter(StoreClosingReport r) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _buildPdfRow(
          'Total',
          r.systemBucketsSumGross,
          r.physicalTotal,
          r.diffBucketsSum,
        ),
        if (r.salesReturnsTotal > 0.001) ...[
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(
                  'Less: Total sales return',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              pw.SizedBox(
                width: 80,
                child: pw.Text(
                  '− SAR ${r.salesReturnsTotal.toStringAsFixed(2)}',
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              pw.SizedBox(width: 80, child: pw.Text('')),
              pw.SizedBox(width: 80, child: pw.Text('')),
            ],
          ),
        ],
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Text(
                'Grand Total',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            pw.SizedBox(
              width: 240,
              child: pw.Text(
                'SAR ${r.systemSales.toStringAsFixed(2)}',
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ],
    );
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
    _summary = null;
    cashController.clear();
    bankController.clear();
    corporateController.clear();
    tamaraController.clear();
    tabbyController.clear();
    othersController.clear();
    notesController.clear();
    notifyListeners();
  }

  void bindSettingsViewModel(Listenable settingsViewModel) {
    bindLocaleRetranslation(settingsViewModel, retranslate);
  }

  Future<void> retranslate() async {
    notifyListeners();
  }

  @override
  void dispose() {
    unbindLocaleRetranslation();
    cashController.dispose();
    bankController.dispose();
    corporateController.dispose();
    tamaraController.dispose();
    tabbyController.dispose();
    othersController.dispose();
    notesController.dispose();
    super.dispose();
  }

}
