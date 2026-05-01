import 'package:flutter/material.dart';
import '../../../../models/workshop_owner_models.dart';
import '../../../../data/repositories/owner_repository.dart';
import '../../../../services/session_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../../services/locker_translation_mixin.dart' as dynamic_i18n;

/// Mixin that gives any ChangeNotifier access to a BuildContext so it can
/// resolve localised strings for toast messages.
///
/// Usage:
///   1. Add `with TranslatableMixin` to your ViewModel.
///   2. Call `setContext(context)` from your View's `initState` /
///      `didChangeDependencies` (after the first frame if needed).
///   3. Use `l10n` inside the ViewModel to get translated strings.
///
/// IMPORTANT: Never store the context beyond a single method call.
/// This mixin deliberately exposes only AppLocalizations, not the full
/// context, so locale is always fresh on every method invocation.
mixin TranslatableMixin on ChangeNotifier {
  BuildContext? _ctx;

  void setContext(BuildContext context) {
    _ctx = context;
  }

  /// Returns localised strings if a context is available, or null.
  /// Always call this inside an async method *after* awaiting, using the
  /// stored context — but verify `_ctx?.mounted == true` first.
  AppLocalizations? get l10n {
    final ctx = _ctx;
    if (ctx == null) return null;
    return AppLocalizations.of(ctx);
  }
}

// ---------------------------------------------------------------------------

class PosMonitoringViewModel extends ChangeNotifier with TranslatableMixin {
  final OwnerRepository ownerRepository;
  final SessionService sessionService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  PosMonitoringResponse? _monitoringResponse;
  PosMonitoringResponse? get monitoringResponse => _monitoringResponse;

  final Map<String, String> _translatedBranchNames = {};
  final Map<String, String> _translatedCashierNames = {};

  String branchDisplayName(PosCounter counter) =>
      _translatedBranchNames[counter.id] ?? counter.branchName;

  String cashierDisplayName(PosCounter counter) =>
      _translatedCashierNames[counter.id] ?? counter.cashierName;

  PosMonitoringViewModel({
    required this.ownerRepository,
    required this.sessionService,
  });

  Future<void> fetchPosMonitoring() async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await sessionService.getToken(role: 'owner');
      if (token != null) {
        final response = await ownerRepository.getPosMonitoring(token);
        if (response != null && response['success'] == true) {
          _monitoringResponse = PosMonitoringResponse.fromJson(response);
          await _translateCounters();
        }
      }
    } catch (e) {
      debugPrint('Error fetching POS monitoring: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> _translateCounters() async {
    _translatedBranchNames.clear();
    _translatedCashierNames.clear();
    final counters = <PosCounter>[
      ...?_monitoringResponse?.liveCounters,
      ...?_monitoringResponse?.closingReports,
    ];
    for (final counter in counters) {
      if (counter.branchName.trim().isNotEmpty) {
        _translatedBranchNames[counter.id] =
            await dynamic_i18n.AppTranslationService.localizedText(
          counter.branchName,
        );
      }
      if (counter.cashierName.trim().isNotEmpty) {
        _translatedCashierNames[counter.id] =
            await dynamic_i18n.AppTranslationService.localizedText(
          counter.cashierName,
        );
      }
    }
  }

  Future<void> onLocaleChanged() async {
    await _translateCounters();
    notifyListeners();
  }

  @override
  void dispose() {
    _ctx = null;
    super.dispose();
  }
}