import 'package:flutter/material.dart';
import '../models/workshop_owner_models.dart';
import '../models/department_model.dart';
import '../data/repositories/owner_repository.dart';
import 'session_service.dart';

class OwnerDataService extends ChangeNotifier {
  final OwnerRepository ownerRepository;
  final SessionService sessionService;

  List<Branch> _branches = [];
  List<Branch> get branches => _branches;

  List<Department> _departments = [];
  List<Department> get departments => _departments;

  bool _isLoadingBranches = false;
  bool get isLoadingBranches => _isLoadingBranches;

  bool _isLoadingDepartments = false;
  bool get isLoadingDepartments => _isLoadingDepartments;

  OwnerDataService({
    required this.ownerRepository,
    required this.sessionService,
  });

  Future<void> fetchBranches({bool silent = false}) async {
    if (!silent) {
      _isLoadingBranches = true;
      notifyListeners();
    }

    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) return;

      final response = await ownerRepository.getBranches(token);
      if (response != null && response['success'] == true && response['branches'] != null) {
        _branches = (response['branches'] as List)
            .map((json) => Branch.fromJson(json))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching branches in Service: $e');
    } finally {
      if (!silent) {
        _isLoadingBranches = false;
        notifyListeners();
      }
    }
  }

  Future<void> fetchDepartments({bool silent = false}) async {
    if (!silent) {
      _isLoadingDepartments = true;
      notifyListeners();
    }

    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) return;

      final response = await ownerRepository.getDepartments(token);
      if (response != null && response['success'] == true && response['departments'] != null) {
        _departments = (response['departments'] as List)
            .map((json) => Department.fromJson(json))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching departments in Service: $e');
    } finally {
      if (!silent) {
        _isLoadingDepartments = false;
        notifyListeners();
      }
    }
  }

  Future<void> refreshAll({bool silent = false}) async {
    await Future.wait([
      fetchBranches(silent: silent),
      fetchDepartments(silent: silent),
    ]);
  }
}
