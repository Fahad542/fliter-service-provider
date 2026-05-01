import 'package:flutter/material.dart';
import '../../../data/repositories/owner_repository.dart';
import '../../../models/workshop_owner_models.dart';
import '../../../services/session_service.dart';
import '../../../services/locker_translation_mixin.dart';
import '../../Workshop pos app/More Tab/settings_view_model.dart';

// ---------------------------------------------------------------------------
// ApprovalsViewModel
//
// Fetches petty-cash approval requests via OwnerRepository.getPettyCashRequests
// using the real token from SessionService.
//
// Filter keys ('all', 'pending', …) are raw API values — never translated.
// Translated display fields are populated via TranslatableMixin after fetch.
// ---------------------------------------------------------------------------

class ApprovalsViewModel extends ChangeNotifier with TranslatableMixin {
  final OwnerRepository ownerRepository;
  final SessionService sessionService;
  final SettingsViewModel settingsViewModel;

  ApprovalsViewModel({
    required this.ownerRepository,
    required this.sessionService,
    required this.settingsViewModel,
  }) {
    bindLocaleRetranslation(settingsViewModel, _retranslateCachedRequests);
  }

  // ── State ─────────────────────────────────────────────────────────────────
  List<PettyCashRequestItem> _requests = [];
  bool _isLoading = false;
  String? _error;

  /// Raw API filter values — NEVER translated.
  String _statusFilter = 'all';
  String _queueFilter  = 'all';

  String _currency = 'SAR';

  /// IDs currently in-flight for approve / reject.
  final Set<String> _approvingIds = {};
  final Set<String> _rejectingIds = {};

  // ── Getters ───────────────────────────────────────────────────────────────
  List<PettyCashRequestItem> get requests => _requests;
  bool         get isLoading             => _isLoading;
  String?      get error                 => _error;
  String       get statusFilter          => _statusFilter;
  String       get queueFilter           => _queueFilter;
  String       get currency              => _currency;

  bool get hasApprovalActionInFlight =>
      _approvingIds.isNotEmpty || _rejectingIds.isNotEmpty;

  bool isApprovingRequest(String id) => _approvingIds.contains(id);
  bool isRejectingRequest(String id) => _rejectingIds.contains(id);

  // ── Filter setters ────────────────────────────────────────────────────────
  void setStatusFilter(String key) {
    if (_statusFilter == key) return;
    _statusFilter = key;
    notifyListeners();
    fetchRequests();
  }

  void setQueueFilter(String key) {
    if (_queueFilter == key) return;
    _queueFilter = key;
    notifyListeners();
    fetchRequests();
  }

  // ── Data fetch ────────────────────────────────────────────────────────────
  Future<void> fetchRequests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await sessionService.getToken(role: 'owner') ?? '';

      // 'all' means no filter — omit the param so the API returns everything.
      final String? statusParam =
      _statusFilter == 'all' ? null : _statusFilter;
      final String? queueParam =
      _queueFilter == 'all' ? null : _queueFilter;

      final PettyCashRequestsResponse response =
      await ownerRepository.getPettyCashRequests(
        token,
        status: statusParam,
        queue: queueParam,
      );

      _currency = response.currency;

      // Translate dynamic strings (branch/cashier names, status label)
      // on-the-fly when the active locale is Arabic.
      final translated = await Future.wait(
        response.requests.map((req) async {
          final tBranchName  = await t(req.branchName);
          final tCashierName = await t(req.cashierName);
          final tStatusLabel = await tStatus(req.status);
          return req.copyWith(
            translatedBranchName:  tBranchName,
            translatedCashierName: tCashierName,
            translatedStatus:      tStatusLabel,
          );
        }),
      );

      _requests = translated;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Actions ───────────────────────────────────────────────────────────────
  Future<void> approveRequest(String id) async {
    if (_approvingIds.contains(id)) return;
    _approvingIds.add(id);
    notifyListeners();

    try {
      final token = await sessionService.getToken(role: 'owner') ?? '';
      await ownerRepository.approvePettyCashRequest(token, id);
      await fetchRequests();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _approvingIds.remove(id);
      notifyListeners();
    }
  }

  Future<void> rejectRequest(String id, String reason) async {
    if (_rejectingIds.contains(id)) return;
    _rejectingIds.add(id);
    notifyListeners();

    try {
      final token = await sessionService.getToken(role: 'owner') ?? '';
      await ownerRepository.rejectPettyCashRequest(token, id, reason);
      await fetchRequests();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _rejectingIds.remove(id);
      notifyListeners();
    }
  }


  Future<void> _retranslateCachedRequests() async {
    if (_requests.isEmpty) return;
    _requests = await translatePettyCashRequests(_requests);
    notifyListeners();
  }

  @override
  void dispose() {
    unbindLocaleRetranslation();
    super.dispose();
  }

  // ── Realtime stubs ────────────────────────────────────────────────────────
  // OwnerRepository is a plain REST client — no push channel exists yet.
  // These satisfy ApprovalsView's initState/dispose lifecycle calls.
  // Replace with a real subscription if a WebSocket/Supabase channel is added.
  void bindRealtime()   {}
  void unbindRealtime() {}
}