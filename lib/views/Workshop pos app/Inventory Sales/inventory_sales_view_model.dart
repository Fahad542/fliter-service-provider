import 'package:flutter/foundation.dart';

import '../../../data/repositories/pos_repository.dart';
import '../../../models/inventory_sales_api_model.dart';
import '../../../services/session_service.dart';
import '../../../services/locker_translation_mixin.dart';

// ─────────────────────────────────────────────────────────────────────────────
// InventorySalesViewModel
//
// Translation strategy
// ────────────────────
// • Static UI strings (presets, column headers, etc.) are resolved by the
//   View via AppLocalizations.of(context) — the ViewModel never touches them.
//
// • Dynamic API strings (productName, sku) come back in English from the
//   backend. When the locale is Arabic they are translated on the fly using
//   TranslatableMixin.t() (which calls AppTranslationService.localizedText).
//
// • The ViewModel stores two parallel lists:
//     _lines          — raw, immutable API data (never mutated after fetch)
//     _displayLines   — translated copies used by the View
//
// • bindLocaleRetranslation() hooks into SettingsViewModel so that switching
//   locale instantly re-translates without a full refetch from the server.
//
// • Error messages that should appear in the UI are stored as enum values
//   (InventorySalesError) so the View can render them through AppLocalizations.
//   Free-text server errors that come as opaque English strings are translated
//   on-the-fly via t() before being stored in errorMessage.
// ─────────────────────────────────────────────────────────────────────────────

/// Drawer tab: sold quantities by product per calendar day for a selected period.
class InventorySalesViewModel extends ChangeNotifier with TranslatableMixin {
  InventorySalesViewModel({
    required this.posRepository,
    required this.sessionService,
  });

  final PosRepository posRepository;
  final SessionService sessionService;

  // ── Preset definitions — labels are intentionally English keys only.
  // The View resolves the localized label via _presetLabels(l10n) map.
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

  /// Raw lines exactly as returned by the API (immutable after assignment).
  List<InventorySaleLine> _rawLines = [];

  /// Display lines — translated copies of _rawLines used by the View.
  List<InventorySaleLine> _displayLines = [];

  bool isLoading = false;

  /// Structured error so the View can map it to a localized string.
  /// null means no error.
  InventorySalesVmError? vmError;

  /// Free-text error (translated server message or translated exception text).
  /// When vmError is non-null, the View should prefer vmError for i18n strings.
  String? errorMessage;

  /// Matches typical backend validation (client-side check).
  static const int maxRangeDaysInclusive = 366;

  InventorySalesPreset get preset => _preset;
  bool get isCustomRange => _preset == InventorySalesPreset.custom;

  /// The View always reads from _displayLines (translated).
  List<InventorySaleLine> get lines => List.unmodifiable(_displayLines);

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
        final a = _customFrom != null
            ? clampEnd(_customFrom!)
            : today.subtract(const Duration(days: 6));
        final b = _customTo != null ? clampEnd(_customTo!) : today;
        if (a.isAfter(b)) {
          return (from: b, toInclusive: a);
        }
        return (from: a, toInclusive: b);
    }
  }

  /// Sections by calendar day (**ascending**); rows per day by **productName** (asc).
  List<({DateTime day, List<InventorySaleLine> rows})> get groupedByDay {
    final map = <DateTime, List<InventorySaleLine>>{};
    for (final l in _displayLines) {
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
          r.sort((a, b) =>
              a.productName.toLowerCase().compareTo(b.productName.toLowerCase()));
          return r;
        }(),
        ),
    ];
  }

  num get totalQuantitySold {
    var total = 0.0;
    // Use raw lines for numeric aggregation — translation doesn't affect numbers.
    for (final l in _rawLines) {
      total += l.quantitySold.toDouble();
    }
    return total;
  }

  int get distinctProductsInPeriod {
    final keys = <String>{};
    for (final l in _rawLines) {
      final k = (l.productId != null && l.productId!.trim().isNotEmpty)
          ? l.productId!.trim()
          : l.productName.trim().toLowerCase();
      keys.add(k);
    }
    return keys.length;
  }

  int get lineCount => _rawLines.length;

  // ── Locale re-translation ─────────────────────────────────────────────────

  /// Call once during widget tree setup (e.g. from a ProxyProvider or
  /// didChangeDependencies) to bind locale-change retranslation.
  ///
  ///   vm.bindLocaleRetranslation(settingsViewModel, vm.retranslate);
  Future<void> retranslate() async {
    // Clear cache so fresh translations are produced for the new locale.
    AppTranslationService.clearCache();
    await _buildDisplayLines();
    notifyListeners();
  }

  // ── Mutations ─────────────────────────────────────────────────────────────

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
      // Store structured error — View maps this to l10n.posInvSalesErrStartBeforeEnd
      vmError = InventorySalesVmError.startAfterEnd;
      errorMessage = null;
      notifyListeners();
      return;
    }
    final spanDays = b.difference(a).inDays + 1;
    if (spanDays > maxRangeDaysInclusive) {
      // Store structured error — View maps this to l10n.posInvSalesErrRangeExceeded(days)
      vmError = InventorySalesVmError.rangeExceeded;
      errorMessage = null;
      notifyListeners();
      return;
    }
    vmError = null;
    errorMessage = null;
    _preset = InventorySalesPreset.custom;
    _customFrom = a;
    _customTo = b;
    notifyListeners();
    await fetch();
  }

  // ── Fetch & sort ──────────────────────────────────────────────────────────

  void _applyClientSort(List<InventorySaleLine> list) {
    list.sort((a, b) {
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
      vmError = null;
      errorMessage = null;
      notifyListeners();
    }
    try {
      final token = await sessionService.getToken(role: 'cashier');
      if (token == null) {
        // Structured error: View maps to l10n.posInvSalesSessionExpiredError
        vmError = InventorySalesVmError.sessionExpired;
        errorMessage = null;
        _rawLines = [];
        _displayLines = [];
        return;
      }
      final range = resolveDateRange();
      final res = await posRepository.getCashierInventorySales(
        token,
        from: range.from,
        toInclusive: range.toInclusive,
      );
      _rawLines = List<InventorySaleLine>.from(res.lines);
      _applyClientSort(_rawLines);

      await _buildDisplayLines();

      if (res.success == false && (res.message?.isNotEmpty ?? false)) {
        // Server message may be English — translate it for Arabic locale.
        errorMessage = await t(res.message!);
        vmError = null;
      } else {
        errorMessage = null;
        vmError = null;
      }
    } catch (e) {
      _rawLines = [];
      _displayLines = [];
      // Translate the exception message before storing.
      errorMessage = await t(_shortError(e));
      vmError = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Builds _displayLines by translating all dynamic API string fields.
  /// Product names and SKUs come from the backend in English; when the app
  /// locale is Arabic they are translated via the GoogleTranslator cache.
  ///
  /// NOTE: numeric data (quantitySold, soldOn) is never translated.
  Future<void> _buildDisplayLines() async {
    final translated = await Future.wait(
      _rawLines.map((line) async {
        final translatedName = await t(line.productName);
        // SKUs / codes are alphanumeric — skip translation (tReference guards this).
        final translatedSku =
        line.sku != null ? await tReference(line.sku!) : null;
        return InventorySaleLine(
          productName: translatedName,
          productId: line.productId,
          sku: translatedSku,
          soldOn: line.soldOn,
          quantitySold: line.quantitySold,
        );
      }),
    );
    _displayLines = translated;
    _applyClientSort(_displayLines);
  }

  void dismissErrorBanner() {
    if (errorMessage == null && vmError == null) return;
    errorMessage = null;
    vmError = null;
    notifyListeners();
  }

  // ── Dispose ───────────────────────────────────────────────────────────────

  @override
  void dispose() {
    unbindLocaleRetranslation();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _shortError(Object e) {
    var s = e.toString();
    if (s.startsWith('Exception: ')) s = s.substring(11);
    if (s.length > 160) return '${s.substring(0, 157)}…';
    return s;
  }
}

// ─────────────────────────────────────────────────────────────────────────────

enum InventorySalesPreset {
  today,
  yesterday,
  last7,
  last30,
  thisMonth,
  custom,
}

/// Structured error codes.
/// The View maps each value to the appropriate l10n string — this avoids
/// storing English error text in the ViewModel that would not update when
/// the locale changes.
enum InventorySalesVmError {
  /// From > To — map to l10n.posInvSalesErrStartBeforeEnd
  startAfterEnd,

  /// Span > maxRangeDaysInclusive — map to l10n.posInvSalesErrRangeExceeded(days)
  rangeExceeded,

  /// Token is null — map to l10n.posInvSalesSessionExpiredError
  sessionExpired,
}