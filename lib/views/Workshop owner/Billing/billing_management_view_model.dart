import 'package:flutter/material.dart';
import '../../../../models/workshop_owner_models.dart';

class BillingManagementViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<MonthlyBill> _monthlyBills = [];
  List<MonthlyBill> get monthlyBills => _monthlyBills;

  double get totalBilledMonth => 125000.0;
  double get totalReceivedMonth => 85000.0;
  double get totalOutstanding => 40000.0;
  double get overdueAmount => 15000.0;

  BillingManagementViewModel() {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(seconds: 1));
    _monthlyBills = [
      MonthlyBill(
        id: '1', 
        corporateCustomerId: '1', 
        customerName: 'Aramco Logistics', 
        month: 1, 
        year: 2026, 
        totalAmount: 45000.0, 
        paidAmount: 45000.0, 
        dueDate: DateTime(2026, 2, 15), 
        status: 'Paid',
      ),
      MonthlyBill(
        id: '2', 
        corporateCustomerId: '2', 
        customerName: 'Sabic Transport', 
        month: 1, 
        year: 2026, 
        totalAmount: 32000.0, 
        paidAmount: 12000.0, 
        dueDate: DateTime(2026, 2, 15), 
        status: 'Partially Paid',
      ),
      MonthlyBill(
        id: '3', 
        corporateCustomerId: '1', 
        customerName: 'Aramco Logistics', 
        month: 12, 
        year: 2025, 
        totalAmount: 28000.0, 
        paidAmount: 0.0, 
        dueDate: DateTime(2026, 1, 15), 
        status: 'Overdue',
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }
}
