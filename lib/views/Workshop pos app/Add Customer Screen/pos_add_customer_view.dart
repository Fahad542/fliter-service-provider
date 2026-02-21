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
            appBar: const PosScreenAppBar(title: 'Add New Customer'),
            body: Column(
              children: [
          const SizedBox(height: 20),

          // Tab Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
              ),
              padding: EdgeInsets.all(isTablet ? 5 : 4),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: AppColors.secondaryLight,
                unselectedLabelColor: Colors.grey,
                labelStyle: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: isTablet ? 15 : 13,
                ),
                unselectedLabelStyle: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: isTablet ? 15 : 13,
                ),
                labelPadding: EdgeInsets.symmetric(vertical: isTablet ? 4 : 0),
                tabs: const [
                  Tab(text: 'Normal Customer'),
                  Tab(text: 'Corporate Customer'),
                ],
              ),
            ),
          ),
          SizedBox(height: isTablet ? 20 : 16),

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
    final hPad = isTablet ? 32.0 : 24.0;
    final fieldGap = isTablet ? 18.0 : 14.0;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 24),
      child: Form(
        key: _normalFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              'Customer Name',
              vm.nameController,
              Icons.person_outline,
              isTablet: isTablet,
              enableSuggestions: true,
              autocorrect: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter customer name';
                }
                return null;
              },
            ),
            SizedBox(height: fieldGap),
            _buildTextField(
              'VAT Number',
              vm.vatController,
              Icons.receipt_long_outlined,
              keyboardType: TextInputType.number,
              isTablet: isTablet,
              enableSuggestions: false,
              autocorrect: false,
              validator: (value) {
                if (value != null && value.isNotEmpty && !RegExp(r'^[0-9٠-٩۰-۹०-९]+$').hasMatch(value)) {
                  return 'Please enter a valid VAT number';
                }
                return null;
              },
            ),
            SizedBox(height: fieldGap),
            _buildTextField(
              'Mobile Number',
              vm.mobileController,
              Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              isTablet: isTablet,
              enableSuggestions: false,
              autocorrect: false,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter mobile number';
                }
                if (value.length < 8) {
                  return 'Please enter a valid mobile number';
                }
                return null;
              },
            ),
            SizedBox(height: isTablet ? 24.0 : 20.0),

            // Vehicle Section
            _buildSectionHeader('Vehicle Information', isTablet: isTablet),
            SizedBox(height: isTablet ? 16.0 : 12.0),
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
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      'Make',
                      vm.makeController,
                      Icons.directions_car_outlined,
                      isTablet: isTablet,
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
                      'Model',
                      vm.modelController,
                      Icons.model_training_outlined,
                      isTablet: isTablet,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
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
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
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
                'Make',
                vm.makeController,
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
                vm.modelController,
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
                vm.odoMeterController,
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

            const SizedBox(height: 32),
            _buildSaveButton(isTablet: isTablet, vm: vm),
          ],
        ),
      ),
    );
  }

  // ── Corporate Customer Form ──
  Widget _buildCorporateCustomerForm(bool isTablet, AddCustomerViewModel vm) {
    final hPad = isTablet ? 32.0 : 24.0;
    final fieldGap = isTablet ? 18.0 : 14.0;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 24),
      child: Form(
        key: _corporateFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Corporate Dropdown
            _buildSectionHeader('Corporate Account', isTablet: isTablet),
            SizedBox(height: isTablet ? 16.0 : 12.0),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16, vertical: isTablet ? 4 : 0),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: vm.selectedCorporate,
                  hint: Text(
                    'Select Corporate Account',
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey, fontSize: isTablet ? 15 : 13),
                  ),
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade400, size: isTablet ? 28 : 24),
                  items: context.read<PosViewModel>().corporateList.map((corp) {
                    return DropdownMenuItem<String>(
                      value: corp['name'],
                      child: Text(
                        corp['name']!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: isTablet ? 15 : 13,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      final corpData = context.read<PosViewModel>().corporateList.firstWhere(
                        (corp) => corp['name'] == value,
                      );
                      vm.setCorporate(value, corpData);
                    }
                  },
                ),
              ),
            ),

            SizedBox(height: isTablet ? 24.0 : 20.0),

            // Auto-filled fields (read-only)
            if (vm.selectedCorporateData != null) ...[
              _buildSectionHeader('Company Details (Auto-filled)', isTablet: isTablet),
              SizedBox(height: isTablet ? 16.0 : 12.0),
              _buildReadOnlyField('Company Name', vm.selectedCorporateData!['name']!, Icons.business, isTablet: isTablet),
              SizedBox(height: fieldGap),
              _buildReadOnlyField('VAT Number', vm.selectedCorporateData!['vat']!, Icons.receipt_long_outlined, isTablet: isTablet),
              SizedBox(height: fieldGap),
              _buildReadOnlyField('Billing Address', vm.selectedCorporateData!['address']!, Icons.location_on_outlined, isTablet: isTablet),
              SizedBox(height: isTablet ? 24.0 : 20.0),
            ],

            // Vehicle Section
            _buildSectionHeader('Vehicle Information', isTablet: isTablet),
            SizedBox(height: isTablet ? 16.0 : 12.0),
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
                  const SizedBox(width: 16),
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
                  const SizedBox(width: 16),
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

            const SizedBox(height: 32),
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
          width: isTablet ? 5 : 4,
          height: isTablet ? 22 : 18,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: isTablet ? 10 : 8),
        Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: isTablet ? 16 : 14,
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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
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
      style: AppTextStyles.bodyMedium.copyWith(fontSize: isTablet ? 15 : 13, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.grey, fontSize: isTablet ? 15 : 13),
        prefixIcon: Icon(icon, size: isTablet ? 24 : 20, color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.fromLTRB(isTablet ? 12 : 8, isTablet ? 18 : 14, isTablet ? 12 : 8, isTablet ? 18 : 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
          borderSide: BorderSide.none,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
          borderSide: BorderSide.none,
        ),
        errorStyle: const TextStyle(fontSize: 11, height: 1),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon, {bool isTablet = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16, vertical: isTablet ? 18 : 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: isTablet ? 24 : 20, color: Colors.grey.shade400),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.grey, fontSize: isTablet ? 12 : 10),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 15 : 13,
                    color: AppColors.secondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.lock_outline, size: isTablet ? 16 : 14, color: Colors.grey.shade300),
        ],
      ),
    );
  }

  Widget _buildSaveButton({bool isTablet = false, required AddCustomerViewModel vm}) {
    return SizedBox(
      width: double.infinity,
      height: isTablet ? 58 : 52,
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
                  builder: (_) => const PosDepartmentView(),
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
            borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
          ),
        ),
        child: Text(
          'Save & Proceed to Department',
          style: AppTextStyles.button.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: isTablet ? 17 : 15,
          ),
        ),
      ),
    );
  }
}
