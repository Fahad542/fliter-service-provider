import 'dart:typed_data';

import 'package:image/image.dart';

/// Receipt-friendly logo: narrower, monochrome black on white for PDF + ESC/POS.
Uint8List? preprocessThermalReceiptLogoPng(
  Uint8List pngBytes, {
  int targetMaxWidth = 200,
}) {
  final decoded = decodeImage(pngBytes);
  if (decoded == null) return null;

  var img = decoded;
  if (img.width > targetMaxWidth) {
    img = copyResize(img, width: targetMaxWidth);
  }

  img = grayscale(img);

  for (final frame in img.frames) {
    for (final p in frame) {
      if (p.a < 28) {
        p
          ..r = 255
          ..g = 255
          ..b = 255
          ..a = 255;
        continue;
      }
      final lum = p.luminanceNormalized;
      final v = lum > 0.86 ? 255 : 0;
      p
        ..r = v
        ..g = v
        ..b = v
        ..a = 255;
    }
  }

  return Uint8List.fromList(encodePng(img));
}
