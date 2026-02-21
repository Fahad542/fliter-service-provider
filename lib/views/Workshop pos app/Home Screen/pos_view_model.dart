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



class PosViewModel extends ChangeNotifier {
  final PosRepository posRepository;
  final SessionService sessionService;

  PosViewModel({
    required this.posRepository,
    required this.sessionService,
  }) {
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

  // Mock corporate list (Moved from View)
  final List<Map<String, String>> _corporateList = [
    {'name': 'Saudi Aramco', 'vat': '300123456789', 'address': 'Dhahran, Eastern Province'},
    {'name': 'SABIC', 'vat': '300987654321', 'address': 'Riyadh, Riyadh Province'},
    {'name': 'STC', 'vat': '300111222333', 'address': 'Riyadh, Olaya District'},
    {'name': 'Al Rajhi Bank', 'vat': '300444555666', 'address': 'Riyadh, King Fahd Road'},
  ];

  List<Map<String, String>> get corporateList => _corporateList;

  // Walk-in Customer State
  String _customerName = '';
  String _vatNumber = '';
  String _mobile = '';
  String _vehicleNumber = '';
  String _make = '';
  String _model = '';
  int _odometerReading = 0;

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
  }) {
    _customerName = name;
    _vatNumber = vat;
    _mobile = mobile;
    _vehicleNumber = vehicleNumber;
    _make = make;
    _model = model;
    _odometerReading = odometer;
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
    required Map<String, String>? selectedCorporateData,
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
        name: selectedCorporateData['name'] ?? '',
        vat: selectedCorporateData['vat'] ?? '',
        mobile: '',
        vehicleNumber: vehicleNumber,
        make: make,
        model: model,
        odometer: int.tryParse(odometerStr) ?? 0,
      );
    }
    onSuccess();
  }
  Future<bool> submitWalkInOrder(List<String> departmentIds, BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await sessionService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final List<RequestedProduct> products = _cartItems.map((item) => RequestedProduct(
        productId: item.product.id,
        departmentId: item.product.departmentId ?? departmentIds.first,
        qty: item.quantity,
      )).toList();
      
      // Combine the passed departmentIds with any departmentIds from the selected products
      final Set<String> allDepartmentIds = {...departmentIds};
      for (var product in products) {
        if (product.departmentId.isNotEmpty) {
          allDepartmentIds.add(product.departmentId);
        }
      }

      final request = WalkInCustomerRequest(
        customerName: _customerName,
        vatNumber: _vatNumber,
        mobile: _mobile,
        vehicleNumber: _vehicleNumber,
        make: _make,
        model: _model,
        odometerReading: _odometerReading,
        departmentIds: allDepartmentIds.toList(),
        products: products,
      );

      final response = await posRepository.createWalkInOrder(request, token);
      
      if (response.success) {
        _currentJobId = response.order?.id;
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

  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await sessionService.getToken();
      final user = await sessionService.getUser();
      
      if (token == null || user == null || user.workshopId == null) {
        throw Exception('Authentication information missing');
      }

      final response = await posRepository.getProducts(user.workshopId!, token);
      
      if (response.success) {
        _allProducts = [];
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




  String _selectedCategory = 'All';
  String _searchQuery = '';

  List<PosProduct> get allProducts => _allProducts;
  List<CartItem> get cartItems => _cartItems;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String get activePromoCode => _activePromoCode;
  double get promoDiscount => _promoDiscount;
  bool get isPromoPercent => _isPromoPercent;

  double get globalDiscount => _globalDiscount;
  bool get isGlobalDiscountPercent => _isGlobalDiscountPercent;

  List<String> get uniqueCategories {
    final cats = _allProducts.map((p) => p.category).toSet().toList();
    cats.sort();
    return ['All', ...cats];
  }

  List<PosProduct> get products {
    return _allProducts.where((p) {
      final matchesCategory = _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  double get subtotalExclVat => _cartItems.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  
  double get totalIndividualDiscount => _cartItems.fold(0, (sum, item) => sum + item.actualDiscountAmount);

  double get totalGlobalDiscount {
    if (_isGlobalDiscountPercent) {
      return subtotalExclVat * (_globalDiscount / 100);
    }
    return _globalDiscount;
  }
  
  double get totalPromoDiscount {
    final baseForPromo = subtotalExclVat - totalIndividualDiscount - totalGlobalDiscount;
    if (_isPromoPercent) {
      return baseForPromo * (_promoDiscount / 100);
    }
    return _promoDiscount;
  }

  double get totalTaxableAmount => subtotalExclVat - totalIndividualDiscount - totalGlobalDiscount - totalPromoDiscount;
  double get totalTax => totalTaxableAmount * 0.15; // 15% VAT
  double get totalAmount => totalTaxableAmount + totalTax;

  int get cartCount => _cartItems.fold(0, (sum, item) => sum + (item.quantity >= 1 ? item.quantity.toInt() : 1));

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void addToCart(PosProduct product, {double qty = 1.0}) {
    final existingIndex = _cartItems.indexWhere((item) => item.product.id == product.id);
    if (existingIndex != -1) {
      _cartItems[existingIndex].quantity += qty;
    } else {
      _cartItems.add(CartItem(product: product, quantity: qty, isDiscountPercent: false));
    }
    notifyListeners();
  }

  void removeFromCart(PosProduct product) {
    _cartItems.removeWhere((item) => item.product.id == product.id);
    notifyListeners();
  }

  void updateQuantity(PosProduct product, double delta) {
    final index = _cartItems.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      _cartItems[index].quantity += delta;
      if (_cartItems[index].quantity <= 0) {
        _cartItems.removeAt(index);
      }
      notifyListeners();
    }
  }

  void setSpecificQuantity(PosProduct product, double qty) {
    final index = _cartItems.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      _cartItems[index].quantity = qty;
      if (_cartItems[index].quantity <= 0) {
        _cartItems.removeAt(index);
      }
      notifyListeners();
    }
  }

  void setIndividualDiscount(PosProduct product, double discount, bool isPercent) {
    final index = _cartItems.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      _cartItems[index].discount = discount;
      _cartItems[index].isDiscountPercent = isPercent;
      notifyListeners();
    }
  }

  void setGlobalDiscount(double value, bool isPercent) {
    _globalDiscount = value;
    _isGlobalDiscountPercent = isPercent;
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    _activePromoCode = '';
    _promoDiscount = 0.0;
    _isPromoPercent = false;
    _globalDiscount = 0.0;
    _isGlobalDiscountPercent = false;
    notifyListeners();
  }

  void applyPromoCode(String code, double discount, bool isPercent) {
    _activePromoCode = code;
    _promoDiscount = discount;
    _isPromoPercent = isPercent;
    notifyListeners();
  }

  void clearPromoCode() {
    _activePromoCode = '';
    _promoDiscount = 0.0;
    _isPromoPercent = false;
  }


  String _orderSearchQuery = '';

  List<PosOrder> get orders {
    if (_orderSearchQuery.isEmpty) return _orders;
    return _orders.where((o) => 
      o.id.toLowerCase().contains(_orderSearchQuery.toLowerCase()) ||
      o.customerName.toLowerCase().contains(_orderSearchQuery.toLowerCase())
    ).toList();
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
    PosTechnician(
      id: 'T1',
      name: 'M. Sheraz',
      technicianType: 'Oil Change',
    ),
    PosTechnician(
      id: 'T2',
      name: 'M. Sheraz',
      technicianType: 'Oil Change',
    ),
    PosTechnician(
      id: 'T3',
      name: 'M. Sheraz',
      technicianType: 'Oil Change',
    ),
    PosTechnician(
      id: 'T4',
      name: 'M. Sheraz',
      technicianType: 'Oil Change',
    ),
    PosTechnician(
      id: 'T5',
      name: 'M. Sheraz',
      technicianType: 'Oil Change',
    ),
    PosTechnician(
      id: 'T6',
      name: 'M. Sheraz',
      technicianType: 'Oil Change',
    ),
    PosTechnician(
      id: 'T7',
      name: 'M. Sheraz',
      technicianType: 'Oil Change',
    ),
    PosTechnician(
      id: 'T8',
      name: 'M. Sheraz',
      technicianType: 'Oil Change',
    ),
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
    return _allTechnicians.where((t) => 
      t.name.toLowerCase().contains(_techSearchQuery.toLowerCase())
    ).toList();
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





  Future<CreateInvoiceResponse?> generateInvoice(String orderId) async {
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
