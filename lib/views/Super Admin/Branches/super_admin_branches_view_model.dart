import 'package:flutter/material.dart';

class SuperAdminBranchesViewModel extends ChangeNotifier {
  bool isLoading = false;
  String searchQuery = '';
  String statusFilter = 'All';

  final List<Map<String, dynamic>> _allBranches = [
    {'id': 'BR-001', 'name': 'Riyadh Main', 'location': 'King Fahd Rd', 'manager': 'Ahmed Salem', 'staff': 15, 'revenue': 450000, 'status': 'Active'},
    {'id': 'BR-002', 'name': 'Jeddah Central', 'location': 'Tahlia St', 'manager': 'Omar K.', 'staff': 12, 'revenue': 380000, 'status': 'Active'},
    {'id': 'BR-003', 'name': 'Dammam East', 'location': 'Corniche Rd', 'manager': 'Sara M.', 'staff': 8, 'revenue': 120000, 'status': 'Active'},
    {'id': 'BR-004', 'name': 'Mecca Branch', 'location': 'Aziziyah', 'manager': 'Khalid S.', 'staff': 10, 'revenue': 200000, 'status': 'Maintenance'},
    {'id': 'BR-005', 'name': 'Medina Branch', 'location': 'Quba St', 'manager': 'Nouf B.', 'staff': 7, 'revenue': 95000, 'status': 'Closed'},
    {'id': 'BR-006', 'name': 'Tabuk North', 'location': 'Airport Rd', 'manager': 'Faisal T.', 'staff': 5, 'revenue': 75000, 'status': 'Maintenance'},
    {'id': 'BR-007', 'name': 'Abha South', 'location': 'Green Mountain', 'manager': 'Mona A.', 'staff': 6, 'revenue': 55000, 'status': 'Closed'},
    {'id': 'BR-008', 'name': 'Buraidah Hub', 'location': 'Main St', 'manager': 'Sami R.', 'staff': 9, 'revenue': 150000, 'status': 'Active'},
  ];

  List<Map<String, dynamic>> get filteredBranches {
    return _allBranches.where((branch) {
      final matchesSearch = branch['name'].toLowerCase().contains(searchQuery.toLowerCase()) || 
                            branch['id'].toLowerCase().contains(searchQuery.toLowerCase());
      final matchesStatus = statusFilter == 'All' || 
                            branch['status'].toString().toLowerCase() == statusFilter.toLowerCase();
      return matchesSearch && matchesStatus;
    }).toList();
  }

  Future<void> refresh() async {
    isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 600));
    isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    debugPrint('[VM] Setting status filter to: $status');
    statusFilter = status;
    notifyListeners();
  }

  void deleteBranch(String id) {
    _allBranches.removeWhere((b) => b['id'] == id);
    notifyListeners();
  }
}
