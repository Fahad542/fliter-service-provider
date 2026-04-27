import 'package:flutter/material.dart';

import '../../../data/network/base_api_service.dart';
import '../../../data/repositories/locker_repository.dart';
import '../../../models/locker_models.dart';
import '../../../services/locker_translation_mixin.dart';
import '../../../services/session_service.dart';

// ── View state enum ───────────────────────────────────────────────────────────

enum LockerDashboardState { idle, loading, success, error }

// ── User-type → view resolver ─────────────────────────────────────────────────

/// Maps the raw `userType` from the login API to the initial dashboard view key
/// ('supervisor' | 'collector').
String _resolveView(String? userType) {
  switch (userType?.toLowerCase()) {
    case 'workshop_supervisor':
    case 'supervisor':
    case 'manager':
    case 'workshop_owner':
      return 'supervisor';
    case 'workshop_collector':
    case 'collection_officer':
    case 'collector':
      return 'collector';
    default:
      debugPrint(
        '[LockerDashboardVM] Unknown userType "$userType" — defaulting to collector.',
      );
      return 'collector';
  }
}

/// Returns true when the logged-in user's role allows switching tabs.
bool _resolveCanSwitch(String? userType) {
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

// ── ViewModel ─────────────────────────────────────────────────────────────────

class LockerDashboardViewModel extends ChangeNotifier
    with LockerTranslationMixin {          // ← uses the typedef alias

  // ── Dependencies ────────────────────────────────────────────────────────────
  final LockerRepository _repository;
  final SessionService _sessionService;

  LockerDashboardViewModel({
    LockerRepository? repository,
    SessionService? sessionService,
  })  : _repository = repository ?? LockerRepository(),
        _sessionService = sessionService ?? SessionService();

  // ── Session / user ──────────────────────────────────────────────────────────
  String? _token;
  String? _userName;
  String? _userId;
  String? _userType;

  String? get userName => translatedUserName ?? _userName;
  String? get userId => _userId;
  String? get userType => _userType;

  /// Arabic-translated version of [_userName] (null until translation resolves).
  String? translatedUserName;

  // ── Active view ─────────────────────────────────────────────────────────────
  String _activeView = 'collector';

  String get activeView => _activeView;
  bool get isSupervisor => _activeView == 'supervisor';
  bool get isCollector  => _activeView == 'collector';
  bool get canSwitchView => _resolveCanSwitch(_userType);

  // ── Dashboard data ──────────────────────────────────────────────────────────
  LockerDashboardData? _dashboardData;
  LockerDashboardData? get dashboardData => _dashboardData;

  LockerSupervisorStats get supervisorStats =>
      _dashboardData?.supervisor ?? LockerSupervisorStats.empty();

  LockerCollectorStats get collectorStats =>
      _dashboardData?.collector ?? LockerCollectorStats.empty();

  LockerPendingCollections get pendingCollections =>
      _dashboardData?.pendingCollections ?? LockerPendingCollections.empty();

  LockerTodaysCollections get todaysCollections =>
      _dashboardData?.todaysCollections ?? LockerTodaysCollections.empty();

  double get monthlyCollected => _dashboardData?.monthlyCollected ?? 0.0;
  int get pendingApprovals => _dashboardData?.pendingApprovals ?? 0;

  // ── UI state ─────────────────────────────────────────────────────────────────
  LockerDashboardState _state = LockerDashboardState.idle;
  String? _errorMessage;
  bool _isSessionLoaded = false;

  LockerDashboardState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading      => _state == LockerDashboardState.loading;
  bool get hasError       => _state == LockerDashboardState.error;
  bool get isSuccess      => _state == LockerDashboardState.success;
  bool get isSessionLoaded => _isSessionLoaded;

  // ── Public API ───────────────────────────────────────────────────────────────

  /// Entry point — call once from [initState] via [addPostFrameCallback].
  Future<void> init() async {
    _setLoading();

    try {
      _token    = await _sessionService.getToken(role: 'locker');
      final user = await _sessionService.getUser(role: 'locker');

      if (_token == null) {
        _setError('Session expired. Please log in again.');
        return;
      }

      _userName = user?.name ?? 'User';
      _userId   = user?.id;
      _userType = user?.userType;
      _activeView = _resolveView(_userType);

      // Translate the user's name if Arabic locale is active.
      // translateUserName is provided by LockerTranslatableMixin.
      translatedUserName = await translateUserName(_userName);

      debugPrint(
        '[LockerDashboardVM] Session loaded — '
            'user=$_userName userType=$_userType '
            'view=$_activeView canSwitch=$canSwitchView',
      );

      _isSessionLoaded = true;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load session: ${_friendlyMessage(e)}');
      return;
    }

    await _fetchDashboard();
  }

  /// Switches between 'supervisor' and 'collector' tabs and re-fetches data.
  Future<void> switchView(String view) async {
    assert(view == 'supervisor' || view == 'collector');
    assert(canSwitchView);
    if (view == _activeView) return;
    _activeView = view;
    notifyListeners();
    await _fetchDashboard();
  }

  Future<void> refresh() => _fetchDashboard();

  Future<void> logout() async {
    await _sessionService.clearSession(role: 'locker');
    await _sessionService.saveLastPortal('');
    debugPrint('[LockerDashboardVM] Session cleared — user logged out.');
  }

  // ── Private helpers ──────────────────────────────────────────────────────────

  Future<void> _fetchDashboard() async {
    _setLoading();

    try {
      final data = await _repository.getDashboard(
        view: _activeView,
        token: _token!,
      );

      _dashboardData = data;
      _state = LockerDashboardState.success;
      _errorMessage = null;
      notifyListeners();
    } on UnauthorisedException {
      _setError('Your session has expired. Please log in again.');
    } on BadRequestException catch (e) {
      _setError('Bad request: ${_friendlyMessage(e)}');
    } on FetchDataException catch (e) {
      _setError(_friendlyMessage(e));
    } catch (e, st) {
      _setError('Something went wrong. Please try again.');
      debugPrint('[LockerDashboardVM] Unexpected error: $e\n$st');
    }
  }

  void _setLoading() {
    _state = LockerDashboardState.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _state = LockerDashboardState.error;
    _errorMessage = message;
    notifyListeners();
    debugPrint('[LockerDashboardVM] Error: $message');
  }

  String _friendlyMessage(Object e) {
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