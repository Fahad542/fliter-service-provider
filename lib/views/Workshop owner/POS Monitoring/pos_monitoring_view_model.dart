import 'package:flutter/material.dart';
import '../../../../models/workshop_owner_models.dart';
import '../../../../data/repositories/owner_repository.dart';
import '../../../../services/session_service.dart';

class PosMonitoringViewModel extends ChangeNotifier {
  final OwnerRepository ownerRepository;
  final SessionService sessionService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  PosMonitoringResponse? _monitoringResponse;
  PosMonitoringResponse? get monitoringResponse => _monitoringResponse;

  PosMonitoringViewModel({
    required this.ownerRepository,
    required this.sessionService,
  });

  Future<void> fetchPosMonitoring() async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token != null) {
        final response = await ownerRepository.getPosMonitoring(token);
        if (response != null && response['success'] == true) {
          _monitoringResponse = PosMonitoringResponse.fromJson(response);
        }
      }
    } catch (e) {
      debugPrint('Error fetching POS monitoring: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
