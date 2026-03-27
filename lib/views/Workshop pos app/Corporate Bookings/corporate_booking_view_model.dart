import 'package:flutter/foundation.dart';
import '../../../data/repositories/pos_repository.dart';
import '../../../models/corporate_booking_model.dart';
import '../../../services/session_service.dart';

class CorporateBookingViewModel extends ChangeNotifier {
  final PosRepository _repository;
  final SessionService _sessionService;

  CorporateBookingViewModel({
    required PosRepository repository,
    required SessionService sessionService,
  })  : _repository = repository,
        _sessionService = sessionService;

  List<CorporateBooking> _allBookings = [];
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String _currentFilter = 'Pending'; // 'Today', 'Pending', 'All'
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
          return b.statusDisplay.toLowerCase().contains('waiting approval') || 
                 b.status.toLowerCase() == 'pending' || 
                 b.status.toLowerCase() == 'submitted';
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

  Future<void> fetchCorporateBookings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _sessionService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final user = await _sessionService.getUser();
      final branchId = user?.branchId ?? '4'; // Resolve branch ID from user session

      final response = await _repository.getCorporateBookings('none', branchId, token, limit: 20, offset: 0);
      if (response.success) {
        _allBookings = response.bookings;
      } else {
        _errorMessage = 'Failed to load bookings';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approveBooking(String bookingId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await _sessionService.getToken();
      if (token == null) {
         throw Exception('Authentication token not found');
      }
      final success = await _repository.approveCorporateBooking(bookingId, token);
      if (success) {
        final index = _allBookings.indexWhere((b) => b.id == bookingId);
        if (index != -1) {
          _allBookings[index] = _allBookings[index].copyWith(
            status: 'Approved', 
            statusDisplay: 'Approved',
          );
        }
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> rejectBooking(String bookingId, String reason) async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await _sessionService.getToken();
      if (token == null) {
         throw Exception('Authentication token not found');
      }
      final success = await _repository.rejectCorporateBooking(bookingId, reason, token);
      if (success) {
        final index = _allBookings.indexWhere((b) => b.id == bookingId);
        if (index != -1) {
          _allBookings.removeAt(index);
        }
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
