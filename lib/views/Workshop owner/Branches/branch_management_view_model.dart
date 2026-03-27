import 'package:flutter/material.dart';
import '../../../../utils/toast_service.dart';
import '../../../../models/workshop_owner_models.dart';
import '../../../../data/repositories/owner_repository.dart';
import '../../../../services/session_service.dart';
import '../../../../services/owner_data_service.dart';

class BranchManagementViewModel extends ChangeNotifier {
  final OwnerRepository ownerRepository;
  final SessionService sessionService;
  final OwnerDataService ownerDataService;
  
  final TextEditingController branchNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  
  String? _editingBranchId;
  bool get isEditing => _editingBranchId != null;

  bool _isLoading = false;
  bool get isLoading => _isLoading || ownerDataService.isLoadingBranches;

  bool _isActionLoading = false;
  bool get isActionLoading => _isActionLoading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<Branch> get branches {
    if (_searchQuery.isEmpty) {
      return ownerDataService.branches;
    }
    return ownerDataService.branches.where((b) => 
      b.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      b.location.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  BranchManagementViewModel({
    required this.ownerRepository,
    required this.sessionService,
    required this.ownerDataService,
  }) {
    ownerDataService.addListener(notifyListeners);
    Future.microtask(() => _init());
  }

  Future<void> _init() async {
    if (branches.isEmpty) {
      await fetchBranches();
    }
  }

  Future<void> fetchBranches({bool silent = false}) async {
    await ownerDataService.fetchBranches(silent: silent);
    notifyListeners();
  }

  void clearForm() {
    branchNameController.clear();
    addressController.clear();
    _editingBranchId = null;
    notifyListeners();
  }

  void setEditBranch(Branch? b) {
    if (b == null) {
      clearForm();
    } else {
      _editingBranchId = b.id;
      branchNameController.text = b.name;
      addressController.text = b.location;
    }
    notifyListeners();
  }

  Future<void> submitBranchForm(BuildContext context) async {
    if (branchNameController.text.trim().isEmpty || addressController.text.trim().isEmpty) {
      ToastService.showError(context, 'Branch Name and Address are required');
      return;
    }

    _isActionLoading = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) throw Exception('No token found');

      final data = {
        "name": branchNameController.text.trim(),
        "address": addressController.text.trim(),
      };

      if (_editingBranchId == null) {
        await ownerRepository.createBranch(data, token);
        if (context.mounted) ToastService.showSuccess(context, 'Branch Created Successfully');
      } else {
        await ownerRepository.updateBranch(token, _editingBranchId!, data);
        if (context.mounted) ToastService.showSuccess(context, 'Branch Updated Successfully');
      }

      if (context.mounted) {
        clearForm();
        Navigator.pop(context); // Close the sheet
        await fetchBranches(silent: true); // Refresh global branches
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, 'Failed to save branch');
      }
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteBranch(BuildContext context, String id) async {
    _isActionLoading = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) return;

      await ownerRepository.deleteBranch(token, id);

      if (context.mounted) {
        ToastService.showSuccess(context, 'Branch Deleted Successfully');
        await fetchBranches(silent: true);
      }
    } catch (e) {
      if (context.mounted) ToastService.showError(context, 'Failed to delete branch');
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    ownerDataService.removeListener(notifyListeners);
    branchNameController.dispose();
    addressController.dispose();
    super.dispose();
  }
}
