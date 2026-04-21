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
import '../../../models/pos_payment_method.dart';
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

/// Billing + vehicle fields saved from the walk-in "Invoice details" dialog, keyed by order id.
/// Prevents one order's draft from pre-filling another when [PosViewModel] is shared.
class WalkInBillingSnapshot {
  final String name;
  final String mobile;
  final String vat;
  final String vehicleNumber;
  final String vin;
  final String make;
  final String model;
  final int odometer;
  final String year;
  final String color;

  const WalkInBillingSnapshot({
    required this.name,
    required this.mobile,
    required this.vat,
    required this.vehicleNumber,
    required this.vin,
    required this.make,
    required this.model,
    required this.odometer,
    required this.year,
    required this.color,
  });
}

/// Prefer saved "Invoice details" snapshot, then VM overlay, then order from API.
String _walkInPickField(String snap, String vm, String orderFallback) {
  final a = snap.trim();
  if (a.isNotEmpty) return a;
  final b = vm.trim();
  if (b.isNotEmpty) return b;
  return orderFallback.trim();
}

/// Backend expects integer year; tolerate spaces or extra text (e.g. "2010 ").
int? _parseYearForBillingApi(String raw) {
  final t = raw.trim();
  if (t.isEmpty) return null;
  final direct = int.tryParse(t);
  if (direct != null) return direct;
  final m = RegExp(r'\b(19|20)\d{2}\b').firstMatch(t);
  if (m != null) return int.tryParse(m.group(0)!);
  return null;
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

  /// Orders summary panel: corporate vs individual + payment method(s) before Generate Invoice.
  bool? _invoicePaymentIsCorporate;
  final Set<PaymentMethod> _invoicePaymentMethods = <PaymentMethod>{};
  final Map<PaymentMethod, double> _invoicePaymentAmounts = <PaymentMethod, double>{};

  /// Per–walk-in-order billing drafts (Add customer details / Final Review). Not global VM bleed.
  final Map<String, WalkInBillingSnapshot> _walkInBillingSnapshotsByOrderId =
      <String, WalkInBillingSnapshot>{};

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

  bool? get invoicePaymentIsCorporate => _invoicePaymentIsCorporate;
  Set<PaymentMethod> get invoicePaymentMethods =>
      Set<PaymentMethod>.unmodifiable(_invoicePaymentMethods);
  Map<PaymentMethod, double> get invoicePaymentAmounts =>
      Map<PaymentMethod, double>.unmodifiable(_invoicePaymentAmounts);
  bool get invoicePaymentSelectionReady =>
      _invoicePaymentIsCorporate != null && _invoicePaymentMethods.isNotEmpty;

  WalkInBillingSnapshot? walkInBillingSnapshotForOrder(String orderId) {
    final k = orderId.trim();
    if (k.isEmpty) return null;
    return _walkInBillingSnapshotsByOrderId[k];
  }

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
    if (_selectedOrder?.id != order?.id) {
      _invoicePaymentIsCorporate = null;
      _invoicePaymentMethods.clear();
      _invoicePaymentAmounts.clear();
    }
    _selectedOrder = order;
    _rehydrateWalkInVmFromSelectedOrderDraft();
    notifyListeners();
  }

  void _clearWalkInBillingOverlayFields() {
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
  }

  void _applyWalkInSnapshotToVm(WalkInBillingSnapshot s) {
    _customerName = s.name;
    _mobile = s.mobile;
    _vatNumber = s.vat;
    _vehicleNumber = s.vehicleNumber;
    _vinNumber = s.vin;
    _make = s.make;
    _model = s.model;
    _odometerReading = s.odometer;
    _vehicleYear = s.year;
    _vehicleColor = s.color;
  }

  /// Keeps [customerName] / vehicle fields aligned with the selected order's saved draft (or clears).
  void _rehydrateWalkInVmFromSelectedOrderDraft() {
    final oid = (_selectedOrder?.id ?? '').trim();
    if (oid.isEmpty) {
      _clearWalkInBillingOverlayFields();
      return;
    }
    final snap = _walkInBillingSnapshotsByOrderId[oid];
    if (snap != null) {
      _applyWalkInSnapshotToVm(snap);
    } else {
      _clearWalkInBillingOverlayFields();
    }
  }

  void setInvoicePaymentPreferences({
    required bool isCorporate,
    required Set<PaymentMethod> payments,
    Map<PaymentMethod, double> paymentAmounts = const {},
  }) {
    _invoicePaymentIsCorporate = isCorporate;
    _invoicePaymentMethods
      ..clear()
      ..addAll(payments);
    _invoicePaymentAmounts
      ..clear()
      ..addAll(paymentAmounts);
    notifyListeners();
  }

  void _clearInvoicePaymentPreferences() {
    _invoicePaymentIsCorporate = null;
    _invoicePaymentMethods.clear();
    _invoicePaymentAmounts.clear();
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
      amountAfterDiscount: job.amountAfterDiscount,
      amountAfterPromo: job.amountAfterPromo,
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
    _broadcastWaitingTicker?.cancel();
    super.dispose();
  }

  String get cashierName => _cashierName ?? 'Cashier';
  String get workshopName => _workshopName ?? 'Loading...';
  String get branchName => _branchName ?? '...';

  // Search Debounce (Moved from View)
  Timer? _searchDebounce;

  /// Coalesce rapid socket events (e.g. multiple job updates) into one list refresh.
  Timer? _ordersRealtimeDebounce;
  Timer? _broadcastWaitingTicker;
  DateTime? _broadcastWaitingEndsAt;
  String? _broadcastWaitingJobId;

  DateTime? _lastCashierOrdersFetchedAt;

  bool get hasActiveBroadcastWaiting {
    final endsAt = _broadcastWaitingEndsAt;
    if (endsAt == null) return false;
    return DateTime.now().isBefore(endsAt);
  }

  Duration get broadcastWaitingRemaining {
    final endsAt = _broadcastWaitingEndsAt;
    if (endsAt == null) return Duration.zero;
    final left = endsAt.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  String get broadcastWaitingTimerLabel {
    final left = broadcastWaitingRemaining;
    final m = left.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = left.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String? get broadcastWaitingJobId => _broadcastWaitingJobId;

  void startBroadcastWaiting({
    required String jobId,
    Duration duration = const Duration(minutes: 5),
  }) {
    if (jobId.trim().isEmpty) return;
    _broadcastWaitingTicker?.cancel();
    _broadcastWaitingJobId = jobId.trim();
    _broadcastWaitingEndsAt = DateTime.now().add(duration);
    notifyListeners();
    _broadcastWaitingTicker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!hasActiveBroadcastWaiting) {
        t.cancel();
        _broadcastWaitingTicker = null;
        _broadcastWaitingEndsAt = null;
        _broadcastWaitingJobId = null;
      }
      notifyListeners();
    });
  }

  void clearBroadcastWaiting() {
    _broadcastWaitingTicker?.cancel();
    _broadcastWaitingTicker = null;
    _broadcastWaitingEndsAt = null;
    _broadcastWaitingJobId = null;
    notifyListeners();
  }

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

  /// Billing + vehicle snapshot before invoice (walk-in billing PATCH). Scoped to [forOrderId].
  void updateWalkInBillingContact({
    required String forOrderId,
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
    final oid = forOrderId.trim();
    if (oid.isEmpty) return;
    final snap = WalkInBillingSnapshot(
      name: name.trim(),
      mobile: mobile.trim(),
      vat: vat.trim(),
      vehicleNumber: vehicleNumber.trim(),
      vin: vin.trim(),
      make: make.trim(),
      model: model.trim(),
      odometer: odometer,
      year: year.trim(),
      color: color.trim(),
    );
    _walkInBillingSnapshotsByOrderId[oid] = snap;
    if (_selectedOrder?.id == oid) {
      _applyWalkInSnapshotToVm(snap);
    }
    notifyListeners();
  }

  /// PATCH `/cashier/order/:orderId/billing` after **Add customer details** / Invoice details (Orders).
  /// Walk-in without corporate only; skipped if an invoice already exists on [order].
  /// Call after [updateWalkInBillingContact] so [_buildWalkInBillingPatchBody] sees the new snapshot.
  /// Returns `null` on success, otherwise a user-facing error string.
  Future<String?> submitWalkInOrderBillingPatch(PosOrder order) async {
    if (!_isStandardWalkInOrderForBilling(order)) return null;
    if ((order.invoiceNo ?? '').trim().isNotEmpty) {
      return 'Billing cannot be edited after an invoice exists.';
    }
    try {
      final token = await sessionService.getToken();
      if (token == null) {
        return 'Session expired. Sign in again.';
      }
      final billingBody = _buildWalkInBillingPatchBody(order);
      final cn = (billingBody['customerName'] as String? ?? '').trim();
      final mb = (billingBody['mobile'] as String? ?? '').trim();
      if (cn.isEmpty || mb.isEmpty) {
        return 'Customer name and mobile are required.';
      }
      final patchRes = await posRepository.patchWalkInOrderBilling(
        order.id.trim(),
        billingBody,
        token,
      );
      if (patchRes['success'] != true) {
        return patchRes['message']?.toString() ??
            'Failed to update billing details';
      }
      await fetchOrders(silent: true, preferredOrderId: order.id);
      return null;
    } on StateError catch (e) {
      return e.message;
    } catch (e) {
      return _extractErrorMessage(e.toString());
    }
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
    String vehicleYear = '',
    String vehicleColor = '',
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
    _vehicleYear = vehicleYear;
    _vehicleColor = vehicleColor;
    notifyListeners();
  }

  void clearCustomerData() {
    _walkInBillingSnapshotsByOrderId.clear();
    _clearWalkInBillingOverlayFields();
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

  static String normalizeCashierJobStatus(String? raw) {
    var s = (raw ?? '').toLowerCase().trim();
    if (s == 'complete') return 'completed';
    if (s == 'job_edited') return 'edited';
    return s;
  }

  PosProduct? _productById(String id) {
    final want = id.trim();
    if (want.isEmpty) return null;
    for (final p in _allProducts) {
      if (p.id == want) return p;
    }
    return null;
  }

  static int _moneyKey(double v) => (v * 100).round();

  List<CartItem> _cartItemsSnapshotFromJob(List<PosOrderJobItem> jobItems) {
    final out = <CartItem>[];
    for (final ji in jobItems) {
      final p = _productById(ji.productId);
      if (p == null) continue;
      final rawDt = (ji.discountType ?? '').trim();
      final pct = rawDt.toLowerCase().contains('percent');
      final dv = ji.discountValue ?? 0.0;
      final ci = CartItem(
        product: p,
        quantity: ji.qty,
        discount: dv,
        isDiscountPercent: pct,
      );
      if (p.isService && p.isPriceEditable && ji.unitPrice > 0) {
        ci.serviceUnitPrice = ji.unitPrice;
      }
      out.add(ci);
    }
    return out;
  }

  String _pricingLineSigFromCartItem(CartItem item, String defaultDepartmentId) {
    final lineDept = item.product.departmentId?.trim().isNotEmpty == true
        ? item.product.departmentId!.trim()
        : defaultDepartmentId;
    if (item.product.isService) {
      final buf = StringBuffer(
        'S|$lineDept|${item.product.id}|${item.quantity}',
      );
      if (item.discount > 0) {
        buf.write('|${item.isDiscountPercent ? 'p' : 'a'}:${_moneyKey(item.discount)}');
      }
      if (item.product.isPriceEditable) {
        buf.write('|u:${_moneyKey(item.effectiveUnitPrice)}');
      }
      return buf.toString();
    }
    final buf = StringBuffer(
      'P|$lineDept|${item.product.id}|${item.quantity}',
    );
    if (item.discount > 0) {
      buf.write('|${item.isDiscountPercent ? 'p' : 'a'}:${_moneyKey(item.discount)}');
    }
    return buf.toString();
  }

  bool _multisetLineSigsEqual(
    List<CartItem> a,
    List<CartItem> b,
    String defaultDepartmentId,
  ) {
    if (a.length != b.length) return false;
    final sa = a.map((c) => _pricingLineSigFromCartItem(c, defaultDepartmentId)).toList()
      ..sort();
    final sb = b.map((c) => _pricingLineSigFromCartItem(c, defaultDepartmentId)).toList()
      ..sort();
    for (var i = 0; i < sa.length; i++) {
      if (sa[i] != sb[i]) return false;
    }
    return true;
  }

  bool _jobOrderPricingMatchesPersisted(
    Map<String, dynamic> body,
    PosOrderJob job,
    PosOrder order,
  ) {
    final gtv = (body['totalDiscountValue'] as num?)?.toDouble() ?? 0.0;
    final gtt = (body['totalDiscountType'] as String?)?.toLowerCase() ?? 'amount';
    final rawGt =
        job.totalDiscountType ?? order.totalDiscountType ?? 'amount';
    final expT =
        rawGt.toLowerCase().contains('percent') ? 'percent' : 'amount';
    if (gtt != expT) return false;
    final expV = job.totalDiscountValue != 0 ||
            (job.totalDiscountType != null && job.totalDiscountType!.trim().isNotEmpty)
        ? job.totalDiscountValue
        : (order.totalDiscountValue ?? 0);
    if (_moneyKey(gtv) != _moneyKey(expV)) return false;

    final jobPid = (job.promoCodeId ?? order.promoCodeId ?? '').trim();
    final explicitClear =
        body.containsKey('promoCode') && body['promoCode'] == null;
    if (explicitClear) {
      return jobPid.isEmpty;
    }
    final bodyPid = body['promoCodeId']?.toString().trim() ?? '';
    if (bodyPid.isEmpty && jobPid.isEmpty) return true;
    return bodyPid == jobPid;
  }

  bool _completedJobEditHasMeaningfulPricingChange({
    required PosOrderJob job,
    required PosOrder order,
    required List<CartItem> itemsForJob,
    required String defaultDept,
    required Map<String, dynamic> body,
  }) {
    final snap = _cartItemsSnapshotFromJob(job.items);
    if (!_multisetLineSigsEqual(itemsForJob, snap, defaultDept)) {
      return true;
    }
    return !_jobOrderPricingMatchesPersisted(body, job, order);
  }

  /// PATCH `/cashier/job/:id/mark-edited` — flips **completed → edited** on success.
  ///
  /// Returns **true** only when the server accepts the patch. Callers that must POST pricing on a
  /// completed job **must** get `true` before [updateJobPricing], or the backend will reject.
  /// Do **not** call on open — only after snapshot diff (or technician diff) says there is a change.
  Future<bool> tryMarkCashierJobEditedAfterMeaningfulChange(
    BuildContext? context, {
    required String jobId,
    required String orderId,
    bool refreshOrdersOnSuccess = true,
  }) async {
    if (jobId.trim().isEmpty) return false;
    try {
      final token = await sessionService.getToken();
      if (token == null) return false;
      final res = await posRepository.markCashierJobEdited(jobId, token);
      final ok = res['success'] != false;
      if (ok) {
        if (refreshOrdersOnSuccess) {
          await fetchOrders(silent: true, preferredOrderId: orderId);
        }
        await _refreshEditingOrderSnapshot(orderId);
        return true;
      }
      // Client still had `completed` while server is already `edited` → redundant PATCH fails.
      if (await _recoverEditingOrderIfJobAlreadyEdited(jobId, orderId)) {
        return true;
      }
      if (context != null && context.mounted) {
        ToastService.showError(
          context,
          res['message']?.toString() ?? 'Could not mark job as edited',
        );
      }
      return false;
    } catch (e) {
      if (await _recoverEditingOrderIfJobAlreadyEdited(jobId, orderId)) {
        return true;
      }
      final msg = _extractErrorMessage(e.toString());
      if (context != null && context.mounted) {
        ToastService.showError(context, msg);
      }
      return false;
    }
  }

  /// Keeps [_editingOrder] job status in sync with the server after mark-edited / list refresh,
  /// so a second Save on the same screen does not call mark-edited again (would fail).
  Future<void> _refreshEditingOrderSnapshot(String orderId) async {
    if (_editingOrder?.id != orderId) return;
    final detail = await loadCashierOrderDetail(orderId);
    if (detail != null) {
      _editingOrder = detail;
    } else {
      _syncEditingOrderFromOrdersList(orderId);
    }
    notifyListeners();
  }

  void _syncEditingOrderFromOrdersList(String orderId) {
    if (_editingOrder?.id != orderId) return;
    try {
      _editingOrder = _orders.firstWhere((o) => o.id == orderId);
    } catch (_) {}
  }

  Future<bool> _recoverEditingOrderIfJobAlreadyEdited(String jobId, String orderId) async {
    if (_editingOrder?.id != orderId) return false;
    final detail = await loadCashierOrderDetail(orderId);
    if (detail == null) return false;
    PosOrderJob? job;
    for (final j in detail.jobs) {
      if (j.id == jobId) {
        job = j;
        break;
      }
    }
    if (normalizeCashierJobStatus(job?.status) != 'edited') return false;
    _editingOrder = detail;
    notifyListeners();
    return true;
  }

  static bool _responseLooksLikeCompletedJobPricingBlock(Map<String, dynamic> response) {
    if (response['success'] != false) return false;
    final m = (response['message']?.toString() ?? '').toLowerCase();
    return m.contains('completed') &&
        (m.contains('pricing') || m.contains('update'));
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

  String? _walkInTrimOrNull(String value) {
    final t = value.trim();
    return t.isEmpty ? null : t;
  }

  int? _walkInOdometerReadingOrNull() =>
      _odometerReading > 0 ? _odometerReading : null;

  WalkInCustomerRequest _walkInShellCreateRequest(List<String> departmentIds) {
    return WalkInCustomerRequest(
      vehicleNumber: _vehicleNumber,
      vinNumber: _walkInTrimOrNull(_vinNumber),
      make: _walkInTrimOrNull(_make),
      model: _walkInTrimOrNull(_model),
      odometerReading: _walkInOdometerReadingOrNull(),
      departmentIds: departmentIds,
    );
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

      final shellReq = _walkInShellCreateRequest(departmentIds);
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
          vinNumber: _walkInTrimOrNull(_vinNumber),
          make: _walkInTrimOrNull(_make),
          model: _walkInTrimOrNull(_model),
          odometerReading: _walkInOdometerReadingOrNull(),
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
          final shellReq =
              _walkInShellCreateRequest(allDepartmentIds.toList());
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

        final shellReq = _walkInShellCreateRequest(allDepartmentIds.toList());
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
        vinNumber: _walkInTrimOrNull(_vinNumber),
        make: _walkInTrimOrNull(_make),
        model: _walkInTrimOrNull(_model),
        odometerReading: _walkInOdometerReadingOrNull(),
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

      final st = normalizeCashierJobStatus(jobMeta?.status);
      final isCompleted = st == 'completed';
      final meaningfulPricingChange = jobMeta != null &&
          _completedJobEditHasMeaningfulPricingChange(
            job: jobMeta,
            order: _editingOrder!,
            itemsForJob: itemsForJob,
            defaultDept: defaultDept.isNotEmpty ? defaultDept : '0',
            body: body,
          );

      // Backend rejects POST …/pricing while the job is still `completed` — never POST in that case
      // unless we successfully PATCH mark-edited first (or there is nothing to persist).
      if (isCompleted && !meaningfulPricingChange) {
        if (context.mounted) {
          ToastService.showInfo(context, 'No changes to save');
        }
        return true;
      }

      if (isCompleted && meaningfulPricingChange) {
        final marked = await tryMarkCashierJobEditedAfterMeaningfulChange(
          context,
          jobId: jobId,
          orderId: orderId,
          refreshOrdersOnSuccess: false,
        );
        if (!marked) {
          _errorMessage = 'Could not unlock this job for editing';
          if (context.mounted) {
            ToastService.showError(
              context,
              'Could not unlock this job for editing. Please try again.',
            );
          }
          return false;
        }
      }

      var response = await posRepository.updateJobPricing(jobId, body, token);
      var success = response['success'] != false;

      if (!success &&
          isCompleted &&
          _responseLooksLikeCompletedJobPricingBlock(response)) {
        final marked = await tryMarkCashierJobEditedAfterMeaningfulChange(
          context,
          jobId: jobId,
          orderId: orderId,
          refreshOrdersOnSuccess: false,
        );
        if (marked) {
          response = await posRepository.updateJobPricing(jobId, body, token);
          success = response['success'] != false;
        }
      }

      if (success) {
        // GET /cashier/orders is authoritative for draft rows; no merge of POST …/pricing body.
        await fetchOrders(silent: true, preferredOrderId: orderId);
      }

      if (context.mounted) {
        if (success) {
          ToastService.showSuccess(
            context,
            response['message']?.toString() ?? 'Order updated successfully',
          );
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
  String _ordersListTab = 'All';

  String get orderStatusFilter => _orderStatusFilter;
  String get ordersListTab => _ordersListTab;

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

        if (_editingOrder != null) {
          try {
            _editingOrder = _orders.firstWhere((o) => o.id == _editingOrder!.id);
          } catch (_) {}
        }

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

  void setOrdersListTab(String tab) {
    if (tab != 'All' && tab != 'Pending' && tab != 'Completed') return;
    _ordersListTab = tab;
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

  bool isStandardWalkInOrderForBilling(PosOrder o) =>
      _isStandardWalkInOrderForBilling(o);

  /// Plate, name, and mobile required for walk-in invoice (VM fields or order payload).
  bool walkInBillingReadyForInvoice(PosOrder order) {
    if (!_isStandardWalkInOrderForBilling(order)) return true;
    final name = _customerName.trim().isNotEmpty
        ? _customerName.trim()
        : (order.customer?.name ?? '').trim();
    final mobile = _mobile.trim().isNotEmpty
        ? _mobile.trim()
        : (order.customer?.mobile ?? '').trim();
    final plate = _vehicleNumber.trim().isNotEmpty
        ? _vehicleNumber.trim()
        : order.plateNumber.trim();
    return name.isNotEmpty && mobile.isNotEmpty && plate.isNotEmpty;
  }

  Map<String, dynamic> _buildWalkInBillingPatchBody(PosOrder order) {
    final snap = _walkInBillingSnapshotsByOrderId[order.id.trim()];

    final nameOrder = (order.customer?.name ?? '').trim();
    final mobOrder = (order.customer?.mobile ?? '').trim();
    final vatOrder = (order.customer?.vatNumber ?? '').trim();

    final name = snap != null
        ? _walkInPickField(snap.name, _customerName, nameOrder)
        : (nameOrder.isNotEmpty ? nameOrder : _customerName.trim());
    final mobile = snap != null
        ? _walkInPickField(snap.mobile, _mobile, mobOrder)
        : (mobOrder.isNotEmpty ? mobOrder : _mobile.trim());
    final vat = snap != null
        ? _walkInPickField(snap.vat, _vatNumber, vatOrder)
        : (vatOrder.isNotEmpty ? vatOrder : _vatNumber.trim());

    final body = <String, dynamic>{
      'customerName': name,
      'mobile': mobile,
    };
    if (vat.isNotEmpty) body['vatNumber'] = vat;

    final plateOrder = (order.vehicle?.plateNo ?? '').trim();
    final plateEff = snap != null
        ? _walkInPickField(snap.vehicleNumber, _vehicleNumber, plateOrder)
        : _vehicleNumber.trim().isNotEmpty
            ? _vehicleNumber.trim()
            : plateOrder;

    int odoEff = order.odometerReading;
    if (snap != null && snap.odometer != 0) {
      odoEff = snap.odometer;
    } else if (_odometerReading != 0) {
      odoEff = _odometerReading;
    }
    if (odoEff != 0) {
      body['odometerReading'] = odoEff;
    }

    final makeEff = snap != null
        ? _walkInPickField(snap.make, _make, (order.vehicle?.make ?? '').trim())
        : _make.trim();
    final modelEff = snap != null
        ? _walkInPickField(snap.model, _model, (order.vehicle?.model ?? '').trim())
        : _model.trim();
    final vinEff = snap != null
        ? _walkInPickField(snap.vin, _vinNumber, (order.vehicle?.vin ?? '').trim())
        : _vinNumber.trim().isNotEmpty
            ? _vinNumber.trim()
            : (order.vehicle?.vin ?? '').trim();
    final yearEff = snap != null
        ? _walkInPickField(snap.year, _vehicleYear, (order.vehicle?.year ?? '').trim())
        : _vehicleYear.trim().isNotEmpty
            ? _vehicleYear.trim()
            : (order.vehicle?.year ?? '').trim();
    final colorEff = snap != null
        ? _walkInPickField(snap.color, _vehicleColor, (order.vehicle?.color ?? '').trim())
        : _vehicleColor.trim();

    final wantsVehicleFields = plateEff.isNotEmpty ||
        makeEff.isNotEmpty ||
        modelEff.isNotEmpty ||
        vinEff.isNotEmpty ||
        yearEff.isNotEmpty ||
        colorEff.isNotEmpty;

    if (wantsVehicleFields) {
      final plate = plateEff.isNotEmpty ? plateEff : plateOrder;
      if (plate.isEmpty) {
        throw StateError(
          'vehicleNumber is required when sending vehicle fields. Add the plate under Add Customer.',
        );
      }
      body['vehicleNumber'] = plate;
      if (makeEff.isNotEmpty) {
        body['make'] = makeEff;
      } else if ((order.vehicle?.make ?? '').trim().isNotEmpty) {
        body['make'] = order.vehicle!.make.trim();
      }
      if (modelEff.isNotEmpty) {
        body['model'] = modelEff;
      } else if ((order.vehicle?.model ?? '').trim().isNotEmpty) {
        body['model'] = order.vehicle!.model.trim();
      }
      if (yearEff.isNotEmpty) {
        final yi = _parseYearForBillingApi(yearEff);
        if (yi != null) {
          body['year'] = yi;
        } else {
          debugPrint(
            'WalkIn billing: year "$yearEff" could not be parsed as int; omitting year field',
          );
        }
      } else {
        final yStr = order.vehicle?.year?.trim();
        if (yStr != null && yStr.isNotEmpty) {
          final yi = _parseYearForBillingApi(yStr);
          if (yi != null) body['year'] = yi;
        }
      }
      if (colorEff.isNotEmpty) {
        body['color'] = colorEff;
      } else {
        final col = order.vehicle?.color?.trim();
        if (col != null && col.isNotEmpty) body['color'] = col;
      }
      if (vinEff.isNotEmpty) {
        body['vin'] = vinEff;
      } else {
        final ov = order.vehicle?.vin?.trim();
        if (ov != null && ov.isNotEmpty) body['vin'] = ov;
      }
    }

    return body;
  }

  /// Production [createInvoice] may still require **completed** jobs only. After mark-edited,
  /// jobs stay **edited** until `complete-cashier` with `{}` (recalc, no line overwrite).
  /// Mirrors backend behavior when present; safe no-op when there are no edited jobs.
  Future<String?> _finalizeEditedJobsBeforeInvoice(PosOrder order, String token) async {
    for (final job in order.jobs) {
      if (job.isCancelledJob) continue;
      final s = job.status.trim().toLowerCase();
      if (s != 'edited' && s != 'job_edited') continue;

      debugPrint(
        'InvoiceFlow: finalizing edited job jobId=${job.id} before createInvoice',
      );
      final readyResponse = await posRepository.checkJobCompleteReady(job.id, token);
      if (!readyResponse.success || !readyResponse.isReady) {
        return readyResponse.message.isNotEmpty
            ? readyResponse.message
            : 'Job is not ready to invoice. Add billable lines and technicians first.';
      }
      final response = await posRepository.completeCashierJob(
        job.id,
        token,
        body: <String, dynamic>{},
      );
      if (!response.success) {
        return response.message.isNotEmpty
            ? response.message
            : 'Could not finalize edited job before invoice.';
      }
    }
    return null;
  }

  Map<String, dynamic> _buildInvoicePaymentBody({
    required double totalAmount,
    String? paymentMethod,
    List<Map<String, dynamic>>? payments,
    bool? isCorporate,
  }) {
    final cleanMethod = paymentMethod?.trim();
    final normalizedPayments = <Map<String, dynamic>>[];

    if (payments != null && payments.isNotEmpty) {
      for (final p in payments) {
        final method = p['method']?.toString().trim() ?? '';
        if (method.isEmpty) continue;
        final amount =
            double.tryParse(p['amount']?.toString() ?? '') ?? 0.0;
        if (amount <= 0) continue;
        normalizedPayments.add(<String, dynamic>{
          'method': method,
          'amount': amount,
        });
      }
    }

    if (normalizedPayments.isEmpty && cleanMethod != null && cleanMethod.isNotEmpty) {
      normalizedPayments.add(<String, dynamic>{
        'method': cleanMethod,
        'amount': totalAmount > 0 ? totalAmount : 0.0,
      });
    }

    return <String, dynamic>{
      if (isCorporate != null) 'isCorporate': isCorporate,
      if (cleanMethod != null && cleanMethod.isNotEmpty) 'paymentMethod': cleanMethod,
      'payments': normalizedPayments,
    };
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

      final freshOrder = await loadCashierOrderDetail(orderId);
      final orderForFinalize = freshOrder ?? orderCtx;
      if (orderForFinalize != null) {
        final finalizeError = await _finalizeEditedJobsBeforeInvoice(orderForFinalize, token);
        if (finalizeError != null) {
          _errorMessage = finalizeError;
          _isInvoiceLoading = false;
          _loadingOrderId = null;
          notifyListeners();
          return CreateInvoiceResponse(success: false, message: finalizeError);
        }
      }

      final request = CreateInvoiceRequest(
        orderId: orderId,
        discountAmount: 0.0,
        invoiceDate: DateTime.now().toIso8601String(),
      );

      debugPrint(
        'InvoiceFlow: creating invoice for orderId=$orderId, invoiceDate=${request.invoiceDate}, paymentMethod=${request.paymentMethod ?? 'N/A'}',
      );
      final createResponse = await posRepository.createInvoice(request, token);
      if (createResponse.success) {
        debugPrint(
          'InvoiceFlow: create success, invoiceId=${createResponse.invoice?.id ?? 'N/A'}, invoiceNo=${createResponse.invoice?.invoiceNo ?? 'N/A'}',
        );
        // Persist payment(s) after create, then fetch invoice again.
        final payableTotal =
            (createResponse.invoice?.totalAmount ?? orderCtx?.draftPosOrderTotalDisplay ?? 0)
                .toDouble();
        final paymentBody = _buildInvoicePaymentBody(
          totalAmount: payableTotal,
          paymentMethod: paymentMethod,
          payments: payments,
          isCorporate: isCorporate,
        );
        final paymentRows =
            (paymentBody['payments'] as List?)?.whereType<Map<String, dynamic>>().toList() ??
                const <Map<String, dynamic>>[];
        if (paymentRows.isEmpty) {
          final msg = 'Payment method is required before generating invoice.';
          _errorMessage = msg;
          _isInvoiceLoading = false;
          _loadingOrderId = null;
          notifyListeners();
          return CreateInvoiceResponse(success: false, message: msg);
        }

        final paymentRes = await posRepository.saveInvoicePayment(
          orderId,
          paymentBody,
          token,
        );
        if (paymentRes['success'] != true) {
          final msg = paymentRes['message']?.toString().trim().isNotEmpty == true
              ? paymentRes['message'].toString()
              : 'Invoice created, but failed to save payment.';
          _errorMessage = msg;
          _isInvoiceLoading = false;
          _loadingOrderId = null;
          notifyListeners();
          return CreateInvoiceResponse(success: false, message: msg);
        }

        final detailedResponse = await posRepository.getInvoiceByOrder(orderId, token);

        Invoice? paymentInvoice;
        final prInv = paymentRes['invoice'];
        if (prInv is Map<String, dynamic>) {
          try {
            paymentInvoice = Invoice.fromJson(Map<String, dynamic>.from(prInv));
          } catch (e, st) {
            debugPrint('InvoiceFlow: paymentRes invoice parse failed: $e\n$st');
          }
        }

        // Prefer fresh by-order payload; fall back to create response or payment response.
        Invoice? mergedInvoice = detailedResponse.invoice ??
            createResponse.invoice ??
            paymentInvoice;

        if (mergedInvoice == null) {
          debugPrint(
            'InvoiceFlow: no invoice object after success — '
            'byOrder=${detailedResponse.invoice != null} '
            'create=${createResponse.invoice != null} '
            'payment=${paymentInvoice != null} '
            'detailedSuccess=${detailedResponse.success}',
          );
        }

        final msg = detailedResponse.message.trim().isNotEmpty
            ? detailedResponse.message
            : (createResponse.message.trim().isNotEmpty
                ? createResponse.message
                : (paymentRes['message']?.toString() ?? 'Invoice saved'));

        final finalResponse = CreateInvoiceResponse(
          success: true,
          message: msg,
          invoice: mergedInvoice,
          statusCode: detailedResponse.statusCode ?? createResponse.statusCode,
        );

        debugPrint('InvoiceFlow: fetched invoice after payment for orderId=$orderId');

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
          'InvoiceFlow: completed. mergedInvoice=${mergedInvoice != null} total=${mergedInvoice?.totalAmount ?? 0}',
        );
        _clearInvoicePaymentPreferences();
        _walkInBillingSnapshotsByOrderId.remove(orderId);
        _rehydrateWalkInVmFromSelectedOrderDraft();
        notifyListeners();
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
      startBroadcastWaiting(jobId: jobId);
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
      clearBroadcastWaiting();
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

