import 'package:flutter/material.dart';

class SuperAdminUsersViewModel extends ChangeNotifier {
  bool isLoading = false;
  String searchQuery = '';
  String roleFilter = 'All';

  final List<Map<String, dynamic>> _allUsers = [
    {'id': 'USR-101', 'name': 'Ahmed Salem', 'email': 'ahmed@filters.com', 'role': 'Manager', 'branch': 'Riyadh Main', 'status': 'Active', 'joined': 'Jan 12, 2024'},
    {'id': 'USR-102', 'name': 'Sami Ali', 'email': 'sami@filters.com', 'role': 'Technician', 'branch': 'Riyadh Main', 'status': 'Active', 'joined': 'Feb 05, 2024'},
    {'id': 'USR-103', 'name': 'Omar K.', 'email': 'omar@filters.com', 'role': 'Cashier', 'branch': 'Jeddah Central', 'status': 'Inactive', 'joined': 'Mar 15, 2024'},
    {'id': 'USR-104', 'name': 'Sara M.', 'email': 'sara@filters.com', 'role': 'Manager', 'branch': 'Dammam East', 'status': 'Active', 'joined': 'Jan 22, 2024'},
    {'id': 'USR-105', 'name': 'Fahad Y.', 'email': 'fahad@filters.com', 'role': 'Technician', 'branch': 'Mecca Branch', 'status': 'Active', 'joined': 'Apr 10, 2024'},
    {'id': 'USR-106', 'name': 'Mona S.', 'email': 'mona@filters.com', 'role': 'Support', 'branch': 'HQ', 'status': 'Active', 'joined': 'May 02, 2024'},
  ];

  List<Map<String, dynamic>> get filteredUsers {
    return _allUsers.where((user) {
      final matchesSearch = user['name'].toLowerCase().contains(searchQuery.toLowerCase()) || 
                            user['email'].toLowerCase().contains(searchQuery.toLowerCase());
      final matchesRole = roleFilter == 'All' || 
                          user['role'].toString().toLowerCase() == roleFilter.toLowerCase();
      return matchesSearch && matchesRole;
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

  void setRoleFilter(String role) {
    debugPrint('[VM] Setting role filter to: $role');
    roleFilter = role;
    notifyListeners();
  }

  void deleteUser(String id) {
    _allUsers.removeWhere((u) => u['id'] == id);
    notifyListeners();
  }
}
