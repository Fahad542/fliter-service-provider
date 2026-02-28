import 'package:flutter/material.dart';
import '../../../../models/department_model.dart';
import '../../../../models/workshop_owner_models.dart';
import '../../../../utils/toast_service.dart';
import '../../../../data/repositories/owner_repository.dart';
import '../../../../services/session_service.dart';

class EmployeeManagementViewModel extends ChangeNotifier {
  final OwnerRepository ownerRepository;
  final SessionService sessionService;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController baseSalaryController = TextEditingController();
  final TextEditingController commissionPercentController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController openingBalanceController = TextEditingController();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<OwnerEmployee> _employees = [];
  List<OwnerEmployee> get employees => _employees;

  List<Branch> _branches = [];
  List<Branch> get branches => _branches;

  List<Department> _departments = [];
  List<Department> get departments => _departments;

  EmployeeManagementViewModel({
    required this.ownerRepository,
    required this.sessionService,
  }) {
    _init();
  }

  Future<void> _init() async {
    await fetchBranches();
    await fetchDepartments();
    await fetchEmployees();
  }

  Future<void> fetchDepartments() async {
    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) throw Exception('No token found');

      final response = await ownerRepository.getDepartments(token);
      if (response['success'] == true && response['departments'] != null) {
        _departments = (response['departments'] as List)
            .map((json) => Department.fromJson(json))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching departments: $e');
    }
  }

  Future<void> fetchBranches() async {
    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) throw Exception('No token found');

      final response = await ownerRepository.getBranches(token);
      if (response['success'] == true && response['branches'] != null) {
        _branches = (response['branches'] as List)
            .map((json) => Branch.fromJson(json))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching branches: $e');
    }
  }

  Future<void> fetchEmployees() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) throw Exception('No token found');

      final response = await ownerRepository.getTechnicians(token);
      if (response['success'] == true && response['technicians'] != null) {
        _employees = (response['technicians'] as List)
            .map((json) => OwnerEmployee.fromJson(json))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching technicians: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearForm() {
    nameController.clear();
    mobileController.clear();
    emailController.clear();
    passwordController.clear();
    departmentController.clear();
    baseSalaryController.clear();
    commissionPercentController.clear();
    addressController.clear();
    openingBalanceController.clear();
  }

  Future<void> submitTechnicianForm(
    BuildContext context, {
    required String? branchId,
    required String? departmentId,
    required bool isWorkshopTechnician,
  }) async {
    if (nameController.text.trim().isEmpty || 
        mobileController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        branchId == null ||
        departmentId == null) {
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
        "mobile": mobileController.text.trim(),
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
        "branchId": branchId,
        "technicianType": isWorkshopTechnician ? "workshop" : "oncall",
        "commissionPercent": double.tryParse(commissionPercentController.text.trim()) ?? 0,
        "departmentIds": [departmentId],
      };

      await ownerRepository.createTechnician(data, token);

      if (context.mounted) {
        ToastService.showSuccess(context, 'Technician Created Successfully');
        clearForm();
        Navigator.pop(context); // Close the sheet
        await fetchEmployees();
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, 'Failed to create technician');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitCashierForm(
    BuildContext context, {
    required String? branchId,
  }) async {
    if (nameController.text.trim().isEmpty || 
        mobileController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        branchId == null) {
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
        "mobile": mobileController.text.trim(),
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
        "branchId": branchId,
      };

      await ownerRepository.createCashier(data, token);

      if (context.mounted) {
        ToastService.showSuccess(context, 'Cashier Created Successfully');
        clearForm();
        Navigator.pop(context); // Close the sheet
        await fetchEmployees();
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, 'Failed to create cashier');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
    mobileController.dispose();
    emailController.dispose();
    passwordController.dispose();
    departmentController.dispose();
    baseSalaryController.dispose();
    commissionPercentController.dispose();
    addressController.dispose();
    openingBalanceController.dispose();
    super.dispose();
  }
}
