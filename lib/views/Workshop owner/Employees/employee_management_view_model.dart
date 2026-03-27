import 'package:flutter/material.dart';
import '../../../../models/workshop_owner_models.dart';
import '../../../../models/department_model.dart';
import '../../../../data/repositories/owner_repository.dart';
import '../../../../services/session_service.dart';
import '../../../../utils/toast_service.dart';
import '../../../../services/owner_data_service.dart';

class EmployeeManagementViewModel extends ChangeNotifier {
  final OwnerRepository ownerRepository;
  final SessionService sessionService;
  final OwnerDataService ownerDataService;

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
  bool get isLoading => _isLoading; // Separated from ownerDataService loading for cleaner UI

  bool _isActionLoading = false;
  bool get isActionLoading => _isActionLoading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<OwnerEmployee> _employees = [];
  String? _editingEmployeeId;
  bool get isEditing => _editingEmployeeId != null;

  List<OwnerEmployee> get employees {
    if (_searchQuery.isEmpty) {
      return _employees;
    }
    return _employees.where((e) => 
      e.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      (e.email?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
      (e.mobile?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
    ).toList();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<Branch> get branches => ownerDataService.branches;
  List<Department> get departments => ownerDataService.departments;

  EmployeeManagementViewModel({
    required this.ownerRepository,
    required this.sessionService,
    required this.ownerDataService,
  }) {
    ownerDataService.addListener(notifyListeners);
    Future.microtask(() => _init());
  }

  Future<void> _init() async {
    await fetchEmployees();
    if (branches.isEmpty || departments.isEmpty) {
      await ownerDataService.refreshAll();
    }
  }

  Future<void> fetchEmployees({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) throw Exception('No token found');

      final response = await ownerRepository.getEmployees(token);
      if (response != null && response['success'] == true && response['employees'] != null) {
        _employees = (response['employees'] as List)
            .map((json) => OwnerEmployee.fromJson(json))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching employees: $e');
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
    _editingEmployeeId = null;
    notifyListeners();
  }

  void setEditEmployee(OwnerEmployee? e) {
    if (e == null) {
      clearForm();
    } else {
      _editingEmployeeId = e.id;
      nameController.text = e.name;
      mobileController.text = e.mobile ?? '';
      emailController.text = e.email ?? '';
      passwordController.clear(); // Don't pre-fill password
      commissionPercentController.text = e.techCommission?.toString() ?? '0';
      // Note: branch and department will be handled in the UI
    }
    notifyListeners();
  }

  Future<void> submitTechnicianForm(
    BuildContext context, {
    required String? branchId,
    required String? departmentId,
    required bool isWorkshop,
    required bool isOnCall,
  }) async {
    if (nameController.text.trim().isEmpty ||
        mobileController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        (!isEditing && passwordController.text.trim().isEmpty)) {
      ToastService.showError(context, 'Please fill in all required text fields.');
      return;
    }

    if (!isWorkshop && !isOnCall) {
      ToastService.showError(context, 'Please select at least one technician type.');
      return;
    }

    if (branchId == null || branchId.isEmpty) {
      ToastService.showError(context, 'Please create a branch first to assign this employee.');
      return;
    }

    if (departmentId == null || departmentId.isEmpty) {
      ToastService.showError(context, 'Please create a department first to assign this employee.');
      return;
    }

    _isActionLoading = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) throw Exception('No token found');

      String techType = "workshop";
      if (isWorkshop && isOnCall) {
        techType = "both";
      } else if (isOnCall) {
        techType = "oncall";
      }

      final data = {
        "name": nameController.text.trim(),
        "mobile": mobileController.text.trim(),
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
        "branchId": branchId,
        "technicianType": techType,
        "commissionPercent": double.tryParse(commissionPercentController.text.trim()) ?? 0,
        "departmentIds": [departmentId],
      };

      if (passwordController.text.trim().isNotEmpty) {
        data["password"] = passwordController.text.trim();
      }

      if (_editingEmployeeId == null) {
        await ownerRepository.createTechnician(data, token);
        if (context.mounted) ToastService.showSuccess(context, 'Technician Created Successfully');
      } else {
        await ownerRepository.updateTechnician(token, _editingEmployeeId!, data);
        if (context.mounted) ToastService.showSuccess(context, 'Technician Updated Successfully');
      }

      if (context.mounted) {
        setEditEmployee(null);
        Navigator.pop(context); // Close the sheet
        await fetchEmployees(silent: true);
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, 'Failed to create technician');
      }
    } finally {
      _isActionLoading = false;
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
        (!isEditing && passwordController.text.trim().isEmpty)) {
      ToastService.showError(context, 'Please fill in all required text fields.');
      return;
    }

    if (branchId == null || branchId.isEmpty) {
      ToastService.showError(context, 'Please create a branch first to assign this cashier.');
      return;
    }

    _isActionLoading = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) throw Exception('No token found');

      final data = {
        "name": nameController.text.trim(),
        "mobile": mobileController.text.trim(),
        "email": emailController.text.trim(),
        "branchId": branchId,
      };

      if (passwordController.text.trim().isNotEmpty) {
        data["password"] = passwordController.text.trim();
      }

      if (_editingEmployeeId == null) {
        await ownerRepository.createCashier(data, token);
        if (context.mounted) ToastService.showSuccess(context, 'Cashier Created Successfully');
      } else {
        await ownerRepository.updateCashier(token, _editingEmployeeId!, data);
        if (context.mounted) ToastService.showSuccess(context, 'Cashier Updated Successfully');
      }

      if (context.mounted) {
        setEditEmployee(null);
        Navigator.pop(context); // Close the sheet
        await fetchEmployees(silent: true);
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, 'Failed to create cashier');
      }
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteEmployee(BuildContext context, String id, String role) async {
    _isActionLoading = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) return;

      if (role.toLowerCase().contains('technician')) {
        await ownerRepository.deleteTechnician(token, id);
      } else {
        await ownerRepository.deleteCashier(token, id);
      }

      if (context.mounted) {
        ToastService.showSuccess(context, 'Employee Deleted Successfully');
        await fetchEmployees(silent: true);
      }
    } catch (e) {
      if (context.mounted) ToastService.showError(context, 'Failed to delete employee');
    } finally {
      _isActionLoading = false;
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

    _isActionLoading = true;
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
      _isActionLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    ownerDataService.removeListener(notifyListeners);
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
