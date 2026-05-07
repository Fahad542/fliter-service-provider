import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Captures the colourful [CashierInvoicePreview] subtree (wrapped in [RepaintBoundary])
/// exactly as rendered on screen, embeds lossless PNG in a single-page PDF for WhatsApp.
abstract final class InvoicePreviewCapturePdf {
  /// Raster → PDF sized to logical layout (~96 DPI → pt). Returns `null` if the key has
  /// no rendereable boundary (e.g. dialog not laid out yet).
  static Future<Uint8List?> repaintBoundaryKeyToPdf({
    required GlobalKey repaintBoundaryKey,
    BuildContext? context,
    double? pixelRatio,
  }) async {
    final ctxForMq = context ?? repaintBoundaryKey.currentContext;
    final prRaw = pixelRatio ??
        (ctxForMq != null
            ? MediaQuery.maybeOf(ctxForMq)?.devicePixelRatio
            : null) ??
        3.25;
    final pr = prRaw.clamp(2.25, 4.0).toDouble();

    await Future<void>.delayed(const Duration(milliseconds: 72));
    await WidgetsBinding.instance.endOfFrame;
    await Future<void>.delayed(Duration.zero);

    final ro = repaintBoundaryKey.currentContext?.findRenderObject();
    if (ro is! RenderRepaintBoundary) {
      debugPrint('[InvoicePreviewCapturePdf] Missing RenderRepaintBoundary');
      return null;
    }

    final boundary = ro;
    if (!boundary.hasSize || boundary.size.isEmpty) {
      debugPrint('[InvoicePreviewCapturePdf] Boundary has no size yet');
      return null;
    }

    ui.Image? uiImg;
    try {
      uiImg = await boundary.toImage(pixelRatio: pr);
    } catch (e, st) {
      debugPrint('[InvoicePreviewCapturePdf] toImage failed: $e\n$st');
      return null;
    }

    late final Uint8List pngBytes;
    try {
      final bd = await uiImg.toByteData(format: ui.ImageByteFormat.png);
      if (bd == null) return null;
      pngBytes = bd.buffer.asUint8List();
    } catch (e, st) {
      debugPrint('[InvoicePreviewCapturePdf] PNG encode failed: $e\n$st');
      return null;
    } finally {
      uiImg.dispose();
    }

    final lw = boundary.size.width;
    final lh = boundary.size.height;
    final wPt = lw * 72 / 96;
    final hPt = lh * 72 / 96;

    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          wPt,
          hPt,
          marginAll: 0,
        ),
        build: (_) =>
            pw.SizedBox(width: wPt, height: hPt, child: pw.Image(pw.MemoryImage(pngBytes))),
      ),
    );

    try {
      return await doc.save();
    } catch (e, st) {
      debugPrint('[InvoicePreviewCapturePdf] PDF save failed: $e\n$st');
      return null;
    }
  }
}
