import 'dart:typed_data';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:image/image.dart' as img;
import 'package:printing/printing.dart';

import '../models/create_invoice_model.dart';
import '../widgets/thermal_invoice_pdf.dart';

/// Target raster width for 80 mm ESC/POS (double density, `Generator.image`).
const int kThermalPdfRasterPrintWidthPx = 576;

/// Max height per ESC/POS bitmap strip (avoids oversized single buffers).
const int kThermalPdfRasterStripMaxHeightPx = 2048;

/// Rasterize any **80 mm roll** PDF and emit ESC/POS image strips + cut.
Future<List<int>> buildEscPosBytesFromPdfRaster(Uint8List pdfBytes) async {
  final profile = await CapabilityProfile.load(name: 'default');
  final g = Generator(PaperSize.mm80, profile);
  var bytes = <int>[];
  bytes += g.reset();

  final rasterPages = await Printing.raster(
    pdfBytes,
    dpi: 203.0,
  ).toList();

  if (rasterPages.isEmpty) {
    throw StateError(
      'Thermal PDF could not be rasterized (no pages). '
      'Confirm the printing plugin supports raster on this platform.',
    );
  }

  for (final raster in rasterPages) {
    final pngBytes = await raster.toPng();
    var image = img.decodeImage(pngBytes);
    if (image == null) {
      throw StateError(
        'Failed to decode rasterized thermal PDF for network printing.',
      );
    }

    if (image.width != kThermalPdfRasterPrintWidthPx) {
      image = img.copyResize(
        image,
        width: kThermalPdfRasterPrintWidthPx,
        interpolation: img.Interpolation.linear,
      );
    }

    var y = 0;
    while (y < image.height) {
      final remaining = image.height - y;
      final stripH = remaining > kThermalPdfRasterStripMaxHeightPx
          ? kThermalPdfRasterStripMaxHeightPx
          : remaining;
      final strip = img.copyCrop(
        image,
        x: 0,
        y: y,
        width: image.width,
        height: stripH,
      );
      bytes += g.image(strip, align: PosAlign.center);
      y += stripH;
      if (y < image.height) {
        bytes += g.feed(1);
      }
    }
    bytes += g.feed(1);
  }

  bytes += g.cut(mode: PosCutMode.full);
  return bytes;
}

/// Invoice thermal PDF → ESC/POS (same bytes as **Done** preview).
Future<List<int>> buildInvoiceEscPosBytesFromThermalPdfRaster({
  required Invoice invoice,
  required String paymentMethodText,
  List<bool>? maintenanceChecksFallback,
}) async {
  final pdfBytes = await buildThermalInvoicePdfBytes(
    invoice: invoice,
    paymentMethodText: paymentMethodText,
    maintenanceChecksFallback: maintenanceChecksFallback,
  );
  return buildEscPosBytesFromPdfRaster(pdfBytes);
}
