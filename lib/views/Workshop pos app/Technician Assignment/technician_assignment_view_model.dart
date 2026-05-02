import 'package:flutter/material.dart';
import '../../../../models/pos_order_model.dart';
import '../../../../models/pos_technician_model.dart';

/// Maps a job row to the cashier catalog row. Job payloads may use [JobTechnician.employeeId]
/// or assignment [id] while [PosTechnician.id] vs [PosTechnician.userId] can differ.
PosTechnician? findCatalogTechForJobAssignment(
  JobTechnician jt,
  List<PosTechnician> catalog,
) {
  final want = jt.pickerEmployeeId.trim();
  if (want.isEmpty) return null;
  for (final t in catalog) {
    if (t.id == want) return t;
    final uid = t.userId.trim();
    if (uid.isNotEmpty && uid == want) return t;
  }
  return null;
}

/// [PosTechnician.id] values for job assignments — same space as [selectedTechnicianIds].
Set<String> catalogIdsForJobTechnicians(
  List<JobTechnician> jobTechs,
  List<PosTechnician> catalog,
) {
  final out = <String>{};
  for (final jt in jobTechs) {
    final t = findCatalogTechForJobAssignment(jt, catalog);
    if (t != null) out.add(t.id);
  }
  return out;
}

class TechnicianAssignmentViewModel extends ChangeNotifier {
  String _searchQuery = '';
  final Set<String> _selectedTechnicianIds = {};
  final List<String> _selectedTechnicianNames = [];
  String? _departmentName;
  /// When true, only [PosTechnician.isOnline] technicians are listed (default).
  bool _onlineOnly = true;
  /// After any user toggle/clear, do not let late [applyInitialSelectionFromJob] overwrite picks.
  bool _userChangedSelection = false;

  String get searchQuery => _searchQuery;
  Set<String> get selectedTechnicianIds => _selectedTechnicianIds;
  List<String> get selectedTechnicianNames => _selectedTechnicianNames;
  String? get departmentName => _departmentName;
  bool get onlineOnly => _onlineOnly;

  void setDepartmentName(String? name) {
    _departmentName = name;
    _onlineOnly = true;
    notifyListeners();
  }

  void setOnlineOnly(bool value) {
    _onlineOnly = value;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleSelection(PosTechnician tech) {
    _userChangedSelection = true;
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
    _userChangedSelection = true;
    _selectedTechnicianIds.clear();
    _selectedTechnicianNames.clear();
    notifyListeners();
  }

  /// After catalog loads: check boxes for technicians already on the job.
  void applyInitialSelectionFromJob(
    List<JobTechnician> assigned,
    List<PosTechnician> catalog,
  ) {
    if (_userChangedSelection) return;
    _selectedTechnicianIds.clear();
    _selectedTechnicianNames.clear();
    for (final jt in assigned) {
      final t = findCatalogTechForJobAssignment(jt, catalog);
      if (t != null) {
        _selectedTechnicianIds.add(t.id);
        _selectedTechnicianNames.add(t.name);
      }
    }
    notifyListeners();
  }
}
