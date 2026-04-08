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
import '../../../services/realtime_service.dart';
import '../../../models/walk_in_customer_model.dart';
import '../../../models/customer_search_model.dart';
import '../../../models/create_invoice_model.dart';
import '../../../models/invoiced_orders_model.dart';
import '../../../models/expense_category_model.dart'; // Added
import '../../../models/cashier_complete_job_model.dart'; // Added
import '../../../models/cashier_corporate_accounts_api_model.dart';

class PosViewModel extends ChangeNotifier {
  final PosRepository posRepository;
  final SessionService sessionService;
  final RealtimeService _realtimeService = RealtimeService();

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
    await _initSocket();
  }

  Future<void> _initSocket() async {
    final token = await sessionService.getToken(role: 'cashier');
    if (token == null) return;
    _realtimeService.connect(token);
    _realtimeService.on(RealtimeService.eventCashierOrdersUpdated, _onOrdersUpdated);
    _realtimeService.on(RealtimeService.eventCashierBroadcastUpdated, _onOrdersUpdated);
    _realtimeService.on(RealtimeService.eventCorporateWalkInOrderUpdated, _onOrdersUpdated);
    _realtimeService.on(RealtimeService.eventCashierCorporateWalkInApproved, _onOrdersUpdated);
    _realtimeService.on(RealtimeService.eventCashierCorporateWalkInRejected, _onOrdersUpdated);
  }

  void _onOrdersUpdated(Map<String, dynamic> payload) {
    fetchOrders(silent: true);
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
  String _vinNumber = '';
  String _make = '';
  String _model = '';
  int _odometerReading = 0;
  String _vehicleYear = '';
  String _vehicleColor = '';
  String? _previousOrderId;
  /// Set when cashier saves a walk-in under Corporate Customer tab (submit-for-approval flow).
  String? _corporateAccountId;
  String? _editDepartmentId;
  List<dynamic>? _editPreSelectedItems;
  PosOrder? _editingOrder;
  String? _editingCompletingOrderId;

  String get customerName => _customerName;
  String get vatNumber => _vatNumber;
  String get mobile => _mobile;
  String get vehicleNumber => _vehicleNumber;
  String get vinNumber => _vinNumber;
  String get make => _make;
  String get model => _model;
  int get odometerReading => _odometerReading;
  String get vehicleYear => _vehicleYear;
  String get vehicleColor => _vehicleColor;
  String? get editDepartmentId => _editDepartmentId;
  List<dynamic>? get editPreSelectedItems => _editPreSelectedItems;
  PosOrder? get editingOrder => _editingOrder;
  String? get editingCompletingOrderId => _editingCompletingOrderId;
  String? get corporateAccountId => _corporateAccountId;

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
    _realtimeService.off(RealtimeService.eventCashierOrdersUpdated, _onOrdersUpdated);
    _realtimeService.off(RealtimeService.eventCashierBroadcastUpdated, _onOrdersUpdated);
    _realtimeService.off(RealtimeService.eventCorporateWalkInOrderUpdated, _onOrdersUpdated);
    _realtimeService.off(RealtimeService.eventCashierCorporateWalkInApproved, _onOrdersUpdated);
    _realtimeService.off(RealtimeService.eventCashierCorporateWalkInRejected, _onOrdersUpdated);
    _realtimeService.disconnect();
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

  /// Billing + vehicle snapshot before invoice (walk-in billing PATCH).
  void updateWalkInBillingContact({
    required String name,
    required String mobile,
    String vat = '',
    String vehicleNumber = '',
    String vin = '',
    String make = '',
    String model = '',
    int odometer = 0,
    String year = '',
    String color = '',
  }) {
    _customerName = name.trim();
    _mobile = mobile.trim();
    _vatNumber = vat.trim();
    _vehicleNumber = vehicleNumber.trim();
    _vinNumber = vin.trim();
    _make = make.trim();
    _model = model.trim();
    _odometerReading = odometer;
    _vehicleYear = year.trim();
    _vehicleColor = color.trim();
    notifyListeners();
  }

  void setCustomerData({
    required String name,
    required String vat,
    required String mobile,
    required String vehicleNumber,
    String vinNumber = '',
    required String make,
    required String model,
    required int odometer,
    String? previousOrderId,
  }) {
    _customerName = name;
    _vatNumber = vat;
    _mobile = mobile;
    _vehicleNumber = vehicleNumber;
    _vinNumber = vinNumber;
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
    _vinNumber = '';
    _make = '';
    _model = '';
    _odometerReading = 0;
    _vehicleYear = '';
    _vehicleColor = '';
    _previousOrderId = null;
    _corporateAccountId = null;
    clearEditOrderContext(notify: false);
    _cartItems.clear();
    _activePromoCode = '';
    _promoDiscount = 0.0;
    _globalDiscount = 0.0;
    notifyListeners();
  }

  void setEditOrderContext({
    required String departmentId,
    required List<dynamic> preSelectedItems,
    required PosOrder order,
    required String completingOrderId,
  }) {
    _editDepartmentId = departmentId;
    _editPreSelectedItems = preSelectedItems;
    _editingOrder = order;
    _editingCompletingOrderId = completingOrderId;
    notifyListeners();
  }

  void clearEditOrderContext({bool notify = true}) {
    _editDepartmentId = null;
    _editPreSelectedItems = null;
    _editingOrder = null;
    _editingCompletingOrderId = null;
    if (notify) {
      notifyListeners();
    }
  }

  void saveCustomerAndProceed({
    required bool isNormal,
    required String name,
    required String vat,
    required String mobile,
    required String vehicleNumber,
    required String vinNumber,
    required String make,
    required String model,
    required String odometerStr,
    required CashierCorporateAccount? selectedCorporateData,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) {
    if (isNormal) {
      _corporateAccountId = null;
      setCustomerData(
        name: name,
        vat: vat,
        mobile: mobile,
        vehicleNumber: vehicleNumber,
        vinNumber: vinNumber,
        make: make,
        model: model,
        odometer: int.tryParse(odometerStr) ?? 0,
      );
    } else {
      if (selectedCorporateData == null) {
        onError('Please select a corporate account');
        return;
      }
      _corporateAccountId = selectedCorporateData.id;
      setCustomerData(
        name: name.trim().isNotEmpty ? name.trim() : selectedCorporateData.companyName,
        vat: vat.isNotEmpty ? vat : (selectedCorporateData.effectiveVatNumber ?? ''),
        mobile: mobile.isNotEmpty ? mobile : (selectedCorporateData.customer?.mobile ?? ''),
        vehicleNumber: vehicleNumber,
        vinNumber: vinNumber,
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
    {bool clearCustomerOnSuccess = true}
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await sessionService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final isCorpSubmit =
          _corporateAccountId != null && _corporateAccountId!.trim().isNotEmpty;
      if (isCorpSubmit && _customerName.trim().isEmpty) {
        _errorMessage = 'Contact name is required for corporate quote';
        _isLoading = false;
        notifyListeners();
        if (context.mounted) ToastService.showError(context, _errorMessage!);
        return false;
      }

      if (_vehicleNumber.trim().isEmpty) {
        _errorMessage = 'Vehicle plate is required';
        _isLoading = false;
        notifyListeners();
        if (context.mounted) ToastService.showError(context, _errorMessage!);
        return false;
      }

      final List<RequestedProduct> products = [];
      final List<RequestedService> services = [];

      for (var item in _cartItems) {
        if (item.product.isService && item.product.isPriceEditable) {
          if (item.effectiveUnitPrice <= 0) {
            _errorMessage = 'Enter a valid unit price for ${item.product.name}';
            _isLoading = false;
            notifyListeners();
            if (context.mounted) ToastService.showError(context, _errorMessage!);
            return false;
          }
        }
        final beforeDiscountPrice = item.lineSubtotalGross;
        final afterDiscountPrice = beforeDiscountPrice - item.actualDiscountAmount;
        if (item.product.isService) {
          services.add(
            RequestedService(
              serviceId: item.product.id,
              departmentId: item.product.departmentId ?? departmentIds.first,
              qty: item.quantity,
              discountType: item.discount > 0 ? (item.isDiscountPercent ? 'percent' : 'amount') : null,
              discountValue: item.discount > 0 ? item.discount : null,
              beforeDiscountPrice: beforeDiscountPrice,
              afterDiscountPrice: afterDiscountPrice,
              unitPrice: item.product.isPriceEditable ? item.effectiveUnitPrice : null,
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
              beforeDiscountPrice: beforeDiscountPrice,
              afterDiscountPrice: afterDiscountPrice,
            ),
          );
        }
      }

      final amountBeforeDiscount = getSubtotalGross(false);
      final amountAfterDiscount = getPriceAfterJobDiscount(false);
      final amountAfterPromo = getTotalTaxableAmountValue(false);
      const vatPercent = 15.0;
      final totalAmount = getTotalAmountValue(false);

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
        vinNumber: _vinNumber.isNotEmpty ? _vinNumber : null,
        make: _make,
        model: _model,
        odometerReading: _odometerReading,
        departmentIds: allDepartmentIds.toList(),
        products: products.isNotEmpty ? products : null,
        services: services.isNotEmpty ? services : null,
        totalDiscountType: _globalDiscount > 0 ? (_isGlobalDiscountPercent ? 'percent' : 'amount') : null,
        totalDiscountValue: _globalDiscount > 0 ? _globalDiscount : null,
        promoCode: _promoDiscount > 0 ? _activePromoCode : null,
        promoCodeId: _promoDiscount > 0 ? _activePromoCodeId : null,
        amountBeforeDiscount: amountBeforeDiscount,
        amountAfterDiscount: amountAfterDiscount,
        amountAfterPromo: amountAfterPromo,
        vat: vatPercent,
        totalAmount: totalAmount,
        corporateAccountId:
            (_corporateAccountId != null && _corporateAccountId!.isNotEmpty) ? _corporateAccountId : null,
      );

      final WalkInCustomerResponse response = (_corporateAccountId != null && _corporateAccountId!.isNotEmpty)
          ? await posRepository.submitWalkInCorporateForApproval(request, token)
          : await posRepository.createWalkInOrder(request, token);

      if (response.success) {
        // Pick greatest numeric jobId when departments already have jobs (normal walk-in).
        String? maxJobId;
        if (response.order?.departments.isNotEmpty == true) {
          final sorted = [...response.order!.departments]
            ..sort(
              (a, b) => (int.tryParse(a.jobId ?? '') ?? 0).compareTo(
                int.tryParse(b.jobId ?? '') ?? 0,
              ),
            );
          maxJobId = sorted.last.jobId;
        }

        _previousOrderId = response.order?.id ?? _previousOrderId;
        final isCorpSubmit = _corporateAccountId != null && _corporateAccountId!.isNotEmpty;
        if (isCorpSubmit) {
          final jid = maxJobId ?? response.order?.jobId;
          _currentJobId = (jid != null && jid.isNotEmpty) ? jid : null;
        } else {
          _currentJobId = maxJobId ?? response.order?.jobId ?? response.order?.id;
        }
        _isLoading = false;
        if (clearCustomerOnSuccess) {
          clearCustomerData(); // Reset for next order
        }
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

  Future<bool> submitEditOrder(
    List<String> departmentIds,
    BuildContext context,
  ) async {
    final orderId = _editingOrder?.id ?? '';
    final jobId = _editingCompletingOrderId ?? '';

    if (orderId.isEmpty || jobId.isEmpty) {
      if (context.mounted) {
        ToastService.showError(context, 'Edit context missing. Please try again.');
      }
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await sessionService.getToken();
      if (token == null) throw Exception('Authentication token not found');

      final List<Map<String, dynamic>> products = [];
      final List<Map<String, dynamic>> services = [];

      for (var item in _cartItems) {
        if (item.product.isService && item.product.isPriceEditable && item.effectiveUnitPrice <= 0) {
          if (context.mounted) {
            ToastService.showError(context, 'Enter a valid unit price for ${item.product.name}');
          }
          _isLoading = false;
          notifyListeners();
          return false;
        }
        final beforeDiscountPrice = item.lineSubtotalGross;
        final afterDiscountPrice = beforeDiscountPrice - item.actualDiscountAmount;
        if (item.product.isService) {
          services.add({
            'serviceId': item.product.id,
            'departmentId': item.product.departmentId ?? (departmentIds.isNotEmpty ? departmentIds.first : ''),
            'qty': item.quantity,
            if (item.discount > 0) 'discountType': item.isDiscountPercent ? 'percent' : 'amount',
            if (item.discount > 0) 'discountValue': item.discount,
            'beforeDiscountPrice': beforeDiscountPrice,
            'afterDiscountPrice': afterDiscountPrice,
            if (item.product.isPriceEditable) 'unitPrice': item.effectiveUnitPrice,
          });
        } else {
          products.add({
            'productId': item.product.id,
            'departmentId': item.product.departmentId ?? (departmentIds.isNotEmpty ? departmentIds.first : ''),
            'qty': item.quantity,
            if (item.discount > 0) 'discountType': item.isDiscountPercent ? 'percent' : 'amount',
            if (item.discount > 0) 'discountValue': item.discount,
            'beforeDiscountPrice': beforeDiscountPrice,
            'afterDiscountPrice': afterDiscountPrice,
          });
        }
      }

      final Set<String> allDeptIds = {...departmentIds};
      for (var p in products) { final d = p['departmentId']?.toString(); if (d != null && d.isNotEmpty) allDeptIds.add(d); }
      for (var s in services) { final d = s['departmentId']?.toString(); if (d != null && d.isNotEmpty) allDeptIds.add(d); }

      const vatPercent = 15.0;
      final body = <String, dynamic>{
        'customerName': _customerName,
        'mobile': _mobile,
        'vatNumber': _vatNumber,
        'vehicleNumber': _vehicleNumber,
        if (_vinNumber.isNotEmpty) 'vinNumber': _vinNumber,
        'make': _make,
        'model': _model,
        'odometerReading': _odometerReading,
        'departmentId': allDeptIds.isNotEmpty ? allDeptIds.first : departmentIds.firstOrNull ?? '',
        if (products.isNotEmpty) 'products': products,
        if (services.isNotEmpty) 'services': services,
        if (_globalDiscount > 0) 'totalDiscountType': _isGlobalDiscountPercent ? 'percent' : 'amount',
        if (_globalDiscount > 0) 'totalDiscountValue': _globalDiscount,
        if (_promoDiscount > 0 && _activePromoCode != null) 'promoCode': _activePromoCode,
        if (_promoDiscount > 0 && _activePromoCodeId != null) 'promoCodeId': _activePromoCodeId,
        'vat': vatPercent,
        'amountBeforeDiscount': getSubtotalGross(false),
        'amountAfterDiscount': getPriceAfterJobDiscount(false),
        'amountAfterPromo': getTotalTaxableAmountValue(false),
        'totalAmount': getTotalAmountValue(false),
      };

      final response = await posRepository.editOrder(orderId, jobId, body, token);
      final success = response['success'] == true;

      _isLoading = false;
      notifyListeners();

      if (context.mounted) {
        if (success) {
          ToastService.showSuccess(context, response['message']?.toString() ?? 'Order updated successfully');
        } else {
          final msg = response['message']?.toString() ?? 'Failed to update order';
          _errorMessage = msg;
          ToastService.showError(context, msg);
        }
      }
      return success;
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
  String? _activePromoCodeId;
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
  String? get activePromoCodeId => _activePromoCodeId;
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

  double getSubtotalGross(bool isMainTab) => _getActiveCart(isMainTab).fold(
    0,
    (sum, item) => sum + item.lineSubtotalGross,
  );

  double getSubtotalExclVat(bool isMainTab) => getSubtotalGross(isMainTab);

  double getTotalIndividualDiscount(bool isMainTab) =>
      _getActiveCart(isMainTab).fold(0, (sum, item) => sum + item.actualDiscountAmount);

  double getPriceAfterItemDiscounts(bool isMainTab) => 
      getSubtotalGross(isMainTab) - getTotalIndividualDiscount(isMainTab);

  double getTotalGlobalDiscountValue(bool isMainTab) {
    final baseForGlobal = getPriceAfterItemDiscounts(isMainTab);
    if (isMainTab) {
      if (_mainTabIsGlobalDiscountPercent) return baseForGlobal * (_mainTabGlobalDiscount / 100);
      return _mainTabGlobalDiscount;
    } else {
      if (_isGlobalDiscountPercent) return baseForGlobal * (_globalDiscount / 100);
      return _globalDiscount;
    }
  }

  double getPriceAfterJobDiscount(bool isMainTab) => 
      getPriceAfterItemDiscounts(isMainTab) - getTotalGlobalDiscountValue(isMainTab);

  double getTotalPromoDiscountValue(bool isMainTab) {
    final baseForPromo = getPriceAfterJobDiscount(isMainTab);
    if (isMainTab) {
      if (_mainTabIsPromoPercent) return baseForPromo * (_mainTabPromoDiscount / 100);
      return _mainTabPromoDiscount;
    } else {
      if (_isPromoPercent) return baseForPromo * (_promoDiscount / 100);
      return _promoDiscount;
    }
  }

  double getTotalTaxableAmountValue(bool isMainTab) =>
      getPriceAfterJobDiscount(isMainTab) - getTotalPromoDiscountValue(isMainTab);

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

  bool _isSameCartProduct(PosProduct a, PosProduct b) {
    return a.id == b.id &&
        a.isServiceType == b.isServiceType &&
        (a.departmentId ?? '') == (b.departmentId ?? '');
  }

  String? addToCart(PosProduct product, {double qty = 1.0, bool isMainTab = false}) {
    if (!product.allowDecimalQty && qty % 1 != 0) {
      qty = qty.floorToDouble();
    }
    final activeCart = _getActiveCart(isMainTab);
    final existingIndex = activeCart.indexWhere(
      (item) => _isSameCartProduct(item.product, product),
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
    _getActiveCart(isMainTab).removeWhere(
      (item) => _isSameCartProduct(item.product, product),
    );
    notifyListeners();
  }

  String? updateQuantity(PosProduct product, double delta, {bool isMainTab = false}) {
    if (!product.allowDecimalQty && delta % 1 != 0) {
      delta = delta.floorToDouble();
    }
    final activeCart = _getActiveCart(isMainTab);
    final index = activeCart.indexWhere(
      (item) => _isSameCartProduct(item.product, product),
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
      (item) => _isSameCartProduct(item.product, product),
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
      (item) => _isSameCartProduct(item.product, product),
    );
    if (index != -1) {
      activeCart[index].discount = discount;
      activeCart[index].isDiscountPercent = isPercent;
      notifyListeners();
    }
  }

  /// Per-unit price override for price-editable services (cashier).
  void setServiceUnitPrice(
    PosProduct product,
    double? unitPrice, {
    bool isMainTab = false,
  }) {
    if (!product.isService || !product.isPriceEditable) return;
    final activeCart = _getActiveCart(isMainTab);
    final index = activeCart.indexWhere(
      (item) => _isSameCartProduct(item.product, product),
    );
    if (index == -1) return;
    if (unitPrice == null || unitPrice <= 0) {
      activeCart[index].serviceUnitPrice = null;
    } else {
      activeCart[index].serviceUnitPrice = unitPrice;
    }
    notifyListeners();
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
      _activePromoCodeId = null;
      _promoDiscount = 0.0;
      _isPromoPercent = false;
      _globalDiscount = 0.0;
      _isGlobalDiscountPercent = false;
    }
    notifyListeners();
  }

  void applyPromoCode(
    String code,
    double discount,
    bool isPercent, {
    bool isMainTab = false,
    String? promoCodeId,
  }) {
    if (isMainTab) {
      _mainTabActivePromoCode = code;
      _mainTabPromoDiscount = discount;
      _mainTabIsPromoPercent = isPercent;
    } else {
      _activePromoCode = code;
      _activePromoCodeId = promoCodeId;
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
      _activePromoCodeId = null;
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
        final status = o.normalizedJobStatus.toLowerCase();
        switch (_orderStatusFilter) {
          case 'Draft':
            return status == 'draft' || status == 'pending assignment';
          case 'Waiting':
            return status.contains('waiting') ||
                status == 'pending' ||
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
          case 'Corp. pending approval':
            return o.status.toLowerCase().contains('waiting for corporate');
          case 'Corporate approved':
            return o.status.toLowerCase().trim() == 'corporate approved';
          case 'Rejected by corporate':
            return o.status.toLowerCase().contains('rejected by corporate');
          default:
            return true;
        }
      });
    }

    return filtered.toList();
  }

  Future<void> fetchOrders({
    bool silent = false,
    String? statusQuery,
    int? limit,
    int? offset,
  }) async {
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

      final response = await posRepository.getCashierOrders(
        token,
        status: statusQuery,
        limit: limit,
        offset: offset,
      );
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

  /// GET /cashier/order/:orderId — use for `pendingDepartments` after corporate approval.
  Future<PosOrder?> loadCashierOrderDetail(String orderId) async {
    try {
      final token = await sessionService.getToken();
      if (token == null) return null;
      final raw = await posRepository.getCashierOrderDetail(orderId, token);
      final orderMap = raw['order'];
      if (orderMap is Map) {
        return PosOrder.fromJson(Map<String, dynamic>.from(orderMap));
      }
      if (raw['id'] != null) {
        return PosOrder.fromJson(Map<String, dynamic>.from(raw));
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// POST …/walk-in-corporate/order/:orderId/start-department
  Future<bool> startCorporateWalkInDepartment(
    BuildContext context, {
    required String orderId,
    required String departmentId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final token = await sessionService.getToken();
      if (token == null) throw Exception('Token not found');
      final res = await posRepository.startCorporateWalkInDepartment(orderId, departmentId, token);
      final ok = res['success'] == true;
      if (ok) {
        final jid = res['jobId']?.toString();
        if (jid != null && jid.isNotEmpty) {
          _currentJobId = jid;
        }
        _previousOrderId = orderId;
        await fetchOrders(silent: true);
        if (context.mounted) {
          ToastService.showSuccess(
            context,
            res['message']?.toString() ?? 'Department started',
          );
        }
      } else {
        final msg = res['message']?.toString() ?? 'Failed to start department';
        _errorMessage = msg;
        if (context.mounted) ToastService.showError(context, msg);
      }
      return ok;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e.toString());
      if (context.mounted) ToastService.showError(context, _errorMessage!);
      return false;
    } finally {
      _isLoading = false;
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

      final trimmed = query.trim();
      final bool isNumeric = RegExp(r'^[0-9]+$').hasMatch(trimmed);

      CustomerSearchResponse response;
      if (isNumeric) {
        // 1) Try phone match first
        response = await posRepository.searchCustomers({'phone': trimmed}, token);

        // 2) If empty, try customer number / id based lookup
        if (response.success && response.customers.isEmpty) {
          response = await posRepository.searchCustomers({'customerNumber': trimmed}, token);
        }
        if (response.success && response.customers.isEmpty) {
          response = await posRepository.searchCustomers({'customerId': trimmed}, token);
        }
      } else {
        response = await posRepository.searchCustomers({'name': trimmed}, token);
      }

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

  /// Billing PATCH applies only to `walk_in` orders without `corporateAccountId`.
  bool _isStandardWalkInOrderForBilling(PosOrder o) {
    if ((o.corporateAccountId ?? '').trim().isNotEmpty) return false;
    final s = o.source.toLowerCase().replaceAll('-', '_');
    return s == 'walk_in';
  }

  Map<String, dynamic> _buildWalkInBillingPatchBody(PosOrder order) {
    final nameOrder = (order.customer?.name ?? '').trim();
    final mobOrder = (order.customer?.mobile ?? '').trim();
    final vatOrder = (order.customer?.vatNumber ?? '').trim();

    final name = nameOrder.isNotEmpty ? nameOrder : _customerName.trim();
    final mobile = mobOrder.isNotEmpty ? mobOrder : _mobile.trim();
    final vat = vatOrder.isNotEmpty ? vatOrder : _vatNumber.trim();

    final body = <String, dynamic>{
      'customerName': name,
      'mobile': mobile,
    };
    if (vat.isNotEmpty) body['vatNumber'] = vat;

    if (_odometerReading != 0) {
      body['odometerReading'] = _odometerReading;
    }

    final plateOrder = (order.vehicle?.plateNo ?? '').trim();
    final plateVm = _vehicleNumber.trim();
    final makeVm = _make.trim();
    final modelVm = _model.trim();
    final vinVm = _vinNumber.trim();

    final yearVm = _vehicleYear.trim();
    final colorVm = _vehicleColor.trim();
    final wantsVehicleFields = plateVm.isNotEmpty ||
        makeVm.isNotEmpty ||
        modelVm.isNotEmpty ||
        vinVm.isNotEmpty ||
        yearVm.isNotEmpty ||
        colorVm.isNotEmpty;

    if (wantsVehicleFields) {
      final plate = plateVm.isNotEmpty ? plateVm : plateOrder;
      if (plate.isEmpty) {
        throw StateError(
          'vehicleNumber is required when sending vehicle fields. Add the plate under Add Customer.',
        );
      }
      body['vehicleNumber'] = plate;
      if (makeVm.isNotEmpty) {
        body['make'] = makeVm;
      } else if ((order.vehicle?.make ?? '').trim().isNotEmpty) {
        body['make'] = order.vehicle!.make.trim();
      }
      if (modelVm.isNotEmpty) {
        body['model'] = modelVm;
      } else if ((order.vehicle?.model ?? '').trim().isNotEmpty) {
        body['model'] = order.vehicle!.model.trim();
      }
      if (yearVm.isNotEmpty) {
        final yi = int.tryParse(yearVm);
        if (yi != null) body['year'] = yi;
      } else {
        final yStr = order.vehicle?.year?.trim();
        if (yStr != null && yStr.isNotEmpty) {
          final yi = int.tryParse(yStr);
          if (yi != null) body['year'] = yi;
        }
      }
      if (colorVm.isNotEmpty) {
        body['color'] = colorVm;
      } else {
        final col = order.vehicle?.color?.trim();
        if (col != null && col.isNotEmpty) body['color'] = col;
      }
      if (vinVm.isNotEmpty) {
        body['vin'] = vinVm;
      } else {
        final ov = order.vehicle?.vin?.trim();
        if (ov != null && ov.isNotEmpty) body['vin'] = ov;
      }
    }

    return body;
  }

  Future<CreateInvoiceResponse?> generateInvoice(
    String orderId, {
    String? paymentMethod,
    bool? isCorporate,
    PosOrder? orderForBilling,
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

      PosOrder? orderCtx = orderForBilling;
      if (orderCtx == null) {
        for (final o in _orders) {
          if (o.id == orderId) {
            orderCtx = o;
            break;
          }
        }
      }
      orderCtx ??= await loadCashierOrderDetail(orderId);

      if (orderCtx != null && _isStandardWalkInOrderForBilling(orderCtx)) {
        try {
          final billingBody = _buildWalkInBillingPatchBody(orderCtx);
          final cn = (billingBody['customerName'] as String? ?? '').trim();
          final mb = (billingBody['mobile'] as String? ?? '').trim();
          if (cn.isEmpty || mb.isEmpty) {
            final msg =
                'Customer name and mobile are required before invoice. Complete the billing prompt or update customer details.';
            _errorMessage = msg;
            _isInvoiceLoading = false;
            _loadingOrderId = null;
            notifyListeners();
            return CreateInvoiceResponse(success: false, message: msg);
          }
          final plateOnOrder = (orderCtx.vehicle?.plateNo ?? '').trim();
          final plateInBody = (billingBody['vehicleNumber'] as String? ?? '').trim();
          if (plateOnOrder.isEmpty && plateInBody.isEmpty) {
            final msg =
                'Vehicle plate is required before invoice. Add it under Add Customer (billing), then try again.';
            _errorMessage = msg;
            _isInvoiceLoading = false;
            _loadingOrderId = null;
            notifyListeners();
            return CreateInvoiceResponse(success: false, message: msg);
          }

          final patchRes =
              await posRepository.patchWalkInOrderBilling(orderId, billingBody, token);
          if (patchRes['success'] != true) {
            final msg =
                patchRes['message']?.toString() ?? 'Failed to update billing details before invoice';
            _errorMessage = msg;
            _isInvoiceLoading = false;
            _loadingOrderId = null;
            notifyListeners();
            return CreateInvoiceResponse(success: false, message: msg);
          }
          await fetchOrders(silent: true);
        } on StateError catch (e) {
          final msg = e.message;
          _errorMessage = msg;
          _isInvoiceLoading = false;
          _loadingOrderId = null;
          notifyListeners();
          return CreateInvoiceResponse(success: false, message: msg);
        }
      }

      final request = CreateInvoiceRequest(
        orderId: orderId,
        discountAmount: 0.0,
        invoiceDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        paymentMethod: paymentMethod,
        isCorporate: isCorporate,
      );

      debugPrint(
        'InvoiceFlow: creating invoice for orderId=$orderId, invoiceDate=${request.invoiceDate}, paymentMethod=${request.paymentMethod ?? 'N/A'}',
      );
      final createResponse = await posRepository.createInvoice(request, token);
      if (createResponse.success) {
        debugPrint(
          'InvoiceFlow: create success, invoiceId=${createResponse.invoice?.id ?? 'N/A'}, invoiceNo=${createResponse.invoice?.invoiceNo ?? 'N/A'}',
        );
        // Immediately fetch full invoice details by order id
        final detailedResponse = await posRepository.getInvoiceByOrder(
          orderId,
          token,
        );
        final finalResponse = detailedResponse.success
            ? detailedResponse
            : createResponse;
        debugPrint(
          detailedResponse.success
              ? 'InvoiceFlow: using detailed by-order response for orderId=$orderId'
              : 'InvoiceFlow: by-order fetch failed, falling back to create response. reason=${detailedResponse.message}',
        );

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
              waitingForCorporateApproval: _orderStats.waitingForCorporateApproval,
              corporateApproved: _orderStats.corporateApproved,
              rejectedByCorporate: _orderStats.rejectedByCorporate,
            );
          }
        }
        _isInvoiceLoading = false;
        _loadingOrderId = null;
        notifyListeners();
        debugPrint(
          'InvoiceFlow: completed. source=${detailedResponse.success ? 'by-order' : 'create'} total=${finalResponse.invoice?.totalAmount ?? 0}',
        );
        return finalResponse;
      } else {
        debugPrint(
          'InvoiceFlow: create failed for orderId=$orderId. reason=${createResponse.message}',
        );
        _errorMessage = createResponse.message;
        _isInvoiceLoading = false;
        _loadingOrderId = null;
        notifyListeners();
        return createResponse;
      }
    } catch (e) {
      _errorMessage = _extractErrorMessage(e.toString());
      _isInvoiceLoading = false;
      _loadingOrderId = null;
      notifyListeners();
      return CreateInvoiceResponse(success: false, message: _errorMessage!);
    }
  }

  Future<CashierCompleteJobResponse?> completeCashierJob(
    String jobId, {
    bool isMainTab = false,
    PosOrder? sourceOrder,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await sessionService.getToken();
      if (token == null) throw Exception('Token not found');

      // 1) Build pricing payload from current cart/discount state
      final activeCart = isMainTab ? _mainTabCartItems : _cartItems;
      final List<Map<String, dynamic>> products = [];
      final List<Map<String, dynamic>> services = [];

      for (var item in activeCart) {
        if (item.product.isService && item.product.isPriceEditable && item.effectiveUnitPrice <= 0) {
          _errorMessage = 'Enter a valid unit price for ${item.product.name}';
          _isLoading = false;
          notifyListeners();
          return CashierCompleteJobResponse(success: false, message: _errorMessage!);
        }
        final lineBefore = item.lineSubtotalGross;
        final lineAfter = lineBefore - item.actualDiscountAmount;
        final map = <String, dynamic>{
          item.product.isService ? 'serviceId' : 'productId': item.product.id,
          'qty': item.quantity,
          'discountType': item.discount > 0
              ? (item.isDiscountPercent ? 'percent' : 'amount')
              : 'amount',
          'discountValue': item.discount > 0 ? item.discount : 0,
        };
        if (item.product.isService) {
          map['beforeDiscountPrice'] = lineBefore;
          map['afterDiscountPrice'] = lineAfter;
          if (item.product.isPriceEditable) {
            map['unitPrice'] = item.effectiveUnitPrice;
          }
          services.add(map);
        } else {
          products.add(map);
        }
      }

      // If cart is empty (common from complete sheet), prefill pricing from current order job data.
      final sourceJob = sourceOrder?.latestJob;
      if (products.isEmpty && services.isEmpty && sourceJob != null) {
        for (final item in sourceJob.items) {
          final lineBefore = item.unitPrice * item.qty;
          final map = <String, dynamic>{
            item.itemType == 'service' ? 'serviceId' : 'productId': item.productId,
            'qty': item.qty,
            'discountType': (item.discountType ?? '').isNotEmpty
                ? item.discountType
                : 'amount',
            'discountValue': item.discountValue ?? 0,
            'beforeDiscountPrice': lineBefore,
            'afterDiscountPrice': item.lineTotal,
          };
          if (item.itemType == 'service') {
            map['unitPrice'] = item.unitPrice;
            services.add(map);
          } else {
            products.add(map);
          }
        }
      }

      final activeGlobalDiscount = getActiveGlobalDiscount(isMainTab);
      final activeGlobalType = getActiveIsGlobalDiscountPercent(isMainTab)
          ? 'percent'
          : 'amount';
      final fallbackGlobalValue =
          sourceJob?.totalDiscountValue ?? sourceOrder?.totalDiscountValue ?? 0;
      final fallbackGlobalType =
          sourceJob?.totalDiscountType ?? sourceOrder?.totalDiscountType ?? 'amount';

      final effectiveGlobalValue =
          activeGlobalDiscount > 0 ? activeGlobalDiscount : fallbackGlobalValue;
      final effectiveGlobalType =
          activeGlobalDiscount > 0 ? activeGlobalType : fallbackGlobalType;
      final hasLiveCartData = products.isNotEmpty || services.isNotEmpty;
      final effectivePromoId = hasLiveCartData
          ? (_activePromoCodeId ??
              sourceJob?.promoCodeId ??
              sourceOrder?.promoCodeId)
          : (sourceJob?.promoCodeId ?? sourceOrder?.promoCodeId);
      final normalizedPromoId =
          (effectivePromoId != null && effectivePromoId.trim().isNotEmpty)
              ? effectivePromoId.trim()
              : null;
      final effectiveVat = sourceJob?.vatPercent ?? 15.0;

      final pricingBody = <String, dynamic>{
        'products': products,
        'services': services,
        'totalDiscountType': effectiveGlobalType,
        'totalDiscountValue': effectiveGlobalValue,
        'VAT': effectiveVat,
        'promoCodeId': (!isMainTab && normalizedPromoId != null)
            ? normalizedPromoId
            : null,
      };

      // 2) Persist/refresh job-level pricing
      await posRepository.updateJobPricing(jobId, pricingBody, token);

      // 3) Check readiness before completion
      final readyResponse = await posRepository.checkJobCompleteReady(jobId, token);
      if (!readyResponse.success || !readyResponse.isReady) {
        _errorMessage = readyResponse.message.isNotEmpty
            ? readyResponse.message
            : 'Please add products/services before completing the job.';
        _isLoading = false;
        notifyListeners();
        return CashierCompleteJobResponse(
          success: false,
          message: _errorMessage!,
        );
      }

      // 4) Complete cashier job (API allows optional pricing updates in body)
      final response = await posRepository.completeCashierJob(
        jobId,
        token,
        body: pricingBody,
      );
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

  /// Broadcast a job to technicians in workshop or on-call duty (POST /cashier/jobs/:jobId/broadcast).
  Future<bool> broadcastJob(
    BuildContext context,
    String jobId, {
    required String dutyMode,
  }) async {
    if (jobId.isEmpty) {
      if (context.mounted) {
        ToastService.showError(
          context,
          'Save the order first before broadcasting.',
        );
      }
      return false;
    }
    try {
      final token = await sessionService.getToken();
      if (token == null) throw Exception('Token not found');
      final res = await posRepository.postJobBroadcast(jobId, dutyMode, token);
      if (res['success'] != true) {
        throw Exception(res['message']?.toString() ?? 'Broadcast failed');
      }
      if (context.mounted) {
        ToastService.showSuccess(
          context,
          res['message']?.toString() ?? 'Broadcast sent to technicians',
        );
      }
      await fetchOrders(silent: true);
      return true;
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, _extractErrorMessage(e.toString()));
      }
      return false;
    }
  }

  /// Cancel an active broadcast and return job to pending assignment.
  Future<bool> cancelJobBroadcast(BuildContext context, String jobId) async {
    if (jobId.isEmpty) return false;
    try {
      final token = await sessionService.getToken();
      if (token == null) throw Exception('Token not found');
      final res = await posRepository.cancelJobBroadcast(jobId, token);
      if (res['success'] != true) {
        throw Exception(res['message']?.toString() ?? 'Cancel broadcast failed');
      }
      if (context.mounted) {
        ToastService.showSuccess(
          context,
          res['message']?.toString() ?? 'Broadcast cancelled',
        );
      }
      await fetchOrders(silent: true);
      return true;
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, _extractErrorMessage(e.toString()));
      }
      return false;
    }
  }

  Future<bool> cancelOrder(BuildContext context, String orderId, String reason) async {
    try {
      final token = await sessionService.getToken();
      if (token == null) throw Exception('Token not found');
      await posRepository.cancelOrder(orderId, reason, token);
      if (context.mounted) {
        ToastService.showSuccess(context, 'Order cancelled successfully');
      }
      await fetchOrders(silent: true);
      return true;
    } catch (e) {
      if (context.mounted) {
        final msg = e.toString().contains('reason is required')
            ? 'Cancellation reason is required'
            : 'Failed to cancel order';
        ToastService.showError(context, msg);
      }
      return false;
    }
  }

  Future<InvoicedOrderResponse?> fetchCustomerInvoicedHistory(String customerId) async {
    try {
      final token = await sessionService.getToken();
      if (token == null) throw Exception('Token not found');
      return await posRepository.getInvoicedOrdersByCustomer(customerId, token);
    } catch (e) {
      return null;
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

