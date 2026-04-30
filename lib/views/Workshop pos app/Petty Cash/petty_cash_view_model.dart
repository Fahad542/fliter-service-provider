import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../services/locker_translation_mixin.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../services/session_service.dart';
import '../../../../data/repositories/pos_repository.dart';
import '../../../../models/petty_cash_model.dart';
import '../../../../models/expense_category_model.dart';
import '../../../../models/cashier_expense_models.dart';
import '../../../../services/realtime_service.dart';

class PettyCashViewModel extends ChangeNotifier {
  Locale? _translatedLocale;
  String _translationSignature = '';
  final Map<String, String> _translationCache = {};

  String localizedText(String value) => _translationCache[value] ?? value;

  Future<void> translateApiDataForLocale(Locale locale) async {
    final signature = [
      ..._expenseCategories.map((c) => '${c.id}|${c.name}'),
      ..._branchEmployees.map((e) => '${e.id}|${e.name}|${e.employeeType}'),
      ..._expenseHistory.map((e) => '${e.id}|${e.kind}|${e.category}|${e.employeeName}|${e.description}|${e.rejectionReason}|${e.status}'),
      ..._fundRequests.map((r) => '${r.id}|${r.reason}|${r.status}'),
    ].join(';;');
    if (_translatedLocale == locale && _translationSignature == signature) return;
    _translatedLocale = locale;
    _translationSignature = signature;
    _translationCache.clear();
    if (locale.languageCode != 'ar') {
      notifyListeners();
      return;
    }

    Future<void> add(String? value) async {
      final v = (value ?? '').trim();
      if (v.isEmpty || _translationCache.containsKey(v)) return;
      _translationCache[v] = await AppTranslationService.localizedText(v);
    }

    for (final c in _expenseCategories) {
      await add(c.name);
    }
    for (final e in _branchEmployees) {
      await add(e.name);
      await add(e.employeeType);
    }
    for (final h in _expenseHistory) {
      await add(h.category);
      await add(h.employeeName);
      await add(h.description);
      await add(h.rejectionReason);
      await add(h.kind.replaceAll('_', ' '));
      await add(h.status);
    }
    for (final r in _fundRequests) {
      await add(r.reason);
    }
    notifyListeners();
  }

  String validationMessage(AppLocalizations l10n, String key) {
    switch (key) {
      case 'valid_amount':
        return l10n.posPettyCashValidAmountError;
      case 'select_category':
        return l10n.posPettyCashSelectCategoryError;
      case 'select_employee':
        return l10n.posPettyCashSelectEmployeeError;
      case 'submit_expense_failed':
        return l10n.posPettyCashSubmitExpenseError;
      case 'reason_required':
        return l10n.posPettyCashReasonError;
      case 'submit_request_failed':
        return l10n.posPettyCashSubmitRequestError;
      case 'token_not_found':
        return l10n.posPettyCashTokenNotFound;
      case 'low_balance':
        return l10n.posPettyCashLowBalanceError;
      default:
        return key;
    }
  }

  final SessionService sessionService;
  final PosRepository posRepository;

  PettyCashViewModel({
    required this.sessionService,
    required this.posRepository,
  });

  List<ExpenseCategory> _expenseCategories = [];
  List<BranchEmployee> _branchEmployees = [];
  BranchEmployee? _selectedBranchEmployee;
  bool _branchEmployeesLoading = false;

  List<CashierExpenseHistoryEntry> _expenseHistory = [];
  bool _expenseHistoryLoading = false;
  String _expenseHistoryStatusFilter = 'all';
  int _expenseHistoryOffset = 0;
  bool _expenseHistoryHasMore = true;
  static const int _expenseHistoryPageSize = 30;
  DateTime? _expenseHistoryFromDate;
  DateTime? _expenseHistoryToDate;
  String? _expenseHistoryCategoryId;

  // Petty Cash State
  double _pettyCashBalance = 450.0;
  double _lowBalanceThreshold = 100.0;
  bool _requestFundRecommended = false;
  final List<PettyCashExpense> _expenses = [];
  final List<FundRequest> _fundRequests = [];
  bool _isPettyCashLoading = false;
  bool _isExpenseSubmitting = false;
  bool _isRequestSubmitting = false;
  final RealtimeService _realtimeService = RealtimeService();
  bool _realtimeBound = false;

  // Form State
  final amountController = TextEditingController();
  final notesController = TextEditingController();
  final requestAmountController = TextEditingController();
  final reasonController = TextEditingController();

  ExpenseCategory? _selectedCategory;
  File? _selectedImage;
  bool _isRequestingFunds = false;
  bool _showPendingRequestStatus = false;

  ExpenseCategory? get selectedCategory => _selectedCategory;
  File? get selectedImage => _selectedImage;
  bool get isRequestingFunds => _isRequestingFunds;
  bool get showPendingRequestStatus => _showPendingRequestStatus;

  List<ExpenseCategory> get expenseCategories => _expenseCategories;
  List<BranchEmployee> get branchEmployees => _branchEmployees;
  BranchEmployee? get selectedBranchEmployee => _selectedBranchEmployee;
  bool get branchEmployeesLoading => _branchEmployeesLoading;
  List<CashierExpenseHistoryEntry> get expenseHistory => _expenseHistory;
  bool get expenseHistoryLoading => _expenseHistoryLoading;
  String get expenseHistoryStatusFilter => _expenseHistoryStatusFilter;
  bool get expenseHistoryHasMore => _expenseHistoryHasMore;
  DateTime? get expenseHistoryFromDate => _expenseHistoryFromDate;
  DateTime? get expenseHistoryToDate => _expenseHistoryToDate;
  String? get expenseHistoryCategoryId => _expenseHistoryCategoryId;
  bool get isPettyCashLoading => _isPettyCashLoading;
  bool get isExpenseSubmitting => _isExpenseSubmitting;
  bool get isRequestSubmitting => _isRequestSubmitting;
  double get pettyCashBalance => _pettyCashBalance;
  bool get isLowPettyCashBalance => _pettyCashBalance < _lowBalanceThreshold;
  bool get requestFundRecommended => _requestFundRecommended;
  List<PettyCashExpense> get expenses => _expenses;
  List<FundRequest> get fundRequests => _fundRequests;

  Future<void> initPettyCash() async {
    _isPettyCashLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        fetchExpenseCategories(),
        fetchWalletBalance(),
      ]);
      await bindRealtime();
    } catch (e) {
      debugPrint('Error initializing petty cash: $e');
    } finally {
      _isPettyCashLoading = false;
      notifyListeners();
    }
  }

  void setCategory(ExpenseCategory? category) {
    _selectedCategory = category;
    _selectedBranchEmployee = null;
    notifyListeners();
    if (category?.requiresEmployeeSelection == true) {
      fetchBranchEmployees();
    }
  }

  void setBranchEmployee(BranchEmployee? employee) {
    _selectedBranchEmployee = employee;
    notifyListeners();
  }

  void setExpenseHistoryStatusFilter(String value) {
    if (_expenseHistoryStatusFilter == value) return;
    _expenseHistoryStatusFilter = value;
    fetchExpenseHistory(refresh: true);
  }

  void setExpenseHistoryDateRange({
    DateTime? from,
    DateTime? to,
  }) {
    if (from != null && to != null && from.isAfter(to)) {
      // Keep API contract: from must be <= to.
      _expenseHistoryFromDate = to;
      _expenseHistoryToDate = from;
    } else {
      _expenseHistoryFromDate = from;
      _expenseHistoryToDate = to;
    }
    fetchExpenseHistory(refresh: true);
  }

  void setExpenseHistoryCategoryId(String? categoryId) {
    final next = (categoryId == null || categoryId.trim().isEmpty)
        ? null
        : categoryId.trim();
    if (_expenseHistoryCategoryId == next) return;
    _expenseHistoryCategoryId = next;
    fetchExpenseHistory(refresh: true);
  }

  void clearExpenseHistoryFilters() {
    _expenseHistoryFromDate = null;
    _expenseHistoryToDate = null;
    _expenseHistoryCategoryId = null;
    _expenseHistoryStatusFilter = 'all';
    fetchExpenseHistory(refresh: true);
  }

  Future<void> fetchBranchEmployees() async {
    if (_branchEmployeesLoading) return;
    _branchEmployeesLoading = true;
    notifyListeners();
    try {
      final token = await sessionService.getToken();
      if (token == null) return;
      final res = await posRepository.getCashierEmployees(token);
      if (res.success) {
        _branchEmployees = res.employees;
      }
    } catch (e) {
      debugPrint('Error fetching branch employees: $e');
    } finally {
      _branchEmployeesLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchExpenseHistory({bool refresh = false}) async {
    if (_expenseHistoryLoading) return;
    if (refresh) {
      _expenseHistoryOffset = 0;
      _expenseHistoryHasMore = true;
      _expenseHistory = [];
    }
    if (!_expenseHistoryHasMore && !refresh) return;

    _expenseHistoryLoading = true;
    notifyListeners();
    try {
      final token = await sessionService.getToken();
      if (token == null) return;
      final statusParam =
      _expenseHistoryStatusFilter == 'all' ? null : _expenseHistoryStatusFilter;
      final res = await posRepository.getExpenseHistory(
        token,
        status: statusParam,
        from: _formatDateOnly(_expenseHistoryFromDate),
        to: _formatDateOnly(_expenseHistoryToDate),
        categoryId: _expenseHistoryCategoryId,
        limit: _expenseHistoryPageSize,
        offset: _expenseHistoryOffset,
      );
      if (refresh) {
        _expenseHistory = List<CashierExpenseHistoryEntry>.from(res.items);
      } else {
        _expenseHistory.addAll(res.items);
        _translatedLocale = null;
      }
      _expenseHistoryOffset += res.items.length;
      _expenseHistoryHasMore = res.items.length >= _expenseHistoryPageSize;
    } catch (e) {
      debugPrint('Error fetching expense history: $e');
    } finally {
      _expenseHistoryLoading = false;
      notifyListeners();
    }
  }

  void setIsRequestingFunds(bool isRequesting) {
    _isRequestingFunds = isRequesting;
    notifyListeners();
  }

  void setShowPendingRequestStatus(bool show) {
    _showPendingRequestStatus = show;
    notifyListeners();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _selectedImage = File(pickedFile.path);
      notifyListeners();
    }
  }

  void clearExpenseForm() {
    amountController.clear();
    notesController.clear();
    _selectedCategory = null;
    _selectedBranchEmployee = null;
    _selectedImage = null;
    notifyListeners();
  }

  void clearRequestForm() {
    requestAmountController.clear();
    reasonController.clear();
    notifyListeners();
  }

  Future<bool> submitExpenseAction(Function(String) onError) async {
    final amount = double.tryParse(amountController.text) ?? 0;
    if (amount <= 0) {
      onError('valid_amount');
      return false;
    }
    if (_selectedCategory == null) {
      onError('select_category');
      return false;
    }
    if (_selectedCategory!.requiresEmployeeSelection) {
      if (_selectedBranchEmployee == null) {
        onError('select_employee');
        return false;
      }
    }

    try {
      final success = await submitExpense(
        amount: amount,
        categoryId: _selectedCategory!.id,
        description: notesController.text,
        employeeId: _selectedCategory!.requiresEmployeeSelection
            ? _selectedBranchEmployee?.id
            : null,
        receiptPath: _selectedImage?.path,
      );

      if (success) {
        clearExpenseForm();
        return true;
      } else {
        onError('submit_expense_failed');
        return false;
      }
    } catch (e) {
      onError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<void> submitRequestAction(
      Function(String) onError,
      VoidCallback onSuccess,
      ) async {
    _isRequestSubmitting = true;
    notifyListeners();

    final amount = double.tryParse(requestAmountController.text) ?? 0;
    if (amount <= 0) {
      onError('valid_amount');
      _isRequestSubmitting = false;
      notifyListeners();
      return;
    }
    if (reasonController.text.isEmpty) {
      onError('reason_required');
      _isRequestSubmitting = false;
      notifyListeners();
      return;
    }

    final success = await requestFunds(
      amount: amount,
      reason: reasonController.text,
    );

    if (success) {
      onSuccess();
      clearRequestForm();
      setShowPendingRequestStatus(true);
      await fetchWalletBalance();
    } else {
      onError('submit_request_failed');
    }
    _isRequestSubmitting = false;
    notifyListeners();
  }

  Future<void> fetchExpenseCategories() async {
    try {
      final token = await sessionService.getToken();
      if (token == null) return;

      final response = await posRepository.getExpenseCategories(token);
      if (response.success) {
        _expenseCategories = response.categories;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching expense categories: $e');
    }
  }

  Future<void> fetchWalletBalance() async {
    try {
      final token = await sessionService.getToken();
      if (token == null) return;

      final response = await posRepository.getWalletBalance(token);
      if (response.success) {
        _pettyCashBalance = response.balance;
        _lowBalanceThreshold = response.lowBalanceThreshold;
        _requestFundRecommended = response.requestFundRecommended;
        notifyListeners();
      } else if (response.message.isNotEmpty) {
        debugPrint('Failed to fetch wallet balance: ${response.message}');
      }
    } catch (e) {
      debugPrint('Error fetching wallet balance: $e');
    }
  }

  Future<bool> submitExpense({
    required double amount,
    required String categoryId,
    required String description,
    String? employeeId,
    String? receiptPath,
  }) async {
    _isExpenseSubmitting = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken();
      if (token == null) throw Exception('token_not_found');

      final response = await posRepository.submitExpense(
        amount: amount,
        categoryId: categoryId,
        description: description,
        employeeId: employeeId,
        receiptFilePath: receiptPath,
        extraJson: (receiptPath == null || receiptPath.isEmpty)
            ? {'proofUrl': ''}
            : null,
        token: token,
      );
      final success = response['success'] == true;
      if (success) {
        final pettyCash = response['pettyCash'];
        if (pettyCash is Map<String, dynamic>) {
          _pettyCashBalance =
              double.tryParse(pettyCash['balance']?.toString() ?? '0') ??
                  _pettyCashBalance;
          _lowBalanceThreshold =
              double.tryParse(
                pettyCash['lowBalanceThreshold']?.toString() ??
                    _lowBalanceThreshold.toString(),
              ) ??
                  _lowBalanceThreshold;
        } else {
          await fetchWalletBalance();
        }
        return true;
      }
      return false;
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('low balance')) {
        throw Exception('low_balance');
      }
      debugPrint('Error submitting expense: $e');
      return false;
    } finally {
      _isExpenseSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> requestFunds({
    required double amount,
    required String reason,
  }) async {
    try {
      final token = await sessionService.getToken();
      if (token == null) throw Exception('token_not_found');

      final response = await posRepository.requestPettyCashFund({
        'amount': amount,
        'reason': reason,
      }, token);

      if (response['success'] == true) {
        final request = FundRequest(
          id: response['requestId']?.toString() ??
              'REQ-${DateTime.now().millisecondsSinceEpoch}',
          amount: double.tryParse(response['amount']?.toString() ?? '$amount') ??
              amount,
          reason: reason,
          date: DateTime.now(),
        );
        _fundRequests.add(request);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error requesting funds: $e');
      return false;
    }
  }

  String? _formatDateOnly(DateTime? value) {
    if (value == null) return null;
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> bindRealtime() async {
    if (_realtimeBound) return;
    final token = await sessionService.getToken();
    if (token == null || token.isEmpty) return;
    _realtimeService.connect(token);
    _realtimeService.on(
      RealtimeService.eventCashierPettyCashUpdated,
      _onCashierPettyCashUpdated,
    );
    _realtimeBound = true;
  }

  void unbindRealtime() {
    if (!_realtimeBound) return;
    _realtimeService.off(
      RealtimeService.eventCashierPettyCashUpdated,
      _onCashierPettyCashUpdated,
    );
    _realtimeService.disconnect();
    _realtimeBound = false;
  }

  void _onCashierPettyCashUpdated(Map<String, dynamic> _) {
    fetchWalletBalance();
    fetchExpenseHistory(refresh: true);
  }

  @override
  void dispose() {
    unbindRealtime();
    amountController.dispose();
    notesController.dispose();
    requestAmountController.dispose();
    reasonController.dispose();
    super.dispose();
  }
}