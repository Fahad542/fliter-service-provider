import '../models/create_invoice_model.dart';
import 'invoice_thermal_escpos.dart';
import 'network_thermal_printer.dart';
import 'thermal_printer_settings.dart';

Future<void> executeInvoiceThermalPrint({
  required Invoice invoice,
  required String paymentMethodText,
}) async {
  final cfg = await ThermalPrinterSettings.load();
  final bytes = await buildInvoiceEscPosBytes(
    invoice: invoice,
    paymentMethodText: paymentMethodText,
  );
  await sendEscPosBytesToTcpPrinter(
    host: cfg.host,
    port: cfg.port,
    bytes: bytes,
  );
}
