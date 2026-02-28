import 'package:flutter/material.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../services/session_service.dart';

class OwnerLoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final SessionService _sessionService;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  OwnerLoginViewModel({
    required AuthRepository authRepository,
    required SessionService sessionService,
  })  : _authRepository = authRepository,
        _sessionService = sessionService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

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

  Future<bool> login() async {
    if (!formKey.currentState!.validate()) return false;

    _setLoading(true);
    _setErrorMessage(null);

    try {
      final authResponse = await _authRepository.adminLogin(
        emailController.text.trim(),
        passwordController.text,
      );
      
      if (authResponse.success == false) {
        _setErrorMessage(authResponse.message ?? 'Invalid email or password');
        _setLoading(false);
        return false;
      }

      await _sessionService.saveSession(authResponse, role: 'owner');
      _setLoading(false);
      return true;
    } catch (e) {
      _setErrorMessage(e.toString());
      _setLoading(false);
      return false;
    }
  }

  void clear() {
    emailController.clear();
    passwordController.clear();
    _errorMessage = null;
    _isLoading = false;
    _obscurePassword = true;
  }
}
