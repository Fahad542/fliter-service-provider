import '../models/create_invoice_model.dart';

Future<void> executeInvoiceThermalPrint({
  required Invoice invoice,
  required String paymentMethodText,
}) async {
  throw UnsupportedError(
    'Wi‑Fi thermal printing needs Android, iOS, or desktop — not supported on web.',
  );
}
