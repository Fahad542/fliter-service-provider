import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/repositories/pos_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/cashier_active_broadcasts_model.dart';
import '../../../services/realtime_service.dart';
import '../../../services/session_service.dart';

/// Typed  error so the view can resolve a translated message without coupling
/// the VM to a BuildContext.
enum _BroadcastError { sessionExpired, fetchFailed }

class CashierBroadcastViewModel extends ChangeNotifier {
  CashierBroadcastViewModel({
    required this.posRepository,
    required this.sessionService,
  }) {
    _realtime.on(RealtimeService.eventCashierBroadcastUpdated, _onSocketBroadcast);
  }

  final PosRepository posRepository;
  final SessionService sessionService;
  final RealtimeService _realtime = RealtimeService();

  List<CashierActiveBroadcastItem> _broadcasts = [];
  int windowSeconds = 300;
  int soonThresholdSeconds = 60;
  int activeCountMeta = 0;
  bool isLoading = false;

  _BroadcastError? _errorKey;
  String? _rawErrorDetail;

  Timer? _tick;
  Timer? _socketDebounce;
  Timer? _backgroundPoll;

  List<CashierActiveBroadcastItem> get broadcasts => List.unmodifiable(_broadcasts);

  /// Returns null when there is no error; otherwise a translated message.
  String? resolveError(AppLocalizations l10n) {
    switch (_errorKey) {
      case _BroadcastError.sessionExpired:
        return l10n.posBroadcastSessionExpired;
      case _BroadcastError.fetchFailed:
        return _rawErrorDetail;
      case null:
        return null;
    }
  }

  /// Kept for legacy callers.
  String? get errorMessage => _rawErrorDetail;

  void _onSocketBroadcast(Map<String, dynamic> _) {
    _socketDebounce?.cancel();
    _socketDebounce = Timer(const Duration(milliseconds: 400), () {
      fetchActive(silent: true);
    });
  }

  Future<void> fetchActive({bool silent = false}) async {
    if (!silent) {
      isLoading = true;
      _errorKey = null;
      _rawErrorDetail = null;
      notifyListeners();
    }
    try {
      final token = await sessionService.getToken(role: 'cashier');
      if (token == null) {
        _errorKey = _BroadcastError.sessionExpired;
        _rawErrorDetail = 'Session expired. Please sign in again.';
        return;
      }
      final res = await posRepository.getCashierActiveBroadcasts(token);
      windowSeconds = res.windowSeconds;
      soonThresholdSeconds = res.soonThresholdSeconds;
      activeCountMeta = res.activeCount;
      final now = DateTime.now();
      _broadcasts = res.broadcasts.map((b) {
        if (b.expiresAt == null && b.remainingSeconds > 0) {
          return b.copyWith(expiresAt: now.add(Duration(seconds: b.remainingSeconds)));
        }
        return b;
      }).toList();
      _pruneExpired();
      _syncTicker();
      _syncBackgroundPoll();
    } catch (e) {
      if (!silent) {
        _errorKey = _BroadcastError.fetchFailed;
        _rawErrorDetail = e.toString();
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _pruneExpired() {
    final now = DateTime.now();
    _broadcasts.removeWhere((b) {
      final exp = b.expiresAt;
      if (exp != null) return !exp.isAfter(now);
      if (b.remainingSeconds <= 0) return true;
      return false;
    });
  }

  Duration remainingFor(CashierActiveBroadcastItem b) {
    final exp = b.expiresAt;
    if (exp != null) return exp.difference(DateTime.now());
    return Duration(seconds: b.remainingSeconds);
  }

  bool isExpired(CashierActiveBroadcastItem b) => remainingFor(b).isNegative;

  bool showSoon(CashierActiveBroadcastItem b) {
    final r = remainingFor(b);
    if (r.isNegative) return false;
    if (b.serverIsSoon) return true;
    return r.inSeconds <= soonThresholdSeconds;
  }

  double progressRemaining(CashierActiveBroadcastItem b) {
    final max = windowSeconds <= 0 ? 300 : windowSeconds;
    final left = remainingFor(b).inSeconds.clamp(0, max);
    return left / max;
  }

  /// Returns a translated badge label for a broadcast type.
  /// Must be called from the view where [AppLocalizations] is available.
  String? resolveBadge(String broadcastType, AppLocalizations l10n) {
    final type = broadcastType.trim().toLowerCase();
    if (type.isEmpty) return null;
    if (type == 'on_call') return l10n.posBroadcastTypeOnCall;
    if (type == 'workshop') return l10n.posBroadcastTypeWorkshop;
    return broadcastType; // unknown type: pass through
  }

  void _syncTicker() {
    if (_broadcasts.isEmpty) {
      _tick?.cancel();
      _tick = null;
      return;
    }
    if (_tick != null) return;
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      final before = _broadcasts.length;
      _pruneExpired();
      if (_broadcasts.length != before) {
        _syncBackgroundPoll();
        if (_broadcasts.isEmpty) {
          _tick?.cancel();
          _tick = null;
        }
      }
      if (_broadcasts.isNotEmpty) notifyListeners();
    });
  }

  void _syncBackgroundPoll() {
    if (_broadcasts.isEmpty) {
      _backgroundPoll?.cancel();
      _backgroundPoll = null;
      return;
    }
    _backgroundPoll ??= Timer.periodic(const Duration(seconds: 45), (_) {
      fetchActive(silent: true);
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _socketDebounce?.cancel();
    _backgroundPoll?.cancel();
    _realtime.off(RealtimeService.eventCashierBroadcastUpdated, _onSocketBroadcast);
    super.dispose();
  }
}