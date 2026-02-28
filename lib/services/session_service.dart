import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_response_model.dart';

class SessionService {
  Future<void> saveSession(AuthResponse authResponse, {String role = 'cashier'}) async {
    final prefs = await SharedPreferences.getInstance();
    if (authResponse.token != null) {
      print('Saving $role Token: ${authResponse.token}');
      await prefs.setString('${role}_auth_token', authResponse.token!);
    }
    if (authResponse.user != null) {
      final userData = jsonEncode(authResponse.user!.toJson());
      print('Saving $role User Data: $userData');
      await prefs.setString('${role}_user_data', userData);
    }
  }

  Future<String?> getToken({String role = 'cashier'}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('${role}_auth_token');
    print('Retrieved $role Token: $token');
    return token;
  }

  Future<User?> getUser({String role = 'cashier'}) async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('${role}_user_data');
    print('Retrieved $role User Data: $userData');
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }

  Future<void> clearSession({String role = 'cashier'}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${role}_auth_token');
    await prefs.remove('${role}_user_data');
  }

  Future<bool> isLoggedIn({String role = 'cashier'}) async {
    final token = await getToken(role: role);
    return token != null;
  }

  Future<void> saveLastPortal(String portal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_portal', portal);
  }

  Future<String?> getLastPortal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_portal');
  }
}
