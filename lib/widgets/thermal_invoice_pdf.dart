import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/create_invoice_model.dart';
import '../services/locker_translation_mixin.dart';
import '../utils/app_formatters.dart';
import '../utils/plate_transliterator.dart';
import '../utils/bundle_brand_logo.dart';
import '../utils/invoice_maintenance_checklist.dart';
import '../utils/thermal_invoice_totals.dart';
import '../utils/thermal_receipt_logo_preprocess.dart';
import '../utils/thermal_safe_text.dart';
import 'thermal_invoice_pdf_ar_constants.dart';
import 'thermal_arabic_pdf_reshaper.dart';

/// Reshape Arabic for the `pdf` package (which has no HarfBuzz shaping).
/// Call this on every Arabic string before passing it to [pw.Text].
/// Do **not** set [pw.TextDirection.rtl] on reshaped strings — the reshaper
/// already reverses the glyphs for LTR layout.
String _ar(String s) => reshapeArabic(s);
String _arMixedLtr(String s) => reshapeArabicForMixedLtr(s);

bool _thermalInvoicePdfHasArabic(String s) =>
    RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]').hasMatch(s);

/// Vector checkbox for maintenance lines (avoids Unicode ballot glyphs on some printers).
pw.Widget thermalMaintenanceCheckbox(bool checked, {double side = 9.2}) {
  return pw.SizedBox(
    width: side + 3,
    height: side + 1,
    child: pw.Align(
      alignment: pw.Alignment.centerLeft,
      child: pw.SizedBox(
        width: side,
        height: side,
        child: pw.CustomPaint(
          size: PdfPoint(side, side),
          painter: (PdfGraphics canvas, PdfPoint sz) {
            final w = sz.x;
            final h = sz.y;
            const inset = 0.35;
            canvas
              ..setStrokeColor(PdfColors.black)
              ..setLineWidth(0.5)
              ..drawRect(inset, inset, w - 2 * inset, h - 2 * inset)
              ..strokePath();
            if (checked) {
              final x0 = w * 0.20;
              final y0 = h * 0.48;
              final x1 = w * 0.40;
              final y1 = h * 0.22;
              final x2 = w * 0.82;
              final y2 = h * 0.58;
              canvas
                ..setStrokeColor(PdfColors.black)
                ..setLineWidth(0.75)
                ..setLineCap(PdfLineCap.round)
                ..setLineJoin(PdfLineJoin.round)
                ..moveTo(x0, y0)
                ..lineTo(x1, y1)
                ..lineTo(x2, y2)
                ..strokePath();
            }
          },
        ),
      ),
    ),
  );
}

/// Narrow roll-style PDF (~80 mm) for system print preview / AirPrint.
pw.Document buildThermalInvoicePdfDocument({
  required Invoice invoice,
  required String paymentMethodText,
  Uint8List? filterLogoPngBytes,
  required pw.Font font,
  required pw.Font fontBold,
  required pw.Font fontArabic,
  List<bool>? maintenanceChecksFallback,
  Map<String, String> dynamicArabicValues = const <String, String>{},
}) {
  final t = computeThermalInvoiceTotals(invoice);
  final qrData = thermalInvoiceQrPayload(invoice, t.totalInvoiceAmount);
  final issued = formatInvoiceIssuedAtDateTime(invoice.issuedAt) ??
      formatInvoiceLegalDate(invoice.invoiceDate);
  final workshopLine = (invoice.workshopName ?? '').trim();
  final seller = workshopLine.isNotEmpty ? workshopLine : '—';
  final vatNo = (invoice.branchVatId ?? invoice.workshopTaxId ?? '').trim();
  final addr =
  (invoice.branchAddress ?? invoice.workshopAddress ?? '').trim();
  final pdfItemDiscount = thermalR2(t.itemDiscountsTotal);
  final pdfInvoiceDiscount = thermalR2(t.invoiceDiscount);
  final pdfPromoDiscount = thermalR2(t.promoDiscount);

  final pdf = pw.Document();

  const fsMeta = 7.45;
  pw.TextStyle tsLabel() => pw.TextStyle(
    font: fontBold,
    fontSize: fsMeta + 0.35,
    fontWeight: pw.FontWeight.bold,
    height: 1.05,
  );
  pw.TextStyle tsArabicLabel() => pw.TextStyle(
    font: fontArabic,
    fontSize: fsMeta + 0.35,
    fontWeight: pw.FontWeight.bold,
    height: 1.05,
  );
  pw.TextStyle tsValue() =>
      pw.TextStyle(font: font, fontSize: fsMeta, height: 1.05);

  String pdfUserLine(String raw) => pdfStripBidiAndInvisible(raw.trim());
  String pdfLabelLine(String raw) {
    final clean = pdfStripBidiAndInvisible(raw.trimRight());
    return _thermalInvoicePdfHasArabic(clean) ? _arMixedLtr(clean) : clean;
  }

  pw.TextStyle pdfLabelStyle(String raw) =>
      _thermalInvoicePdfHasArabic(raw) ? tsArabicLabel() : tsLabel();

  String pdfArabicDigits(String raw) {
    var out = raw;
    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (var i = 0; i < western.length; i++) {
      out = out.replaceAll(western[i], arabic[i]);
    }
    return out;
  }

  String pdfMoneyEn(num amount) => '${amount.toStringAsFixed(2)} SR';
  String pdfMoneyAr(num amount) => '${pdfArabicDigits(amount.toStringAsFixed(2))} ر.س';

  String dynamicArabicFor(String raw) {
    final clean = pdfUserLine(raw);
    if (clean.isEmpty || clean == '-') return '';
    if (_thermalInvoicePdfHasArabic(clean)) return '';
    final direct = dynamicArabicValues[clean] ?? dynamicArabicValues[raw.trim()];
    final ar = pdfUserLine(direct ?? '');
    if (ar.isNotEmpty && ar.toLowerCase() != clean.toLowerCase()) return ar;
    final digitMirror = pdfArabicDigits(clean);
    return digitMirror == clean ? '' : digitMirror;
  }

  pw.Widget bilingualHeaderLeading(String ar, String en) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            _ar(ar),
            style: pw.TextStyle(font: fontArabic, fontSize: 6.6, height: 1.08),
            textAlign: pw.TextAlign.right,
          ),
        ),
        pw.SizedBox(height: 1.1),
        pw.Text(
          en,
          style: pw.TextStyle(font: fontBold, fontSize: 7.8),
        ),
      ],
    );
  }

  pw.Widget bilingualHeaderTriple(String ar, String en) {
    return pw.Center(
      child: pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(
            _ar(ar),
            style: pw.TextStyle(font: fontArabic, fontSize: 6.6, height: 1.08),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 1.1),
          pw.Text(
            en,
            style: pw.TextStyle(font: fontBold, fontSize: 7),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  pw.Widget bilingualHeaderEndAligned(String ar, String en) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            _ar(ar),
            style: pw.TextStyle(font: fontArabic, fontSize: 6.6, height: 1.08),
            textAlign: pw.TextAlign.right,
          ),
        ),
        pw.SizedBox(height: 1.1),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            en,
            style: pw.TextStyle(font: fontBold, fontSize: 7),
            textAlign: pw.TextAlign.right,
          ),
        ),
      ],
    );
  }

  String paymentEnLabelNoColon(String rawMethod) {
    final display = thermalSafeText(rawMethod).trim();
    final inner = display.isEmpty ? '-' : display;
    return 'Payment type ( $inner )';
  }

  /// Payment lines only: Arabic + English, left-aligned; no SR amount row.
  pw.Widget thermalPaymentBlockLeftNoAmount(String paymentMethodRaw) {
    const enSize = 7.6;
    const arabicSize = 6.6;
    final lbl = pw.TextStyle(font: fontBold, fontSize: enSize);
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 1.85),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(
            _ar(ThermalInvoicePdfLabels.paymentArabicLine(paymentMethodRaw)),
            style: pw.TextStyle(
              font: fontArabic,
              fontSize: arabicSize,
              height: 1.08,
            ),
            textAlign: pw.TextAlign.left,
            maxLines: 10,
          ),
          pw.SizedBox(height: 0.5),
          pw.Text(
            paymentEnLabelNoColon(paymentMethodRaw),
            style: lbl,
            textAlign: pw.TextAlign.left,
            maxLines: 6,
          ),
        ],
      ),
    );
  }

  pw.Widget arabicAboveRichLabelSized(
      String arabicLines,
      String englishLabel,
      String englishValue, {
        required double enSize,
        double arabicSize = 6.6,
      }) {
    final lbl = pw.TextStyle(font: fontBold, fontSize: enSize);
    final val = pw.TextStyle(font: font, fontSize: enSize);
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 1.85),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(
            _ar(arabicLines),
            style: pw.TextStyle(
              font: fontArabic,
              fontSize: arabicSize,
              height: 1.08,
            ),
            textAlign: pw.TextAlign.left,
            maxLines: 10,
          ),
          pw.SizedBox(height: 0.5),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Expanded(
                child: pw.Text(
                  englishLabel,
                  style: lbl,
                  textAlign: pw.TextAlign.left,
                ),
              ),
              pw.Text(
                englishValue,
                style: val,
                textAlign: pw.TextAlign.right,
              ),
            ],
          ),
        ],
      ),
    );
  }


  pw.Widget arabicEnglishAmountLabelSized(
    String arabicLines,
    String englishLabel,
    num amount, {
    required double enSize,
    double arabicSize = 6.6,
  }) {
    final lbl = pw.TextStyle(font: fontBold, fontSize: enSize);
    final val = pw.TextStyle(font: font, fontSize: enSize);
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 1.85),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Expanded(
                child: pw.Text(
                  _ar(arabicLines),
                  style: pw.TextStyle(
                    font: fontArabic,
                    fontSize: arabicSize,
                    height: 1.08,
                  ),
                  textAlign: pw.TextAlign.left,
                  maxLines: 10,
                ),
              ),
              pw.Text(
                _ar(pdfMoneyAr(amount)),
                style: pw.TextStyle(
                  font: fontArabic,
                  fontSize: arabicSize,
                  height: 1.08,
                ),
                textAlign: pw.TextAlign.right,
              ),
            ],
          ),
          pw.SizedBox(height: 0.5),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Expanded(
                child: pw.Text(
                  englishLabel,
                  style: lbl,
                  textAlign: pw.TextAlign.left,
                ),
              ),
              pw.Text(
                pdfMoneyEn(amount),
                style: val,
                textAlign: pw.TextAlign.right,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Latin-only values: inline [RichText]. Arabic (or mixed) values: separate [pw.Text] with RTL
  /// so HarfBuzz shapes joined glyphs — [RichText] spans break Arabic ligatures.
  pw.Widget richLabelValue(String label, String value) {
    final v = pdfUserLine(value);
    final pad = pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 0.35),
      child: _thermalInvoicePdfHasArabic(v)
          ? pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(pdfLabelLine(label), style: pdfLabelStyle(label)),
          pw.SizedBox(width: 3),
          pw.Expanded(
            child: pw.Text(
              _ar(v),
              style: pw.TextStyle(
                font: fontArabic,
                fontSize: fsMeta + 0.5,
                height: 1.05,
              ),
              textAlign: pw.TextAlign.left,
              maxLines: 6,
              softWrap: true,
            ),
          ),
        ],
      )
          : pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(text: pdfLabelLine(label), style: pdfLabelStyle(label)),
            pw.TextSpan(text: v, style: tsValue()),
          ],
        ),
      ),
    );
    return pad;
  }

  pw.Widget richLabelValueBilingual(String label, String value) {
    final v = pdfUserLine(value);
    final ar = dynamicArabicFor(v);
    if (ar.isEmpty) return richLabelValue(label, v);
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 0.55),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(
            _ar(ar),
            style: pw.TextStyle(
              font: fontArabic,
              fontSize: fsMeta + 0.1,
              height: 1.05,
            ),
            textAlign: pw.TextAlign.left,
            maxLines: 6,
            softWrap: true,
          ),
          richLabelValue(label, v),
        ],
      ),
    );
  }

  /// Matches POS / cashier preview: letters-first Latin + MoI Arabic line (not generic translation).
  pw.Widget richPlateLineBilingual(String label, String plateRawTrimmed) {
    final formatted = formatVehiclePlateLettersFirst(plateRawTrimmed);
    final latin =
        formatted.isEmpty ? pdfUserLine(plateRawTrimmed) : pdfUserLine(formatted);
    final plateAr = PlateTransliterator.localize(
      formatted.isEmpty ? plateRawTrimmed : formatted,
      'ar',
    );
    if (plateAr.isEmpty) return richLabelValue(label, latin);
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 0.55),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(
            _ar(plateAr),
            style: pw.TextStyle(
              font: fontArabic,
              fontSize: fsMeta + 0.1,
              height: 1.05,
            ),
            textAlign: pw.TextAlign.left,
            maxLines: 6,
            softWrap: true,
          ),
          richLabelValue(label, latin),
        ],
      ),
    );
  }

  /// Branch / address / cashier — Arabic dynamic value above English when available.
  pw.Widget thermalMetaLabelValue(String label, String rawValue) {
    return richLabelValueBilingual(label, pdfUserLine(rawValue));
  }

// ── Bilingual section header (Arabic / English) ─────────────────────────────
  pw.Widget bilingualSectionHeader(String ar, String en) => pw.Row(
    children: [
      pw.Text(
        _ar(ar),
        style: pw.TextStyle(font: fontArabic, fontSize: 7.2, height: 1.08),
      ),
      pw.Text(' / ', style: pw.TextStyle(font: fontBold, fontSize: 7.6)),
      pw.Text(en, style: pw.TextStyle(font: fontBold, fontSize: 7.6)),
    ],
  );

  /// Strong full-width divider for thermal raster printing.
  /// Text-based dashed lines can clip or fade on 80mm raster output,
  /// so this uses a vector line that always spans the available paper width.
  pw.Widget dashed() => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2.1),
    child: pw.Container(
      width: double.infinity,
      height: 1.1,
      color: PdfColors.grey700,
    ),
  );

  pw.Widget row4(
      pw.Widget w1,
      pw.Widget w2,
      pw.Widget w3,
      pw.Widget w4,
      ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(flex: 5, child: w1),
        pw.SizedBox(width: 22, child: w2),
        pw.Expanded(flex: 3, child: w3),
        pw.Expanded(flex: 3, child: w4),
      ],
    );
  }

  pw.Widget thermalDetailGrid(
      List<pw.Widget> cells, {
        int columnsPerRow = 1,
        double rowGap = 3,
        double colGap = 5,
      }) {
    final cols = columnsPerRow.clamp(1, 12);
    final rows = <pw.Widget>[];
    for (var i = 0; i < cells.length; i += cols) {
      final end = i + cols > cells.length ? cells.length : i + cols;
      final chunk = cells.sublist(i, end);
      rows.add(
        pw.Padding(
          padding: pw.EdgeInsets.only(bottom: rowGap),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              for (var idx = 0; idx < chunk.length; idx++)
                pw.Expanded(
                  child: pw.Padding(
                    padding: pw.EdgeInsets.only(
                      right: idx < chunk.length - 1 ? colGap : 0,
                    ),
                    child: chunk[idx],
                  ),
                ),
              for (var j = chunk.length; j < cols; j++)
                pw.Expanded(child: pw.SizedBox()),
            ],
          ),
        ),
      );
    }
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: rows,
    );
  }

  final itemNumStyle = pw.TextStyle(font: fontBold, fontSize: 7.85);
  final itemEnStyle = pw.TextStyle(font: fontBold, fontSize: 7.9);
  final itemArStyle = pw.TextStyle(
    font: fontArabic,
    fontSize: 6.65,
    height: 1.06,
  );

  final itemBlocks = <pw.Widget>[];
  accumulateInvoiceItems(invoice, (item) {
    final qty = item.qty % 1 == 0
        ? '${item.qty.toInt()}'
        : item.qty.toStringAsFixed(2);
    final unit = item.qty > 0.0001
        ? thermalR2(item.lineTotal / item.qty)
        : thermalR2(item.unitPrice);
    final total = thermalR2(item.lineTotal);
    final en = thermalSafeText(item.productName).toUpperCase();
    final ar = pdfUserLine((item.productNameArabic ?? '').trim().isNotEmpty
        ? item.productNameArabic!
        : dynamicArabicFor(item.productName));
    itemBlocks.add(
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 0.9),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            if (ar.isNotEmpty) ...[
              pw.Text(
                _ar(ar),
                style: itemArStyle,
                textAlign: pw.TextAlign.left,
                maxLines: 4,
              ),
              pw.SizedBox(height: 1.1),
            ],
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Expanded(
                  flex: 5,
                  child: pw.Text(
                    en,
                    style: itemEnStyle,
                    textAlign: pw.TextAlign.left,
                    maxLines: 3,
                  ),
                ),
                pw.SizedBox(
                  width: 22,
                  child: pw.Center(
                    child: pw.Column(
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        pw.Text(qty, style: itemNumStyle),
                        pw.Text(
                          pdfArabicDigits(qty),
                          style: pw.TextStyle(font: fontArabic, fontSize: 6.3),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 3,
                  child: pw.Text(
                    '${unit.toStringAsFixed(2)} SR\n${pdfMoneyAr(unit)}',
                    style: itemNumStyle,
                    textAlign: pw.TextAlign.right,
                  ),
                ),
                pw.Expanded(
                  flex: 3,
                  child: pw.Text(
                    '${total.toStringAsFixed(2)} SR\n${pdfMoneyAr(total)}',
                    style: itemNumStyle,
                    textAlign: pw.TextAlign.right,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  });

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat(
        80 * PdfPageFormat.mm,
        double.infinity,
        marginAll: 4.5 * PdfPageFormat.mm,
      ),
      build: (ctx) {
        bool hasAnyText(String? s) => (s ?? '').trim().isNotEmpty;

        bool hasMeaningfulCustomerName(String name) {
          final t = name.trim();
          return t.isNotEmpty && t.toLowerCase() != 'unknown';
        }

        final customerKids = <pw.Widget>[];

        void addCustLine(String label, String valueTrimmed) {
          if (valueTrimmed.isEmpty) return;
          customerKids.add(
            richLabelValueBilingual(label, pdfUserLine(valueTrimmed)),
          );
        }

        if (hasMeaningfulCustomerName(invoice.customerName)) {
          addCustLine('${ThermalInvoicePdfLabels.customerNameAr} / Name: ', invoice.customerName.trim());
        }
        if (hasAnyText(invoice.customerMobile)) {
          addCustLine('${ThermalInvoicePdfLabels.customerMobileAr} / Mobile: ', invoice.customerMobile!.trim());
        }
        if (hasAnyText(invoice.customerTaxId)) {
          addCustLine('${ThermalInvoicePdfLabels.customerTaxIdAr} / Tax ID: ', invoice.customerTaxId!.trim());
        }
        addCustLine(
          '${ThermalInvoicePdfLabels.customerTypeAr} / Customer type: ',
          pdfUserLine(invoice.thermalDisplayedCustomerType.trim()),
        );

        final hasMake = invoice.vehicleMake.trim().isNotEmpty;
        final hasModel = invoice.vehicleModel.trim().isNotEmpty;
        if (!(hasMake || hasModel) && invoice.vehicleInfo.trim().isNotEmpty) {
          addCustLine('${ThermalInvoicePdfLabels.vehicleAr} / Vehicle: ', invoice.vehicleInfo.trim());
        } else {
          if (hasMake) addCustLine('${ThermalInvoicePdfLabels.vehicleMakeAr} / Make: ', invoice.vehicleMake.trim());
          if (hasModel) addCustLine('${ThermalInvoicePdfLabels.vehicleModelAr} / Model: ', invoice.vehicleModel.trim());
        }

        if (hasAnyText(invoice.vehicleYear)) {
          addCustLine('${ThermalInvoicePdfLabels.vehicleYearAr} / Year: ', invoice.vehicleYear.trim());
        }
        if (invoice.plateNo.trim().isNotEmpty) {
          customerKids.add(
            richPlateLineBilingual(
              '${ThermalInvoicePdfLabels.vehiclePlateAr} / Plate: ',
              invoice.plateNo.trim(),
            ),
          );
        }
        if (hasAnyText(invoice.vehicleVin)) {
          addCustLine('${ThermalInvoicePdfLabels.vehicleVinAr} / VIN: ', invoice.vehicleVin.trim());
        }
        if (invoice.odometerReading != null && invoice.odometerReading! > 0) {
          addCustLine('${ThermalInvoicePdfLabels.vehicleOdometerAr} / Odometer: ', '${invoice.odometerReading}');
        }

        final chkResolved = InvoiceMaintenanceChecklist.resolvedChecks(
          invoice,
          maintenanceChecksFallback,
        );
        final checklistKids = <pw.Widget>[];
        if (chkResolved != null && chkResolved.any((v) => v)) {
          for (var i = 0;
          i < InvoiceMaintenanceChecklist.rows.length;
          i++) {
            final row = InvoiceMaintenanceChecklist.rows[i];
            final checked = chkResolved[i];
            checklistKids.add(
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 2),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 0.5, right: 4),
                      child: thermalMaintenanceCheckbox(checked),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        mainAxisSize: pw.MainAxisSize.min,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            _ar(row.ar),
                            style: pw.TextStyle(
                              font: fontArabic,
                              fontSize: 5.25,
                              height: 1.06,
                            ),
                            maxLines: 4,
                            textAlign: pw.TextAlign.left,
                          ),
                          pw.SizedBox(height: 1.5),
                          pw.Text(
                            row.en,
                            style: pw.TextStyle(font: fontBold, fontSize: 6),
                            maxLines: 3,
                            textAlign: pw.TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        }

        return pw.DefaultTextStyle(
          style: pw.TextStyle(font: font, fontSize: 7.85),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              if (filterLogoPngBytes != null && filterLogoPngBytes.isNotEmpty)
                pw.Center(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 2),
                    child: pw.Image(
                      pw.MemoryImage(filterLogoPngBytes),
                      height: 26,
                      fit: pw.BoxFit.contain,
                    ),
                  ),
                ),
              pw.Center(
                child: pw.Column(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Text(
                      _ar(ThermalInvoicePdfLabels.documentTitleAr),
                      style: pw.TextStyle(
                        font: fontArabic,
                        fontSize: 9.8,
                        height: 1.0,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 0.8),
                    pw.Text(
                      ThermalInvoicePdfLabels.documentTitleEn,
                      style: pw.TextStyle(font: fontBold, fontSize: 10),
                      textAlign: pw.TextAlign.center,
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Center(
                child: pw.Column(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    if (dynamicArabicFor(seller).isNotEmpty) ...[
                      pw.Text(
                        _ar(dynamicArabicFor(seller)),
                        style: pw.TextStyle(
                          font: fontArabic,
                          fontSize: 9.0,
                          height: 1.05,
                        ),
                        textAlign: pw.TextAlign.center,
                        maxLines: 3,
                      ),
                      pw.SizedBox(height: 0.8),
                    ],
                    pw.Text(
                      pdfUserLine(seller),
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 9.6,
                        height: 1.05,
                      ),
                      textAlign: pw.TextAlign.center,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 2.5),
              thermalDetailGrid(
                [
                  thermalMetaLabelValue('${ThermalInvoicePdfLabels.branchAr} / Branch: ', invoice.branchName ?? '-'),
                  richLabelValue(
                    '${ThermalInvoicePdfLabels.vatNoAr} / VAT: ',
                    vatNo.isEmpty ? '-' : pdfUserLine(vatNo),
                  ),
                  thermalMetaLabelValue(
                    '${ThermalInvoicePdfLabels.addressAr} / Address: ',
                    addr.isEmpty ? '-' : addr,
                  ),
                  richLabelValue('${ThermalInvoicePdfLabels.invoiceNoAr} / Invoice No: ', pdfUserLine(invoice.invoiceNo)),
                  richLabelValue('${ThermalInvoicePdfLabels.dateAr} / Date: ', pdfUserLine(issued)),
                  thermalMetaLabelValue(
                    '${ThermalInvoicePdfLabels.cashierAr} / Cashier: ',
                    invoice.cashierName ?? '-',
                  ),
                ],
                rowGap: 0.25,
              ),
              dashed(),
              row4(
                bilingualHeaderLeading(
                  ThermalInvoicePdfLabels.columnItemAr,
                  ThermalInvoicePdfLabels.columnItemEn,
                ),
                bilingualHeaderTriple(
                  ThermalInvoicePdfLabels.columnQtyAr,
                  ThermalInvoicePdfLabels.columnQtyEn,
                ),
                bilingualHeaderEndAligned(
                  ThermalInvoicePdfLabels.columnUnitAr,
                  ThermalInvoicePdfLabels.columnUnitEn,
                ),
                bilingualHeaderEndAligned(
                  ThermalInvoicePdfLabels.columnTotalAr,
                  ThermalInvoicePdfLabels.columnTotalEn,
                ),
              ),
              dashed(),
              ...itemBlocks,
              dashed(),
              arabicEnglishAmountLabelSized(
                ThermalInvoicePdfLabels.totalExclVatAr,
                '${ThermalInvoicePdfLabels.totalExclVatEn}: ',
                t.grossExVatBeforeDiscount,
                enSize: 7.8,
              ),
              arabicEnglishAmountLabelSized(
                ThermalInvoicePdfLabels.itemDiscountAr,
                '${ThermalInvoicePdfLabels.itemDiscountEn}: ',
                pdfItemDiscount,
                enSize: 7.6,
              ),
              arabicEnglishAmountLabelSized(
                ThermalInvoicePdfLabels.invoiceDiscountAr,
                '${ThermalInvoicePdfLabels.invoiceDiscountEn}: ',
                pdfInvoiceDiscount,
                enSize: 7.6,
              ),
              arabicEnglishAmountLabelSized(
                ThermalInvoicePdfLabels.promoDiscountAr,
                '${ThermalInvoicePdfLabels.promoDiscountEn}: ',
                pdfPromoDiscount,
                enSize: 7.6,
              ),
              arabicEnglishAmountLabelSized(
                ThermalInvoicePdfLabels.taxableAr,
                '${ThermalInvoicePdfLabels.taxableEn}: ',
                t.totalTaxableAmount,
                enSize: 7.6,
              ),
              arabicEnglishAmountLabelSized(
                ThermalInvoicePdfLabels.totalVatAr,
                '${ThermalInvoicePdfLabels.totalVatEn}: ',
                t.vatAmount,
                enSize: 7.6,
              ),
              arabicEnglishAmountLabelSized(
                ThermalInvoicePdfLabels.totalDueAr,
                '${ThermalInvoicePdfLabels.totalDueEn}: ',
                t.totalInvoiceAmount,
                enSize: 8.2,
                arabicSize: 6.75,
              ),
              pw.SizedBox(height: 0.35),
              thermalPaymentBlockLeftNoAmount(paymentMethodText),
              if (invoice.nextOilChangeKm != null) ...[
                dashed(),
                pw.SizedBox(height: 1.1),
                arabicAboveRichLabelSized(
                  ThermalInvoicePdfLabels.nextOilChangeAr,
                  '${ThermalInvoicePdfLabels.nextOilChangeEn}: ',
                  '${NumberFormat('#,##0', 'en_US').format(invoice.nextOilChangeKm!)} km / ${pdfArabicDigits(NumberFormat('#,##0', 'en_US').format(invoice.nextOilChangeKm!))} كم',
                  enSize: 7.4,
                ),
              ],
              dashed(),
              if (customerKids.isNotEmpty) ...[
                bilingualSectionHeader(
                  ThermalInvoicePdfLabels.customerDetailsSectionAr,
                  ThermalInvoicePdfLabels.customerDetailsSectionEn,
                ),
                pw.SizedBox(height: 1.2),
                thermalDetailGrid(
                  customerKids,
                  columnsPerRow: 2,
                  rowGap: 0.35,
                  colGap: 3,
                ),
              ],
              if (checklistKids.isNotEmpty) ...[
                if (customerKids.isNotEmpty) pw.SizedBox(height: 2.5),
                bilingualSectionHeader(
                  ThermalInvoicePdfLabels.maintenanceSectionAr,
                  ThermalInvoicePdfLabels.maintenanceSectionEn,
                ),
                pw.SizedBox(height: 1.2),
                thermalDetailGrid(
                  checklistKids,
                  columnsPerRow: 2,
                  rowGap: 1.25,
                ),
                pw.SizedBox(height: 2),
              ],
              dashed(),
              pw.Center(
                child: pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: qrData,
                  width: 104,
                  height: 104,
                ),
              ),
              pw.SizedBox(height: 1.5),
              pw.Center(
                child: pw.Row(
                  mainAxisSize: pw.MainAxisSize.min,
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      ThermalInvoicePdfLabels.thankYouEn,
                      style: pw.TextStyle(font: fontBold, fontSize: 8),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Text(
                      _ar(ThermalInvoicePdfLabels.thankYouAr),
                      style: pw.TextStyle(
                        font: fontArabic,
                        fontSize: 8,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  return pdf;
}

Future<Uint8List> buildThermalInvoicePdfBytes({
  required Invoice invoice,
  required String paymentMethodText,
  List<bool>? maintenanceChecksFallback,
}) async {
  Uint8List? logoBytes;
  try {
    final data = await loadBrandLogoByteData();
    if (data != null) {
      final raw = data.buffer.asUint8List();
      logoBytes =
          preprocessThermalReceiptLogoPng(raw, targetMaxWidth: 200) ?? raw;
    }
  } catch (_) {
    logoBytes = null;
  }

  /// Bundled Noto: same TTF for [font] and [fontBold] so Latin/Arabic always
  /// render (no separate bold TTF — avoids missing-glyph “tofu” on English).
  pw.Font font;
  pw.Font fontBold;
  pw.Font fontArabic;
  try {
    final notoBytes = await rootBundle.load(
      'assets/fonts/NotoSansArabic-Regular.ttf',
    );
    final noto = pw.Font.ttf(notoBytes);
    font = noto;
    fontBold = noto;
    fontArabic = noto;
  } catch (_) {
    try {
      font = await PdfGoogleFonts.poppinsRegular();
      fontBold = await PdfGoogleFonts.poppinsBold();
    } catch (_) {
      font = pw.Font.helvetica();
      fontBold = pw.Font.helveticaBold();
    }
    try {
      fontArabic = await PdfGoogleFonts.almaraiBold();
    } catch (_) {
      try {
        fontArabic = await PdfGoogleFonts.cairoBold();
      } catch (_) {
        fontArabic = fontBold;
      }
    }
  }

  // Dynamic API/database values cannot use the Flutter LocalizedApiText widget in
  // a pdf/widgets document. Use the same translation service behind
  // LocalizedApiText so screen preview, PDF, and Wi-Fi print all stay bilingual.
  final dynamicArabicValues = <String, String>{};

  Future<void> addDynamicArabic(String? raw) async {
    final clean = pdfStripBidiAndInvisible((raw ?? '').trim());
    if (clean.isEmpty || clean == '-' || _thermalInvoicePdfHasArabic(clean)) {
      return;
    }
    // Plates are handled by PlateTransliterator only, not by API translation.
    if (PlateTransliterator.looksLikePlate(clean)) return;
    // Pure numbers, phone numbers, dates, and IDs only need Arabic-Indic digits;
    // do not send them to dynamic API translation.
    if (!RegExp(r'[A-Za-z]').hasMatch(clean)) return;
    if (dynamicArabicValues.containsKey(clean)) return;
    try {
      final translated = await AppTranslationService.localizedDynamicValueForLanguage(
        clean,
        'ar',
      );
      final ar = pdfStripBidiAndInvisible(translated.trim());
      if (ar.isNotEmpty && ar.toLowerCase() != clean.toLowerCase()) {
        dynamicArabicValues[clean] = ar;
      }
    } catch (_) {
      // Printing must never fail because dynamic translation is unavailable.
    }
  }

  await Future.wait([
    addDynamicArabic(invoice.workshopName),
    addDynamicArabic(invoice.branchName),
    addDynamicArabic(invoice.branchAddress),
    addDynamicArabic(invoice.workshopAddress),
    addDynamicArabic(invoice.cashierName),
    addDynamicArabic(invoice.customerName),
    addDynamicArabic(invoice.thermalDisplayedCustomerType),
    addDynamicArabic(invoice.vehicleInfo),
    addDynamicArabic(invoice.vehicleMake),
    addDynamicArabic(invoice.vehicleModel),
    for (final item in invoice.items) addDynamicArabic(item.productName),
    for (final dept in invoice.departments)
      for (final item in dept.items) addDynamicArabic(item.productName),
  ]);

  final doc = buildThermalInvoicePdfDocument(
    invoice: invoice,
    paymentMethodText: paymentMethodText,
    filterLogoPngBytes: logoBytes,
    font: font,
    fontBold: fontBold,
    fontArabic: fontArabic,
    maintenanceChecksFallback: maintenanceChecksFallback,
    dynamicArabicValues: dynamicArabicValues,
  );
  return doc.save();
}