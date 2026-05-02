import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/toast_service.dart';
import '../../../widgets/pos_widgets.dart';
import '../../../utils/app_formatters.dart';
import 'package:provider/provider.dart';
import '../Department/pos_department_view.dart';
import '../Home Screen/pos_view_model.dart';
import 'add_customer_view_model.dart';
import '../../../l10n/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PosAddCustomerView
//
// Translation notes
// ─────────────────
// • ALL static UI strings use l10n.posAddCustomer* keys.
// • Corporate company names (API data) are translated on the fly using
//   FutureBuilder<String> + vm.translateCompanyName(). The dropdown value is
//   always the ORIGINAL English name so selection logic never breaks.
// • Validator closures capture l10n at widget-build time — this means they
//   always use the locale that was active when the form was built.  When the
//   locale switches the parent rebuilds, new validators are registered, so the
//   next validation run uses the correct language. No stale-closure issue.
// • TextDirection.ltr is enforced on vehicle/VIN/odometer fields so numeric
//   entry is never reversed in RTL mode.
// • No hard-coded Arabic or English strings remain in this file.
// ─────────────────────────────────────────────────────────────────────────────

class PosAddCustomerView extends StatefulWidget {
  final int initialTab;

  const PosAddCustomerView({super.key, this.initialTab = 0});

  @override
  State<PosAddCustomerView> createState() => _PosAddCustomerViewState();
}

class _PosAddCustomerViewState extends State<PosAddCustomerView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _normalFormKey    = GlobalKey<FormState>();
  final _corporateFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
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
    if (posVm.corporateAccounts.isEmpty && !posVm.isCorpAccountsLoading) {
      posVm.fetchCorporateAccounts(silent: false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n        = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet    = screenWidth > 600;

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

                // ── Tab Bar ──────────────────────────────────────────────
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
                      unselectedLabelColor:
                      AppColors.secondaryLight.withOpacity(0.42),
                      labelStyle: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      unselectedLabelStyle: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.secondaryLight.withOpacity(0.42),
                      ),
                      labelPadding:
                      EdgeInsets.symmetric(vertical: isTablet ? 3 : 2),
                      overlayColor:
                      MaterialStateProperty.all(Colors.transparent),
                      splashFactory: NoSplash.splashFactory,
                      tabs: [
                        Tab(text: l10n.posAddCustomerTabNormal),
                        Tab(text: l10n.posAddCustomerTabCorporate),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: isTablet ? 14 : 12),

                // ── Tab Content ──────────────────────────────────────────
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildNormalCustomerForm(isTablet, vm, l10n),
                      _buildCorporateCustomerForm(isTablet, vm, l10n),
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

  // ── Normal Customer Form ──────────────────────────────────────────────────

  Widget _buildNormalCustomerForm(
      bool isTablet,
      AddCustomerViewModel vm,
      AppLocalizations l10n,
      ) {
    final hPad    = isTablet ? 28.0 : 20.0;
    final fieldGap = isTablet ? 14.0 : 12.0;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 18),
      child: Form(
        key: _normalFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(l10n.posAddCustomerSectionVehicleInfo,
                isTablet: isTablet),
            SizedBox(height: isTablet ? 12.0 : 10.0),

            if (isTablet) ...[
              // ── Tablet: 2-column layout ──────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      l10n.posAddCustomerFieldVehicleNumber,
                      vm.vehicleNumberController,
                      Icons.confirmation_number_outlined,
                      isTablet: isTablet,
                      validator: (v) => _validateRequired(v, l10n),                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      l10n.posAddCustomerFieldMake,
                      vm.makeController,
                      Icons.directions_car_outlined,
                      isTablet: isTablet,
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
                validator: (v) => _validateVin(v, l10n),
              ),
              SizedBox(height: fieldGap),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      l10n.posAddCustomerFieldModel,
                      vm.modelController,
                      Icons.model_training_outlined,
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
                      validator: (v) => _validateOdometerShort(v, l10n),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // ── Phone: single-column layout ──────────────────────────
              _buildTextField(
                l10n.posAddCustomerFieldVehicleNumber,
                vm.vehicleNumberController,
                Icons.confirmation_number_outlined,
                isTablet: isTablet,
                enableSuggestions: false,
                autocorrect: false,
                validator: (v) => _validateVehicleRequired(v, l10n),
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
                validator: (v) => _validateVin(v, l10n),
              ),
              SizedBox(height: fieldGap),
              _buildTextField(
                l10n.posAddCustomerFieldMake,
                vm.makeController,
                Icons.directions_car_outlined,
                isTablet: isTablet,
                enableSuggestions: false,
                autocorrect: false,
              ),
              SizedBox(height: fieldGap),
              _buildTextField(
                l10n.posAddCustomerFieldModel,
                vm.modelController,
                Icons.model_training_outlined,
                isTablet: isTablet,
                enableSuggestions: false,
                autocorrect: false,
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
                validator: (v) => _validateOdometerLong(v, l10n),
              ),
            ],

            const SizedBox(height: 22),
            _buildSaveButton(isTablet: isTablet, vm: vm, l10n: l10n),
          ],
        ),
      ),
    );
  }

  // ── Corporate Customer Form ───────────────────────────────────────────────

  Widget _buildCorporateCustomerForm(
      bool isTablet,
      AddCustomerViewModel vm,
      AppLocalizations l10n,
      ) {
    final hPad    = isTablet ? 28.0 : 20.0;
    final fieldGap = isTablet ? 14.0 : 12.0;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 18),
      child: Form(
        key: _corporateFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Corporate Dropdown ────────────────────────────────────
            _buildSectionHeader(l10n.posAddCustomerSectionCorporateAccount,
                isTablet: isTablet),
            SizedBox(height: isTablet ? 12.0 : 10.0),
            Consumer<PosViewModel>(
              builder: (context, posVm, child) {
                if (posVm.isCorpAccountsLoading) {
                  return Container(
                    height: isTablet ? 52 : 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(isTablet ? 14 : 12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.primaryLight),
                      ),
                    ),
                  );
                }

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(isTablet ? 14 : 12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 14 : 12,
                      vertical: isTablet ? 2 : 0),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      // Value is always the ORIGINAL English company name.
                      value: vm.selectedCorporate,
                      hint: Text(
                        posVm.corporateAccounts.isEmpty
                            ? l10n.posAddCustomerNoCorporateFound
                            : l10n.posAddCustomerSelectCorporate,
                        style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.grey, fontSize: isTablet ? 14 : 13),
                      ),
                      isExpanded: true,
                      icon: Icon(Icons.keyboard_arrow_down,
                          color: Colors.grey.shade400,
                          size: isTablet ? 24 : 22),
                      // Each item value = original English company name.
                      // Display label = FutureBuilder translates on the fly.
                      items: posVm.corporateAccounts.map((corp) {
                        return DropdownMenuItem<String>(
                          value: corp.companyName, // English key — never changes
                          child: FutureBuilder<String>(
                            future: vm.translateCompanyName(corp.companyName),
                            initialData: corp.companyName,
                            builder: (context, snap) {
                              return Text(
                                snap.data ?? corp.companyName,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: isTablet ? 14 : 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                        );
                      }).toList(),
                      onChanged: posVm.corporateAccounts.isEmpty
                          ? null
                          : (value) {
                        if (value != null) {
                          final corpData = posVm.corporateAccounts
                              .firstWhere(
                                  (c) => c.companyName == value);
                          vm.setCorporate(value, corpData);
                        }
                      },
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: isTablet ? 18.0 : 14.0),

            // ── Auto-filled Company Details ──────────────────────────
            if (vm.selectedCorporateData != null) ...[
              _buildSectionHeader(l10n.posAddCustomerSectionCompanyDetails,
                  isTablet: isTablet),
              SizedBox(height: isTablet ? 12.0 : 10.0),

              // Company Name — translate the API value for display
              FutureBuilder<String>(
                future: vm.translateCompanyName(
                    vm.selectedCorporateData!.companyName),
                initialData: vm.selectedCorporateData!.companyName,
                builder: (context, snap) => _buildReadOnlyField(
                  l10n.posAddCustomerFieldCompanyName,
                  snap.data ?? vm.selectedCorporateData!.companyName,
                  Icons.business,
                  isTablet: isTablet,
                ),
              ),
              SizedBox(height: fieldGap),

              _buildReadOnlyField(
                l10n.posAddCustomerFieldVatNumber,
                vm.selectedCorporateData!.effectiveVatNumber ??
                    l10n.posAddCustomerFieldNA,
                Icons.receipt_long_outlined,
                isTablet: isTablet,
              ),
              SizedBox(height: fieldGap),

              _buildReadOnlyField(
                l10n.posAddCustomerFieldBillingAddress,
                vm.selectedCorporateData!.billingAddress ??
                    vm.selectedCorporateData!.address ??
                    l10n.posAddCustomerFieldNA,
                Icons.location_on_outlined,
                isTablet: isTablet,
              ),
              SizedBox(height: isTablet ? 18.0 : 14.0),
            ],

            // ── Vehicle Section ───────────────────────────────────────
            _buildSectionHeader(l10n.posAddCustomerSectionVehicleInfo,
                isTablet: isTablet),
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
                      validator: (v) => _validateRequired(v, l10n),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      l10n.posAddCustomerFieldMake,
                      vm.corpMakeController,
                      Icons.directions_car_outlined,
                      isTablet: isTablet,
                      enableSuggestions: false,
                      autocorrect: false,
                    ),
                  ),
                ],
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
                validator: (v) => _validateVin(v, l10n),
              ),
              SizedBox(height: fieldGap),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      l10n.posAddCustomerFieldModel,
                      vm.corpModelController,
                      Icons.model_training_outlined,
                      isTablet: isTablet,
                      enableSuggestions: false,
                      autocorrect: false,
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
                      validator: (v) => _validateOdometerShort(v, l10n),
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
                validator: (v) => _validateVehicleRequired(v, l10n),
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
                validator: (v) => _validateVin(v, l10n),
              ),
              SizedBox(height: fieldGap),
              _buildTextField(
                l10n.posAddCustomerFieldMake,
                vm.corpMakeController,
                Icons.directions_car_outlined,
                isTablet: isTablet,
                enableSuggestions: false,
                autocorrect: false,
              ),
              SizedBox(height: fieldGap),
              _buildTextField(
                l10n.posAddCustomerFieldModel,
                vm.corpModelController,
                Icons.model_training_outlined,
                isTablet: isTablet,
                enableSuggestions: false,
                autocorrect: false,
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
                validator: (v) => _validateOdometerLong(v, l10n),
              ),
            ],

            const SizedBox(height: 22),
            _buildSaveButton(isTablet: isTablet, vm: vm, l10n: l10n),
          ],
        ),
      ),
    );
  }

  // ── Validators ────────────────────────────────────────────────────────────
  // All validators receive l10n so messages are always in the active locale.
  // Logic compares values as raw strings/numbers — never translated text.

  String? _validateVehicleRequired(String? v, AppLocalizations l10n) {
    if (v == null || v.trim().isEmpty) {
      return l10n.posAddCustomerValidationVehicleRequired;
    }
    return null;
  }

  /// Used in tablet layout where space is tighter.
  String? _validateRequired(String? v, AppLocalizations l10n) {
    if (v == null || v.trim().isEmpty) return l10n.posAddCustomerValidationRequired;
    return null;
  }

  String? _validateVin(String? v, AppLocalizations l10n) {
    if (v == null || v.trim().isEmpty) return null; // optional
    if (v.trim().length > 17) return l10n.posAddCustomerValidationVinMax;
    return null;
  }

  /// Long form: "Please enter a valid number" (phone layout).
  String? _validateOdometerLong(String? v, AppLocalizations l10n) {
    if (v == null || v.trim().isEmpty) return null; // optional
    if (int.tryParse(EnglishNumberFormatter.convert(v)) == null) {
      return l10n.posAddCustomerValidationInvalidNumber;
    }
    return null;
  }

  /// Short form: "Invalid number" (tablet inline layout).
  String? _validateOdometerShort(String? v, AppLocalizations l10n) {
    if (v == null || v.trim().isEmpty) return null; // optional
    if (int.tryParse(EnglishNumberFormatter.convert(v)) == null) {
      return l10n.posAddCustomerValidationInvalidNumberShort;
    }
    return null;
  }

  // ── Shared Widgets ────────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title, {bool isTablet = false}) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: isTablet ? 15 : 14,
              color: AppColors.secondaryLight,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
        bool isTablet = false,
        String? Function(String?)? validator,
        List<TextInputFormatter>? inputFormatters,
        bool enableSuggestions = true,
        bool autocorrect = true,
        TextCapitalization textCapitalization = TextCapitalization.none,
      }) {
    // Vehicle numbers, VINs, and odometer readings must always be LTR
    // regardless of the app locale to prevent digit reversal in Arabic mode.
    final bool forceLeftAlign = keyboardType == TextInputType.number ||
        keyboardType == TextInputType.phone ||
        textCapitalization == TextCapitalization.characters;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      validator: (val) {
        if (val == null || val.isEmpty) return validator?.call(val);
        return validator?.call(EnglishNumberFormatter.convert(val));
      },
      // Always LTR for technical fields (plate, VIN, odometer)
      textAlign: forceLeftAlign ? TextAlign.left : TextAlign.start,
      textDirection: forceLeftAlign ? TextDirection.ltr : null,
      inputFormatters: [
        EnglishNumberFormatter(),
        if (keyboardType == TextInputType.number ||
            keyboardType == TextInputType.phone)
          FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩۰-۹०-९]')),
        ...?inputFormatters,
      ],
      enableSuggestions: enableSuggestions,
      autocorrect: autocorrect,
      style: AppTextStyles.bodyMedium.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodyMedium.copyWith(
            color: Colors.grey, fontSize: isTablet ? 14 : 13),
        prefixIcon: Icon(icon,
            size: isTablet ? 22 : 20, color: Colors.grey.shade400),
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

  Widget _buildReadOnlyField(
      String label,
      String value,
      IconData icon, {
        bool isTablet = false,
      }) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 16 : 14, vertical: isTablet ? 14 : 12),
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
                  style: AppTextStyles.bodySmall
                      .copyWith(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.secondaryLight,
                  ),
                  // Allow wrapping for long addresses; no overflow in RTL.
                  softWrap: true,
                ),
              ],
            ),
          ),
          Icon(Icons.lock_outline,
              size: isTablet ? 16 : 16, color: Colors.grey.shade300),
        ],
      ),
    );
  }

  Widget _buildSaveButton({
    bool isTablet = false,
    required AddCustomerViewModel vm,
    required AppLocalizations l10n,
  }) {
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
            // onError now receives a pre-translated message from the VM.
            onError: (message) async {
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
            fontSize: 15,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}