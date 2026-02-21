import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_response_model.dart';

class SessionService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  Future<void> saveSession(AuthResponse authResponse) async {
    final prefs = await SharedPreferences.getInstance();
    if (authResponse.token != null) {
      print('Saving Token: ${authResponse.token}');
      await prefs.setString(_tokenKey, authResponse.token!);
    }
    if (authResponse.user != null) {
      final userData = jsonEncode(authResponse.user!.toJson());
      print('Saving User Data: $userData');
      await prefs.setString(_userKey, userData);
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    print('Retrieved Token: $token');
    return token;
  }

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    print('Retrieved User Data: $userData');
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
