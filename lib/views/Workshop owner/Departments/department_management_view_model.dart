import 'package:flutter/material.dart';
import '../../../../utils/toast_service.dart';
import '../../../../models/department_model.dart';
import '../../../../data/repositories/owner_repository.dart';
import '../../../../services/session_service.dart';
import '../../../../services/owner_data_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../services/locker_translation_mixin.dart';

class DepartmentManagementViewModel extends ChangeNotifier with TranslatableMixin {
  final OwnerRepository ownerRepository;
  final SessionService sessionService;
  final OwnerDataService ownerDataService;

  final TextEditingController departmentNameController =
  TextEditingController();

  bool _isActive = true;
  bool get isActive => _isActive;

  void toggleStatus(bool value) {
    _isActive = value;
    notifyListeners();
  }

  String? _editingDepartmentId;
  bool get isEditing => _editingDepartmentId != null;

  bool _isLoading = false;
  bool get isLoading =>
      _isLoading || ownerDataService.isLoadingDepartments;

  bool _isActionLoading = false;
  bool get isActionLoading => _isActionLoading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  final Map<String, String> _translatedDepartmentNames = {};

  String departmentDisplayName(Department department) =>
      _translatedDepartmentNames[department.id] ?? department.name;

  List<Department> get departments {
    if (_searchQuery.isEmpty) {
      return ownerDataService.departments;
    }
    return ownerDataService.departments
        .where((d) =>
        d.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        departmentDisplayName(d).toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
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
    await _translateDepartments();
    notifyListeners();
  }

  Future<void> _translateDepartments() async {
    _translatedDepartmentNames.clear();
    for (final department in ownerDataService.departments) {
      if (department.name.trim().isNotEmpty) {
        _translatedDepartmentNames[department.id] = await t(department.name);
      }
    }
  }

  Future<void> onLocaleChanged() async {
    await _translateDepartments();
    notifyListeners();
  }

  void clearForm() {
    departmentNameController.clear();
    _isActive = true;
    _editingDepartmentId = null;
    notifyListeners();
  }

  void setEditDepartment(Department? d) {
    if (d == null) {
      clearForm();
    } else {
      _editingDepartmentId = d.id;
      departmentNameController.text = d.name;
      _isActive = d.isActive;
    }
    notifyListeners();
  }

  Future<void> submitDepartmentForm(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    if (departmentNameController.text.trim().isEmpty) {
      ToastService.showError(context, l10n.deptMgmtValidationNameRequired);
      return;
    }

    _isActionLoading = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) throw Exception('No token found');

      final data = {
        "name": departmentNameController.text.trim(),
        "isActive": _isActive,
      };

      if (_editingDepartmentId == null) {
        await ownerRepository.createDepartment(data, token);
        if (context.mounted) {
          ToastService.showSuccess(context, l10n.deptMgmtCreateSuccess);
        }
      } else {
        await ownerRepository.updateDepartment(
            token, _editingDepartmentId!, data);
        if (context.mounted) {
          ToastService.showSuccess(context, l10n.deptMgmtUpdateSuccess);
        }
      }

      if (context.mounted) {
        clearForm();
        Navigator.pop(context);
        await fetchDepartments(silent: true);
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, l10n.deptMgmtSaveError);
      }
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteDepartment(BuildContext context, String id) async {
    final l10n = AppLocalizations.of(context)!;

    _isActionLoading = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) return;

      final response = await ownerRepository.deleteDepartment(token, id);

      // Prefer the server message if meaningful, otherwise fall back to l10n.
      final serverMsg = (response is Map<String, dynamic> &&
          response['message'] != null &&
          response['message'].toString().trim().isNotEmpty)
          ? response['message'].toString()
          : null;

      await fetchDepartments(silent: false);

      if (context.mounted) {
        ToastService.showSuccess(
            context, serverMsg ?? l10n.deptMgmtDeleteSuccess);
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, l10n.deptMgmtDeleteError);
      }
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