import 'package:flutter/material.dart';
import '../../../../utils/toast_service.dart';
import '../../../../data/repositories/owner_repository.dart';
import '../../../../services/session_service.dart';

class SuppliersViewModel extends ChangeNotifier {
  final OwnerRepository ownerRepository;
  final SessionService sessionService;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController openingBalanceController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  SuppliersViewModel({
    required this.ownerRepository,
    required this.sessionService,
  });

  void clearForm() {
    nameController.clear();
    emailController.clear();
    mobileController.clear();
    addressController.clear();
    openingBalanceController.clear();
    passwordController.clear();
  }

  Future<void> submitSupplierForm(BuildContext context) async {
    if (nameController.text.trim().isEmpty || 
        emailController.text.trim().isEmpty || 
        mobileController.text.trim().isEmpty || 
        addressController.text.trim().isEmpty || 
        passwordController.text.trim().isEmpty) {
      ToastService.showError(context, 'Please fill in all required fields');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) throw Exception('No token found');

      final data = {
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "mobile": mobileController.text.trim(),
        "address": addressController.text.trim(),
        "openingBalance": double.tryParse(openingBalanceController.text.trim()) ?? 0,
        "password": passwordController.text.trim(),
      };

      await ownerRepository.createSupplier(data, token);

      if (context.mounted) {
        ToastService.showSuccess(context, 'Supplier Created Successfully');
        clearForm();
        Navigator.pop(context); // Close the sheet
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, 'Failed to create supplier');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    addressController.dispose();
    openingBalanceController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
