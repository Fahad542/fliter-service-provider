import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../models/pos_technician_model.dart';
import '../../Navbar/pos_shell.dart';

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

  // Dialog State
  int _secondsRemaining = 300;
  Timer? _timer;
  bool _isAccepted = false;
  String _acceptedBy = '';
  int _arrivalMinutes = 0;

  int get secondsRemaining => _secondsRemaining;
  bool get isAccepted => _isAccepted;
  String get acceptedBy => _acceptedBy;
  int get arrivalMinutes => _arrivalMinutes;

  void startBroadcastTimer(BuildContext context, bool isWorkshop, List<String>? specificTechNames) {
    _secondsRemaining = 300;
    _isAccepted = false;
    _acceptedBy = '';
    _arrivalMinutes = 0;
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0 && !_isAccepted) {
        _secondsRemaining--;
        notifyListeners();
      } else if (_secondsRemaining <= 0 && !_isAccepted) {
        handleBroadcastTimeout(context, isWorkshop, specificTechNames);
      }
    });
    // Immediately notify view
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
  }

  void handleBroadcastTimeout(BuildContext context, bool isWorkshop, List<String>? specificTechNames) {
    _timer?.cancel();
    if (context.mounted) {
      Navigator.pop(context);
      
      final specificNamesText = specificTechNames?.join(', ');
      final timeoutMessage = specificTechNames != null
          ? 'Technicians $specificNamesText did not accept. Re-routed to workshop.'
          : isWorkshop 
              ? 'No Workshop technician available – please assign manually or broadcast to On-Call'
              : 'No On-Call technician available – order re-routed to workshop technician';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(timeoutMessage),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void simulateAccept(BuildContext context, List<String>? specificTechNames) {
    _isAccepted = true;
    _acceptedBy = specificTechNames?.join(', ') ?? 'Ali';
    _arrivalMinutes = 18;
    notifyListeners();
    
    _timer?.cancel();

    Timer(const Duration(seconds: 3), () {
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const PosShell(initialIndex: 2)),
          (route) => false,
        );
      }
    });
  }

  void cancelTimer() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
