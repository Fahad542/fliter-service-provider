import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../Home Screen/pos_view_model.dart';
import '../../../models/cashier_corporate_accounts_api_model.dart';
import '../../../models/customer_search_model.dart';
import '../../../models/cashier_expense_models.dart';
import '../../../services/locker_translation_mixin.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/toast_service.dart';
import '../../../utils/app_formatters.dart';
import 'pos_add_customer_phone_format.dart';

export 'pos_add_customer_phone_format.dart';

class AddCustomerViewModel extends ChangeNotifier with TranslatableMixin {
  final BuildContext context;
  static const String _vpicBaseUrl = 'https://vpic.nhtsa.dot.gov/api/vehicles';

  AddCustomerViewModel(this.context) {
    _hydrateFromSavedCustomer();
    loadMakes();
  }

  // Controllers for Normal Customer
  final TextEditingController nameController = TextEditingController();
  final TextEditingController vatController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();

  PosAddCustomerMobileDial _mobileDialCountry = PosAddCustomerMobileDial.saudiArabia;
  PosAddCustomerMobileDial get mobileDialCountry => _mobileDialCountry;

  bool _pickBranchEmployeeMode = false;
  List<BranchEmployee> _branchEmployeesPickList = [];
  bool _branchEmployeesPickLoading = false;
  BranchEmployee? _branchEmployeePickSelection;

  bool get pickBranchEmployeeMode => _pickBranchEmployeeMode;
  List<BranchEmployee> get branchEmployeesPickList => _branchEmployeesPickList;
  bool get branchEmployeesPickLoading => _branchEmployeesPickLoading;
  BranchEmployee? get branchEmployeePickSelection => _branchEmployeePickSelection;

  bool get lockNameMobileFromBranchEmployee => _pickBranchEmployeeMode;

  void setPickBranchEmployeeMode(bool v) {
    if (_pickBranchEmployeeMode == v) return;
    _pickBranchEmployeeMode = v;
    if (!v) {
      _branchEmployeePickSelection = null;
      nameController.clear();
      mobileController.clear();
      _mobileDialCountry = PosAddCustomerMobileDial.saudiArabia;
    } else {
      loadBranchEmployeesIfNeeded();
    }
    notifyListeners();
  }

  void setBranchEmployeeSelection(BranchEmployee? e) {
    _branchEmployeePickSelection = e;
    if (e != null) {
      nameController.text = e.name;
      _applyInternationalMobileToField(e.mobile ?? '');
    }
    notifyListeners();
  }

  Future<void> loadBranchEmployeesIfNeeded() async {
    if (_branchEmployeesPickLoading || _branchEmployeesPickList.isNotEmpty) {
      return;
    }
    _branchEmployeesPickLoading = true;
    notifyListeners();
    try {
      final posVm = context.read<PosViewModel>();
      final token = await posVm.sessionService.getToken(role: 'cashier');
      if (token == null) return;
      final res = await posVm.posRepository.getCashierEmployees(token);
      if (res.success) {
        _branchEmployeesPickList = res.employees;
      }
    } catch (_) {
      _branchEmployeesPickList = [];
    } finally {
      _branchEmployeesPickLoading = false;
      notifyListeners();
    }
  }

  void setMobileDialCountry(PosAddCustomerMobileDial value) {
    if (_mobileDialCountry == value) return;
    _mobileDialCountry = value;
    final digits = digitsOnlyPhone(mobileController.text);
    mobileController.text = PosAddCustomerPhoneFormat.formatDigits(value, digits);
    mobileController.selection =
        TextSelection.collapsed(offset: mobileController.text.length);
    notifyListeners();
  }

  static String digitsOnlyPhone(String input) => PosAddCustomerPhoneFormat.digitsOnly(input);

  /// E.164-style value for walk-in save (normalized national + selected dial).
  String composedInternationalMobile() {
    final local = PosAddCustomerPhoneFormat.normalizeNational(
      _mobileDialCountry,
      mobileController.text,
    );
    if (local.isEmpty) return '';
    return '+${_mobileDialCountry.dialDigits}$local';
  }

  String? validateNationalMobileInput({
    required String? raw,
    required String messageEmpty,
    required String messageInvalidSaudi,
    required String messageInvalidPakistan,
  }) {
    final digits = digitsOnlyPhone(raw ?? '');
    if (digits.isEmpty) return messageEmpty;
    if (PosAddCustomerPhoneFormat.isValidNational(_mobileDialCountry, raw ?? '')) {
      return null;
    }
    return _mobileDialCountry == PosAddCustomerMobileDial.saudiArabia
        ? messageInvalidSaudi
        : messageInvalidPakistan;
  }

  void _applyInternationalMobileToField(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      mobileController.text = '';
      return;
    }
    var d = digitsOnlyPhone(trimmed);
    if (d.startsWith('966') && d.length > 3) {
      _mobileDialCountry = PosAddCustomerMobileDial.saudiArabia;
      d = d.substring(3);
    } else if (d.startsWith('92') && d.length > 2) {
      _mobileDialCountry = PosAddCustomerMobileDial.pakistan;
      d = d.substring(2);
    } else if (d.length >= 10 && d.startsWith('3')) {
      _mobileDialCountry = PosAddCustomerMobileDial.pakistan;
    } else {
      _mobileDialCountry = PosAddCustomerMobileDial.saudiArabia;
    }
    mobileController.text =
        PosAddCustomerPhoneFormat.formatDigits(_mobileDialCountry, d);
  }
  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController vinNumberController = TextEditingController();
  final TextEditingController makeController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController odoMeterController = TextEditingController();

  /// Model year (optional), must match [_vehicleModelYearChoices] when set.
  String? _normalVehicleYear;
  String? _corpVehicleYear;

  String? get normalVehicleYear => _normalVehicleYear;
  String? get corpVehicleYear => _corpVehicleYear;

  void setNormalVehicleYear(String? year) {
    _normalVehicleYear = year;
    notifyListeners();
  }

  void setCorpVehicleYear(String? year) {
    _corpVehicleYear = year;
    notifyListeners();
  }

  // Controllers for Corporate Customer
  final TextEditingController corpVehicleNumberController =
      TextEditingController();
  final TextEditingController corpVinNumberController =
      TextEditingController();
  final TextEditingController corpMakeController = TextEditingController();
  final TextEditingController corpModelController = TextEditingController();
  final TextEditingController corpOdoMeterController = TextEditingController();

  /// Selected corporate account **id** (must match [DropdownMenuItem.value] — never duplicate company names).
  String? _selectedCorporate;
  CashierCorporateAccount? _selectedCorporateData;

  String? get selectedCorporate => _selectedCorporate;
  CashierCorporateAccount? get selectedCorporateData => _selectedCorporateData;

  /// Keeps selection valid when the API list loads or contains duplicate [CashierCorporateAccount.companyName] rows.
  void reconcileCorporateDropdownSelection(List<CashierCorporateAccount> accounts) {
    if (accounts.isEmpty) {
      if (_selectedCorporate != null || _selectedCorporateData != null) {
        _selectedCorporate = null;
        _selectedCorporateData = null;
        notifyListeners();
      }
      return;
    }

    final sid = _selectedCorporate;
    if (sid != null && accounts.any((c) => c.id == sid)) {
      final m = accounts.firstWhere((c) => c.id == sid);
      if (_selectedCorporateData?.id != m.id) {
        _selectedCorporateData = m;
        notifyListeners();
      }
      return;
    }

    if (sid != null && sid.isNotEmpty) {
      final byName = accounts.where((c) => c.companyName == sid).toList();
      if (byName.isNotEmpty) {
        final pick =
            (_selectedCorporateData != null &&
                    accounts.any((c) => c.id == _selectedCorporateData!.id))
                ? accounts.firstWhere((c) => c.id == _selectedCorporateData!.id)
                : byName.first;
        _selectedCorporate = pick.id;
        _selectedCorporateData = pick;
        notifyListeners();
        return;
      }
    }

    if (_selectedCorporateData != null &&
        accounts.any((c) => c.id == _selectedCorporateData!.id)) {
      final m =
          accounts.firstWhere((c) => c.id == _selectedCorporateData!.id);
      _selectedCorporate = m.id;
      _selectedCorporateData = m;
      notifyListeners();
      return;
    }

    if (_selectedCorporate != null || _selectedCorporateData != null) {
      _selectedCorporate = null;
      _selectedCorporateData = null;
      notifyListeners();
    }
  }

  List<String> _makes = const [];
  final Map<String, List<String>> _modelsByMake = {};
  bool _isLoadingMakes = false;
  final Set<String> _loadingModelsForMakes = <String>{};

  List<String> get makes => _makes;
  bool get isLoadingMakes => _isLoadingMakes;
  List<SearchedCustomer> _vehicleHistorySuggestions = const [];
  List<SearchedCustomer> _mobileHistorySuggestions = const [];
  /// Shown when the field is focused with no / short query (same API + limit).
  List<SearchedCustomer> _historyFocusHints = const [];
  bool _historyFocusHintsLoading = false;
  bool _isSearchingVehicleHistory = false;
  bool _isSearchingMobileHistory = false;

  List<SearchedCustomer> get vehicleHistorySuggestions => _vehicleHistorySuggestions;
  List<SearchedCustomer> get mobileHistorySuggestions => _mobileHistorySuggestions;
  List<SearchedCustomer> get historyFocusHints => _historyFocusHints;
  bool get isSearchingVehicleHistory => _isSearchingVehicleHistory;
  bool get isSearchingMobileHistory => _isSearchingMobileHistory;

  bool hasExactMake(String value) {
    final needle = value.trim().toLowerCase();
    if (needle.isEmpty) return false;
    return _makes.any((m) => m.toLowerCase() == needle);
  }

  Future<Map<String, dynamic>?> _getVehicleJson(Uri uri) async {
    try {
      final res = await http.get(uri);
      if (res.statusCode < 200 || res.statusCode >= 300) return null;
      final raw = res.body.trim();
      if (raw.isEmpty) return null;

      // Supports pure JSON (vPIC) and JSONP-like wrappers if any.
      dynamic decoded;
      try {
        decoded = jsonDecode(raw);
      } catch (_) {
        final start = raw.indexOf('{');
        final end = raw.lastIndexOf('}');
        if (start == -1 || end == -1 || end <= start) return null;
        decoded = jsonDecode(raw.substring(start, end + 1));
      }
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> loadMakes({bool forceRefresh = false}) async {
    if (_isLoadingMakes) return;
    if (!forceRefresh && _makes.isNotEmpty) return;
    _isLoadingMakes = true;
    notifyListeners();
    try {
      final uri = Uri.parse(
        '$_vpicBaseUrl/getallmakes?format=json',
      );
      final json = await _getVehicleJson(uri);
      final rawMakes = (json?['Results'] as List?) ?? const [];
      final fetched = rawMakes
          .map((e) => (e as Map?)?['Make_Name']?.toString().trim() ?? '')
          .where((e) => e.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
      if (fetched.isNotEmpty) {
        _makes = fetched;
      }
    } finally {
      _isLoadingMakes = false;
      notifyListeners();
    }
  }

  Future<void> loadModelsForMake(String make, {bool forceRefresh = false}) async {
    final key = make.trim();
    if (key.isEmpty) return;
    if (!forceRefresh && _modelsByMake.containsKey(key)) return;
    if (_loadingModelsForMakes.contains(key)) return;

    _loadingModelsForMakes.add(key);
    notifyListeners();
    try {
      final uri = Uri.parse(
        '$_vpicBaseUrl/GetModelsForMake/${Uri.encodeComponent(key)}?format=json',
      );
      final json = await _getVehicleJson(uri);
      final rawModels = (json?['Results'] as List?) ?? const [];
      final fetched = rawModels
          .map((e) => (e as Map?)?['Model_Name']?.toString().trim() ?? '')
          .where((e) => e.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
      _modelsByMake[key] = fetched;
    } finally {
      _loadingModelsForMakes.remove(key);
      notifyListeners();
    }
  }

  bool isLoadingModelsForMake(String make) =>
      _loadingModelsForMakes.contains(make.trim());

  List<String> makeSuggestions(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return _makes.take(20).toList();
    return _makes
        .where((m) => m.toLowerCase().contains(q))
        .take(20)
        .toList();
  }

  List<String> modelSuggestions({
    required String make,
    required String query,
  }) {
    final models = _modelsByMake[make.trim()] ?? const <String>[];
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return models.take(20).toList();
    return models
        .where((m) => m.toLowerCase().contains(q))
        .take(20)
        .toList();
  }

  static const String _hintLimit = '4';

  /// A few customers for empty / short query (backend requires name or phone; [limit] caps rows).
  Future<void> loadCustomerHistoryFocusHints() async {
    if (_historyFocusHints.isNotEmpty || _historyFocusHintsLoading) return;
    _historyFocusHintsLoading = true;
    try {
      final posVm = context.read<PosViewModel>();
      final token = await posVm.sessionService.getToken();
      if (token == null) return;

      List<SearchedCustomer> found = [];
      for (final params in <Map<String, String>>[
        {'phone': '05', 'limit': _hintLimit},
        {'phone': '0', 'limit': _hintLimit},
        {'name': 'a', 'limit': _hintLimit},
        {'name': 'ا', 'limit': _hintLimit},
      ]) {
        final response = await posVm.posRepository.searchCustomers(params, token);
        if (response.success && response.customers.isNotEmpty) {
          found = response.customers.take(4).toList();
          break;
        }
      }
      _historyFocusHints = found;
    } catch (_) {
      _historyFocusHints = const [];
    } finally {
      _historyFocusHintsLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchCustomerHistoryByVehicle(String query) async {
    final q = query.trim();
    if (q.length < 2) {
      _vehicleHistorySuggestions = const [];
      notifyListeners();
      return;
    }
    _isSearchingVehicleHistory = true;
    notifyListeners();
    try {
      final posVm = context.read<PosViewModel>();
      final token = await posVm.sessionService.getToken();
      if (token == null) {
        _vehicleHistorySuggestions = const [];
        return;
      }
      final response = await posVm.posRepository.searchCustomers(
        {'vehicleNumber': q, 'limit': '20'},
        token,
      );
      _vehicleHistorySuggestions = response.success ? response.customers : const [];
    } catch (_) {
      _vehicleHistorySuggestions = const [];
    } finally {
      _isSearchingVehicleHistory = false;
      notifyListeners();
    }
  }

  Future<void> searchCustomerHistoryByMobile(String query) async {
    final q = digitsOnlyPhone(query);
    if (q.length < 3) {
      _mobileHistorySuggestions = const [];
      notifyListeners();
      return;
    }
    _isSearchingMobileHistory = true;
    notifyListeners();
    try {
      final posVm = context.read<PosViewModel>();
      final token = await posVm.sessionService.getToken();
      if (token == null) {
        _mobileHistorySuggestions = const [];
        return;
      }
      final response = await posVm.posRepository.searchCustomers(
        {'phone': q, 'limit': '20'},
        token,
      );
      _mobileHistorySuggestions = response.success ? response.customers : const [];
    } catch (_) {
      _mobileHistorySuggestions = const [];
    } finally {
      _isSearchingMobileHistory = false;
      notifyListeners();
    }
  }

  int _customerPrefillRebuildToken = 0;
  int get customerPrefillRebuildToken => _customerPrefillRebuildToken;

  DateTime _orderDate(SearchedCustomerOrder o) {
    try {
      return DateTime.parse(o.createdAt);
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  /// Vehicle from the newest order that has usable plate/make/model/vin data.
  SearchedCustomerVehicle? historyVehicleSnapshot(SearchedCustomer c) =>
      _bestOrderForVehicle(c.orders)?.vehicle;

  /// Newest order that still has usable vehicle data (plate/make/model/vin).
  SearchedCustomerOrder? _bestOrderForVehicle(List<SearchedCustomerOrder> orders) {
    if (orders.isEmpty) return null;
    bool hasVehicleData(SearchedCustomerVehicle? v) {
      if (v == null) return false;
      return (v.plateNo.trim().isNotEmpty) ||
          (v.make.trim().isNotEmpty) ||
          (v.model.trim().isNotEmpty) ||
          ((v.vin ?? '').trim().isNotEmpty);
    }

    final sorted = [...orders]..sort((a, b) => _orderDate(b).compareTo(_orderDate(a)));
    for (final o in sorted) {
      if (hasVehicleData(o.vehicle)) return o;
    }
    return sorted.first;
  }

  void prefillFromCustomer(SearchedCustomer customer) {
    final best = _bestOrderForVehicle(customer.orders);
    final vehicle = best?.vehicle;

    nameController.text = customer.name.trim();
    final tax = (customer.taxId ?? '').trim();
    if (tax.isNotEmpty) vatController.text = tax;

    _applyInternationalMobileToField(customer.mobile);

    if ((vehicle?.plateNo ?? '').trim().isNotEmpty) {
      vehicleNumberController.text =
          formatVehiclePlateLettersFirst(vehicle!.plateNo.trim());
    }
    if ((vehicle?.make ?? '').trim().isNotEmpty) {
      makeController.text = vehicle!.make.trim();
      loadModelsForMake(makeController.text);
    }
    if ((vehicle?.model ?? '').trim().isNotEmpty) {
      modelController.text = vehicle!.model.trim();
    }
    if ((vehicle?.vin ?? '').trim().isNotEmpty) {
      vinNumberController.text = vehicle!.vin!.trim();
    }
    if ((best?.odometerReading ?? 0) > 0) {
      odoMeterController.text = best!.odometerReading.toString();
    }

    // Autocomplete uses its own internal TextEditingController; bump token so
    // those widgets rebuild and pick up the updated external controllers.
    _customerPrefillRebuildToken++;
    notifyListeners();
  }

  Future<void> retranslate() async {
    AppTranslationService.clearCache();
    notifyListeners();
  }

  void bindSettingsViewModel(Listenable settingsViewModel) {
    bindLocaleRetranslation(settingsViewModel, retranslate);
  }

  void _hydrateFromSavedCustomer() {
    final vm = context.read<PosViewModel>();
    nameController.text = vm.customerName;
    vatController.text = vm.vatNumber;
    _applyInternationalMobileToField(vm.mobile);
    vehicleNumberController.text =
        formatVehiclePlateLettersFirst(vm.vehicleNumber.trim());

    final oid = (vm.selectedOrder?.id ?? '').trim();
    final hasBillingDraft =
        oid.isNotEmpty && vm.walkInBillingSnapshotForOrder(oid) != null;
    final continuingShell =
        (vm.walkInDraftOrderId ?? '').trim().isNotEmpty;

    if (hasBillingDraft || continuingShell) {
      vinNumberController.text = vm.vinNumber;
      makeController.text = vm.make;
      modelController.text = vm.model;
      odoMeterController.text = vm.odometerReading > 0
          ? vm.odometerReading.toString()
          : '';
      final y = vm.vehicleYear.trim();
      _normalVehicleYear = y.isNotEmpty ? y : null;
    } else {
      vinNumberController.text = '';
      makeController.text = '';
      modelController.text = '';
      odoMeterController.text = '';
      _normalVehicleYear = null;
    }
  }

  void setCorporate(String accountId, CashierCorporateAccount? data) {
    _selectedCorporate = accountId;
    _selectedCorporateData = data;
    notifyListeners();
  }

  void saveAndProceed({
    required bool isNormal,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) {
    final vm = context.read<PosViewModel>();
    final l10n = AppLocalizations.of(context)!;

    if (isNormal && _pickBranchEmployeeMode) {
      if (_branchEmployeesPickLoading) {
        ToastService.showInfo(context, l10n.posInvoiceDetailsLoadingEmployees);
        return;
      }
      if (_branchEmployeePickSelection == null) {
        ToastService.showError(context, l10n.posOrdersSelectBranchEmployeeCustomer);
        return;
      }
    }

    final composedMobile = composedInternationalMobile();
    final pickEmp = isNormal && _pickBranchEmployeeMode;
    vm.saveCustomerAndProceed(
      isNormal: isNormal,
      name: nameController.text.trim(),
      vat: isNormal ? vatController.text.trim() : '',
      mobile: composedMobile.isNotEmpty ? composedMobile : '',
      vehicleNumber: isNormal
          ? canonicalSaudiPlateForApi(vehicleNumberController.text.trim())
          : canonicalSaudiPlateForApi(corpVehicleNumberController.text.trim()),
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
      onError: onError,
      billingCustomerIsEmployee: pickEmp,
      billingEmployeeId: pickEmp ? _branchEmployeePickSelection?.id : null,
      billingEmployeeType: pickEmp ? _branchEmployeePickSelection?.employeeType : null,
      vehicleYear: isNormal
          ? (_normalVehicleYear ?? '')
          : (_corpVehicleYear ?? ''),
    );
    nameController.clear();
    mobileController.clear();
    if (isNormal) {
      vatController.clear();
      _pickBranchEmployeeMode = false;
      _branchEmployeePickSelection = null;
    }
    _normalVehicleYear = null;
    _corpVehicleYear = null;
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
    _selectedCorporate = null;
    _selectedCorporateData = null;
    _mobileDialCountry = PosAddCustomerMobileDial.saudiArabia;
    _pickBranchEmployeeMode = false;
    _branchEmployeePickSelection = null;
    _branchEmployeesPickList = [];
    _normalVehicleYear = null;
    _corpVehicleYear = null;
    notifyListeners();
  }

  @override
  void dispose() {
    unbindLocaleRetranslation();
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

/// Calendar years for vehicle year dropdown (current year back 40 years).
List<String> vehicleModelYearChoices() {
  final y = DateTime.now().year;
  return List<String>.generate(41, (i) => '${y - i}');
}
