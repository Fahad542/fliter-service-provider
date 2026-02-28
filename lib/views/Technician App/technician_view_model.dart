import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/technician_models.dart';

class TechAppViewModel extends ChangeNotifier {
  // --- Toggles ---
  bool _isWorkshopDuty = false;
  bool _isOnCallDuty = false;

  bool get isWorkshopDuty => _isWorkshopDuty;
  bool get isOnCallDuty => _isOnCallDuty;

  void toggleWorkshopDuty(bool value) {
    _isWorkshopDuty = value;
    if (value) _isOnCallDuty = false; // Mutually exclusive
    notifyListeners();
  }

  void toggleOnCallDuty(bool value) {
    _isOnCallDuty = value;
    if (value) _isWorkshopDuty = false; // Mutually exclusive
    notifyListeners();
  }

  // --- Real-time Stats ---
  int todayCompletedJobs = 8;
  double todayRevenue = 4850.0;
  double todayCommission = 485.0;
  double weekCommission = 2820.0;

  // --- Orders ---
  List<TechOrder> _assignedOrders = [];
  List<TechOrder> get assignedOrders => _assignedOrders;

  // --- Notifications ---
  List<TechNotification> _notifications = [];
  List<TechNotification> get notifications => _notifications;
  int get unreadNotifications => _notifications.where((n) => !n.isRead).length;

  // --- Broadcast Logic ---
  bool _hasActiveBroadcast = false;
  int _broadcastTimerSeconds = 300; // 5:00
  Timer? _broadcastTimer;

  bool get hasActiveBroadcast => _hasActiveBroadcast;
  int get broadcastTimerSeconds => _broadcastTimerSeconds;

  void startMockBroadcast() {
    _hasActiveBroadcast = true;
    _broadcastTimerSeconds = 300;
    _broadcastTimer?.cancel();
    _broadcastTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_broadcastTimerSeconds > 0) {
        _broadcastTimerSeconds--;
        notifyListeners();
      } else {
        stopBroadcast();
      }
    });
    notifyListeners();
  }

  void stopBroadcast() {
    _hasActiveBroadcast = false;
    _broadcastTimer?.cancel();
    notifyListeners();
  }

  // --- Initialize Mock Data ---
  void init() {
    _assignedOrders = [
      TechOrder(
        id: 'ORD-8821',
        customerName: 'Ahmad Abdullah',
        vehicleModel: 'Toyota Camry 2024',
        plateNumber: 'ABC 1234',
        department: 'Oil Change',
        totalValue: 250.0,
        commission: 25.0,
        status: 'In Progress',
        timestamp: DateTime.now(),
      ),
      TechOrder(
        id: 'ORD-8825',
        customerName: 'Khalid Jassim',
        vehicleModel: 'Nissan Patrol 2023',
        plateNumber: 'XYZ 9988',
        department: 'Brake Service',
        totalValue: 850.0,
        commission: 85.0,
        status: 'Pending',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];

    _notifications = [
      TechNotification(
        id: '1',
        title: 'Commission Credited',
        message: 'SAR 45.00 added to your daily earnings for ORD-7721',
        timestamp: DateTime.now(),
        type: 'Commission',
      ),
    ];
    notifyListeners();
  }
}
