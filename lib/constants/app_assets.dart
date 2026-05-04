/// Single source of truth for bundled brand logo paths (pubspec `flutter.assets`).
const String kAppBrandLogoAsset = 'assets/images/icon.png';

/// Tried in order when the primary PNG is missing from the release bundle.
const List<String> kAppBrandLogoAssetCandidates = [
  kAppBrandLogoAsset,
  'assets/images/icons.png',
];
