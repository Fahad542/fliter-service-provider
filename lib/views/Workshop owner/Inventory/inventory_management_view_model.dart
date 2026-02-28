import 'package:flutter/material.dart';
import '../../../../models/workshop_owner_models.dart';
import '../../../../utils/toast_service.dart';
import '../../../../data/repositories/owner_repository.dart';
import '../../../../services/session_service.dart';

class InventoryManagementViewModel extends ChangeNotifier {
  final OwnerRepository ownerRepository;
  final SessionService sessionService;
  
  // Product Form Controllers
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

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<OwnerProduct> _products = [];
  List<OwnerProduct> get products => _products;

  List<String> _categories = ['Engine Oil', 'Brake Pads', 'Air Filters', 'Spark Plugs', 'Coolant'];
  List<String> get categories => _categories;

  InventoryManagementViewModel({
    required this.ownerRepository,
    required this.sessionService,
  }) {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(seconds: 1));
    _products = [
      // Mock data can be added here if needed, currently empty in the original view model too
    ];

    _isLoading = false;
    notifyListeners();
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
        departmentId == null || categoryId == null || subCategoryId == null) {
      ToastService.showError(context, 'Please fill in all required fields, including department and category selections.');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) throw Exception('No token found');

      final data = {
        "name": nameController.text.trim(),
        "unit": unitController.text.trim().isEmpty ? "pcs" : unitController.text.trim(),
        "departmentId": departmentId,
        "categoryId": categoryIdController.text.trim().isEmpty ? categoryId : categoryIdController.text.trim(),
        "subCategoryId": subCategoryIdController.text.trim().isEmpty ? subCategoryId : subCategoryIdController.text.trim(),
        "purchasePrice": double.tryParse(purchasePriceController.text.trim()) ?? 0,
        "salePrice": double.tryParse(salePriceController.text.trim()) ?? 0,
        "openingQty": double.tryParse(openingQtyController.text.trim()) ?? 0,
        "criticalStockPoint": double.tryParse(criticalStockPointController.text.trim()) ?? 5,
        "kmTypeValue": int.tryParse(kmTypeValueController.text.trim()) ?? 0,
        "allowDecimalQty": allowDecimalQty,
      };

      await ownerRepository.createProduct(data, token);

      if (context.mounted) {
        ToastService.showSuccess(context, 'Product Created Successfully');
        clearForm();
        Navigator.pop(context); // Close the sheet
        // Re-fetch products if a generic fetchProducts method exists
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
    super.dispose();
  }
}
