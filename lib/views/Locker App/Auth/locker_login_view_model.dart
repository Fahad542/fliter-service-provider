import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/network/base_api_service.dart';
import '../../../services/session_service.dart';

class LockerLoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final SessionService _sessionService = SessionService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Returns true on success, false on failure.
  Future<bool> login(String email, String password) async {
    _setError(null);
    _setLoading(true);

    try {
      final authResponse = await _authRepository.lockerLogin(email, password);

      if (authResponse.success == true) {
        await _sessionService.saveSession(authResponse, role: 'locker');
        await _sessionService.saveLastPortal('locker');  // ← add this line
        return true;
      } else {
        _setError(authResponse.message ?? 'Login failed. Please try again.');
        return false;
      }
    } on BadRequestException catch (e) {
      _setError(e.toString().replaceFirst('Invalid Request: ', ''));
      return false;
    } on UnauthorisedException catch (e) {
      _setError(e.toString().replaceFirst('Unauthorised: ', ''));
      return false;
    } on FetchDataException catch (e) {
      _setError(e.toString().replaceFirst('Error During Communication: ', ''));
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
