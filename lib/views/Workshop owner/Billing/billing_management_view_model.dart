import 'package:flutter/material.dart';
import '../../../../models/workshop_owner_models.dart';
import '../../../../data/repositories/owner_repository.dart';
import '../../../../services/session_service.dart';

class BillingManagementViewModel extends ChangeNotifier {
  final OwnerRepository ownerRepository;
  final SessionService sessionService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<MonthlyBill> _monthlyBills = [];
  List<MonthlyBill> get monthlyBills => _monthlyBills;

  double _totalBilledMonth = 0.0;
  double get totalBilledMonth => _totalBilledMonth;

  double _totalReceivedMonth = 0.0;
  double get totalReceivedMonth => _totalReceivedMonth;

  double _totalOutstanding = 0.0;
  double get totalOutstanding => _totalOutstanding;

  double _overdueAmount = 0.0;
  double get overdueAmount => _overdueAmount;


  BillingManagementViewModel({
    required this.ownerRepository,
    required this.sessionService,
  }) {
    _init();
  }

  Future<void> _init() async {
    await fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token == null) throw Exception('No token found');

      final response = await ownerRepository.getBillingDashboard(token);

      if (response != null && response['success'] == true) {
        _totalBilledMonth = double.tryParse(response['totalBilled']?.toString() ?? '0') ?? 0.0;
        _totalReceivedMonth = double.tryParse(response['totalReceived']?.toString() ?? '0') ?? 0.0;
        _totalOutstanding = double.tryParse(response['outstanding']?.toString() ?? '0') ?? 0.0;
        _overdueAmount = double.tryParse(response['overdue']?.toString() ?? '0') ?? 0.0;

        if (response['recentBillingActivity'] != null) {
          _monthlyBills = (response['recentBillingActivity'] as List)
              .map((activity) => MonthlyBill.fromJson(activity))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching billing dashboard: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
