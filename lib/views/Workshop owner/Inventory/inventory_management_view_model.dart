import 'package:flutter/material.dart';
import '../../../../models/workshop_owner_models.dart';
import '../../../../utils/toast_service.dart';
import '../../../../data/repositories/owner_repository.dart';
import '../../../../services/session_service.dart';
import '../../../../services/owner_data_service.dart';
import '../../../../services/locker_translation_mixin.dart';
import '../../../../l10n/app_localizations.dart';
import 'dart:async';

class InventoryManagementViewModel extends ChangeNotifier with TranslatableMixin {
  final OwnerRepository ownerRepository;
  final SessionService sessionService;
  final OwnerDataService ownerDataService;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  final TextEditingController categoryIdController = TextEditingController();
  final TextEditingController subCategoryIdController = TextEditingController();
  final TextEditingController purchasePriceController = TextEditingController();
  final TextEditingController salePriceController = TextEditingController();
  final TextEditingController openingQtyController = TextEditingController();
  final TextEditingController criticalStockPointController = TextEditingController();
  final TextEditingController kmTypeValueController = TextEditingController();
  final TextEditingController minCorporatePriceController = TextEditingController();
  final TextEditingController maxCorporatePriceController = TextEditingController();
  bool allowDecimalQty = true;
  bool isActive = true;
  bool isPriceEditable = false;
  String vatMode = 'inclusive';
  List<OwnerSubCategory> _productCategories = [];
  List<OwnerSubCategory> _serviceCategories = [];
  List<String> _productUnits = [];
  List<String> get productUnits => _productUnits;

  String? _editingProductId;
  String? _editingServiceId;
  String? _editingCategoryId;
  String? _editingSubCategoryId;
  String? _editingCategoryName;
  String? _editingSubCategoryName;
  String? _editingCategoryDepartmentId;

  bool get isEditingProduct => _editingProductId != null;
  bool get isEditingService => _editingServiceId != null;
  bool get isEditingCategory => _editingCategoryId != null;
  bool get isEditingSubCategory => _editingSubCategoryId != null;
  String? get editingCategoryName => _editingCategoryName;
  String? get editingSubCategoryName => _editingSubCategoryName;
  String? get editingCategoryDepartmentId => _editingCategoryDepartmentId;

  final TextEditingController categoryNameController = TextEditingController();
  final TextEditingController categoryTypeController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading || ownerDataService.isLoadingDepartments;

  bool _isActionLoading = false;
  bool get isActionLoading => _isActionLoading;

  bool _isSubCategoriesLoading = false;
  bool get isSubCategoriesLoading => _isSubCategoriesLoading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // Raw (English) backing lists — used for logic/search
  List<OwnerProduct> _products = [];
  List<OwnerProduct> _services = [];
  List<OwnerCategory> _categories = [];
  List<OwnerSubCategory> _displayedSubCategories = [];

  // Translated display lists — rebuilt after every fetch or locale switch
  List<OwnerProduct> _translatedProducts = [];
  List<OwnerProduct> _translatedServices = [];
  List<OwnerSubCategory> _translatedSubCategories = [];

  List<OwnerProduct> get products {
    final src = _translatedProducts.isEmpty ? _products : _translatedProducts;
    if (_searchQuery.isEmpty) return src;
    final q = _searchQuery.toLowerCase();
    return src.asMap().entries.where((entry) {
      final translated = entry.value;
      final raw = entry.key < _products.length ? _products[entry.key] : translated;
      return translated.name.toLowerCase().contains(q) ||
          raw.name.toLowerCase().contains(q) ||
          (translated.category?.toLowerCase().contains(q) ?? false) ||
          (raw.category?.toLowerCase().contains(q) ?? false) ||
          (translated.departmentName?.toLowerCase().contains(q) ?? false) ||
          (raw.departmentName?.toLowerCase().contains(q) ?? false);
    }).map((entry) => entry.value).toList();
  }

  List<OwnerProduct> get services {
    final src = _translatedServices.isEmpty ? _services : _translatedServices;
    if (_searchQuery.isEmpty) return src;
    final q = _searchQuery.toLowerCase();
    return src.asMap().entries.where((entry) {
      final translated = entry.value;
      final raw = entry.key < _services.length ? _services[entry.key] : translated;
      return translated.name.toLowerCase().contains(q) ||
          raw.name.toLowerCase().contains(q) ||
          (translated.category?.toLowerCase().contains(q) ?? false) ||
          (raw.category?.toLowerCase().contains(q) ?? false) ||
          (translated.departmentName?.toLowerCase().contains(q) ?? false) ||
          (raw.departmentName?.toLowerCase().contains(q) ?? false);
    }).map((entry) => entry.value).toList();
  }

  List<OwnerCategory> get categories {
    if (_searchQuery.isEmpty) return _categories;
    return _categories.where((c) =>
        c.name.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  List<OwnerSubCategory> get displayedSubCategories {
    final src = _translatedSubCategories.isEmpty
        ? _displayedSubCategories
        : _translatedSubCategories;
    if (_searchQuery.isEmpty) return src;
    return src.where((s) =>
        s.name.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  List<OwnerSubCategory> get productCategories => _productCategories;
  List<OwnerSubCategory> get serviceCategories => _serviceCategories;

  int _selectedInnerTab = 0;
  int get selectedInnerTab => _selectedInnerTab;

  void setInnerTab(int index) {
    _selectedInnerTab = index;
    fetchProductCategoriesForTab();
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  final Map<String, String> _translatedBranchNames = {};

  List<Branch> get branches => ownerDataService.branches;

  String branchDisplayName(Branch branch) =>
      _translatedBranchNames[branch.id] ?? branch.name;

  List<String> get branchDisplayNames =>
      branches.map(branchDisplayName).toList();

  InventoryManagementViewModel({
    required this.ownerRepository,
    required this.sessionService,
    required this.ownerDataService,
  }) {
    ownerDataService.addListener(notifyListeners);
    Future.microtask(() => _init());
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    try {
      await Future.wait([
        fetchProducts(silent: true),
        fetchProductUnits(silent: true),
      ]);
      if (ownerDataService.departments.isEmpty) {
        await ownerDataService.fetchDepartments(silent: true);
      }
      if (ownerDataService.branches.isEmpty) {
        await ownerDataService.fetchBranches(silent: true);
      }
      await _translateBranches();
      unawaited(fetchServices(silent: true));
      unawaited(fetchCategories(silent: true));
    } catch (e) {
      debugPrint('Error initializing inventory: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Call this when the app locale changes so all dynamic strings are re-translated.
  Future<void> retranslate() async {
    // Invalidate translated caches so raw lists are used as source
    _translatedProducts = [];
    _translatedServices = [];
    _translatedSubCategories = [];
    await Future.wait([
      _translateProducts(),
      _translateServices(),
      _translateSubCategories(),
      _translateBranches(),
    ]);
    notifyListeners();
  }

  // ── Translation helpers ───────────────────────────────────────────────────


  Future<void> _translateBranches() async {
    _translatedBranchNames.clear();
    for (final branch in branches) {
      if (branch.name.trim().isNotEmpty) {
        _translatedBranchNames[branch.id] = await t(branch.name);
      }
    }
  }

  Future<void> _translateProducts() async {
    _translatedProducts = await Future.wait(_products.map(_translateProduct));
  }

  Future<OwnerProduct> _translateProduct(OwnerProduct p) async {
    final name = await t(p.name);
    final category = p.category != null ? await t(p.category!) : null;
    final departmentName = p.departmentName != null ? await t(p.departmentName!) : null;
    final subCategoryName = p.subCategoryName != null ? await t(p.subCategoryName!) : null;
    return p.copyWith(
      name: name,
      category: category,
      departmentName: departmentName,
      subCategoryName: subCategoryName,
    );
  }

  Future<void> _translateServices() async {
    _translatedServices = await Future.wait(_services.map(_translateProduct));
  }

  Future<void> _translateSubCategories() async {
    _translatedSubCategories = await Future.wait(
      _displayedSubCategories.map((s) async {
        final name = await t(s.name);
        final deptName = s.departmentName != null ? await t(s.departmentName!) : null;
        return OwnerSubCategory(
          id: s.id,
          name: name,
          departmentId: s.departmentId,
          departmentName: deptName,
        );
      }),
    );
  }

  // ── Data fetching ─────────────────────────────────────────────────────────

  Future<void> onTabChanged(int index) async {
    if (index == 1 && _services.isEmpty) {
      await fetchServices();
      return;
    }
    if (index == 2) {
      if (_categories.isEmpty) await fetchCategories();
      await fetchProductCategoriesForTab(silent: false);
    }
  }

  Future<void> fetchCategories({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }
    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) return;
      final response = await ownerRepository.getCategories(token);
      if (response != null && response['success'] == true && response['categories'] != null) {
        _categories = (response['categories'] as List)
            .map((c) => OwnerCategory.fromJson(c))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    } finally {
      if (!silent) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> fetchProductCategoriesForTab({
    String? typeOverride,
    bool forceRefresh = false,
    bool silent = false,
  }) async {
    final typeStr = typeOverride ?? (_selectedInnerTab == 0 ? 'product' : 'service');

    if (!forceRefresh) {
      if (typeStr == 'product' && _productCategories.isNotEmpty) {
        _displayedSubCategories = _productCategories;
        await _translateSubCategories();
        if (!silent) notifyListeners();
        return;
      } else if (typeStr == 'service' && _serviceCategories.isNotEmpty) {
        _displayedSubCategories = _serviceCategories;
        await _translateSubCategories();
        if (!silent) notifyListeners();
        return;
      }
    }

    if (!silent) {
      _isSubCategoriesLoading = true;
      notifyListeners();
    }
    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) return;
      final response = await ownerRepository.getProductsCategories(token, typeStr);
      if (response != null && response['success'] == true && response['categories'] != null) {
        List<OwnerSubCategory> flatSubs = [];
        for (var c in response['categories']) {
          if (c['subCategories'] != null && (c['subCategories'] as List).isNotEmpty) {
            flatSubs.addAll((c['subCategories'] as List)
                .map((s) => OwnerSubCategory.fromJson(s)));
          } else {
            flatSubs.add(OwnerSubCategory(
              id: c['id']?.toString() ?? '',
              name: c['name'] ?? '',
              departmentId: c['departmentId']?.toString(),
              departmentName: c['departmentName']?.toString(),
            ));
          }
        }
        _displayedSubCategories = flatSubs;
        if (typeStr == 'product') {
          _productCategories = flatSubs;
        } else {
          _serviceCategories = flatSubs;
        }
        await _translateSubCategories();
      } else {
        _displayedSubCategories = [];
        _translatedSubCategories = [];
      }
    } catch (e) {
      debugPrint('Error fetching product categories for tab: $e');
      _displayedSubCategories = [];
      _translatedSubCategories = [];
    } finally {
      if (!silent) {
        _isSubCategoriesLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> fetchProducts({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }
    try {
      final token = await sessionService.getToken(role: 'owner');
      final user = await sessionService.getUser(role: 'owner');
      if (token == null) throw Exception('No token found');
      final workshopId = user?.workshopId ?? '3';

      final response = await ownerRepository.getProducts(token, workshopId);
      if (response != null && response['success'] == true) {
        List<OwnerProduct> allProducts = [];
        if (response['categories'] != null) {
          for (var cat in response['categories']) {
            if (cat['subCategories'] != null) {
              for (var sub in cat['subCategories']) {
                if (sub['products'] != null) {
                  for (var prod in sub['products']) {
                    allProducts.add(OwnerProduct.fromJson(prod));
                  }
                }
              }
            }
            if (cat['productsWithoutSub'] != null || cat['products'] != null) {
              final productList = cat['productsWithoutSub'] ?? cat['products'];
              for (var prod in productList) {
                allProducts.add(OwnerProduct.fromJson(prod));
              }
            }
            if (cat['services'] != null) {
              for (var serv in cat['services']) {
                allProducts.add(OwnerProduct.fromJson(serv));
              }
            }
          }
        }
        if (response['uncategorizedProducts'] != null) {
          for (var prod in response['uncategorizedProducts']) {
            allProducts.add(OwnerProduct.fromJson(prod));
          }
        }
        _products = allProducts;
        await _translateProducts();
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
    } finally {
      if (!silent) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> fetchProductUnits({bool silent = false}) async {
    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) return;
      final response = await ownerRepository.getProductUnits(token);
      if (response != null && response['success'] == true && response['units'] is List) {
        _productUnits = (response['units'] as List)
            .map((e) => e.toString())
            .where((e) => e.trim().isNotEmpty)
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching product units: $e');
    } finally {
      if (_productUnits.isEmpty) _productUnits = ['pcs'];
      if (unitController.text.trim().isEmpty) unitController.text = _productUnits.first;
      if (!silent) notifyListeners();
    }
  }

  Future<void> fetchServices({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }
    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) throw Exception('No token found');
      final response = await ownerRepository.getWorkshopServices(token);
      if (response != null && response['success'] == true && response['services'] != null) {
        _services = (response['services'] as List)
            .map((s) => OwnerProduct.fromJson(s))
            .toList();
        await _translateServices();
      }
    } catch (e) {
      debugPrint('Error fetching services: $e');
    } finally {
      if (!silent) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void toggleAllowDecimal(bool value) { allowDecimalQty = value; notifyListeners(); }
  void toggleIsActive(bool value) { isActive = value; notifyListeners(); }
  void toggleIsPriceEditable(bool val) { isPriceEditable = val; notifyListeners(); }
  void setVatMode(String val) { vatMode = val; notifyListeners(); }

  void clearForm() {
    nameController.clear();
    unitController.text = _productUnits.isNotEmpty ? _productUnits.first : 'pcs';
    categoryIdController.clear();
    subCategoryIdController.clear();
    purchasePriceController.clear();
    salePriceController.clear();
    minCorporatePriceController.clear();
    maxCorporatePriceController.clear();
    openingQtyController.clear();
    criticalStockPointController.clear();
    kmTypeValueController.clear();
    allowDecimalQty = true;
    isActive = true;
    _editingCategoryName = null;
    _editingSubCategoryName = null;
    _editingCategoryDepartmentId = null;
    categoryNameController.clear();
    categoryTypeController.text = 'product';
    isPriceEditable = false;
    vatMode = 'inclusive';
  }

  void setEditProduct(OwnerProduct? p) {
    if (p == null) {
      _editingProductId = null;
      clearForm();
    } else {
      _editingProductId = p.id;
      // Always populate controllers from the raw English list to avoid editing
      // a translated name back to the API.
      final raw = _products.firstWhere((r) => r.id == p.id, orElse: () => p);
      _editingCategoryName = raw.category;
      _editingSubCategoryName = raw.subCategoryName;
      nameController.text = raw.name;
      unitController.text = raw.unit.isEmpty ? 'pcs' : raw.unit;      purchasePriceController.text = raw.purchasePrice.toString();
      salePriceController.text = raw.salePrice.toString();
      openingQtyController.text = raw.stock.toString();
      criticalStockPointController.text = raw.criticalStockPoint.toString();
      kmTypeValueController.text = raw.kmTypeValue.toString();
      minCorporatePriceController.text = raw.minPriceCorporate?.toString() ?? '0.0';
      maxCorporatePriceController.text = raw.maxPriceCorporate?.toString() ?? '0.0';
      allowDecimalQty = raw.allowDecimalQty;
      isActive = raw.isActive;
      isPriceEditable = raw.isPriceEditable;
    }
    fetchProductCategoriesForTab(typeOverride: 'product');
    notifyListeners();
  }

  void setEditService(OwnerProduct? s) {
    if (s == null) {
      _editingServiceId = null;
      clearForm();
    } else {
      _editingServiceId = s.id;
      final raw = _services.firstWhere((r) => r.id == s.id, orElse: () => s);
      _editingCategoryName = raw.category;
      _editingSubCategoryName = raw.subCategoryName;
      nameController.text = raw.name;
      purchasePriceController.text = raw.purchasePrice.toString();
      salePriceController.text = raw.salePrice.toString();
      minCorporatePriceController.text = raw.minPriceCorporate?.toString() ?? '0.0';
      maxCorporatePriceController.text = raw.maxPriceCorporate?.toString() ?? '0.0';
      isPriceEditable = raw.isPriceEditable;
      isActive = raw.isActive;
    }
    fetchProductCategoriesForTab(typeOverride: 'service');
    notifyListeners();
  }

  void setEditCategory(OwnerCategory? c, {String? departmentId}) {
    if (c == null) {
      _editingCategoryId = null;
      _editingCategoryDepartmentId = null;
      categoryNameController.clear();
    } else {
      _editingCategoryId = c.id;
      _editingCategoryDepartmentId = departmentId;
      categoryNameController.text = c.name;
      categoryTypeController.text = c.type;
    }
    notifyListeners();
  }

  void setEditSubCategory(OwnerSubCategory? s) {
    if (s == null) {
      _editingSubCategoryId = null;
      categoryNameController.clear();
    } else {
      _editingSubCategoryId = s.id;
      categoryNameController.text = s.name;
    }
    notifyListeners();
  }

  // ── CRUD with l10n-aware toasts ───────────────────────────────────────────

  Future<void> submitProductForm(
      BuildContext context, {
        required String? departmentId,
        required String? categoryId,
        required String? subCategoryId,
        required String? branchId,
      }) async {
    final l10n = AppLocalizations.of(context)!;

    if (nameController.text.trim().isEmpty ||
        purchasePriceController.text.trim().isEmpty ||
        salePriceController.text.trim().isEmpty ||
        openingQtyController.text.trim().isEmpty) {
      ToastService.showError(context, l10n.invValidationFillRequired);
      return;
    }
    if (departmentId == null) { ToastService.showError(context, l10n.invValidationSelectDepartment); return; }
    if (categoryId == null)   { ToastService.showError(context, l10n.invValidationCreateCategory);   return; }
    if (branchId == null)     { ToastService.showError(context, l10n.invValidationSelectBranch);      return; }

    _isActionLoading = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken(role: 'owner');
      final user  = await sessionService.getUser(role: 'owner');
      if (token == null) throw Exception('No token found');
      final workshopId = user?.workshopId ?? '3';
      final finalSubId = subCategoryIdController.text.trim().isEmpty
          ? (subCategoryId ?? '')
          : subCategoryIdController.text.trim();
      final resolvedCategoryId = categoryIdController.text.trim().isEmpty
          ? categoryId
          : categoryIdController.text.trim();

      final Map<String, dynamic> data = _editingProductId == null
          ? {
        "workshopId": workshopId, "branchId": branchId,
        "name": nameController.text.trim(), "departmentId": departmentId,
        "categoryId": resolvedCategoryId,
        if (finalSubId.isNotEmpty) "subCategoryId": finalSubId,
        "unit": unitController.text.trim().isEmpty ? "pcs" : unitController.text.trim(),
        "purchasePrice": double.tryParse(purchasePriceController.text.trim()) ?? 0.0,
        "salePrice": double.tryParse(salePriceController.text.trim()) ?? 0.0,
        "openingQty": double.tryParse(openingQtyController.text.trim()) ?? 0,
        "minPriceCorporate": double.tryParse(minCorporatePriceController.text.trim()) ?? 0.0,
        "maxPriceCorporate": double.tryParse(maxCorporatePriceController.text.trim()) ?? 0.0,
        "criticalStockPoint": double.tryParse(criticalStockPointController.text.trim()) ?? 5,
        "kmTypeValue": int.tryParse(kmTypeValueController.text.trim()) ?? 5000,
        "allowDecimalQty": allowDecimalQty, "type": "product", "isActive": isActive,
      }
          : {
        "name": nameController.text.trim(),
        "unit": unitController.text.trim().isEmpty ? "pcs" : unitController.text.trim(),
        "purchasePrice": double.tryParse(purchasePriceController.text.trim()) ?? 0.0,
        "salePrice": double.tryParse(salePriceController.text.trim()) ?? 0.0,
        "openingQty": double.tryParse(openingQtyController.text.trim()) ?? 0,
        "criticalStockPoint": double.tryParse(criticalStockPointController.text.trim()) ?? 5,
        "categoryId": resolvedCategoryId,
        "allowDecimalQty": allowDecimalQty,
        "minPriceCorporate": double.tryParse(minCorporatePriceController.text.trim()) ?? 0.0,
        "maxPriceCorporate": double.tryParse(maxCorporatePriceController.text.trim()) ?? 0.0,
        "isActive": isActive,
      };

      await (_editingProductId == null
          ? ownerRepository.createProduct(data, token)
          : ownerRepository.updateProduct(token, _editingProductId!, data));

      if (context.mounted) {
        ToastService.showSuccess(context,
            _editingProductId == null ? l10n.invProductCreateSuccess : l10n.invProductUpdateSuccess);
        setEditProduct(null);
        Navigator.pop(context);
        await fetchProducts(silent: true);
      }
    } catch (e) {
      if (context.mounted) ToastService.showError(context, l10n.invProductCreateError);
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitServiceForm(
      BuildContext context, {
        required String? departmentId,
        required String? categoryId,
        required String? subCategoryId,
        required String? branchId,
      }) async {
    final l10n = AppLocalizations.of(context)!;

    if (nameController.text.trim().isEmpty || salePriceController.text.trim().isEmpty) {
      ToastService.showError(context, l10n.invValidationFillServiceRequired);
      return;
    }
    if (departmentId == null) { ToastService.showError(context, l10n.invValidationSelectDepartment); return; }
    if (categoryId == null)   { ToastService.showError(context, l10n.invValidationCreateCategory);   return; }
    if (branchId == null)     { ToastService.showError(context, l10n.invValidationSelectBranch);      return; }

    _isActionLoading = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken(role: 'owner');
      final user  = await sessionService.getUser(role: 'owner');
      if (token == null) throw Exception('No token found');
      final workshopId = user?.workshopId ?? '3';
      final finalSubId = subCategoryIdController.text.trim().isEmpty
          ? (subCategoryId ?? '')
          : subCategoryIdController.text.trim();
      final resolvedCategoryId = categoryIdController.text.trim().isEmpty
          ? categoryId
          : categoryIdController.text.trim();

      final Map<String, dynamic> data = _editingServiceId == null
          ? {
        "workshopId": workshopId, "departmentId": departmentId, "branchId": branchId,
        "categoryId": resolvedCategoryId,
        if (finalSubId.isNotEmpty) "subCategoryId": finalSubId,
        "name": nameController.text.trim(),
        "sellingPrice": double.tryParse(salePriceController.text.trim()) ?? 0.0,
        "isPriceEditable": isPriceEditable, "vatMode": vatMode,
        "minPriceCorporate": double.tryParse(minCorporatePriceController.text.trim()) ?? 0.0,
        "maxPriceCorporate": double.tryParse(maxCorporatePriceController.text.trim()) ?? 0.0,
        "type": "service", "isActive": isActive,
      }
          : {
        "name": nameController.text.trim(),
        "sellingPrice": double.tryParse(salePriceController.text.trim()) ?? 0.0,
        "categoryId": resolvedCategoryId,
        "isPriceEditable": isPriceEditable, "vatMode": vatMode,
        "minPriceCorporate": double.tryParse(minCorporatePriceController.text.trim()) ?? 0.0,
        "maxPriceCorporate": double.tryParse(maxCorporatePriceController.text.trim()) ?? 0.0,
        "isActive": isActive,
      };

      await (_editingServiceId == null
          ? ownerRepository.createWorkshopService(data, token)
          : ownerRepository.updateService(token, _editingServiceId!, data));

      if (context.mounted) {
        ToastService.showSuccess(context,
            _editingServiceId == null ? l10n.invServiceCreateSuccess : l10n.invServiceUpdateSuccess);
        setEditService(null);
        Navigator.pop(context);
        await fetchServices(silent: true);
      }
    } catch (e) {
      if (context.mounted) ToastService.showError(context, l10n.invServiceCreateError);
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitCategoryForm(BuildContext context, {required String? departmentId}) async {
    final l10n = AppLocalizations.of(context)!;
    if (categoryNameController.text.trim().isEmpty) {
      ToastService.showError(context, l10n.invValidationFillRequired);
      return;
    }
    if (departmentId == null || departmentId.isEmpty) {
      ToastService.showError(context, l10n.invValidationSelectDepartment);
      return;
    }
    _isActionLoading = true;
    notifyListeners();
    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) throw Exception('No token found');
      final data = {
        "name": categoryNameController.text.trim(),
        "type": _selectedInnerTab == 0 ? 'product' : 'service',
        "departmentId": departmentId,
        "isActive": true,
      };
      await (_editingCategoryId == null
          ? ownerRepository.createCategory(data, token)
          : ownerRepository.updateCategory(token, _editingCategoryId!, data));
      if (context.mounted) {
        ToastService.showSuccess(context,
            _editingCategoryId == null ? l10n.invCategoryCreateSuccess : l10n.invCategoryUpdateSuccess);
        setEditCategory(null);
        Navigator.pop(context);
        await fetchCategories(silent: true);
        await fetchProductCategoriesForTab(forceRefresh: true, silent: true);
        if (_selectedInnerTab == 0) {
          await fetchProducts(silent: true);
        } else {
          await fetchServices(silent: true);
        }
      }
    } catch (e) {
      if (context.mounted) ToastService.showError(context, l10n.invCategoryCreateError);
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitSubCategoryForm(BuildContext context, {required String categoryId}) async {
    final l10n = AppLocalizations.of(context)!;
    if (categoryNameController.text.trim().isEmpty) {
      ToastService.showError(context, l10n.invValidationFillRequired);
      return;
    }
    _isActionLoading = true;
    notifyListeners();
    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) throw Exception('No token found');
      final data = {"name": categoryNameController.text.trim(), "categoryId": categoryId, "isActive": true};
      await (_editingSubCategoryId == null
          ? ownerRepository.createSubCategory(data, token)
          : ownerRepository.updateSubCategory(token, _editingSubCategoryId!, data));
      if (context.mounted) {
        ToastService.showSuccess(context,
            _editingSubCategoryId == null ? l10n.invSubCategoryCreateSuccess : l10n.invSubCategoryUpdateSuccess);
        setEditSubCategory(null);
        Navigator.pop(context);
        await fetchCategories(silent: true);
        await fetchProductCategoriesForTab(forceRefresh: true, silent: true);
      }
    } catch (e) {
      if (context.mounted) ToastService.showError(context, l10n.invSubCategoryCreateError);
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(BuildContext context, String id) async {
    final l10n = AppLocalizations.of(context)!;
    _isActionLoading = true; notifyListeners();
    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) return;
      await ownerRepository.deleteProduct(token, id);
      if (context.mounted) { ToastService.showSuccess(context, l10n.invProductDeleteSuccess); await fetchProducts(silent: true); }
    } catch (e) {
      if (context.mounted) ToastService.showError(context, l10n.invProductDeleteError);
    } finally { _isActionLoading = false; notifyListeners(); }
  }

  Future<void> deleteService(BuildContext context, String id) async {
    final l10n = AppLocalizations.of(context)!;
    _isActionLoading = true; notifyListeners();
    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) return;
      await ownerRepository.deleteService(token, id);
      if (context.mounted) { ToastService.showSuccess(context, l10n.invServiceDeleteSuccess); await fetchServices(silent: true); }
    } catch (e) {
      if (context.mounted) ToastService.showError(context, l10n.invServiceDeleteError);
    } finally { _isActionLoading = false; notifyListeners(); }
  }

  Future<void> deleteCategory(BuildContext context, String id) async {
    final l10n = AppLocalizations.of(context)!;
    _isLoading = true; notifyListeners();
    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) return;
      await ownerRepository.deleteCategory(token, id);
      if (context.mounted) {
        ToastService.showSuccess(context, l10n.invCategoryDeleteSuccess);
        await fetchCategories(silent: true);
        await fetchProductCategoriesForTab(forceRefresh: true, silent: true);
      }
    } catch (e) {
      if (context.mounted) ToastService.showError(context, l10n.invCategoryDeleteError);
    } finally { _isLoading = false; _isActionLoading = false; notifyListeners(); }
  }

  Future<void> deleteSubCategory(BuildContext context, String id) async {
    final l10n = AppLocalizations.of(context)!;
    _isActionLoading = true; notifyListeners();
    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) return;
      await ownerRepository.deleteSubCategory(token, id);
      if (context.mounted) {
        ToastService.showSuccess(context, l10n.invSubCategoryDeleteSuccess);
        await fetchCategories(silent: true);
        await fetchProductCategoriesForTab(forceRefresh: true, silent: true);
      }
    } catch (e) {
      if (context.mounted) ToastService.showError(context, l10n.invSubCategoryDeleteError);
    } finally { _isActionLoading = false; notifyListeners(); }
  }

  @override
  void dispose() {
    ownerDataService.removeListener(notifyListeners);
    nameController.dispose();
    unitController.dispose();
    categoryIdController.dispose();
    subCategoryIdController.dispose();
    purchasePriceController.dispose();
    salePriceController.dispose();
    minCorporatePriceController.dispose();
    maxCorporatePriceController.dispose();
    openingQtyController.dispose();
    criticalStockPointController.dispose();
    kmTypeValueController.dispose();
    categoryNameController.dispose();
    categoryTypeController.dispose();
    super.dispose();
  }
}