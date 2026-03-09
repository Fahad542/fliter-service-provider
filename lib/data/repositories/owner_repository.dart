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

  Future<dynamic> getCorporateCustomers(String token) async {
    try {
      final response = await _apiService.get(
        ApiConstants.corporateCustomersEndpoint,
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
        ApiConstants.createProductEndpoint,
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

  Future<dynamic> createCategory(Map<String, dynamic> data, String token) async {
    try {
      final response = await _apiService.post(
        ApiConstants.createCategoryEndpoint,
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

  Future<dynamic> getBillingDashboard(String token) async {
    try {
      final response = await _apiService.get(
        ApiConstants.billingDashboardEndpoint,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getReportsAnalytics(String token) async {
    try {
      final response = await _apiService.get(
        ApiConstants.reportsAnalyticsEndpoint,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getPromoCodes(String token) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.promoCodesEndpoint}?isActive=true&limit=20&offset=0',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> createPromoCode(String token, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post(
        ApiConstants.createPromoCodeEndpoint,
        data,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getCategories(String token) async {
    try {
      final response = await _apiService.get(
        ApiConstants.categoriesEndpoint,
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

  Future<dynamic> getProducts(String token, String workshopId) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.productsEndpoint}?workshopId=$workshopId',
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

  Future<dynamic> getDashboardData(String token, {String? branchId}) async {
    try {
      String endpoint = ApiConstants.dashboardEndpoint;
      if (branchId != null && branchId.isNotEmpty) {
        endpoint += '?branchId=$branchId';
      }
      final response = await _apiService.get(
        endpoint,
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

