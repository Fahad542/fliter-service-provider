import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../utils/toast_service.dart';
import 'package:intl/intl.dart';
import '../../../models/pos_product_model.dart';
import '../../../models/pos_order_model.dart';
import '../../../models/pos_technician_model.dart';
import '../../../models/petty_cash_model.dart';
import '../../../models/store_closing_model.dart';
import '../../../data/repositories/pos_repository.dart';
import '../../../services/session_service.dart';
import '../../../models/walk_in_customer_model.dart';
import '../../../models/customer_search_model.dart';
import '../../../models/create_invoice_model.dart';
import '../../../models/expense_category_model.dart'; // Added
import '../../../models/cashier_complete_job_model.dart'; // Added
import '../../../models/cashier_corporate_accounts_api_model.dart';

class PosViewModel extends ChangeNotifier {
  final PosRepository posRepository;
  final SessionService sessionService;

  PosViewModel({required this.posRepository, required this.sessionService}) {
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    _homeSearchFocusNode.addListener(() {
      notifyListeners();
    });
    final user = await sessionService.getUser();
    if (user != null) {
      _cashierName = user.cashier?.cashierName ?? user.name;
      _workshopName = user.workshopName;
      _branchName = user.branchName;
      notifyListeners();
    }
  }

  List<CashierCorporateAccount> _corporateAccounts = [];
  bool _isCorpAccountsLoading = false;

  List<CashierCorporateAccount> get corporateAccounts => _corporateAccounts;
  bool get isCorpAccountsLoading => _isCorpAccountsLoading;

  Future<void> fetchCorporateAccounts({bool silent = true}) async {
    if (!silent) {
      _isCorpAccountsLoading = true;
      _errorMessage = null;
      notifyListeners();
    }
    try {
      final token = await sessionService.getToken();
      if (token == null) throw Exception('Token not found');
      final response = await posRepository.getCashierCorporateAccounts(token);
      if (response.success) {
        _corporateAccounts = response.accounts;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = _extractErrorMessage(e.toString());
    } finally {
      if (!silent) {
        _isCorpAccountsLoading = false;
        notifyListeners();
      }
    }
  }

  // Walk-in Customer State
  String _customerName = '';
  String _vatNumber = '';
  String _mobile = '';
  String _vehicleNumber = '';
  String _make = '';
  String _model = '';
  int _odometerReading = 0;
  String? _previousOrderId;

  String get customerName => _customerName;
  String get vatNumber => _vatNumber;
  String get mobile => _mobile;
  String get vehicleNumber => _vehicleNumber;
  String get make => _make;
  String get model => _model;
  int get odometerReading => _odometerReading;

  bool _isLoading = false;
  String? _errorMessage;
  String? _currentJobId;
  List<PosOrder> _orders = [];
  OrderStats _orderStats = OrderStats.empty();
  List<SearchedCustomer> _searchedCustomers = [];
  bool _isSearchingCustomer = false;
  int _shellSelectedIndex = 0;

  String? _cashierName;
  String? _workshopName;
  String? _branchName;

  bool _isInvoiceLoading = false;
  String? _loadingOrderId;

  bool get isLoading => _isLoading;
  bool get isInvoiceLoading => _isInvoiceLoading;
  String? get loadingOrderId => _loadingOrderId;
  String? get errorMessage => _errorMessage;
  String? get currentJobId => _currentJobId;
  OrderStats get orderStats => _orderStats;
  List<SearchedCustomer> get searchedCustomers => _searchedCustomers;
  bool get isSearchingCustomer => _isSearchingCustomer;
  int get shellSelectedIndex => _shellSelectedIndex;

  void setShellSelectedIndex(int index) {
    _shellSelectedIndex = index;
    notifyListeners();
  }

  // Home Screen Search State
  final TextEditingController _homeSearchController = TextEditingController();
  final FocusNode _homeSearchFocusNode = FocusNode();

  TextEditingController get homeSearchController => _homeSearchController;
  FocusNode get homeSearchFocusNode => _homeSearchFocusNode;

  @override
  void dispose() {
    _homeSearchController.dispose();
    _homeSearchFocusNode.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  String get cashierName => _cashierName ?? 'Cashier';
  String get workshopName => _workshopName ?? 'Loading...';
  String get branchName => _branchName ?? '...';

  // Search Debounce (Moved from View)
  Timer? _searchDebounce;

  void handleSearchDebounce(String query) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      searchCustomers(query);
    });
  }

  // Date Formatting (Moved from View logic)
  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd-MMM-yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _extractErrorMessage(String error) {
    String clean = error;
    // Remove generic exception prefixes
    if (clean.startsWith('Exception: ')) clean = clean.substring(11);
    if (clean.startsWith('Error: ')) clean = clean.substring(7);
    if (clean.startsWith('Invalid Request: ')) clean = clean.substring(17);

    // Try to find JSON object
    final startIndex = clean.indexOf('{');
    final endIndex = clean.lastIndexOf('}');

    if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
      try {
        final jsonStr = clean.substring(startIndex, endIndex + 1);
        final Map<String, dynamic> json = jsonDecode(jsonStr);
        if (json.containsKey('message') && json['message'] != null) {
          return json['message'].toString();
        }
      } catch (_) {
        // JSON parsing failed, just return the cleaned string
      }
    }
    return clean;
  }

  void setCustomerData({
    required String name,
    required String vat,
    required String mobile,
    required String vehicleNumber,
    required String make,
    required String model,
    required int odometer,
    String? previousOrderId,
  }) {
    _customerName = name;
    _vatNumber = vat;
    _mobile = mobile;
    _vehicleNumber = vehicleNumber;
    _make = make;
    _model = model;
    _odometerReading = odometer;
    _previousOrderId = previousOrderId;
    notifyListeners();
  }

  void clearCustomerData() {
    _customerName = '';
    _vatNumber = '';
    _mobile = '';
    _vehicleNumber = '';
    _make = '';
    _model = '';
    _odometerReading = 0;
    _previousOrderId = null;
    _cartItems.clear();
    _activePromoCode = '';
    _promoDiscount = 0.0;
    _globalDiscount = 0.0;
    notifyListeners();
  }

  void saveCustomerAndProceed({
    required bool isNormal,
    required String name,
    required String vat,
    required String mobile,
    required String vehicleNumber,
    required String make,
    required String model,
    required String odometerStr,
    required CashierCorporateAccount? selectedCorporateData,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) {
    if (isNormal) {
      setCustomerData(
        name: name,
        vat: vat,
        mobile: mobile,
        vehicleNumber: vehicleNumber,
        make: make,
        model: model,
        odometer: int.tryParse(odometerStr) ?? 0,
      );
    } else {
      if (selectedCorporateData == null) {
        onError('Please select a corporate account');
        return;
      }
      setCustomerData(
        name: selectedCorporateData.companyName,
        vat: '', // Empty as API doesn't provide VAT
        mobile: selectedCorporateData.customer?.mobile ?? '',
        vehicleNumber: vehicleNumber,
        make: make,
        model: model,
        odometer: int.tryParse(odometerStr) ?? 0,
      );
    }
    onSuccess();
  }

  Future<bool> submitWalkInOrder(
    List<String> departmentIds,
    BuildContext context,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await sessionService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final List<RequestedProduct> products = [];
      final List<RequestedService> services = [];

      for (var item in _cartItems) {
        if (item.product.isService) {
          services.add(
            RequestedService(
              serviceId: item.product.id,
              departmentId: item.product.departmentId ?? departmentIds.first,
              qty: 1.0,
              discountType: item.discount > 0 ? (item.isDiscountPercent ? 'percent' : 'amount') : null,
              discountValue: item.discount > 0 ? item.discount : null,
            ),
          );
        } else {
          products.add(
            RequestedProduct(
              productId: item.product.id,
              departmentId: item.product.departmentId ?? departmentIds.first,
              qty: item.quantity,
              discountType: item.discount > 0 ? (item.isDiscountPercent ? 'percent' : 'amount') : null,
              discountValue: item.discount > 0 ? item.discount : null,
            ),
          );
        }
      }

      // Combine the passed departmentIds with any departmentIds from the selected products
      final Set<String> allDepartmentIds = {...departmentIds};
      for (var product in products) {
        if (product.departmentId.isNotEmpty) {
          allDepartmentIds.add(product.departmentId);
        }
      }
      for (var service in services) {
        if (service.departmentId.isNotEmpty) {
          allDepartmentIds.add(service.departmentId);
        }
      }

      final request = WalkInCustomerRequest(
        orderId: _previousOrderId,
        customerName: _customerName,
        vatNumber: _vatNumber,
        mobile: _mobile,
        vehicleNumber: _vehicleNumber,
        make: _make,
        model: _model,
        odometerReading: _odometerReading,
        departmentIds: allDepartmentIds.toList(),
        products: products.isNotEmpty ? products : null,
        services: services.isNotEmpty ? services : null,
        totalDiscountType: _globalDiscount > 0 ? (_isGlobalDiscountPercent ? 'percent' : 'amount') : null,
        totalDiscountValue: _globalDiscount > 0 ? _globalDiscount : null,
        promoCode: _promoDiscount > 0 ? _activePromoCode : null,
      );

      final response = await posRepository.createWalkInOrder(request, token);

      if (response.success) {
        // Try to get jobId from the last added department first, then fallback to top-level jobId or order id
        _currentJobId =
            (response.order?.departments.isNotEmpty == true
                ? response.order?.departments.last.jobId
                : null) ??
            response.order?.jobId ??
            response.order?.id;
        _isLoading = false;
        clearCustomerData(); // Reset for next order
        notifyListeners();
        if (context.mounted) {
          ToastService.showSuccess(context, response.message);
        }
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        if (context.mounted) {
          ToastService.showError(context, response.message);
        }
        return false;
      }
    } catch (e) {
      _errorMessage = _extractErrorMessage(e.toString());
      _isLoading = false;
      notifyListeners();
      if (context.mounted) {
        ToastService.showError(context, _errorMessage!);
      }
      return false;
    }
  }

  List<PosProduct> _allProducts = [];
  String? _lastFetchedDepartmentId;
  String? get lastFetchedDepartmentId => _lastFetchedDepartmentId;

  Future<void> fetchProducts({String? departmentId}) async {
    _lastFetchedDepartmentId = departmentId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await sessionService.getToken();
      final user = await sessionService.getUser();

      if (token == null || user == null || user.workshopId == null) {
        throw Exception('Authentication information missing');
      }

      final response = await posRepository.getProducts(
        user.workshopId!,
        token,
        departmentId: departmentId,
        branchId: user.branchId,
      );

      if (response.success) {
        _allProducts = [];
        _apiCategories = response.categories;
        // Flatten categories and subcategories into a single list of products
        for (var cat in response.categories) {
          for (var sub in cat.subCategories) {
            _allProducts.addAll(sub.products);
          }
          _allProducts.addAll(cat.productsWithoutSub);
        }
        _allProducts.addAll(response.uncategorizedProducts);
      } else {
        _errorMessage = 'Failed to fetch products';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  final List<CartItem> _cartItems = [];
  String _activePromoCode = '';
  double _promoDiscount = 0.0;
  bool _isPromoPercent = false;
  double _globalDiscount = 0.0;
  bool _isGlobalDiscountPercent = false;

  // Secondary cart state for main navigation tab
  final List<CartItem> _mainTabCartItems = [];
  String _mainTabActivePromoCode = '';
  double _mainTabPromoDiscount = 0.0;
  bool _mainTabIsPromoPercent = false;
  double _mainTabGlobalDiscount = 0.0;
  bool _mainTabIsGlobalDiscountPercent = false;

  String _selectedProductType = 'All';
  String _selectedCategory = 'All';
  String _searchQuery = '';

  List<ProductCategory> _apiCategories = [];

  List<PosProduct> get allProducts => _allProducts;
  List<ProductCategory> get apiCategories => _apiCategories;
  List<CartItem> get cartItems => _cartItems;
  List<CartItem> get mainTabCartItems => _mainTabCartItems;
  String get selectedProductType => _selectedProductType;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  void setProductType(String type) {
    if (_selectedProductType != type) {
      _selectedProductType = type;
      _selectedCategory = 'All';
      notifyListeners();
    }
  }

  Future<void> initMainProductsTab() async {
    _selectedProductType = 'All';
    _selectedCategory = 'All';
    _searchQuery = '';
    notifyListeners();
    await fetchProducts(departmentId: null);
  }

  String get activePromoCode => _activePromoCode;
  double get promoDiscount => _promoDiscount;
  bool get isPromoPercent => _isPromoPercent;

  double get globalDiscount => _globalDiscount;
  bool get isGlobalDiscountPercent => _isGlobalDiscountPercent;

  // Context-aware getters for discounts
  double getActiveGlobalDiscount(bool isMainTab) => isMainTab ? _mainTabGlobalDiscount : _globalDiscount;
  bool getActiveIsGlobalDiscountPercent(bool isMainTab) => isMainTab ? _mainTabIsGlobalDiscountPercent : _isGlobalDiscountPercent;
  String getActivePromoCode(bool isMainTab) => isMainTab ? _mainTabActivePromoCode : _activePromoCode;

  List<String> get uniqueCategories {
    final cats = _allProducts
        .where((p) {
          if (_selectedProductType == 'All') return true;
          return _selectedProductType == 'Products'
              ? !p.isService
              : p.isService;
        })
        .map((p) => p.category)
        .toSet()
        .toList();
    cats.sort();
    return ['All', ...cats];
  }

  List<PosProduct> get products {
    return _allProducts.where((p) {
      final matchesType =
          _selectedProductType == 'All' ||
          (_selectedProductType == 'Products' ? !p.isService : p.isService);
      final matchesCategory =
          _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchesSearch = p.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      return matchesType && matchesCategory && matchesSearch;
    }).toList();
  }

  int get cartCount => getCartCount(false);

  // --- Backward Compatibility Getters (defaults to primary cart) ---
  double get subtotalExclVat => getSubtotalExclVat(false);
  double get totalIndividualDiscount => getTotalIndividualDiscount(false);
  double get totalGlobalDiscount => getTotalGlobalDiscountValue(false);
  double get totalPromoDiscount => getTotalPromoDiscountValue(false);
  double get totalTaxableAmount => getTotalTaxableAmountValue(false);
  double get totalTax => getTotalTaxValue(false);
  double get totalAmount => getTotalAmountValue(false);

  double getSubtotalExclVat(bool isMainTab) => _getActiveCart(isMainTab).fold(
    0,
    (sum, item) => sum + (item.product.price * item.quantity),
  );

  double getTotalIndividualDiscount(bool isMainTab) =>
      _getActiveCart(isMainTab).fold(0, (sum, item) => sum + item.actualDiscountAmount);

  double getTotalGlobalDiscountValue(bool isMainTab) {
    final baseForGlobal = getSubtotalExclVat(isMainTab) - getTotalIndividualDiscount(isMainTab);
    if (isMainTab) {
      if (_mainTabIsGlobalDiscountPercent) return baseForGlobal * (_mainTabGlobalDiscount / 100);
      return _mainTabGlobalDiscount;
    } else {
      if (_isGlobalDiscountPercent) return baseForGlobal * (_globalDiscount / 100);
      return _globalDiscount;
    }
  }

  double getTotalPromoDiscountValue(bool isMainTab) {
    final baseForPromo = getSubtotalExclVat(isMainTab) - 
                        getTotalIndividualDiscount(isMainTab) - 
                        getTotalGlobalDiscountValue(isMainTab);
    if (isMainTab) {
      if (_mainTabIsPromoPercent) return baseForPromo * (_mainTabPromoDiscount / 100);
      return _mainTabPromoDiscount;
    } else {
      if (_isPromoPercent) return baseForPromo * (_promoDiscount / 100);
      return _promoDiscount;
    }
  }

  double getTotalTaxableAmountValue(bool isMainTab) =>
      getSubtotalExclVat(isMainTab) -
      getTotalIndividualDiscount(isMainTab) -
      getTotalGlobalDiscountValue(isMainTab) -
      getTotalPromoDiscountValue(isMainTab);

  double getTotalTaxValue(bool isMainTab) => getTotalTaxableAmountValue(isMainTab) * 0.15; // 15% VAT
  
  double getTotalAmountValue(bool isMainTab) => getTotalTaxableAmountValue(isMainTab) + getTotalTaxValue(isMainTab);

  int getCartCount(bool isMainTab) => _getActiveCart(isMainTab).fold(
    0,
    (sum, item) => sum + (item.quantity >= 1 ? item.quantity.toInt() : 1),
  );

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // --- Cart Management Helpers ---
  List<CartItem> _getActiveCart(bool isMainTab) => isMainTab ? _mainTabCartItems : _cartItems;

  String? addToCart(PosProduct product, {double qty = 1.0, bool isMainTab = false}) {
    if (!product.allowDecimalQty && qty % 1 != 0) {
      qty = qty.floorToDouble();
    }
    final activeCart = _getActiveCart(isMainTab);
    final existingIndex = activeCart.indexWhere(
      (item) => item.product.id == product.id,
    );
    if (existingIndex != -1) {
      if (product.isService) {
        return 'Services can only be booked once per order.';
      }
      if (!product.isService &&
          activeCart[existingIndex].quantity + qty > product.stock) {
        return 'Cannot exceed available stock limit (${product.stock})';
      }
      activeCart[existingIndex].quantity += qty;
    } else {
      if (!product.isService && qty > product.stock) {
        return 'Cannot exceed available stock limit (${product.stock})';
      }
      activeCart.add(
        CartItem(product: product, quantity: qty, isDiscountPercent: false),
      );
    }
    notifyListeners();
    return null;
  }

  void removeFromCart(PosProduct product, {bool isMainTab = false}) {
    _getActiveCart(isMainTab).removeWhere((item) => item.product.id == product.id);
    notifyListeners();
  }

  String? updateQuantity(PosProduct product, double delta, {bool isMainTab = false}) {
    if (!product.allowDecimalQty && delta % 1 != 0) {
      delta = delta.floorToDouble();
    }
    final activeCart = _getActiveCart(isMainTab);
    final index = activeCart.indexWhere(
      (item) => item.product.id == product.id,
    );
    if (index != -1) {
      if (product.isService && delta > 0) {
        return 'Services can only be booked once per order.';
      }
      if (!product.isService &&
          activeCart[index].quantity + delta > product.stock) {
        return 'Cannot exceed available stock limit (${product.stock})';
      }
      activeCart[index].quantity += delta;
      if (activeCart[index].quantity <= 0) {
        activeCart.removeAt(index);
      }
      notifyListeners();
    }
    return null;
  }

  String? setSpecificQuantity(PosProduct product, double qty, {bool isMainTab = false}) {
    if (qty <= 0) {
      removeFromCart(product, isMainTab: isMainTab);
      return null;
    }
    if (!product.allowDecimalQty && qty % 1 != 0) {
      qty = qty.floorToDouble();
    }

    if (product.isService && qty > 1) {
      return 'Services can only be booked once per order.';
    }

    if (!product.isService && qty > product.stock) {
      return 'Cannot exceed available stock limit (${product.stock})';
    }

    final activeCart = _getActiveCart(isMainTab);
    final index = activeCart.indexWhere(
      (item) => item.product.id == product.id,
    );
    if (index != -1) {
      activeCart[index].quantity = qty;
      notifyListeners();
      return null;
    } else {
      return addToCart(product, qty: qty, isMainTab: isMainTab);
    }
  }

  void setIndividualDiscount(
    PosProduct product,
    double discount,
    bool isPercent,
    {bool isMainTab = false}
  ) {
    final activeCart = _getActiveCart(isMainTab);
    final index = activeCart.indexWhere(
      (item) => item.product.id == product.id,
    );
    if (index != -1) {
      activeCart[index].discount = discount;
      activeCart[index].isDiscountPercent = isPercent;
      notifyListeners();
    }
  }

  void setGlobalDiscount(double value, bool isPercent, {bool isMainTab = false}) {
    if (isMainTab) {
      _mainTabGlobalDiscount = value;
      _mainTabIsGlobalDiscountPercent = isPercent;
    } else {
      _globalDiscount = value;
      _isGlobalDiscountPercent = isPercent;
    }
    notifyListeners();
  }

  void clearCart({bool isMainTab = false}) {
    _getActiveCart(isMainTab).clear();
    if (isMainTab) {
      _mainTabActivePromoCode = '';
      _mainTabPromoDiscount = 0.0;
      _mainTabIsPromoPercent = false;
      _mainTabGlobalDiscount = 0.0;
      _mainTabIsGlobalDiscountPercent = false;
    } else {
      _activePromoCode = '';
      _promoDiscount = 0.0;
      _isPromoPercent = false;
      _globalDiscount = 0.0;
      _isGlobalDiscountPercent = false;
    }
    notifyListeners();
  }

  void applyPromoCode(String code, double discount, bool isPercent, {bool isMainTab = false}) {
    if (isMainTab) {
      _mainTabActivePromoCode = code;
      _mainTabPromoDiscount = discount;
      _mainTabIsPromoPercent = isPercent;
    } else {
      _activePromoCode = code;
      _promoDiscount = discount;
      _isPromoPercent = isPercent;
    }
    notifyListeners();
  }

  void clearPromoCode({bool isMainTab = false}) {
    if (isMainTab) {
      _mainTabActivePromoCode = '';
      _mainTabPromoDiscount = 0.0;
      _mainTabIsPromoPercent = false;
    } else {
      _activePromoCode = '';
      _promoDiscount = 0.0;
      _isPromoPercent = false;
    }
    notifyListeners();
  }

  String _orderSearchQuery = '';
  String _orderStatusFilter = 'All';

  String get orderStatusFilter => _orderStatusFilter;

  List<PosOrder> get orders {
    // Globally filter out invoiced orders based on order status
    Iterable<PosOrder> filtered = _orders.where(
      (o) => o.statusText.toLowerCase() != 'invoiced',
    );

    // 1. Text Search Filter
    if (_orderSearchQuery.isNotEmpty) {
      filtered = filtered.where(
        (o) =>
            o.id.toLowerCase().contains(_orderSearchQuery.toLowerCase()) ||
            o.customerName.toLowerCase().contains(
              _orderSearchQuery.toLowerCase(),
            ),
      );
    }

    // 2. Status Tab Filter
    if (_orderStatusFilter != 'All') {
      filtered = filtered.where((o) {
        String statusStr = o.statusText;
        if (o.jobs.isNotEmpty) {
          statusStr = o.latestJob!.status;
        }
        final status = statusStr.toLowerCase();
        switch (_orderStatusFilter) {
          case 'Draft':
            return status == 'draft' || status == 'pending assignment' || status == 'pending';
          case 'Waiting':
            return status.contains('waiting') ||
                status == 'assigned';
          case 'Accepted by Tech':
            return status.contains('accepted');
          case 'In Progress':
            return status == 'in progress';
          case 'Tech Completed':
            return status == 'completed by technician';
          case 'Completed':
            return status == 'completed';
          case 'Cancelled':
            return status.contains('rejected') || status.contains('cancelled');
          default:
            return true;
        }
      });
    }

    return filtered.toList();
  }

  Future<void> fetchOrders({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final token = await sessionService.getToken();
      if (token == null) {
        throw Exception('Token not found');
      }

      final response = await posRepository.getCashierOrders(token);
      if (response.success) {
        _orders = response.orders;
        _orderStats = response.stats;
      } else {
        _errorMessage = 'Failed to fetch orders';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (!silent) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  void setOrderSearchQuery(String query) {
    _orderSearchQuery = query;
    notifyListeners();
  }

  void setOrderStatusFilter(String status) {
    _orderStatusFilter = status;
    notifyListeners();
  }

  Future<void> searchCustomers(String query) async {
    if (query.isEmpty) {
      _searchedCustomers = [];
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _isSearchingCustomer = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await sessionService.getToken();
      if (token == null) {
        throw Exception('Token not found');
      }

      final Map<String, String> queryParams = {};
      // If query is numeric, assume phone, otherwise name
      if (RegExp(r'^[0-9]+$').hasMatch(query)) {
        queryParams['phone'] = query;
      } else {
        queryParams['name'] = query;
      }

      final response = await posRepository.searchCustomers(queryParams, token);
      if (response.success) {
        _searchedCustomers = response.customers;
      } else {
        _errorMessage = response.message;
        _searchedCustomers = [];
      }
    } catch (e) {
      _errorMessage = e.toString();
      _searchedCustomers = [];
    } finally {
      _isSearchingCustomer = false;
      notifyListeners();
    }
  }

  final List<PosTechnician> _allTechnicians = [
    // Oil Change
    PosTechnician(id: 'T1', name: 'M. Sheraz', technicianType: 'Oil Change'),
    PosTechnician(id: 'T2', name: 'M. Sheraz', technicianType: 'Oil Change'),
    PosTechnician(id: 'T3', name: 'M. Sheraz', technicianType: 'Oil Change'),
    PosTechnician(id: 'T4', name: 'M. Sheraz', technicianType: 'Oil Change'),
    PosTechnician(id: 'T5', name: 'M. Sheraz', technicianType: 'Oil Change'),
    PosTechnician(id: 'T6', name: 'M. Sheraz', technicianType: 'Oil Change'),
    PosTechnician(id: 'T7', name: 'M. Sheraz', technicianType: 'Oil Change'),
    PosTechnician(id: 'T8', name: 'M. Sheraz', technicianType: 'Oil Change'),
    // General Repair
    PosTechnician(
      id: 'T9',
      name: 'M. Sheraz',
      technicianType: 'General Repair',
    ),
    PosTechnician(
      id: 'T10',
      name: 'M. Sheraz',
      technicianType: 'General Repair',
    ),
    PosTechnician(
      id: 'T11',
      name: 'M. Sheraz',
      technicianType: 'General Repair',
    ),
    PosTechnician(
      id: 'T12',
      name: 'M. Sheraz',
      technicianType: 'General Repair',
    ),
    PosTechnician(
      id: 'T13',
      name: 'M. Sheraz',
      technicianType: 'General Repair',
    ),
    PosTechnician(
      id: 'T14',
      name: 'M. Sheraz',
      technicianType: 'General Repair',
    ),
    PosTechnician(
      id: 'T15',
      name: 'M. Sheraz',
      technicianType: 'General Repair',
    ),
    PosTechnician(
      id: 'T16',
      name: 'M. Sheraz',
      technicianType: 'General Repair',
    ),
  ];

  String _techSearchQuery = '';

  List<PosTechnician> get technicians {
    if (_techSearchQuery.isEmpty) return _allTechnicians;
    return _allTechnicians
        .where(
          (t) => t.name.toLowerCase().contains(_techSearchQuery.toLowerCase()),
        )
        .toList();
  }

  Map<String, List<PosTechnician>> get techniciansByCategory {
    final Map<String, List<PosTechnician>> map = {};
    for (PosTechnician tech in technicians) {
      if (!map.containsKey(tech.serviceCategory)) {
        map[tech.serviceCategory] = [];
      }
      map[tech.serviceCategory]!.add(tech);
    }
    return map;
  }

  void setTechSearchQuery(String query) {
    _techSearchQuery = query;
    notifyListeners();
  }

  bool isInCart(String productId) {
    return _cartItems.any((item) => item.product.id == productId);
  }

  Future<CreateInvoiceResponse?> generateInvoice(
    String orderId, {
    String? paymentMethod,
    bool? isCorporate,
  }) async {
    _isInvoiceLoading = true;
    _loadingOrderId = orderId;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await sessionService.getToken();
      if (token == null) {
        throw Exception('Token not found');
      }

      final request = CreateInvoiceRequest(
        orderId: orderId,
        discountAmount: 0.0,
        invoicedDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        paymentMethod: paymentMethod,
        isCorporate: isCorporate,
      );

      final response = await posRepository.createInvoice(request, token);
      if (response.success) {
        // Update local order status to avoid refetching
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          _orders[index] = _orders[index].copyWith(status: 'invoiced');

          if (_orderStats.readyForInvoice > 0) {
            _orderStats = OrderStats(
              total: _orderStats.total,
              draft: _orderStats.draft,
              inProgress: _orderStats.inProgress,
              readyForInvoice: _orderStats.readyForInvoice - 1,
              invoiced: _orderStats.invoiced + 1,
              cancelled: _orderStats.cancelled,
            );
          }
        }
        _isInvoiceLoading = false;
        _loadingOrderId = null;
        notifyListeners();
        return response;
      } else {
        _errorMessage = response.message;
        _isInvoiceLoading = false;
        _loadingOrderId = null;
        notifyListeners();
        return response;
      }
    } catch (e) {
      _errorMessage = _extractErrorMessage(e.toString());
      _isInvoiceLoading = false;
      _loadingOrderId = null;
      notifyListeners();
      return CreateInvoiceResponse(success: false, message: _errorMessage!);
    }
  }

  Future<CashierCompleteJobResponse?> completeCashierJob(String jobId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await sessionService.getToken();
      if (token == null) throw Exception('Token not found');

      final response = await posRepository.completeCashierJob(jobId, token);
      if (response.success) {
        // Refresh orders to reflect updated statuses implicitly
        await fetchOrders(silent: true);
        _isLoading = false;
        notifyListeners();
        return response;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return response;
      }
    } catch (e) {
      _errorMessage = _extractErrorMessage(e.toString());
      _isLoading = false;
      notifyListeners();
      return CashierCompleteJobResponse(
        success: false,
        message: _errorMessage!,
      );
    }
  }

  Future<CreateInvoiceResponse?> fetchInvoiceByOrder(String orderId) async {
    _isInvoiceLoading = true;
    _loadingOrderId = orderId;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await sessionService.getToken();
      if (token == null) throw Exception('Token not found');

      final response = await posRepository.getInvoiceByOrder(orderId, token);
      _isInvoiceLoading = false;
      _loadingOrderId = null;
      notifyListeners();
      return response;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e.toString());
      _isInvoiceLoading = false;
      _loadingOrderId = null;
      notifyListeners();
      return CreateInvoiceResponse(success: false, message: _errorMessage!);
    }
  }
}
