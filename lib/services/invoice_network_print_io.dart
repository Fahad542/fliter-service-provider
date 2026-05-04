import '../models/create_invoice_model.dart';
import '../models/store_closing_model.dart';
import '../widgets/thermal_store_closing_pdf.dart';
import 'invoice_thermal_pdf_raster_escpos.dart';
import 'network_thermal_printer.dart';
import 'thermal_printer_settings.dart';

/// Sends the same visual receipt as **Done** (thermal PDF), rasterized for ESC/POS.
Future<void> executeInvoiceThermalPrint({
  required Invoice invoice,
  required String paymentMethodText,
  List<bool>? maintenanceChecksFallback,
}) async {
  final cfg = await ThermalPrinterSettings.load();
  final bytes = await buildInvoiceEscPosBytesFromThermalPdfRaster(
    invoice: invoice,
    paymentMethodText: paymentMethodText,
    maintenanceChecksFallback: maintenanceChecksFallback,
  );
  await sendEscPosBytesToTcpPrinter(
    host: cfg.host,
    port: cfg.port,
    bytes: bytes,
  );
}

/// Store closing **80 mm** thermal PDF → same Wi‑Fi raster pipeline as invoices.
Future<void> executeStoreClosingThermalPrint({
  required StoreClosingReport report,
  String? closingId,
}) async {
  final cfg = await ThermalPrinterSettings.load();
  final pdfBytes = await buildThermalStoreClosingPdfBytes(
    report: report,
    closingId: closingId,
  );
  final bytes = await buildEscPosBytesFromPdfRaster(pdfBytes);
  await sendEscPosBytesToTcpPrinter(
    host: cfg.host,
    port: cfg.port,
    bytes: bytes,
  );
}
