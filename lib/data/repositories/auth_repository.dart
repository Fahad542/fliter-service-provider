import '../network/api_constants.dart';
import '../network/base_api_service.dart';
import '../../models/auth_response_model.dart';

class AuthRepository {
  final BaseApiService _apiService = BaseApiService();

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        ApiConstants.loginEndpoint,
        {
          'email': email,
          'password': password,
        },
      );
      return AuthResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
  Future<AuthResponse> adminLogin(String email, String password) async {
    try {
      final response = await _apiService.post(
        ApiConstants.adminLoginEndpoint,
        {
          'email': email,
          'password': password,
        },
      );
      return AuthResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> superAdminLogin(String email, String password) async {
    try {
      final response = await _apiService.post(
        ApiConstants.superAdminLoginEndpoint,
        {
          'email': email,
          'password': password,
        },
      );
      return AuthResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> registerWorkshopOwner({
    required String name,
    required String email,
    required String password,
    required String ownerName,
    required String mobile,
    required String taxId,
    required String address,
    required double gpsLat,
    required double gpsLng,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.adminRegisterEndpoint,
        {
          'name': name,
          'email': email,
          'password': password,
          'ownerName': ownerName,
          'mobile': mobile,
          'taxId': taxId,
          'address': address,
          'gpsLat': gpsLat,
          'gpsLng': gpsLng,
        },
      );
      return AuthResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> technicianLogin(String email, String password) async {
    try {
      final response = await _apiService.post(
        ApiConstants.technicianLoginEndpoint,
        {
          'email': email,
          'password': password,
        },
      );
      return AuthResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> openSession(String email, String password, String token) async {
    try {
      final response = await _apiService.post(
        ApiConstants.openSessionEndpoint,
        {
          'email': email,
          'password': password,
        },
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> closeSession(String email, String password, String token) async {
    try {
      final response = await _apiService.post(
        ApiConstants.closeSessionEndpoint,
        {
          'email': email,
          'password': password,
        },
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getCurrentSession(String email, String password, String token) async {
    try {
      final response = await _apiService.getWithBody(
        ApiConstants.currentSessionEndpoint,
        {
          'email': email,
          'password': password,
        },
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
