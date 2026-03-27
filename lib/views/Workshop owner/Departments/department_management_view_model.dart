import 'package:flutter/material.dart';
import '../../../../utils/toast_service.dart';
import '../../../../models/department_model.dart';
import '../../../../data/repositories/owner_repository.dart';
import '../../../../services/session_service.dart';
import '../../../../services/owner_data_service.dart';

class DepartmentManagementViewModel extends ChangeNotifier {
  final OwnerRepository ownerRepository;
  final SessionService sessionService;
  final OwnerDataService ownerDataService;
  
  final TextEditingController departmentNameController = TextEditingController();
  
  String? _editingDepartmentId;
  bool get isEditing => _editingDepartmentId != null;

  bool _isLoading = false;
  bool get isLoading => _isLoading || ownerDataService.isLoadingDepartments;

  bool _isActionLoading = false;
  bool get isActionLoading => _isActionLoading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<Department> get departments {
    if (_searchQuery.isEmpty) {
      return ownerDataService.departments;
    }
    return ownerDataService.departments.where((d) => 
      d.name.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  DepartmentManagementViewModel({
    required this.ownerRepository,
    required this.sessionService,
    required this.ownerDataService,
  }) {
    ownerDataService.addListener(notifyListeners);
    Future.microtask(() => _init());
  }

  Future<void> _init() async {
    if (departments.isEmpty) {
      await fetchDepartments();
    }
  }

  Future<void> fetchDepartments({bool silent = false}) async {
    await ownerDataService.fetchDepartments(silent: silent);
    notifyListeners();
  }

  void clearForm() {
    departmentNameController.clear();
    _editingDepartmentId = null;
    notifyListeners();
  }

  void setEditDepartment(Department? d) {
    if (d == null) {
      clearForm();
    } else {
      _editingDepartmentId = d.id;
      departmentNameController.text = d.name;
    }
    notifyListeners();
  }

  Future<void> submitDepartmentForm(BuildContext context) async {
    if (departmentNameController.text.trim().isEmpty) {
      ToastService.showError(context, 'Department Name is required');
      return;
    }

    _isActionLoading = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) throw Exception('No token found');

      final data = {
        "name": departmentNameController.text.trim(),
      };

      if (_editingDepartmentId == null) {
        await ownerRepository.createDepartment(data, token);
        if (context.mounted) ToastService.showSuccess(context, 'Department Created Successfully');
      } else {
        await ownerRepository.updateDepartment(token, _editingDepartmentId!, data);
        if (context.mounted) ToastService.showSuccess(context, 'Department Updated Successfully');
      }

      if (context.mounted) {
        clearForm();
        Navigator.pop(context); // Close the sheet
        await fetchDepartments(silent: true); // Refresh global departments
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, 'Failed to save department');
      }
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteDepartment(BuildContext context, String id) async {
    _isActionLoading = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) return;

      await ownerRepository.deleteDepartment(token, id);

      if (context.mounted) {
        ToastService.showSuccess(context, 'Department Deleted Successfully');
        await fetchDepartments(silent: true);
      }
    } catch (e) {
      if (context.mounted) ToastService.showError(context, 'Failed to delete department');
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    ownerDataService.removeListener(notifyListeners);
    departmentNameController.dispose();
    super.dispose();
  }
}
