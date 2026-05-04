import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/store_closing_model.dart';
import '../utils/thermal_invoice_totals.dart' show kThermalInvoiceLogoAsset;
import '../utils/thermal_receipt_logo_preprocess.dart';
import '../utils/thermal_safe_text.dart';

bool _hasArabicScript(String s) =>
    RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]').hasMatch(s);

Future<({pw.Font font, pw.Font fontBold})> _loadPoppinsPair() async {
  for (var attempt = 0; attempt < 2; attempt++) {
    try {
      final font = await PdfGoogleFonts.poppinsRegular();
      final fontBold = await PdfGoogleFonts.poppinsBold();
      return (font: font, fontBold: fontBold);
    } catch (_) {
      if (attempt == 0) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }
    }
  }
  return (font: pw.Font.helvetica(), fontBold: pw.Font.helveticaBold());
}

Future<pw.Font> _loadArabicFont(pw.Font fallbackBold) async {
  try {
    return await PdfGoogleFonts.almaraiBold();
  } catch (_) {
    try {
      return await PdfGoogleFonts.cairoBold();
    } catch (_) {
      return fallbackBold;
    }
  }
}

pw.Document buildThermalStoreClosingPdfDocument({
  required StoreClosingReport report,
  String? closingId,
  Uint8List? filterLogoPngBytes,
  required pw.Font font,
  required pw.Font fontBold,
  required pw.Font fontArabic,
}) {
  // Fixed English month names so raster text never depends on device locale.
  final dateStr = DateFormat('dd MMM, yyyy hh:mm a', 'en_US')
      .format(report.timestamp.toLocal());
  const fs = 7.0;
  const fsBold = 7.6;
  const titleFs = 10.0;
  const tableHdr = 6.9;

  pw.TextStyle ts({bool bold = false, double? size}) => pw.TextStyle(
        font: bold ? fontBold : font,
        fontSize: size ?? fs,
      );

  pw.Widget metaLine(String label, String raw) {
    final v = pdfStripBidiAndInvisible(raw.trim());
    if (v.isEmpty) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 3),
        child: pw.Text('$label: —', style: ts()),
      );
    }
    if (_hasArabicScript(v)) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 4),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Text('$label:', style: ts(bold: true, size: fsBold)),
            pw.SizedBox(height: 2),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                v,
                style: pw.TextStyle(font: fontArabic, fontSize: fsBold),
                textDirection: pw.TextDirection.rtl,
                textAlign: pw.TextAlign.right,
                maxLines: 5,
                softWrap: true,
              ),
            ),
          ],
        ),
      );
    }
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Text(
        '$label: $v',
        style: ts(),
        maxLines: 4,
        softWrap: true,
      ),
    );
  }

  pw.Widget cell(
    String text, {
    pw.TextAlign align = pw.TextAlign.left,
    bool bold = false,
    double? size,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 3.5),
      child: pw.Text(
        thermalSafeText(text),
        style: ts(bold: bold, size: size),
        textAlign: align,
        maxLines: 3,
        softWrap: true,
      ),
    );
  }

  pw.TableRow dataRow(String cat, double sys, double phy, double diff) {
    final dStr =
        diff >= 0 ? '+${diff.toStringAsFixed(2)}' : diff.toStringAsFixed(2);
    return pw.TableRow(
      children: [
        cell(cat, size: fs - 0.15),
        cell(sys.toStringAsFixed(2), align: pw.TextAlign.right),
        cell(phy.toStringAsFixed(2), align: pw.TextAlign.right),
        cell(dStr, align: pw.TextAlign.right, bold: true),
      ],
    );
  }

  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat(
        80 * PdfPageFormat.mm,
        double.infinity,
        marginLeft: 4.5 * PdfPageFormat.mm,
        marginRight: 4.5 * PdfPageFormat.mm,
        marginTop: 5 * PdfPageFormat.mm,
        marginBottom: 6 * PdfPageFormat.mm,
      ),
      textDirection: pw.TextDirection.ltr,
      build: (ctx) {
        final kids = <pw.Widget>[];

        if (filterLogoPngBytes != null && filterLogoPngBytes.isNotEmpty) {
          kids.add(
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Image(
                  pw.MemoryImage(filterLogoPngBytes),
                  height: 24,
                  fit: pw.BoxFit.contain,
                ),
              ),
            ),
          );
        }

        kids.addAll([
          pw.Center(
            child: pw.Text(
              thermalSafeText('STORE CLOSING REPORT'),
              style: pw.TextStyle(font: fontBold, fontSize: titleFs),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.SizedBox(height: 7),
          metaLine('Branch', report.branch),
          metaLine('Cashier', report.cashierName),
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 3),
            child: pw.Text('Date: $dateStr', style: ts()),
          ),
          if (closingId != null && closingId.trim().isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 2),
              child: pw.Text(
                'Closing ID: ${thermalSafeText(closingId.trim())}',
                style: ts(),
              ),
            ),
          pw.SizedBox(height: 5),
          pw.Divider(thickness: 0.55, color: PdfColors.grey700),
          pw.SizedBox(height: 5),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey500, width: 0.4),
            columnWidths: const {
              0: pw.FlexColumnWidth(2.28),
              1: pw.FlexColumnWidth(1.12),
              2: pw.FlexColumnWidth(1.12),
              3: pw.FlexColumnWidth(1.12),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  cell('Category', bold: true, size: tableHdr),
                  cell(
                    report.salesReturnsTotal > 0.001
                        ? 'System\n(gross)'
                        : 'System',
                    align: pw.TextAlign.right,
                    bold: true,
                    size: tableHdr,
                  ),
                  cell('Phys.',
                      align: pw.TextAlign.right, bold: true, size: tableHdr),
                  cell(
                    report.salesReturnsTotal > 0.001 ? 'Diff\n(net)' : 'Diff',
                    align: pw.TextAlign.right,
                    bold: true,
                    size: tableHdr,
                  ),
                ],
              ),
              dataRow(
                  'Cash', report.systemCashGross, report.physicalCash, report.cashDiff),
              dataRow('Bank/Cards', report.systemBankGross, report.physicalBank,
                  report.bankDiff),
              dataRow('Corporate', report.systemCorporateGross,
                  report.physicalCorporate, report.corporateDiff),
              dataRow('Tamara', report.systemTamaraGross, report.physicalTamara,
                  report.tamaraDiff),
              dataRow('Tabby', report.systemTabbyGross, report.physicalTabby,
                  report.tabbyDiff),
              dataRow('Others', report.systemOthersGross, report.physicalOthers,
                  report.othersDiff),
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  cell('Total', bold: true, size: fsBold),
                  cell(
                    report.systemBucketsSumGross.toStringAsFixed(2),
                    align: pw.TextAlign.right,
                    bold: true,
                    size: fsBold,
                  ),
                  cell(
                    report.physicalTotal.toStringAsFixed(2),
                    align: pw.TextAlign.right,
                    bold: true,
                    size: fsBold,
                  ),
                  cell(
                    (report.diffBucketsSum >= 0 ? '+' : '') +
                        report.diffBucketsSum.toStringAsFixed(2),
                    align: pw.TextAlign.right,
                    bold: true,
                    size: fsBold,
                  ),
                ],
              ),
            ],
          ),
        ]);

        if (report.salesReturnsTotal > 0.001) {
          kids.addAll([
            pw.SizedBox(height: 6),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey300,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      thermalSafeText('Less: Total sales return'),
                      style: pw.TextStyle(font: fontBold, fontSize: fsBold + 0.6),
                      softWrap: true,
                    ),
                  ),
                  pw.Text(
                    thermalSafeText(
                      '- SAR ${report.salesReturnsTotal.toStringAsFixed(2)}',
                    ),
                    style: pw.TextStyle(font: fontBold, fontSize: fsBold + 0.6),
                    textAlign: pw.TextAlign.right,
                  ),
                ],
              ),
            ),
          ]);
        }

        kids.addAll([
          pw.SizedBox(height: 7),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey300,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Text(
                    thermalSafeText('Grand Total'),
                    style: pw.TextStyle(font: fontBold, fontSize: fsBold + 0.6),
                  ),
                ),
                pw.Text(
                  thermalSafeText(
                      'SAR ${report.systemSales.toStringAsFixed(2)}'),
                  style: pw.TextStyle(font: fontBold, fontSize: fsBold + 0.6),
                  textAlign: pw.TextAlign.right,
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 9),
          pw.Center(
            child: pw.Text(
              thermalSafeText('Thank you'),
              style: pw.TextStyle(font: fontBold, fontSize: 7.5),
            ),
          ),
        ]);

        return pw.DefaultTextStyle(
          style: pw.TextStyle(font: font, fontSize: fs),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: kids,
          ),
        );
      },
    ),
  );

  return pdf;
}

Future<Uint8List> buildThermalStoreClosingPdfBytes({
  required StoreClosingReport report,
  String? closingId,
}) async {
  Uint8List? logoBytes;
  try {
    final data = await rootBundle.load(kThermalInvoiceLogoAsset);
    final raw = data.buffer.asUint8List();
    logoBytes =
        preprocessThermalReceiptLogoPng(raw, targetMaxWidth: 200) ?? raw;
  } catch (_) {
    logoBytes = null;
  }

  final poppins = await _loadPoppinsPair();
  final fontArabic = await _loadArabicFont(poppins.fontBold);

  final doc = buildThermalStoreClosingPdfDocument(
    report: report,
    closingId: closingId,
    filterLogoPngBytes: logoBytes,
    font: poppins.font,
    fontBold: poppins.fontBold,
    fontArabic: fontArabic,
  );
  return doc.save();
}
