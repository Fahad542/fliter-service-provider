import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/create_invoice_model.dart';
import '../utils/app_formatters.dart';
import '../utils/thermal_invoice_totals.dart';

/// Narrow roll-style PDF (~80 mm) for system print preview / AirPrint.
pw.Document buildThermalInvoicePdfDocument({
  required Invoice invoice,
  required String paymentMethodText,
  Uint8List? filterLogoPngBytes,
}) {
  final t = computeThermalInvoiceTotals(invoice);
  final qrData = thermalInvoiceQrPayload(invoice, t.totalInvoiceAmount);
  final issued = formatInvoiceIssuedAtDateTime(invoice.issuedAt) ??
      formatInvoiceLegalDate(invoice.invoiceDate);
  final seller =
      (invoice.workshopName ?? invoice.branchName ?? 'Filter Car Services')
          .trim();
  final vatNo = (invoice.branchVatId ?? invoice.workshopTaxId ?? '').trim();
  final addr =
      (invoice.branchAddress ?? invoice.workshopAddress ?? '').trim();

  pw.Font font = pw.Font.helvetica();
  pw.Font fontBold = pw.Font.helveticaBold();

  final pdf = pw.Document();

  pw.Widget dashed() => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 6),
        child: pw.Text(
          List.filled(36, '-').join(),
          style: pw.TextStyle(font: font, fontSize: 7, color: PdfColors.grey600),
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
        pw.SizedBox(width: 26, child: w2),
        pw.Expanded(flex: 3, child: w3),
        pw.Expanded(flex: 3, child: w4),
      ],
    );
  }

  final itemBlocks = <pw.Widget>[];
  accumulateInvoiceItems(invoice, (item) {
    final qty = item.qty % 1 == 0
        ? '${item.qty.toInt()}'
        : item.qty.toStringAsFixed(2);
    final unit = item.qty > 0.0001
        ? thermalR2(item.lineTotal / item.qty)
        : thermalR2(item.unitPrice);
    final total = thermalR2(item.lineTotal);
    itemBlocks.add(
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Text(
              item.productName.toUpperCase(),
              style:
                  pw.TextStyle(font: fontBold, fontSize: 8.5),
              maxLines: 3,
            ),
            pw.SizedBox(height: 2),
            row4(
              pw.Text(
                item.productName,
                style: pw.TextStyle(font: font, fontSize: 7.5),
                textDirection: pw.TextDirection.rtl,
              ),
              pw.Center(
                child: pw.Text(qty,
                    style: pw.TextStyle(font: font, fontSize: 8)),
              ),
              pw.Text(unit.toStringAsFixed(2),
                  style: pw.TextStyle(font: font, fontSize: 8),
                  textAlign: pw.TextAlign.right),
              pw.Text('${total.toStringAsFixed(2)} SR',
                  style: pw.TextStyle(font: fontBold, fontSize: 8),
                  textAlign: pw.TextAlign.right),
            ),
          ],
        ),
      ),
    );
  });

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat(80 * PdfPageFormat.mm, double.infinity,
          marginAll: 6 * PdfPageFormat.mm),
      build: (ctx) {
        return pw.DefaultTextStyle(
          style: pw.TextStyle(font: font, fontSize: 8),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              if (filterLogoPngBytes != null && filterLogoPngBytes.isNotEmpty)
                pw.Center(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 8),
                    child: pw.Image(
                      pw.MemoryImage(filterLogoPngBytes),
                      height: 44,
                      fit: pw.BoxFit.contain,
                    ),
                  ),
                ),
              pw.Center(
                child: pw.Text(
                  'Simplified Tax Invoice',
                  style: pw.TextStyle(font: fontBold, fontSize: 11),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'فاتورة ضريبية مبسطة',
                  style: pw.TextStyle(font: fontBold, fontSize: 10),
                  textDirection: pw.TextDirection.rtl,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Center(
                child: pw.Text(seller,
                    style: pw.TextStyle(font: fontBold, fontSize: 10)),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Branch: ${invoice.branchName ?? '-'}\n'
                'VAT: ${vatNo.isEmpty ? '-' : vatNo}\n'
                'Address: ${addr.isEmpty ? '-' : addr}\n'
                'Invoice No: ${invoice.invoiceNo}\n'
                'Date: $issued\n'
                'Counter: ${invoice.branchName ?? '-'}\t\tCashier: ${invoice.cashierName ?? '-'}',
              ),
              dashed(),
              row4(
                pw.Text(
                  'Item / الصنف',
                  style: pw.TextStyle(font: fontBold, fontSize: 8),
                ),
                pw.Center(
                  child: pw.Text('Qty',
                      style: pw.TextStyle(font: fontBold, fontSize: 7)),
                ),
                pw.Text('Unit',
                    style: pw.TextStyle(font: fontBold, fontSize: 7),
                    textAlign: pw.TextAlign.right),
                pw.Text('Total',
                    style: pw.TextStyle(font: fontBold, fontSize: 7),
                    textAlign: pw.TextAlign.right),
              ),
              dashed(),
              ...itemBlocks,
              dashed(),
              pw.Text(
                'Total (Excl VAT): ${t.grossExVatBeforeDiscount.toStringAsFixed(2)} SR',
                style: pw.TextStyle(font: fontBold, fontSize: 8),
              ),
              pw.Text(
                'Discount: ${t.totalDiscountLine.toStringAsFixed(2)} SR',
              ),
              pw.Text(
                'Taxable (Excl VAT): ${t.totalTaxableAmount.toStringAsFixed(2)} SR',
              ),
              pw.Text(
                'VAT 15%: ${t.vatAmount.toStringAsFixed(2)} SR',
              ),
              pw.Text(
                'Total Due: ${t.totalInvoiceAmount.toStringAsFixed(2)} SR',
                style: pw.TextStyle(font: fontBold, fontSize: 9),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Payment: $paymentMethodText',
                style: pw.TextStyle(font: fontBold, fontSize: 8),
              ),
              dashed(),
              pw.Text(
                'CUSTOMER DETAILS — بيانات العميل\n'
                'Name: ${invoice.customerName}\n'
                'Mobile: ${invoice.customerMobile ?? '-'}\n'
                'Vehicle: ${invoice.plateNo.isNotEmpty ? invoice.plateNo : '-'}\n'
                'Odometer: ${invoice.odometerReading ?? '-'}',
              ),
              dashed(),
              pw.Center(
                child: pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: qrData,
                  width: 120,
                  height: 120,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Center(
                child: pw.Text('Thank you',
                    style: pw.TextStyle(font: fontBold, fontSize: 9)),
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
}) async {
  Uint8List? logoBytes;
  try {
    final data = await rootBundle.load(kThermalInvoiceLogoAsset);
    logoBytes = data.buffer.asUint8List();
  } catch (_) {
    logoBytes = null;
  }

  final doc = buildThermalInvoicePdfDocument(
    invoice: invoice,
    paymentMethodText: paymentMethodText,
    filterLogoPngBytes: logoBytes,
  );
  return doc.save();
}
