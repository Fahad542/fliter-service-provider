import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/create_invoice_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_formatters.dart';
import '../utils/invoice_maintenance_checklist.dart';
import '../utils/thermal_invoice_totals.dart';

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

String _sar(double v) => 'SAR ${v.toStringAsFixed(2)}';

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
      child: const Text(
        'Maintenance checklist',
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 12,
          color: AppColors.onPrimaryLight,
        ),
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
  'Goods/Services',
  'Unit Price (Excl. VAT)',
  'Qty',
  'Gross Amt Before VAT',
  'Discount',
  'Total Before VAT',
  'VAT',
  'Total With VAT',
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
                                    'Simplified TAX Invoice',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: white70,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    'Invoice No: ${invoice.invoiceNo}',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: white70,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Date: $dateStr',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: white70,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    timeStr != null
                                        ? 'Time: $timeStr'
                                        : 'Time: —',
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
            child: Text(
              _branchRibbonText(invoice),
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 0.35,
                color: AppColors.onPrimaryLight,
              ),
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
                        label: 'Customer',
                        value: _dash(invoice.customerName),
                      ),
                      _infoCell(
                        label: 'Phone',
                        value: _dash(invoice.customerMobile ?? ''),
                      ),
                      _infoCell(
                        label: 'Tax ID',
                        value: _dash(invoice.customerTaxId),
                      ),
                      _infoCell(
                        label: 'Model',
                        value: _dash(invoice.vehicleModel),
                      ),
                      _infoCell(
                        label: 'Plate',
                        value: invoice.plateNo.trim().isEmpty
                            ? '—'
                            : invoice.plateNo.trim(),
                      ),
                      _infoCell(
                        label: 'Year',
                        value: _dash(invoice.vehicleYear),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      _infoCell(
                        label: 'VIN',
                        value: _dash(invoice.vehicleVin),
                      ),
                      _infoCell(
                        label: 'Mileage',
                        value:
                            invoice.odometerReading != null &&
                                invoice.odometerReading! > 0
                            ? '${invoice.odometerReading}'
                            : '—',
                      ),
                      _infoCell(
                        label: 'Make',
                        value: _dash(invoice.vehicleMake),
                      ),
                      _infoCell(
                        label: 'Payment Method',
                        value: paymentMethodText.trim().isEmpty
                            ? '—'
                            : paymentMethodText.trim(),
                      ),
                      _infoCell(
                        label: 'Employees',
                        value: _employeesSummary(invoice),
                      ),
                      _infoCell(
                        label: 'Cashier',
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
                _amountRow(
                  'Gross Amount (Excluding VAT)',
                  _sar(t.grossAmountExclVat),
                ),
                _amountRow('Item Discounts', _sar(t.itemDiscountsTotal)),
                _amountRow('Total Taxable Amount', _sar(t.totalTaxableAmount)),
                _amountRow('VAT 15%', _sar(t.vatAmount)),
                const Divider(height: 18),
                _amountRow(
                  'Total Invoice Amount',
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

  Widget _infoCell({required String label, required String value}) {
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
            value,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.grey.shade900,
              height: 1.25,
            ),
          ),
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
      const hdrRowH = 36.0;
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
                          maxLines: 1,
                          softWrap: false,
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
              bodyCell(row.productName, maxLines: 4, leadingPadding: 8),
              bodyCell(_sar(row.unitPriceExclVat)),
              bodyCell(_fmtQty(row.qty), maxLines: 1),
              bodyCell(_sar(row.grossBeforeVat)),
              bodyCell(_sar(row.discount)),
              bodyCell(_sar(row.totalBeforeVat)),
              bodyCell(_sar(row.lineVat)),
              bodyCell(_sar(row.totalWithVat), maxLines: 1),
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
              'No line items.',
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
      child: const Text(
        'Total Amount',
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 13,
          color: AppColors.onPrimaryLight,
        ),
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
}
