import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/create_invoice_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_formatters.dart';
import '../utils/plate_transliterator.dart';
import '../utils/invoice_maintenance_checklist.dart';
import '../utils/thermal_invoice_totals.dart';
import '../services/locker_translation_mixin.dart';
import 'thermal_invoice_pdf_ar_constants.dart';

String _workshopHeaderSingleLine(String? workshopName) {
  final s = (workshopName ?? '').trim();
  if (s.isEmpty) return 'FILTER';
  return s.toUpperCase();
}

String _dash(String? s) {
  final v = (s ?? '').trim();
  return v.isEmpty ? '—' : v;
}

String _employeesSummary(Invoice invoice) {
  final names = <String>{};
  for (final d in invoice.departments) {
    for (final c in d.commissions) {
      final n = c.technicianName.trim();
      if (n.isNotEmpty) names.add(n);
    }
  }
  if (names.isEmpty) return '—';
  return names.join(', ');
}

String _branchRibbonText(Invoice i) {
  final b = (i.branchName ?? '').trim();
  if (b.isEmpty) return '—';
  return b.toUpperCase();
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

String _paymentMethodArabic(String raw) {
  final p = raw.trim().toLowerCase();
  if (p.isEmpty || p == '—' || p == '-') return '—';
  if (p.contains('split')) return 'دفع مقسم';
  if (p.contains('cash')) return 'نقداً';
  if (p.contains('card') || p.contains('mada') || p.contains('visa') ||
      p.contains('master')) return 'بطاقة';
  if (p.contains('bank') || p.contains('transfer')) return 'تحويل بنكي';
  if (p.contains('employee')) return 'الموظفين';
  if (p.contains('monthly')) return 'فوترة شهرية';
  if (p.contains('corporate') || p.contains('company')) return 'شركة';
  if (p.contains('wallet')) return 'محفظة';
  if (p.contains('tabby')) return 'تابي';
  if (p.contains('tamara')) return 'تمارا';
  return raw;
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

const _kMaintenanceChecklistColumns = 3;

List<Widget> _maintenanceChecklistBlock(List<bool> checks) {
  Widget item(int i) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${checks[i] ? '☑' : '☐'} ${InvoiceMaintenanceChecklist.rows[i].en}',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade900,
              height: 1.2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 14, top: 2),
            child: Text(
              InvoiceMaintenanceChecklist.rows[i].ar,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 9.5,
                color: Colors.grey.shade700,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  final n = InvoiceMaintenanceChecklist.rows.length;
  final columnWidths = <int, TableColumnWidth>{
    for (var c = 0; c < _kMaintenanceChecklistColumns; c++)
      c: const FlexColumnWidth(1),
  };
  final tableRows = <TableRow>[];
  for (var start = 0; start < n; start += _kMaintenanceChecklistColumns) {
    final cells = <Widget>[];
    for (var c = 0; c < _kMaintenanceChecklistColumns; c++) {
      final i = start + c;
      if (i < n) {
        cells.add(TableCell(child: item(i)));
      } else {
        cells.add(const TableCell(child: SizedBox.shrink()));
      }
    }
    tableRows.add(TableRow(children: cells));
  }

  final checklistGrid = Table(
    columnWidths: columnWidths,
    defaultVerticalAlignment: TableCellVerticalAlignment.top,
    children: tableRows,
  );

  return [
    Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      color: AppColors.primaryLight,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'Maintenance checklist',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 12,
              color: AppColors.onPrimaryLight,
            ),
          ),
          Text(
            'قائمة الصيانة',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 10,
              color: AppColors.onPrimaryLight,
            ),
          ),
        ],
      ),
    ),
    Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
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
  'Goods/Services\nالبضائع/الخدمات',
  'Unit Price (Excl. VAT)\nسعر الوحدة (بدون ضريبة)',
  'Qty\nالكمية',
  'Gross Amt Before VAT\nالإجمالي قبل الضريبة',
  'Discount\nالخصم',
  'Total Before VAT\nالمجموع قبل الضريبة',
  'VAT\nالضريبة',
  'Total With VAT\nالإجمالي مع الضريبة',
];

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

    final dateStr = formatInvoiceLegalDate(invoice.invoiceDate);
    final timeStr = formatInvoiceIssuedAtClock(invoice.issuedAt);
    final white70 = Colors.white.withValues(alpha: 0.85);

    const border = Color(0xFF1A1A1A);
    const tableBorder = TableBorder(
      top: BorderSide(color: border, width: 0.75),
      left: BorderSide(color: border, width: 0.75),
      right: BorderSide(color: border, width: 0.75),
      bottom: BorderSide(color: border, width: 0.75),
      horizontalInside: BorderSide(color: border, width: 0.75),
      verticalInside: BorderSide(color: border, width: 0.75),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Transform.translate(
                        offset: const Offset(-6, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Transform.translate(
                              offset: const Offset(-3, 0),
                              child: Image.asset(
                                kThermalInvoiceLogoAsset,
                                height: 40,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.high,
                                errorBuilder: (context, error, stackTrace) =>
                                const SizedBox(height: 40),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      _workshopHeaderSingleLine(
                                          invoice.workshopName),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 22,
                                        height: 1.05,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Simplified TAX Invoice / فاتورة ضريبية مبسطة',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: white70,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    'Invoice No / رقم الفاتورة: ${invoice.invoiceNo}',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: white70,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Date / التاريخ: $dateStr',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: white70,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    timeStr != null
                                        ? 'Time / الوقت: $timeStr'
                                        : 'Time / الوقت: —',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Branch / الفرع',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 9.5,
                    color: AppColors.onPrimaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _branchRibbonText(invoice),
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 0.35,
                    color: AppColors.onPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              var cw = constraints.maxWidth;
              if (!cw.isFinite || cw <= 0) {
                cw = MediaQuery.sizeOf(context).width;
              }
              // Six flex columns — wider minimum; horizontal scroll when narrow.
              const minInfoTableWidth = 600.0;
              final tableW = cw < minInfoTableWidth ? minInfoTableWidth : cw;
              final rawPlate = invoice.plateNo.trim();
              final plateLettersFirst =
                  rawPlate.isEmpty ? null : formatVehiclePlateLettersFirst(rawPlate);
              final infoTable = Table(
                border: tableBorder,
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                  3: FlexColumnWidth(1),
                  4: FlexColumnWidth(1),
                  5: FlexColumnWidth(1),
                },
                children: [
                  TableRow(
                    children: [
                      _infoCell(
                        label: 'Customer / العميل',
                        value: _dash(invoice.customerName),
                      ),
                      _infoCell(
                        label: 'Phone / الهاتف',
                        value: _dash(invoice.customerMobile ?? ''),
                      ),
                      _infoCell(
                        label: 'Tax ID / الرقم الضريبي',
                        value: _dash(invoice.customerTaxId),
                      ),
                      _infoCell(
                        label: 'Model / الموديل',
                        value: _dash(invoice.vehicleModel),
                      ),
                      _infoCell(
                        label: 'Plate / اللوحة',
                        value: plateLettersFirst ?? '—',
                        valueArabic: plateLettersFirst == null
                            ? null
                            : PlateTransliterator.localize(
                                plateLettersFirst,
                                'ar',
                              ),
                      ),
                      _infoCell(
                        label: 'Year / السنة',
                        value: _dash(invoice.vehicleYear),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      _infoCell(
                        label: 'VIN / رقم الهيكل',
                        value: _dash(invoice.vehicleVin),
                      ),
                      _infoCell(
                        label: 'Mileage / العداد',
                        value:
                        invoice.odometerReading != null &&
                            invoice.odometerReading! > 0
                            ? '${invoice.odometerReading}'
                            : '—',
                        valueArabic: invoice.odometerReading != null &&
                            invoice.odometerReading! > 0
                            ? _arDigits('${invoice.odometerReading}')
                            : '—',
                      ),
                      _infoCell(
                        label: 'Make / الشركة المصنّعة',
                        value: _dash(invoice.vehicleMake),
                      ),
                      _infoCell(
                        label: 'Payment Method / طريقة الدفع',
                        value: paymentMethodText.trim().isEmpty
                            ? '—'
                            : paymentMethodText.trim(),
                        valueArabic: _paymentMethodArabic(paymentMethodText),
                      ),
                      _infoCell(
                        label: 'Employees / الموظفون',
                        value: _employeesSummary(invoice),
                      ),
                      _infoCell(
                        label: 'Cashier / الكاشير',
                        value: _dash(invoice.cashierName),
                      ),
                    ],
                  ),
                ],
              );
              if (tableW <= cw) {
                return SizedBox(width: double.infinity, child: infoTable);
              }
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(width: tableW, child: infoTable),
              );
            },
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              var w = constraints.maxWidth;
              if (!w.isFinite || w <= 0) {
                w = MediaQuery.sizeOf(context).width;
              }
              return _goodsSection(lineRows, w);
            },
          ),
          const SizedBox(height: 12),
          _totalsBanner(),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
            child: Column(
              children: [
                _amountRowBilingual(
                  'Gross Amount (Excluding VAT)',
                  'الإجمالي (بدون ضريبة)',
                  _sar(t.grossAmountExclVat),
                ),
                _amountRowBilingual(
                  ThermalInvoicePdfLabels.itemDiscountEn,
                  ThermalInvoicePdfLabels.itemDiscountAr,
                  _sar(thermalR2(t.itemDiscountsTotal)),
                ),
                _amountRowBilingual(
                  ThermalInvoicePdfLabels.invoiceDiscountEn,
                  ThermalInvoicePdfLabels.invoiceDiscountAr,
                  _sar(thermalR2(t.invoiceDiscount)),
                ),
                _amountRowBilingual(
                  ThermalInvoicePdfLabels.promoDiscountEn,
                  ThermalInvoicePdfLabels.promoDiscountAr,
                  _sar(thermalR2(t.promoDiscount)),
                ),
                _amountRowBilingual(
                  'Total Taxable Amount',
                  'إجمالي المبلغ الخاضع للضريبة',
                  _sar(t.totalTaxableAmount),
                ),
                _amountRowBilingual(
                  'VAT 15%',
                  'ضريبة القيمة المضافة ١٥٪',
                  _sar(t.vatAmount),
                ),
                const Divider(height: 18),
                _amountRowBilingual(
                  'Total Invoice Amount',
                  'إجمالي مبلغ الفاتورة',
                  _sar(t.totalInvoiceAmount),
                  emphasized: true,
                ),
              ],
            ),
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

  Widget _infoCell({
    required String label,
    required String value,
    String? valueArabic,
  }) {
    final cleanValue = value.trim();
    final staticAr = valueArabic?.trim();
    final valueStyle = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w800,
      color: Colors.grey.shade900,
      height: 1.25,
    );
    final arValueStyle = TextStyle(
      fontSize: 8.8,
      fontWeight: FontWeight.w600,
      color: Colors.grey.shade600,
      height: 1.2,
    );

    Widget arabicValue() {
      if (cleanValue.isEmpty || cleanValue == '—' || cleanValue == '-') {
        return Text('—', style: arValueStyle);
      }
      if (staticAr != null && staticAr.isNotEmpty) {
        return Text(
          staticAr,
          textDirection: TextDirection.rtl,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: arValueStyle,
        );
      }
      return FutureBuilder<String>(
        future: AppTranslationService.localizedDynamicValueForLanguage(
          cleanValue,
          'ar',
        ),
        initialData: _arDigits(cleanValue),
        builder: (context, snapshot) {
          final ar = (snapshot.data ?? _arDigits(cleanValue)).trim();
          return Text(
            ar.isEmpty ? '—' : ar,
            textDirection: TextDirection.rtl,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: arValueStyle,
          );
        },
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            cleanValue.isEmpty ? '—' : cleanValue,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: valueStyle,
          ),
          const SizedBox(height: 1.5),
          arabicValue(),
        ],
      ),
    );
  }

  Widget _goodsSection(List<ThermalInvoiceLineRow> rows, double availWidth) {
    final safeW = (!availWidth.isFinite || availWidth <= 8)
        ? 360.0
        : availWidth;
    const borderColor = Color(0xFF1A1A1A);

    Widget goodsHeaderBanner(double bannerW, Color bc) {
      final hdr = BorderSide(color: bc, width: 0.75);
      final fz = bannerW >= 620 ? 9.35 : 8.85;
      final labelStyle = TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: fz,
        height: 1.1,
        color: AppColors.onPrimaryLight,
      );
      // Single-line labels; ellipsis if column is narrow.
      // Fixed height stretches column dividers; keep compact vs data rows.
      const hdrRowH = 60.0;
      return SizedBox(
        width: bannerW,
        height: hdrRowH,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
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
                        child: Text(
                          _kGoodsHeaderTexts[i],
                          maxLines: 2,
                          softWrap: true,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          style: labelStyle,
                        ),
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

    TableCell bodyCell(
        String text, {
          TextAlign ta = TextAlign.start,
          int maxLines = 2,
          double leadingPadding = 4,
        }) {
      return TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Padding(
          padding: EdgeInsets.fromLTRB(leadingPadding, 5, 3, 5),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              text,
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
        child: Padding(
          padding: EdgeInsets.fromLTRB(leadingPadding, 5, 3, 5),
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
        return FutureBuilder<String>(
          future: AppTranslationService.localizedDynamicValueForLanguage(
            cleanEn,
            'ar',
          ),
          initialData: _arDigits(cleanEn),
          builder: (context, snapshot) {
            final ar = (snapshot.data ?? _arDigits(cleanEn)).trim();
            return Text(
              ar.isEmpty ? '—' : ar,
              textDirection: TextDirection.rtl,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: arStyle,
            );
          },
        );
      }

      return TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Padding(
          padding: EdgeInsets.fromLTRB(leadingPadding, 5, 3, 5),
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
              arabicProductLine(),
            ],
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
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      color: AppColors.primaryLight,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'Total Amount',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13,
              color: AppColors.onPrimaryLight,
            ),
          ),
          Text(
            'إجمالي المبلغ',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 11,
              color: AppColors.onPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountRow(String label, String amount, {bool emphasized = false}) {
    final baseStyle = TextStyle(
      fontSize: emphasized ? 15 : 13,
      fontWeight: emphasized ? FontWeight.w900 : FontWeight.w600,
      color: emphasized ? AppColors.secondaryLight : Colors.grey.shade800,
    );
    final amtStyle = TextStyle(
      fontSize: emphasized ? 15.5 : 13,
      fontWeight: emphasized ? FontWeight.w900 : FontWeight.w700,
      color: emphasized ? AppColors.secondaryLight : Colors.grey.shade900,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: baseStyle)),
          Text(amount, style: amtStyle),
        ],
      ),
    );
  }

  /// English + Arabic label (RTL) with amount; matches thermal PDF discount labels.
  Widget _amountRowBilingual(
      String labelEn,
      String labelAr,
      String amount, {
        bool emphasized = false,
      }) {
    final baseStyle = TextStyle(
      fontSize: emphasized ? 15 : 13,
      fontWeight: emphasized ? FontWeight.w900 : FontWeight.w600,
      color: emphasized ? AppColors.secondaryLight : Colors.grey.shade800,
    );
    final arStyle = baseStyle.copyWith(
      fontSize: (emphasized ? 15.0 : 13.0) * 0.82,
      fontWeight: FontWeight.w500,
      color: Colors.grey.shade700,
      height: 1.2,
    );
    final amtStyle = TextStyle(
      fontSize: emphasized ? 15.5 : 13,
      fontWeight: emphasized ? FontWeight.w900 : FontWeight.w700,
      color: emphasized ? AppColors.secondaryLight : Colors.grey.shade900,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(labelEn, style: baseStyle),
                Text(
                  labelAr,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.left,
                  style: arStyle,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: amtStyle),
              Text(
                _sarStringAr(amount),
                textDirection: TextDirection.rtl,
                style: amtStyle.copyWith(
                  fontSize: (emphasized ? 15.5 : 13.0) * 0.78,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}