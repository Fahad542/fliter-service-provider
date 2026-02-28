import 'package:flutter/material.dart';
import '../../../../models/department_model.dart';
import '../../../../utils/toast_service.dart';
import '../../../../data/repositories/owner_repository.dart';
import '../../../../services/session_service.dart';

class DepartmentManagementViewModel extends ChangeNotifier {
  final OwnerRepository ownerRepository;
  final SessionService sessionService;
  
  final TextEditingController departmentNameController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Department> _departments = [];
  List<Department> get departments => _departments;

  DepartmentManagementViewModel({
    required this.ownerRepository,
    required this.sessionService,
  }) {
    _init();
  }

  Future<void> _init() async {
    await fetchDepartments();
  }

  Future<void> fetchDepartments() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) throw Exception('No token found');

      final response = await ownerRepository.getDepartments(token);
      if (response['success'] == true && response['departments'] != null) {
        _departments = (response['departments'] as List)
            .map((json) => Department.fromJson(json))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching departments: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearForm() {
    departmentNameController.clear();
  }

  Future<void> submitDepartmentForm(BuildContext context) async {
    if (departmentNameController.text.trim().isEmpty) {
      ToastService.showError(context, 'Department name is required');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) throw Exception('No token found');

      final data = {
        "name": departmentNameController.text.trim(),
      };

      await ownerRepository.createDepartment(data, token);

      if (context.mounted) {
        ToastService.showSuccess(context, 'Department Created Successfully');
        clearForm();
        Navigator.pop(context); // Close the sheet
        await fetchDepartments();
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, 'Failed to create department');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    departmentNameController.dispose();
    super.dispose();
  }
}
