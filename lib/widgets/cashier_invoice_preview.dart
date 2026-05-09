import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/create_invoice_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_formatters.dart';
import '../utils/plate_transliterator.dart';
import '../utils/invoice_maintenance_checklist.dart';
import '../utils/thermal_invoice_totals.dart';
import '../services/locker_translation_mixin.dart';
import '../services/LocalizedApiText.dart';
import 'thermal_invoice_pdf_ar_constants.dart';

String _dash(String? s) {
  final v = (s ?? '').trim();
  return v.isEmpty ? '—' : v;
}

List<String> _branchRibbonSegments(Invoice i) {
  final raw = _invoiceBranchDisplayRaw(i).trim();
  if (raw.isEmpty) return const [];
  final byBullet =
      raw.split('•').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  if (byBullet.length >= 2) return byBullet;
  return [raw];
}

/// Prefer rich branch line for splitting (Arabic/workshop combos).
String _invoiceBranchDisplayRaw(Invoice i) {
  final b = (i.branchName ?? '').trim();
  final w = (i.workshopName ?? '').trim();
  if (b.isNotEmpty &&
      w.isNotEmpty &&
      b.toLowerCase() != w.toLowerCase()) {
    return '$b • $w';
  }
  if (b.isNotEmpty) return b;
  if (w.isNotEmpty) return w;
  return '';
}

String _fmtQty(double q) =>
    q % 1 == 0 ? q.toInt().toString() : q.toStringAsFixed(2);

String _arDigits(String text) =>
    AppTranslationService.localizeDigitsForLanguage(text, 'ar');

String _fmtQtyAr(double q) => _arDigits(_fmtQty(q));

String _sar(double v) => 'SAR ${v.toStringAsFixed(2)}';
String _sarAr(double v) => '${_arDigits(v.toStringAsFixed(2))} ر.س';

String _sarStringAr(String sarText) {
  final n = sarText.replaceAll(RegExp(r'\bSAR\b', caseSensitive: false), '').trim();
  if (n.isEmpty) return sarText;
  return '${_arDigits(n)} ر.س';
}

String _invoicePreviewArabicMirrorText(String raw) {
  final v = raw.trim();
  if (v.isEmpty || v == '—' || v == '-') return '';
  final ar = AppTranslationService.localizeDigitsForLanguage(v, 'ar').trim();
  return ar == v ? '' : ar;
}

/// Prefer API [Invoice.maintenanceChecklistChecks]; else [fallback]; else all false.
/// Always returns six entries so the invoice always lists every checklist row.
List<bool> _displayMaintenanceChecks(
    Invoice invoice,
    List<bool>? fallback,
    ) {
  final m = invoice.maintenanceChecklistChecks;
  if (m != null && m.length == InvoiceMaintenanceChecklist.rows.length) {
    return List<bool>.from(m);
  }
  if (fallback != null &&
      fallback.length == InvoiceMaintenanceChecklist.rows.length) {
    return List<bool>.from(fallback);
  }
  return List<bool>.filled(InvoiceMaintenanceChecklist.rows.length, false);
}

const _kMaintenanceChecklistColumns = 2;

List<Widget> _maintenanceChecklistBlock(List<bool> checks) {
  Widget checkItem(int idx) {
    final row = InvoiceMaintenanceChecklist.rows[idx];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.en,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  row.ar,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 9.5,
                    color: Colors.grey.shade700,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 2),
            child: Text(
              checks[idx] ? '☑' : '☐',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.grey.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  final tableRows = <TableRow>[];
  const n = 3;
  for (var r = 0; r < n; r++) {
    final leftIdx = r;
    final rightIdx = r + 3;
    tableRows.add(
      TableRow(
        children: [
          TableCell(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFCCCCCC), width: 0.75),
              ),
              child: checkItem(leftIdx),
            ),
          ),
          TableCell(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFCCCCCC), width: 0.75),
              ),
              child: checkItem(rightIdx),
            ),
          ),
        ],
      ),
    );
  }

  final checklistGrid = Table(
    columnWidths: {
      for (var c = 0; c < _kMaintenanceChecklistColumns; c++)
        c: const FlexColumnWidth(1),
    },
    defaultVerticalAlignment: TableCellVerticalAlignment.top,
    children: tableRows,
  );

  return [
    Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: Color(0xFFE2E8F0),
        border: Border.all(color: Color(0xFFCCCCCC), width: 0.75),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Check list',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: Colors.grey.shade900,
            ),
          ),
          Text(
            'قائمة الفحص',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: Colors.grey.shade900,
            ),
          ),
        ],
      ),
    ),
    Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 8),
      child: checklistGrid,
    ),
  ];
}

final _kGoodsInvoiceTableColumns = <int, TableColumnWidth>{
  0: const FlexColumnWidth(3.65), // Goods/Services
  1: const FlexColumnWidth(1.92), // Unit excl VAT
  2: const FlexColumnWidth(1.0), // Qty
  3: const FlexColumnWidth(2.02), // Gross before VAT
  4: const FlexColumnWidth(1.42), // Discount
  5: const FlexColumnWidth(2.02), // Total before VAT
  6: const FlexColumnWidth(1.42), // VAT
  7: const FlexColumnWidth(2.13), // Total with VAT
};

/// Must stay proportional to [`_kGoodsInvoiceTableColumns`] (FlexColumn × 100).
const _kGoodsHeaderFlexInts = <int>[365, 192, 100, 202, 142, 202, 142, 213];

const _kGoodsHeaderTexts = <String>[
  'Goods/Services\nالسلعة / الخدمة',
  'Unit Price (Excl. VAT)\nسعر الوحدة (بدون ضريبة)',
  'Qty\nالكمية',
  'Gross Amt Before VAT\nالإجمالي قبل الضريبة',
  'Discount\nالخصم',
  'Total Before VAT\nالمجموع قبل الضريبة',
  'VAT\nالضريبة',
  'Total With VAT\nالإجمالي مع الضريبة',
];

String _localizedInvoiceDateBanner(BuildContext context, String legalDateStr) =>
    AppTranslationService.localizeDigitsForLanguage(
      legalDateStr,
      Localizations.maybeLocaleOf(context)?.languageCode ?? 'en',
    );

/// ScrollView + [Align] children often get unbounded max width; never pass that to [Table].
double _invoicePreviewTrackWidth(
  BuildContext context,
  BoxConstraints constraints,
) {
  var w = constraints.maxWidth;
  if (w.isFinite && w > 16) return w;
  final mqPad = MediaQuery.sizeOf(context).width - 72;
  return mqPad.clamp(260.0, 920.0);
}

/// Customer / vehicle grid cell fill — solid white per product reference.
const Color _kCustomerMetaGridBg = Color(0xFFFFFFFF);

const Color _kCustomerMetaBorderColor = Color(0xFF1A1A1A);

/// Fixed row height so the block matches reference density (4 rows, compact).
const double _kCustomerVehicleCellHeight = 40.0;

/// Line items table: a bit more vertical room for EN/AR stacks.
const double _kGoodsBodyCellVPad = 9.0;

const double _kCustomerMetaBorderWidth = 1.0;

/// Goods table banner uses app primary yellow (solid).
const Color _goodsTableHeaderFill = AppColors.primaryLight;

const String _invoicePreviewNextChangeEn = 'Next Change';
const String _invoicePreviewNextChangeAr = 'غيار الزيت القادم';

Widget _invoiceMetaBlankSixColCell() {
  return SizedBox(
    height: _kCustomerVehicleCellHeight,
    width: double.infinity,
    child: DecoratedBox(
      decoration: BoxDecoration(color: _kCustomerMetaGridBg),
    ),
  );
}

/// Label: Arabic (left) — English (right), vertically centered, reference density.
Widget _invoiceMetaLabelPairCell(String en, String ar) {
  final arStyle = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w600,
    color: Colors.grey.shade800,
    height: 1.2,
  );
  final enStyle = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w600,
    color: Colors.grey.shade800,
    height: 1.2,
  );
  final dash = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w500,
    color: Colors.grey.shade600,
    height: 1.2,
  );
  return SizedBox(
    height: _kCustomerVehicleCellHeight,
    width: double.infinity,
    child: Container(
      color: _kCustomerMetaGridBg,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              ar,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.left,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: arStyle,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Text(' - ', style: dash),
          ),
          Expanded(
            child: Text(
              en,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: enStyle,
            ),
          ),
        ],
      ),
    ),
  );
}

/// Value cell: centered vertically, left text; optional second line (plate Arabic only in ref).
Widget _invoiceMetaValueOnlyCell(
  String primary, {
  String? secondaryAr,
}) {
  final main = TextStyle(
    fontSize: 11.25,
    fontWeight: FontWeight.w700,
    color: Colors.grey.shade900,
    height: 1.15,
  );
  final sub = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w600,
    color: Colors.grey.shade600,
    height: 1.1,
  );
  final pv = primary.trim();
  final explicitSec = secondaryAr?.trim();
  final autoSec = explicitSec == null || explicitSec.isEmpty
      ? _invoicePreviewArabicMirrorText(pv)
      : '';
  final sec = explicitSec != null && explicitSec.isNotEmpty ? explicitSec : autoSec;
  return SizedBox(
    height: _kCustomerVehicleCellHeight,
    width: double.infinity,
    child: Container(
      color: _kCustomerMetaGridBg,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      alignment: Alignment.centerLeft,
      child: sec.isEmpty
          ? Text(
              pv.isEmpty ? '—' : pv,
              textAlign: TextAlign.left,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: main,
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  pv.isEmpty ? '—' : pv,
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: main,
                ),
                const SizedBox(height: 2),
                Text(
                  sec,
                  textAlign: TextAlign.left,
                  textDirection: TextDirection.rtl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: sub,
                ),
              ],
            ),
    ),
  );
}

bool _invoicePreviewHasArabic(String s) =>
    RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]').hasMatch(s);

bool _invoicePreviewNeedsDynamicArabic(String raw) {
  final v = raw.trim();
  if (v.isEmpty || v == '—' || v == '-') return false;
  if (_invoicePreviewHasArabic(v)) return false;
  // Do not send pure numbers / money / phone-style values to dynamic translation.
  if (!RegExp(r'[A-Za-z]').hasMatch(v)) return false;
  return true;
}

/// English/API value on top + Arabic line underneath for dynamic API values.
/// Uses [LocalizedApiText] for API/database strings so the same dynamic
/// translation path is used as the rest of POS. The Arabic line is forced
/// through an Arabic [Localizations] scope because this invoice is bilingual
/// even when the app locale changes.
Widget _invoiceMetaDynamicValueCell(String primary) {
  final raw = primary.trim();
  if (!_invoicePreviewNeedsDynamicArabic(raw)) {
    return _invoiceMetaValueOnlyCell(raw.isEmpty ? '—' : raw);
  }

  final main = TextStyle(
    fontSize: 11.25,
    fontWeight: FontWeight.w700,
    color: Colors.grey.shade900,
    height: 1.15,
  );
  final sub = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w600,
    color: Colors.grey.shade600,
    height: 1.1,
  );

  return SizedBox(
    height: _kCustomerVehicleCellHeight,
    width: double.infinity,
    child: Container(
      color: _kCustomerMetaGridBg,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      alignment: Alignment.centerLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            raw,
            textAlign: TextAlign.left,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: main,
          ),
          const SizedBox(height: 2),
          Builder(
            builder: (context) => Localizations.override(
              context: context,
              locale: const Locale('ar'),
              child: LocalizedApiText(
                raw,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.left,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: sub,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _invoicePreviewDynamicArabicLine(
  String raw, {
  TextStyle? style,
  int maxLines = 1,
}) {
  final clean = raw.trim();
  if (!_invoicePreviewNeedsDynamicArabic(clean)) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.only(top: 2),
    child: Builder(
      builder: (context) => Localizations.override(
        context: context,
        locale: const Locale('ar'),
        child: LocalizedApiText(
          clean,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.left,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: style,
        ),
      ),
    ),
  );
}


TableRow _invoiceTotalsTripleRow(
  String labelEn,
  String labelAr,
  String sarAmount, {
    bool emphasized = false,
}) {
  final labelEnStyle = TextStyle(
    fontSize: emphasized ? 14.8 : 12.8,
    fontWeight: emphasized ? FontWeight.w900 : FontWeight.w700,
    color:
        emphasized ? AppColors.secondaryLight : Colors.grey.shade900,
    height: 1.22,
  );
  final labelArStyle = TextStyle(
    fontSize: (emphasized ? 14.8 : 12.8) * 0.84,
    fontWeight: emphasized ? FontWeight.w800 : FontWeight.w600,
    color:
        emphasized ? AppColors.secondaryLight : Colors.grey.shade700,
    height: 1.18,
  );
  final sarStyle = TextStyle(
    fontSize: emphasized ? 15 : 13,
    fontWeight: emphasized ? FontWeight.w900 : FontWeight.w700,
    color:
        emphasized ? AppColors.secondaryLight : Colors.grey.shade900,
  );
  Widget cellPadding(Widget child) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
        child: child,
      ),
    );
  }

  return TableRow(
    children: [
      cellPadding(
        Align(
          alignment: Alignment.centerLeft,
          child: Text(labelEn, style: labelEnStyle, textAlign: TextAlign.left),
        ),
      ),
      cellPadding(
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            labelAr,
            style: labelArStyle,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),
        ),
      ),
      cellPadding(
        Align(
          alignment: Alignment.centerRight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(sarAmount, style: sarStyle),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  _sarStringAr(sarAmount),
                  style: sarStyle.copyWith(
                    fontSize: (emphasized ? 15 : 13) * 0.78,
                    fontWeight: FontWeight.w600,
                    color: emphasized
                        ? AppColors.secondaryLight.withValues(alpha: 0.92)
                        : Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

/// Simplified UAE-style tax invoice preview for the cashier **dialog** (screen),
/// aligned with product reference: branded header + QR + detailed goods breakdown.
/// ESC/POS / printer output remains separate (`Print`).
class CashierInvoicePreview extends StatelessWidget {
  final Invoice invoice;
  final String paymentMethodText;
  /// When create-invoice API omits checklist, use ticks from [PosOrder.maintenanceChecks].
  final List<bool>? maintenanceChecksFallback;

  const CashierInvoicePreview({
    super.key,
    required this.invoice,
    required this.paymentMethodText,
    this.maintenanceChecksFallback,
  });

  @override
  Widget build(BuildContext context) {
    final t = computeThermalInvoiceTotals(invoice);
    final lineRows = computeThermalInvoiceLineRows(invoice);
    final qrData = thermalInvoiceQrPayload(invoice, t.totalInvoiceAmount);
    final displayChecks = _displayMaintenanceChecks(
      invoice,
      maintenanceChecksFallback,
    );

    final branchRibbonSegments = _branchRibbonSegments(invoice);

    final dateStr = formatInvoiceLegalDate(invoice.invoiceDate);
    final timeStr = formatInvoiceIssuedAtClock(invoice.issuedAt);
    final white70 = Colors.white.withValues(alpha: 0.70);

    final localizedTimeStr = timeStr == null
        ? '—'
        : AppTranslationService.localizeDigitsForLanguage(
            timeStr,
            Localizations.maybeLocaleOf(context)?.languageCode ?? 'en',
          );

    return Material(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
            decoration: BoxDecoration(
              color: AppColors.secondaryLight,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.black.withValues(alpha: 0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Transform.translate(
                              offset: const Offset(-2, 0),
                              child: Image.asset(
                                kThermalInvoiceLogoAsset,
                                height: 34,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.high,
                                errorBuilder: (context, error, stackTrace) =>
                                    const SizedBox(height: 34),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'فلتر',
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 22,
                                height: 1.05,
                                color: AppColors.primaryLight,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'CAR SERVICE',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15.5,
                                height: 1.1,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 5,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Simplified TAX Invoice',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'فاتورة ضريبية مبسطة',
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  height: 1.05,
                                  color: white70,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Directionality(
                                textDirection: TextDirection.rtl,
                                child: Text(
                                  'رقم الفاتورة : ${_arDigits(invoice.invoiceNo)}',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: white70,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Directionality(
                                textDirection: TextDirection.rtl,
                                child: Text(
                                  'الرقم الضريبي للعميل : ${_arDigits(_dash(invoice.customerTaxId))}',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: white70,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 92,
                    gapless: true,
                    backgroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            color: AppColors.primaryLight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (branchRibbonSegments.isEmpty)
                        Text(
                          '—',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: Colors.black.withValues(alpha: 0.82),
                          ),
                        )
                      else
                        ...[
                          for (
                              var i = 0;
                              i < branchRibbonSegments.length;
                              i++) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  i == 0
                                      ? Icons.person_outline_rounded
                                      : Icons.location_on_rounded,
                                  size: 18,
                                  color: Colors.black.withValues(alpha: 0.88),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        branchRibbonSegments[i],
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12.5,
                                          height: 1.35,
                                          color:
                                              Colors.black.withValues(alpha: 0.88),
                                        ),
                                      ),
                                      _invoicePreviewDynamicArabicLine(
                                        branchRibbonSegments[i],
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11.2,
                                          height: 1.25,
                                          color:
                                              Colors.black.withValues(alpha: 0.74),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (i != branchRibbonSegments.length - 1)
                              const SizedBox(height: 5),
                          ],
                        ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Date: ${_localizedInvoiceDateBanner(context, dateStr)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 0.25,
                          color: Colors.black.withValues(alpha: 0.88),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'التاريخ: ${_arDigits(dateStr)}',
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 11.5,
                          height: 1.15,
                          color: Colors.black.withValues(alpha: 0.72),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final rw = _invoicePreviewTrackWidth(context, constraints);
              return SizedBox(
                width: rw,
                child:
                    _buildCustomerVehicleDetailsTable(localizedTimeStr),
              );
            },
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final w = _invoicePreviewTrackWidth(context, constraints);
              return _goodsSection(lineRows, w);
            },
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final tw = _invoicePreviewTrackWidth(context, constraints);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: tw, child: _totalsBanner()),
                  SizedBox(
                    width: tw,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Table(
                        border: TableBorder.all(
                          color: _kCustomerMetaBorderColor,
                          width: 0.75,
                        ),
                        columnWidths: const {
                          0: FlexColumnWidth(2.05),
                          1: FlexColumnWidth(2.05),
                          2: FlexColumnWidth(1.25),
                        },
                        children: [
                          _invoiceTotalsTripleRow(
                            ThermalInvoicePdfLabels.totalExclVatEn,
                            ThermalInvoicePdfLabels.totalExclVatAr,
                            _sar(t.grossAmountExclVat),
                          ),
                          _invoiceTotalsTripleRow(
                            ThermalInvoicePdfLabels.itemDiscountEn,
                            ThermalInvoicePdfLabels.itemDiscountAr,
                            _sar(thermalR2(t.itemDiscountsTotal)),
                          ),
                          _invoiceTotalsTripleRow(
                            ThermalInvoicePdfLabels.taxableEn,
                            ThermalInvoicePdfLabels.taxableAr,
                            _sar(t.totalTaxableAmount),
                          ),
                          _invoiceTotalsTripleRow(
                            ThermalInvoicePdfLabels.totalVatEn,
                            ThermalInvoicePdfLabels.totalVatAr,
                            _sar(t.vatAmount),
                          ),
                          _invoiceTotalsTripleRow(
                            ThermalInvoicePdfLabels.totalDueEn,
                            ThermalInvoicePdfLabels.totalDueAr,
                            _sar(t.totalInvoiceAmount),
                            emphasized: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          ..._maintenanceChecklistBlock(displayChecks),
          const SizedBox(height: 14),
          Center(
            child: Text(
              'Thank you — شكراً لزيارتكم',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Bilingual 6-column × 4-row customer / vehicle block (ribbon → items table).
  Table _buildCustomerVehicleDetailsTable(String localizedTimeStr) {
    TableCell tc(Widget w) => TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: w,
        );

    final rawPlate = invoice.plateNo.trim();
    final plateLettersFirst =
        rawPlate.isEmpty ? null : formatVehiclePlateLettersFirst(rawPlate);
    final plateArLocalized = plateLettersFirst == null
        ? null
        : PlateTransliterator.localize(
            plateLettersFirst,
            'ar',
          );

    final nextKm = invoice.nextOilChangeKm;
    final nextKmStr = nextKm != null && nextKm > 0 ? '$nextKm' : '—';

    final odo = invoice.odometerReading;
    final mileageStr = (odo != null && odo > 0) ? '$odo' : '—';

    final phoneDisplay =
        formatInvoiceMobileForDisplay(invoice.customerMobile);

    return Table(
      border: TableBorder.all(
        color: _kCustomerMetaBorderColor,
        width: _kCustomerMetaBorderWidth,
      ),
      columnWidths: const {
        0: FlexColumnWidth(1.0),
        1: FlexColumnWidth(1.0),
        2: FlexColumnWidth(1.0),
        3: FlexColumnWidth(1.0),
        4: FlexColumnWidth(1.0),
        5: FlexColumnWidth(1.0),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          children: [
            tc(_invoiceMetaLabelPairCell(
              ThermalInvoicePdfLabels.custNameEn,
              ThermalInvoicePdfLabels.custNameAr,
            )),
            tc(_invoiceMetaDynamicValueCell(_dash(invoice.customerName))),
            tc(_invoiceMetaBlankSixColCell()),
            tc(_invoiceMetaBlankSixColCell()),
            tc(_invoiceMetaLabelPairCell(
              ThermalInvoicePdfLabels.custTimeEn,
              ThermalInvoicePdfLabels.custTimeAr,
            )),
            tc(_invoiceMetaValueOnlyCell(
              localizedTimeStr,
            )),
          ],
        ),
        TableRow(
          children: [
            tc(_invoiceMetaLabelPairCell(
              ThermalInvoicePdfLabels.custPhoneEn,
              ThermalInvoicePdfLabels.custPhoneAr,
            )),
            tc(_invoiceMetaValueOnlyCell(phoneDisplay)),
            tc(_invoiceMetaLabelPairCell(
              ThermalInvoicePdfLabels.custModelEn,
              ThermalInvoicePdfLabels.custModelAr,
            )),
            tc(_invoiceMetaDynamicValueCell(_dash(invoice.vehicleModel))),
            tc(_invoiceMetaLabelPairCell(
              ThermalInvoicePdfLabels.mileageEn,
              ThermalInvoicePdfLabels.mileageAr,
            )),
            tc(_invoiceMetaValueOnlyCell(
              mileageStr,
            )),
          ],
        ),
        TableRow(
          children: [
            tc(_invoiceMetaLabelPairCell(
              ThermalInvoicePdfLabels.custPlateEn,
              ThermalInvoicePdfLabels.custPlateAr,
            )),
            tc(_invoiceMetaValueOnlyCell(
              plateLettersFirst ?? '—',
              secondaryAr: plateArLocalized,
            )),
            tc(_invoiceMetaLabelPairCell(
              ThermalInvoicePdfLabels.vinEn,
              ThermalInvoicePdfLabels.vinAr,
            )),
            tc(_invoiceMetaValueOnlyCell(_dash(invoice.vehicleVin))),
            tc(_invoiceMetaLabelPairCell(
              _invoicePreviewNextChangeEn,
              _invoicePreviewNextChangeAr,
            )),
            tc(_invoiceMetaValueOnlyCell(
              nextKmStr,
            )),
          ],
        ),
        TableRow(
          children: [
            tc(_invoiceMetaLabelPairCell(
              ThermalInvoicePdfLabels.custMakeEn,
              ThermalInvoicePdfLabels.custMakeAr,
            )),
            tc(_invoiceMetaDynamicValueCell(_dash(invoice.vehicleMake))),
            tc(_invoiceMetaLabelPairCell(
              ThermalInvoicePdfLabels.custYearEn,
              ThermalInvoicePdfLabels.custYearAr,
            )),
            tc(_invoiceMetaValueOnlyCell(_dash(invoice.vehicleYear))),
            tc(_invoiceMetaBlankSixColCell()),
            tc(_invoiceMetaBlankSixColCell()),
          ],
        ),
      ],
    );
  }

  Widget _goodsSection(List<ThermalInvoiceLineRow> rows, double availWidth) {
    final safeW = (!availWidth.isFinite || availWidth <= 8)
        ? 360.0
        : availWidth;
    const borderColor = _kCustomerMetaBorderColor;

    Widget goodsHeaderBanner(double bannerW, Color bc) {
      final hdr = BorderSide(color: bc, width: 0.75);
      final fz = bannerW >= 620 ? 9.35 : 8.85;
      final labelStyle = TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: fz,
        height: 1.1,
        color: Colors.black.withValues(alpha: 0.87),
      );
      final arHdrStyle = labelStyle.copyWith(
        height: 1.12,
      );
      // EN line + slight gap + AR line; shallow row height.
      const hdrRowH = 58.0;
      const hdrEnArGap = 8.0;

      Widget cell(int idx) {
        final parts = _kGoodsHeaderTexts[idx].split('\n');
        final en = parts.first;
        final ar = parts.length > 1 ? parts[1] : '';
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              en,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: labelStyle,
            ),
            const SizedBox(height: hdrEnArGap),
            Text(
              ar,
              maxLines: 1,
              textDirection: TextDirection.rtl,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: arHdrStyle,
            ),
          ],
        );
      }

      return SizedBox(
        width: bannerW,
        height: hdrRowH,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _goodsTableHeaderFill,
            border: Border(left: hdr, top: hdr, right: hdr, bottom: hdr),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < _kGoodsHeaderFlexInts.length; i++) ...[
                if (i > 0)
                  SizedBox(
                    width: 1,
                    child: DecoratedBox(decoration: BoxDecoration(color: bc)),
                  ),
                Expanded(
                  flex: _kGoodsHeaderFlexInts[i],
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      i == 0 ? 8.0 : 4.0,
                      0,
                      3,
                      0,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: double.infinity,
                        child: cell(i),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    /// Bilingual value cell: English/Latin value on top, Arabic/localized value below.
    TableCell bodyCellBilingualValue(
        String textEn,
        String textAr, {
          TextAlign ta = TextAlign.start,
          int maxLines = 2,
          double leadingPadding = 4,
        }) {
      return TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: ColoredBox(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              leadingPadding,
              _kGoodsBodyCellVPad,
              3,
              _kGoodsBodyCellVPad,
            ),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: Text(
                  textEn,
                  textAlign: ta,
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade900,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                textAr,
                textDirection: TextDirection.rtl,
                textAlign: ta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9.3,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
        ),
      );
    }

    /// Bilingual cell: English name on top, Arabic below (for product name column).
    /// If API does not send productNameArabic, translate the English product name
    /// for the Arabic line instead of leaving the cell English-only.
    TableCell bodyCellBilingual(
        String textEn,
        String? textAr, {
          double leadingPadding = 8,
        }) {
      final cleanEn = textEn.trim();
      final cleanAr = textAr?.trim() ?? '';
      final arStyle = TextStyle(
        fontSize: 9.5,
        fontWeight: FontWeight.w500,
        color: Colors.grey.shade600,
        height: 1.2,
      );

      Widget arabicProductLine() {
        if (cleanAr.isNotEmpty) {
          return Text(
            cleanAr,
            textDirection: TextDirection.rtl,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: arStyle,
          );
        }
        if (cleanEn.isEmpty || cleanEn == '—' || cleanEn == '-') {
          return Text('—', style: arStyle);
        }
        return Builder(
          builder: (context) => Localizations.override(
            context: context,
            locale: const Locale('ar'),
            child: LocalizedApiText(
              cleanEn,
              textDirection: TextDirection.rtl,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: arStyle,
            ),
          ),
        );
      }

      return TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: ColoredBox(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              leadingPadding,
              _kGoodsBodyCellVPad,
              3,
              _kGoodsBodyCellVPad,
            ),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                cleanEn.isEmpty ? '—' : cleanEn,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade900,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 5),
              arabicProductLine(),
            ],
          ),
        ),
        ),
      );
    }

    final table = Table(
      border: TableBorder(
        left: BorderSide(color: borderColor, width: 0.75),
        top: BorderSide.none,
        right: BorderSide(color: borderColor, width: 0.75),
        bottom: BorderSide(color: borderColor, width: 0.75),
        horizontalInside: BorderSide(color: borderColor, width: 0.75),
        verticalInside: BorderSide(color: borderColor, width: 0.75),
      ),
      columnWidths: _kGoodsInvoiceTableColumns,
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        for (final row in rows)
          TableRow(
            children: [
              bodyCellBilingual(row.productName, row.productNameArabic),
              bodyCellBilingualValue(_sar(row.unitPriceExclVat), _sarAr(row.unitPriceExclVat)),
              bodyCellBilingualValue(_fmtQty(row.qty), _fmtQtyAr(row.qty), maxLines: 1),
              bodyCellBilingualValue(_sar(row.grossBeforeVat), _sarAr(row.grossBeforeVat)),
              bodyCellBilingualValue(_sar(row.discount), _sarAr(row.discount)),
              bodyCellBilingualValue(_sar(row.totalBeforeVat), _sarAr(row.totalBeforeVat)),
              bodyCellBilingualValue(_sar(row.lineVat), _sarAr(row.lineVat)),
              bodyCellBilingualValue(_sar(row.totalWithVat), _sarAr(row.totalWithVat), maxLines: 1),
            ],
          ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        goodsHeaderBanner(safeW, borderColor),
        SizedBox(width: safeW, child: table),
        if (rows.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'No line items. / لا توجد عناصر.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
      ],
    );
  }

  Widget _totalsBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      color: AppColors.primaryLight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Total Amount',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 14,
              color: AppColors.secondaryLight,
              height: 1.1,
            ),
          ),
          Text(
            'إجمالي المبالغ',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              height: 1.1,
              color: AppColors.secondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}