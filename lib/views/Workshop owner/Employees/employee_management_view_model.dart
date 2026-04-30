import 'package:flutter/material.dart';
import '../../../../models/workshop_owner_models.dart';
import '../../../../models/department_model.dart';
import '../../../../data/repositories/owner_repository.dart';
import '../../../../services/session_service.dart';
import '../../../../utils/toast_service.dart';
import '../../../../services/owner_data_service.dart';
import '../../../../services/google_places_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../services/locker_translation_mixin.dart';

class EmployeeManagementViewModel extends ChangeNotifier with TranslatableMixin {
  final OwnerRepository ownerRepository;
  final SessionService sessionService;
  final OwnerDataService ownerDataService;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController baseSalaryController = TextEditingController();
  final TextEditingController commissionPercentController =
  TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController openingBalanceController =
  TextEditingController();
  final GooglePlacesService googlePlacesService =
  GooglePlacesService('AIzaSyDfxcDdlq5IDIHjpRQKeAHepYIFaSYvVMQ');

  double _gpsLat = 24.7136;
  double _gpsLng = 46.6753;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isActive = true;
  bool get isActive => _isActive;

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
    return _employees
        .where((e) =>
    e.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (e.email?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
            false) ||
        (e.mobile?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
            false))
        .toList();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleStatus(bool value) {
    _isActive = value;
    notifyListeners();
  }

  final Map<String, String> _translatedBranchNames = {};
  final Map<String, String> _translatedDepartmentNames = {};

  List<Branch> get branches => ownerDataService.branches;
  List<Department> get departments => ownerDataService.departments;

  String branchDisplayName(Branch branch) =>
      _translatedBranchNames[branch.id] ?? branch.name;
  String departmentDisplayName(Department department) =>
      _translatedDepartmentNames[department.id] ?? department.name;

  List<String> get branchDisplayNames =>
      branches.map(branchDisplayName).toList();
  List<String> get departmentDisplayNames =>
      departments.map(departmentDisplayName).toList();

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
    await _translateLookups();
  }


  Future<void> _translateLookups() async {
    _translatedBranchNames.clear();
    _translatedDepartmentNames.clear();
    for (final branch in branches) {
      if (branch.name.trim().isNotEmpty) {
        _translatedBranchNames[branch.id] = await t(branch.name);
      }
    }
    for (final department in departments) {
      if (department.name.trim().isNotEmpty) {
        _translatedDepartmentNames[department.id] = await t(department.name);
      }
    }
  }

  Future<void> onLocaleChanged() async {
    await _translateLookups();
    notifyListeners();
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
      if (response != null &&
          response['success'] == true &&
          response['employees'] != null) {
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
    _gpsLat = 24.7136;
    _gpsLng = 46.6753;
    _isActive = true;
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getAddressSuggestions(
      String input) async {
    return await googlePlacesService.getSuggestions(input);
  }

  Future<void> onAddressSelected(Map<String, dynamic> selection) async {
    final description = selection['description'] as String;
    addressController.text = description;

    final placeId = selection['place_id'] as String;
    final details = await googlePlacesService.getPlaceDetails(placeId);

    if (details != null) {
      _gpsLat = details['lat'];
      _gpsLng = details['lng'];
      notifyListeners();
    }
  }

  void setEditEmployee(OwnerEmployee? e) {
    if (e == null) {
      clearForm();
    } else {
      _editingEmployeeId = e.id;
      nameController.text = e.name;
      mobileController.text = e.mobile ?? '';
      emailController.text = e.email ?? '';
      passwordController.clear();
      commissionPercentController.text = e.techCommission.toString();
      baseSalaryController.text = e.basicSalary?.toString() ?? '0';
      _isActive = e.status == 'active';
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
    final l10n = AppLocalizations.of(context)!;

    if (nameController.text.trim().isEmpty ||
        mobileController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        (!isEditing && passwordController.text.trim().isEmpty)) {
      ToastService.showError(context, l10n.empMgmtValidationRequired);
      return;
    }

    if (!isWorkshop && !isOnCall) {
      ToastService.showError(context, l10n.empMgmtValidationTechType);
      return;
    }

    if (branchId == null || branchId.isEmpty) {
      ToastService.showError(context, l10n.empMgmtValidationNoBranch);
      return;
    }

    if (departmentId == null || departmentId.isEmpty) {
      ToastService.showError(context, l10n.empMgmtValidationNoDepartment);
      return;
    }

    _isActionLoading = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) throw Exception('No token found');

      String techType = 'workshop';
      if (isWorkshop && isOnCall) {
        techType = 'both';
      } else if (isOnCall) {
        techType = 'oncall';
      }

      final data = {
        'name': nameController.text.trim(),
        'mobile': mobileController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
        'branchId': branchId,
        'technicianType': techType,
        'commissionPercent':
        double.tryParse(commissionPercentController.text.trim()) ?? 0,
        'basicSalary':
        double.tryParse(baseSalaryController.text.trim()) ?? 0,
        'departmentIds': [departmentId],
        'isActive': _isActive,
      };

      if (passwordController.text.trim().isNotEmpty) {
        data['password'] = passwordController.text.trim();
      }

      if (_editingEmployeeId == null) {
        await ownerRepository.createTechnician(data, token);
        if (context.mounted) {
          ToastService.showSuccess(
              context, l10n.empMgmtTechnicianCreateSuccess);
        }
      } else {
        await ownerRepository.updateTechnician(
            token, _editingEmployeeId!, data);
        if (context.mounted) {
          ToastService.showSuccess(
              context, l10n.empMgmtTechnicianUpdateSuccess);
        }
      }

      if (context.mounted) {
        setEditEmployee(null);
        Navigator.pop(context);
        await fetchEmployees(silent: true);
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, l10n.empMgmtTechnicianCreateError);
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
    final l10n = AppLocalizations.of(context)!;

    if (nameController.text.trim().isEmpty ||
        mobileController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        (!isEditing && passwordController.text.trim().isEmpty)) {
      ToastService.showError(context, l10n.empMgmtValidationRequired);
      return;
    }

    if (branchId == null || branchId.isEmpty) {
      ToastService.showError(
          context, l10n.empMgmtValidationNoBranchCashier);
      return;
    }

    _isActionLoading = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) throw Exception('No token found');

      final data = {
        'name': nameController.text.trim(),
        'mobile': mobileController.text.trim(),
        'email': emailController.text.trim(),
        'branchId': branchId,
        'isActive': _isActive,
      };

      if (passwordController.text.trim().isNotEmpty) {
        data['password'] = passwordController.text.trim();
      }

      if (_editingEmployeeId == null) {
        await ownerRepository.createCashier(data, token);
        if (context.mounted) {
          ToastService.showSuccess(
              context, l10n.empMgmtCashierCreateSuccess);
        }
      } else {
        await ownerRepository.updateCashier(
            token, _editingEmployeeId!, data);
        if (context.mounted) {
          ToastService.showSuccess(
              context, l10n.empMgmtCashierUpdateSuccess);
        }
      }

      if (context.mounted) {
        setEditEmployee(null);
        Navigator.pop(context);
        await fetchEmployees(silent: true);
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, l10n.empMgmtCashierCreateError);
      }
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteEmployee(
      BuildContext context,
      String id,
      String role,
      ) async {
    final l10n = AppLocalizations.of(context)!;

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
        ToastService.showSuccess(context, l10n.empMgmtDeleteSuccess);
        await fetchEmployees(silent: true);
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, l10n.empMgmtDeleteError);
      }
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitSupplierForm(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        mobileController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ToastService.showError(
          context, l10n.empMgmtValidationSupplierRequired);
      return;
    }

    _isActionLoading = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) throw Exception('No token found');

      final data = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'mobile': mobileController.text.trim(),
        'address': addressController.text.trim(),
        'openingBalance':
        double.tryParse(openingBalanceController.text.trim()) ?? 0,
        'password': passwordController.text.trim(),
        'gpsLat': _gpsLat,
        'gpsLng': _gpsLng,
        'isActive': _isActive,
      };

      await ownerRepository.createSupplier(data, token);

      if (context.mounted) {
        ToastService.showSuccess(
            context, l10n.empMgmtSupplierCreateSuccess);
        clearForm();
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, l10n.empMgmtSupplierCreateError);
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