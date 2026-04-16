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

class _DepartmentPromoState {
  final String code;
  final String? promoCodeId;
  final double discount;
  final bool isPercent;

  const _DepartmentPromoState({
    required this.code,
    required this.promoCodeId,
    required this.discount,
    required this.isPercent,
  });
}

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
    _ordersRealtimeDebounce?.cancel();
    _ordersRealtimeDebounce = Timer(const Duration(milliseconds: 400), () {
      _ordersRealtimeDebounce = null;
      final last = _lastCashierOrdersFetchedAt;
      if (last != null &&
          DateTime.now().difference(last) < const Duration(milliseconds: 800)) {
        return;
      }
      fetchOrders(silent: true);
    });
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
  /// Last order returned from a successful walk-in shell / create (for jobId lookup by department).
  WalkInOrder? _lastPlacedWalkInOrder;
  /// Tracks the latest created walk-in order id for post-create redirect selection.
  String? _lastCreatedWalkInOrderId;
  /// Fallback selector when backend create response omits order.id.
  String? _lastCreatedWalkInVehicleNumber;
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
  WalkInOrder? get lastPlacedWalkInOrder => _lastPlacedWalkInOrder;
  String? get lastCreatedWalkInOrderId => _lastCreatedWalkInOrderId;
  String? get lastCreatedWalkInVehicleNumber => _lastCreatedWalkInVehicleNumber;

  /// Job id for a department on the last successful walk-in create response (shell).
  String? jobIdForPlacedDepartment(String departmentId) {
    final o = _lastPlacedWalkInOrder;
    if (o == null || departmentId.trim().isEmpty) return null;
    final want = departmentId.trim();
    for (final d in o.departments) {
      if ((d.departmentId ?? '').trim() == want) {
        final jid = d.jobId?.trim();
        if (jid != null && jid.isNotEmpty) return jid;
      }
    }
    return null;
  }

  bool _isLoading = false;
  /// True after [fetchOrders] finishes (success or error), including `silent` calls.
  bool _ordersApiFetchCompleted = false;
  /// True while Save on the product-grid invoice panel is running (pricing / walk-in from panel).
  bool _invoicePanelSaveBusy = false;
  String? _errorMessage;
  String? _currentJobId;
  List<PosOrder> _orders = [];
  PosOrder? _selectedOrder;
  OrderStats _orderStats = OrderStats.empty();
  List<SearchedCustomer> _searchedCustomers = [];
  bool _isSearchingCustomer = false;
  int _shellSelectedIndex = 0;

  String? _cashierName;
  String? _workshopName;
  String? _branchName;

  bool _isInvoiceLoading = false;
  String? _loadingOrderId;
  /// Cashier "Mark complete" API in flight for this job (orders list, product grid, sheets).
  String? _cashierCompletingJobId;

  bool get isLoading => _isLoading;
  bool get ordersApiFetchCompleted => _ordersApiFetchCompleted;
  bool get isInvoicePanelSaveBusy => _invoicePanelSaveBusy;
  bool get isInvoiceLoading => _isInvoiceLoading;
  String? get loadingOrderId => _loadingOrderId;
  bool isCashierCompletingJob(String jobId) =>
      jobId.isNotEmpty && _cashierCompletingJobId == jobId;
  String? get errorMessage => _errorMessage;
  String? get currentJobId => _currentJobId;
  PosOrder? get selectedOrder => _selectedOrder;
  OrderStats get orderStats => _orderStats;
  List<SearchedCustomer> get searchedCustomers => _searchedCustomers;
  bool get isSearchingCustomer => _isSearchingCustomer;
  int get shellSelectedIndex => _shellSelectedIndex;

  void setShellSelectedIndex(int index) {
    _shellSelectedIndex = index;
    notifyListeners();
  }

  void selectOrder(PosOrder? order) {
    _selectedOrder = order;
    notifyListeners();
  }

  /// Merge technicians from POST /cashier/job/:id/assign before [fetchOrders] returns.
  void applyJobTechniciansFromAssign({
    required String orderId,
    required String jobId,
    required List<JobTechnician> technicians,
  }) {
    if (orderId.trim().isEmpty || jobId.trim().isEmpty) return;
    final oi = _orders.indexWhere((o) => o.id == orderId.trim());
    if (oi < 0) return;
    final order = _orders[oi];
    final ji = order.jobs.indexWhere((j) => j.id == jobId.trim());
    if (ji < 0) return;
    final job = order.jobs[ji];
    final updatedJob = PosOrderJob(
      id: job.id,
      status: job.status,
      department: job.department,
      departmentId: job.departmentId,
      items: job.items,
      technicians: technicians,
      amountBeforeDiscount: job.amountBeforeDiscount,
      totalAmount: job.totalAmount,
      vatAmount: job.vatAmount,
      vatPercent: job.vatPercent,
      promoCodeId: job.promoCodeId,
      promoCodeName: job.promoCodeName,
      promoDiscountType: job.promoDiscountType,
      promoDiscountValue: job.promoDiscountValue,
      promoDiscountAmount: job.promoDiscountAmount,
      totalDiscountType: job.totalDiscountType,
      totalDiscountValue: job.totalDiscountValue,
    );
    final newJobs = List<PosOrderJob>.from(order.jobs);
    newJobs[ji] = updatedJob;
    _orders[oi] = order.copyWith(jobs: newJobs);
    if (_selectedOrder?.id == orderId.trim()) {
      _selectedOrder = _orders[oi];
    }
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
    _ordersRealtimeDebounce?.cancel();
    super.dispose();
  }

  String get cashierName => _cashierName ?? 'Cashier';
  String get workshopName => _workshopName ?? 'Loading...';
  String get branchName => _branchName ?? '...';

  // Search Debounce (Moved from View)
  Timer? _searchDebounce;

  /// Coalesce rapid socket events (e.g. multiple job updates) into one list refresh.
  Timer? _ordersRealtimeDebounce;

  DateTime? _lastCashierOrdersFetchedAt;

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
    _lastPlacedWalkInOrder = null;
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

  static const double _kCashierVatPercent = 15.0;

  /// Active walk-in draft order id after a successful create/append (for debugging / UI).
  String? get walkInDraftOrderId => _previousOrderId;

  Map<String, String> _departmentJobMapFromWalkInOrder(WalkInOrder? order) {
    final map = <String, String>{};
    if (order == null) return map;
    for (final d in order.departments) {
      final did = d.departmentId?.trim() ?? '';
      final jid = d.jobId?.trim() ?? '';
      if (did.isNotEmpty && jid.isNotEmpty) {
        map[did] = jid;
      }
    }
    return map;
  }

  Map<String, List<CartItem>> _groupCartItemsByDepartment(List<String> fallbackDepartmentIds) {
    final fallback =
        fallbackDepartmentIds.isNotEmpty ? fallbackDepartmentIds.first.trim() : '';
    final map = <String, List<CartItem>>{};
    for (final item in _cartItems) {
      final d = item.product.departmentId?.trim() ?? '';
      final key = d.isNotEmpty ? d : fallback;
      if (key.isEmpty) continue;
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }

  /// Body for POST /cashier/job/:jobId/pricing (replace-all lines for that job).
  Map<String, dynamic> _buildCashierJobPricingPayload({
    required List<CartItem> items,
    required String defaultDepartmentId,
    required bool applyJobDiscountAndPromo,
    bool isMainTab = false,
    PosOrderJob? sourceJob,
    PosOrder? sourceOrder,
  }) {
    final products = <Map<String, dynamic>>[];
    final services = <Map<String, dynamic>>[];

    for (final item in items) {
      final lineDept = item.product.departmentId?.trim().isNotEmpty == true
          ? item.product.departmentId!.trim()
          : defaultDepartmentId;
      if (item.product.isService) {
        final m = <String, dynamic>{
          'serviceId': item.product.id,
          'departmentId': lineDept,
          'qty': item.quantity,
        };
        if (item.discount > 0) {
          m['discountType'] = item.isDiscountPercent ? 'percent' : 'amount';
          m['discountValue'] = item.discount;
        }
        if (item.product.isPriceEditable) {
          m['unitPrice'] = item.effectiveUnitPrice;
        }
        services.add(m);
      } else {
        final m = <String, dynamic>{
          'productId': item.product.id,
          'departmentId': lineDept,
          'qty': item.quantity,
        };
        if (item.discount > 0) {
          m['discountType'] = item.isDiscountPercent ? 'percent' : 'amount';
          m['discountValue'] = item.discount;
        }
        products.add(m);
      }
    }

    // Only fall back to existing job items for NEW orders (submitWalkInOrder)
    // where the user hasn't touched the cart at all. For edits, an empty cart
    // means the user intentionally removed everything.
    if (products.isEmpty && services.isEmpty && sourceJob != null && sourceOrder == null) {
      for (final item in sourceJob.items) {
        final lineDept = item.departmentId.trim().isNotEmpty
            ? item.departmentId.trim()
            : defaultDepartmentId;
        if (item.itemType == 'service') {
          services.add({
            'serviceId': item.productId,
            'departmentId': lineDept,
            'qty': item.qty,
            'discountType': (item.discountType ?? '').isNotEmpty ? item.discountType : 'amount',
            'discountValue': item.discountValue ?? 0,
          });
        } else {
          final m = <String, dynamic>{
            'productId': item.productId,
            'departmentId': lineDept,
            'qty': item.qty,
          };
          if ((item.discountType ?? '').isNotEmpty) {
            m['discountType'] = item.discountType;
          }
          if ((item.discountValue ?? 0) > 0) {
            m['discountValue'] = item.discountValue;
          }
          products.add(m);
        }
      }
    }

    final hasLiveCartData = products.isNotEmpty || services.isNotEmpty;

    final activeGlobal = getActiveGlobalDiscount(isMainTab);
    final activeGlobalIsPct = getActiveIsGlobalDiscountPercent(isMainTab);
    final fallbackGlobalValue =
        sourceJob?.totalDiscountValue ?? sourceOrder?.totalDiscountValue ?? 0.0;
    final rawGlobalType =
        sourceJob?.totalDiscountType ?? sourceOrder?.totalDiscountType ?? 'amount';
    final fallbackGlobalType =
        rawGlobalType.toLowerCase().contains('percent') ? 'percent' : 'amount';

    double effectiveGlobalValue = 0.0;
    String effectiveGlobalType = 'amount';
    if (applyJobDiscountAndPromo) {
      if (hasLiveCartData) {
        // Cart / invoice panel is authoritative — do not resurrect cleared job-level discount.
        effectiveGlobalValue = activeGlobal;
        effectiveGlobalType = activeGlobalIsPct ? 'percent' : 'amount';
      } else {
        effectiveGlobalValue = activeGlobal > 0 ? activeGlobal : fallbackGlobalValue;
        effectiveGlobalType = activeGlobal > 0
            ? (activeGlobalIsPct ? 'percent' : 'amount')
            : fallbackGlobalType;
      }
    }

    String? promoCodeStr;
    String? promoId;
    var explicitClearPromo = false;
    if (applyJobDiscountAndPromo) {
      final promo = _resolvePromoState(isMainTab, departmentId: _editDepartmentId);
      final code = promo.code.trim();
      if (code.isNotEmpty) {
        promoCodeStr = code;
        final pid = promo.promoCodeId?.trim();
        if (pid != null && pid.isNotEmpty) promoId = pid;
      } else if (hasLiveCartData) {
        // Omitting promo keys leaves the server's stored promo unchanged; null clears it.
        explicitClearPromo = true;
      } else {
        final sid = sourceJob?.promoCodeId ?? sourceOrder?.promoCodeId;
        if (sid != null && sid.trim().isNotEmpty) {
          promoId = sid.trim();
        }
      }
    }

    return <String, dynamic>{
      'products': products,
      'services': services,
      'totalDiscountType': effectiveGlobalType,
      'totalDiscountValue': effectiveGlobalValue,
      'VAT': _kCashierVatPercent,
      if (promoCodeStr != null && promoCodeStr.isNotEmpty) 'promoCode': promoCodeStr,
      if (promoId != null && promoId.isNotEmpty) 'promoCodeId': promoId,
      if (explicitClearPromo) 'promoCode': null,
      if (explicitClearPromo) 'promoCodeId': null,
    };
  }

  void _applyWalkInOrderSuccess(
    WalkInCustomerResponse response, {
    required bool isCorporateFlow,
    required bool clearCustomerOnSuccess,
  }) {
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
    _lastPlacedWalkInOrder = response.order;
    _lastCreatedWalkInOrderId = response.order?.id ?? _lastCreatedWalkInOrderId;
    final plate = response.order?.vehicle?.plateNo.trim() ?? '';
    if (plate.isNotEmpty) {
      _lastCreatedWalkInVehicleNumber = plate;
    }
    if (isCorporateFlow) {
      final jid = maxJobId ?? response.order?.jobId;
      _currentJobId = (jid != null && jid.isNotEmpty) ? jid : null;
    } else {
      _currentJobId = maxJobId ?? response.order?.jobId ?? response.order?.id;
    }
    _isLoading = false;
    if (clearCustomerOnSuccess) {
      clearCustomerData();
    }
    notifyListeners();
  }

  /// POST /cashier/walk-in-order — new order + empty jobs (vehicle + departmentIds only).
  /// Corporate accounts use the existing submit-for-approval path instead.
  Future<bool> placeWalkInShellOrder(
    List<String> departmentIds,
    BuildContext context,
  ) async {
    if (departmentIds.isEmpty) {
      if (context.mounted) {
        ToastService.showError(context, 'Select at least one department');
      }
      return false;
    }

    final isCorp =
        _corporateAccountId != null && _corporateAccountId!.trim().isNotEmpty;
    if (isCorp) {
      return submitWalkInOrder(departmentIds, context, clearCustomerOnSuccess: false);
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await sessionService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }
      if (_vehicleNumber.trim().isEmpty) {
        _errorMessage = 'Vehicle plate is required';
        _isLoading = false;
        notifyListeners();
        if (context.mounted) ToastService.showError(context, _errorMessage!);
        return false;
      }
      final createdVehicle = _vehicleNumber.trim();

      final shellReq = WalkInCustomerRequest(
        vehicleNumber: _vehicleNumber,
        vinNumber: _vinNumber.isNotEmpty ? _vinNumber : null,
        make: _make.trim().isNotEmpty ? _make.trim() : null,
        model: _model.trim().isNotEmpty ? _model.trim() : null,
        odometerReading: _odometerReading > 0 ? _odometerReading : null,
        departmentIds: departmentIds,
      );
      final res = await posRepository.postWalkInOrder(
        shellReq.toShellCreateJson(),
        token,
      );
      if (res.success) {
        if ((res.order?.id ?? '').trim().isEmpty && createdVehicle.isNotEmpty) {
          _lastCreatedWalkInVehicleNumber = createdVehicle;
        }
        _applyWalkInOrderSuccess(
          res,
          isCorporateFlow: false,
          clearCustomerOnSuccess: true,
        );
        if (context.mounted) {
          ToastService.showSuccess(
            context,
            res.message.isNotEmpty ? res.message : 'Order created',
          );
        }
        return true;
      }
      _errorMessage = res.message;
      _isLoading = false;
      notifyListeners();
      if (context.mounted) ToastService.showError(context, res.message);
      return false;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e.toString());
      _isLoading = false;
      notifyListeners();
      if (context.mounted) ToastService.showError(context, _errorMessage!);
      return false;
    }
  }

  Future<bool> submitWalkInOrder(
    List<String> departmentIds,
    BuildContext context, {
    bool clearCustomerOnSuccess = true,
    bool forInvoicePanelSave = false,
  }) async {
    _isLoading = true;
    if (forInvoicePanelSave) _invoicePanelSaveBusy = true;
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
        if (item.product.isService) {
          services.add(
            RequestedService(
              serviceId: item.product.id,
              departmentId: item.product.departmentId ?? departmentIds.first,
              qty: item.quantity,
              discountType: item.discount > 0 ? (item.isDiscountPercent ? 'percent' : 'amount') : null,
              discountValue: item.discount > 0 ? item.discount : null,
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

      final amountBeforeDiscount = getSubtotalGross(false);
      final amountAfterDiscount = getPriceAfterJobDiscount(false);
      final amountAfterPromo = getTotalTaxableAmountValue(false);
      const vatPercent = 15.0;
      final totalAmount = getTotalAmountValue(false);

      if (isCorpSubmit) {
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
          corporateAccountId: _corporateAccountId!.trim(),
        );

        final corpRes = await posRepository.submitWalkInCorporateForApproval(request, token);
        if (corpRes.success) {
          _applyWalkInOrderSuccess(
            corpRes,
            isCorporateFlow: true,
            clearCustomerOnSuccess: clearCustomerOnSuccess,
          );
          if (context.mounted) {
            ToastService.showSuccess(context, corpRes.message);
          }
          return true;
        }
        _errorMessage = corpRes.message;
        _isLoading = false;
        notifyListeners();
        if (context.mounted) {
          ToastService.showError(context, corpRes.message);
        }
        return false;
      }

      // Standard cashier walk-in (Nest: shell create + per-job pricing).
      if (_previousOrderId == null) {
        if (products.isEmpty && services.isEmpty) {
          if (allDepartmentIds.isEmpty) {
            _errorMessage = 'Select at least one department';
            _isLoading = false;
            notifyListeners();
            if (context.mounted) ToastService.showError(context, _errorMessage!);
            return false;
          }
          final shellReq = WalkInCustomerRequest(
            vehicleNumber: _vehicleNumber,
            vinNumber: _vinNumber.isNotEmpty ? _vinNumber : null,
            make: _make,
            model: _model,
            odometerReading: _odometerReading,
            departmentIds: allDepartmentIds.toList(),
          );
          final shellRes =
              await posRepository.postWalkInOrder(shellReq.toShellCreateJson(), token);
          if (shellRes.success) {
            _applyWalkInOrderSuccess(
              shellRes,
              isCorporateFlow: false,
              clearCustomerOnSuccess: clearCustomerOnSuccess,
            );
            if (context.mounted) {
              ToastService.showSuccess(context, shellRes.message);
            }
            return true;
          }
          _errorMessage = shellRes.message;
          _isLoading = false;
          notifyListeners();
          if (context.mounted) {
            ToastService.showError(context, shellRes.message);
          }
          return false;
        }

        if (allDepartmentIds.isEmpty) {
          _errorMessage = 'Each line needs a department';
          _isLoading = false;
          notifyListeners();
          if (context.mounted) ToastService.showError(context, _errorMessage!);
          return false;
        }

        final shellReq = WalkInCustomerRequest(
          vehicleNumber: _vehicleNumber,
          vinNumber: _vinNumber.isNotEmpty ? _vinNumber : null,
          make: _make,
          model: _model,
          odometerReading: _odometerReading,
          departmentIds: allDepartmentIds.toList(),
        );
        final shellRes =
            await posRepository.postWalkInOrder(shellReq.toShellCreateJson(), token);
        if (!shellRes.success || shellRes.order == null) {
          _errorMessage = shellRes.message;
          _isLoading = false;
          notifyListeners();
          if (context.mounted) {
            ToastService.showError(context, shellRes.message);
          }
          return false;
        }

        _previousOrderId = shellRes.order!.id;
        final deptJob = _departmentJobMapFromWalkInOrder(shellRes.order);
        final grouped = _groupCartItemsByDepartment(allDepartmentIds.toList());
        final keys = grouped.keys.toList()..sort();
        if (keys.isEmpty) {
          _errorMessage = 'No line items to save';
          _isLoading = false;
          notifyListeners();
          if (context.mounted) ToastService.showError(context, _errorMessage!);
          return false;
        }

        for (var i = 0; i < keys.length; i++) {
          final deptId = keys[i];
          final jid = deptJob[deptId];
          if (jid == null || jid.isEmpty) {
            _errorMessage =
                'No job for department $deptId. Use “Add departments” or refresh orders.';
            _isLoading = false;
            notifyListeners();
            if (context.mounted) ToastService.showError(context, _errorMessage!);
            return false;
          }
          final payload = _buildCashierJobPricingPayload(
            items: grouped[deptId]!,
            defaultDepartmentId: deptId,
            applyJobDiscountAndPromo: i == 0,
            isMainTab: false,
          );
          final pr = await posRepository.updateJobPricing(jid, payload, token);
          if (pr['success'] == false) {
            _errorMessage =
                pr['message']?.toString() ?? 'Failed to save pricing for department $deptId';
            _isLoading = false;
            notifyListeners();
            if (context.mounted) ToastService.showError(context, _errorMessage!);
            return false;
          }
        }

        String? maxJobId;
        if (shellRes.order!.departments.isNotEmpty) {
          final sorted = [...shellRes.order!.departments]
            ..sort(
              (a, b) => (int.tryParse(a.jobId ?? '') ?? 0).compareTo(
                    int.tryParse(b.jobId ?? '') ?? 0,
                  ),
            );
          maxJobId = sorted.last.jobId;
        }
        _currentJobId = maxJobId ?? shellRes.order?.jobId ?? shellRes.order?.id;
        _isLoading = false;
        if (clearCustomerOnSuccess) {
          clearCustomerData();
        }
        notifyListeners();
        if (context.mounted) {
          ToastService.showSuccess(context, shellRes.message);
        }
        return true;
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
      );

      final response = await posRepository.createWalkInOrder(request, token);

      if (response.success) {
        _applyWalkInOrderSuccess(
          response,
          isCorporateFlow: false,
          clearCustomerOnSuccess: clearCustomerOnSuccess,
        );
        if (context.mounted) {
          ToastService.showSuccess(context, response.message);
        }
        return true;
      }
      _errorMessage = response.message;
      _isLoading = false;
      notifyListeners();
      if (context.mounted) {
        ToastService.showError(context, response.message);
      }
      return false;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e.toString());
      _isLoading = false;
      notifyListeners();
      if (context.mounted) {
        ToastService.showError(context, _errorMessage!);
      }
      return false;
    } finally {
      if (forInvoicePanelSave) {
        _invoicePanelSaveBusy = false;
        notifyListeners();
      }
    }
  }

  Future<bool> submitEditOrder(
    List<String> departmentIds,
    BuildContext context, {
    bool forInvoicePanelSave = false,
  }) async {
    final orderId = _editingOrder?.id ?? '';
    final jobId = _editingCompletingOrderId ?? '';

    if (orderId.isEmpty || jobId.isEmpty) {
      if (context.mounted) {
        ToastService.showError(context, 'Edit context missing. Please try again.');
      }
      return false;
    }

    _isLoading = true;
    if (forInvoicePanelSave) _invoicePanelSaveBusy = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await sessionService.getToken();
      if (token == null) throw Exception('Authentication token not found');

      for (var item in _cartItems) {
        if (item.product.isService && item.product.isPriceEditable && item.effectiveUnitPrice <= 0) {
          if (context.mounted) {
            ToastService.showError(context, 'Enter a valid unit price for ${item.product.name}');
          }
          return false;
        }
      }

      final deptId = (_editDepartmentId ?? '').trim();
      final fallbackDept =
          departmentIds.isNotEmpty ? departmentIds.first.trim() : deptId;
      final defaultDept = deptId.isNotEmpty ? deptId : fallbackDept;

      final itemsForJob = _cartItems.where((c) {
        if (deptId.isEmpty) return true;
        final pd = c.product.departmentId?.trim() ?? '';
        return pd.isEmpty || pd == deptId;
      }).toList();

      PosOrderJob? jobMeta;
      for (final j in _editingOrder?.jobs ?? const <PosOrderJob>[]) {
        if (j.id == jobId) {
          jobMeta = j;
          break;
        }
      }

      final body = _buildCashierJobPricingPayload(
        items: itemsForJob,
        defaultDepartmentId: defaultDept.isNotEmpty ? defaultDept : '0',
        applyJobDiscountAndPromo: true,
        isMainTab: false,
        sourceJob: jobMeta,
        sourceOrder: _editingOrder,
      );

      final response = await posRepository.updateJobPricing(jobId, body, token);
      final success = response['success'] != false;

      if (success) {
        // GET /cashier/orders is authoritative for draft rows; no merge of POST …/pricing body.
        await fetchOrders(silent: true, preferredOrderId: orderId);
      }

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
      if (context.mounted) {
        ToastService.showError(context, _errorMessage!);
      }
      return false;
    } finally {
      _isLoading = false;
      if (forInvoicePanelSave) _invoicePanelSaveBusy = false;
      notifyListeners();
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
  final Map<String, _DepartmentPromoState> _departmentPromoById = {};
  String? _promoContextDepartmentId;
  double _globalDiscount = 0.0;
  bool _isGlobalDiscountPercent = false;

  // Secondary cart state for main navigation tab
  final List<CartItem> _mainTabCartItems = [];
  String _mainTabActivePromoCode = '';
  String? _mainTabActivePromoCodeId;
  double _mainTabPromoDiscount = 0.0;
  bool _mainTabIsPromoPercent = false;
  final Map<String, _DepartmentPromoState> _mainTabDepartmentPromoById = {};
  String? _mainTabPromoContextDepartmentId;
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
  String getActivePromoCode(bool isMainTab, {String? departmentId}) {
    final promo = _resolvePromoState(isMainTab, departmentId: departmentId);
    return promo.code;
  }

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

  /// Gross amount VAT-exclusive (sum of unit price excl. VAT × qty).
  double getSubtotalGross(bool isMainTab) => _getActiveCart(isMainTab).fold(
    0,
    (sum, item) => sum + item.lineSubtotalExclVat,
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

  double getTotalPromoDiscountValue(bool isMainTab, {String? departmentId}) {
    final baseForPromo = getPriceAfterJobDiscount(isMainTab);
    final promo = _resolvePromoState(isMainTab, departmentId: departmentId);
    if (promo.code.isNotEmpty) {
      if (promo.isPercent) return baseForPromo * (promo.discount / 100);
      return promo.discount;
    }
    if (isMainTab) {
      if (_mainTabIsPromoPercent) return baseForPromo * (_mainTabPromoDiscount / 100);
      return _mainTabPromoDiscount;
    } else {
      if (_isPromoPercent) return baseForPromo * (_promoDiscount / 100);
      return _promoDiscount;
    }
  }

  double getPromoDiscountForBase(
    double baseForPromo, {
    bool isMainTab = false,
    String? departmentId,
  }) {
    final promo = _resolvePromoState(isMainTab, departmentId: departmentId);
    final raw = promo.isPercent ? baseForPromo * (promo.discount / 100) : promo.discount;
    return raw.clamp(0, baseForPromo).toDouble();
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
      _mainTabActivePromoCodeId = null;
      _mainTabPromoDiscount = 0.0;
      _mainTabIsPromoPercent = false;
      _mainTabDepartmentPromoById.clear();
      _mainTabPromoContextDepartmentId = null;
      _mainTabGlobalDiscount = 0.0;
      _mainTabIsGlobalDiscountPercent = false;
    } else {
      _activePromoCode = '';
      _activePromoCodeId = null;
      _promoDiscount = 0.0;
      _isPromoPercent = false;
      _departmentPromoById.clear();
      _promoContextDepartmentId = null;
      _globalDiscount = 0.0;
      _isGlobalDiscountPercent = false;
    }
    notifyListeners();
  }

  void removeDepartmentItemsFromCart(
    String departmentId, {
    bool isMainTab = false,
  }) {
    final depId = departmentId.trim();
    if (depId.isEmpty) return;
    final activeCart = _getActiveCart(isMainTab);
    activeCart.removeWhere((item) => (item.product.departmentId ?? '') == depId);
    if (isMainTab) {
      _mainTabDepartmentPromoById.remove(depId);
      if (_mainTabPromoContextDepartmentId == depId) {
        _mainTabPromoContextDepartmentId = null;
      }
    } else {
      _departmentPromoById.remove(depId);
      if (_promoContextDepartmentId == depId) {
        _promoContextDepartmentId = null;
      }
    }
    notifyListeners();
  }

  void setPromoContextDepartment(String? departmentId, {bool isMainTab = false}) {
    if (isMainTab) {
      _mainTabPromoContextDepartmentId = departmentId;
    } else {
      _promoContextDepartmentId = departmentId;
    }
  }

  void applyPromoCode(
    String code,
    double discount,
    bool isPercent, {
    bool isMainTab = false,
    String? promoCodeId,
    String? departmentId,
  }) {
    final targetDepartmentId = (departmentId ?? _getPromoContextDepartmentId(isMainTab))
        ?.trim();
    if (targetDepartmentId != null && targetDepartmentId.isNotEmpty) {
      final map = isMainTab ? _mainTabDepartmentPromoById : _departmentPromoById;
      map[targetDepartmentId] = _DepartmentPromoState(
        code: code,
        promoCodeId: promoCodeId,
        discount: discount,
        isPercent: isPercent,
      );
      notifyListeners();
      return;
    }
    if (isMainTab) {
      _mainTabActivePromoCode = code;
      _mainTabActivePromoCodeId = promoCodeId;
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

  void clearPromoCode({bool isMainTab = false, String? departmentId}) {
    final targetDepartmentId = (departmentId ?? _getPromoContextDepartmentId(isMainTab))
        ?.trim();
    if (targetDepartmentId != null && targetDepartmentId.isNotEmpty) {
      final map = isMainTab ? _mainTabDepartmentPromoById : _departmentPromoById;
      final removed = map.remove(targetDepartmentId);
      if (removed != null) {
        notifyListeners();
        return;
      }
    }
    if (isMainTab) {
      _mainTabActivePromoCode = '';
      _mainTabActivePromoCodeId = null;
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

  String? _getPromoContextDepartmentId(bool isMainTab) =>
      isMainTab ? _mainTabPromoContextDepartmentId : _promoContextDepartmentId;

  _DepartmentPromoState _resolvePromoState(
    bool isMainTab, {
    String? departmentId,
  }) {
    final targetDepartmentId = (departmentId ?? _getPromoContextDepartmentId(isMainTab))
        ?.trim();
    if (targetDepartmentId != null && targetDepartmentId.isNotEmpty) {
      final map = isMainTab ? _mainTabDepartmentPromoById : _departmentPromoById;
      final byDepartment = map[targetDepartmentId];
      if (byDepartment != null) return byDepartment;
    }
    if (isMainTab) {
      return _DepartmentPromoState(
        code: _mainTabActivePromoCode,
        promoCodeId: _mainTabActivePromoCodeId,
        discount: _mainTabPromoDiscount,
        isPercent: _mainTabIsPromoPercent,
      );
    }
    return _DepartmentPromoState(
      code: _activePromoCode,
      promoCodeId: _activePromoCodeId,
      discount: _promoDiscount,
      isPercent: _isPromoPercent,
    );
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
            return status == 'completed' || status == 'edited';
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
    String? preferredOrderId,
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
        _lastCashierOrdersFetchedAt = DateTime.now();

        final preferredId = (preferredOrderId?.trim().isNotEmpty == true)
            ? preferredOrderId!.trim()
            : ((_lastCreatedWalkInOrderId ?? '').trim().isNotEmpty
                ? _lastCreatedWalkInOrderId!.trim()
                : null);

        // Always prioritize a caller-requested order selection.
        if (preferredId != null) {
          try {
            _selectedOrder = _orders.firstWhere((o) => o.id == preferredId);
          } catch (_) {
            _selectedOrder = null;
          }
        }

        // Fallback: when create response didn't include order id, select by latest matching vehicle plate.
        if (_selectedOrder == null &&
            (_lastCreatedWalkInVehicleNumber ?? '').trim().isNotEmpty) {
          final targetPlate = _lastCreatedWalkInVehicleNumber!.trim().toLowerCase();
          final matches = _orders.where(
            (o) => o.plateNumber.trim().toLowerCase() == targetPlate,
          ).toList();
          if (matches.isNotEmpty) {
            matches.sort((a, b) {
              final bi = int.tryParse(b.id) ?? 0;
              final ai = int.tryParse(a.id) ?? 0;
              return bi.compareTo(ai);
            });
            _selectedOrder = matches.first;
          }
        } else if (_selectedOrder != null) {
          // Re-select order if it already exists
          try {
            _selectedOrder = _orders.firstWhere((o) => o.id == _selectedOrder!.id);
          } catch (_) {
            _selectedOrder = null;
          }
        }
        
        // If no order selected and list not empty, select first
        if (_selectedOrder == null && _orders.isNotEmpty) {
          _selectedOrder = _orders.first;
        }

        // We only need these hints right after creation.
        if (_selectedOrder != null) {
          _lastCreatedWalkInOrderId = _selectedOrder!.id;
          _lastCreatedWalkInVehicleNumber = null;
        }

        notifyListeners();
      } else {
        _errorMessage = 'Failed to fetch orders';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (!silent) {
        _isLoading = false;
      }
      _ordersApiFetchCompleted = true;
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
    List<Map<String, dynamic>>? payments,
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
        payments: payments,
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
    _cashierCompletingJobId = jobId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await sessionService.getToken();
      if (token == null) throw Exception('Token not found');

      // 1) Build pricing payload (per-job replace-all snapshot for POST /cashier/job/:id/pricing)
      final activeCart = isMainTab ? _mainTabCartItems : _cartItems;
      for (var item in activeCart) {
        if (item.product.isService && item.product.isPriceEditable && item.effectiveUnitPrice <= 0) {
          _errorMessage = 'Enter a valid unit price for ${item.product.name}';
          _isLoading = false;
          notifyListeners();
          return CashierCompleteJobResponse(success: false, message: _errorMessage!);
        }
      }

      PosOrderJob? sourceJob;
      if (sourceOrder != null) {
        for (final j in sourceOrder.jobs) {
          if (j.id == jobId) {
            sourceJob = j;
            break;
          }
        }
      }
      sourceJob ??= sourceOrder?.latestJob;

      var deptId = '';
      if (sourceJob != null) {
        final did = sourceJob.departmentId?.trim() ?? '';
        if (did.isNotEmpty) {
          deptId = did;
        } else if (sourceJob.items.isNotEmpty) {
          final fd = sourceJob.items.first.departmentId.trim();
          if (fd.isNotEmpty) deptId = fd;
        }
      }

      final itemsForJob = activeCart.where((c) {
        if (deptId.isEmpty) return true;
        final pd = c.product.departmentId?.trim() ?? '';
        return pd.isEmpty || pd == deptId;
      }).toList();

      final defaultDept = deptId.isNotEmpty ? deptId : '0';
      final pricingBody = _buildCashierJobPricingPayload(
        items: itemsForJob,
        defaultDepartmentId: defaultDept,
        applyJobDiscountAndPromo: true,
        isMainTab: isMainTab,
        sourceJob: sourceJob,
        sourceOrder: sourceOrder,
      );

      // 2) Persist/refresh job-level pricing — skip if the cart is empty
      //    but the job already has items (user is completing from Orders screen
      //    without going through the Product Grid).
      final jobAlreadyHasItems = sourceJob != null && sourceJob.items.isNotEmpty;
      if (itemsForJob.isNotEmpty || !jobAlreadyHasItems) {
        await posRepository.updateJobPricing(jobId, pricingBody, token);
      }

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

      // 4) Complete cashier job — only send pricing body when we actually have cart items
      final response = await posRepository.completeCashierJob(
        jobId,
        token,
        body: itemsForJob.isNotEmpty ? pricingBody : <String, dynamic>{},
      );
      if (response.success) {
        // Refresh orders — keep the same order selected
        await fetchOrders(silent: true, preferredOrderId: sourceOrder?.id ?? _selectedOrder?.id);
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
    } finally {
      if (_cashierCompletingJobId == jobId) {
        _cashierCompletingJobId = null;
      }
      notifyListeners();
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

  /// PATCH /cashier/job/:jobId/cancel — single job, before invoice.
  Future<bool> cancelCashierJob(
    BuildContext context,
    String jobId, [
    String reason = 'Cancelled by cashier',
  ]) async {
    if (jobId.trim().isEmpty) return false;
    final trimmed = reason.trim().isEmpty ? 'Cancelled by cashier' : reason.trim();
    try {
      final token = await sessionService.getToken();
      if (token == null) throw Exception('Token not found');
      final res = await posRepository.cancelCashierJob(jobId, trimmed, token);
      final ok = res['success'] != false;
      if (context.mounted) {
        if (ok) {
          ToastService.showSuccess(
            context,
            res['message']?.toString() ?? 'Job cancelled',
          );
        } else {
          ToastService.showError(
            context,
            res['message']?.toString() ?? 'Failed to cancel job',
          );
        }
      }
      if (ok) await fetchOrders(silent: true, preferredOrderId: _selectedOrder?.id);
      return ok;
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, _extractErrorMessage(e.toString()));
      }
      return false;
    }
  }

  /// POST /cashier/order/:orderId/jobs — add departments to an existing walk-in draft.
  Future<bool> addDepartmentsToWalkInOrder(
    BuildContext context,
    String orderId,
    List<String> departmentIds,
  ) async {
    if (orderId.trim().isEmpty || departmentIds.isEmpty) return false;
    try {
      final token = await sessionService.getToken();
      if (token == null) throw Exception('Token not found');
      final res = await posRepository.addJobsToCashierOrder(orderId, departmentIds, token);
      final ok = res['success'] != false;
      if (context.mounted) {
        if (ok) {
          ToastService.showSuccess(
            context,
            res['message']?.toString() ?? 'Departments added',
          );
        } else {
          ToastService.showError(
            context,
            res['message']?.toString() ?? 'Failed to add departments',
          );
        }
      }
      if (ok) await fetchOrders(silent: true);
      return ok;
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, _extractErrorMessage(e.toString()));
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

