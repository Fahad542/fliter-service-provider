import 'package:flutter/material.dart';
import '../../../../models/pos_product_model.dart';

class ProductGridViewModel extends ChangeNotifier {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController searchController = TextEditingController();

  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    searchController.clear();
    _searchQuery = '';
    notifyListeners();
  }

  List<PosProduct> getFilteredProducts(List<PosProduct> allProducts) {
    return allProducts.where((p) {
      final matchesCategory = _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<String> getUniqueCategories(List<PosProduct> allProducts) {
    final cats = allProducts.map((p) => p.category).toSet().toList();
    cats.sort();
    return ['All', ...cats];
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
