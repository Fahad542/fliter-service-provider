import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Home Screen/pos_view_model.dart';
import '../../../models/cashier_corporate_accounts_api_model.dart';

class AddCustomerViewModel extends ChangeNotifier {
  final BuildContext context;

  AddCustomerViewModel(this.context) {
    _hydrateFromSavedCustomer();
  }

  // Controllers for Normal Customer
  final TextEditingController nameController = TextEditingController();
  final TextEditingController vatController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController vinNumberController = TextEditingController();
  final TextEditingController makeController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController odoMeterController = TextEditingController();

  // Controllers for Corporate Customer
  final TextEditingController corpVehicleNumberController =
      TextEditingController();
  final TextEditingController corpVinNumberController =
      TextEditingController();
  final TextEditingController corpMakeController = TextEditingController();
  final TextEditingController corpModelController = TextEditingController();
  final TextEditingController corpOdoMeterController = TextEditingController();

  String? _selectedCorporate;
  CashierCorporateAccount? _selectedCorporateData;

  String? get selectedCorporate => _selectedCorporate;
  CashierCorporateAccount? get selectedCorporateData => _selectedCorporateData;

  void _hydrateFromSavedCustomer() {
    final vm = context.read<PosViewModel>();
    nameController.text = vm.customerName;
    vatController.text = vm.vatNumber;
    mobileController.text = vm.mobile;
    vehicleNumberController.text = vm.vehicleNumber;
    vinNumberController.text = vm.vinNumber;
    makeController.text = vm.make;
    modelController.text = vm.model;
    odoMeterController.text = vm.odometerReading > 0
        ? vm.odometerReading.toString()
        : '';
  }

  void setCorporate(String name, CashierCorporateAccount? data) {
    _selectedCorporate = name;
    _selectedCorporateData = data;
    notifyListeners();
  }

  void saveAndProceed({
    required bool isNormal,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) {
    final vm = context.read<PosViewModel>();

    vm.saveCustomerAndProceed(
      isNormal: isNormal,
      name: isNormal ? '' : nameController.text.trim(),
      vat: isNormal ? '' : vatController.text.trim(),
      mobile: isNormal ? '' : mobileController.text.trim(),
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
      onError: onError,
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
    _selectedCorporate = null;
    _selectedCorporateData = null;
    notifyListeners();
  }

  @override
  void dispose() {
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
