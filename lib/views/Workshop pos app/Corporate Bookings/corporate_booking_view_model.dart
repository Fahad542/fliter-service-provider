import 'package:flutter/foundation.dart';
import '../../../models/corporate_booking_model.dart';

class CorporateBookingViewModel extends ChangeNotifier {
  final List<CorporateBooking> _allBookings = [
    CorporateBooking(
      id: 'CB-1001',
      companyName: 'Acme Corp',
      vehicleName: 'Toyota Camry 2022',
      vehiclePlate: 'ABC 1234',
      department: 'Oil Change',
      bookedDateTime: DateTime.now().subtract(const Duration(hours: 1)),
      status: 'Waiting Approval',
      preSelectedProducts: ['p1', 'p2'], // Add mock product IDs here (you would use actual backend IDs)
    ),
    CorporateBooking(
      id: 'CB-1002',
      companyName: 'B2B Logistics',
      vehicleName: 'Ford Transit 2021',
      vehiclePlate: 'XYZ 9876',
      department: 'Tyre Services',
      bookedDateTime: DateTime.now().subtract(const Duration(days: 1)),
      status: 'Completed',
    ),
    CorporateBooking(
      id: 'CB-1003',
      companyName: 'Tech Innovators',
      vehicleName: 'Hyundai Sonata 2023',
      vehiclePlate: 'DEF 5678',
      department: 'AC Cleaning',
      bookedDateTime: DateTime.now().add(const Duration(hours: 2)),
      status: 'Pending', // treated as waiting approval/upcoming
    ),
    CorporateBooking(
      id: 'CB-1004',
      companyName: 'Acme Corp',
      vehicleName: 'Toyota Corolla 2020',
      vehiclePlate: 'LMN 3456',
      department: 'Repair',
      bookedDateTime: DateTime.now().subtract(const Duration(hours: 24)),
      status: 'In Progress',
    ),
  ];

  String _currentFilter = 'Today'; // 'Today', 'Pending', 'All'

  String get currentFilter => _currentFilter;

  List<CorporateBooking> get filteredBookings {
    final now = DateTime.now();

    switch (_currentFilter) {
      case 'Today':
        return _allBookings.where((b) {
          return b.bookedDateTime.year == now.year &&
                 b.bookedDateTime.month == now.month &&
                 b.bookedDateTime.day == now.day;
        }).toList();
      case 'Pending':
        return _allBookings.where((b) {
          return b.status == 'Waiting Approval' || b.status == 'Pending';
        }).toList();
      case 'All':
      default:
        return _allBookings;
    }
  }

  void setFilter(String filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  void updateBookingStatus(String bookingId, String newStatus, {String? reason}) {
    final index = _allBookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _allBookings[index] = _allBookings[index].copyWith(status: newStatus);
      notifyListeners();
    }
    if (reason != null && reason.isNotEmpty) {
      debugPrint('Booking $bookingId $newStatus. Reason: $reason');
      // In a real app, this would be sent to the backend API here.
    }
  }
}
