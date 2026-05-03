import 'dart:async';
import 'package:flutter/material.dart';

import '../../../data/network/base_api_service.dart';
import '../../../data/repositories/locker_repository.dart';
import '../../../models/locker_financial_models.dart';
import '../../../services/session_service.dart';
import '../../../utils/debug_log.dart';

// ── State enums ───────────────────────────────────────────────────────────────

enum HistoryState    { idle, loading, loadingMore, success, error }
enum AnalyticsState { idle, loading, success, error }
enum ExportState    { idle, exporting, done, error }

// ── Sort options ──────────────────────────────────────────────────────────────

enum HistorySortField  { date, amount, difference }
enum HistorySortOrder  { asc, desc }

// ── ViewModel ─────────────────────────────────────────────────────────────────

class LockerReportsViewModel extends ChangeNotifier {
  // ── Dependencies ─────────────────────────────────────────────────────────────
  final LockerRepository _repository;
  final SessionService   _sessionService;

  LockerReportsViewModel({
    LockerRepository? repository,
    SessionService?   sessionService,
  })  : _repository    = repository    ?? LockerRepository(),
        _sessionService = sessionService ?? SessionService();

  // ── Session ───────────────────────────────────────────────────────────────────
  String? _token;
  bool _isCollector = false;

  /// True when the current user is a locker collector.
  /// Collectors see only the Analytics tab — History is hidden.
  bool get isCollector => _isCollector;

  // ── History state ─────────────────────────────────────────────────────────────
  HistoryState _historyState = HistoryState.idle;
  String?      _historyError;
  final List<AuditLogEntry> _historyItems = [];

  HistoryState get historyState => _historyState;
  String?      get historyError => _historyError;
  List<AuditLogEntry> get historyItems => List.unmodifiable(_historyItems);

  bool get isHistoryLoading     => _historyState == HistoryState.loading;
  bool get isHistoryLoadingMore => _historyState == HistoryState.loadingMore;
  bool get isHistorySuccess     => _historyState == HistoryState.success;
  bool get isHistoryError       => _historyState == HistoryState.error;

  // ── History pagination ────────────────────────────────────────────────────────
  static const int _pageSize = 20;
  int  _currentPage = 1;
  int  _totalItems  = 0;
  bool _hasMore     = false;

  int  get totalItems => _totalItems;
  bool get hasMore    => _hasMore;

  // ── History filters ───────────────────────────────────────────────────────────
  String    _searchQuery  = '';
  String?   _selectedBranchId;    // branch id sent to API; null = 'all'
  DateTime? _historyFrom;
  DateTime? _historyTo;

  String    get searchQuery        => _searchQuery;
  String?   get selectedBranchId   => _selectedBranchId;
  DateTime? get historyFrom        => _historyFrom;
  DateTime? get historyTo          => _historyTo;

  /// Human-readable name of the currently selected branch, or `null` when
  /// "all branches" is selected. Used by the export filter label in the view.
  String? get branchFilter {
    if (_selectedBranchId == null) return null;
    try {
      return _branches
          .firstWhere((b) => b.id == _selectedBranchId)
          .name;
    } catch (_) {
      // Branch list not yet loaded or id not found — fall back to the raw id.
      return _selectedBranchId;
    }
  }

  // ── Branches (loaded from API) ────────────────────────────────────────────────
  List<LockerBranch> _branches = [];
  bool _branchesLoading = false;

  List<LockerBranch> get branches        => List.unmodifiable(_branches);
  bool               get branchesLoading => _branchesLoading;

  bool get hasActiveHistoryFilters =>
      _selectedBranchId != null ||
          _historyFrom  != null ||
          _historyTo    != null ||
          _searchQuery.isNotEmpty;

  // ── History sorting ───────────────────────────────────────────────────────────
  HistorySortField _sortField = HistorySortField.date;
  HistorySortOrder _sortOrder = HistorySortOrder.desc;

  HistorySortField get sortField => _sortField;
  HistorySortOrder get sortOrder => _sortOrder;

  /// Sorted view of all loaded history items.
  /// Branch filtering is now server-side via [_selectedBranchId].
  List<AuditLogEntry> get sortedHistory {
    final list = List<AuditLogEntry>.from(_historyItems);

    list.sort((a, b) {
      int cmp;
      switch (_sortField) {
        case HistorySortField.date:
          cmp = a.collectedAt.compareTo(b.collectedAt);
          break;
        case HistorySortField.amount:
          cmp = a.receivedFund.compareTo(b.receivedFund);
          break;
        case HistorySortField.difference:
          cmp = a.difference.abs().compareTo(b.difference.abs());
          break;
      }
      return _sortOrder == HistorySortOrder.asc ? cmp : -cmp;
    });
    return list;
  }

  // ── Analytics state ───────────────────────────────────────────────────────────
  AnalyticsState    _analyticsState = AnalyticsState.idle;
  String?           _analyticsError;
  LockerAnalyticsData? _analytics;

  AnalyticsState       get analyticsState => _analyticsState;
  String?              get analyticsError => _analyticsError;
  LockerAnalyticsData? get analytics      => _analytics;

  bool get isAnalyticsLoading => _analyticsState == AnalyticsState.loading;
  bool get isAnalyticsSuccess => _analyticsState == AnalyticsState.success;
  bool get isAnalyticsError   => _analyticsState == AnalyticsState.error;

  // ── Analytics filters ─────────────────────────────────────────────────────────
  DateTime? _analyticsFrom;
  DateTime? _analyticsTo;

  DateTime? get analyticsFrom => _analyticsFrom;
  DateTime? get analyticsTo   => _analyticsTo;

  bool get hasActiveAnalyticsFilters =>
      _analyticsFrom != null || _analyticsTo != null;

  // ── Export state ──────────────────────────────────────────────────────────────
  ExportState _exportState = ExportState.idle;
  String?     _exportError;

  ExportState get exportState => _exportState;
  String?     get exportError => _exportError;
  bool get isExporting => _exportState == ExportState.exporting;

  // ── Search debounce ───────────────────────────────────────────────────────────
  Timer? _debounce;

  // ── Public API ────────────────────────────────────────────────────────────────

  /// Call once from initState via addPostFrameCallback.
  Future<void> init() async {
    try {
      _token = await _sessionService.getToken(role: 'locker');
      if (_token == null) {
        _setHistoryError('Session expired. Please log in again.');
        _setAnalyticsError('Session expired. Please log in again.');
        return;
      }
      // Detect collector role from the stored user's userType field.
      final user = await _sessionService.getUser(role: 'locker');
      final userType = user?.userType?.toLowerCase();
      _isCollector = userType == 'collector' ||
          userType == 'collection_officer' ||
          userType == 'workshop_collector';
      notifyListeners();
    } catch (e) {
      _setHistoryError('Failed to load session: ${_friendly(e)}');
      _setAnalyticsError('Failed to load session: ${_friendly(e)}');
      return;
    }

    // Collectors only need analytics — skip history & branches for performance.
    if (_isCollector) {
      await _loadAnalytics();
    } else {
      // Load history, analytics, and branches in parallel for fast initial render.
      await Future.wait([
        _loadHistoryPage(1, replace: true),
        _loadAnalytics(),
        _loadBranches(),
      ]);
    }
  }

  // ── History controls ──────────────────────────────────────────────────────────

  void onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (query == _searchQuery) return;
      _searchQuery = query;
      await _loadHistoryPage(1, replace: true);
    });
  }

  /// Sets the selected branch by its API id and triggers a fresh server fetch.
  /// Pass `null` to clear (show all branches).
  Future<void> setSelectedBranch(String? branchId) async {
    if (_selectedBranchId == branchId) return;
    _selectedBranchId = branchId;
    notifyListeners();
    await _loadHistoryPage(1, replace: true);
  }

  Future<void> setHistoryDateRange(DateTime? from, DateTime? to) async {
    if (_historyFrom == from && _historyTo == to) return;
    _historyFrom = from;
    _historyTo   = to;
    await _loadHistoryPage(1, replace: true);
  }

  Future<void> clearHistoryFilters() async {
    _searchQuery      = '';
    _selectedBranchId = null;
    _historyFrom      = null;
    _historyTo        = null;
    notifyListeners();
    await _loadHistoryPage(1, replace: true);
  }

  void toggleSort(HistorySortField field) {
    if (_sortField == field) {
      _sortOrder = _sortOrder == HistorySortOrder.asc
          ? HistorySortOrder.desc
          : HistorySortOrder.asc;
    } else {
      _sortField = field;
      _sortOrder = HistorySortOrder.desc;
    }
    notifyListeners();
  }

  Future<void> refreshHistory() => _loadHistoryPage(1, replace: true);

  Future<void> loadMoreHistory() async {
    if (_historyState == HistoryState.loadingMore || !_hasMore) return;
    await _loadHistoryPage(_currentPage + 1, replace: false);
  }

  // ── Analytics controls ────────────────────────────────────────────────────────

  Future<void> setAnalyticsDateRange(DateTime? from, DateTime? to) async {
    if (_analyticsFrom == from && _analyticsTo == to) return;
    _analyticsFrom = from;
    _analyticsTo   = to;
    await _loadAnalytics();
  }

  Future<void> clearAnalyticsFilters() async {
    _analyticsFrom = null;
    _analyticsTo   = null;
    await _loadAnalytics();
  }

  Future<void> refreshAnalytics() => _loadAnalytics();

  // ── Export controls ───────────────────────────────────────────────────────────

  void setExportIdle() {
    _exportState = ExportState.idle;
    _exportError = null;
    notifyListeners();
  }

  void setExportState(ExportState state, {String? error}) {
    _exportState = state;
    _exportError = error;
    notifyListeners();
  }

  // ── Private: History ──────────────────────────────────────────────────────────

  Future<void> _loadHistoryPage(int page, {required bool replace}) async {
    if (_token == null) return;

    _historyState = replace ? HistoryState.loading : HistoryState.loadingMore;
    _historyError = null;
    notifyListeners();

    try {
      final result = await _repository.getFinancialHistory(
        token    : _token!,
        search   : _searchQuery.isEmpty ? null : _searchQuery,
        branchId : _selectedBranchId,   // null → 'all' handled in repo
        from     : _historyFrom,
        to       : _historyTo,
        page     : page,
        limit    : _pageSize,
      );

      if (replace) {
        _historyItems
          ..clear()
          ..addAll(result.items);
      } else {
        _historyItems.addAll(result.items);
      }

      _currentPage = page;
      _totalItems  = result.total;
      _hasMore     = _historyItems.length < result.total;

      _historyState = HistoryState.success;
      _historyError = null;
      notifyListeners();

      debugLog(
        '[ReportsVM] History page=$page total=${result.total} '
            'loaded=${_historyItems.length} hasMore=$_hasMore',
      );
    } on UnauthorisedException {
      _setHistoryError('Session expired. Please log in again.');
    } on BadRequestException catch (e) {
      _setHistoryError('Bad request: ${_friendly(e)}');
    } on FetchDataException catch (e) {
      _setHistoryError(_friendly(e));
    } catch (e, st) {
      _setHistoryError('Something went wrong. Please try again.');
      debugLog('[ReportsVM] History unexpected: $e\n$st');
    }
  }

  // ── Private: Branches ─────────────────────────────────────────────────────────

  Future<void> _loadBranches() async {
    if (_token == null) return;
    _branchesLoading = true;
    notifyListeners();
    try {
      _branches = await _repository.getBranches(token: _token!);
      debugLog('[ReportsVM] Loaded ${_branches.length} branches');
    } catch (e) {
      debugLog('[ReportsVM] Failed to load branches: $e');
      // Non-fatal: dropdown just stays empty; user can still use date/search filters.
    } finally {
      _branchesLoading = false;
      notifyListeners();
    }
  }

  // ── Private: Analytics ────────────────────────────────────────────────────────

  Future<void> _loadAnalytics() async {
    if (_token == null) return;

    _analyticsState = AnalyticsState.loading;
    _analyticsError = null;
    notifyListeners();

    try {
      _analytics = await _repository.getFinancialAnalytics(
        token: _token!,
        from : _analyticsFrom,
        to   : _analyticsTo,
      );

      _analyticsState = AnalyticsState.success;
      _analyticsError = null;
      notifyListeners();

      debugLog('[ReportsVM] Analytics loaded — range ${_analytics?.range.from} → ${_analytics?.range.to}');
    } on UnauthorisedException {
      _setAnalyticsError('Session expired. Please log in again.');
    } on BadRequestException catch (e) {
      _setAnalyticsError('Bad request: ${_friendly(e)}');
    } on FetchDataException catch (e) {
      _setAnalyticsError(_friendly(e));
    } catch (e, st) {
      _setAnalyticsError('Something went wrong. Please try again.');
      debugLog('[ReportsVM] Analytics unexpected: $e\n$st');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  void _setHistoryError(String msg) {
    _historyState = HistoryState.error;
    _historyError = msg;
    notifyListeners();
    debugLog('[ReportsVM] History error: $msg');
  }

  void _setAnalyticsError(String msg) {
    _analyticsState = AnalyticsState.error;
    _analyticsError = msg;
    notifyListeners();
    debugLog('[ReportsVM] Analytics error: $msg');
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