import 'package:flutter/material.dart';

import '../../../data/network/base_api_service.dart';
import '../../../data/repositories/locker_repository.dart';
import '../../../utils/debug_log.dart';
import '../../../models/locker_models.dart';
import '../../../services/session_service.dart';

// ── State ─────────────────────────────────────────────────────────────────────

enum RecordCollectionState { idle, submitting, success, error }

// ── ViewModel ─────────────────────────────────────────────────────────────────

class RecordCollectionViewModel extends ChangeNotifier {
  // ── Dependencies ─────────────────────────────────────────────────────────────
  final LockerRepository _repository;
  final SessionService _sessionService;

  /// The request this collection is being recorded for. Supplied at construction
  /// so the view can display expected amount immediately without a second fetch.
  final LockerRequest request;

  RecordCollectionViewModel({
    required this.request,
    LockerRepository? repository,
    SessionService? sessionService,
  })  : _repository = repository ?? LockerRepository(),
        _sessionService = sessionService ?? SessionService();

  // ── Session ───────────────────────────────────────────────────────────────────
  String? _token;

  // ── UI State ──────────────────────────────────────────────────────────────────
  RecordCollectionState _state = RecordCollectionState.idle;
  String? _errorMessage;
  CollectionResult? _result;

  RecordCollectionState get state => _state;
  String? get errorMessage => _errorMessage;
  CollectionResult? get result => _result;

  bool get isSubmitting => _state == RecordCollectionState.submitting;
  bool get isSuccess    => _state == RecordCollectionState.success;
  bool get hasError     => _state == RecordCollectionState.error;

  // ── Derived helpers ───────────────────────────────────────────────────────────

  /// Difference between expected and received (signed: positive = short).
  double computeDifference(double received) =>
      request.lockedCashAmount - received;

  // ── Public API ────────────────────────────────────────────────────────────────

  /// Loads the auth token lazily — call once before [submit].
  Future<bool> loadSession() async {
    try {
      _token = await _sessionService.getToken(role: 'locker');
      if (_token == null) {
        _setError('Session expired. Please log in again.');
        return false;
      }
      return true;
    } catch (e) {
      _setError('Failed to load session: ${_friendly(e)}');
      return false;
    }
  }

  /// Submits the collection record to the API.
  ///
  /// Returns [true] on success; the caller can then read [result] for details.
  /// Returns [false] on any error; read [errorMessage] for a user-facing string.
  Future<bool> submit({
    required double receivedAmount,
    String notes = '',
    String proofUrl = '',
  }) async {
    // Ensure we have a token (idempotent call).
    if (_token == null) {
      final ok = await loadSession();
      if (!ok) return false;
    }

    _state = RecordCollectionState.submitting;
    _errorMessage = null;
    _result = null;
    notifyListeners();

    debugLog(
      '[RecordCollectionVM] Submitting — requestId=${request.id} '
      'receivedAmount=$receivedAmount',
    );

    try {
      final result = await _repository.recordCollection(
        token          : _token!,
        requestId      : request.id,
        receivedAmount : receivedAmount,
        notes          : notes,
        proofUrl       : proofUrl,
      );

      _result = result;
      _state = RecordCollectionState.success;
      _errorMessage = null;
      notifyListeners();

      debugLog(
        '[RecordCollectionVM] Success — collectionId=${result.collectionId} '
        'difference=${result.difference} status=${result.collectionStatus}',
      );

      return true;
    } on UnauthorisedException {
      _setError('Session expired. Please log in again.');
    } on BadRequestException catch (e) {
      _setError(_friendly(e));
    } on FetchDataException catch (e) {
      _setError(_friendly(e));
    } catch (e, st) {
      _setError('Something went wrong. Please try again.');
      debugLog('[RecordCollectionVM] Unexpected error: $e\n$st');
    }

    return false;
  }

  /// Resets to idle — allows the user to correct and resubmit after an error.
  void resetError() {
    if (_state == RecordCollectionState.error) {
      _state = RecordCollectionState.idle;
      _errorMessage = null;
      notifyListeners();
    }
  }

  // ── Private ───────────────────────────────────────────────────────────────────

  void _setError(String msg) {
    _state = RecordCollectionState.error;
    _errorMessage = msg;
    notifyListeners();
    debugLog('[RecordCollectionVM] Error: $msg');
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
