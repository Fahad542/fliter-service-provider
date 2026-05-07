/// Single source of truth for bundled brand logo paths.
const String kAppBrandLogoAsset = 'assets/images/Icon.png';

/// Fallback candidates if primary logo is unavailable.
const List<String> kAppBrandLogoAssetCandidates = [
  kAppBrandLogoAsset,
  'assets/images/icons.png',
];
