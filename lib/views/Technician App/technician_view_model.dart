import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/technician_models.dart';
import '../../data/repositories/technician_repository.dart';
import '../../services/session_service.dart';
import '../../services/realtime_service.dart';
import '../../models/technician_performance_model.dart';
import '../../models/technician_today_performance_model.dart';
import '../../models/technician_profile_model.dart';
import '../../models/technician_commission_history_model.dart';
import '../../models/technician_broadcast_model.dart';
import '../../utils/toast_service.dart';

class TechAppViewModel extends ChangeNotifier {
  final TechnicianRepository _repository;
  final SessionService _sessionService;
  final RealtimeService _realtimeService = RealtimeService();

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
    _realtimeService.off(RealtimeService.eventTechnicianOrdersUpdated, _onAssignedOrdersUpdated);
    _realtimeService.off(RealtimeService.eventTechnicianBroadcastCreated, _onBroadcastCreated);
    _realtimeService.off(RealtimeService.eventTechnicianBroadcastClosed, _onBroadcastClosed);
    _realtimeService.disconnect();
    _broadcastTimer?.cancel();
    super.dispose();
  }

  // --- Toggles ---
  bool _isWorkshopDuty = false;
  bool _isOnCallDuty = false;
  bool _isOnline = true;
  bool _isOnlineUpdating = false;
  bool _cachedWorkshopDutyBeforeOffline = false;
  bool _cachedOnCallDutyBeforeOffline = false;

  bool get isWorkshopDuty => _isWorkshopDuty;
  bool get isOnCallDuty => _isOnCallDuty;
  bool get isOnline => _isOnline;
  bool get isOnlineUpdating => _isOnlineUpdating;

  Future<void> fetchOnlineStatus() async {
    try {
      final token = await _sessionService.getToken(role: 'tech');
      if (token == null) return;
      final response = await _repository.getOnlineStatus(token);
      if (response is! Map<String, dynamic>) return;

      final rawStatus =
          response['status'] ??
          response['onlineStatus'] ??
          response['technicianStatus']?['status'] ??
          response['data']?['status'] ??
          response['data']?['technicianStatus']?['status'];
      final status = rawStatus?.toString().toLowerCase();
      if (status == 'online' || status == 'available') {
        _isOnline = true;
      } else if (status == 'offline') {
        _isOnline = false;
        _cachedWorkshopDutyBeforeOffline = _isWorkshopDuty;
        _cachedOnCallDutyBeforeOffline = _isOnCallDuty;
        _isWorkshopDuty = false;
        _isOnCallDuty = false;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching online status: $e');
    }
  }

  Future<void> updateOnlineStatus(bool value) async {
    if (value == _isOnline || _isOnlineUpdating) return;
    _isOnlineUpdating = true;
    notifyListeners();
    try {
      final token = await _sessionService.getToken(role: 'tech');
      if (token != null) {
        final res = await _repository.updateOnlineStatus(
          token,
          value ? 'online' : 'offline',
        );
        if (res != null) {
          final wasOnline = _isOnline;
          _isOnline = value;
          if (!value) {
            // Cache duty state before going offline, so we can restore it later.
            _cachedWorkshopDutyBeforeOffline = _isWorkshopDuty;
            _cachedOnCallDutyBeforeOffline = _isOnCallDuty;
            _isWorkshopDuty = false;
            _isOnCallDuty = false;
          } else if (!wasOnline) {
            // Restore last known duty state when coming back online.
            _isWorkshopDuty = _cachedWorkshopDutyBeforeOffline;
            _isOnCallDuty = _cachedOnCallDutyBeforeOffline;

            // Keep backend duty-mode in sync with restored local state.
            if (_isWorkshopDuty && !_isOnCallDuty) {
              await _repository.updateDutyStatus(token, 'workshop');
            } else if (_isOnCallDuty && !_isWorkshopDuty) {
              await _repository.updateDutyStatus(token, 'on_call');
            } else {
              await _repository.updateDutyStatus(token, 'offline');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error updating online status: $e');
    } finally {
      _isOnlineUpdating = false;
      notifyListeners();
    }
  }

  Future<void> toggleWorkshopDuty(BuildContext context, bool value) async {
    if (!_isOnline) return;
    if (value == _isWorkshopDuty) return;
    
    _setLoading(true);
    try {
      final token = await _sessionService.getToken(role: 'tech');
      if (token != null) {
        // use 'offline' if turning off, otherwise 'workshop'
        final res = await _repository.updateDutyStatus(token, value ? 'workshop' : 'offline');
        if (res != null) {
          _isWorkshopDuty = value;
          if (value) _isOnCallDuty = false;
          _cachedWorkshopDutyBeforeOffline = _isWorkshopDuty;
          _cachedOnCallDutyBeforeOffline = _isOnCallDuty;
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
    if (!_isOnline) return;
    if (value == _isOnCallDuty) return;

    _setLoading(true);
    try {
      final token = await _sessionService.getToken(role: 'tech');
      if (token != null) {
        // use 'offline' if turning off, otherwise 'on_call'
        final res = await _repository.updateDutyStatus(token, value ? 'on_call' : 'offline');
        if (res != null) {
          _isOnCallDuty = value;
          if (value) _isWorkshopDuty = false;
          _cachedWorkshopDutyBeforeOffline = _isWorkshopDuty;
          _cachedOnCallDutyBeforeOffline = _isOnCallDuty;
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
  int todayCompletedJobs = 0;
  double todayRevenue = 0.0;
  double todayCommission = 0.0;
  double weekCommission = 0.0;
  List<WeeklyOverview> weeklyOverview = [];
  TechnicianProfile? profile;

  // --- Commission History ---
  List<CommissionEntry> commissionHistory = [];
  bool isLoadingCommission = false;
  DateTime selectedCommissionMonth = DateTime.now();

  List<DateTime> get availableCommissionMonths {
    final now = DateTime.now();
    return List.generate(3, (index) => DateTime(now.year, now.month - index));
  }

  void selectCommissionMonth(DateTime month) {
    selectedCommissionMonth = month;
    fetchCommissionHistory(month: month.month, year: month.year);
  }

  Future<void> fetchCommissionHistory({int? month, int? year}) async {
    isLoadingCommission = true;
    notifyListeners();
    try {
      final token = await _sessionService.getToken(role: 'tech');
      if (token != null) {
        final m = month ?? selectedCommissionMonth.month;
        final y = year ?? selectedCommissionMonth.year;
        final response = await _repository.getCommissionHistory(token, m, y);
        if (response.success) {
          commissionHistory = response.entries;
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
  DateTime? _broadcastCountdownStartedAt;
  Timer? _broadcastTimer;

  List<TechBroadcast> get broadcasts => List.unmodifiable(_broadcasts);
  TechBroadcast? get primaryBroadcast =>
      _broadcasts.isEmpty ? null : _broadcasts.first;

  bool get hasActiveBroadcast => _broadcasts.isNotEmpty;
  int get broadcastTimerSeconds => _broadcastTimerSeconds;
  int get broadcastRingTotalSecs =>
      _broadcastRingTotalSecs <= 0 ? 300 : _broadcastRingTotalSecs;

  Future<void> fetchBroadcasts() async {
    try {
      final token = await _sessionService.getToken(role: 'tech');
      if (token == null) return;
      final list = await _repository.getBroadcasts(token);
      _broadcasts = list;
      _restartBroadcastCountdown();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching broadcasts: $e');
    }
  }

  void _restartBroadcastCountdown() {
    _broadcastTimer?.cancel();
    final b = primaryBroadcast;
    if (b == null) {
      _broadcastTimerSeconds = 0;
      _broadcastRingTotalSecs = 300;
      _broadcastCountdownStartedAt = null;
      return;
    }

    if (b.expiresAt != null) {
      final left = b.expiresAt!.difference(DateTime.now()).inSeconds;
      _broadcastTimerSeconds = left < 0 ? 0 : left;
      _broadcastRingTotalSecs = _broadcastTimerSeconds > 0 ? _broadcastTimerSeconds : 300;
    } else {
      _broadcastCountdownStartedAt = DateTime.now();
      _broadcastTimerSeconds = 300;
      _broadcastRingTotalSecs = 300;
    }

    _broadcastTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final current = primaryBroadcast;
      if (current == null) {
        _broadcastTimer?.cancel();
        return;
      }
      if (current.expiresAt != null) {
        _broadcastTimerSeconds =
            current.expiresAt!.difference(DateTime.now()).inSeconds;
        if (_broadcastTimerSeconds < 0) _broadcastTimerSeconds = 0;
      } else if (_broadcastCountdownStartedAt != null) {
        final elapsed =
            DateTime.now().difference(_broadcastCountdownStartedAt!).inSeconds;
        _broadcastTimerSeconds = (300 - elapsed).clamp(0, 300);
      }
      notifyListeners();
      if (_broadcastTimerSeconds <= 0) {
        _broadcastTimer?.cancel();
        fetchBroadcasts();
      }
    });
  }

  Future<bool> acceptCurrentBroadcast() async {
    final jobId = primaryBroadcast?.jobId;
    if (jobId == null) return false;
    return acceptOrder(jobId);
  }

  Future<bool> rejectCurrentBroadcast() async {
    final jobId = primaryBroadcast?.jobId;
    if (jobId == null) return false;
    return cancelOrder(jobId);
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
          technicianName = profile?.name ?? technicianName;
          
          // Sync duty status switches - prioritize dutyMode if booleans are null
          if (profile?.workshopDuty != null) {
            _isWorkshopDuty = profile!.workshopDuty!;
          } else {
            _isWorkshopDuty = profile?.dutyMode == 'workshop';
          }
          
          if (profile?.onCallDuty != null) {
            _isOnCallDuty = profile!.onCallDuty!;
          } else {
            _isOnCallDuty = profile?.dutyMode == 'on_call';
          }

          final status = profile?.onlineStatus?.toLowerCase();
          if (status == 'online') {
            _isOnline = true;
          } else if (status == 'offline') {
            _isOnline = false;
            _cachedWorkshopDutyBeforeOffline = _isWorkshopDuty;
            _cachedOnCallDutyBeforeOffline = _isOnCallDuty;
            _isWorkshopDuty = false;
            _isOnCallDuty = false;
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
    if (affectLoading) _setLoading(true);
    try {
      final token = await _sessionService.getToken(role: 'tech');
      if (token != null) {
        final response = await _repository.getAssignedOrders(token);
        if (response.success) {
          _assignedOrders = response.orders.map((o) => TechOrder.fromAssignedOrder(o)).toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching assigned orders: $e');
    } finally {
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

  // --- Initialize Logged In User ---
  Future<void> init() async {
    _isBootstrapped = false;
    _setLoading(true);
    final user = await _sessionService.getUser(role: 'tech');
    if (user != null) {
      technicianName = user.name ?? '';
      
      // Set initial duty status based on technician type
      if (user.technician?.technicianType == 'workshop') {
        _isWorkshopDuty = true;
        _isOnCallDuty = false;
      } else if (user.technician?.technicianType == 'on_call') {
        _isOnCallDuty = true;
        _isWorkshopDuty = false;
      } else if (user.technician?.technicianType == 'both') {
        _isWorkshopDuty = true;
        _isOnCallDuty = false;
      }
    }

    // 1) Critical APIs first (faster first paint)
    await Future.wait([
      fetchProfile(affectLoading: false),
      fetchOnlineStatus(),
      fetchTodayPerformance(affectLoading: false),
    ]);

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
    _isWorkshopDuty = false;
    _isOnCallDuty = false;
    _isOnline = true;
    _isOnlineUpdating = false;
    _isBootstrapped = false;
    _cachedWorkshopDutyBeforeOffline = false;
    _cachedOnCallDutyBeforeOffline = false;
    technicianName = '';
    todayCompletedJobs = 0;
    todayRevenue = 0.0;
    todayCommission = 0.0;
    weekCommission = 0.0;
    weeklyOverview = [];
    profile = null;
    commissionHistory = [];
    _assignedOrders = [];
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
