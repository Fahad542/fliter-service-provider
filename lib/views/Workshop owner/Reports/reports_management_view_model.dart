import 'package:flutter/material.dart';
import '../../../../models/workshop_owner_models.dart';
import '../../../../data/repositories/owner_repository.dart';
import '../../../../services/session_service.dart';

class ReportsManagementViewModel extends ChangeNotifier {
  final OwnerRepository ownerRepository;
  final SessionService sessionService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ReportsAnalyticsResponse? _reportsData;
  ReportsAnalyticsResponse? get reportsData => _reportsData;

  ReportsManagementViewModel({
    required this.ownerRepository,
    required this.sessionService,
  }) {
    fetchReportsData();
  }

  Future<void> fetchReportsData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) throw Exception('No token found');

      final response = await ownerRepository.getReportsAnalytics(token);

      if (response != null && response['success'] == true) {
        _reportsData = ReportsAnalyticsResponse.fromJson(response);
      }
    } catch (e) {
      debugPrint('Error fetching reports data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
