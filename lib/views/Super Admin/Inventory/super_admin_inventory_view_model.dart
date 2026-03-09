import 'package:flutter/material.dart';

class SuperAdminInventoryViewModel extends ChangeNotifier {
  bool isLoading = false;
  String searchQuery = '';
  String categoryFilter = 'All';

  final List<Map<String, dynamic>> _allProducts = [
    {'id': 'PRD-001', 'name': 'Engine Oil 5W-40', 'sku': 'OIL-5W40-01', 'category': 'Oils & Fluids', 'price': 150.0, 'stock': 120, 'minStock': 20},
    {'id': 'PRD-002', 'name': 'Premium Air Filter XT', 'sku': 'FLT-AIR-02', 'category': 'Filters', 'price': 85.0, 'stock': 5, 'minStock': 10},
    {'id': 'PRD-003', 'name': 'Ceramic Brake Pads', 'sku': 'BRK-PAD-03', 'category': 'Brakes', 'price': 220.0, 'stock': 0, 'minStock': 15},
    {'id': 'PRD-004', 'name': 'Spark Plugs Set (4)', 'sku': 'SPK-PLG-04', 'category': 'Ignition', 'price': 120.0, 'stock': 45, 'minStock': 20},
    {'id': 'PRD-005', 'name': 'Windshield Wipers 24"', 'sku': 'WIP-24-05', 'category': 'Accessories', 'price': 65.0, 'stock': 8, 'minStock': 10},
    {'id': 'PRD-006', 'name': 'Battery 12V 70Ah', 'sku': 'BAT-70A-06', 'category': 'Electrical', 'price': 450.0, 'stock': 32, 'minStock': 5},
  ];

  List<Map<String, dynamic>> get filteredProducts {
    return _allProducts.where((product) {
      final matchesSearch = product['name'].toLowerCase().contains(searchQuery.toLowerCase()) || 
                            product['sku'].toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory = categoryFilter == 'All' || 
                              product['category'].toString().toLowerCase() == categoryFilter.toLowerCase();
      return matchesSearch && matchesCategory;
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

  void setCategoryFilter(String category) {
    debugPrint('[VM] Setting category filter to: $category');
    categoryFilter = category;
    notifyListeners();
  }

  void deleteProduct(String id) {
    _allProducts.removeWhere((p) => p['id'] == id);
    notifyListeners();
  }
}
