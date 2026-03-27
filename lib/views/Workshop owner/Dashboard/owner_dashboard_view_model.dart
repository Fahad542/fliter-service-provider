import 'package:flutter/material.dart';
import 'dart:async';
import '../../../models/workshop_owner_models.dart';
import '../../../services/session_service.dart';
import '../../../data/repositories/owner_repository.dart';
import '../../../services/owner_data_service.dart';

class OwnerDashboardViewModel extends ChangeNotifier {
  final OwnerRepository ownerRepository;
  final SessionService sessionService;
  final OwnerDataService ownerDataService;

  bool _isLoading = false;
  bool get isLoading => _isLoading || ownerDataService.isLoadingBranches;

  List<Branch> get branches => ownerDataService.branches;

  Branch? _selectedBranch;
  Branch? get selectedBranch => _selectedBranch;

  List<OwnerEmployee> _employees = [];
  List<OwnerEmployee> get employees => _employees;

  String _ownerName = 'Admin';
  String get ownerName => _ownerName;

  OwnerDashboardResponse? _dashboardData;
  OwnerDashboardResponse? get dashboardData => _dashboardData;

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
    if (user != null && user.name != null) {
      _ownerName = user.name ?? 'Admin';
    }

    String? token = await sessionService.getToken(role: 'owner');
    if (token != null) {
      if (branches.isEmpty) {
        await ownerDataService.fetchBranches();
      }
      await _fetchDashboardData(token);
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

  Future<void> setSelectedBranch(Branch? branch) async {
    _selectedBranch = branch;
    _isLoading = true;
    notifyListeners();
    
    String? token = await sessionService.getToken(role: 'owner');
    if (token != null) {
      await _fetchDashboardData(token);
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
    if (_selectedBranch != null) return 2;
    return 8;
  }

  // Per-branch details (not in dashboard API yet, mocked)
  int get activeOrders => _selectedBranch != null ? 14 : 0;
  double get technicianWorkload => _selectedBranch != null ? 0.85 : 0.0;

  @override
  void dispose() {
    ownerDataService.removeListener(notifyListeners);
    super.dispose();
  }
}
