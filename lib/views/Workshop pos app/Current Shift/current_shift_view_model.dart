import 'package:flutter/material.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../services/session_service.dart';
import '../../../../models/current_session_model.dart';
import '../../../../l10n/app_localizations.dart';

/// Error keys used by the view model — the *view* resolves them to translated
/// strings via [CurrentShiftViewModel.resolveError].  This keeps the VM free
/// of BuildContext while still supporting locale switches without a refetch.
enum _ShiftError { sessionMissing, noActiveShift, fetchFailed }

class CurrentShiftViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final SessionService _sessionService;

  CurrentShiftViewModel({
    required AuthRepository authRepository,
    required SessionService sessionService,
  })  : _authRepository = authRepository,
        _sessionService = sessionService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  CurrentSession? _currentSession;
  CurrentSession? get currentSession => _currentSession;

  /// Raw technical error (shown by view via [resolveError]).
  _ShiftError? _errorKey;
  String? _rawErrorDetail;

  /// Returns a translated, human-readable error string for the current locale.
  /// Call this from the view instead of storing a pre-baked string.
  String? resolveError(AppLocalizations l10n) {
    switch (_errorKey) {
      case _ShiftError.sessionMissing:
        return l10n.posCurrentShiftSessionExpiredError;
      case _ShiftError.noActiveShift:
        return l10n.posCurrentShiftNoActiveShiftFound;
      case _ShiftError.fetchFailed:
        return l10n.posCurrentShiftFetchError(_rawErrorDetail ?? '');
      case null:
        return null;
    }
  }

  /// Legacy getter kept for any callers not yet migrated; prefer [resolveError].
  String? get errorMessage => _rawErrorDetail;

  void fetchCurrentSession() async {
    _isLoading = true;
    _errorKey = null;
    _rawErrorDetail = null;
    notifyListeners();

    try {
      final creds = await _sessionService.getCredentials();
      final token = await _sessionService.getToken();

      if (creds == null || token == null) {
        _errorKey = _ShiftError.sessionMissing;
        _rawErrorDetail = 'User credentials or token missing.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _authRepository.getCurrentSession(
        creds['email']!,
        creds['password']!,
        token,
      );

      final sessionResponse = CurrentSessionResponse.fromJson(response);

      if (sessionResponse.success && sessionResponse.hasOpenSession) {
        var session = sessionResponse.session;
        if (session != null && (session.cashierName.isEmpty || session.cashierName == 'N/A')) {
          final user = await _sessionService.getUser();
          if (user != null) {
            session = CurrentSession(
              posSessionId: session.posSessionId,
              branchId: session.branchId,
              branchName: session.branchName,
              branchAddress: session.branchAddress,
              cashierName: user.name ?? 'Cashier',
              openedAt: session.openedAt,
              status: session.status.isEmpty ? 'Active' : session.status,
              elapsedTime: session.elapsedTime,
            );
          }
        }
        _currentSession = session;
      } else {
        _currentSession = null;
        _errorKey = _ShiftError.noActiveShift;
        _rawErrorDetail = 'No active shift found.';
      }
    } catch (e) {
      _errorKey = _ShiftError.fetchFailed;
      _rawErrorDetail = e.toString();
      _currentSession = null;
    }

    _isLoading = false;
    notifyListeners();
  }
}