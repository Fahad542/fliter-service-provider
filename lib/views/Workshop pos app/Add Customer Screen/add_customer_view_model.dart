import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Home Screen/pos_view_model.dart';
import '../../../models/cashier_corporate_accounts_api_model.dart';
import '../../../services/locker_translation_mixin.dart';
import '../More Tab/settings_view_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AddCustomerViewModel
//
// Translation strategy
// ────────────────────
// • Static UI strings  → AppLocalizations via the view (l10n.posAddCustomer*).
// • Dynamic API data   → TranslatableMixin.t() / tNullable() called explicitly
//   whenever the locale changes so that re-hydration on locale switch works.
//
// Key pitfalls avoided
// ────────────────────
// 1. Corporate company names from the API are kept as raw English in the model;
//    translation happens in the view via a FutureBuilder so the dropdown value
//    stays comparable to the original string (no mismatch on re-selection).
// 2. Error messages from the API (passed via onError callback) are translated
//    inside saveAndProceed using tStatus() before being forwarded to the view.
// 3. No if/else branching on translated text — all logic uses the original
//    English enum/status values; only display-layer strings are translated.
// ─────────────────────────────────────────────────────────────────────────────

class AddCustomerViewModel extends ChangeNotifier with TranslatableMixin {
  final BuildContext context;

  AddCustomerViewModel(this.context) {
    _hydrateFromSavedCustomer();
    // Re-translate whenever the locale changes.
    context.read<SettingsViewModel>().addListener(_onLocaleChanged);
  }

  // ── Controllers — Normal Customer ─────────────────────────────────────────
  final TextEditingController nameController        = TextEditingController();
  final TextEditingController vatController         = TextEditingController();
  final TextEditingController mobileController      = TextEditingController();
  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController vinNumberController   = TextEditingController();
  final TextEditingController makeController        = TextEditingController();
  final TextEditingController modelController       = TextEditingController();
  final TextEditingController odoMeterController    = TextEditingController();

  // ── Controllers — Corporate Customer ─────────────────────────────────────
  final TextEditingController corpVehicleNumberController = TextEditingController();
  final TextEditingController corpVinNumberController     = TextEditingController();
  final TextEditingController corpMakeController          = TextEditingController();
  final TextEditingController corpModelController         = TextEditingController();
  final TextEditingController corpOdoMeterController      = TextEditingController();

  // ── Corporate selection ───────────────────────────────────────────────────
  // _selectedCorporate always holds the ORIGINAL English company name so that
  // dropdown value comparison never breaks when locale switches.
  String? _selectedCorporate;
  CashierCorporateAccount? _selectedCorporateData;

  String? get selectedCorporate     => _selectedCorporate;
  CashierCorporateAccount? get selectedCorporateData => _selectedCorporateData;

  // ── Hydration ─────────────────────────────────────────────────────────────

  void _hydrateFromSavedCustomer() {
    final vm = context.read<PosViewModel>();
    nameController.text          = vm.customerName;
    vatController.text           = vm.vatNumber;
    mobileController.text        = vm.mobile;
    vehicleNumberController.text = vm.vehicleNumber;

    final oid = (vm.selectedOrder?.id ?? '').trim();
    final hasBillingDraft =
        oid.isNotEmpty && vm.walkInBillingSnapshotForOrder(oid) != null;
    final continuingShell =
        (vm.walkInDraftOrderId ?? '').trim().isNotEmpty;

    if (hasBillingDraft || continuingShell) {
      vinNumberController.text   = vm.vinNumber;
      makeController.text        = vm.make;
      modelController.text       = vm.model;
      odoMeterController.text    =
      vm.odometerReading > 0 ? vm.odometerReading.toString() : '';
    } else {
      vinNumberController.text   = '';
      makeController.text        = '';
      modelController.text       = '';
      odoMeterController.text    = '';
    }
  }

  // ── Locale-change hook ────────────────────────────────────────────────────
  // When the user toggles the language we just notify listeners; the view
  // rebuilds automatically and all l10n.* keys are re-read from the new locale.
  // Corporate names are translated on demand in the view via translateCompanyName().
  void _onLocaleChanged() {
    notifyListeners();
  }

  // ── Public API ────────────────────────────────────────────────────────────

  void setCorporate(String rawEnglishName, CashierCorporateAccount? data) {
    _selectedCorporate     = rawEnglishName; // always stored in English
    _selectedCorporateData = data;
    notifyListeners();
  }

  /// Translates a corporate company name for display purposes only.
  /// Returns the original string if locale is English or translation fails.
  Future<String> translateCompanyName(String name) => t(name);

  void saveAndProceed({
    required bool isNormal,
    required VoidCallback onSuccess,
    required Future<void> Function(String) onError,
  }) {
    final vm = context.read<PosViewModel>();

    vm.saveCustomerAndProceed(
      isNormal: isNormal,
      name:    isNormal ? '' : nameController.text.trim(),
      vat:     isNormal ? '' : vatController.text.trim(),
      mobile:  isNormal ? '' : mobileController.text.trim(),
      vehicleNumber: isNormal
          ? vehicleNumberController.text.trim()
          : corpVehicleNumberController.text.trim(),
      vinNumber: isNormal
          ? vinNumberController.text.trim().toUpperCase()
          : corpVinNumberController.text.trim().toUpperCase(),
      make: isNormal
          ? makeController.text.trim()
          : corpMakeController.text.trim(),
      model: isNormal
          ? modelController.text.trim()
          : corpModelController.text.trim(),
      odometerStr: isNormal
          ? odoMeterController.text.trim()
          : corpOdoMeterController.text.trim(),
      selectedCorporateData: _selectedCorporateData,
      onSuccess: onSuccess,
      // Translate the error message coming from the API before displaying it.
      onError: (msg) async {
        final translated = await tStatus(msg);
        await onError(translated);
      },
    );

    if (isNormal) {
      nameController.clear();
      vatController.clear();
      mobileController.clear();
    }
  }

  void clearAllFields() {
    nameController.clear();
    vatController.clear();
    mobileController.clear();
    vehicleNumberController.clear();
    vinNumberController.clear();
    makeController.clear();
    modelController.clear();
    odoMeterController.clear();
    corpVehicleNumberController.clear();
    corpVinNumberController.clear();
    corpMakeController.clear();
    corpModelController.clear();
    corpOdoMeterController.clear();
    _selectedCorporate     = null;
    _selectedCorporateData = null;
    notifyListeners();
  }

  @override
  void dispose() {
    // Remove locale listener before disposal to avoid calling notifyListeners
    // on a disposed object.
    if (context.mounted) {
      context.read<SettingsViewModel>().removeListener(_onLocaleChanged);
    }
    nameController.dispose();
    vatController.dispose();
    mobileController.dispose();
    vehicleNumberController.dispose();
    vinNumberController.dispose();
    makeController.dispose();
    modelController.dispose();
    odoMeterController.dispose();
    corpVehicleNumberController.dispose();
    corpVinNumberController.dispose();
    corpMakeController.dispose();
    corpModelController.dispose();
    corpOdoMeterController.dispose();
    super.dispose();
  }
}