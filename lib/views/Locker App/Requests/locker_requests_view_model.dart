import 'dart:async';
import 'package:flutter/material.dart';

import '../../../data/network/base_api_service.dart';
import '../../../data/repositories/locker_repository.dart';
import '../../../utils/debug_log.dart';
import '../../../models/locker_models.dart';
import '../../../services/session_service.dart';
import 'locker_requests_list_view.dart'; // for LockerListFilterMode

// ── State ─────────────────────────────────────────────────────────────────────

enum LockerRequestsState { idle, loading, loadingMore, success, error }

// ── Status filter options ─────────────────────────────────────────────────────

/// The 'all' tab sends no status param; the rest map 1-to-1 with the API.
/// Shown to supervisors — full visibility across all statuses.
const List<({String label, String? value})> kStatusFilters = [
  (label: 'ALL', value: null),
  (label: 'PENDING', value: 'pending'),
  (label: 'ASSIGNED', value: 'assigned'),
  (label: 'COLLECTED', value: 'collected'),
  (label: 'COMPLETED', value: 'completed'),
];

/// Supervisor-mode filter list when opened from "Assign Officers" shortcut.
/// Shows only PENDING — the only actionable status for assignment.
const List<({String label, String? value})> kAssignPendingFilters = [
  (label: 'PENDING', value: 'pending'),
];

/// Collector-scoped filters — only statuses relevant to a collector's workflow.
const List<({String label, String? value})> kCollectorStatusFilters = [

  (label: 'All', value: null),
  (label: 'ASSIGNED', value: 'assigned'),
  (label: 'COLLECTED', value: 'collected'),
];

// ── Role helpers ──────────────────────────────────────────────────────────────

bool _isSupervisorRole(String? userType) {
  switch (userType?.toLowerCase()) {
    case 'workshop_owner':
    case 'workshop_supervisor':
    case 'supervisor':
    case 'manager':
      return true;
    default:
      return false;
  }
}

String _viewParamFor(String? userType) =>
    _isSupervisorRole(userType) ? 'supervisor' : 'collector';

// ── ViewModel ─────────────────────────────────────────────────────────────────

class LockerRequestsViewModel extends ChangeNotifier {
  // ── Dependencies ────────────────────────────────────────────────────────────
  final LockerRepository _repository;
  final SessionService _sessionService;

  /// Controls which pre-set filter mode the list opens with.
  final LockerListFilterMode filterMode;

  LockerRequestsViewModel({
    LockerRepository? repository,
    SessionService? sessionService,
    this.filterMode = LockerListFilterMode.normal,
  })  : _repository = repository ?? LockerRepository(),
        _sessionService = sessionService ?? SessionService();

  // ── Session ──────────────────────────────────────────────────────────────────
  String? _token;
  String? _userType;
  String? _userId;

  // ── Role exposure ─────────────────────────────────────────────────────────
  String? get userId => _userId;
  bool get isSupervisor => _isSupervisorRole(_userType);
  bool get isCollector => !isSupervisor;

  /// Returns the correct filter list for the current role and filterMode.
  List<({String label, String? value})> get activeFilters {
    if (isCollector) return kCollectorStatusFilters;
    if (filterMode == LockerListFilterMode.assignPending) {
      return kAssignPendingFilters;
    }
    return kStatusFilters;
  }

  // ── Pagination ───────────────────────────────────────────────────────────────
  static const int _pageSize = 20;
  int _currentPage = 1;
  int _totalItems = 0;
  bool _hasMore = false;

  int get totalItems => _totalItems;
  bool get hasMore => _hasMore;

  // ── Data ─────────────────────────────────────────────────────────────────────
  final List<LockerRequest> _requests = [];
  List<LockerRequest> get requests => List.unmodifiable(_requests);

  // ── Filters ──────────────────────────────────────────────────────────────────
  String? _selectedStatus;
  String _searchQuery = '';
  Timer? _debounce;

  String? get selectedStatus => _selectedStatus;
  String get searchQuery => _searchQuery;

  // ── UI State ─────────────────────────────────────────────────────────────────
  LockerRequestsState _state = LockerRequestsState.idle;
  String? _errorMessage;

  LockerRequestsState get state => _state;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _state == LockerRequestsState.loading;
  bool get isLoadingMore => _state == LockerRequestsState.loadingMore;
  bool get hasError => _state == LockerRequestsState.error;
  bool get isSuccess => _state == LockerRequestsState.success;

  // ── Public API ───────────────────────────────────────────────────────────────

  Future<void> init() async {
    _state = LockerRequestsState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _token = await _sessionService.getToken(role: 'locker');
      final user = await _sessionService.getUser(role: 'locker');
      _userType = user?.userType;
      _userId = user?.id;

      if (_token == null) {
        _setError('Session expired. Please log in again.');
        return;
      }

      debugLog(
        '[LockerRequestsVM] Session loaded — '
            'userType=$_userType view=${_viewParamFor(_userType)} '
            'filterMode=$filterMode',
      );

      // Set initial status filter based on mode and role.
      if (filterMode == LockerListFilterMode.assignPending && isSupervisor) {
        // Supervisor opened via "Assign Officers" — lock to pending.
        _selectedStatus = 'pending';
      } else if (isCollector && _selectedStatus == null) {
        // Collectors default to 'assigned'.
        _selectedStatus = 'assigned';
      }
    } catch (e) {
      _setError('Failed to load session: ${_friendly(e)}');
      return;
    }

    await _loadPage(1, replace: true);
  }

  Future<void> setStatus(String? status) async {
    if (status == _selectedStatus) return;
    _selectedStatus = status;
    notifyListeners();
    await _loadPage(1, replace: true);
  }

  void onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (query == _searchQuery) return;
      _searchQuery = query;
      await _loadPage(1, replace: true);
    });
  }

  Future<void> refresh() => _loadPage(1, replace: true);

  Future<void> loadMore() async {
    if (_state == LockerRequestsState.loadingMore || !_hasMore) return;
    await _loadPage(_currentPage + 1, replace: false);
  }

  // ── Private ───────────────────────────────────────────────────────────────────

  Future<void> _loadPage(int page, {required bool replace}) async {
    if (replace) {
      _state = LockerRequestsState.loading;
    } else {
      _state = LockerRequestsState.loadingMore;
    }
    _errorMessage = null;
    notifyListeners();

    try {
      final page_ = await _repository.getCollectionRequests(
        token: _token!,
        view: _viewParamFor(_userType),
        status: _selectedStatus,
        search: _searchQuery.isEmpty ? null : _searchQuery,
        page: page,
        limit: _pageSize,
      );

      if (replace) {
        _requests
          ..clear()
          ..addAll(page_.items);
      } else {
        _requests.addAll(page_.items);
      }

      _currentPage = page;
      _totalItems = page_.total;
      _hasMore = _requests.length < page_.total;

      _state = LockerRequestsState.success;
      _errorMessage = null;
      notifyListeners();

      debugLog(
        '[LockerRequestsVM] page=$page total=${page_.total} '
            'loaded=${_requests.length} hasMore=$_hasMore',
      );
    } on UnauthorisedException {
      _setError('Session expired. Please log in again.');
    } on BadRequestException catch (e) {
      _setError('Bad request: ${_friendly(e)}');
    } on FetchDataException catch (e) {
      _setError(_friendly(e));
    } catch (e, st) {
      _setError('Something went wrong. Please try again.');
      debugLog('[LockerRequestsVM] Unexpected: $e\n$st');
    }
  }

  void _setError(String msg) {
    _state = LockerRequestsState.error;
    _errorMessage = msg;
    notifyListeners();
    debugLog('[LockerRequestsVM] Error: $msg');
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

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}