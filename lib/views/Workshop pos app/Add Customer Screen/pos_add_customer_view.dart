import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/toast_service.dart';
import '../../../widgets/pos_widgets.dart';
import '../../../utils/app_formatters.dart';
// import '../../Department/pos_department_view.dart';
import 'package:provider/provider.dart';
import '../Department/pos_department_view.dart';
import '../Home Screen/pos_view_model.dart';
import 'add_customer_view_model.dart';
class PosAddCustomerView extends StatefulWidget {
  final int initialTab;

  const PosAddCustomerView({super.key, this.initialTab = 0});

  @override
  State<PosAddCustomerView> createState() => _PosAddCustomerViewState();
}

class _PosAddCustomerViewState extends State<PosAddCustomerView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    if (posVm.corporateAccounts.isEmpty && !posVm.isCorpAccountsLoading) {
      posVm.fetchCorporateAccounts(silent: false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            appBar: PosScreenAppBar(title: 'Add New Customer'),
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
                tabs: const [
                  Tab(text: 'Normal Customer'),
                  Tab(text: 'Corporate Customer'),
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
            // Standard walk-in: customer name / VAT / mobile are collected before invoice (billing PATCH).
            _buildSectionHeader('Vehicle Information', isTablet: isTablet),
            SizedBox(height: isTablet ? 12.0 : 10.0),
            if (isTablet) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'Vehicle Number',
                      vm.vehicleNumberController,
                      Icons.confirmation_number_outlined,
                      isTablet: isTablet,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter vehicle number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      'Make',
                      vm.makeController,
                      Icons.directions_car_outlined,
                      isTablet: isTablet,
                    ),
                  ),
                ],
              ),
              SizedBox(height: fieldGap),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'VIN',
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
                          return 'Max 17 characters';
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
                    child: _buildTextField(
                      'Model',
                      vm.modelController,
                      Icons.model_training_outlined,
                      isTablet: isTablet,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      'Odometer',
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
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ] else ...[
              _buildTextField(
                'Vehicle Number',
                vm.vehicleNumberController,
                Icons.confirmation_number_outlined,
                isTablet: isTablet,
                enableSuggestions: false,
                autocorrect: false,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter vehicle number';
                  }
                  return null;
                },
              ),
              SizedBox(height: fieldGap),
              _buildTextField(
                'VIN',
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
                    return 'Max 17 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: fieldGap),
              _buildTextField(
                'Make',
                vm.makeController,
                Icons.directions_car_outlined,
                isTablet: isTablet,
                enableSuggestions: false,
                autocorrect: false,
              ),
              SizedBox(height: fieldGap),
              _buildTextField(
                'Model',
                vm.modelController,
                Icons.model_training_outlined,
                isTablet: isTablet,
                enableSuggestions: false,
                autocorrect: false,
              ),
              SizedBox(height: fieldGap),
              _buildTextField(
                'Odometer',
                vm.odoMeterController,
                Icons.speed_outlined,
                keyboardType: TextInputType.number,
                isTablet: isTablet,
                enableSuggestions: false,
                autocorrect: false,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
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
            _buildSectionHeader('Corporate Account', isTablet: isTablet),
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

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 14 : 12, vertical: isTablet ? 2 : 0),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: vm.selectedCorporate,
                      hint: Text(
                        posVm.corporateAccounts.isEmpty 
                            ? 'No Corporate Accounts Found' 
                            : 'Select Corporate Account',
                        style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey, fontSize: isTablet ? 14 : 13),
                      ),
                      isExpanded: true,
                      icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade400, size: isTablet ? 24 : 22),
                      items: posVm.corporateAccounts.map((corp) {
                        return DropdownMenuItem<String>(
                          value: corp.companyName,
                          child: Text(
                            corp.companyName,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: isTablet ? 14 : 13,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: posVm.corporateAccounts.isEmpty ? null : (value) {
                        if (value != null) {
                          final corpData = posVm.corporateAccounts.firstWhere(
                            (corp) => corp.companyName == value,
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

            // Auto-filled fields (read-only)
            if (vm.selectedCorporateData != null) ...[
              _buildSectionHeader('Company Details (Auto-filled)', isTablet: isTablet),
              SizedBox(height: isTablet ? 12.0 : 10.0),
              _buildReadOnlyField('Company Name', vm.selectedCorporateData!.companyName, Icons.business, isTablet: isTablet),
              SizedBox(height: fieldGap),
              _buildReadOnlyField(
                'VAT Number',
                vm.selectedCorporateData!.effectiveVatNumber ?? 'N/A',
                Icons.receipt_long_outlined,
                isTablet: isTablet,
              ),
              SizedBox(height: fieldGap),
              _buildReadOnlyField('Billing Address', vm.selectedCorporateData!.billingAddress ?? vm.selectedCorporateData!.address ?? 'N/A', Icons.location_on_outlined, isTablet: isTablet),
              SizedBox(height: isTablet ? 18.0 : 14.0),
            ],

            // Vehicle Section
            _buildSectionHeader('Vehicle Information', isTablet: isTablet),
            SizedBox(height: isTablet ? 12.0 : 10.0),
            if (isTablet) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'Vehicle Number',
                      vm.corpVehicleNumberController,
                      Icons.confirmation_number_outlined,
                      isTablet: isTablet,
                      enableSuggestions: false,
                      autocorrect: false,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      'Make',
                      vm.corpMakeController,
                      Icons.directions_car_outlined,
                      isTablet: isTablet,
                      enableSuggestions: false,
                      autocorrect: false,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
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
                    child: _buildTextField(
                      'VIN',
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
                          return 'Max 17 characters';
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
                    child: _buildTextField(
                      'Model',
                      vm.corpModelController,
                      Icons.model_training_outlined,
                      isTablet: isTablet,
                      enableSuggestions: false,
                      autocorrect: false,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      'Odometer',
                      vm.corpOdoMeterController,
                      Icons.speed_outlined,
                      keyboardType: TextInputType.number,
                      isTablet: isTablet,
                      enableSuggestions: false,
                      autocorrect: false,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ] else ...[
              _buildTextField(
                'Vehicle Number',
                vm.corpVehicleNumberController,
                Icons.confirmation_number_outlined,
                isTablet: isTablet,
                enableSuggestions: false,
                autocorrect: false,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter vehicle number';
                  }
                  return null;
                },
              ),
              SizedBox(height: fieldGap),
              _buildTextField(
                'VIN',
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
                    return 'Max 17 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: fieldGap),
              _buildTextField(
                'Make',
                vm.corpMakeController,
                Icons.directions_car_outlined,
                isTablet: isTablet,
                enableSuggestions: false,
                autocorrect: false,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter vehicle make';
                  }
                  return null;
                },
              ),
              SizedBox(height: fieldGap),
              _buildTextField(
                'Model',
                vm.corpModelController,
                Icons.model_training_outlined,
                isTablet: isTablet,
                enableSuggestions: false,
                autocorrect: false,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter vehicle model';
                  }
                  return null;
                },
              ),
              SizedBox(height: fieldGap),
              _buildTextField(
                'Odometer',
                vm.corpOdoMeterController,
                Icons.speed_outlined,
                keyboardType: TextInputType.number,
                isTablet: isTablet,
                enableSuggestions: false,
                autocorrect: false,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter odometer reading';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
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
    TextInputType keyboardType = TextInputType.text,
    bool isTablet = false,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    bool enableSuggestions = true,
    bool autocorrect = true,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      validator: (val) {
        if (val == null || val.isEmpty) return validator?.call(val);
        return validator?.call(EnglishNumberFormatter.convert(val));
      },
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
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
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.grey, fontSize: isTablet ? 14 : 13),
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

  Widget _buildReadOnlyField(String label, String value, IconData icon, {bool isTablet = false}) {
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
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 14 : 14,
                    color: AppColors.secondaryLight,
                  ),
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
          'Save & Proceed to Department',
          style: AppTextStyles.button.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: isTablet ? 15 : 15,
          ),
        ),
      ),
    );
  }
}
