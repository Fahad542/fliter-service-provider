import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/toast_service.dart';
import '../../../widgets/pos_widgets.dart';
import '../../../utils/app_formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/LocalizedApiText.dart';
import '../../../models/customer_search_model.dart';
import '../../../models/cashier_corporate_accounts_api_model.dart';
import '../../../models/cashier_expense_models.dart';
// import '../../Department/pos_department_view.dart';
import 'package:provider/provider.dart';
import '../Department/pos_department_view.dart';
import '../Home Screen/pos_view_model.dart';
import 'add_customer_view_model.dart';

/// One [DropdownMenuItem] per id (API can return duplicate company names).
List<CashierCorporateAccount> _dedupeCorporateAccountsById(
  List<CashierCorporateAccount> list,
) {
  final byId = <String, CashierCorporateAccount>{};
  for (final c in list) {
    final id = c.id.trim();
    if (id.isEmpty) continue;
    byId.putIfAbsent(id, () => c);
  }
  return byId.values.toList();
}

class PosAddCustomerView extends StatefulWidget {
  final int initialTab;

  const PosAddCustomerView({super.key, this.initialTab = 0});

  @override
  State<PosAddCustomerView> createState() => _PosAddCustomerViewState();
}

class _PosAddCustomerViewState extends State<PosAddCustomerView> with SingleTickerProviderStateMixin {
  AppLocalizations get l10n => AppLocalizations.of(context)!;
  late TabController _tabController;
  static const Map<String, String> _makeArabicMap = {
    'Toyota': 'تويوتا',
    'Nissan': 'نيسان',
    'Hyundai': 'هيونداي',
    'Kia': 'كيا',
    'Honda': 'هوندا',
    'Mazda': 'مازدا',
    'Mitsubishi': 'ميتسوبيشي',
    'Ford': 'فورد',
    'Chevrolet': 'شيفروليه',
    'GMC': 'جي إم سي',
    'Lexus': 'لكزس',
    'BMW': 'بي إم دبليو',
    'Mercedes-Benz': 'مرسيدس بنز',
    'Audi': 'أودي',
    'Volkswagen': 'فولكس واجن',
    'Isuzu': 'إيسوزو',
    'Suzuki': 'سوزوكي',
  };

  /// Slightly darker than [Colors.grey.shade400] so hints stay readable on white fields.
  static Color get _fieldHintColor => Colors.grey.shade500;

  // Form keys
  final _normalFormKey = GlobalKey<FormState>();
  final _corporateFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
    _tabController.addListener(_onTabChanged);
    if (widget.initialTab == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchCorporateAccountsIfEmpty();
      });
    }
  }

  void _onTabChanged() {
    if (_tabController.index == 1 && !_tabController.indexIsChanging) {
      _fetchCorporateAccountsIfEmpty();
    }
  }

  void _fetchCorporateAccountsIfEmpty() {
    final posVm = context.read<PosViewModel>();
    if (posVm.isCorpAccountsLoading) return;
    // Empty list + cached "loaded once" would skip GET in VM; force so newly added server accounts can appear.
    posVm.fetchCorporateAccounts(
      silent: false,
      forceRefresh: posVm.corporateAccounts.isEmpty,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _normalizeSaudiPlate(String value) {
    return value
        .replaceAll(RegExp(r'[\s\-\|]'), '')
        .toUpperCase();
  }

  bool _isArabicPlateLetter(String char) {
    return RegExp(r'^[\u0621-\u064A]$').hasMatch(char);
  }

  bool _isEnglishPlateLetter(String char) {
    return RegExp(r'^[A-Z]$').hasMatch(char);
  }

  TextInputFormatter _saudiPlateInputFormatter({
    VoidCallback? onRejectedDigitBeyondFour,
    VoidCallback? onRejectedLetterBeyondThree,
  }) {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      final raw =
          _normalizeSaudiPlate(EnglishNumberFormatter.convert(newValue.text));
      if (raw.isEmpty) {
        return TextEditingValue(
          text: '',
          selection: TextSelection.collapsed(offset: 0),
        );
      }

      var rejectedExtraDigit = false;
      var rejectedExtraLetter = false;

      /// Complete plate pasted as `1312 + DDS` (API order) — show as letters first.
      final pastedDigitsFirst =
          RegExp(r'^([0-9]{3,4})([A-Z\u0621-\u064A]{3})$').firstMatch(raw);
      if (pastedDigitsFirst != null) {
        final digits = pastedDigitsFirst.group(1)!;
        final letters = pastedDigitsFirst.group(2)!;
        final formatted = '$letters - $digits';
        return TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }

      final letterPart = StringBuffer();
      final digitPart = StringBuffer();
      var lettersDone = false;

      for (final ch in raw.split('')) {
        if (!lettersDone) {
          if (_isEnglishPlateLetter(ch) || _isArabicPlateLetter(ch)) {
            if (letterPart.length < 3) {
              letterPart.write(ch);
              if (letterPart.length == 3) lettersDone = true;
            } else {
              rejectedExtraLetter = true;
            }
          }
          continue;
        }

        if (RegExp(r'^[0-9]$').hasMatch(ch)) {
          if (digitPart.length < 4) {
            digitPart.write(ch);
          } else {
            rejectedExtraDigit = true;
          }
        }
      }

      final ls = letterPart.toString();
      final ds = digitPart.toString();
      final formatted = ds.isNotEmpty ? '$ls - $ds' : ls;

      if (rejectedExtraLetter && onRejectedLetterBeyondThree != null) {
        final cb = onRejectedLetterBeyondThree;
        WidgetsBinding.instance.addPostFrameCallback((_) => cb());
      }
      if (rejectedExtraDigit && onRejectedDigitBeyondFour != null) {
        final cb = onRejectedDigitBeyondFour;
        WidgetsBinding.instance.addPostFrameCallback((_) => cb());
      }

      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    });
  }

  void _toastPlateMaxFourDigitsAfterLetters() {
    if (!mounted) return;
    ToastService.showError(
      context,
      l10n.posAddCustomerValidationVehiclePlateMaxFourDigits,
    );
  }

  void _toastPlateMaxThreeLettersBeforeDigits() {
    if (!mounted) return;
    ToastService.showError(
      context,
      l10n.posAddCustomerValidationVehiclePlateMaxThreeLetters,
    );
  }

  String? _validateSaudiPlate(String? value, {required String requiredMessage}) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return requiredMessage;

    final normalized = _normalizeSaudiPlate(
      canonicalSaudiPlateForApi(raw),
    );
    if (normalized.length < 6 || normalized.length > 7) {
      return 'Saudi plate: exactly 3 letters and 3 or 4 digits';
    }

    int splitIndex = 0;
    while (splitIndex < normalized.length &&
        RegExp(r'^[0-9]$').hasMatch(normalized[splitIndex])) {
      splitIndex++;
    }
    final digitPart = normalized.substring(0, splitIndex);
    final letterPart = normalized.substring(splitIndex);

    if (!RegExp(r'^[0-9]{3,4}$').hasMatch(digitPart)) {
      return 'Saudi plate needs 3 or 4 digits (after the 3 letters)';
    }

    if (letterPart.length != 3) {
      return 'Saudi plate needs exactly 3 letters';
    }

    for (var i = 0; i < letterPart.length; i++) {
      final ch = letterPart[i];
      if (!_isEnglishPlateLetter(ch) && !_isArabicPlateLetter(ch)) {
        return 'Saudi plate letters must be valid (Latin or Arabic)';
      }
    }

    return null;
  }

  String _vehicleLabelWithArabic(String value) {
    final isArabic = Localizations.maybeLocaleOf(context)?.languageCode == 'ar';
    if (!isArabic) return value;
    final ar = _makeArabicMap[value];
    if (ar == null || ar.isEmpty) return value;
    return '$ar - $value';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return ChangeNotifierProvider(
      create: (context) => AddCustomerViewModel(context),
      child: Builder(
        builder: (context) {
          final vm = context.watch<AddCustomerViewModel>();
          return Scaffold(
            backgroundColor: const Color(0xFFFBF9F6),
            appBar: PosScreenAppBar(title: l10n.posAddCustomerTitle),
            body: Column(
              children: [
          SizedBox(height: isTablet ? 14 : 12),

          // Tab Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 28 : 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
              ),
              padding: EdgeInsets.all(isTablet ? 4 : 3),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: AppColors.secondaryLight,
                unselectedLabelColor: AppColors.secondaryLight.withOpacity(0.42),
                labelStyle: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: isTablet ? 14 : 14,
                ),
                unselectedLabelStyle: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: isTablet ? 14 : 14,
                  color: AppColors.secondaryLight.withOpacity(0.42),
                ),
                labelPadding: EdgeInsets.symmetric(vertical: isTablet ? 3 : 2),
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                splashFactory: NoSplash.splashFactory,
                tabs: [
                  Tab(text: l10n.posAddCustomerTabNormal),
                  Tab(text: l10n.posAddCustomerTabCorporate),
                ],
              ),
            ),
          ),
          SizedBox(height: isTablet ? 14 : 12),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNormalCustomerForm(isTablet, vm),
                _buildCorporateCustomerForm(isTablet, vm),
              ],
            ),
          ),
        ],
      ),
    );
        },
      ),
    );
  }

  /// Name + mobile; optional branch-employee pick (Normal tab only).
  Widget _buildCustomerInformationSection(
    AddCustomerViewModel vm, {
    required bool isTablet,
    bool showBranchEmployeePick = false,
  }) {
    final fieldGap = isTablet ? 14.0 : 12.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(l10n.posAddCustomerSectionCustomerInfo, isTablet: isTablet),
        SizedBox(height: isTablet ? 12.0 : 10.0),
        if (showBranchEmployeePick)
          ListenableBuilder(
            listenable: vm,
            builder: (context, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(
                      l10n.posInvoiceDetailsBranchEmployee,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: isTablet ? 13.5 : 12.5,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    subtitle: Text(
                      l10n.posInvoiceDetailsPickStaff,
                      style: TextStyle(
                        fontSize: isTablet ? 12 : 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    value: vm.pickBranchEmployeeMode,
                    onChanged: (v) => vm.setPickBranchEmployeeMode(v),
                  ),
                  if (vm.pickBranchEmployeeMode) ...[
                    const SizedBox(height: 4),
                    if (vm.branchEmployeesPickLoading)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryLight,
                            ),
                          ),
                        ),
                      )
                    else if (vm.branchEmployeesPickList.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          l10n.posInvoiceDetailsNoEmployees,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      )
                    else
                      DropdownButtonFormField<BranchEmployee>(
                        value: vm.branchEmployeePickSelection,
                        decoration: InputDecoration(
                          labelText: l10n.posInvoiceDetailsEmployee,
                          filled: true,
                          fillColor: Colors.white,
                          isDense: true,
                          contentPadding: EdgeInsets.fromLTRB(
                            isTablet ? 12 : 10,
                            isTablet ? 14 : 12,
                            isTablet ? 12 : 10,
                            isTablet ? 14 : 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        hint: Text(
                          l10n.posInvoiceDetailsChooseEmployee,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        isExpanded: true,
                        items: vm.branchEmployeesPickList.map((e) {
                          final mob = e.mobile ?? '';
                          final sub = mob.isNotEmpty ? ' · $mob' : '';
                          return DropdownMenuItem(
                            value: e,
                            child: Text(
                              '${e.name}$sub',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                          );
                        }).toList(),
                        onChanged: (e) => vm.setBranchEmployeeSelection(e),
                      ),
                  ],
                  SizedBox(height: isTablet ? 12.0 : 10.0),
                ],
              );
            },
          ),
        ListenableBuilder(
          listenable: vm,
          builder: (context, _) {
            final lock = showBranchEmployeePick && vm.lockNameMobileFromBranchEmployee;
            if (isTablet) {
              return Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      l10n.posAddCustomerFieldCustomerName,
                      vm.nameController,
                      Icons.person_outline,
                      isTablet: isTablet,
                      readOnly: lock,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNationalMobileField(
                      vm,
                      isTablet: isTablet,
                      readOnly: lock,
                    ),
                  ),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  l10n.posAddCustomerFieldCustomerName,
                  vm.nameController,
                  Icons.person_outline,
                  isTablet: isTablet,
                  readOnly: lock,
                ),
                SizedBox(height: fieldGap),
                _buildNationalMobileField(
                  vm,
                  isTablet: isTablet,
                  readOnly: lock,
                ),
              ],
            );
          },
        ),
        SizedBox(height: fieldGap),
      ],
    );
  }

  // ── Normal Customer Form ──
  Widget _buildNormalCustomerForm(bool isTablet, AddCustomerViewModel vm) {
    final hPad = isTablet ? 28.0 : 20.0;
    final fieldGap = isTablet ? 14.0 : 12.0;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 18),
      child: Form(
        key: _normalFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCustomerInformationSection(
              vm,
              isTablet: isTablet,
              showBranchEmployeePick: true,
            ),

            _buildSectionHeader(l10n.posAddCustomerSectionVehicleInfo, isTablet: isTablet),
            SizedBox(height: isTablet ? 12.0 : 10.0),
            if (isTablet) ...[
              _buildCustomerHistoryAutocompleteField(
                vm: vm,
                l10n.posAddCustomerFieldVehicleNumber,
                vm.vehicleNumberController,
                Icons.confirmation_number_outlined,
                isTablet: isTablet,
                enableSuggestions: false,
                autocorrect: false,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  _saudiPlateInputFormatter(
                    onRejectedDigitBeyondFour:
                        _toastPlateMaxFourDigitsAfterLetters,
                    onRejectedLetterBeyondThree:
                        _toastPlateMaxThreeLettersBeforeDigits,
                  ),
                ],
                validator: (value) => _validateSaudiPlate(
                  value,
                  requiredMessage: l10n.posAddCustomerValidationVehicleRequired,
                ),
              ),
              SizedBox(height: fieldGap),
              Row(
                children: [
                  Expanded(
                    child: _buildVehicleAutocompleteField(
                      vm: vm,
                      type: VehicleLookupType.make,
                      l10n.posAddCustomerFieldMake,
                      vm.makeController,
                      Icons.directions_car_outlined,
                      dependentModelController: vm.modelController,
                      isTablet: isTablet,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildVehicleAutocompleteField(
                      vm: vm,
                      type: VehicleLookupType.model,
                      l10n.posAddCustomerFieldModel,
                      vm.modelController,
                      Icons.model_training_outlined,
                      makeController: vm.makeController,
                      isTablet: isTablet,
                    ),
                  ),
                ],
              ),
              SizedBox(height: fieldGap),
              Row(
                children: [
                  Expanded(
                    child: _buildVehicleYearDropdown(
                      vm,
                      isCorporate: false,
                      isTablet: isTablet,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      l10n.posAddCustomerFieldOdometer,
                      vm.odoMeterController,
                      Icons.speed_outlined,
                      keyboardType: TextInputType.number,
                      isTablet: isTablet,
                      enableSuggestions: false,
                      autocorrect: false,
                      inputFormatters: [EnglishNumberFormatter()],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return null;
                        if (!RegExp(r'^[0-9٠-٩۰-۹०-९]+$').hasMatch(value)) {
                          return l10n.posAddCustomerValidationInvalidNumberShort;
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: fieldGap),
              _buildTextField(
                l10n.posAddCustomerFieldVin,
                vm.vinNumberController,
                Icons.tag_outlined,
                isTablet: isTablet,
                enableSuggestions: false,
                autocorrect: false,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                  LengthLimitingTextInputFormatter(17),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  if (value.trim().length > 17) {
                    return l10n.posAddCustomerValidationVinMax;
                  }
                  return null;
                },
              ),
            ] else ...[
              _buildCustomerHistoryAutocompleteField(
                vm: vm,
                l10n.posAddCustomerFieldVehicleNumber,
                vm.vehicleNumberController,
                Icons.confirmation_number_outlined,
                isTablet: isTablet,
                enableSuggestions: false,
                autocorrect: false,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  _saudiPlateInputFormatter(
                    onRejectedDigitBeyondFour:
                        _toastPlateMaxFourDigitsAfterLetters,
                    onRejectedLetterBeyondThree:
                        _toastPlateMaxThreeLettersBeforeDigits,
                  ),
                ],
                validator: (value) {
                  return _validateSaudiPlate(
                    value,
                    requiredMessage: l10n.posAddCustomerValidationVehicleRequired,
                  );
                },
              ),
              SizedBox(height: fieldGap),
              _buildVehicleAutocompleteField(
                vm: vm,
                type: VehicleLookupType.make,
                l10n.posAddCustomerFieldMake,
                vm.makeController,
                Icons.directions_car_outlined,
                isTablet: isTablet,
                dependentModelController: vm.modelController,
              ),
              SizedBox(height: fieldGap),
              _buildVehicleAutocompleteField(
                l10n.posAddCustomerFieldModel,
                vm.modelController,
                Icons.model_training_outlined,
                vm: vm,
                type: VehicleLookupType.model,
                makeController: vm.makeController,
                isTablet: isTablet,
              ),
              SizedBox(height: fieldGap),
              _buildVehicleYearDropdown(
                vm,
                isCorporate: false,
                isTablet: isTablet,
              ),
              SizedBox(height: fieldGap),
              _buildTextField(
                l10n.posAddCustomerFieldVin,
                vm.vinNumberController,
                Icons.tag_outlined,
                isTablet: isTablet,
                enableSuggestions: false,
                autocorrect: false,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                  LengthLimitingTextInputFormatter(17),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return null;
                  }
                  if (value.trim().length > 17) {
                    return l10n.posAddCustomerValidationVinMax;
                  }
                  return null;
                },
              ),
              SizedBox(height: fieldGap),
              _buildTextField(
                l10n.posAddCustomerFieldOdometer,
                vm.odoMeterController,
                Icons.speed_outlined,
                keyboardType: TextInputType.number,
                isTablet: isTablet,
                enableSuggestions: false,
                autocorrect: false,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  if (int.tryParse(value) == null) {
                    return l10n.posAddCustomerValidationInvalidNumber;
                  }
                  return null;
                },
              ),
            ],

            const SizedBox(height: 22),
            _buildSaveButton(isTablet: isTablet, vm: vm),
          ],
        ),
      ),
    );
  }

  // ── Corporate Customer Form ──
  Widget _buildCorporateCustomerForm(bool isTablet, AddCustomerViewModel vm) {
    final hPad = isTablet ? 28.0 : 20.0;
    final fieldGap = isTablet ? 14.0 : 12.0;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 18),
      child: Form(
        key: _corporateFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Corporate Dropdown
            _buildSectionHeader(l10n.posAddCustomerSectionCorporateAccount, isTablet: isTablet),
            SizedBox(height: isTablet ? 12.0 : 10.0),
            Consumer<PosViewModel>(
              builder: (context, posVm, child) {
                if (posVm.isCorpAccountsLoading) {
                  return Container(
                    height: isTablet ? 52 : 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryLight),
                      ),
                    ),
                  );
                }

                final accounts = _dedupeCorporateAccountsById(posVm.corporateAccounts);
                vm.reconcileCorporateDropdownSelection(accounts);
                final selectedId = vm.selectedCorporate;
                final dropdownValue =
                    selectedId != null && accounts.any((c) => c.id == selectedId)
                        ? selectedId
                        : null;

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 14 : 12, vertical: isTablet ? 2 : 0),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: dropdownValue,
                      hint: Text(
                        accounts.isEmpty
                            ? l10n.posAddCustomerNoCorporateFound 
                            : l10n.posAddCustomerSelectCorporate,
                        style: AppTextStyles.bodyMedium.copyWith(color: _fieldHintColor, fontSize: isTablet ? 14 : 13),
                      ),
                      isExpanded: true,
                      icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade400, size: isTablet ? 24 : 22),
                      items: accounts.map((corp) {
                        return DropdownMenuItem<String>(
                          value: corp.id,
                          child: LocalizedApiText(
                            corp.companyName,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: isTablet ? 14 : 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: accounts.isEmpty ? null : (value) {
                        if (value != null) {
                          final corpData = accounts.firstWhere(
                            (corp) => corp.id == value,
                          );
                          vm.setCorporate(value, corpData);
                        }
                      },
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: isTablet ? 18.0 : 14.0),

            _buildCustomerInformationSection(
              vm,
              isTablet: isTablet,
              showBranchEmployeePick: false,
            ),
            SizedBox(height: isTablet ? 18.0 : 14.0),

            // Auto-filled fields (read-only)
            if (vm.selectedCorporateData != null) ...[
              _buildSectionHeader(l10n.posAddCustomerSectionCompanyDetails, isTablet: isTablet),
              SizedBox(height: isTablet ? 12.0 : 10.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildReadOnlyField(
                      l10n.posAddCustomerFieldCompanyName,
                      vm.selectedCorporateData!.companyName,
                      Icons.business,
                      isTablet: isTablet,
                      maxValueLines: 2,
                      valueOverflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: isTablet ? 12 : 10),
                  Expanded(
                    child: _buildReadOnlyField(
                      l10n.posAddCustomerFieldVatNumber,
                      vm.selectedCorporateData!.effectiveVatNumber ?? l10n.posAddCustomerFieldNA,
                      Icons.receipt_long_outlined,
                      isTablet: isTablet,
                      maxValueLines: 2,
                      valueOverflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: isTablet ? 12 : 10),
                  Expanded(
                    child: _buildReadOnlyField(
                      l10n.posAddCustomerFieldBillingAddress,
                      vm.selectedCorporateData!.billingAddress ?? vm.selectedCorporateData!.address ?? l10n.posAddCustomerFieldNA,
                      Icons.location_on_outlined,
                      isTablet: isTablet,
                      maxValueLines: 3,
                      valueOverflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isTablet ? 18.0 : 14.0),
            ],

            // Vehicle Section
            _buildSectionHeader(l10n.posAddCustomerSectionVehicleInfo, isTablet: isTablet),
            SizedBox(height: isTablet ? 12.0 : 10.0),
            if (isTablet) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      l10n.posAddCustomerFieldVehicleNumber,
                      vm.corpVehicleNumberController,
                      Icons.confirmation_number_outlined,
                      isTablet: isTablet,
                      enableSuggestions: false,
                      autocorrect: false,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        _saudiPlateInputFormatter(
                          onRejectedDigitBeyondFour:
                              _toastPlateMaxFourDigitsAfterLetters,
                          onRejectedLetterBeyondThree:
                              _toastPlateMaxThreeLettersBeforeDigits,
                        ),
                      ],
                      validator: (value) {
                        return _validateSaudiPlate(
                          value,
                          requiredMessage: l10n.posAddCustomerValidationRequired,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildVehicleAutocompleteField(
                      vm: vm,
                      type: VehicleLookupType.make,
                      l10n.posAddCustomerFieldMake,
                      vm.corpMakeController,
                      Icons.directions_car_outlined,
                      dependentModelController: vm.corpModelController,
                      isTablet: isTablet,
                    ),
                  ),
                ],
              ),
              SizedBox(height: fieldGap),
              _buildVehicleYearDropdown(
                vm,
                isCorporate: true,
                isTablet: isTablet,
              ),
              SizedBox(height: fieldGap),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      l10n.posAddCustomerFieldVin,
                      vm.corpVinNumberController,
                      Icons.tag_outlined,
                      isTablet: isTablet,
                      enableSuggestions: false,
                      autocorrect: false,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                        LengthLimitingTextInputFormatter(17),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return null;
                        }
                        if (value.trim().length > 17) {
                          return l10n.posAddCustomerValidationVinMax;
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: fieldGap),
              Row(
                children: [
                  Expanded(
                    child: _buildVehicleAutocompleteField(
                      vm: vm,
                      type: VehicleLookupType.model,
                      l10n.posAddCustomerFieldModel,
                      vm.corpModelController,
                      Icons.model_training_outlined,
                      makeController: vm.corpMakeController,
                      isTablet: isTablet,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      l10n.posAddCustomerFieldOdometer,
                      vm.corpOdoMeterController,
                      Icons.speed_outlined,
                      keyboardType: TextInputType.number,
                      isTablet: isTablet,
                      enableSuggestions: false,
                      autocorrect: false,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return null;
                        }
                        if (int.tryParse(value) == null) {
                          return l10n.posAddCustomerValidationInvalidNumberShort;
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ] else ...[
              _buildTextField(
                l10n.posAddCustomerFieldVehicleNumber,
                vm.corpVehicleNumberController,
                Icons.confirmation_number_outlined,
                isTablet: isTablet,
                enableSuggestions: false,
                autocorrect: false,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  _saudiPlateInputFormatter(
                    onRejectedDigitBeyondFour:
                        _toastPlateMaxFourDigitsAfterLetters,
                    onRejectedLetterBeyondThree:
                        _toastPlateMaxThreeLettersBeforeDigits,
                  ),
                ],
                validator: (value) {
                  return _validateSaudiPlate(
                    value,
                    requiredMessage: l10n.posAddCustomerValidationVehicleRequired,
                  );
                },
              ),
              SizedBox(height: fieldGap),
              _buildTextField(
                l10n.posAddCustomerFieldVin,
                vm.corpVinNumberController,
                Icons.tag_outlined,
                isTablet: isTablet,
                enableSuggestions: false,
                autocorrect: false,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                  LengthLimitingTextInputFormatter(17),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return null;
                  }
                  if (value.trim().length > 17) {
                    return l10n.posAddCustomerValidationVinMax;
                  }
                  return null;
                },
              ),
              SizedBox(height: fieldGap),
              _buildVehicleAutocompleteField(
                vm: vm,
                type: VehicleLookupType.make,
                l10n.posAddCustomerFieldMake,
                vm.corpMakeController,
                Icons.directions_car_outlined,
                dependentModelController: vm.corpModelController,
                isTablet: isTablet,
              ),
              SizedBox(height: fieldGap),
              _buildVehicleAutocompleteField(
                vm: vm,
                type: VehicleLookupType.model,
                l10n.posAddCustomerFieldModel,
                vm.corpModelController,
                Icons.model_training_outlined,
                makeController: vm.corpMakeController,
                isTablet: isTablet,
              ),
              SizedBox(height: fieldGap),
              _buildVehicleYearDropdown(
                vm,
                isCorporate: true,
                isTablet: isTablet,
              ),
              SizedBox(height: fieldGap),
              _buildTextField(
                l10n.posAddCustomerFieldOdometer,
                vm.corpOdoMeterController,
                Icons.speed_outlined,
                keyboardType: TextInputType.number,
                isTablet: isTablet,
                enableSuggestions: false,
                autocorrect: false,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return null;
                  }
                  if (int.tryParse(value) == null) {
                    return l10n.posAddCustomerValidationInvalidNumber;
                  }
                  return null;
                },
              ),
            ],

            const SizedBox(height: 22),
            _buildSaveButton(isTablet: isTablet, vm: vm),
          ],
        ),
      ),
    );
  }

  // ── Shared Widgets ──

  Widget _buildVehicleYearDropdown(
    AddCustomerViewModel vm, {
    required bool isCorporate,
    required bool isTablet,
  }) {
    final years = vehicleModelYearChoices();
    final isAr = Localizations.maybeLocaleOf(context)?.languageCode == 'ar';
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        final raw = isCorporate ? vm.corpVehicleYear : vm.normalVehicleYear;
        final selected = raw != null && years.contains(raw) ? raw : null;

        return MenuAnchor(
          alignmentOffset: const Offset(0, 4),
          crossAxisUnconstrained: false,
          style: MenuStyle(
            backgroundColor: const WidgetStatePropertyAll(Colors.white),
            elevation: const WidgetStatePropertyAll(6),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(vertical: 6),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maximumSize:
                const WidgetStatePropertyAll(Size.fromHeight(260)),
          ),
          builder: (context, controller, _) {
            return InkWell(
              borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
              onTap: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              child: InputDecorator(
                isFocused: controller.isOpen,
                decoration: InputDecoration(
                  labelText: l10n.posAddCustomerFieldYear,
                  prefixIcon: Icon(
                    Icons.calendar_today_outlined,
                    size: isTablet ? 22 : 20,
                    color: Colors.grey.shade400,
                  ),
                  suffixIcon: Icon(
                    controller.isOpen
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down,
                    color: Colors.grey.shade500,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  contentPadding: EdgeInsets.fromLTRB(
                    isTablet ? 10 : 8,
                    isTablet ? 14 : 12,
                    isTablet ? 10 : 8,
                    isTablet ? 14 : 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(isTablet ? 14 : 12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(isTablet ? 14 : 12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(isTablet ? 14 : 12),
                    borderSide: BorderSide.none,
                  ),
                  labelStyle: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey,
                    fontSize: isTablet ? 14 : 13,
                  ),
                ),
                child: Text(
                  selected ?? '',
                  textAlign: isAr ? TextAlign.right : TextAlign.left,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondaryLight,
                    fontSize: isTablet ? 14 : 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          },
          menuChildren: years.map((y) {
            final isSelected = y == selected;
            return MenuItemButton(
              style: ButtonStyle(
                minimumSize: WidgetStatePropertyAll(
                  Size(isTablet ? 220 : 180, 40),
                ),
                backgroundColor: WidgetStatePropertyAll(
                  isSelected
                      ? AppColors.primaryLight.withValues(alpha: 0.18)
                      : Colors.white,
                ),
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
              onPressed: () {
                if (isCorporate) {
                  vm.setCorpVehicleYear(y);
                } else {
                  vm.setNormalVehicleYear(y);
                }
              },
              child: Align(
                alignment: isAr
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Text(
                  y,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: isTablet ? 14 : 13,
                    fontWeight: isSelected
                        ? FontWeight.w800
                        : FontWeight.w600,
                    color: AppColors.secondaryLight,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, {bool isTablet = false}) {
    return Row(
      children: [
        Container(
          width: 4,
          height: isTablet ? 18 : 18,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: isTablet ? 15 : 14,
            color: AppColors.secondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    bool isTablet = false,
    bool readOnly = false,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    bool enableSuggestions = true,
    bool autocorrect = true,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    final isAr = Localizations.maybeLocaleOf(context)?.languageCode == 'ar';
    final effectiveHint = hintText ?? label;
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      validator: (val) {
        if (val == null || val.isEmpty) return validator?.call(val);
        return validator?.call(EnglishNumberFormatter.convert(val));
      },
      textAlign: isAr ? TextAlign.right : TextAlign.left,
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      inputFormatters: [
        EnglishNumberFormatter(),
        if (keyboardType == TextInputType.number || keyboardType == TextInputType.phone)
          FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩۰-۹०-९]')),
        ...?inputFormatters,
      ],
      enableSuggestions: enableSuggestions,
      autocorrect: autocorrect,
      style: AppTextStyles.bodyMedium.copyWith(fontSize: isTablet ? 14 : 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        hintText: effectiveHint,
        hintTextDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        alignLabelWithHint: true,
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.grey, fontSize: isTablet ? 14 : 13),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: _fieldHintColor, fontSize: isTablet ? 14 : 13),
        prefixIcon: Icon(icon, size: isTablet ? 22 : 20, color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: EdgeInsets.fromLTRB(isTablet ? 10 : 8, isTablet ? 14 : 12, isTablet ? 10 : 8, isTablet ? 14 : 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
          borderSide: BorderSide.none,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
          borderSide: BorderSide.none,
        ),
        errorStyle: const TextStyle(fontSize: 11, height: 1),
      ),
    );
  }

  Widget _buildVehicleAutocompleteField(
    String label,
    TextEditingController controller,
    IconData icon, {
    required AddCustomerViewModel vm,
    required VehicleLookupType type,
    TextEditingController? makeController,
    TextEditingController? dependentModelController,
    bool isTablet = false,
  }) {
    final isAr = Localizations.maybeLocaleOf(context)?.languageCode == 'ar';
    final makeText = makeController?.text.trim() ?? '';
    final hasSelectedMake = vm.hasExactMake(makeText);

    if (type == VehicleLookupType.make) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        vm.loadMakes();
      });
    } else if (hasSelectedMake) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        vm.loadModelsForMake(makeText);
      });
    }

    return KeyedSubtree(
      key: ValueKey('vehlookup_${type.name}_${vm.customerPrefillRebuildToken}'),
      child: Autocomplete<String>(
      initialValue: TextEditingValue(text: controller.text),
      optionsBuilder: (textEditingValue) {
        final q = textEditingValue.text;
        if (type == VehicleLookupType.make) {
          return vm.makeSuggestions(q);
        }
        final selectedMake = (makeController?.text ?? '').trim();
        if (!vm.hasExactMake(selectedMake)) return const Iterable<String>.empty();
        return vm.modelSuggestions(make: selectedMake, query: q);
      },
      onSelected: (selection) {
        final previous = controller.text.trim();
        controller.text = selection;
        if (type == VehicleLookupType.make &&
            dependentModelController != null &&
            previous.toLowerCase() != selection.toLowerCase()) {
          dependentModelController.clear();
        }
      },
      fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: textController,
          focusNode: focusNode,
          textAlign: isAr ? TextAlign.right : TextAlign.left,
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: isTablet ? 14 : 14,
            fontWeight: FontWeight.w500,
          ),
          onChanged: (value) {
            final previous = controller.text.trim();
            controller.text = value;
            if (type == VehicleLookupType.make &&
                dependentModelController != null &&
                previous.toLowerCase() != value.trim().toLowerCase()) {
              dependentModelController.clear();
            }
            if (type == VehicleLookupType.make) {
              // Trigger API-backed make refresh while typing.
              vm.loadMakes(forceRefresh: true);
            } else if (vm.hasExactMake((makeController?.text ?? '').trim())) {
              final typedMake = (makeController?.text ?? '').trim();
              // Trigger model API on every change only for an exact selected make.
              vm.loadModelsForMake(typedMake, forceRefresh: true);
            }
          },
          decoration: InputDecoration(
            labelText: label,
            hintText: label,
            hintTextDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            alignLabelWithHint: true,
            labelStyle: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey,
              fontSize: isTablet ? 14 : 13,
            ),
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: _fieldHintColor,
              fontSize: isTablet ? 14 : 13,
            ),
            prefixIcon: Icon(icon, size: isTablet ? 22 : 20, color: Colors.grey.shade400),
            suffixIcon: type == VehicleLookupType.model &&
                    !vm.hasExactMake((makeController?.text ?? '').trim())
                ? Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.info_outline,
                      size: isTablet ? 18 : 16,
                      color: Colors.grey.shade400,
                    ),
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            contentPadding: EdgeInsets.fromLTRB(
              isTablet ? 10 : 8,
              isTablet ? 14 : 12,
              isTablet ? 10 : 8,
              isTablet ? 14 : 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
              borderSide: BorderSide.none,
            ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: isAr ? Alignment.topRight : Alignment.topLeft,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 420 : 320,
                maxHeight: 220,
              ),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 6),
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return InkWell(
                    onTap: () => onSelected(option),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Text(
                        type == VehicleLookupType.make
                            ? _vehicleLabelWithArabic(option)
                            : option,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: isTablet ? 14 : 13,
                          color: AppColors.secondaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    ),
    );
  }

  Widget _mobileCountryDialPrefix(
    AddCustomerViewModel vm, {
    required bool isTablet,
    bool enabled = true,
  }) {
    final textStyle = AppTextStyles.bodyMedium.copyWith(
      fontWeight: FontWeight.w700,
      fontSize: isTablet ? 14 : 13,
      color: AppColors.secondaryLight,
    );
    return DropdownButtonHideUnderline(
      child: DropdownButton<PosAddCustomerMobileDial>(
        value: vm.mobileDialCountry,
        isDense: true,
        alignment: AlignmentDirectional.centerStart,
        dropdownColor: Colors.white,
        icon: Padding(
          padding: const EdgeInsetsDirectional.only(start: 2),
          child: Icon(Icons.arrow_drop_down, size: 22, color: Colors.grey.shade500),
        ),
        style: textStyle,
        items: PosAddCustomerMobileDial.values.map((code) {
          return DropdownMenuItem<PosAddCustomerMobileDial>(
            value: code,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(code.flagEmoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text('+${code.dialDigits}', style: textStyle),
              ],
            ),
          );
        }).toList(),
        onChanged: enabled
            ? (v) {
                if (v != null) vm.setMobileDialCountry(v);
              }
            : null,
        selectedItemBuilder: (context) => PosAddCustomerMobileDial.values.map((code) {
          return Padding(
            padding: const EdgeInsetsDirectional.only(start: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(code.flagEmoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text('+${code.dialDigits}', style: textStyle),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNationalMobileField(
    AddCustomerViewModel vm, {
    required bool isTablet,
    bool readOnly = false,
  }) {
    final isAr = Localizations.maybeLocaleOf(context)?.languageCode == 'ar';
    return TextFormField(
      controller: vm.mobileController,
      readOnly: readOnly,
      keyboardType: TextInputType.phone,
      validator: (v) {
        final raw = (v ?? '').trim();
        if (raw.isEmpty) return null;
        return vm.validateNationalMobileInput(
          raw: v,
          messageEmpty: l10n.posAddCustomerValidationMobileRequired,
          messageInvalidSaudi: l10n.posAddCustomerValidationMobileSaudi,
          messageInvalidPakistan: l10n.posAddCustomerValidationMobilePakistan,
        );
      },
      textAlign: isAr ? TextAlign.right : TextAlign.left,
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      inputFormatters: [
        EnglishNumberFormatter(),
        PosAddCustomerNationalMobileFormatter(vm.mobileDialCountry),
      ],
      enableSuggestions: false,
      autocorrect: false,
      style: AppTextStyles.bodyMedium.copyWith(
        fontSize: isTablet ? 14 : 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: l10n.posDetailsMobile,
        hintText: vm.mobileDialCountry.inputHintSample,
        hintTextDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        alignLabelWithHint: false,
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: Colors.grey,
          fontSize: isTablet ? 14 : 13,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: _fieldHintColor,
          fontSize: isTablet ? 14 : 13,
        ),
        prefixIcon: Padding(
          padding: EdgeInsetsDirectional.only(
            start: isTablet ? 8 : 6,
            end: 2,
          ),
          child: _mobileCountryDialPrefix(
            vm,
            isTablet: isTablet,
            enabled: !readOnly,
          ),
        ),
        prefixIconConstraints: BoxConstraints(
          minWidth: isTablet ? 114 : 102,
          minHeight: isTablet ? 28 : 26,
        ),
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: EdgeInsets.fromLTRB(
          isTablet ? 10 : 8,
          isTablet ? 14 : 12,
          isTablet ? 10 : 8,
          isTablet ? 14 : 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
          borderSide: BorderSide.none,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
          borderSide: BorderSide.none,
        ),
        errorStyle: const TextStyle(fontSize: 11, height: 1),
      ),
    );
  }

  Widget _buildCustomerHistoryAutocompleteField(
    String label,
    TextEditingController controller,
    IconData icon, {
    required AddCustomerViewModel vm,
    TextInputType keyboardType = TextInputType.text,
    bool isTablet = false,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    bool enableSuggestions = true,
    bool autocorrect = true,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    final isAr = Localizations.maybeLocaleOf(context)?.languageCode == 'ar';
    return KeyedSubtree(
      key: ValueKey('custhist_vehicle_${vm.customerPrefillRebuildToken}'),
      child: Autocomplete<SearchedCustomer>(
      displayStringForOption: (option) {
        final plate = (vm.historyVehicleSnapshot(option)?.plateNo ?? '').trim();
        return plate.isNotEmpty ? plate : option.mobile;
      },
      initialValue: TextEditingValue(text: controller.text),
      optionsBuilder: (textEditingValue) {
        final q = textEditingValue.text.trim();
        if (q.length < 2) return vm.historyFocusHints;
        return vm.vehicleHistorySuggestions;
      },
      onSelected: (selection) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          vm.prefillFromCustomer(selection);
        });
      },
      fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
        return _CustomerHistoryFieldFocusLoader(
          focusNode: focusNode,
          textEditingController: textController,
          vm: vm,
          child: TextFormField(
            controller: textController,
            focusNode: focusNode,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            validator: validator,
            textAlign: isAr ? TextAlign.right : TextAlign.left,
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            inputFormatters: [
              EnglishNumberFormatter(),
              if (keyboardType == TextInputType.number || keyboardType == TextInputType.phone)
                FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩۰-۹०-९]')),
              ...?inputFormatters,
            ],
            enableSuggestions: enableSuggestions,
            autocorrect: autocorrect,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: isTablet ? 14 : 14,
              fontWeight: FontWeight.w500,
            ),
            onChanged: (value) {
              controller.text = value;
              vm.searchCustomerHistoryByVehicle(value);
            },
            decoration: InputDecoration(
              labelText: label,
              hintText: label,
              hintTextDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
              alignLabelWithHint: true,
              labelStyle: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey,
                fontSize: isTablet ? 14 : 13,
              ),
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: _fieldHintColor,
                fontSize: isTablet ? 14 : 13,
              ),
              prefixIcon: Icon(icon, size: isTablet ? 22 : 20, color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.white,
              isDense: true,
              contentPadding: EdgeInsets.fromLTRB(
                isTablet ? 10 : 8,
                isTablet ? 14 : 12,
                isTablet ? 10 : 8,
                isTablet ? 14 : 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: isAr ? Alignment.topRight : Alignment.topLeft,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 480 : 320,
                maxHeight: 240,
              ),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 6),
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  final vehicle = vm.historyVehicleSnapshot(option);
                  final plate = vehicle?.plateNo ?? '';
                  final title = plate.isNotEmpty ? plate : option.mobile;
                  final subtitle = '${option.name}${(vehicle?.make ?? '').isNotEmpty ? ' • ${vehicle!.make} ${vehicle.model}' : ''}';
                  return InkWell(
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      onSelected(option);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: isTablet ? 14 : 13,
                              color: AppColors.secondaryLight,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: isTablet ? 12 : 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    ),
    );
  }

  Widget _buildReadOnlyField(
    String label,
    String value,
    IconData icon, {
    bool isTablet = false,
    int? maxValueLines,
    TextOverflow? valueOverflow,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 14, vertical: isTablet ? 14 : 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: isTablet ? 22 : 20, color: Colors.grey.shade400),
          SizedBox(width: isTablet ? 12 : 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.grey, fontSize: isTablet ? 12 : 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                LocalizedApiText(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 14 : 14,
                    color: AppColors.secondaryLight,
                  ),
                  maxLines: maxValueLines,
                  overflow: valueOverflow,
                ),
              ],
            ),
          ),
          Icon(Icons.lock_outline, size: isTablet ? 16 : 16, color: Colors.grey.shade300),
        ],
      ),
    );
  }

  Widget _buildSaveButton({bool isTablet = false, required AddCustomerViewModel vm}) {
    return SizedBox(
      width: double.infinity,
      height: isTablet ? 54 : 50,
      child: ElevatedButton(
        onPressed: () {
          final isNormal = _tabController.index == 0;

          if (isNormal) {
            if (!_normalFormKey.currentState!.validate()) return;
          } else {
            if (!_corporateFormKey.currentState!.validate()) return;
          }

          vm.saveAndProceed(
            isNormal: isNormal,
            onSuccess: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PosDepartmentView(
                    initialDepartmentId:
                        context.read<PosViewModel>().editDepartmentId,
                  ),
                ),
              );
            },
            onError: (message) {
              if (context.mounted) {
                ToastService.showError(context, message);
              }
            },
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.secondaryLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
          ),
        ),
        child: Text(
          l10n.posAddCustomerSaveButton,
          style: AppTextStyles.button.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: isTablet ? 15 : 15,
          ),
        ),
      ),
    );
  }
}

/// Loads a few customer rows when history fields gain focus so [Autocomplete]
/// shows suggestions before the user types (same search API + limit).
class _CustomerHistoryFieldFocusLoader extends StatefulWidget {
  const _CustomerHistoryFieldFocusLoader({
    required this.focusNode,
    required this.textEditingController,
    required this.vm,
    required this.child,
  });

  final FocusNode focusNode;
  final TextEditingController textEditingController;
  final AddCustomerViewModel vm;
  final Widget child;

  @override
  State<_CustomerHistoryFieldFocusLoader> createState() => _CustomerHistoryFieldFocusLoaderState();
}

class _CustomerHistoryFieldFocusLoaderState extends State<_CustomerHistoryFieldFocusLoader> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant _CustomerHistoryFieldFocusLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_onFocusChange);
      widget.focusNode.addListener(_onFocusChange);
    }
    if (oldWidget.textEditingController != widget.textEditingController) {
      // New Autocomplete internals after KeyedSubtree key change — prompt refresh if focused.
      if (widget.focusNode.hasFocus && widget.textEditingController.text.trim().isEmpty) {
        _afterHintsLoaded();
      }
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _kickAutocompleteRebuild() {
    // RawAutocomplete listens to TextEditingController; no public refresh API.
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    widget.textEditingController.notifyListeners();
  }

  void _onFocusChange() {
    if (!widget.focusNode.hasFocus) return;
    if (widget.textEditingController.text.trim().isNotEmpty) return;
    widget.vm.loadCustomerHistoryFocusHints().whenComplete(() {
      if (!mounted || !widget.focusNode.hasFocus) return;
      _kickAutocompleteRebuild();
    });
  }

  void _afterHintsLoaded() {
    widget.vm.loadCustomerHistoryFocusHints().whenComplete(() {
      if (!mounted || !widget.focusNode.hasFocus) return;
      _kickAutocompleteRebuild();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

enum VehicleLookupType { make, model }
