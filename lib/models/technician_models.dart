import 'package:flutter/material.dart';

class TechOrder {
  final String id;
  final String customerName;
  final String vehicleModel;
  final String plateNumber;
  final String department;
  final double totalValue;
  final double commission;
  final String status; // 'Pending', 'In Progress', 'Completed'
  final DateTime timestamp;

  TechOrder({
    required this.id,
    required this.customerName,
    required this.vehicleModel,
    required this.plateNumber,
    required this.department,
    required this.totalValue,
    required this.commission,
    required this.status,
    required this.timestamp,
  });
}

class CommissionRecord {
  final String id;
  final String orderId;
  final DateTime date;
  final double amount;
  final String status; // 'Paid', 'Pending'

  CommissionRecord({
    required this.id,
    required this.orderId,
    required this.date,
    required this.amount,
    required this.status,
  });
}

class TechNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String type; // 'Broadcast', 'Assignment', 'Commission'

  TechNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    required this.type,
  });
}
