import '../network/api_constants.dart';
import '../network/base_api_service.dart';

class OwnerRepository {
  final BaseApiService _apiService = BaseApiService();

  Future<dynamic> createBranch(Map<String, dynamic> data, String token) async {
    try {
      final response = await _apiService.post(
        ApiConstants.createBranchEndpoint,
        data,
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

  Future<dynamic> createDepartment(Map<String, dynamic> data, String token) async {
    try {
      final response = await _apiService.post(
        ApiConstants.createDepartmentEndpoint,
        data,
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

  Future<dynamic> createCorporateAccount(Map<String, dynamic> data, String token) async {
    try {
      final response = await _apiService.post(
        ApiConstants.createCorporateAccountEndpoint,
        data,
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

  Future<dynamic> createCorporateUser(Map<String, dynamic> data, String token) async {
    try {
      final response = await _apiService.post(
        ApiConstants.createCorporateUserEndpoint,
        data,
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

  Future<dynamic> createTechnician(Map<String, dynamic> data, String token) async {
    try {
      final response = await _apiService.post(
        ApiConstants.createTechnicianEndpoint,
        data,
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

  Future<dynamic> createCashier(Map<String, dynamic> data, String token) async {
    try {
      final response = await _apiService.post(
        ApiConstants.createCashierEndpoint,
        data,
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

  Future<dynamic> createSupplier(Map<String, dynamic> data, String token) async {
    try {
      final response = await _apiService.post(
        ApiConstants.createSupplierEndpoint,
        data,
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

  Future<dynamic> createProduct(Map<String, dynamic> data, String token) async {
    try {
      final response = await _apiService.post(
        ApiConstants.productsEndpoint,
        data,
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

  Future<dynamic> getBranches(String token) async {
    try {
      final response = await _apiService.get(
        ApiConstants.getBranchesEndpoint,
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

  Future<dynamic> getTechnicians(String token) async {
    try {
      final response = await _apiService.get(
        ApiConstants.techniciansEndpoint,
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

  Future<dynamic> getDepartments(String token) async {
    try {
      final response = await _apiService.get(
        ApiConstants.departmentsEndpoint,
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

