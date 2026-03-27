import 'package:flutter/material.dart';

class SupplierLoginViewModel extends ChangeNotifier {
  final TextEditingController mobileEmailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get obscurePassword => _obscurePassword;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Returns true if login succeeded. Caller navigates to SupplierHomeView.
  Future<bool> login() async {
    final mobileEmail = mobileEmailController.text.trim();
    final password = passwordController.text;

    if (mobileEmail.isEmpty) {
      _errorMessage = 'Please enter mobile or email';
      notifyListeners();
      return false;
    }
    if (password.isEmpty) {
      _errorMessage = 'Please enter password';
      notifyListeners();
      return false;
    }

    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      // Stub: simulate API call
      await Future.delayed(const Duration(milliseconds: 800));
      // For now always succeed; replace with AuthRepository when API exists
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    mobileEmailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
