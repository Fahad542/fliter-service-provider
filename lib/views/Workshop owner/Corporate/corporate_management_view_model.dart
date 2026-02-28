import 'package:filter_service_providers/data/repositories/owner_repository.dart';
import 'package:flutter/material.dart';
import '../../../../models/workshop_owner_models.dart';
import '../../../../utils/toast_service.dart';
import '../../../../data/repositories/owner_repository.dart';
import '../../../../services/session_service.dart';

class CorporateManagementViewModel extends ChangeNotifier {
  final OwnerRepository ownerRepository;
  final SessionService sessionService;
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController vatNumberController = TextEditingController();
  final TextEditingController contactNameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController creditLimitController = TextEditingController();

  final TextEditingController userNameController = TextEditingController();
  final TextEditingController userEmailController = TextEditingController();
  final TextEditingController userPasswordController = TextEditingController();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<CorporateCustomer> _corporateCustomers = [];
  List<CorporateCustomer> get corporateCustomers => _corporateCustomers;

  CorporateManagementViewModel({
    required this.ownerRepository,
    required this.sessionService,
  }) {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(seconds: 1));
    _corporateCustomers = [
      CorporateCustomer(id: '1', companyName: 'Aramco Logistics', vatNumber: '300099887766', contactName: 'John Doe', mobile: '0567788990', email: 'logistics@aramco.com', allowedBranchIds: ['1', '2'], category: 'Gold', totalSales: 450000.0, vehicleCount: 25),
      CorporateCustomer(id: '2', companyName: 'Sabic Transport', vatNumber: '300055443322', contactName: 'Jane Smith', mobile: '0544332211', email: 'fleet@sabic.com', allowedBranchIds: ['1', '3'], category: 'Silver', totalSales: 210000.0, vehicleCount: 12),
    ];

    _isLoading = false;
    notifyListeners();
  }

  void clearForm() {
    companyNameController.clear();
    vatNumberController.clear();
    contactNameController.clear();
    mobileController.clear();
    emailController.clear();
    creditLimitController.clear();

    userNameController.clear();
    userEmailController.clear();
    userPasswordController.clear();
  }

  Future<void> submitCorporateForm(BuildContext context) async {
    if (companyNameController.text.trim().isEmpty || 
        contactNameController.text.trim().isEmpty ||
        mobileController.text.trim().isEmpty ||
        vatNumberController.text.trim().isEmpty) {
      ToastService.showError(context, 'Please fill in all required fields');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) throw Exception('No token found');

      final data = {
        "companyName": companyNameController.text.trim(),
        "customerName": contactNameController.text.trim(),
        "mobile": mobileController.text.trim(),
        "taxId": vatNumberController.text.trim(),
        "creditLimit": double.tryParse(creditLimitController.text.trim()) ?? 0,
      };

      await ownerRepository.createCorporateAccount(data, token);

      if (context.mounted) {
        ToastService.showSuccess(context, 'Corporate Account Created Successfully');
        clearForm();
        Navigator.pop(context); // Close the sheet
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, 'Failed to create corporate account');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitCorporateUserForm(BuildContext context, String corporateAccountId) async {
    if (userNameController.text.trim().isEmpty || 
        userEmailController.text.trim().isEmpty ||
        userPasswordController.text.trim().isEmpty) {
      ToastService.showError(context, 'Please fill in all required fields');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) throw Exception('No token found');

      final data = {
        "name": userNameController.text.trim(),
        "email": userEmailController.text.trim(),
        "password": userPasswordController.text.trim(),
        "corporateAccountId": corporateAccountId,
      };

      await ownerRepository.createCorporateUser(data, token);

      if (context.mounted) {
        ToastService.showSuccess(context, 'Corporate User Created Successfully');
        clearForm();
        Navigator.pop(context); // Close the sheet
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, 'Failed to create corporate user');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    companyNameController.dispose();
    vatNumberController.dispose();
    contactNameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    creditLimitController.dispose();
    userNameController.dispose();
    userEmailController.dispose();
    userPasswordController.dispose();
    super.dispose();
  }
}
