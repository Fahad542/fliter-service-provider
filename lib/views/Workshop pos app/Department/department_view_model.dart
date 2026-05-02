import 'package:flutter/material.dart';

import '../../../data/repositories/pos_repository.dart';
import '../../../models/department_model.dart';
import '../../../services/session_service.dart';
// import '../../data/repositories/department_repository.dart';
// import '../../data/repositories/pos_repository.dart';
// import '../../services/session_service.dart';
// import '../../models/department_model.dart';
class DepartmentViewModel extends ChangeNotifier {
  final PosRepository _departmentRepository;
  final SessionService _sessionService;

  DepartmentViewModel({
    required PosRepository departmentRepository,
    required SessionService sessionService,
  })  : _departmentRepository = departmentRepository,
        _sessionService = sessionService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Department> _departments = [];
  List<Department> get departments => _departments;

  int? _selectedIndex;
  int? get selectedIndex => _selectedIndex;
  final Set<int> _selectedIndices = {};
  Set<int> get selectedIndices => Set.unmodifiable(_selectedIndices);
  List<Department> get selectedDepartments => _selectedIndices
      .where((i) => i >= 0 && i < _departments.length)
      .map((i) => _departments[i])
      .toList();

  void setSelectedIndex(int? index) {
    _selectedIndex = index;
    _selectedIndices.clear();
    if (index != null) _selectedIndices.add(index);
    notifyListeners();
  }

  void toggleSelectedIndex(int index) {
    if (_selectedIndices.contains(index)) {
      _selectedIndices.remove(index);
    } else {
      _selectedIndices.add(index);
    }
    _selectedIndex = _selectedIndices.isEmpty ? null : _selectedIndices.first;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? value) {
    _errorMessage = value;
    notifyListeners();
  }

  Future<void> fetchDepartments() async {
    _selectedIndex = null; // Reset selection every time screen loads fresh
    _selectedIndices.clear();
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final token = await _sessionService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await _departmentRepository.getDepartments(token);
      if (response.success) {
        _departments = response.departments;
      } else {
        _setErrorMessage('Failed to load departments');
      }
    } catch (e) {
      _setErrorMessage(e.toString());
    } finally {
      _setLoading(false);
    }
  }
}
