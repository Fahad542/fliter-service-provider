import 'package:flutter/material.dart';
import 'dart:async';
import '../../../models/workshop_owner_models.dart';
import '../../../services/session_service.dart';
import '../../../data/repositories/owner_repository.dart';
import '../../../services/owner_data_service.dart';
import '../../../services/realtime_service.dart';
import '../../../services/locker_translation_mixin.dart';

class OwnerDashboardViewModel extends ChangeNotifier with TranslatableMixin {
  final OwnerRepository ownerRepository;
  final SessionService sessionService;
  final OwnerDataService ownerDataService;

  bool _isLoading = false;
  bool get isLoading => _isLoading || ownerDataService.isLoadingBranches;

  final Map<String, String> _translatedBranchNames = {};
  final Map<String, String> _translatedBranchLocations = {};

  List<Branch> get branches => ownerDataService.branches;

  String branchDisplayName(Branch branch) =>
      _translatedBranchNames[branch.id] ?? branch.name;

  String branchDisplayLocation(Branch branch) =>
      _translatedBranchLocations[branch.id] ?? branch.location;

  Branch? _selectedBranch;
  Branch? get selectedBranch => _selectedBranch;

  List<OwnerEmployee> _employees = [];
  List<OwnerEmployee> get employees => _employees;

  String _rawOwnerName = '';
  String _ownerName = '';
  String get ownerName => _ownerName;

  OwnerDashboardResponse? _dashboardData;
  OwnerDashboardResponse? get dashboardData => _dashboardData;
  List<PettyCashRequestItem> _rawPendingPettyCashRequests = [];
  List<PettyCashRequestItem> _pendingPettyCashRequests = [];
  List<PettyCashRequestItem> get pendingPettyCashRequests =>
      _pendingPettyCashRequests;
  String _pettyCashCurrency = 'SAR';
  String get pettyCashCurrency => _pettyCashCurrency;
  String? _approvingRequestId;
  String? _rejectingRequestId;
  bool get hasApprovalActionInFlight =>
      _approvingRequestId != null || _rejectingRequestId != null;
  bool isApprovingRequest(String id) => _approvingRequestId == id;
  bool isRejectingRequest(String id) => _rejectingRequestId == id;
  final RealtimeService _realtimeService = RealtimeService();
  bool _realtimeBound = false;

  OwnerDashboardViewModel({
    required this.ownerRepository,
    required this.sessionService,
    required this.ownerDataService,
  }) {
    ownerDataService.addListener(notifyListeners);
    Future.microtask(() => init());
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    
    final user = await sessionService.getUser(role: 'owner');
    _rawOwnerName = user?.name ?? '';
    _ownerName = await tNullable(_rawOwnerName) ?? _rawOwnerName;

    String? token = await sessionService.getToken(role: 'owner');
    if (token != null) {
      if (branches.isEmpty) {
        await ownerDataService.fetchBranches();
      }
      await _translateBranches();
      await _fetchDashboardData(token);
      await _fetchPendingPettyCashRequests(token);
      await _bindRealtime(token);
    }


    _employees = [
      OwnerEmployee(id: '1', name: 'Ahmed Khan', mobile: '0501234567', branchId: '1', role: 'Technician', departmentIds: ['AC', 'Oil'], commissionPercent: 5.0, isAvailable: true),
      OwnerEmployee(id: '2', name: 'Mohamed Ali', mobile: '0507654321', branchId: '2', role: 'Cashier', departmentIds: [], commissionPercent: 0.0),
      OwnerEmployee(id: '3', name: 'Saeed Omar', mobile: '0509988776', branchId: '1', role: 'Manager', departmentIds: [], commissionPercent: 2.0),
    ];

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchDashboardData(String token) async {
    try {
      final response = await ownerRepository.getDashboardData(token, branchId: _selectedBranch?.id);
      if (response != null && response['success'] == true) {
        _dashboardData = OwnerDashboardResponse.fromJson(response);
      }
    } catch (e) {
      debugPrint('Error fetching dashboard KPIs: $e');
    }
  }

  Future<void> _fetchPendingPettyCashRequests(String token) async {
    try {
      final response = await ownerRepository.getPettyCashRequests(
        token,
        queue: 'all',
        status: 'pending',
        branchId: _selectedBranch?.id,
        limit: 20,
        offset: 0,
      );
      _rawPendingPettyCashRequests = response.requests;
      _pendingPettyCashRequests =
          await translatePettyCashRequests(_rawPendingPettyCashRequests);
      _pettyCashCurrency = response.currency;
    } catch (e) {
      debugPrint('Error fetching pending petty-cash requests: $e');
      _rawPendingPettyCashRequests = [];
      _pendingPettyCashRequests = [];
    }
  }

  Future<void> setSelectedBranch(Branch? branch) async {
    _selectedBranch = branch;
    _isLoading = true;
    notifyListeners();
    
    String? token = await sessionService.getToken(role: 'owner');
    if (token != null) {
      await _fetchDashboardData(token);
      await _fetchPendingPettyCashRequests(token);
    }
    
    _isLoading = false;
    notifyListeners();
  }

  // Dashboard KPIs
  double get totalSalesToday => _dashboardData?.totalSalesToday ?? 0.0;
  double get totalSalesMonth => _dashboardData?.totalSalesThisMonth ?? 0.0;
  int get pendingInvoices => _dashboardData?.pendingInvoicesCount ?? 0;
  int get lowStockAlerts => _dashboardData?.lowStockAlertsCount ?? 0;
  
  // Pending Approvals (not in dashboard API yet, mocked)
  int get pendingApprovals {
    return _pendingPettyCashRequests.length;
  }

  // Per-branch details (not in dashboard API yet, mocked)
  int get activeOrders => _selectedBranch != null ? 14 : 0;
  double get technicianWorkload => _selectedBranch != null ? 0.85 : 0.0;

  Future<void> _bindRealtime(String token) async {
    if (_realtimeBound) return;
    _realtimeService.connect(token);
    _realtimeService.on(
      RealtimeService.eventWorkshopPettyCashUpdated,
      _onWorkshopPettyCashUpdated,
    );
    _realtimeBound = true;
  }

  void _unbindRealtime() {
    if (!_realtimeBound) return;
    _realtimeService.off(
      RealtimeService.eventWorkshopPettyCashUpdated,
      _onWorkshopPettyCashUpdated,
    );
    _realtimeService.disconnect();
    _realtimeBound = false;
  }

  void _onWorkshopPettyCashUpdated(Map<String, dynamic> _) async {
    final token = await sessionService.getToken(role: 'owner');
    if (token == null) return;
    await _fetchPendingPettyCashRequests(token);
    notifyListeners();
  }


  Future<void> _translateBranches() async {
    _translatedBranchNames.clear();
    _translatedBranchLocations.clear();
    for (final branch in branches) {
      if (branch.name.trim().isNotEmpty) {
        _translatedBranchNames[branch.id] = await t(branch.name);
      }
      if (branch.location.trim().isNotEmpty) {
        _translatedBranchLocations[branch.id] = await t(branch.location);
      }
    }
  }

  Future<void> onLocaleChanged() async {
    _ownerName = await tNullable(_rawOwnerName) ?? _rawOwnerName;
    await _translateBranches();
    _pendingPettyCashRequests =
        await translatePettyCashRequests(_rawPendingPettyCashRequests);
    notifyListeners();
  }

  Future<bool> approvePettyCashRequest(String requestId) async {
    _approvingRequestId = requestId;
    notifyListeners();
    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) return false;
      final ok =
          await ownerRepository.approvePettyCashRequest(token, requestId);
      if (ok) {
        await _fetchPendingPettyCashRequests(token);
      }
      return ok;
    } catch (_) {
      return false;
    } finally {
      _approvingRequestId = null;
      notifyListeners();
    }
  }

  Future<bool> rejectPettyCashRequest(
    String requestId,
    String rejectionReason,
  ) async {
    _rejectingRequestId = requestId;
    notifyListeners();
    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) return false;
      final ok = await ownerRepository.rejectPettyCashRequest(
        token,
        requestId,
        rejectionReason,
      );
      if (ok) {
        await _fetchPendingPettyCashRequests(token);
      }
      return ok;
    } catch (_) {
      return false;
    } finally {
      _rejectingRequestId = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _unbindRealtime();
    ownerDataService.removeListener(notifyListeners);
    super.dispose();
  }
}
