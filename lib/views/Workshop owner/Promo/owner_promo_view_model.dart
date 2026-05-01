import 'package:flutter/material.dart';
import '../../../../models/workshop_owner_models.dart';
import '../../../../data/repositories/owner_repository.dart';
import '../../../../services/session_service.dart';
import '../../../../utils/toast_service.dart';
import '../../../l10n/app_localizations.dart';

/// Mixin that gives any ChangeNotifier access to a BuildContext so it can
/// resolve localised strings for toast messages.
///
/// Usage:
///   1. Add `with TranslatableMixin` to your ViewModel.
///   2. Call `setContext(context)` from your View's `initState` /
///      `didChangeDependencies` (after the first frame if needed).
///   3. Use `l10n` inside the ViewModel to get translated strings.
///
/// IMPORTANT: Never store the context beyond a single method call.
/// This mixin deliberately exposes only AppLocalizations, not the full
/// context, so locale is always fresh on every method invocation.
mixin TranslatableMixin on ChangeNotifier {
  BuildContext? _ctx;

  void setContext(BuildContext context) {
    _ctx = context;
  }

  AppLocalizations? get l10n {
    final ctx = _ctx;
    if (ctx == null) return null;
    return AppLocalizations.of(ctx);
  }
}

// ---------------------------------------------------------------------------

class OwnerPromoViewModel extends ChangeNotifier with TranslatableMixin {
  final OwnerRepository ownerRepository;
  final SessionService sessionService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isActionLoading = false;
  bool get isActionLoading => _isActionLoading;

  List<PromoCode> _promoCodes = [];
  List<PromoCode> get promoCodes => _promoCodes;

  // Form controllers
  final codeController = TextEditingController();
  final discountValueController = TextEditingController();
  final validFromController = TextEditingController();
  final validToController = TextEditingController();
  final usageLimitController = TextEditingController();
  final minOrderAmountController = TextEditingController();
  final descriptionController = TextEditingController();

  /// Internal API value — 'fixed' or 'percent'. Never shown in the UI raw;
  /// the view translates this via l10n.promoTypeFixed / l10n.promoTypePercent.
  String _discountType = 'fixed';
  String get discountType => _discountType;

  String? _editingPromoId;
  bool get isEditing => _editingPromoId != null;

  OwnerPromoViewModel({
    required this.ownerRepository,
    required this.sessionService,
  }) {
    fetchPromoCodes();
  }

  void setDiscountType(String type) {
    _discountType = type;
    notifyListeners();
  }

  // ── Fetch ──────────────────────────────────────────────────────────────────

  Future<void> fetchPromoCodes() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) throw Exception('No token found');

      final response = await ownerRepository.getPromoCodes(token);
      if (response != null && response['success'] == true) {
        final parsed = PromoCodesResponse.fromJson(response);
        _promoCodes = parsed.promoCodes;
      }
    } catch (e) {
      debugPrint('Error fetching promo codes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Edit helpers ───────────────────────────────────────────────────────────

  void setEditPromoCode(PromoCode? p) {
    if (p == null) {
      _editingPromoId = null;
      clearControllers();
    } else {
      _editingPromoId = p.id;
      codeController.text = p.code;
      // _discountType stores the raw API value ('fixed'/'percent') — not
      // a translated label — so no translation is needed here.
      _discountType = p.discountType;
      discountValueController.text = p.discountValue.toString();
      validFromController.text = p.validFrom.split('T').first;
      validToController.text = p.validTo.split('T').first;
      usageLimitController.text = p.usageLimit.toString();
      minOrderAmountController.text = p.minOrderAmount.toString();
      descriptionController.text = p.description ?? '';
    }
    notifyListeners();
  }

  void clearControllers() {
    codeController.clear();
    discountValueController.clear();
    validFromController.clear();
    validToController.clear();
    usageLimitController.clear();
    minOrderAmountController.clear();
    descriptionController.clear();
    _discountType = 'fixed';
  }

  // ── Submit (create / update) ───────────────────────────────────────────────

  Future<void> submitPromoCode(BuildContext context) async {
    // Resolve l10n at the start of the call — guaranteed to use the current
    // locale even if locale switches mid-flight.
    final strings = AppLocalizations.of(context)!;

    if (codeController.text.trim().isEmpty ||
        discountValueController.text.trim().isEmpty) {
      ToastService.showInfo(context, strings.promoValidationRequired);
      return;
    }

    _isActionLoading = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) throw Exception('No token found');

      final data = {
        'code': codeController.text.trim(),
        // _discountType is the raw API enum value — sent as-is to the backend.
        'discountType': _discountType,
        'discountValue':
        double.tryParse(discountValueController.text) ?? 0,
        'validFrom': validFromController.text.trim().isNotEmpty
            ? validFromController.text.trim()
            : DateTime.now().toIso8601String().split('T').first,
        'validTo': validToController.text.trim().isNotEmpty
            ? validToController.text.trim()
            : DateTime.now()
            .add(const Duration(days: 30))
            .toIso8601String()
            .split('T')
            .first,
        'usageLimit': int.tryParse(usageLimitController.text) ?? 100,
        'minOrderAmount':
        double.tryParse(minOrderAmountController.text) ?? 0,
        'description': descriptionController.text.trim(),
      };

      final response = _editingPromoId == null
          ? await ownerRepository.createPromoCode(token, data)
          : await ownerRepository.updatePromoCode(
          token, _editingPromoId!, data);

      if (response != null && response['success'] == true) {
        // Re-resolve l10n after await — locale may have changed or context
        // may have been rebuilt.
        final freshStrings = AppLocalizations.of(context);
        ToastService.showSuccess(
          context,
          _editingPromoId == null
              ? (freshStrings?.promoCreateSuccess ??
              strings.promoCreateSuccess)
              : (freshStrings?.promoUpdateSuccess ??
              strings.promoUpdateSuccess),
        );
        Navigator.pop(context);
        setEditPromoCode(null);
        fetchPromoCodes();
      } else {
        throw Exception(
          response?['message'] ??
              (AppLocalizations.of(context)?.promoCreateError ??
                  strings.promoCreateError),
        );
      }
    } catch (e) {
      ToastService.showError(context, e.toString());
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  // ── Delete ─────────────────────────────────────────────────────────────────

  Future<void> deletePromoCode(BuildContext context, String id) async {
    final strings = AppLocalizations.of(context)!;

    _isActionLoading = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) throw Exception('No token found');

      final response = await ownerRepository.deletePromoCode(token, id);
      if (response != null && response['success'] == true) {
        final freshStrings = AppLocalizations.of(context);
        ToastService.showSuccess(
          context,
          freshStrings?.promoDeleteSuccess ?? strings.promoDeleteSuccess,
        );
        fetchPromoCodes();
      } else {
        throw Exception(
          response?['message'] ??
              (AppLocalizations.of(context)?.promoDeleteError ??
                  strings.promoDeleteError),
        );
      }
    } catch (e) {
      ToastService.showError(context, e.toString());
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void dispose() {
    codeController.dispose();
    discountValueController.dispose();
    validFromController.dispose();
    validToController.dispose();
    usageLimitController.dispose();
    minOrderAmountController.dispose();
    descriptionController.dispose();
    _ctx = null;
    super.dispose();
  }
}