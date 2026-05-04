import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/create_invoice_model.dart';
import '../utils/app_formatters.dart';
import '../utils/invoice_maintenance_checklist.dart';
import '../utils/thermal_invoice_totals.dart';

const double kThermalPaperWidth = 380;

String paymentMethodLabelAr(String method) {
  final m = method.trim().toLowerCase();
  if (m.contains('card')) return 'الدفع عن طريق البطاقة';
  if (m.contains('cash')) return 'الدفع نقدًا';
  if (m.contains('bank')) return 'تحويل بنكي';
  return method;
}

Widget thermalDashedRule() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Text(
      List.filled(42, '─').join(),
      maxLines: 1,
      overflow: TextOverflow.clip,
      style: TextStyle(
        fontSize: 9,
        height: 1,
        color: Colors.grey.shade600,
        letterSpacing: 0,
      ),
    ),
  );
}

/// On-screen thermal-style simplified tax invoice (bilingual shell; line names follow API).
class ThermalInvoiceReceipt extends StatelessWidget {
  final Invoice invoice;
  final String paymentMethodText;

  const ThermalInvoiceReceipt({
    super.key,
    required this.invoice,
    required this.paymentMethodText,
  });

  @override
  Widget build(BuildContext context) {
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

    const headEn = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w900,
      color: Color(0xFF111111),
      height: 1.2,
    );
    const headAr = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w800,
      height: 1.3,
    );
    final body = TextStyle(
      fontSize: 10.5,
      height: 1.25,
      color: Colors.grey.shade900,
      fontWeight: FontWeight.w500,
    );
    final bodyBold = body.copyWith(fontWeight: FontWeight.w800);

    Widget cText(String s, TextStyle style, [TextAlign ta = TextAlign.center]) {
      return Text(s, textAlign: ta, style: style);
    }

    return Container(
      width: kThermalPaperWidth,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black87, width: 0.8),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Image.asset(
              kThermalInvoiceLogoAsset,
              height: 52,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 8),
          cText('Simplified Tax Invoice', headEn),
          cText(
            'فاتورة ضريبية مبسطة',
            headAr.copyWith(color: Colors.grey.shade900),
          ),
          const SizedBox(height: 6),
          cText(seller, headEn.copyWith(fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child:
                    Text('Branch:\n${invoice.branchName ?? '-'}', style: body),
              ),
              Expanded(
                child: Text(
                  'فرع :\n${invoice.branchName ?? '-'}',
                  style: body.copyWith(height: 1.2),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Address:\n${addr.isEmpty ? '-' : addr}',
            style: body,
          ),
          Text(
            'عنوان :\n${addr.isEmpty ? '-' : addr}',
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: body,
          ),
          const SizedBox(height: 4),
          Text(
            'VAT Number: ${vatNo.isEmpty ? '-' : vatNo}',
            style: bodyBold,
          ),
          Text(
            'الرقم الضريبي : ${vatNo.isEmpty ? '-' : vatNo}',
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: bodyBold,
          ),
          const SizedBox(height: 4),
          Text('Invoice No: ${invoice.invoiceNo}', style: bodyBold),
          Text(
            'رقم الفاتورة : ${invoice.invoiceNo}',
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: bodyBold,
          ),
          thermalDashedRule(),
          Text('Date: $issued', style: body),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Counter:\n${invoice.branchName ?? '-'}',
                  style: body,
                ),
              ),
              Expanded(
                child: Text(
                  'Cashier:\n${invoice.cashierName ?? '-'}',
                  style: body,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          thermalDashedRule(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Text('Item\nالصنف', style: bodyBold),
              ),
              SizedBox(
                width: 28,
                child: Text(
                  'Qty\nعدد',
                  style: bodyBold,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'Unit Price\nسعر الوحدة',
                  style: bodyBold,
                  textAlign: TextAlign.right,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'Total\nالإجمالي',
                  style: bodyBold,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          thermalDashedRule(),
          ..._itemRows(body),
          thermalDashedRule(),
          _moneyRow(
            'Total (Excluding VAT)',
            t.grossExVatBeforeDiscount,
            bodyBold,
          ),
          _moneyRow('Discount', t.totalDiscountLine, body),
          _moneyRow(
            'Total Taxable Amount (Excl. VAT)',
            t.totalTaxableAmount,
            body,
          ),
          _moneyRow('Total VAT (15%)', t.vatAmount, body),
          _moneyRow(
            'Total Amount Due',
            t.totalInvoiceAmount,
            bodyBold.copyWith(fontSize: 11),
            emphasize: true,
          ),
          const SizedBox(height: 6),
          Text(
            'Payment: $paymentMethodText — ${t.totalInvoiceAmount.toStringAsFixed(2)} SR',
            style: bodyBold,
          ),
          Text(
            '${paymentMethodLabelAr(paymentMethodText)} : ${t.totalInvoiceAmount.toStringAsFixed(2)} ريال',
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: bodyBold,
          ),
          if (invoice.odometerReading != null &&
              invoice.odometerReading! > 0) ...[
            thermalDashedRule(),
            Text(
              'Next Oil Change / Odometer: ${invoice.odometerReading}',
              style: body,
            ),
            Text(
              'التغيير القادم / العداد : ${invoice.odometerReading}',
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: body,
            ),
          ],
          thermalDashedRule(),
          cText('CUSTOMER DETAILS', bodyBold.copyWith(fontSize: 11)),
          cText('************', body.copyWith(letterSpacing: 2)),
          const SizedBox(height: 4),
          Text('Name: ${invoice.customerName}', style: body),
          Text('Mobile: ${invoice.customerMobile ?? '-'}', style: body),
          Text(
            'Vehicle No: ${invoice.plateNo.isNotEmpty ? invoice.plateNo : '-'}',
            style: body,
          ),
          Text('Odometer: ${invoice.odometerReading ?? '-'}', style: body),
          thermalDashedRule(),
          Center(
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 132,
              gapless: true,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          if (invoice.maintenanceChecklistChecks != null &&
              invoice.maintenanceChecklistChecks!.length ==
                  InvoiceMaintenanceChecklist.rows.length &&
              invoice.maintenanceChecklistChecks!.any((v) => v)) ...[
            thermalDashedRule(),
            cText('Maintenance checklist', bodyBold.copyWith(fontSize: 11)),
            const SizedBox(height: 4),
            for (var i = 0; i < InvoiceMaintenanceChecklist.rows.length; i++)
              if (invoice.maintenanceChecklistChecks![i])
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '☑ ${InvoiceMaintenanceChecklist.rows[i].en}',
                        style: body,
                      ),
                      Text(
                        InvoiceMaintenanceChecklist.rows[i].ar,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: body.copyWith(
                          fontSize: 9,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
          ],
          const SizedBox(height: 8),
          cText(
            'Thank you — شكراً لزيارتكم',
            body.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }

  List<Widget> _itemRows(TextStyle body) {
    final out = <Widget>[];
    accumulateInvoiceItems(invoice, (item) {
      final qty = item.qty % 1 == 0
          ? '${item.qty.toInt()}'
          : item.qty.toStringAsFixed(2);
      final unit = item.qty > 0.0001
          ? thermalR2(item.lineTotal / item.qty)
          : thermalR2(item.unitPrice);
      final total = thermalR2(item.lineTotal);
      out.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                item.productName.toUpperCase(),
                style: body.copyWith(fontWeight: FontWeight.w700, fontSize: 10),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      item.productName,
                      style: body.copyWith(
                        fontSize: 9,
                        color: Colors.grey.shade700,
                      ),
                      textDirection: TextDirection.rtl,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    width: 28,
                    child: Text(qty, style: body, textAlign: TextAlign.center),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      unit.toStringAsFixed(2),
                      style: body,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      '${total.toStringAsFixed(2)} SR',
                      style: body.copyWith(fontWeight: FontWeight.w700),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
    return out;
  }

  Widget _moneyRow(
    String label,
    double value,
    TextStyle style, {
    bool emphasize = false,
  }) {
    final vStr = '${value.toStringAsFixed(2)} SR';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style:
                  emphasize ? style.copyWith(fontWeight: FontWeight.w900) : style,
            ),
          ),
          Text(
            vStr,
            style: emphasize
                ? style.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0D47A1),
                  )
                : style.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
