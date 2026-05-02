import 'package:flutter/material.dart';

import '../../../data/network/base_api_service.dart';
import '../../../data/repositories/locker_repository.dart';
import '../../../services/session_service.dart';
import '../../../utils/debug_log.dart';

// ── State enums ───────────────────────────────────────────────────────────────

enum VarianceApprovalsState { idle, loading, success, error }

enum VarianceActionState { idle, processing, success, error }

// ── ViewModel ─────────────────────────────────────────────────────────────────

class LockerVarianceApprovalsViewModel extends ChangeNotifier {
  final LockerRepository _repository;
  final SessionService _sessionService;

  LockerVarianceApprovalsViewModel({
    LockerRepository? repository,
    SessionService? sessionService,
  })  : _repository = repository ?? LockerRepository(),
        _sessionService = sessionService ?? SessionService();

  // ── Session ───────────────────────────────────────────────────────────────
  String? _token;

  // ── List state ────────────────────────────────────────────────────────────
  VarianceApprovalsState _state = VarianceApprovalsState.idle;
  String? _errorMessage;
  List<LockerVarianceApproval> _approvals = [];

  VarianceApprovalsState get state => _state;
  String? get errorMessage => _errorMessage;
  List<LockerVarianceApproval> get approvals => List.unmodifiable(_approvals);

  bool get isLoading => _state == VarianceApprovalsState.loading;
  bool get hasError => _state == VarianceApprovalsState.error;
  bool get isSuccess => _state == VarianceApprovalsState.success;

  // ── Per-item action state ─────────────────────────────────────────────────
  VarianceActionState _actionState = VarianceActionState.idle;
  String? _actionError;

  /// The collection ID currently being processed (used for per-tile loading).
  String? _processingId;

  VarianceActionState get actionState => _actionState;
  String? get actionError => _actionError;
  String? get processingId => _processingId;
  bool get isProcessing => _actionState == VarianceActionState.processing;

  // ── Public API ────────────────────────────────────────────────────────────

  Future<void> init() async {
    _state = VarianceApprovalsState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _token = await _sessionService.getToken(role: 'locker');
      if (_token == null) {
        _setError('Session expired. Please log in again.');
        return;
      }
    } catch (e) {
      _setError('Failed to load session: ${_friendly(e)}');
      return;
    }

    await _fetchApprovals();
  }

  Future<void> refresh() => _fetchApprovals();

  /// Approves the collection with [collectionId].
  /// Returns true on success.
  Future<bool> approve(String collectionId) async {
    return _performAction(collectionId, 'approved', '');
  }

  /// Rejects the collection with [collectionId] with an optional reason.
  /// Returns true on success.
  Future<bool> reject(String collectionId, {String reason = ''}) async {
    return _performAction(collectionId, 'rejected', reason);
  }

  void resetActionState() {
    _actionState = VarianceActionState.idle;
    _actionError = null;
    _processingId = null;
    notifyListeners();
  }

  // ── Private ───────────────────────────────────────────────────────────────

  Future<void> _fetchApprovals() async {
    _state = VarianceApprovalsState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _approvals = await _repository.getApprovals(token: _token!);
      _state = VarianceApprovalsState.success;
      _errorMessage = null;
      notifyListeners();
      debugLog('[VarianceApprovalsVM] Loaded ${_approvals.length} approvals');
    } on UnauthorisedException {
      _setError('Session expired. Please log in again.');
    } on BadRequestException catch (e) {
      _setError('Bad request: ${_friendly(e)}');
    } on FetchDataException catch (e) {
      _setError(_friendly(e));
    } catch (e, st) {
      _setError('Something went wrong. Please try again.');
      debugLog('[VarianceApprovalsVM] Unexpected: $e\n$st');
    }
  }

  Future<bool> _performAction(
      String collectionId, String status, String reason) async {
    if (_token == null) {
      _actionError = 'Not authenticated.';
      _actionState = VarianceActionState.error;
      notifyListeners();
      return false;
    }

    _processingId = collectionId;
    _actionState = VarianceActionState.processing;
    _actionError = null;
    notifyListeners();

    try {
      await _repository.approveDifference(
        token: _token!,
        collectionId: collectionId,
        status: status,
        rejectionReason: reason,
      );

      // Remove the item from the local list immediately so the UI updates.
      _approvals =
          _approvals.where((a) => a.id != collectionId).toList();

      _actionState = VarianceActionState.success;
      _processingId = null;
      notifyListeners();

      debugLog(
          '[VarianceApprovalsVM] $status collectionId=$collectionId');
      return true;
    } on UnauthorisedException {
      _setActionError('Session expired. Please log in again.');
    } on BadRequestException catch (e) {
      _setActionError('Bad request: ${_friendly(e)}');
    } on FetchDataException catch (e) {
      _setActionError(_friendly(e));
    } catch (e, st) {
      _setActionError('Operation failed. Please try again.');
      debugLog('[VarianceApprovalsVM] Unexpected action error: $e\n$st');
    }

    _processingId = null;
    return false;
  }

  void _setError(String msg) {
    _state = VarianceApprovalsState.error;
    _errorMessage = msg;
    notifyListeners();
    debugLog('[VarianceApprovalsVM] Error: $msg');
  }

  void _setActionError(String msg) {
    _actionState = VarianceActionState.error;
    _actionError = msg;
    notifyListeners();
    debugLog('[VarianceApprovalsVM] Action error: $msg');
  }

  String _friendly(Object e) {
    final raw = e.toString();
    const prefixes = [
      'Error During Communication: ',
      'Invalid Request: ',
      'Unauthorised: ',
    ];
    for (final p in prefixes) {
      if (raw.startsWith(p)) return raw.substring(p.length);
    }
    return raw;
  }
}