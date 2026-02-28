import 'package:flutter/material.dart';
import '../../../../utils/toast_service.dart';
import '../../../../models/workshop_owner_models.dart';
import '../../../../data/repositories/owner_repository.dart';
import '../../../../services/session_service.dart';

class BranchManagementViewModel extends ChangeNotifier {
  final OwnerRepository ownerRepository;
  final SessionService sessionService;
  
  final TextEditingController branchNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Branch> _branches = [];
  List<Branch> get branches => _branches;

  BranchManagementViewModel({
    required this.ownerRepository,
    required this.sessionService,
  }) {
    _init();
  }

  Future<void> _init() async {
    await fetchBranches();
  }

  Future<void> fetchBranches() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) throw Exception('No token found');

      final response = await ownerRepository.getBranches(token);
      if (response['success'] == true && response['branches'] != null) {
        _branches = (response['branches'] as List)
            .map((json) => Branch.fromJson(json))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching branches: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearForm() {
    branchNameController.clear();
    addressController.clear();
  }

  Future<void> submitBranchForm(BuildContext context) async {
    if (branchNameController.text.trim().isEmpty || addressController.text.trim().isEmpty) {
      ToastService.showError(context, 'Branch Name and Address are required');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) throw Exception('No token found');

      final data = {
        "name": branchNameController.text.trim(),
        "address": addressController.text.trim(),
      };

      await ownerRepository.createBranch(data, token);

      if (context.mounted) {
        ToastService.showSuccess(context, 'Branch Created Successfully');
        clearForm();
        Navigator.pop(context); // Close the sheet
        await fetchBranches();
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, 'Failed to create branch');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    branchNameController.dispose();
    addressController.dispose();
    super.dispose();
  }
}
