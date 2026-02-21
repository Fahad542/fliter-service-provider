import 'package:flutter/foundation.dart';
import '../../../data/repositories/pos_repository.dart';
import '../../../services/session_service.dart';
import '../../../models/pos_technician_model.dart';

class TechnicianViewModel extends ChangeNotifier {
  final PosRepository _posRepository;
  final SessionService _sessionService;

  TechnicianViewModel({
    required PosRepository posRepository,
    required SessionService sessionService,
  })  : _posRepository = posRepository,
        _sessionService = sessionService;

  List<PosTechnician> _technicians = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  bool _isAssigning = false;
  String? _assigningTechnicianId;
  String? _assignmentMessage;
  bool _assignmentSuccess = false;

  List<PosTechnician> get technicians {
    if (_searchQuery.isEmpty) return _technicians;
    return _technicians.where((t) => 
      t.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      t.employeeType.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  // Grouped Technicians (Moved from View)
  Map<String, List<PosTechnician>> get groupedTechnicians {
    final Map<String, List<PosTechnician>> grouped = {};
    for (var tech in technicians) {
      final type = tech.technicianType ?? 'General';
      grouped.putIfAbsent(type, () => []).add(tech);
    }
    return grouped;
  }
 
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAssigning => _isAssigning;
  String? get assigningTechnicianId => _assigningTechnicianId;
  String? get assignmentMessage => _assignmentMessage;
  bool get assignmentSuccess => _assignmentSuccess;

  bool isAssigningTechnician(String id) => _isAssigning && _assigningTechnicianId == id;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchTechnicians() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _sessionService.getToken();
      if (token == null) {
        throw Exception('Token not found');
      }

      final response = await _posRepository.getTechnicians(token);
      if (response.success) {
        _technicians = response.technicians;
      } else {
        _errorMessage = 'Failed to fetch technicians';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> assignTechnician(String jobId, String employeeId) async {
    _isAssigning = true;
    _assigningTechnicianId = employeeId;
    _assignmentMessage = null;
    _assignmentSuccess = false;
    notifyListeners();

    try {
      final token = await _sessionService.getToken();
      if (token == null) {
        throw Exception('Token not found');
      }

      final response =
          await _posRepository.assignTechnician(jobId, employeeId, token);
      _assignmentMessage = response.message;
      _assignmentSuccess = response.success;
      return response.success;
    } catch (e) {
      _assignmentMessage = e.toString();
      _assignmentSuccess = false;
      return false;
    } finally {
      _isAssigning = false;
      _assigningTechnicianId = null;
      notifyListeners();
    }
  }
  Future<bool> assignMultipleTechnicians(String jobId, List<String> employeeIds) async {
    _isAssigning = true;
    _assigningTechnicianId = null; // Don't show specific spinner on list items when doing bulk
    _assignmentMessage = null;
    _assignmentSuccess = false;
    notifyListeners();

    try {
      final token = await _sessionService.getToken();
      if (token == null) {
        throw Exception('Token not found');
      }

      bool allSuccess = true;
      String? lastMessage;

      // Call API sequentially for each technician
      for (final employeeId in employeeIds) {
        final response = await _posRepository.assignTechnician(jobId, employeeId, token);
        if (!response.success) {
          allSuccess = false;
        }
        lastMessage = response.message;
      }

      _assignmentSuccess = allSuccess;
      _assignmentMessage = allSuccess ? 'All assigned successfully' : (lastMessage ?? 'Some assignments failed');
      return allSuccess;
    } catch (e) {
      _assignmentMessage = e.toString();
      _assignmentSuccess = false;
      return false;
    } finally {
      _isAssigning = false;
      notifyListeners();
    }
  }
}
