import 'package:flutter/material.dart';
import '../../../../utils/toast_service.dart';
import '../../../../data/repositories/owner_repository.dart';
import '../../../../services/session_service.dart';
import '../../../../models/workshop_owner_models.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../services/locker_translation_mixin.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SuppliersViewModel
//
// All user-visible toast strings are resolved through AppLocalizations so they
// are shown in the current locale. l10n is passed in at call-site from the
// BuildContext, which is always available for every action that shows a toast.
// ─────────────────────────────────────────────────────────────────────────────

class SuppliersViewModel extends ChangeNotifier with TranslatableMixin {
  final OwnerRepository ownerRepository;
  final SessionService sessionService;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController openingBalanceController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isActionLoading = false;
  bool get isActionLoading => _isActionLoading;

  SupplierStatsResponse? _stats;
  SupplierStatsResponse? get stats => _stats;

  List<Supplier> _suppliersList = [];
  List<Supplier> get suppliersList => _suppliersList;

  final Map<String, String> _translatedSupplierNames = {};
  final Map<String, String> _translatedSupplierAddresses = {};

  String supplierDisplayName(Supplier supplier) =>
      _translatedSupplierNames[supplier.id] ?? supplier.name;

  String supplierDisplayAddress(Supplier supplier) {
    final raw = (supplier.address != null && supplier.address!.isNotEmpty)
        ? supplier.address!
        : supplier.category;
    return _translatedSupplierAddresses[supplier.id] ?? raw;
  }

  SuppliersViewModel({
    required this.ownerRepository,
    required this.sessionService,
  });

  Future<void> initData() async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token != null) {
        final responses = await Future.wait([
          ownerRepository.getSupplierStats(token).catchError((_) => null),
          ownerRepository.getSuppliers(token).catchError((_) => <Supplier>[]),
        ]);

        if (responses[0] != null) {
          _stats = SupplierStatsResponse.fromJson(
            responses[0] as Map<String, dynamic>,
          );
        }
        if (responses[1] != null) {
          _suppliersList = responses[1] as List<Supplier>;
          await _translateSuppliers();
        }
      }
    } catch (e) {
      debugPrint('Error fetching supplier data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> _translateSuppliers() async {
    _translatedSupplierNames.clear();
    _translatedSupplierAddresses.clear();
    for (final supplier in _suppliersList) {
      if (supplier.name.trim().isNotEmpty) {
        _translatedSupplierNames[supplier.id] = await t(supplier.name);
      }
      final addressOrCategory =
          (supplier.address != null && supplier.address!.isNotEmpty)
              ? supplier.address!
              : supplier.category;
      if (addressOrCategory.trim().isNotEmpty) {
        _translatedSupplierAddresses[supplier.id] = await t(addressOrCategory);
      }
    }
  }

  Future<void> onLocaleChanged() async {
    await _translateSuppliers();
    notifyListeners();
  }

  void clearForm() {
    nameController.clear();
    emailController.clear();
    mobileController.clear();
    addressController.clear();
    openingBalanceController.clear();
    passwordController.clear();
  }

  Future<void> submitSupplierForm(BuildContext context) async {
    // Resolve l10n once — always in the correct locale.
    final l10n = AppLocalizations.of(context)!;

    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        mobileController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ToastService.showError(context, l10n.suppliersValidationRequired);
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
      };

      await ownerRepository.createSupplier(data, token);

      if (context.mounted) {
        ToastService.showSuccess(context, l10n.suppliersCreateSuccess);
        clearForm();
        Navigator.pop(context);
        initData();
      }
    } catch (e) {
      if (context.mounted) {
        final l = AppLocalizations.of(context)!;
        ToastService.showError(context, l.suppliersCreateError);
      }
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitPurchaseOrder(
      BuildContext context, {
        required String supplierName,
        required List<Map<String, dynamic>> items,
        required String defaultBranchId,
      }) async {
    final l10n = AppLocalizations.of(context)!;

    if (items.isEmpty) {
      ToastService.showError(context, l10n.suppliersPoValidationEmpty);
      return;
    }

    for (final item in items) {
      if (item['name'] == null ||
          item['name'].toString().trim().isEmpty ||
          item['qty'] == null ||
          item['qty'].toString().trim().isEmpty ||
          item['price'] == null ||
          item['price'].toString().trim().isEmpty) {
        ToastService.showError(context, l10n.suppliersPoValidationItemDetails);
        return;
      }
    }

    _isActionLoading = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken(role: 'owner');
      final user = await sessionService.getUser(role: 'owner');
      if (token == null || user == null) throw Exception('Session invalid');

      final supplier = _suppliersList.firstWhere(
            (s) => s.name == supplierName,
        orElse: () => Supplier(
          id: '',
          name: '',
          email: '',
          mobile: '',
          outstanding: 0,
          category: '',
        ),
      );

      if (supplier.id.isEmpty) {
        if (context.mounted) {
          ToastService.showError(
            context,
            AppLocalizations.of(context)!.suppliersPoValidationInvalidSupplier,
          );
        }
        return;
      }

      final branchId = user.branchId ?? defaultBranchId;

      final formattedItems = items
          .map(
            (e) => {
          'productName': e['name'].toString().trim(),
          'qty': int.tryParse(e['qty'].toString().trim()) ?? 0,
          'unitPrice':
          double.tryParse(e['price'].toString().trim()) ?? 0.0,
        },
      )
          .toList();

      final data = {
        'supplierId': supplier.id,
        'branchId': branchId,
        'items': formattedItems,
      };

      await ownerRepository.createPurchaseOrder(data, token);

      if (context.mounted) {
        ToastService.showSuccess(
          context,
          AppLocalizations.of(context)!.suppliersPoCreateSuccess,
        );
        Navigator.pop(context);
        initData();
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(
          context,
          AppLocalizations.of(context)!.suppliersPoCreateError,
        );
      }
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    addressController.dispose();
    openingBalanceController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}