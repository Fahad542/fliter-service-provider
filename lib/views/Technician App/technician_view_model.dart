import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/technician_models.dart';
import '../../data/repositories/technician_repository.dart';
import '../../services/session_service.dart';
import '../../services/realtime_service.dart';
import '../../models/technician_performance_model.dart';
import '../../models/technician_profile_model.dart';
import '../../models/technician_commission_history_model.dart';
import '../../models/technician_broadcast_model.dart';
import '../../models/auth_response_model.dart';
import '../../utils/toast_service.dart';

class TechAppViewModel extends ChangeNotifier {
  final TechnicianRepository _repository;
  final SessionService _sessionService;
  final RealtimeService _realtimeService = RealtimeService();

  Timer? _profileSocketDebounce;

  TechAppViewModel({
    required TechnicianRepository repository,
    required SessionService sessionService,
  })  : _repository = repository,
        _sessionService = sessionService {
    _initSocket();
  }

  Future<void> _initSocket() async {
    final token = await _sessionService.getToken(role: 'tech');
    if (token == null) return;
    _realtimeService.connect(token);
    _realtimeService.on(RealtimeService.eventTechnicianOrdersUpdated, _onAssignedOrdersUpdated);
    _realtimeService.on(RealtimeService.eventTechnicianBroadcastCreated, _onBroadcastCreated);
    _realtimeService.on(RealtimeService.eventTechnicianBroadcastClosed, _onBroadcastClosed);
    _realtimeService.on(RealtimeService.eventTechnicianProfileUpdated, _onProfileUpdatedSocket);
  }

  void _onProfileUpdatedSocket(Map<String, dynamic> _) {
    _profileSocketDebounce?.cancel();
    _profileSocketDebounce = Timer(const Duration(milliseconds: 350), () {
      fetchProfile(affectLoading: false);
    });
  }

  void _onAssignedOrdersUpdated(Map<String, dynamic> payload) {
    fetchAssignedOrders(affectLoading: false);
  }

  /// New broadcast(s) from cashier — sync with GET /technician/broadcasts.
  void _onBroadcastCreated(Map<String, dynamic> payload) {
    fetchBroadcasts();
  }

  /// Broadcast ended (e.g. reason `accepted` by another tech) — drop locally first, then re-fetch.
  void _onBroadcastClosed(Map<String, dynamic> payload) {
    final jobId = _parseJobIdFromSocketPayload(payload);
    if (jobId != null && jobId.isNotEmpty) {
      final before = _broadcasts.length;
      _broadcasts = _broadcasts.where((b) => b.jobId != jobId).toList();
      if (_broadcasts.length != before) {
        _restartBroadcastCountdown();
        notifyListeners();
      }
    }
    fetchBroadcasts();
  }

  /// Best-effort job id from socket payload (shape may vary by server).
  String? _parseJobIdFromSocketPayload(Map<String, dynamic> payload) {
    for (final key in ['jobId', 'job_id']) {
      final v = payload[key]?.toString();
      if (v != null && v.isNotEmpty) return v;
    }
    final job = payload['job'];
    if (job is Map) {
      final m = Map<String, dynamic>.from(job);
      final id = m['id']?.toString();
      if (id != null && id.isNotEmpty) return id;
    }
    final data = payload['data'];
    if (data is Map) {
      return _parseJobIdFromSocketPayload(Map<String, dynamic>.from(data));
    }
    final broadcast = payload['broadcast'];
    if (broadcast is Map) {
      return _parseJobIdFromSocketPayload(Map<String, dynamic>.from(broadcast));
    }
    return null;
  }

  @override
  void dispose() {
    _profileSocketDebounce?.cancel();
    _realtimeService.off(RealtimeService.eventTechnicianOrdersUpdated, _onAssignedOrdersUpdated);
    _realtimeService.off(RealtimeService.eventTechnicianBroadcastCreated, _onBroadcastCreated);
    _realtimeService.off(RealtimeService.eventTechnicianBroadcastClosed, _onBroadcastClosed);
    _realtimeService.off(RealtimeService.eventTechnicianProfileUpdated, _onProfileUpdatedSocket);
    _realtimeService.disconnect();
    _broadcastTimer?.cancel();
    super.dispose();
  }

  // --- Toggles (workshop / on-call / both / inactive via API dutyMode) ---
  bool _isWorkshopDuty = false;
  bool _isOnCallDuty = false;

  /// From login payload; profile may omit `technicianType` so we keep this for duty defaults.
  String? _sessionTechnicianType;

  /// So pull-to-refresh / re-init does not override duty toggles the user already changed.
  bool _initialDutyDefaultsApplied = false;

  /// When this changes (new login), duty defaults run again for the new account.
  String? _lastBootstrappedUserId;

  bool get isWorkshopDuty => _isWorkshopDuty;
  bool get isOnCallDuty => _isOnCallDuty;

  /// Presence is **offline** (cashier / system). Duty toggles are hidden until marked online again.
  /// Note: `dutyMode` may be `inactive` while offline — that does **not** mean the technician should
  /// see duty toggles; presence `offline` always shows the offline notice.
  bool get isOfflineLockedByCashier {
    final os = profile?.onlineStatus?.toString().toLowerCase().trim() ?? '';
    return os == 'offline';
  }

  static String _encodeDutyModeForType(
    String technicianType,
    bool workshop,
    bool onCall,
  ) {
    final t = technicianType.toLowerCase();
    if (t == 'workshop') {
      return workshop ? 'workshop' : 'inactive';
    }
    if (t == 'on_call') {
      return onCall ? 'on_call' : 'inactive';
    }
    if (!workshop && !onCall) return 'inactive';
    if (workshop && onCall) return 'workshop';
    if (workshop) return 'workshop';
    return 'on_call';
  }

  Future<void> toggleWorkshopDuty(BuildContext context, bool value) async {
    if (isOfflineLockedByCashier) {
      if (context.mounted) {
        ToastService.showError(
          context,
          'You are offline. Ask the cashier to mark you online.',
        );
      }
      return;
    }
    if (value == _isWorkshopDuty) return;
    final t =
        (_sessionTechnicianType ?? profile?.technicianType ?? 'workshop')
            .toLowerCase();
    var w = value;
    var o = _isOnCallDuty;
    if (t == 'on_call') return;
    if (t == 'workshop') o = false;
    if (t == 'both') {
      if (value) o = false;
    }

    _setLoading(true);
    try {
      final token = await _sessionService.getToken(role: 'tech');
      if (token != null) {
        final techType =
            _sessionTechnicianType ?? profile?.technicianType ?? 'workshop';
        final mode = _encodeDutyModeForType(techType, w, o);
        final res = await _repository.updateDutyStatus(token, mode);
        if (res != null) {
          _isWorkshopDuty = w;
          _isOnCallDuty = o;
        }
      }
    } catch (e) {
      debugPrint('Error updating duty status: $e');
      if (context.mounted) {
        final msg = e.toString().replaceFirst('Exception: ', '');
        ToastService.showError(context, msg);
      }
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> toggleOnCallDuty(BuildContext context, bool value) async {
    if (isOfflineLockedByCashier) {
      if (context.mounted) {
        ToastService.showError(
          context,
          'You are offline. Ask the cashier to mark you online.',
        );
      }
      return;
    }
    if (value == _isOnCallDuty) return;
    final t =
        (_sessionTechnicianType ?? profile?.technicianType ?? 'workshop')
            .toLowerCase();
    var w = _isWorkshopDuty;
    var o = value;
    if (t == 'workshop') return;
    if (t == 'on_call') w = false;
    if (t == 'both' && value) w = false;

    _setLoading(true);
    try {
      final token = await _sessionService.getToken(role: 'tech');
      if (token != null) {
        final techType =
            _sessionTechnicianType ?? profile?.technicianType ?? 'workshop';
        final mode = _encodeDutyModeForType(techType, w, o);
        final res = await _repository.updateDutyStatus(token, mode);
        if (res != null) {
          _isWorkshopDuty = w;
          _isOnCallDuty = o;
        }
      }
    } catch (e) {
      debugPrint('Error updating duty status: $e');
      if (context.mounted) {
        final msg = e.toString().replaceFirst('Exception: ', '');
        ToastService.showError(context, msg);
      }
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // --- Real-time Stats ---
  String technicianName = '';

  /// Shown under "Welcome Back," — prefers profile, then session name / email local-part.
  String get dashboardGreetingName {
    String? pick(String? s) {
      final t = s?.trim();
      return (t != null && t.isNotEmpty) ? t : null;
    }

    return pick(profile?.name) ??
        pick(technicianName) ??
        pick(profile?.email?.split('@').first) ??
        pick(profile?.mobile) ??
        'Technician';
  }
  int todayCompletedJobs = 0;
  double todayRevenue = 0.0;
  double todayCommission = 0.0;
  double weekCommission = 0.0;
  List<WeeklyOverview> weeklyOverview = [];
  TechnicianProfile? profile;

  // --- Commission History ---
  List<CommissionEntry> commissionHistory = [];
  bool isLoadingCommission = false;
  /// From last successful `/technician/commission-history` response (IANA id).
  String? commissionHistoryBusinessTimeZone;

  DateTime _commissionHistoryFrom = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );
  DateTime _commissionHistoryTo = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  DateTime get commissionHistoryFrom => _commissionHistoryFrom;
  DateTime get commissionHistoryTo => _commissionHistoryTo;

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// `yyyy-MM-dd` for range query / post-filter (matches API inclusive date bounds).
  static String _commissionRangeYmd(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  /// Post-filter: `from <= displayYmd <= to` as ISO date strings (calendar order).
  bool _commissionEntryInSelectedRange(CommissionEntry e) {
    final ymd = e.displayYmd.trim();
    if (ymd.length != 10) return false;
    final from = _commissionRangeYmd(_commissionHistoryFrom);
    final to = _commissionRangeYmd(_commissionHistoryTo);
    return from.compareTo(ymd) <= 0 && ymd.compareTo(to) <= 0;
  }

  static int _compareCommissionEntriesDescending(CommissionEntry a, CommissionEntry b) {
    final byYmd = b.displayYmd.compareTo(a.displayYmd);
    if (byYmd != 0) return byYmd;
    final da = DateTime.tryParse(a.date);
    final db = DateTime.tryParse(b.date);
    if (da != null && db != null) return db.compareTo(da);
    return b.date.compareTo(a.date);
  }

  void setCommissionHistoryFrom(DateTime d) {
    var next = _dateOnly(d);
    if (next.isAfter(_commissionHistoryTo)) {
      _commissionHistoryTo = next;
    }
    _commissionHistoryFrom = next;
    notifyListeners();
  }

  void setCommissionHistoryTo(DateTime d) {
    var next = _dateOnly(d);
    if (next.isBefore(_commissionHistoryFrom)) {
      _commissionHistoryFrom = next;
    }
    _commissionHistoryTo = next;
    notifyListeners();
  }

  Future<void> fetchCommissionHistory() async {
    isLoadingCommission = true;
    notifyListeners();
    try {
      final token = await _sessionService.getToken(role: 'tech');
      if (token != null) {
        final response = await _repository.getCommissionHistory(
          token,
          from: _commissionHistoryFrom,
          to: _commissionHistoryTo,
        );
        if (response.success) {
          commissionHistoryBusinessTimeZone = response.businessTimeZone;
          final list = response.entries
              .where(_commissionEntryInSelectedRange)
              .toList()
            ..sort(_compareCommissionEntriesDescending);
          commissionHistory = list;
        }
      }
    } catch (e) {
      debugPrint('Error fetching commission history: $e');
    } finally {
      isLoadingCommission = false;
      notifyListeners();
    }
  }

  // --- Orders ---
  List<TechOrder> _assignedOrders = [];
  List<TechOrder> get assignedOrders => _assignedOrders;

  /// True while GET assigned-orders is in flight (including `affectLoading: false` from init).
  bool _assignedOrdersRequestInFlight = false;
  bool get isAssignedOrdersRequestInFlight => _assignedOrdersRequestInFlight;

  /// Home dashboard (header + body) only after init finished and we have enough to avoid the "Technician" placeholder.
  bool get isTechDashboardReady =>
      _isBootstrapped &&
      !_isLoading &&
      (technicianName.trim().isNotEmpty ||
          (profile?.name?.trim().isNotEmpty ?? false) ||
          profile != null);

  TechOrder? _currentOrderDetail;
  TechOrder? get currentOrderDetail => _currentOrderDetail;

  // --- Notifications ---
  List<TechNotification> _notifications = [];
  List<TechNotification> get notifications => _notifications;
  int get unreadNotifications => _notifications.where((n) => !n.isRead).length;

  // --- Loading State ---
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isBootstrapped = false;
  bool get isBootstrapped => _isBootstrapped;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // --- Broadcast (GET /technician/broadcasts + socket refresh) ---
  List<TechBroadcast> _broadcasts = [];
  int _broadcastTimerSeconds = 0;
  int _broadcastRingTotalSecs = 300;
  int _broadcastWindowSeconds = 300;
  int _broadcastSoonThresholdSeconds = 60;
  int _broadcastActiveCount = 0;
  Timer? _broadcastTimer;
  final Set<String> _broadcastAcceptBusy = {};
  final Set<String> _broadcastRejectBusy = {};

  List<TechBroadcast> get broadcasts => List.unmodifiable(_broadcasts);
  TechBroadcast? get primaryBroadcast =>
      _broadcasts.isEmpty ? null : _broadcasts.first;

  bool get hasActiveBroadcast => _broadcasts.isNotEmpty;

  /// Full-screen overlay; dedicated [BroadcastTechnicianView] has its own Accept / Reject.
  bool get showBroadcastAcceptanceUi => false;
  int get broadcastTimerSeconds => _broadcastTimerSeconds;
  int get broadcastRingTotalSecs =>
      _broadcastRingTotalSecs <= 0 ? 300 : _broadcastRingTotalSecs;
  int get broadcastWindowSeconds =>
      _broadcastWindowSeconds <= 0 ? 300 : _broadcastWindowSeconds;
  int get broadcastSoonThresholdSeconds =>
      _broadcastSoonThresholdSeconds <= 0 ? 60 : _broadcastSoonThresholdSeconds;
  int get broadcastActiveCountMeta => _broadcastActiveCount;

  bool isBroadcastAcceptBusy(String jobId) =>
      _broadcastAcceptBusy.contains(jobId);

  bool isBroadcastRejectBusy(String jobId) =>
      _broadcastRejectBusy.contains(jobId);

  Duration remainingForBroadcast(TechBroadcast b) {
    final exp = b.expiresAt;
    if (exp != null) return exp.difference(DateTime.now());
    if (b.remainingSecondsBootstrap > 0) {
      return Duration(seconds: b.remainingSecondsBootstrap);
    }
    return Duration.zero;
  }

  bool broadcastExpired(TechBroadcast b) => remainingForBroadcast(b).isNegative;

  bool broadcastShowSoon(TechBroadcast b) {
    final r = remainingForBroadcast(b);
    if (r.isNegative) return false;
    if (b.serverIsSoon) return true;
    return r.inSeconds <= _broadcastSoonThresholdSeconds;
  }

  double broadcastProgress(TechBroadcast b) {
    final max = _broadcastWindowSeconds <= 0 ? 300 : _broadcastWindowSeconds;
    final left = remainingForBroadcast(b).inSeconds.clamp(0, max);
    return left / max;
  }

  Future<void> fetchBroadcasts() async {
    try {
      final token = await _sessionService.getToken(role: 'tech');
      if (token == null) return;
      final result = await _repository.getBroadcasts(token);
      _broadcasts = result.broadcasts;
      _broadcastWindowSeconds = result.windowSeconds;
      _broadcastSoonThresholdSeconds = result.soonThresholdSeconds;
      _broadcastActiveCount = result.activeCount;
      _restartBroadcastCountdown();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching broadcasts: $e');
    }
  }

  void _restartBroadcastCountdown() {
    _broadcastTimer?.cancel();
    _broadcastRingTotalSecs =
        _broadcastWindowSeconds > 0 ? _broadcastWindowSeconds : 300;

    void tickPrimaryTimer() {
      final current = primaryBroadcast;
      if (current == null) {
        _broadcastTimerSeconds = 0;
        return;
      }
      final left = remainingForBroadcast(current).inSeconds;
      _broadcastTimerSeconds = left < 0 ? 0 : left;
    }

    if (_broadcasts.isEmpty) {
      _broadcastTimerSeconds = 0;
      return;
    }

    tickPrimaryTimer();
    _broadcastTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      tickPrimaryTimer();
      notifyListeners();
      if (_broadcasts.isEmpty) {
        _broadcastTimer?.cancel();
        return;
      }
      final anyLive =
          _broadcasts.any((b) => !remainingForBroadcast(b).isNegative);
      if (!anyLive) {
        _broadcastTimer?.cancel();
        fetchBroadcasts();
      }
    });
  }

  Future<bool> acceptBroadcastJob(BuildContext context, String jobId) async {
    if (jobId.isEmpty ||
        _broadcastAcceptBusy.contains(jobId) ||
        _broadcastRejectBusy.contains(jobId)) {
      return false;
    }
    _broadcastAcceptBusy.add(jobId);
    notifyListeners();
    try {
      final token = await _sessionService.getToken(role: 'tech');
      if (token == null) return false;
      await _repository.acceptBroadcast(token, jobId);
      await fetchAssignedOrders(affectLoading: false);
      await fetchBroadcasts();
      if (context.mounted) {
        ToastService.showSuccess(context, 'Job accepted');
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, e.toString());
      }
      return false;
    } finally {
      _broadcastAcceptBusy.remove(jobId);
      notifyListeners();
    }
  }

  Future<bool> rejectBroadcastJob(BuildContext context, String jobId) async {
    if (jobId.isEmpty ||
        _broadcastAcceptBusy.contains(jobId) ||
        _broadcastRejectBusy.contains(jobId)) {
      return false;
    }
    _broadcastRejectBusy.add(jobId);
    notifyListeners();
    try {
      final token = await _sessionService.getToken(role: 'tech');
      if (token == null) return false;
      await _repository.rejectBroadcast(token, jobId);
      await fetchBroadcasts();
      if (context.mounted) {
        ToastService.showInfo(context, 'Broadcast declined');
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, e.toString());
      }
      return false;
    } finally {
      _broadcastRejectBusy.remove(jobId);
      notifyListeners();
    }
  }

  Future<bool> acceptCurrentBroadcast() async {
    final jobId = primaryBroadcast?.jobId;
    if (jobId == null) return false;
    _acceptingJobId = jobId;
    _acceptMessage = null;
    notifyListeners();
    try {
      final token = await _sessionService.getToken(role: 'tech');
      if (token == null) return false;
      await _repository.acceptBroadcast(token, jobId);
      await fetchAssignedOrders(affectLoading: false);
      await fetchBroadcasts();
      return true;
    } catch (e) {
      debugPrint('Error accepting broadcast: $e');
      _acceptMessage = e.toString();
      return false;
    } finally {
      _acceptingJobId = null;
      notifyListeners();
    }
  }

  Future<bool> rejectCurrentBroadcast() async {
    final jobId = primaryBroadcast?.jobId;
    if (jobId == null) return false;
    _cancellingJobId = jobId;
    _cancelMessage = null;
    notifyListeners();
    try {
      final token = await _sessionService.getToken(role: 'tech');
      if (token == null) return false;
      await _repository.rejectBroadcast(token, jobId);
      await fetchBroadcasts();
      return true;
    } catch (e) {
      debugPrint('Error rejecting broadcast: $e');
      _cancelMessage = e.toString();
      return false;
    } finally {
      _cancellingJobId = null;
      notifyListeners();
    }
  }

  Future<void> fetchTodayPerformance({bool affectLoading = true}) async {
    if (affectLoading) _setLoading(true);
    try {
      final token = await _sessionService.getToken(role: 'tech');
      if (token != null) {
        final performance = await _repository.getTodayPerformance(token);
        if (performance.success == true) {
          todayCompletedJobs = performance.completedJobs ?? 0;
          todayRevenue = performance.dailyRevenue ?? 0.0;
          todayCommission = performance.todayEarned ?? 0.0;
          weekCommission = performance.weeklyEarned ?? 0.0;
        }
      }
    } catch (e) {
      debugPrint('Error fetching today performance: $e');
    } finally {
      if (affectLoading) _setLoading(false);
    }
  }

  Future<void> fetchProfile({bool affectLoading = true}) async {
    if (affectLoading) _setLoading(true);
    try {
      final token = await _sessionService.getToken(role: 'tech');
      if (token != null) {
        final response = await _repository.getTechnicianProfile(token);
        if (response.success == true) {
          profile = response.profile;
          final fromProfile = profile?.name?.trim();
          if (fromProfile != null && fromProfile.isNotEmpty) {
            technicianName = fromProfile;
          } else if (technicianName.trim().isEmpty) {
            final emailLocal = profile?.email?.split('@').first.trim();
            if (emailLocal != null && emailLocal.isNotEmpty) {
              technicianName = emailLocal;
            } else {
              final mobile = profile?.mobile?.trim();
              if (mobile != null && mobile.isNotEmpty) {
                technicianName = mobile;
              }
            }
          }
          
          // Duty toggles: `dutyMode` is the source of truth when the API sends it.
          final dm =
              profile?.dutyMode?.toString().toLowerCase().trim() ?? '';
          if (dm == 'workshop') {
            _isWorkshopDuty = true;
            _isOnCallDuty = false;
          } else if (dm == 'on_call') {
            _isWorkshopDuty = false;
            _isOnCallDuty = true;
          } else if (dm == 'both') {
            _isWorkshopDuty = true;
            _isOnCallDuty = false;
          } else if (dm == 'inactive') {
            _isWorkshopDuty = false;
            _isOnCallDuty = false;
          } else if (dm == 'offline') {
            _isWorkshopDuty = false;
            _isOnCallDuty = false;
          } else {
            if (profile?.workshopDuty != null) {
              _isWorkshopDuty = profile!.workshopDuty!;
            } else {
              _isWorkshopDuty = false;
            }
            if (profile?.onCallDuty != null) {
              _isOnCallDuty = profile!.onCallDuty!;
            } else {
              _isOnCallDuty = false;
            }
          }

          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    } finally {
      if (affectLoading) _setLoading(false);
    }
  }

  /// Workshop-only (or on-call / both) accounts should show the matching duty ON when online.
  /// The profile API often returns `workshopDuty: false` while `technicianType` is `workshop`, which hid the toggle.
  void _applyDefaultDutyForTechnicianType() {
    final dm =
        profile?.dutyMode?.toString().toLowerCase().trim() ?? '';
    if (dm == 'workshop') {
      _isOnCallDuty = false;
      _isWorkshopDuty = true;
      notifyListeners();
      return;
    }
    if (dm == 'on_call') {
      _isWorkshopDuty = false;
      _isOnCallDuty = true;
      notifyListeners();
      return;
    }
    if (dm == 'both') {
      _isWorkshopDuty = true;
      _isOnCallDuty = false;
      notifyListeners();
      return;
    }
    if (dm == 'inactive' || dm == 'offline') {
      _isWorkshopDuty = false;
      _isOnCallDuty = false;
      notifyListeners();
      return;
    }

    final type = (profile?.technicianType ?? _sessionTechnicianType)
        ?.toLowerCase()
        .trim();
    if (type == null || type.isEmpty) return;

    if (type == 'workshop') {
      _isOnCallDuty = false;
      _isWorkshopDuty = true;
    } else if (type == 'on_call') {
      _isWorkshopDuty = false;
      _isOnCallDuty = true;
    } else if (type == 'both') {
      if (!_isWorkshopDuty && !_isOnCallDuty) {
        _isWorkshopDuty = true;
        _isOnCallDuty = false;
      }
    }
    notifyListeners();
  }

  /// Keeps server duty mode aligned when we default the toggles from `technicianType`.
  Future<void> _syncDutyStateToBackendAfterInitialDefault() async {
    try {
      final token = await _sessionService.getToken(role: 'tech');
      if (token == null) return;
      final techType =
          _sessionTechnicianType ?? profile?.technicianType ?? 'workshop';
      final mode =
          _encodeDutyModeForType(techType, _isWorkshopDuty, _isOnCallDuty);
      await _repository.updateDutyStatus(token, mode);
    } catch (e) {
      debugPrint('Initial duty backend sync: $e');
    }
  }

  Future<void> fetchDailyPerformance({bool affectLoading = true}) async {
    if (affectLoading) _setLoading(true);
    try {
      final token = await _sessionService.getToken(role: 'tech');
      if (token != null) {
        final performance = await _repository.getDailyPerformance(token);
        if (performance.success == true) {
          todayCompletedJobs = performance.totalJobs ?? 0;
          todayRevenue = performance.earned ?? 0.0;
          // Note: API response doesn't seem to have todayCommission directly, using earned for now or placeholder
          todayCommission = performance.earned ?? 0.0; 
          weeklyOverview = performance.weeklyOverview ?? [];
          
          // Calculate weekly commission total
          weekCommission = weeklyOverview.fold(0.0, (sum, item) => sum + (item.amount ?? 0.0));
        }
      }
    } catch (e) {
      debugPrint('Error fetching performance: $e');
    } finally {
      if (affectLoading) _setLoading(false);
    }
  }

  Future<void> fetchAssignedOrders({bool affectLoading = true}) async {
    _assignedOrdersRequestInFlight = true;
    notifyListeners();
    if (affectLoading) _setLoading(true);
    try {
      final token = await _sessionService.getToken(role: 'tech');
      if (token != null) {
        final response = await _repository.getAssignedOrders(token);
        if (response.success) {
          _assignedOrders = response.orders
              .where((o) => o.isEligibleForPostInvoiceAssignedList)
              .map((o) => TechOrder.fromAssignedOrder(o))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching assigned orders: $e');
    } finally {
      _assignedOrdersRequestInFlight = false;
      if (affectLoading) _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> fetchOrderDetails(String jobId) async {
    _setLoading(true);
    _currentOrderDetail = null; // Clear previous
    notifyListeners();
    try {
      final token = await _sessionService.getToken(role: 'tech');
      if (token != null) {
        final response = await _repository.getOrderDetails(token, jobId);
        if (response.success && response.order != null) {
          _currentOrderDetail = TechOrder.fromOrderDetails(response.order!);
        }
      }
    } catch (e) {
      debugPrint('Error fetching order details: $e');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  String? _completingJobId;
  String? get completingJobId => _completingJobId;

  String? _completeMessage;
  String? get completeMessage => _completeMessage;

  Future<bool> completeOrder(String jobId) async {
    _completingJobId = jobId;
    _completeMessage = null;
    notifyListeners();
    try {
      final token = await _sessionService.getToken(role: 'tech');
      if (token != null) {
        await _repository.completeOrder(token, jobId);
        // Refresh orders and current detail
        await fetchAssignedOrders();
        await fetchOrderDetails(jobId);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error completing order: $e');
      _completeMessage = e.toString();
      return false;
    } finally {
      _completingJobId = null;
      notifyListeners();
    }
  }

  String? _acceptingJobId;
  String? get acceptingJobId => _acceptingJobId;

  String? _acceptMessage;
  String? get acceptMessage => _acceptMessage;

  Future<bool> acceptOrder(String jobId) async {
    _acceptingJobId = jobId;
    _acceptMessage = null;
    notifyListeners();
    try {
      final token = await _sessionService.getToken(role: 'tech');
      if (token != null) {
        await _repository.acceptOrder(token, jobId);
        await fetchAssignedOrders();
        await fetchBroadcasts();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error accepting order: $e');
      _acceptMessage = e.toString();
      return false;
    } finally {
      _acceptingJobId = null;
      notifyListeners();
    }
  }

  String? _cancellingJobId;
  String? get cancellingJobId => _cancellingJobId;

  String? _cancelMessage;
  String? get cancelMessage => _cancelMessage;

  Future<bool> cancelOrder(String jobId) async {
    _cancellingJobId = jobId;
    _cancelMessage = null;
    notifyListeners();
    try {
      final token = await _sessionService.getToken(role: 'tech');
      if (token != null) {
        await _repository.cancelOrder(token, jobId);
        await fetchAssignedOrders();
        await fetchBroadcasts();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error cancelling order: $e');
      _cancelMessage = e.toString();
      return false;
    } finally {
      _cancellingJobId = null;
      notifyListeners();
    }
  }

  String? _startingJobId;
  String? get startingJobId => _startingJobId;

  String? _startMessage;
  String? get startMessage => _startMessage;

  Future<bool> startOrder(String jobId) async {
    _startingJobId = jobId;
    _startMessage = null;
    notifyListeners();
    try {
      final token = await _sessionService.getToken(role: 'tech');
      if (token != null) {
        await _repository.startOrder(token, jobId);
        await fetchAssignedOrders();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error starting order: $e');
      _startMessage = e.toString();
      return false;
    } finally {
      _startingJobId = null;
      notifyListeners();
    }
  }

  /// Duty toggles from persisted login payload (before GET profile).
  void _applySessionTechnicianDutyFromUser(User? user) {
    final t = user?.technician;
    final dm = t?.dutyMode?.toLowerCase().trim();
    if (dm != null && dm.isNotEmpty) {
      switch (dm) {
        case 'workshop':
          _isWorkshopDuty = true;
          _isOnCallDuty = false;
          return;
        case 'on_call':
          _isWorkshopDuty = false;
          _isOnCallDuty = true;
          return;
        case 'both':
          _isWorkshopDuty = true;
          _isOnCallDuty = false;
          return;
        case 'inactive':
          _isWorkshopDuty = false;
          _isOnCallDuty = false;
          return;
        case 'offline':
          _isWorkshopDuty = false;
          _isOnCallDuty = false;
          return;
      }
    }
    if (t?.workshopDuty == true && t?.onCallDuty != true) {
      _isWorkshopDuty = true;
      _isOnCallDuty = false;
      return;
    }
    if (t?.onCallDuty == true) {
      _isWorkshopDuty = false;
      _isOnCallDuty = true;
      return;
    }
    final type = t?.technicianType?.toLowerCase();
    if (type == 'workshop') {
      _isWorkshopDuty = true;
      _isOnCallDuty = false;
    } else if (type == 'on_call') {
      _isOnCallDuty = true;
      _isWorkshopDuty = false;
    } else if (type == 'both') {
      _isWorkshopDuty = true;
      _isOnCallDuty = false;
    }
  }

  // --- Initialize Logged In User ---
  Future<void> init() async {
    _isBootstrapped = false;
    _setLoading(true);
    final user = await _sessionService.getUser(role: 'tech');
    final uid = user?.id?.toString();
    if (uid != null && uid != _lastBootstrappedUserId) {
      _initialDutyDefaultsApplied = false;
      _lastBootstrappedUserId = uid;
    } else if (user == null) {
      _lastBootstrappedUserId = null;
    }
    if (user != null) {
      final n = user.name?.trim();
      if (n != null && n.isNotEmpty) {
        technicianName = n;
      } else {
        final email = user.email?.trim();
        if (email != null && email.isNotEmpty) {
          final local = email.split('@').first.trim();
          technicianName = local.isNotEmpty ? local : '';
        } else {
          technicianName = '';
        }
      }
      _applySessionTechnicianDutyFromUser(user);
      _sessionTechnicianType = user.technician?.technicianType;
    } else {
      _sessionTechnicianType = null;
    }
    notifyListeners();

    // 1) Profile + performance (duty comes from GET /technician/profile)
    await fetchProfile(affectLoading: false);
    await fetchTodayPerformance(affectLoading: false);
    if (!_initialDutyDefaultsApplied) {
      _applyDefaultDutyForTechnicianType();
      _initialDutyDefaultsApplied = true;
      if (!isOfflineLockedByCashier) {
        unawaited(_syncDutyStateToBackendAfterInitialDefault());
      }
    }

    _isBootstrapped = true;
    _setLoading(false);

    // 2) Secondary APIs in background (don't block dashboard UI)
    unawaited(fetchAssignedOrders(affectLoading: false));
    unawaited(fetchCommissionHistory());
    unawaited(fetchBroadcasts());
    
    // Notifications remain mock for now as per image focus
    _notifications = [
      TechNotification(
        id: '1',
        title: 'Commission Credited',
        message: 'SAR 45.00 added to your daily earnings for ORD-7721',
        timestamp: DateTime.now(),
        type: 'Commission',
      ),
    ];
    notifyListeners();
  }

  void clearSession() {
    _sessionTechnicianType = null;
    _lastBootstrappedUserId = null;
    _initialDutyDefaultsApplied = false;
    _isWorkshopDuty = false;
    _isOnCallDuty = false;
    _isBootstrapped = false;
    technicianName = '';
    todayCompletedJobs = 0;
    todayRevenue = 0.0;
    todayCommission = 0.0;
    weekCommission = 0.0;
    weeklyOverview = [];
    profile = null;
    commissionHistory = [];
    commissionHistoryBusinessTimeZone = null;
    final now = DateTime.now();
    _commissionHistoryFrom = DateTime(now.year, now.month, 1);
    _commissionHistoryTo = DateTime(now.year, now.month, now.day);
    _assignedOrders = [];
    _assignedOrdersRequestInFlight = false;
    _currentOrderDetail = null;
    _notifications = [];
    _broadcasts = [];
    _broadcastTimer?.cancel();
    _broadcastTimer = null;
    _broadcastTimerSeconds = 0;
    _isLoading = false;
    notifyListeners();
  }
}
