import 'package:flutter/material.dart';
import '../../../../services/session_service.dart';
// import '../../../../repositories/pos_repository.dart';
import '../../../../utils/toast_service.dart';
import '../../../data/repositories/pos_repository.dart';
import '../Home Screen/pos_view_model.dart';

class AvailablePromotion {
  final String code;
  final String title;
  final String description;
  final double discount;
  final bool isPercent;
  final String applicableStore;
  final String applicableProducts;
  final String validityPeriod;

  AvailablePromotion({
    required this.code,
    required this.title,
    required this.description,
    required this.discount,
    required this.isPercent,
    required this.applicableStore,
    required this.applicableProducts,
    required this.validityPeriod,
  });
}

class PromoViewModel extends ChangeNotifier {
  final SessionService sessionService;
  final PosRepository posRepository;

  PromoViewModel({
    required this.sessionService,
    required this.posRepository,
  });

  bool _isLoading = false;
  String? _promoErrorMessage;
  final TextEditingController promoController = TextEditingController();

  Map<String, dynamic>? _validResult;
  Map<String, dynamic>? get validResult => _validResult;

  final List<AvailablePromotion> _availablePromotions = [
    AvailablePromotion(
      code: 'SAVE10',
      title: 'Welcome Discount',
      description: 'Get 10% off on your first order.',
      discount: 10.0,
      isPercent: true,
      applicableStore: 'All Branches',
      applicableProducts: 'All Products',
      validityPeriod: 'Until 31 Dec 2026',
    ),
    AvailablePromotion(
      code: 'FILTER50',
      title: 'Oil Service Special',
      description: 'SAR 50 off on all oil change services.',
      discount: 50.0,
      isPercent: false,
      applicableStore: 'Riyadh Main Branch',
      applicableProducts: 'Oil Change Services',
      validityPeriod: 'Until 30 Jun 2026',
    ),
    AvailablePromotion(
      code: 'REFER15',
      title: 'Referral Bonus',
      description: 'Get 15% off when you refer a friend.',
      discount: 15.0,
      isPercent: true,
      applicableStore: 'All Branches',
      applicableProducts: 'Services Only',
      validityPeriod: 'Until 31 Dec 2026',
    ),
  ];

  bool get isLoading => _isLoading;
  String? get promoErrorMessage => _promoErrorMessage;
  List<AvailablePromotion> get availablePromotions => _availablePromotions;

  Future<void> validatePromo(String code, PosViewModel posVm, BuildContext context) async {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) return;

    _isLoading = true;
    _promoErrorMessage = null;
    _validResult = null;
    notifyListeners();

    try {
      final token = await sessionService.getToken();
      if (token == null) throw Exception('Token not found');

      final response = await posRepository.applyPromoCode(
        cleanCode,
        posVm.subtotalExclVat, // Use cart subtotal as order amount
        token,
      );

      if (response.success && response.valid && response.promoCode != null) {
        _validResult = {
          'discount': response.promoCode!.discount,
          'isPercent': response.promoCode!.isPercent,
          'message': response.promoCode!.isPercent
              ? '${response.promoCode!.discount}% Discount'
              : 'SAR ${response.promoCode!.discount} Discount',
          'store': response.promoCode!.applicableStore ?? 'All Branches',
          'products': response.promoCode!.applicableProducts ?? 'All Products',
          'period': response.promoCode!.validityPeriod ?? 'No Expiry',
        };
        // Don't apply to cart yet, let user confirm first.
      } else {
        final msg = response.message.isNotEmpty ? response.message : 'Invalid Promo Code';
        _promoErrorMessage = msg;
        posVm.clearPromoCode();
        _validResult = null;
      }
    } catch (e) {
      _promoErrorMessage = e.toString().replaceFirst('Exception: ', '');
      posVm.clearPromoCode();
      if (context.mounted) {
        ToastService.showError(context, _promoErrorMessage!);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearPromoError() {
    bool changed = false;
    if (_promoErrorMessage != null) {
      _promoErrorMessage = null;
      changed = true;
    }
    if (_validResult != null) {
      _validResult = null;
      changed = true;
    }
    if (changed) {
      notifyListeners();
    }
  }

  Future<void> checkMockValidity(String? explicitCode, PosViewModel posVm, BuildContext context) async {
    final code = (explicitCode ?? promoController.text).trim().toUpperCase();
    if (code.isEmpty) return;

    if (explicitCode != null) {
      promoController.text = explicitCode;
    }

    _isLoading = true;
    _promoErrorMessage = null;
    _validResult = null;
    notifyListeners();

    // Simulated backend call
    await Future.delayed(const Duration(milliseconds: 800));

    if (!context.mounted) return;

    if (code == 'SAVE10') {
      _validResult = {
        'discount': 10.0,
        'isPercent': true,
        'message': '10% Discount',
        'store': 'All Branches',
        'products': 'All Products',
        'period': 'Until 31 Dec 2026',
      };
      _isLoading = false;
      notifyListeners();
      _applyMockPromo(posVm);
    } else if (code == 'FILTER50') {
      _validResult = {
        'discount': 50.0,
        'isPercent': false,
        'message': 'SAR 50 Discount',
        'store': 'Riyadh Main Branch',
        'products': 'Oil Change Services',
        'period': 'Until 30 Jun 2026',
      };
      _isLoading = false;
      notifyListeners();
      _applyMockPromo(posVm);
    } else if (code == 'REFER15') {
      _validResult = {
        'discount': 15.0,
        'isPercent': true,
        'message': '15% Discount',
        'store': 'All Branches',
        'products': 'Services Only',
        'period': 'Until 31 Dec 2026',
      };
      _isLoading = false;
      notifyListeners();
      _applyMockPromo(posVm);
    } else {
      _promoErrorMessage = 'Invalid or Expired Promo Code';
      _isLoading = false;
      notifyListeners();
    }
  }

  void _applyMockPromo(PosViewModel posVm) {
    if (_validResult == null) return;
    posVm.applyPromoCode(
      promoController.text.trim().toUpperCase(),
      _validResult!['discount'],
      _validResult!['isPercent'],
    );
  }

  @override
  void dispose() {
    promoController.dispose();
    super.dispose();
  }
}
