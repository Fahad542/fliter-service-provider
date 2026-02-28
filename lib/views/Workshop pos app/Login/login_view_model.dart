import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../services/session_service.dart';
// import '../../data/repositories/auth_repository.dart';
// import '../../services/session_service.dart';
// import '../../data/network/api_response.dart';

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
      _setLoading(false);
      return true;
    } catch (e) {
      _setErrorMessage(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await _sessionService.clearSession();
    notifyListeners();
  }
}
