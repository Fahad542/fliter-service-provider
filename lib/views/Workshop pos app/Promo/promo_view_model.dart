import 'package:flutter/material.dart';
import '../../../../services/locker_translation_mixin.dart';
import '../../../../services/session_service.dart';
import '../../../../utils/toast_service.dart';
import '../../../data/repositories/pos_repository.dart';
import '../Home Screen/pos_view_model.dart';

// ---------------------------------------------------------------------------
// AvailablePromotion
//
// Raw fields come from the API (always English).
// Translated display fields are populated by PromoViewModel after calling
// _translatePromo(). Views must use the translated* variants.
// ---------------------------------------------------------------------------

class AvailablePromotion {
  // ── Raw API fields (never mutate after construction) ─────────────────────
  final String code;
  final double discount;
  final bool isPercent;
  final String rawTitle;
  final String rawDescription;
  final String rawApplicableStore;
  final String rawApplicableProducts;
  final String rawValidityPeriod;

  // ── Translated display fields (locale-aware) ──────────────────────────────
  final String title;
  final String description;
  final String applicableStore;
  final String applicableProducts;
  final String validityPeriod;

  const AvailablePromotion({
    required this.code,
    required this.discount,
    required this.isPercent,
    required this.rawTitle,
    required this.rawDescription,
    required this.rawApplicableStore,
    required this.rawApplicableProducts,
    required this.rawValidityPeriod,
    // translated defaults to raw until translation runs
    String? title,
    String? description,
    String? applicableStore,
    String? applicableProducts,
    String? validityPeriod,
  })  : title = title ?? rawTitle,
        description = description ?? rawDescription,
        applicableStore = applicableStore ?? rawApplicableStore,
        applicableProducts = applicableProducts ?? rawApplicableProducts,
        validityPeriod = validityPeriod ?? rawValidityPeriod;

  AvailablePromotion copyWithTranslated({
    required String title,
    required String description,
    required String applicableStore,
    required String applicableProducts,
    required String validityPeriod,
  }) {
    return AvailablePromotion(
      code: code,
      discount: discount,
      isPercent: isPercent,
      rawTitle: rawTitle,
      rawDescription: rawDescription,
      rawApplicableStore: rawApplicableStore,
      rawApplicableProducts: rawApplicableProducts,
      rawValidityPeriod: rawValidityPeriod,
      title: title,
      description: description,
      applicableStore: applicableStore,
      applicableProducts: applicableProducts,
      validityPeriod: validityPeriod,
    );
  }
}

// ---------------------------------------------------------------------------
// PromoViewModel
// ---------------------------------------------------------------------------

class PromoViewModel extends ChangeNotifier with TranslatableMixin {
  final SessionService sessionService;
  final PosRepository posRepository;

  // SettingsViewModel (or any locale-change Listenable) injected externally.
  // Set via [bindSettings] once from the widget tree or a parent VM.
  PromoViewModel({
    required this.sessionService,
    required this.posRepository,
  });

  // ── State ─────────────────────────────────────────────────────────────────
  bool _isLoading = false;
  String? _promoErrorMessage;
  final TextEditingController promoController = TextEditingController();

  // validResult stores ONLY locale-neutral keys ('discount', 'isPercent',
  // 'id') plus pre-translated display strings for the current locale.
  // Re-translated on locale switch via [_retranslateValidResult].
  Map<String, dynamic>? _validResult;
  Map<String, dynamic>? get validResult => _validResult;

  // Raw API strings for validResult — kept so we can re-translate on switch.
  Map<String, String>? _rawValidResultStrings;

  List<AvailablePromotion> _availablePromotions = [];
  // Raw promo list — kept for re-translation on locale switch.
  List<AvailablePromotion> _rawPromotions = [];

  bool _isLoadingPromos = false;

  bool get isLoading => _isLoading;
  bool get isLoadingPromos => _isLoadingPromos;
  String? get promoErrorMessage => _promoErrorMessage;
  List<AvailablePromotion> get availablePromotions => _availablePromotions;

  // ── Locale binding ────────────────────────────────────────────────────────

  /// Call once after construction, passing the SettingsViewModel (or any
  /// Listenable that fires when the locale changes).
  void bindSettings(Listenable settingsViewModel) {
    bindLocaleRetranslation(settingsViewModel, _retranslateAll);
  }

  /// Re-translates all dynamic display strings without re-fetching from the
  /// network.  Called automatically by [TranslatableMixin] on locale switch.
  Future<void> _retranslateAll() async {
    await Future.wait([
      _retranslatePromotions(),
      _retranslateValidResult(),
    ]);
    notifyListeners();
  }

  // ── Fetch available promotions ─────────────────────────────────────────────

  Future<void> fetchAvailablePromos() async {
    _isLoadingPromos = true;
    notifyListeners();
    try {
      final token = await sessionService.getToken();
      if (token == null) throw Exception('Token not found');

      final response = await posRepository.getPromoCodes(token);
      if (response.success && response.promoCodes != null) {
        // Build raw list (titles/descriptions in API language — typically EN).
        _rawPromotions = response.promoCodes!.map((code) {
          final rawTitle = code.discountLabel ??
              (code.isPercent
                  ? '${code.discount.toStringAsFixed(0)}% Discount'
                  : 'SAR ${code.discount.toStringAsFixed(0)} Discount');
          return AvailablePromotion(
            code: code.code,
            discount: code.discount,
            isPercent: code.isPercent,
            rawTitle: rawTitle,
            rawDescription: code.description ?? 'Promotional discount',
            rawApplicableStore: code.applicableStore ?? 'All Branches',
            rawApplicableProducts: code.applicableProducts ?? 'All Products',
            rawValidityPeriod: code.validityPeriod ?? 'No Expiry',
          );
        }).toList();
        await _retranslatePromotions();
      }
    } catch (e) {
      debugPrint('Failed to fetch promos: $e');
    } finally {
      _isLoadingPromos = false;
      notifyListeners();
    }
  }

  /// Translates the raw promo list and updates [_availablePromotions].
  Future<void> _retranslatePromotions() async {
    if (_rawPromotions.isEmpty) {
      _availablePromotions = [];
      return;
    }
    _availablePromotions = await Future.wait(
      _rawPromotions.map(_translatePromo),
    );
  }

  Future<AvailablePromotion> _translatePromo(AvailablePromotion p) async {
    final results = await tAll([
      p.rawTitle,
      p.rawDescription,
      p.rawApplicableStore,
      p.rawApplicableProducts,
      p.rawValidityPeriod,
    ]);
    return p.copyWithTranslated(
      title: results[0],
      description: results[1],
      applicableStore: results[2],
      applicableProducts: results[3],
      validityPeriod: results[4],
    );
  }

  // ── Validate promo code ────────────────────────────────────────────────────

  Future<void> validatePromo(
      String code,
      PosViewModel posVm,
      BuildContext context, {
        bool isMainTab = false,
      }) async {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) return;

    _isLoading = true;
    _promoErrorMessage = null;
    _validResult = null;
    _rawValidResultStrings = null;
    notifyListeners();

    try {
      final token = await sessionService.getToken();
      if (token == null) throw Exception('Token not found');

      final cartAmount = posVm.getSubtotalExclVat(isMainTab);
      final orderAmount = cartAmount > 0 ? cartAmount : 999999.0;

      final response = await posRepository.applyPromoCode(
        cleanCode,
        orderAmount,
        token,
      );

      if (response.success && response.valid && response.promoCode != null) {
        final pc = response.promoCode!;

        // Raw API strings stored for re-translation on locale switch.
        final rawStore = pc.applicableStore ?? 'All Branches';
        final rawProducts = pc.applicableProducts ?? 'All Products';
        final rawPeriod = pc.validityPeriod ?? 'No Expiry';
        final rawMessage = pc.isPercent
            ? '${pc.discount.toStringAsFixed(0)}% Discount'
            : 'SAR ${pc.discount.toStringAsFixed(0)} Discount';

        _rawValidResultStrings = {
          'message': rawMessage,
          'store': rawStore,
          'products': rawProducts,
          'period': rawPeriod,
        };

        // Translate for display.
        final translated = await tAll([rawMessage, rawStore, rawProducts, rawPeriod]);

        _validResult = {
          'id': pc.id,
          'discount': pc.discount,
          'isPercent': pc.isPercent,
          'message': translated[0],
          'store': translated[1],
          'products': translated[2],
          'period': translated[3],
        };
      } else {
        final rawMsg =
        response.message.isNotEmpty ? response.message : 'Invalid Promo Code';
        _promoErrorMessage = await t(rawMsg);
        posVm.clearPromoCode(isMainTab: isMainTab);
        _validResult = null;
        _rawValidResultStrings = null;
      }
    } catch (e) {
      final rawMsg = e.toString().replaceFirst('Exception: ', '');
      _promoErrorMessage = await t(rawMsg);
      posVm.clearPromoCode(isMainTab: isMainTab);
      if (context.mounted) {
        ToastService.showError(context, _promoErrorMessage!);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Re-translates the current validResult display strings into the active
  /// locale without touching the numeric/boolean values.
  Future<void> _retranslateValidResult() async {
    if (_validResult == null || _rawValidResultStrings == null) return;
    final raw = _rawValidResultStrings!;
    final translated = await tAll([
      raw['message']!,
      raw['store']!,
      raw['products']!,
      raw['period']!,
    ]);
    _validResult = {
      ..._validResult!, // keeps 'id', 'discount', 'isPercent'
      'message': translated[0],
      'store': translated[1],
      'products': translated[2],
      'period': translated[3],
    };
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void clearPromoError() {
    bool changed = false;
    if (_promoErrorMessage != null) {
      _promoErrorMessage = null;
      changed = true;
    }
    if (_validResult != null) {
      _validResult = null;
      _rawValidResultStrings = null;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  /// Clears validated promo UI, input text, and any promo applied on the cart.
  void removeAppliedPromo(PosViewModel posVm, {bool isMainTab = false}) {
    _validResult = null;
    _rawValidResultStrings = null;
    _promoErrorMessage = null;
    promoController.clear();
    posVm.clearPromoCode(isMainTab: isMainTab);
    notifyListeners();
  }

  // ── Mock validation (dev / demo only) ─────────────────────────────────────

  Future<void> checkMockValidity(
      String? explicitCode,
      PosViewModel posVm,
      BuildContext context,
      ) async {
    final code = (explicitCode ?? promoController.text).trim().toUpperCase();
    if (code.isEmpty) return;

    if (explicitCode != null) promoController.text = explicitCode;

    _isLoading = true;
    _promoErrorMessage = null;
    _validResult = null;
    _rawValidResultStrings = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));
    if (!context.mounted) return;

    Map<String, String>? rawStrings;

    if (code == 'SAVE10') {
      rawStrings = {
        'message': '10% Discount',
        'store': 'All Branches',
        'products': 'All Products',
        'period': 'Until 31 Dec 2026',
      };
    } else if (code == 'FILTER50') {
      rawStrings = {
        'message': 'SAR 50 Discount',
        'store': 'Riyadh Main Branch',
        'products': 'Oil Change Services',
        'period': 'Until 30 Jun 2026',
      };
    } else if (code == 'REFER15') {
      rawStrings = {
        'message': '15% Discount',
        'store': 'All Branches',
        'products': 'Services Only',
        'period': 'Until 31 Dec 2026',
      };
    }

    if (rawStrings != null) {
      _rawValidResultStrings = rawStrings;
      final translated = await tAll([
        rawStrings['message']!,
        rawStrings['store']!,
        rawStrings['products']!,
        rawStrings['period']!,
      ]);
      final isPercent = code == 'SAVE10' || code == 'REFER15';
      final discount = code == 'SAVE10'
          ? 10.0
          : code == 'FILTER50'
          ? 50.0
          : 15.0;

      _validResult = {
        'discount': discount,
        'isPercent': isPercent,
        'message': translated[0],
        'store': translated[1],
        'products': translated[2],
        'period': translated[3],
      };
      _isLoading = false;
      notifyListeners();
      _applyMockPromo(posVm);
    } else {
      _promoErrorMessage = await t('Invalid or Expired Promo Code');
      _isLoading = false;
      notifyListeners();
    }
  }

  void _applyMockPromo(PosViewModel posVm) {
    if (_validResult == null) return;
    posVm.applyPromoCode(
      promoController.text.trim().toUpperCase(),
      _validResult!['discount'] as double,
      _validResult!['isPercent'] as bool,
      promoCodeId: _validResult!['id']?.toString(),
    );
  }

  @override
  void dispose() {
    unbindLocaleRetranslation();
    promoController.dispose();
    super.dispose();
  }
}