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

  bool _isListLoading = false;
  bool get isListLoading => _isListLoading;

  List<CorporateCustomer> _corporateCustomers = [];
  List<CorporateCustomer> get corporateCustomers => _corporateCustomers;

  CorporateManagementViewModel({
    required this.ownerRepository,
    required this.sessionService,
  }) {
    Future.microtask(_init);
  }

  Future<void> _init() async {
    _isListLoading = true;
    notifyListeners();
    
    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token != null) {
        final response = await ownerRepository.getCorporateCustomers(token);
        if (response['success'] == true && response['corporateCustomers'] != null) {
          _corporateCustomers = (response['corporateCustomers'] as List)
              .map((e) => CorporateCustomer.fromJson(e))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching corporate customers: $e');
    }

    _isListLoading = false;
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
        _init(); // Refresh list automatically
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
