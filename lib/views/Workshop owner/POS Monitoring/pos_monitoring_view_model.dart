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

  DateTime? _filterFrom;
  DateTime? _filterTo;

  /// Inclusive calendar bounds (date only, no time semantics for filter label).
  DateTime? get filterFrom => _filterFrom;
  DateTime? get filterTo => _filterTo;

  PosMonitoringViewModel({
    required this.ownerRepository,
    required this.sessionService,
  });

  void clearDateFilter() {
    _filterFrom = null;
    _filterTo = null;
    notifyListeners();
  }

  /// Fetches monitoring; optional [from]/[to] query + client-side list filter.
  Future<void> fetchPosMonitoring({
    DateTime? from,
    DateTime? to,
  }) async {
    _filterFrom = from;
    _filterTo = to;
    _isLoading = true;
    notifyListeners();
    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token != null) {
        final response = await ownerRepository.getPosMonitoring(
          token,
          from: from,
          to: to,
        );
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

  static bool _sameDayInRange(DateTime t, DateTime from, DateTime to) {
    final d = DateTime(t.year, t.month, t.day);
    final f = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);
    return !d.isBefore(f) && !d.isAfter(end);
  }

  /// Filter live rows by **session start** ([`sessionStart`]) day in [filterFrom, filterTo].
  List<PosCounter> filterLiveCounters(List<PosCounter> base) {
    if (_filterFrom == null || _filterTo == null) return base;
    final from = _filterFrom!;
    final to = _filterTo!;
    return base
        .where((c) => _sameDayInRange(c.sessionStart, from, to))
        .toList();
  }

  /// When the API echoed [`dateRangeFilter`], closing rows are already scoped by [`closedAt`]; otherwise filter client-side.
  List<PosCounter> filterClosingReports(List<PosCounter> base) {
    if (_filterFrom == null || _filterTo == null) return base;
    if (_monitoringResponse?.dateRangeFilter != null) return base;
    final from = _filterFrom!;
    final to = _filterTo!;
    return base.where((c) {
      final anchor = c.closedAt ?? c.endTime ?? c.openedAt;
      return _sameDayInRange(anchor, from, to);
    }).toList();
  }
}
