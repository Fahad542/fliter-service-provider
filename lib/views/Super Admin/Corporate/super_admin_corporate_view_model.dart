import 'package:flutter/material.dart';

class SuperAdminCorporateViewModel extends ChangeNotifier {
  bool isLoading = false;
  String searchQuery = '';
  String statusFilter = 'All';

  final List<Map<String, dynamic>> _allClients = [
    {
      'id': 'CORP-01',
      'companyName': 'Aramco Logistics',
      'contactPerson': 'Faisal N.',
      'email': 'procurement@aramco.com',
      'phone': '+966 50 123 4567',
      'balance': 45500.0,
      'pendingInvoices': 3,
      'status': 'Active',
      'logo': 'A',
    },
    {
      'id': 'CORP-02',
      'companyName': 'STC Fleet',
      'contactPerson': 'Saud M.',
      'email': 'fleet@stc.com.sa',
      'phone': '+966 55 987 6543',
      'balance': 12000.0,
      'pendingInvoices': 1,
      'status': 'Active',
      'logo': 'S',
    },
    {
      'id': 'CORP-03',
      'companyName': 'AlBaik Operations',
      'contactPerson': 'Omar H.',
      'email': 'ops@albaik.com',
      'phone': '+966 54 321 0987',
      'balance': 0.0,
      'pendingInvoices': 0,
      'status': 'Inactive',
      'logo': 'A',
    },
    {
      'id': 'CORP-04',
      'companyName': 'Saudi Airlines',
      'contactPerson': 'Khalid A.',
      'email': 'maintenance@saudia.com',
      'phone': '+966 56 111 2222',
      'balance': 85000.0,
      'pendingInvoices': 5,
      'status': 'Active',
      'logo': 'S',
    },
  ];

  List<Map<String, dynamic>> get filteredClients {
    return _allClients.where((client) {
      final matchesSearch = client['companyName'].toString().toLowerCase().contains(searchQuery.toLowerCase()) || 
                            client['id'].toString().toLowerCase().contains(searchQuery.toLowerCase());
      final matchesStatus = statusFilter == 'All' || 
                            client['status'].toString().toLowerCase() == statusFilter.toLowerCase();
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

  void deleteClient(String id) {
    _allClients.removeWhere((c) => c['id'] == id);
    notifyListeners();
  }
}
