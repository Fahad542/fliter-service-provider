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
}
