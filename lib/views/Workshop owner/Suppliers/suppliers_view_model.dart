import 'package:flutter/material.dart';
import '../../../../utils/toast_service.dart';
import '../../../../data/repositories/owner_repository.dart';
import '../../../../services/session_service.dart';
import '../../../../models/workshop_owner_models.dart';

class SuppliersViewModel extends ChangeNotifier {
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

        if (responses[0] != null) _stats = SupplierStatsResponse.fromJson(responses[0] as Map<String, dynamic>);
        if (responses[1] != null) _suppliersList = responses[1] as List<Supplier>;
      }
    } catch (e) {
      debugPrint('Error fetching supplier data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
    if (nameController.text.trim().isEmpty || 
        emailController.text.trim().isEmpty || 
        mobileController.text.trim().isEmpty || 
        addressController.text.trim().isEmpty || 
        passwordController.text.trim().isEmpty) {
      ToastService.showError(context, 'Please fill in all required fields');
      return;
    }

    _isActionLoading = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) throw Exception('No token found');

      final data = {
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "mobile": mobileController.text.trim(),
        "address": addressController.text.trim(),
        "openingBalance": double.tryParse(openingBalanceController.text.trim()) ?? 0,
        "password": passwordController.text.trim(),
      };

      await ownerRepository.createSupplier(data, token);

      if (context.mounted) {
        ToastService.showSuccess(context, 'Supplier Created Successfully');
        clearForm();
        Navigator.pop(context); // Close the sheet
        initData(); // Refresh the list
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, 'Failed to create supplier');
      }
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitPurchaseOrder(BuildContext context, {required String supplierName, required List<Map<String, dynamic>> items, required String defaultBranchId}) async {
    if (items.isEmpty) {
      ToastService.showError(context, 'Please add at least one item');
      return;
    }

    for (var item in items) {
      if (item['name'] == null || item['name'].toString().trim().isEmpty ||
          item['qty'] == null || item['qty'].toString().trim().isEmpty ||
          item['price'] == null || item['price'].toString().trim().isEmpty) {
        ToastService.showError(context, 'Please fill all item details properly');
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
        orElse: () => Supplier(id: '', name: '', email: '', mobile: '', outstanding: 0, category: '')
      );

      if (supplier.id.isEmpty) {
        ToastService.showError(context, 'Invalid supplier selected');
        return;
      }

      final branchId = user.branchId ?? defaultBranchId;

      final formattedItems = items.map((e) => {
        "productName": e['name'].toString().trim(),
        "qty": int.tryParse(e['qty'].toString().trim()) ?? 0,
        "unitPrice": double.tryParse(e['price'].toString().trim()) ?? 0.0
      }).toList();

      final data = {
        "supplierId": supplier.id,
        "branchId": branchId,
        "items": formattedItems,
      };

      await ownerRepository.createPurchaseOrder(data, token);

      if (context.mounted) {
        ToastService.showSuccess(context, 'Purchase Order Created Successfully');
        Navigator.pop(context);
        initData(); // Refresh the list
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, 'Failed to create purchase order');
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
