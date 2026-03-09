import 'package:flutter/material.dart';
import '../../../../models/workshop_owner_models.dart';
import '../../../../utils/toast_service.dart';
import '../../../../data/repositories/owner_repository.dart';
import '../../../../services/session_service.dart';

class InventoryManagementViewModel extends ChangeNotifier {
  final OwnerRepository ownerRepository;
  final SessionService sessionService;
  

  final TextEditingController nameController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  final TextEditingController categoryIdController = TextEditingController();
  final TextEditingController subCategoryIdController = TextEditingController();
  final TextEditingController purchasePriceController = TextEditingController();
  final TextEditingController salePriceController = TextEditingController();
  final TextEditingController openingQtyController = TextEditingController();
  final TextEditingController criticalStockPointController = TextEditingController();
  final TextEditingController kmTypeValueController = TextEditingController();
  bool allowDecimalQty = false;
  bool isActive = true;

  // Category controllers
  final TextEditingController categoryNameController = TextEditingController();
  final TextEditingController categoryTypeController = TextEditingController(); // typically 'product' or 'expense'

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<OwnerProduct> _products = [];
  List<OwnerProduct> get products => _products;

  List<OwnerCategory> _categories = [];
  List<OwnerCategory> get categories => _categories;

  InventoryManagementViewModel({
    required this.ownerRepository,
    required this.sessionService,
  }) {
    _init();
  }

  Future<void> _init() async {
    await fetchCategories();
    await fetchProducts();
  }

  Future<void> fetchCategories() async {
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
    }
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final token = await sessionService.getToken(role: 'owner');
      final user = await sessionService.getUser(role: 'owner');
      if (token == null) throw Exception('No token found');
      final workshopId = user?.workshopId ?? '3';

      final response = await ownerRepository.getProducts(token, workshopId);
      
      if (response != null && response['success'] == true) {
        List<OwnerProduct> allProducts = [];
        
        // 1. Process nested categories/subcategories
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
            // 2. Process products without subcategories under a category
            if (cat['productsWithoutSub'] != null) {
              for (var prod in cat['productsWithoutSub']) {
                allProducts.add(OwnerProduct.fromJson(prod));
              }
            }
          }
        }
        
        // 3. Process uncategorized products at the root level
        if (response['uncategorizedProducts'] != null) {
          for (var prod in response['uncategorizedProducts']) {
            allProducts.add(OwnerProduct.fromJson(prod));
          }
        }

        _products = allProducts;
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleAllowDecimal(bool value) {
    allowDecimalQty = value;
    notifyListeners();
  }

  void toggleIsActive(bool value) {
    isActive = value;
    notifyListeners();
  }

  void clearForm() {
    nameController.clear();
    unitController.text = 'pcs';
    categoryIdController.clear();
    subCategoryIdController.clear();
    purchasePriceController.clear();
    salePriceController.clear();
    openingQtyController.clear();
    criticalStockPointController.clear();
    kmTypeValueController.clear();
    allowDecimalQty = false;
    isActive = true;
    
    categoryNameController.clear();
    categoryTypeController.text = 'product';
  }

  Future<void> submitProductForm(
    BuildContext context, {
    required String? departmentId,
    required String? categoryId,
    required String? subCategoryId,
  }) async {
    if (nameController.text.trim().isEmpty || 
        purchasePriceController.text.trim().isEmpty ||
        salePriceController.text.trim().isEmpty ||
        openingQtyController.text.trim().isEmpty ||
        departmentId == null || categoryId == null) {
      ToastService.showError(context, 'Please fill in all required fields, including department and category selections.');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) throw Exception('No token found');

      String finalSubCategoryId = subCategoryIdController.text.trim().isEmpty ? (subCategoryId ?? '') : subCategoryIdController.text.trim();
      final data = {
        "name": nameController.text.trim(),
        "departmentId": departmentId,
        "categoryId": categoryIdController.text.trim().isEmpty ? categoryId : categoryIdController.text.trim(),
        if (finalSubCategoryId.isNotEmpty)
          "subCategoryId": finalSubCategoryId,
        "unit": unitController.text.trim().isEmpty ? "pcs" : unitController.text.trim(),
        "purchasePrice": double.tryParse(purchasePriceController.text.trim()) ?? 0.0,
        "salePrice": double.tryParse(salePriceController.text.trim()) ?? 0.0,
        "openingQty": double.tryParse(openingQtyController.text.trim()) ?? 0,
        "criticalStockPoint": double.tryParse(criticalStockPointController.text.trim()) ?? 5,
        "kmTypeValue": int.tryParse(kmTypeValueController.text.trim()) ?? 5000,
        "allowDecimalQty": allowDecimalQty,
        "isActive": isActive,
      };

      await ownerRepository.createProduct(data, token);

      if (context.mounted) {
        ToastService.showSuccess(context, 'Product Created Successfully');
        clearForm();
        Navigator.pop(context); // Close the sheet
        await fetchProducts(); // Refresh the list
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, 'Failed to create product');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitCategoryForm(BuildContext context) async {
    if (categoryNameController.text.trim().isEmpty || 
        categoryTypeController.text.trim().isEmpty) {
      ToastService.showError(context, 'Please fill in all required fields.');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) throw Exception('No token found');

      final data = {
        "name": categoryNameController.text.trim(),
        "type": categoryTypeController.text.trim(),
      };

      await ownerRepository.createCategory(data, token);

      if (context.mounted) {
        ToastService.showSuccess(context, 'Category Created Successfully');
        clearForm();
        Navigator.pop(context); // Close the sheet
        await fetchCategories(); // Refresh the list
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, 'Failed to create category');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    unitController.dispose();
    categoryIdController.dispose();
    subCategoryIdController.dispose();
    purchasePriceController.dispose();
    salePriceController.dispose();
    openingQtyController.dispose();
    criticalStockPointController.dispose();
    kmTypeValueController.dispose();
    categoryNameController.dispose();
    categoryTypeController.dispose();
    super.dispose();
  }
}
