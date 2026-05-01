import 'package:flutter/material.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../services/session_service.dart';
import '../../../../models/current_session_model.dart';

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

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isOpeningShift = false;
  bool get isOpeningShift => _isOpeningShift;

  Future<void> openShift() async {
    _isOpeningShift = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final creds = await _sessionService.getCredentials();
      final token = await _sessionService.getToken();

      if (creds == null || token == null) {
        throw Exception('User credentials or token missing.');
      }

      final response = await _authRepository.openSession(
        creds['email']!,
        creds['password']!,
        token,
      );
      if (response is Map) {
        final map = Map<String, dynamic>.from(response);
        final payload =
            map['data'] is Map ? Map<String, dynamic>.from(map['data'] as Map) : map;
        if (payload['success'] == false) {
          throw Exception(payload['message']?.toString() ?? 'Shift did not open.');
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to start shift: $e';
      _currentSession = null;
      _isOpeningShift = false;
      notifyListeners();
      return;
    }

    _isOpeningShift = false;
    notifyListeners();
    fetchCurrentSession();
  }

  void fetchCurrentSession() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final creds = await _sessionService.getCredentials();
      final token = await _sessionService.getToken();

      if (creds == null || token == null) {
        throw Exception('User credentials or token missing.');
      }

      final response = await _authRepository.getCurrentSession(token);
      final sessionResponse = CurrentSessionResponse.fromJson(
        response is Map<String, dynamic>
            ? response
            : Map<String, dynamic>.from(response as Map),
      );

      if (!sessionResponse.success) {
        _currentSession = null;
        _errorMessage = 'Failed to fetch shift details.';
      } else if (sessionResponse.hasOpenSession &&
          sessionResponse.session != null) {
        var session = sessionResponse.session;
        if (session != null &&
            (session.cashierName.isEmpty || session.cashierName == 'N/A')) {
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
        _errorMessage = null;
      } else {
        _currentSession = null;
        _errorMessage = null;
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch shift details: $e';
      _currentSession = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
