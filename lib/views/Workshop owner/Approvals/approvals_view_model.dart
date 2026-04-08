import 'package:flutter/material.dart';
import '../../../data/repositories/owner_repository.dart';
import '../../../models/workshop_owner_models.dart';
import '../../../services/realtime_service.dart';
import '../../../services/session_service.dart';

class ApprovalsViewModel extends ChangeNotifier {
  final OwnerRepository ownerRepository;
  final SessionService sessionService;

  ApprovalsViewModel({
    required this.ownerRepository,
    required this.sessionService,
  });

  bool _isLoading = false;
  String? _approvingRequestId;
  String? _rejectingRequestId;
  String? _error;
  String _statusFilter = 'all';
  /// API: `fund` (top-ups), `expense` (cashier expenses), `all`.
  String _queueFilter = 'all';
  List<PettyCashRequestItem> _requests = [];
  String _currency = 'SAR';
  final RealtimeService _realtimeService = RealtimeService();
  bool _realtimeBound = false;

  bool get isLoading => _isLoading;
  String? get approvingRequestId => _approvingRequestId;
  String? get rejectingRequestId => _rejectingRequestId;

  /// True while any approve/reject API call is in flight (all card actions disabled).
  bool get hasApprovalActionInFlight =>
      _approvingRequestId != null || _rejectingRequestId != null;

  bool isApprovingRequest(String id) => _approvingRequestId == id;
  bool isRejectingRequest(String id) => _rejectingRequestId == id;

  String? get error => _error;
  String get statusFilter => _statusFilter;
  String get queueFilter => _queueFilter;
  List<PettyCashRequestItem> get requests => _requests;
  String get currency => _currency;

  Future<void> fetchRequests({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) throw Exception('Token not found');
      final response = await ownerRepository.getPettyCashRequests(
        token,
        status: _statusFilter == 'all' ? null : _statusFilter,
        queue: _queueFilter,
        limit: 100,
        offset: 0,
      );
      _requests = response.requests;
      _currency = response.currency;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approveRequest(String requestId) async {
    _approvingRequestId = requestId;
    notifyListeners();
    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) throw Exception('Token not found');
      final ok = await ownerRepository.approvePettyCashRequest(token, requestId);
      if (ok) {
        await fetchRequests(silent: true);
      }
      return ok;
    } catch (_) {
      return false;
    } finally {
      _approvingRequestId = null;
      notifyListeners();
    }
  }

  Future<bool> rejectRequest(String requestId, String rejectionReason) async {
    _rejectingRequestId = requestId;
    notifyListeners();
    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) throw Exception('Token not found');
      final ok = await ownerRepository.rejectPettyCashRequest(token, requestId, rejectionReason);
      if (ok) {
        await fetchRequests(silent: true);
      }
      return ok;
    } catch (_) {
      return false;
    } finally {
      _rejectingRequestId = null;
      notifyListeners();
    }
  }

  void setStatusFilter(String value) {
    _statusFilter = value;
    fetchRequests();
  }

  void setQueueFilter(String value) {
    if (_queueFilter == value) return;
    _queueFilter = value;
    fetchRequests();
  }

  Future<void> bindRealtime() async {
    if (_realtimeBound) return;
    final token = await sessionService.getToken(role: 'owner');
    if (token == null || token.isEmpty) return;
    _realtimeService.connect(token);
    _realtimeService.on(
      RealtimeService.eventWorkshopPettyCashUpdated,
      _onWorkshopPettyCashUpdated,
    );
    _realtimeBound = true;
  }

  void unbindRealtime() {
    if (!_realtimeBound) return;
    _realtimeService.off(
      RealtimeService.eventWorkshopPettyCashUpdated,
      _onWorkshopPettyCashUpdated,
    );
    _realtimeService.disconnect();
    _realtimeBound = false;
  }

  void _onWorkshopPettyCashUpdated(Map<String, dynamic> _) {
    fetchRequests(silent: true);
  }

  @override
  void dispose() {
    unbindRealtime();
    super.dispose();
  }
}
