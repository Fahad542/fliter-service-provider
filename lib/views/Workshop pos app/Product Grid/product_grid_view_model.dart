import 'package:flutter/material.dart';
import '../../../../models/pos_product_model.dart';

class ProductGridViewModel extends ChangeNotifier {
  String _selectedDepartment = 'All';
  String _selectedCategory = 'All';
  String _selectedSubCategory = 'All';
  String _searchQuery = '';
  final TextEditingController searchController = TextEditingController();

  String get selectedDepartment => _selectedDepartment;
  String get selectedCategory => _selectedCategory;
  String get selectedSubCategory => _selectedSubCategory;
  String get searchQuery => _searchQuery;

  void setDepartment(String department) {
    _selectedDepartment = department;
    _selectedCategory = 'All';
    _selectedSubCategory = 'All';
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _selectedSubCategory = 'All'; // Reset subcategory when category changes
    notifyListeners();
  }

  void setSubCategory(String subCategory) {
    _selectedSubCategory = subCategory;
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
