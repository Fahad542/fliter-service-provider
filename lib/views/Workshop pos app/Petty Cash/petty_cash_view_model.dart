import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../services/session_service.dart';
import '../../../../data/repositories/pos_repository.dart';
import '../../../../models/petty_cash_model.dart';
import '../../../../models/expense_category_model.dart';

class PettyCashViewModel extends ChangeNotifier {
  final SessionService sessionService;
  final PosRepository posRepository;

  PettyCashViewModel({
    required this.sessionService,
    required this.posRepository,
  });

  List<ExpenseCategory> _expenseCategories = [];

  // Petty Cash State
  double _pettyCashBalance = 450.0;
  final double _lowBalanceThreshold = 100.0;
  final List<PettyCashExpense> _expenses = [];
  final List<FundRequest> _fundRequests = [];
  bool _isPettyCashLoading = false;
  bool _isExpenseSubmitting = false;

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
  bool get isPettyCashLoading => _isPettyCashLoading;
  bool get isExpenseSubmitting => _isExpenseSubmitting;
  double get pettyCashBalance => _pettyCashBalance;
  bool get isLowPettyCashBalance => _pettyCashBalance < _lowBalanceThreshold;
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
    } catch (e) {
      debugPrint('Error initializing petty cash: $e');
    } finally {
      _isPettyCashLoading = false;
      notifyListeners();
    }
  }

  void setCategory(ExpenseCategory? category) {
    _selectedCategory = category;
    notifyListeners();
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
      onError('Please enter a valid amount');
      return false;
    }
    if (amount > _pettyCashBalance) {
      onError('Low balance – request fund first');
      return false;
    }
    if (_selectedCategory == null) {
      onError('Please select a category');
      return false;
    }

    final success = await submitExpense(
      amount: amount,
      categoryId: _selectedCategory!.id,
      description: notesController.text,
      receiptPath: _selectedImage?.path,
    );

    if (success) {
      clearExpenseForm();
      return true;
    } else {
      onError('Failed to submit expense. Check balance or try again.');
      return false;
    }
  }

  void submitRequestAction(Function(String) onError, VoidCallback onSuccess) {
    final amount = double.tryParse(requestAmountController.text) ?? 0;
    if (amount <= 0) {
      onError('Please enter a valid amount');
      return;
    }
    if (reasonController.text.isEmpty) {
      onError('Please enter a reason');
      return;
    }

    requestFunds(
      amount: amount,
      reason: reasonController.text,
    );

    onSuccess();
    clearRequestForm();
    setShowPendingRequestStatus(true);
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
    String? receiptPath,
  }) async {
    _isExpenseSubmitting = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken();
      if (token == null) throw Exception('Token not found');

      final data = {
        'amount': amount,
        'categoryId': categoryId,
        'description': description,
        'proofUrl': receiptPath ?? '',
      };

      final success = await posRepository.submitExpense(data, token);

      if (success) {
        // Refresh balance after successful submission
        await fetchWalletBalance();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error submitting expense: $e');
      return false;
    } finally {
      _isExpenseSubmitting = false;
      notifyListeners();
    }
  }

  void requestFunds({
    required double amount,
    required String reason,
  }) {
    final request = FundRequest(
      id: 'REQ-${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      reason: reason,
      date: DateTime.now(),
    );

    _fundRequests.add(request);
    notifyListeners();
  }

  @override
  void dispose() {
    amountController.dispose();
    notesController.dispose();
    requestAmountController.dispose();
    reasonController.dispose();
    super.dispose();
  }
}
