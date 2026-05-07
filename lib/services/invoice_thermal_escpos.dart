import 'dart:convert' show utf8;

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart';

import '../models/create_invoice_model.dart';
import '../utils/app_formatters.dart';
import '../utils/invoice_maintenance_checklist.dart';
import '../utils/thermal_invoice_totals.dart'
    show computeThermalInvoiceTotals, thermalInvoiceQrPayload, kThermalInvoiceLogoAsset;

/// [Generator] default was `latin1`. Arabic labels need UTF-8 capable printers.
String thermalSafeText(String input) {
  final normalized = input
      .replaceAll(RegExp(r'[\u2010-\u2015\u2212\uFE63\uFF0D]'), '-')
      .replaceAll('\u00a0', ' ')
      .replaceAll('\u2026', '...')
      .replaceAll(RegExp(r'[\u2018\u2019\u0091\u0092\u201B]'), "'")
      .replaceAll(RegExp(r'[\u201C\u201D\u0093\u0094\u201F]'), '"')
      .replaceAll('\u2022', '*')
      .replaceAll(RegExp(r'[\u061C\u200E\u200F\u2066-\u2069\u2060]'), '');

  final b = StringBuffer();
  for (final code in normalized.runes) {
    if (code >= 0x20 && code <= 0x7e) {
      b.writeCharCode(code);
    } else if (code == 0x09 || code == 0x0a || code == 0x0d) {
      b.writeCharCode(code);
    }
  }
  return b.toString();
}

/// Keeps Arabic blocks + ASCII for bilingual thermal lines (UTF-8 printers).
String thermalBilingualLine(String input) {
  final normalized = input
      .replaceAll(RegExp(r'[\u061C\u200E\u200F\u2066-\u2069\u2060]'), '');
  final b = StringBuffer();
  for (final code in normalized.runes) {
    final c = code;
    if (c >= 0x20 && c <= 0x7e) {
      b.writeCharCode(c);
    } else if (c == 0x09 || c == 0x0a || c == 0x0d) {
      b.writeCharCode(c);
    } else if (c >= 0x0600 && c <= 0x06FF) {
      b.writeCharCode(c);
    } else if (c >= 0x0750 && c <= 0x077F) {
      b.writeCharCode(c);
    } else if (c >= 0x08A0 && c <= 0x08FF) {
      b.writeCharCode(c);
    } else if (c >= 0xFB50 && c <= 0xFDFF) {
      b.writeCharCode(c);
    } else if (c >= 0xFE70 && c <= 0xFEFF) {
      b.writeCharCode(c);
    }
  }
  return b.toString();
}

String _ascii(String s) => thermalSafeText(s);

String _line(String s) => thermalBilingualLine(s);

String _sr(double v) => '${((v * 100).roundToDouble() / 100).toStringAsFixed(2)} SR';

double _r2(double v) => (v * 100).roundToDouble() / 100;

/// Truncate for narrow ESC/POS columns.
String _fitCol(String s, int maxChars) {
  final t = _ascii(s.trim());
  if (t.length <= maxChars) return t;
  if (maxChars <= 3) return t.substring(0, maxChars);
  return '${t.substring(0, maxChars - 2)}..';
}

void _accumulateItems(
  Invoice invoice,
  void Function(InvoiceItem) add,
) {
  if (invoice.departments.isNotEmpty) {
    for (final dept in invoice.departments) {
      for (final item in dept.items) {
        add(item);
      }
    }
  } else {
    for (final item in invoice.items) {
      add(item);
    }
  }
}

const int _kThermalPreviewPaperChars = 48;

void _previewHr(StringBuffer sb, [String ch = '-']) {
  sb.writeln(ch * _kThermalPreviewPaperChars);
}

void _previewCenter(StringBuffer sb, String text, {bool bilingual = false}) {
  final raw = bilingual ? _line(text) : _ascii(text);
  if (raw.length >= _kThermalPreviewPaperChars) {
    sb.writeln(raw);
    return;
  }
  final pad = _kThermalPreviewPaperChars - raw.length;
  sb.writeln('${' ' * (pad ~/ 2)}$raw');
}

/// Plain-text mirror of [buildInvoiceEscPosBytes] content (logo/QR shown as placeholders).
/// For checking exact strings next to what the printer receives.
String buildInvoiceThermalTerminalPreview({
  required Invoice invoice,
  required String paymentMethodText,
}) {
  final sb = StringBuffer();
  _previewHr(sb, '═');
  sb.writeln(_ascii(
    'THERMAL 80mm — text preview ($_kThermalPreviewPaperChars columns)',
  ));
  _previewHr(sb, '═');
  sb.writeln(_ascii('[RASTER CENTER] $kThermalInvoiceLogoAsset'));
  sb.writeln('');

  final issuedFull = formatInvoiceIssuedAtDateTime(invoice.issuedAt);
  final issuedDateOnly = formatInvoiceLegalDate(invoice.invoiceDate);

  final sellerName =
      (invoice.workshopName ?? invoice.branchName ?? 'FILTER').trim();
  final sellerVat = (invoice.branchVatId ?? invoice.workshopTaxId ?? '')
      .trim();
  final addr = (invoice.branchAddress ?? invoice.workshopAddress ?? '')
      .trim();

  _previewCenter(sb, 'Simplified Tax Invoice');
  _previewCenter(sb, 'فاتورة ضريبية مبسطة', bilingual: true);
  sb.writeln('');
  _previewCenter(sb, sellerName, bilingual: true);
  _previewCenter(sb, 'Branch: ${invoice.branchName ?? '-'}', bilingual: true);
  _previewCenter(sb, 'الفرع: ${invoice.branchName ?? '-'}', bilingual: true);
  sb.writeln(_ascii('Address: ${addr.isEmpty ? '-' : addr}'));
  sb.writeln(_line('العنوان: ${addr.isEmpty ? '-' : addr}'));
  sb.writeln(_ascii('VAT Number: ${sellerVat.isEmpty ? '-' : sellerVat}'));
  sb.writeln(
    _line('رقم التسجيل الضريبي: ${sellerVat.isEmpty ? '-' : sellerVat}'),
  );
  sb.writeln(_ascii('Invoice No: ${invoice.invoiceNo}'));
  sb.writeln(_line('رقم الفاتورة: ${invoice.invoiceNo}'));
  final dateLine = issuedFull != null
      ? 'Date: $issuedFull'
      : 'Date: $issuedDateOnly';
  sb.writeln(_ascii(dateLine));
  sb.writeln(_ascii('Counter: ${invoice.branchName ?? '-'}'));
  sb.writeln(_ascii('Cashier: ${invoice.cashierName ?? '-'}'));

  _previewHr(sb, '.');
  sb.writeln('${_ascii('Item').padRight(22)} ${_ascii('Qty').padLeft(4)} '
      '${_ascii('Unit').padLeft(8)} ${_ascii('Total').padLeft(8)}');
  sb.writeln('${_line('الصنف').padRight(22)} ${_line('الكمية').padLeft(4)} '
      '${_line('سعر').padLeft(8)} ${_line('الإجمالي').padLeft(8)}');
  _previewHr(sb, '.');

  void emitLineItem(InvoiceItem item) {
    final qtyLabel = item.qty % 1 == 0
        ? '${item.qty.toInt()}'
        : item.qty.toStringAsFixed(2);
    final unitStr = item.qty > 0.0001
        ? _r2(item.lineTotal / item.qty).toStringAsFixed(2)
        : _r2(item.unitPrice).toStringAsFixed(2);
    final lineStr = _r2(item.lineTotal).toStringAsFixed(2);
    final nm = _fitCol(item.productName, 22);
    sb.writeln(
      '${nm.padRight(22)} ${qtyLabel.padLeft(4)} '
      '${_ascii(unitStr).padLeft(8)} ${_ascii(lineStr).padLeft(8)}',
    );
  }

  _accumulateItems(invoice, emitLineItem);
  _previewHr(sb, '.');

  final t = computeThermalInvoiceTotals(invoice);
  void emitSummaryRow(String label, String valueRight, {bool bold = false}) {
    final mark = bold ? '* ' : '  ';
    sb.writeln(
      '$mark${_ascii(label).padRight(30)} ${_ascii(valueRight).padLeft(14)}',
    );
  }

  emitSummaryRow('Total (Excl VAT)', _sr(t.grossExVatBeforeDiscount));
  emitSummaryRow('Discount', _sr(t.totalDiscountLine));
  emitSummaryRow('Taxable (Excl VAT)', _sr(t.totalTaxableAmount));
  emitSummaryRow('Total VAT', _sr(t.vatAmount));
  emitSummaryRow('Total Amount Due', _sr(t.totalInvoiceAmount), bold: true);
  sb.writeln('');
  sb.writeln(
    _ascii('Paid: $paymentMethodText  ${_sr(t.totalInvoiceAmount)}'),
  );

  _previewHr(sb, '.');

  if (invoice.odometerReading != null && invoice.odometerReading! > 0) {
    sb.writeln(
      _ascii('Next Oil Change / Service: ${invoice.odometerReading}'),
    );
    sb.writeln(_line('القراءة: ${invoice.odometerReading}'));
  }

  _previewHr(sb, '.');
  _previewCenter(sb, 'CUSTOMER DETAILS');
  _previewCenter(sb, 'بيانات العميل', bilingual: true);
  _previewHr(sb, '.');
  sb.writeln(_ascii(
    'Name: ${invoice.customerName}\n'
    'Mobile: ${invoice.customerMobile ?? '-'}\n'
    'Vehicle No: ${invoice.plateNo.isNotEmpty ? invoice.plateNo : '-'}\n'
    'Odometer: ${invoice.odometerReading ?? '-'}',
  ));

  _previewHr(sb, '.');

  final qrPayload = thermalInvoiceQrPayload(invoice, t.totalInvoiceAmount);
  if (qrPayload.isNotEmpty) {
    sb.writeln(_ascii('[QR CODE CENTER — payload]'));
    sb.writeln(qrPayload);
  }

  final checks = invoice.maintenanceChecklistChecks;
  if (checks != null &&
      checks.length == InvoiceMaintenanceChecklist.rows.length &&
      checks.any((v) => v)) {
    _previewHr(sb, '.');
    _previewCenter(sb, 'Maintenance checklist');
    for (var i = 0; i < InvoiceMaintenanceChecklist.rows.length; i++) {
      if (!checks[i]) continue;
      sb.writeln(_ascii('[X] ${InvoiceMaintenanceChecklist.rows[i].en}'));
      sb.writeln(_line(InvoiceMaintenanceChecklist.rows[i].ar));
    }
  }

  _previewCenter(sb, 'Thank you');

  sb.writeln('');
  sb.writeln(_ascii('[CUT] full cut'));
  return sb.toString();
}

/// Line-by-line dump for `flutter run` / IDE terminal when verifying receipt text.
void printThermalInvoicePreviewToStdout({
  required Invoice invoice,
  required String paymentMethodText,
}) {
  final text = buildInvoiceThermalTerminalPreview(
    invoice: invoice,
    paymentMethodText: paymentMethodText,
  );
  const bar =
      '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
  // ignore: avoid_print
  print(bar);
  // ignore: avoid_print
  print(
    'THERMAL INVOICE — Done ► terminal preview (${DateTime.now().toIso8601String()})',
  );
  // ignore: avoid_print
  print(bar);
  for (final line in text.split('\n')) {
    // ignore: avoid_print
    print(line);
  }
  // ignore: avoid_print
  print(bar);
}

/// ESC/POS byte stream — 80mm, simplified tax invoice layout (bilingual header where supported).
Future<List<int>> buildInvoiceEscPosBytes({
  required Invoice invoice,
  required String paymentMethodText,
}) async {
  final profile = await CapabilityProfile.load(name: 'default');
  final g = Generator(PaperSize.mm80, profile, codec: utf8);

  var bytes = <int>[];
  bytes += g.reset();

  try {
    final snap = await rootBundle.load(kThermalInvoiceLogoAsset);
    final decoded = decodeImage(snap.buffer.asUint8List());
    if (decoded != null) {
      Image logo = decoded;
      if (decoded.width > 240) {
        logo = copyResize(decoded, width: 240);
      }
      bytes += g.feed(1);
      bytes += g.image(logo, align: PosAlign.center);
      bytes += g.feed(1);
    }
  } catch (_) {}

  final issuedFull = formatInvoiceIssuedAtDateTime(invoice.issuedAt);
  final issuedDateOnly = formatInvoiceLegalDate(invoice.invoiceDate);

  final sellerName =
      (invoice.workshopName ?? invoice.branchName ?? 'FILTER').trim();
  final sellerVat = (invoice.branchVatId ?? invoice.workshopTaxId ?? '')
      .trim();
  final addr = (invoice.branchAddress ?? invoice.workshopAddress ?? '')
      .trim();

  // ── Header (bilingual title) ───────────────────────────────────────────
  bytes += g.text(
    _line('Simplified Tax Invoice'),
    styles: const PosStyles(
      align: PosAlign.center,
      height: PosTextSize.size2,
      width: PosTextSize.size2,
      bold: true,
    ),
    linesAfter: 1,
  );
  bytes += g.text(
    _line('فاتورة ضريبية مبسطة'),
    styles: const PosStyles(align: PosAlign.center, bold: true),
    linesAfter: 1,
  );

  bytes += g.text(
    _line(sellerName),
    styles: const PosStyles(align: PosAlign.center, bold: true),
    linesAfter: 1,
  );

  bytes += g.text(
    _line('Branch: ${invoice.branchName ?? '-'}'),
    styles: const PosStyles(align: PosAlign.center),
    linesAfter: 0,
  );
  bytes += g.text(
    _line('الفرع: ${invoice.branchName ?? '-'}'),
    styles: const PosStyles(align: PosAlign.center),
    linesAfter: 1,
  );

  bytes += g.text(
    _ascii('Address: ${addr.isEmpty ? '-' : addr}'),
    linesAfter: 0,
  );
  bytes += g.text(
    _line('العنوان: ${addr.isEmpty ? '-' : addr}'),
    linesAfter: 1,
  );

  bytes += g.text(
    _ascii('VAT Number: ${sellerVat.isEmpty ? '-' : sellerVat}'),
    linesAfter: 0,
  );
  bytes += g.text(
    _line('رقم التسجيل الضريبي: ${sellerVat.isEmpty ? '-' : sellerVat}'),
    linesAfter: 1,
  );

  bytes += g.text(
    _ascii('Invoice No: ${invoice.invoiceNo}'),
    linesAfter: 0,
  );
  bytes += g.text(
    _line('رقم الفاتورة: ${invoice.invoiceNo}'),
    linesAfter: 1,
  );

  final dateLine = issuedFull != null
      ? 'Date: $issuedFull'
      : 'Date: $issuedDateOnly';
  bytes += g.text(_ascii(dateLine), linesAfter: 1);
  bytes += g.text(
    _ascii('Counter: ${invoice.branchName ?? '-'}'),
    linesAfter: 1,
  );
  bytes += g.text(
    _ascii('Cashier: ${invoice.cashierName ?? '-'}'),
    linesAfter: 1,
  );

  bytes += g.hr(ch: '.', linesAfter: 1);

  // ── Line items (Item | Qty | Unit | Total) ──────────────────────────────
  const kBoldHdr = PosStyles(bold: true);
  bytes += g.row(
    [
      PosColumn(
        text: _ascii('Item'),
        width: 5,
        styles: kBoldHdr,
      ),
      PosColumn(
        text: _ascii('Qty'),
        width: 2,
        styles: const PosStyles(bold: true, align: PosAlign.center),
      ),
      PosColumn(
        text: _ascii('Unit'),
        width: 2,
        styles: const PosStyles(bold: true, align: PosAlign.right),
      ),
      PosColumn(
        text: _ascii('Total'),
        width: 3,
        styles: const PosStyles(bold: true, align: PosAlign.right),
      ),
    ],
    multiLine: false,
  );
  bytes += g.row(
    [
      PosColumn(text: _line('الصنف'), width: 5, styles: kBoldHdr),
      PosColumn(
        text: _line('الكمية'),
        width: 2,
        styles: const PosStyles(bold: true, align: PosAlign.center),
      ),
      PosColumn(
        text: _line('سعر'),
        width: 2,
        styles: const PosStyles(bold: true, align: PosAlign.right),
      ),
      PosColumn(
        text: _line('الإجمالي'),
        width: 3,
        styles: const PosStyles(bold: true, align: PosAlign.right),
      ),
    ],
    multiLine: false,
  );
  bytes += g.hr(ch: '.', linesAfter: 0);

  void emitLineItem(InvoiceItem item) {
    final qtyLabel = item.qty % 1 == 0
        ? '${item.qty.toInt()}'
        : item.qty.toStringAsFixed(2);
    final unitStr =
        item.qty > 0.0001 ? _r2(item.lineTotal / item.qty).toStringAsFixed(2) : _r2(item.unitPrice).toStringAsFixed(2);
    final lineStr = _r2(item.lineTotal).toStringAsFixed(2);
    final nm = _fitCol(item.productName, 22);
    bytes += g.row(
      [
        PosColumn(text: nm, width: 5),
        PosColumn(
          text: qtyLabel,
          width: 2,
          styles: const PosStyles(align: PosAlign.center),
        ),
        PosColumn(
          text: _ascii(unitStr),
          width: 2,
          styles: const PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: _ascii(lineStr),
          width: 3,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ],
      multiLine: true,
    );
  }

  _accumulateItems(invoice, emitLineItem);
  bytes += g.hr(ch: '.', linesAfter: 1);

  // ── Totals (computed + API fallback) ────────────────────────────────────
  double grossAmountExclVat = 0;
  double itemDiscountsTotal = 0;
  void accumulate(InvoiceItem item) {
    final unitExcl = _r2(item.unitPrice / 1.15);
    final gross = _r2(unitExcl * item.qty);
    var disc = 0.0;
    if (item.discountType == 'percent' || item.discountType == 'percentage') {
      disc = _r2(gross * ((item.discountValue ?? 0) / 100));
    } else if ((item.discountValue ?? 0) > 0) {
      disc = item.discountValue ?? 0;
    }
    grossAmountExclVat += gross;
    itemDiscountsTotal += disc;
  }

  _accumulateItems(invoice, accumulate);

  double invoiceDiscount = 0;
  double promoDiscount = 0;
  if (invoice.departments.isNotEmpty) {
    for (final dept in invoice.departments) {
      final afterLine = dept.amountAfterDiscount > 0
          ? dept.amountAfterDiscount
          : (grossAmountExclVat - itemDiscountsTotal);
      if (dept.totalDiscountType == 'percent' ||
          dept.totalDiscountType == 'percentage') {
        invoiceDiscount += _r2(afterLine * (dept.totalDiscountValue / 100));
      } else {
        invoiceDiscount += dept.totalDiscountValue;
      }
      promoDiscount += dept.promoDiscountAmount;
    }
  }

  var totalDiscountLine = _r2(
    itemDiscountsTotal + invoiceDiscount + promoDiscount,
  );
  if (invoice.discountAmount > 0.001) {
    totalDiscountLine = _r2(invoice.discountAmount);
  }

  var totalTaxableAmount =
      _r2(grossAmountExclVat - itemDiscountsTotal - invoiceDiscount - promoDiscount);
  var vatAmount = _r2(totalTaxableAmount * 0.15);
  var totalInvoiceAmount = _r2(totalTaxableAmount + vatAmount);

  if (invoice.subtotal > 0.001) {
    totalTaxableAmount = _r2(invoice.subtotal);
  }
  if (invoice.vatAmount > 0.001) {
    vatAmount = _r2(invoice.vatAmount);
  }
  if (invoice.totalAmount > 0.001) {
    totalInvoiceAmount = _r2(invoice.totalAmount);
  }

  var grossExVatBeforeDiscount = grossAmountExclVat > 0.001
      ? grossAmountExclVat
      : _r2(totalTaxableAmount + totalDiscountLine);

  void emitSummaryRow(String label, String valueRight, {bool emphasis = false}) {
    bytes += g.row(
      [
        PosColumn(
          text: _ascii(label),
          width: 8,
          styles: PosStyles(bold: emphasis),
        ),
        PosColumn(
          text: _ascii(valueRight),
          width: 4,
          styles: PosStyles(bold: emphasis, align: PosAlign.right),
        ),
      ],
      multiLine: true,
    );
  }

  emitSummaryRow('Total (Excl VAT)', _sr(grossExVatBeforeDiscount));
  emitSummaryRow('Discount', _sr(totalDiscountLine));
  emitSummaryRow('Taxable (Excl VAT)', _sr(totalTaxableAmount));
  emitSummaryRow('Total VAT', _sr(vatAmount));
  emitSummaryRow('Total Amount Due', _sr(totalInvoiceAmount), emphasis: true);
  bytes += g.emptyLines(1);
  bytes += g.text(
    _ascii('Paid: $paymentMethodText  ${_sr(totalInvoiceAmount)}'),
    styles: const PosStyles(bold: true),
    linesAfter: 1,
  );

  bytes += g.hr(ch: '.', linesAfter: 1);

  if (invoice.odometerReading != null && invoice.odometerReading! > 0) {
    bytes += g.text(
      _ascii('Next Oil Change / Service: ${invoice.odometerReading}'),
      linesAfter: 0,
    );
    bytes += g.text(
      _line('القراءة: ${invoice.odometerReading}'),
      linesAfter: 1,
    );
  }

  bytes += g.hr(ch: '.', linesAfter: 1);
  bytes += g.text(
    _ascii('CUSTOMER DETAILS'),
    styles: const PosStyles(align: PosAlign.center, bold: true),
    linesAfter: 0,
  );
  bytes += g.text(
    _line('بيانات العميل'),
    styles: const PosStyles(align: PosAlign.center, bold: true),
    linesAfter: 1,
  );
  bytes += g.hr(ch: '.', linesAfter: 1);

  bytes += g.text(
    _ascii(
      'Name: ${invoice.customerName}\n'
      'Mobile: ${invoice.customerMobile ?? '-'}\n'
      'Vehicle No: ${invoice.plateNo.isNotEmpty ? invoice.plateNo : '-'}\n'
      'Odometer: ${invoice.odometerReading ?? '-'}',
    ),
    linesAfter: 1,
  );

  bytes += g.hr(ch: '.', linesAfter: 1);

  final qrPayload =
      thermalInvoiceQrPayload(invoice, totalInvoiceAmount);
  if (qrPayload.length <= 500 && qrPayload.isNotEmpty) {
    bytes += g.qrcode(
      qrPayload,
      align: PosAlign.center,
      size: QRSize.size5,
      cor: QRCorrection.L,
    );
    bytes += g.emptyLines(2);
  }

  final checks = invoice.maintenanceChecklistChecks;
  if (checks != null &&
      checks.length == InvoiceMaintenanceChecklist.rows.length &&
      checks.any((v) => v)) {
    bytes += g.hr(ch: '.', linesAfter: 1);
    bytes += g.text(
      _ascii('Maintenance checklist'),
      styles: const PosStyles(align: PosAlign.center, bold: true),
      linesAfter: 1,
    );
    for (var i = 0; i < InvoiceMaintenanceChecklist.rows.length; i++) {
      if (!checks[i]) continue;
      bytes += g.text(
        _ascii('[X] ${InvoiceMaintenanceChecklist.rows[i].en}'),
        linesAfter: 0,
      );
      bytes += g.text(
        _line(InvoiceMaintenanceChecklist.rows[i].ar),
        linesAfter: 1,
      );
    }
  }

  bytes += g.text(
    _ascii('Thank you'),
    styles: const PosStyles(align: PosAlign.center, bold: true),
    linesAfter: 1,
  );

  bytes += g.emptyLines(1);
  bytes += g.cut(mode: PosCutMode.full);

  return bytes;
}
