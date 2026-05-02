import 'package:flutter/material.dart';
import '../../../../models/workshop_owner_models.dart';
import '../../../../data/repositories/owner_repository.dart';
import '../../../../services/session_service.dart';
import '../../../../services/locker_translation_mixin.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ReportsManagementViewModel
//
// • Uses TranslatableMixin for all dynamic API strings (tech names, day labels).
// • Exposes pre-translated display lists so the View never calls async methods.
// • Re-fetches + re-translates whenever the locale changes (locale-switch safe).
// ─────────────────────────────────────────────────────────────────────────────

class ReportsManagementViewModel extends ChangeNotifier
    with TranslatableMixin {
  final OwnerRepository ownerRepository;
  final SessionService sessionService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // ── Raw API response ───────────────────────────────────────────────────────
  ReportsAnalyticsResponse? _reportsData;
  ReportsAnalyticsResponse? get reportsData => _reportsData;

  // ── Pre-translated display values (consumed by the View synchronously) ─────

  /// Translated tech/employee names in the same order as
  /// [reportsData.operationalPerformance].
  List<String> translatedTechNames = [];

  /// Translated day-of-week labels for the bar chart (Mon, Tue …).
  /// The API sends English short names; we translate them for Arabic locale.
  List<String> translatedDayLabels = [];

  // ── Current locale – used to detect locale switches ───────────────────────
  String _currentLocale = '';

  // ─────────────────────────────────────────────────────────────────────────
  ReportsManagementViewModel({
    required this.ownerRepository,
    required this.sessionService,
  }) {
    fetchReportsData();
  }

  // ── Public refresh (called by View on locale change via SettingsViewModel) ─
  Future<void> onLocaleChanged() async {
    final newLocale = await SessionService.getLocale();
    if (newLocale == _currentLocale) return; // nothing changed
    _currentLocale = newLocale;
    await _retranslate();
    notifyListeners();
  }

  // ── Main fetch ─────────────────────────────────────────────────────────────
  Future<void> fetchReportsData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final locale = await SessionService.getLocale();
      _currentLocale = locale;

      final token = await sessionService.getToken(role: 'owner');
      if (token == null) throw Exception('No token found');

      final response = await ownerRepository.getReportsAnalytics(token);

      if (response != null && response['success'] == true) {
        _reportsData = ReportsAnalyticsResponse.fromJson(response);
        await _retranslate();
      }
    } catch (e) {
      debugPrint('Error fetching reports data: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Translation pass ───────────────────────────────────────────────────────
  /// Translates all dynamic API strings in one pass.
  /// Safe to call multiple times (locale switch, refresh, etc.).
  Future<void> _retranslate() async {
    if (_reportsData == null) return;

    // 1. Technician / employee names from operationalPerformance
    final rawNames = _reportsData!.operationalPerformance
        .map((p) => p.name)
        .toList();
    translatedTechNames = await tAll(rawNames);

    // 2. Day-of-week labels from dailyRevenue
    //    API sends English abbreviations: Mon, Tue, Wed, Thu, Fri, Sat, Sun
    //    We translate them; numbers and date strings are left unchanged by
    //    AppTranslationService (numeric/reference guard).
    final rawDays = _reportsData!.financialOverview.dailyRevenue
        .map((d) => d.day)
        .toList();
    translatedDayLabels = await tAll(rawDays);
  }

  @override
  void dispose() {
    super.dispose();
  }
}