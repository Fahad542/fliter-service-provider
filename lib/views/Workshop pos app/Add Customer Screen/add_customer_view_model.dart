import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Home Screen/pos_view_model.dart';

class AddCustomerViewModel extends ChangeNotifier {
  final BuildContext context;

  AddCustomerViewModel(this.context);

  // Controllers for Normal Customer
  final TextEditingController nameController = TextEditingController();
  final TextEditingController vatController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController makeController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController odoMeterController = TextEditingController();

  // Controllers for Corporate Customer
  final TextEditingController corpVehicleNumberController =
      TextEditingController();
  final TextEditingController corpMakeController = TextEditingController();
  final TextEditingController corpModelController = TextEditingController();
  final TextEditingController corpOdoMeterController = TextEditingController();

  String? _selectedCorporate;
  Map<String, String>? _selectedCorporateData;

  String? get selectedCorporate => _selectedCorporate;
  Map<String, String>? get selectedCorporateData => _selectedCorporateData;

  void setCorporate(String name, Map<String, String>? data) {
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
      name: nameController.text.trim(),
      vat: vatController.text.trim(),
      mobile: mobileController.text.trim(),
      vehicleNumber: isNormal
          ? vehicleNumberController.text.trim()
          : corpVehicleNumberController.text.trim(),
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
  }

  @override
  void dispose() {
    nameController.dispose();
    vatController.dispose();
    mobileController.dispose();
    vehicleNumberController.dispose();
    makeController.dispose();
    modelController.dispose();
    odoMeterController.dispose();
    corpVehicleNumberController.dispose();
    corpMakeController.dispose();
    corpModelController.dispose();
    corpOdoMeterController.dispose();
    super.dispose();
  }
}
