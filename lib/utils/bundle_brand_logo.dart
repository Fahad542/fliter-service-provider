import 'package:flutter/services.dart';

import '../constants/app_assets.dart';

/// First successfully loaded logo bytes from [kAppBrandLogoAssetCandidates], or null.
Future<ByteData?> loadBrandLogoByteData() async {
  for (final path in kAppBrandLogoAssetCandidates) {
    try {
      return await rootBundle.load(path);
    } catch (_) {}
  }
  return null;
}
