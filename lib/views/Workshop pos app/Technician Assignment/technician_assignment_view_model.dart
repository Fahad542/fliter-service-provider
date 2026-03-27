import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../models/pos_technician_model.dart';
import '../Navbar/pos_shell.dart';


class TechnicianAssignmentViewModel extends ChangeNotifier {
  String _searchQuery = '';
  final Set<String> _selectedTechnicianIds = {};
  final List<String> _selectedTechnicianNames = [];

  String get searchQuery => _searchQuery;
  Set<String> get selectedTechnicianIds => _selectedTechnicianIds;
  List<String> get selectedTechnicianNames => _selectedTechnicianNames;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleSelection(PosTechnician tech) {
    if (_selectedTechnicianIds.contains(tech.id)) {
      _selectedTechnicianIds.remove(tech.id);
      _selectedTechnicianNames.remove(tech.name);
    } else {
      _selectedTechnicianIds.add(tech.id);
      _selectedTechnicianNames.add(tech.name);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedTechnicianIds.clear();
    _selectedTechnicianNames.clear();
    notifyListeners();
  }
}
