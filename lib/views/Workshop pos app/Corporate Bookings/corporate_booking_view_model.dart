import 'package:flutter/foundation.dart';
import '../../../data/repositories/pos_repository.dart';
import '../../../models/corporate_booking_model.dart';
import '../../../services/realtime_service.dart';
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
  final RealtimeService _realtimeService = RealtimeService();
  bool _realtimeBound = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String _currentFilter = 'Pending'; // 'Today', 'Pending', 'All'
  String get currentFilter => _currentFilter;

  bool _isCompletedBooking(CorporateBooking booking) {
    final statusRaw =
        '${booking.statusDisplay} ${booking.status} ${booking.orderStatus}'
            .toLowerCase();
    return statusRaw.contains('complete') || statusRaw.contains('invoiced');
  }

  List<CorporateBooking> get filteredBookings {
    final now = DateTime.now();
    final activeBookings = _allBookings
        .where((booking) => !_isCompletedBooking(booking))
        .toList();
    List<CorporateBooking> filtered;

    switch (_currentFilter) {
      case 'Today':
        filtered = activeBookings.where((b) {
          return b.bookedDateTime.year == now.year &&
                 b.bookedDateTime.month == now.month &&
                 b.bookedDateTime.day == now.day;
        }).toList();
        break;
      case 'Pending':
        filtered = activeBookings.where((b) {
          return b.statusDisplay.toLowerCase().contains('waiting approval') || 
                 b.status.toLowerCase() == 'pending' || 
                 b.status.toLowerCase() == 'submitted';
        }).toList();
        break;
      case 'All':
      default:
        filtered = List<CorporateBooking>.from(activeBookings);
        break;
    }
    filtered.sort((a, b) {
      final bi = int.tryParse(b.id) ?? -1;
      final ai = int.tryParse(a.id) ?? -1;
      if (bi != ai) return bi.compareTo(ai);
      return b.submittedAt.compareTo(a.submittedAt);
    });
    return filtered;
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

      // Backend contract: cancelled corporate orders are returned under `filter=all`.
      final response = await _repository.getCorporateBookings('all', branchId, token, limit: 20, offset: 0);
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

  Future<void> bindRealtime() async {
    if (_realtimeBound) return;
    final token = await _sessionService.getToken();
    if (token == null || token.isEmpty) return;
    _realtimeService.connect(token);
    _realtimeService.on(
      RealtimeService.eventCorporateWalkInOrderUpdated,
      _onCorporateWalkInUpdated,
    );
    _realtimeService.on(
      RealtimeService.eventCashierOrdersUpdated,
      _onCashierOrdersUpdated,
    );
    _realtimeService.on(
      RealtimeService.eventCashierCorporateWalkInApproved,
      _onCashierOrdersUpdated,
    );
    _realtimeService.on(
      RealtimeService.eventCashierCorporateWalkInRejected,
      _onCashierOrdersUpdated,
    );
    _realtimeBound = true;
  }

  void unbindRealtime() {
    if (!_realtimeBound) return;
    _realtimeService.off(
      RealtimeService.eventCorporateWalkInOrderUpdated,
      _onCorporateWalkInUpdated,
    );
    _realtimeService.off(
      RealtimeService.eventCashierOrdersUpdated,
      _onCashierOrdersUpdated,
    );
    _realtimeService.off(
      RealtimeService.eventCashierCorporateWalkInApproved,
      _onCashierOrdersUpdated,
    );
    _realtimeService.off(
      RealtimeService.eventCashierCorporateWalkInRejected,
      _onCashierOrdersUpdated,
    );
    _realtimeService.disconnect();
    _realtimeBound = false;
  }

  Future<void> _onCorporateWalkInUpdated(Map<String, dynamic> payload) async {
    final eventName = (payload['event']?.toString() ?? '').trim().toLowerCase();
    if (eventName != 'lines_updated_by_branch') {
      await fetchCorporateBookings();
      return;
    }
    final orderId = (payload['orderId']?.toString() ?? payload['id']?.toString() ?? '').trim();
    if (orderId.isEmpty) {
      await fetchCorporateBookings();
      return;
    }
    await refreshCorporateOrderLines(orderId);
  }

  Future<void> _onCashierOrdersUpdated(Map<String, dynamic> _) async {
    await fetchCorporateBookings();
  }

  Future<void> refreshCorporateOrderLines(String orderId) async {
    try {
      final token = await _sessionService.getToken();
      if (token == null || token.isEmpty) return;
      final updated = await _repository.getCorporateWalkInOrder(orderId, token);
      if (updated == null) return;
      final index = _allBookings.indexWhere((b) => b.id.trim() == orderId.trim());
      if (index == -1) {
        // If list shape differs (booking not currently loaded), keep data fresh.
        await fetchCorporateBookings();
        return;
      }
      _allBookings[index] = updated;
      notifyListeners();
    } catch (_) {
      // Fallback keeps list consistent if detail endpoint is unavailable.
      await fetchCorporateBookings();
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

  @override
  void dispose() {
    unbindRealtime();
    super.dispose();
  }
}
