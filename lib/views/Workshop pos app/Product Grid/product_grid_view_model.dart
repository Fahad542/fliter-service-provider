import 'package:flutter/material.dart';
import '../../../../models/pos_product_model.dart';
import '../../../../services/locker_translation_mixin.dart';

class ProductGridViewModel extends ChangeNotifier with TranslatableMixin {
  static const String allFilter = 'All';
  String _selectedDepartment = allFilter;
  String _selectedCategory = allFilter;
  String _selectedSubCategory = allFilter;
  String _searchQuery = '';
  final TextEditingController searchController = TextEditingController();

  void bindSettingsViewModel(Listenable settingsViewModel) {
    bindLocaleRetranslation(settingsViewModel, retranslate);
  }

  Future<void> retranslate() async {
    notifyListeners();
  }

  String get selectedDepartment => _selectedDepartment;
  String get selectedCategory => _selectedCategory;
  String get selectedSubCategory => _selectedSubCategory;
  String get searchQuery => _searchQuery;

  void setDepartment(String department) {
    _selectedDepartment = department;
    _selectedCategory = allFilter;
    _selectedSubCategory = allFilter;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _selectedSubCategory = allFilter; // Reset subcategory when category changes
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
      final matchesCategory = _selectedCategory == allFilter || p.category == _selectedCategory;
      final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<String> getUniqueCategories(List<PosProduct> allProducts) {
    final cats = allProducts.map((p) => p.category).toSet().toList();
    cats.sort();
    return [allFilter, ...cats];
  }

  @override
  void dispose() {
    unbindLocaleRetranslation();
    searchController.dispose();
    super.dispose();
  }
}
