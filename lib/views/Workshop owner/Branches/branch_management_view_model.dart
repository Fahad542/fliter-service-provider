import 'package:flutter/material.dart';
import '../../../../utils/toast_service.dart';
import '../../../../models/workshop_owner_models.dart';
import '../../../../data/repositories/owner_repository.dart';
import '../../../../services/session_service.dart';
import '../../../../services/owner_data_service.dart';
import '../../../../services/google_places_service.dart';
import '../../../../services/locker_translation_mixin.dart';

class BranchManagementViewModel extends ChangeNotifier with TranslatableMixin {
  final OwnerRepository ownerRepository;
  final SessionService sessionService;
  final OwnerDataService ownerDataService;
  final GooglePlacesService googlePlacesService = GooglePlacesService('AIzaSyDfxcDdlq5IDIHjpRQKeAHepYIFaSYvVMQ');

  final TextEditingController branchNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController gpsLatController = TextEditingController();
  final TextEditingController gpsLngController = TextEditingController();

  bool _isActive = true;
  bool get isActive => _isActive;

  void toggleStatus(bool value) {
    _isActive = value;
    notifyListeners();
  }

  String? _editingBranchId;
  bool get isEditing => _editingBranchId != null;

  bool _isLoading = false;
  bool get isLoading => _isLoading || ownerDataService.isLoadingBranches;

  bool _isActionLoading = false;
  bool get isActionLoading => _isActionLoading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  /// Cache of translated branches keyed by branch id, so re-renders don't
  /// re-translate on every notifyListeners call.
  final Map<String, Branch> _translatedBranchCache = {};

  List<Branch> get branches {
    final raw = _searchQuery.isEmpty
        ? ownerDataService.branches
        : ownerDataService.branches.where((b) =>
    b.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        b.location.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    // Return translated version when cached, raw otherwise.
    return raw.map((b) => _translatedBranchCache[b.id] ?? b).toList();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getAddressSuggestions(String input) async {
    return await googlePlacesService.getSuggestions(input);
  }

  Future<void> setSelectedAddress(String description, String placeId) async {
    addressController.text = description;
    final location = await googlePlacesService.getPlaceDetails(placeId);
    if (location != null) {
      gpsLatController.text = location['lat'].toString();
      gpsLngController.text = location['lng'].toString();
    }
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
    await _translateBranches(ownerDataService.branches);
    notifyListeners();
  }

  /// Translates name and location for every branch and caches the results.
  Future<void> _translateBranches(List<Branch> raw) async {
    final translated = await Future.wait(raw.map(_translateBranch));
    for (final b in translated) {
      _translatedBranchCache[b.id] = b;
    }
  }

  Future<Branch> _translateBranch(Branch branch) async {
    final name     = await tBranch(branch.name);
    final location = await tBranch(branch.location);
    return branch.copyWith(
      translatedName:     name,
      translatedLocation: location,
    );
  }

  void clearForm() {
    branchNameController.clear();
    addressController.clear();
    gpsLatController.clear();
    gpsLngController.clear();
    _isActive = true;
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
      gpsLatController.text = b.gpsLat?.toString() ?? '';
      gpsLngController.text = b.gpsLng?.toString() ?? '';
      _isActive = b.status.toLowerCase() == 'active';
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
        "gpsLat": double.tryParse(gpsLatController.text.trim()),
        "gpsLng": double.tryParse(gpsLngController.text.trim()),
        "isActive": _isActive,
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

      final response = await ownerRepository.deleteBranch(token, id);
      final successMessage = (response is Map<String, dynamic> &&
          response['message'] != null &&
          response['message'].toString().trim().isNotEmpty)
          ? response['message'].toString()
          : 'Branch Deleted Successfully';

      // Force a fresh branches API call so list updates immediately.
      await fetchBranches(silent: false);
      if (context.mounted) {
        ToastService.showSuccess(context, successMessage);
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
    gpsLatController.dispose();
    gpsLngController.dispose();
    super.dispose();
  }
}