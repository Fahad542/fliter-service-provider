import 'package:flutter/material.dart';
import '../../../models/workshop_owner_models.dart';
import '../../../services/session_service.dart';

class OwnerDashboardViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Branch> _branches = [];
  List<Branch> get branches => _branches;

  Branch? _selectedBranch;
  Branch? get selectedBranch => _selectedBranch;

  List<OwnerEmployee> _employees = [];
  List<OwnerEmployee> get employees => _employees;

  String _ownerName = 'Admin';
  String get ownerName => _ownerName;

  OwnerDashboardViewModel() {
    init();
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    
    final user = await SessionService().getUser(role: 'owner');
    if (user != null && user.name != null) {
      _ownerName = user.name ?? 'Admin';
    }

    await Future.delayed(const Duration(seconds: 1));
    _branches = [
      Branch(id: '1', name: 'Riyadh Main', location: 'Riyadh, Olaya', vat: '300012345678', cr: '1010123456', status: 'active', salesMTD: 125000.0),
      Branch(id: '2', name: 'Jeddah Center', location: 'Jeddah, Tahliya', vat: '300012345679', cr: '4030123456', status: 'active', salesMTD: 98000.0),
      Branch(id: '3', name: 'Dammam Branch', location: 'Dammam, Khobar', vat: '300012345680', cr: '2050123456', status: 'active', salesMTD: 45000.0),
    ];

    _employees = [
      OwnerEmployee(id: '1', name: 'Ahmed Khan', mobile: '0501234567', branchId: '1', role: 'Technician', departmentIds: ['AC', 'Oil'], commissionPercent: 5.0, isAvailable: true),
      OwnerEmployee(id: '2', name: 'Mohamed Ali', mobile: '0507654321', branchId: '2', role: 'Cashier', departmentIds: [], commissionPercent: 0.0),
      OwnerEmployee(id: '3', name: 'Saeed Omar', mobile: '0509988776', branchId: '1', role: 'Manager', departmentIds: [], commissionPercent: 2.0),
    ];

    _isLoading = false;
    notifyListeners();
  }

  void setSelectedBranch(Branch? branch) {
    _selectedBranch = branch;
    notifyListeners();
  }

  // Aggregated or Per-Branch KPIs
  double get totalSalesToday {
    if (_selectedBranch != null) return _selectedBranch!.salesMTD / 25;
    return _branches.fold(0, (sum, b) => sum + (b.salesMTD / 25));
  }

  double get totalSalesMonth {
    if (_selectedBranch != null) return _selectedBranch!.salesMTD;
    return _branches.fold(0, (sum, b) => sum + b.salesMTD);
  }

  int get pendingInvoices {
    if (_selectedBranch != null) return 3;
    return 12;
  }

  int get lowStockAlerts {
    if (_selectedBranch != null) return 1;
    return _branches.length + 2;
  }

  int get pendingApprovals {
    if (_selectedBranch != null) return 2;
    return 8;
  }

  // Per-branch details
  int get activeOrders => _selectedBranch != null ? 14 : 0;
  double get technicianWorkload => _selectedBranch != null ? 0.85 : 0.0;
}
