import '../models/create_invoice_model.dart';

double thermalR2(double v) => (v * 100).roundToDouble() / 100;

/// Shared totals logic for ESC/POS, on-screen thermal preview, and PDF.
class ThermalInvoiceTotals {
  final double grossAmountExclVat;
  final double itemDiscountsTotal;
  final double invoiceDiscount;
  final double promoDiscount;
  final double totalDiscountLine;
  final double grossExVatBeforeDiscount;
  final double totalTaxableAmount;
  final double vatAmount;
  final double totalInvoiceAmount;

  ThermalInvoiceTotals({
    required this.grossAmountExclVat,
    required this.itemDiscountsTotal,
    required this.invoiceDiscount,
    required this.promoDiscount,
    required this.totalDiscountLine,
    required this.grossExVatBeforeDiscount,
    required this.totalTaxableAmount,
    required this.vatAmount,
    required this.totalInvoiceAmount,
  });
}

void accumulateInvoiceItems(Invoice invoice, void Function(InvoiceItem) emit) {
  if (invoice.departments.isNotEmpty) {
    for (final dept in invoice.departments) {
      for (final item in dept.items) {
        emit(item);
      }
    }
  } else {
    for (final item in invoice.items) {
      emit(item);
    }
  }
}

ThermalInvoiceTotals computeThermalInvoiceTotals(Invoice invoice) {
  double grossAmountExclVat = 0;
  double itemDiscountsTotal = 0;

  accumulateInvoiceItems(invoice, (InvoiceItem item) {
    final unitExcl = thermalR2(item.unitPrice / 1.15);
    final gross = thermalR2(unitExcl * item.qty);
    var disc = 0.0;
    if (item.discountType == 'percent' || item.discountType == 'percentage') {
      disc = thermalR2(gross * ((item.discountValue ?? 0) / 100));
    } else if ((item.discountValue ?? 0) > 0) {
      disc = item.discountValue ?? 0;
    }
    grossAmountExclVat += gross;
    itemDiscountsTotal += disc;
  });

  double invoiceDiscount = 0;
  double promoDiscount = 0;
  if (invoice.departments.isNotEmpty) {
    for (final dept in invoice.departments) {
      final afterLine = dept.amountAfterDiscount > 0
          ? dept.amountAfterDiscount
          : (grossAmountExclVat - itemDiscountsTotal);
      if (dept.totalDiscountType == 'percent' ||
          dept.totalDiscountType == 'percentage') {
        invoiceDiscount +=
            thermalR2(afterLine * (dept.totalDiscountValue / 100));
      } else {
        invoiceDiscount += dept.totalDiscountValue;
      }
      promoDiscount += dept.promoDiscountAmount;
    }
  }

  var totalDiscountLine = thermalR2(
    itemDiscountsTotal + invoiceDiscount + promoDiscount,
  );
  if (invoice.discountAmount > 0.001) {
    totalDiscountLine = thermalR2(invoice.discountAmount);
  }

  var totalTaxableAmount = thermalR2(grossAmountExclVat -
      itemDiscountsTotal -
      invoiceDiscount -
      promoDiscount);
  var vatAmount = thermalR2(totalTaxableAmount * 0.15);
  var totalInvoiceAmount = thermalR2(totalTaxableAmount + vatAmount);

  if (invoice.subtotal > 0.001) {
    totalTaxableAmount = thermalR2(invoice.subtotal);
  }
  if (invoice.vatAmount > 0.001) {
    vatAmount = thermalR2(invoice.vatAmount);
  }
  if (invoice.totalAmount > 0.001) {
    totalInvoiceAmount = thermalR2(invoice.totalAmount);
  }

  final grossExVatBeforeDiscount = grossAmountExclVat > 0.001
      ? grossAmountExclVat
      : thermalR2(totalTaxableAmount + totalDiscountLine);

  return ThermalInvoiceTotals(
    grossAmountExclVat: grossAmountExclVat,
    itemDiscountsTotal: itemDiscountsTotal,
    invoiceDiscount: invoiceDiscount,
    promoDiscount: promoDiscount,
    totalDiscountLine: totalDiscountLine,
    grossExVatBeforeDiscount: grossExVatBeforeDiscount,
    totalTaxableAmount: totalTaxableAmount,
    vatAmount: vatAmount,
    totalInvoiceAmount: totalInvoiceAmount,
  );
}

/// Line breakdown for detailed goods table (dialog preview only).
class ThermalInvoiceLineRow {
  final String productName;
  final double unitPriceExclVat;
  final double qty;
  final double grossBeforeVat;
  final double discount;
  final double totalBeforeVat;
  final double lineVat;
  final double totalWithVat;

  ThermalInvoiceLineRow({
    required this.productName,
    required this.unitPriceExclVat,
    required this.qty,
    required this.grossBeforeVat,
    required this.discount,
    required this.totalBeforeVat,
    required this.lineVat,
    required this.totalWithVat,
  });
}

List<ThermalInvoiceLineRow> computeThermalInvoiceLineRows(Invoice invoice) {
  final rows = <ThermalInvoiceLineRow>[];
  accumulateInvoiceItems(invoice, (InvoiceItem item) {
    final unitExcl = thermalR2(item.unitPrice / 1.15);
    final gross = thermalR2(unitExcl * item.qty);
    var disc = 0.0;
    if (item.discountType == 'percent' ||
        item.discountType == 'percentage') {
      disc = thermalR2(gross * ((item.discountValue ?? 0) / 100));
    } else if ((item.discountValue ?? 0) > 0) {
      disc = thermalR2(item.discountValue ?? 0);
    }
    final totalBeforeVat = thermalR2(gross - disc);
    final lineVat = thermalR2(totalBeforeVat * 0.15);
    final totalWithVat = thermalR2(totalBeforeVat + lineVat);
    rows.add(
      ThermalInvoiceLineRow(
        productName: item.productName,
        unitPriceExclVat: unitExcl,
        qty: item.qty,
        grossBeforeVat: gross,
        discount: disc,
        totalBeforeVat: totalBeforeVat,
        lineVat: lineVat,
        totalWithVat: totalWithVat,
      ),
    );
  });
  return rows;
}

/// Some QR backends (PDF [BarcodeWidget], printer firmware) only accept ASCII /
/// latin-1 subsets; strip/replace typography like em‑dash (“—”) before encoding.
String asciiSafeBarcodeQrData(String data) => data
    .replaceAll('\u2014', '-') // em dash
    .replaceAll('\u2013', '-') // en dash
    .replaceAll(RegExp(r'[^\x20-\x7E]'), '');

String thermalInvoiceQrPayload(Invoice invoice, double totalWithVat) {
  final raw =
      'INV:${invoice.invoiceNo},ID:${invoice.id},TOTAL:${totalWithVat.toStringAsFixed(2)}';
  return asciiSafeBarcodeQrData(raw);
}

/// Filter logo bundled under pubspec `assets/images/`.
const String kThermalInvoiceLogoAsset = 'assets/images/icon.png';
