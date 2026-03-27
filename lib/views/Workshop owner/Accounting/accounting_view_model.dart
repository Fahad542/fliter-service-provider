import 'package:flutter/material.dart';
import '../../../../models/workshop_owner_models.dart';
import '../../../../data/repositories/owner_repository.dart';
import '../../../../services/session_service.dart';

class AccountingViewModel extends ChangeNotifier {
  final OwnerRepository ownerRepository;
  final SessionService sessionService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AccountingSummaryResponse? _summaryResponse;
  AccountingSummaryResponse? get summaryResponse => _summaryResponse;

  final Map<String, List<AccountEntry>> _transactionsMap = {};
  List<AccountEntry> getTransactionsFor(String type) => _transactionsMap[type] ?? [];

  bool _isTransactionsLoading = false;
  bool get isTransactionsLoading => _isTransactionsLoading;
  
  String _currentLoadingType = '';
  bool isLoadingType(String type) => _isTransactionsLoading && _currentLoadingType == type;

  AccountingViewModel({
    required this.ownerRepository,
    required this.sessionService,
  });

  Future<void> fetchSummary() async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token != null) {
        final response = await ownerRepository.getAccountingSummary(token);
        if (response != null) {
          _summaryResponse = AccountingSummaryResponse.fromJson(response);
        }
      }
    } catch (e) {
      debugPrint('Error fetching accounting summary: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTransactions(String type) async {
    _isTransactionsLoading = true;
    _currentLoadingType = type;
    notifyListeners();
    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token != null) {
        final response = await ownerRepository.getAccountingTransactions(token, type);
        if (response != null && response is Map<String, dynamic> && response['success'] == true) {
          final List<dynamic> txs = response['transactions'] ?? [];
          _transactionsMap[type] = txs.map((json) => AccountEntry.fromJson(json)).toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching accounting transactions: $e');
    } finally {
      if (_currentLoadingType == type) {
        _isTransactionsLoading = false;
      }
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
