import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../services/session_service.dart';


class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final SessionService _sessionService;

  LoginViewModel({
    required AuthRepository authRepository,
    required SessionService sessionService,
  })  : _authRepository = authRepository,
        _sessionService = sessionService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // UI State (Moved from View)
  bool _obscurePassword = true;

  bool get obscurePassword => _obscurePassword;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? value) {
    _errorMessage = value;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final authResponse = await _authRepository.login(email, password);
      
      if (authResponse.success == false) {
        _setErrorMessage(authResponse.message ?? 'Invalid email or password');
        _setLoading(false);
        return false;
      }

      await _sessionService.saveSession(authResponse);
      await _sessionService.saveCredentials(email, password);

      if (authResponse.token != null) {
        try {
          await _authRepository.openSession(email, password, authResponse.token!);
        } catch (e) {
          debugPrint('Failed to open shift session: $e');
        }
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setErrorMessage(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final creds = await _sessionService.getCredentials();
      final token = await _sessionService.getToken();
      if (creds != null && token != null) {
        await _authRepository.closeSession(creds['email']!, creds['password']!, token);
      }
    } catch (e) {
      debugPrint('Failed to close shift session: $e');
    }

    await _sessionService.clearSession();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pos_user_email');
    await prefs.remove('pos_user_password');
    notifyListeners();
  }
}
