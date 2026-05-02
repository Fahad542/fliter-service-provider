import 'package:flutter/material.dart';
import '../../../../utils/toast_service.dart';
import '../../../../models/workshop_owner_models.dart';
import '../../../../data/repositories/owner_repository.dart';
import '../../../../services/session_service.dart';
import '../../../../services/owner_data_service.dart';
import '../../../../services/google_places_service.dart';
import '../../../../services/locker_translation_mixin.dart';
import '../../../../l10n/app_localizations.dart';
import '../../Workshop pos app/More Tab/settings_view_model.dart';

// ---------------------------------------------------------------------------
// BranchManagementViewModel
//
// Re-translation on locale switch
// ────────────────────────────────
// The VM observes [SettingsViewModel]. When the locale changes
// [_onLocaleChanged] clears the translation cache and re-translates every
// branch name / location that was already fetched, without touching the
// network. The View rebuilds automatically via notifyListeners.
// ---------------------------------------------------------------------------

class BranchManagementViewModel extends ChangeNotifier with TranslatableMixin {
  final OwnerRepository    ownerRepository;
  final SessionService     sessionService;
  final OwnerDataService   ownerDataService;
  final SettingsViewModel  settingsViewModel;
  final GooglePlacesService googlePlacesService =
  GooglePlacesService('AIzaSyDfxcDdlq5IDIHjpRQKeAHepYIFaSYvVMQ');

  // ── Form controllers ──────────────────────────────────────────────────────

  final TextEditingController branchNameController = TextEditingController();
  final TextEditingController addressController    = TextEditingController();
  final TextEditingController gpsLatController     = TextEditingController();
  final TextEditingController gpsLngController     = TextEditingController();

  // ── State ─────────────────────────────────────────────────────────────────

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

  /// Cache of translated branches keyed by branch id. Cleared when locale
  /// changes so stale Arabic/English translations are evicted.
  final Map<String, Branch> _translatedBranchCache = {};

  List<Branch> get branches {
    final raw = _searchQuery.isEmpty
        ? ownerDataService.branches
        : ownerDataService.branches.where((b) =>
    b.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        b.location.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    return raw.map((b) => _translatedBranchCache[b.id] ?? b).toList();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // ── Constructor / lifecycle ───────────────────────────────────────────────

  BranchManagementViewModel({
    required this.ownerRepository,
    required this.sessionService,
    required this.ownerDataService,
    required this.settingsViewModel,
  }) {
    ownerDataService.addListener(notifyListeners);
    settingsViewModel.addListener(_onLocaleChanged);
    Future.microtask(() => _init());
  }

  String _lastLocale = '';

  Future<void> _init() async {
    _lastLocale = settingsViewModel.locale.languageCode;
    if (branches.isEmpty) {
      await fetchBranches();
    }
  }

  // ── Locale change handler ─────────────────────────────────────────────────

  void _onLocaleChanged() {
    final newLocale = settingsViewModel.locale.languageCode;
    if (newLocale == _lastLocale) return;
    _lastLocale = newLocale;

    // Evict all cached translations — old locale strings are now stale.
    AppTranslationService.clearCache();
    _translatedBranchCache.clear();

    // Re-translate without re-fetching from the network.
    _retranslateBranches();
  }

  Future<void> _retranslateBranches() async {
    final raw = ownerDataService.branches;
    if (raw.isEmpty) return;

    await _translateBranches(raw);
    notifyListeners();
  }

  // ── Fetch & translate ─────────────────────────────────────────────────────

  Future<void> fetchBranches({bool silent = false}) async {
    await ownerDataService.fetchBranches(silent: silent);
    await _translateBranches(ownerDataService.branches);
    notifyListeners();
  }

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

  // ── Google Places ─────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAddressSuggestions(String input) async {
    return googlePlacesService.getSuggestions(input);
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

  // ── Form helpers ──────────────────────────────────────────────────────────

  void clearForm() {
    branchNameController.clear();
    addressController.clear();
    gpsLatController.clear();
    gpsLngController.clear();
    _isActive        = true;
    _editingBranchId = null;
    notifyListeners();
  }

  void setEditBranch(Branch? b) {
    if (b == null) {
      clearForm();
    } else {
      _editingBranchId         = b.id;
      branchNameController.text = b.name;
      addressController.text    = b.location;
      gpsLatController.text     = b.gpsLat?.toString() ?? '';
      gpsLngController.text     = b.gpsLng?.toString() ?? '';
      _isActive                 = b.status.toLowerCase() == 'active';
    }
    notifyListeners();
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  Future<void> submitBranchForm(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    if (branchNameController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty) {
      ToastService.showError(context, l10n.branchFormValidationError);
      return;
    }

    _isActionLoading = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) throw Exception('No token found');

      final data = {
        'name':    branchNameController.text.trim(),
        'address': addressController.text.trim(),
        'gpsLat':  double.tryParse(gpsLatController.text.trim()),
        'gpsLng':  double.tryParse(gpsLngController.text.trim()),
        'isActive': _isActive,
      };

      if (_editingBranchId == null) {
        await ownerRepository.createBranch(data, token);
        if (context.mounted) {
          ToastService.showSuccess(context, l10n.branchCreateSuccess);
        }
      } else {
        await ownerRepository.updateBranch(token, _editingBranchId!, data);
        if (context.mounted) {
          ToastService.showSuccess(context, l10n.branchUpdateSuccess);
        }
      }

      if (context.mounted) {
        clearForm();
        Navigator.pop(context);
        await fetchBranches(silent: true);
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, l10n.branchSaveError);
      }
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteBranch(BuildContext context, String id) async {
    final l10n = AppLocalizations.of(context)!;
    _isActionLoading = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) return;

      final response = await ownerRepository.deleteBranch(token, id);

      // Prefer the server's localised message; fall back to the ARB string.
      final successMessage =
      (response is Map<String, dynamic> &&
          response['message'] != null &&
          response['message'].toString().trim().isNotEmpty)
          ? response['message'].toString()
          : l10n.branchDeleteSuccess;

      await fetchBranches(silent: false);
      if (context.mounted) {
        ToastService.showSuccess(context, successMessage);
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, l10n.branchDeleteError);
      }
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  // ── Dispose ───────────────────────────────────────────────────────────────

  @override
  void dispose() {
    ownerDataService.removeListener(notifyListeners);
    settingsViewModel.removeListener(_onLocaleChanged);
    branchNameController.dispose();
    addressController.dispose();
    gpsLatController.dispose();
    gpsLngController.dispose();
    super.dispose();
  }
}