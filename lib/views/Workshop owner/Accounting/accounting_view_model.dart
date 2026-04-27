import 'package:flutter/material.dart';
import '../../../../models/workshop_owner_models.dart';
import '../../../../data/repositories/owner_repository.dart';
import '../../../../services/session_service.dart';
import '../../../services/locker_translation_mixin.dart';

// ---------------------------------------------------------------------------
// AccountingViewModel
//
// Static UI labels (tab names, card headers, etc.) are resolved in the View
// via AppLocalizations.  Dynamic data coming from the API — party names,
// reference strings, status values — are translated here using
// [TranslatableMixin] so every widget just reads a pre-translated string.
// ---------------------------------------------------------------------------

class AccountingViewModel extends ChangeNotifier with TranslatableMixin {
  final OwnerRepository ownerRepository;
  final SessionService sessionService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AccountingSummaryResponse? _summaryResponse;
  AccountingSummaryResponse? get summaryResponse => _summaryResponse;

  final Map<String, List<AccountEntry>> _transactionsMap = {};
  List<AccountEntry> getTransactionsFor(String type) =>
      _transactionsMap[type] ?? [];

  bool _isTransactionsLoading = false;
  bool get isTransactionsLoading => _isTransactionsLoading;

  String _currentLoadingType = '';
  bool isLoadingType(String type) =>
      _isTransactionsLoading && _currentLoadingType == type;

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
        final response =
        await ownerRepository.getAccountingTransactions(token, type);
        if (response != null &&
            response is Map<String, dynamic> &&
            response['success'] == true) {
          final List<dynamic> txs = response['transactions'] ?? [];
          final entries = txs
              .map((json) => AccountEntry.fromJson(json))
              .toList();

          // ── Translate dynamic API strings ──────────────────────────────
          // Runs concurrently for all entries in this batch.
          final translated = await Future.wait(
            entries.map((entry) => _translateEntry(entry)),
          );
          _transactionsMap[type] = translated;
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

  /// Translates the mutable display fields of a single [AccountEntry].
  /// Returns a new entry with [translatedParty] and [translatedStatus] set.
  Future<AccountEntry> _translateEntry(AccountEntry entry) async {
    final party  = await tParty(entry.party);
    final status = await tStatus(entry.status);
    return entry.copyWith(
      translatedParty: party,
      translatedStatus: status,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}