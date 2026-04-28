import 'package:flutter/material.dart';
import '../../../../models/workshop_owner_models.dart';
import '../../../../data/repositories/owner_repository.dart';
import '../../../../services/session_service.dart';
import '../../../services/locker_translation_mixin.dart';
import '../../../views/Workshop pos app/More Tab/settings_view_model.dart';

// ---------------------------------------------------------------------------
// AccountingViewModel
//
// Static UI labels (tab names, card headers, etc.) are resolved in the View
// via AppLocalizations.  Dynamic API data — party names, reference strings,
// status values — are translated here using [TranslatableMixin].
//
// ── Locale-change re-translation ────────────────────────────────────────────
// Raw (untranslated) entries are kept in [_rawTransactionsMap].
// When [SettingsViewModel] fires a locale change, [_onLocaleChanged] is
// called, which re-translates every cached raw entry and calls
// notifyListeners(), so the UI rebuilds with the correct language WITHOUT
// a new network request.
//
// ── Switch / if-else safety ─────────────────────────────────────────────────
// All switch/if logic in the View ALWAYS uses the RAW entry.status and
// entry.type values (English API values like 'overdue', 'settled', 'payable').
// Translated text lives ONLY in entry.translatedStatus / entry.translatedParty.
// This guarantees Arabic mode NEVER breaks any colour/icon conditional.
// ---------------------------------------------------------------------------

class AccountingViewModel extends ChangeNotifier with TranslatableMixin {
  final OwnerRepository ownerRepository;
  final SessionService sessionService;
  final SettingsViewModel settingsViewModel;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AccountingSummaryResponse? _summaryResponse;
  AccountingSummaryResponse? get summaryResponse => _summaryResponse;

  /// Translated entries shown in the UI.
  final Map<String, List<AccountEntry>> _transactionsMap = {};

  /// Raw (untranslated) entries — kept so we can re-translate on locale
  /// change without a new network call.
  final Map<String, List<AccountEntry>> _rawTransactionsMap = {};

  List<AccountEntry> getTransactionsFor(String type) =>
      _transactionsMap[type] ?? [];

  bool _isTransactionsLoading = false;
  bool get isTransactionsLoading => _isTransactionsLoading;

  String _currentLoadingType = '';
  bool isLoadingType(String type) =>
      _isTransactionsLoading && _currentLoadingType == type;

  String? _error;
  String? get error => _error;

  AccountingViewModel({
    required this.ownerRepository,
    required this.sessionService,
    required this.settingsViewModel,
  }) {
    // Listen for locale changes so we can re-translate cached data.
    settingsViewModel.addListener(_onLocaleChanged);
  }

  // ── Locale-change handler ─────────────────────────────────────────────────

  /// Called whenever [SettingsViewModel] notifies (e.g. locale toggle).
  /// Re-translates every cached raw entry and notifies UI listeners.
  /// No network call is made — uses the already-fetched raw entries.
  Future<void> _onLocaleChanged() async {
    if (_rawTransactionsMap.isEmpty) return;

    // Re-translate all cached types concurrently.
    final futures = _rawTransactionsMap.entries.map((entry) async {
      final translated = await Future.wait(
        entry.value.map((e) => _translateEntry(e)),
      );
      _transactionsMap[entry.key] = translated;
    });

    await Future.wait(futures);
    notifyListeners();
  }

  // ── Data fetching ─────────────────────────────────────────────────────────

  Future<void> fetchSummary() async {
    _isLoading = true;
    _error = null;
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
      _error = e.toString();
      debugPrint('Error fetching accounting summary: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTransactions(String type) async {
    // [type] is always a raw API key ('payable', 'receivable', 'expense',
    // 'advance'). It is NEVER a translated string — safe for map key lookup.
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
          final rawEntries =
          txs.map((json) => AccountEntry.fromJson(json)).toList();

          // Store raw entries for later re-translation on locale change.
          _rawTransactionsMap[type] = rawEntries;

          // Translate for the current locale.
          final translated = await Future.wait(
            rawEntries.map((entry) => _translateEntry(entry)),
          );
          _transactionsMap[type] = translated;
        }
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching accounting transactions: $e');
    } finally {
      if (_currentLoadingType == type) {
        _isTransactionsLoading = false;
      }
      notifyListeners();
    }
  }

  // ── Translation helpers ───────────────────────────────────────────────────

  /// Translates the mutable display fields of a single [AccountEntry].
  ///
  /// IMPORTANT: The raw [entry.party], [entry.status], and [entry.type]
  /// fields are NEVER modified here — only the "translated*" fields are set.
  /// All switch/if logic in the View must read from the raw fields.
  Future<AccountEntry> _translateEntry(AccountEntry entry) async {
    // tParty: translates vendor/customer names (dynamic API strings).
    final party = await tParty(entry.party);

    // tStatus: uses the fast-path status map first (no network call for known
    // statuses like 'overdue', 'settled', 'pending').
    final status = await tStatus(entry.status);

    // tReference: skips translation for reference codes like "INV-001".
    // We expose this via the translatedParty field for the reference string
    // only when needed; for now we keep ref untranslated (it's a code).
    return entry.copyWith(
      translatedParty: party,
      translatedStatus: status,
    );
  }

  @override
  void dispose() {
    settingsViewModel.removeListener(_onLocaleChanged);
    super.dispose();
  }
}