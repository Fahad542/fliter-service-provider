import 'package:flutter/foundation.dart';

import '../../../data/repositories/pos_repository.dart';
import '../../../models/inventory_sales_api_model.dart';
import '../../../services/session_service.dart';

/// Drawer tab: sold quantities by product per calendar day for a selected period.
class InventorySalesViewModel extends ChangeNotifier {
  InventorySalesViewModel({
    required this.posRepository,
    required this.sessionService,
  });

  final PosRepository posRepository;
  final SessionService sessionService;

  static const presets = [
    ('Today', InventorySalesPreset.today),
    ('Yesterday', InventorySalesPreset.yesterday),
    ('Last 7 days', InventorySalesPreset.last7),
    ('Last 30 days', InventorySalesPreset.last30),
    ('This month', InventorySalesPreset.thisMonth),
  ];

  InventorySalesPreset _preset = InventorySalesPreset.last7;
  DateTime? _customFrom;
  DateTime? _customTo;

  List<InventorySaleLine> _lines = [];
  bool isLoading = false;
  String? errorMessage;

  /// Matches typical backend validation (client-side check).
  static const int maxRangeDaysInclusive = 366;

  InventorySalesPreset get preset => _preset;
  bool get isCustomRange => _preset == InventorySalesPreset.custom;

  List<InventorySaleLine> get lines => List.unmodifiable(_lines);

  ({DateTime from, DateTime toInclusive}) resolveDateRange({DateTime? now}) {
    final n = now ?? DateTime.now();
    final today = DateTime(n.year, n.month, n.day);

    DateTime clampEnd(DateTime d) => DateTime(d.year, d.month, d.day);

    switch (_preset) {
      case InventorySalesPreset.today:
        return (from: today, toInclusive: today);
      case InventorySalesPreset.yesterday:
        final y = today.subtract(const Duration(days: 1));
        return (from: y, toInclusive: y);
      case InventorySalesPreset.last7:
        final from = today.subtract(const Duration(days: 6));
        return (from: from, toInclusive: today);
      case InventorySalesPreset.last30:
        final from = today.subtract(const Duration(days: 29));
        return (from: from, toInclusive: today);
      case InventorySalesPreset.thisMonth:
        final from = DateTime(today.year, today.month, 1);
        return (from: from, toInclusive: today);
      case InventorySalesPreset.custom:
        final a = _customFrom != null ? clampEnd(_customFrom!) : today.subtract(const Duration(days: 6));
        final b = _customTo != null ? clampEnd(_customTo!) : today;
        if (a.isAfter(b)) {
          return (from: b, toInclusive: a);
        }
        return (from: a, toInclusive: b);
    }
  }

  /// Sections by calendar day (**ascending**); rows per day by **productName** (asc).
  /// (Lines are also globally sorted soldDate ↑, productName ↑ after fetch.)
  List<({DateTime day, List<InventorySaleLine> rows})> get groupedByDay {
    final map = <DateTime, List<InventorySaleLine>>{};
    for (final l in _lines) {
      final d = DateTime(l.soldOn.year, l.soldOn.month, l.soldOn.day);
      map.putIfAbsent(d, () => []).add(l);
    }
    final days = map.keys.toList()..sort((a, b) => a.compareTo(b));
    return [
      for (final d in days)
        (
          day: d,
          rows: () {
            final r = List<InventorySaleLine>.from(map[d]!);
            r.sort((a, b) => a.productName.toLowerCase().compareTo(b.productName.toLowerCase()));
            return r;
          }(),
        ),
    ];
  }

  num get totalQuantitySold {
    var t = 0.0;
    for (final l in _lines) {
      t += l.quantitySold.toDouble();
    }
    return t;
  }

  int get distinctProductsInPeriod {
    final keys = <String>{};
    for (final l in _lines) {
      final k = (l.productId != null && l.productId!.trim().isNotEmpty)
          ? l.productId!.trim()
          : l.productName.trim().toLowerCase();
      keys.add(k);
    }
    return keys.length;
  }

  int get lineCount => _lines.length;

  Future<void> setPreset(InventorySalesPreset p) async {
    _preset = p;
    notifyListeners();
    await fetch();
  }

  Future<void> setCustomRange(DateTime from, DateTime to) async {
    _preset = InventorySalesPreset.custom;
    _customFrom = from;
    _customTo = to;
    notifyListeners();
    await fetch();
  }

  /// Explicit `from` / `to` (inclusive) + fetch; validates order and max span.
  Future<void> setExplicitRangeAndFetch(DateTime from, DateTime to) async {
    final a = DateTime(from.year, from.month, from.day);
    final b = DateTime(to.year, to.month, to.day);
    if (a.isAfter(b)) {
      errorMessage = 'Start date must be on or before end date.';
      notifyListeners();
      return;
    }
    final spanDays = b.difference(a).inDays + 1;
    if (spanDays > maxRangeDaysInclusive) {
      errorMessage = 'Date range cannot exceed $maxRangeDaysInclusive days.';
      notifyListeners();
      return;
    }
    errorMessage = null;
    _preset = InventorySalesPreset.custom;
    _customFrom = a;
    _customTo = b;
    notifyListeners();
    await fetch();
  }

  void _applyClientSort() {
    _lines.sort((a, b) {
      final da = DateTime(a.soldOn.year, a.soldOn.month, a.soldOn.day);
      final db = DateTime(b.soldOn.year, b.soldOn.month, b.soldOn.day);
      final c = da.compareTo(db);
      if (c != 0) return c;
      return a.productName.toLowerCase().compareTo(b.productName.toLowerCase());
    });
  }

  Future<void> fetch({bool silent = false}) async {
    if (!silent) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
    }
    try {
      final token = await sessionService.getToken(role: 'cashier');
      if (token == null) {
        errorMessage = 'Session expired. Please sign in again.';
        _lines = [];
        return;
      }
      final range = resolveDateRange();
      final res = await posRepository.getCashierInventorySales(
        token,
        from: range.from,
        toInclusive: range.toInclusive,
      );
      _lines = List<InventorySaleLine>.from(res.lines);
      _applyClientSort();
      if (res.success == false && (res.message?.isNotEmpty ?? false)) {
        errorMessage = res.message;
      } else {
        errorMessage = null;
      }
    } catch (e) {
      _lines = [];
      errorMessage = _shortError(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void dismissErrorBanner() {
    if (errorMessage == null) return;
    errorMessage = null;
    notifyListeners();
  }

  String _shortError(Object e) {
    var s = e.toString();
    if (s.startsWith('Exception: ')) s = s.substring(11);
    if (s.length > 160) return '${s.substring(0, 157)}…';
    return s;
  }
}

enum InventorySalesPreset {
  today,
  yesterday,
  last7,
  last30,
  thisMonth,
  custom,
}
