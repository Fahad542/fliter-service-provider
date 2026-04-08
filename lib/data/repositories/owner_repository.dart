import 'package:flutter/foundation.dart';
import '../../models/workshop_owner_models.dart';
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
        ApiConstants.corporateRegisterEndpoint,
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

  Future<dynamic> getProductsCategories(String token, String type) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.getProductsCategoriesEndpoint}?type=$type',
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

  Future<dynamic> createSubCategory(Map<String, dynamic> data, String token) async {
    try {
      final response = await _apiService.post(
        ApiConstants.createSubCategoryEndpoint, // Use the proper endpoint
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

  Future<dynamic> getEmployees(String token) async {
    try {
      final response = await _apiService.get(
        ApiConstants.employeesEndpoint,
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

  Future<dynamic> getReferrers(String token, {String? search}) async {
    try {
      String endpoint = ApiConstants.referrersEndpoint;
      if (search != null && search.trim().isNotEmpty) {
        endpoint += '?search=${Uri.encodeQueryComponent(search.trim())}';
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
          'Content-Type': 'application/json',
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

  Future<dynamic> getSubCategories(String token, String categoryId) async {
    try {
      final response = await _apiService.getWithQueryParams(
        ApiConstants.getSubCategoriesEndpoint,
        {'categoryId': categoryId},
        token,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getProducts(String token, String workshopId, {String? departmentId}) async {
    try {
      String endpoint = '${ApiConstants.productsEndpoint}?workshopId=$workshopId';
      if (departmentId != null && departmentId.isNotEmpty) {
        endpoint += '&departmentId=$departmentId';
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

  Future<dynamic> getProductUnits(String token) async {
    try {
      final response = await _apiService.get(
        ApiConstants.productUnitsEndpoint,
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

  Future<dynamic> getWorkshopServices(String token) async {
    try {
      final response = await _apiService.get(
        ApiConstants.workshopServicesEndpoint,
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

  Future<dynamic> createWorkshopService(Map<String, dynamic> data, String token) async {
    try {
      final response = await _apiService.post(
        ApiConstants.workshopServicesEndpoint,
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

  Future<dynamic> getSupplierStats(String token) async {
    try {
      final response = await _apiService.get(
        ApiConstants.suppliersStatsEndpoint,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Supplier>> getSuppliers(String token) async {
    try {
      final response = await _apiService.get(
        ApiConstants.suppliersEndpoint,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response != null && response is Map<String, dynamic> && response['success'] == true) {
        final List<dynamic> suppliersData = response['suppliers'] ?? [];
        return suppliersData.map((json) => Supplier.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching suppliers: $e');
      return [];
    }
  }

  Future<dynamic> getAccountingSummary(String token) async {
    try {
      final response = await _apiService.get(
        ApiConstants.accountingSummaryEndpoint,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> createPurchaseOrder(Map<String, dynamic> data, String token) async {
    try {
      final response = await _apiService.post(
        ApiConstants.purchaseOrdersEndpoint,
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

  Future<dynamic> getAccountingTransactions(String token, String type) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.accountingTransactionsEndpoint}?type=$type',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getPosMonitoring(String token) async {
    try {
      final response = await _apiService.get(
        ApiConstants.posMonitoringEndpoint,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// [queue]: `fund` (default top-ups), `expense` (cashier POS expenses), `all`.
  Future<PettyCashRequestsResponse> getPettyCashRequests(
    String token, {
    String? status,
    String? branchId,
    String? queue,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final params = <String, String>{
        'limit': '$limit',
        'offset': '$offset',
      };
      if (status != null && status.isNotEmpty) params['status'] = status;
      if (branchId != null && branchId.isNotEmpty) params['branchId'] = branchId;
      if (queue != null && queue.isNotEmpty) params['queue'] = queue;

      final response = await _apiService.getWithQueryParams(
        ApiConstants.workshopPettyCashRequestsEndpoint,
        params,
        token,
      );
      return PettyCashRequestsResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// History endpoint for workshop petty-cash approvals:
  /// GET /workshop-staff/petty-cash/history
  Future<PettyCashRequestsResponse> getPettyCashHistory(
    String token, {
    String? status,
    String? branchId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final params = <String, String>{
        'limit': '$limit',
        'offset': '$offset',
      };
      if (status != null && status.isNotEmpty) params['status'] = status;
      if (branchId != null && branchId.isNotEmpty) params['branchId'] = branchId;

      final response = await _apiService.getWithQueryParams(
        ApiConstants.workshopPettyCashHistoryEndpoint,
        params,
        token,
      );
      return PettyCashRequestsResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> approvePettyCashRequest(String token, String requestId) async {
    try {
      final response = await _apiService.post(
        ApiConstants.workshopPettyCashApproveEndpoint(requestId),
        {},
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return response['success'] == true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> rejectPettyCashRequest(String token, String requestId, String rejectionReason) async {
    try {
      final response = await _apiService.post(
        ApiConstants.workshopPettyCashRejectEndpoint(requestId),
        {'rejectionReason': rejectionReason},
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return response['success'] == true;
    } catch (e) {
      rethrow;
    }
  }

  // Promo Codes
  Future<dynamic> updatePromoCode(String token, String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.patch(
        ApiConstants.workshopPromoCodeByIdEndpoint(id),
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

  Future<dynamic> deletePromoCode(String token, String id) async {
    try {
      final response = await _apiService.delete(
        ApiConstants.workshopPromoCodeByIdEndpoint(id),
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

  // Products
  Future<dynamic> updateProduct(String token, String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.patch(
        '/workshop-staff/product/$id',
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

  Future<dynamic> deleteProduct(String token, String id) async {
    try {
      final response = await _apiService.delete(
        '/workshop-staff/product/$id',
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
  // Services
  Future<dynamic> updateService(String token, String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.patch(
        '/workshop-staff/service/$id',
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

  Future<dynamic> deleteService(String token, String id) async {
    try {
      final response = await _apiService.delete(
        '/workshop-staff/service/$id',
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

  // Categories
  Future<dynamic> updateCategory(String token, String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.patch(
        ApiConstants.editCategoryEndpoint(id),
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

  Future<dynamic> updateCorporateAccount(String token, String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.patch(
        ApiConstants.editCorporateAccountEndpoint(id),
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

  Future<dynamic> deleteCategory(String token, String id) async {
    try {
      final response = await _apiService.delete(
        '${ApiConstants.categoriesEndpoint}/$id',
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

  // Sub-Categories
  Future<dynamic> updateSubCategory(String token, String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.patch(
        '${ApiConstants.createSubCategoryEndpoint}/$id',
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

  Future<dynamic> deleteSubCategory(String token, String id) async {
    try {
      final response = await _apiService.delete(
        '${ApiConstants.createSubCategoryEndpoint}/$id',
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

  // Employees
  Future<dynamic> updateTechnician(String token, String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.patch(
        '/workshop-staff/technician/$id',
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

  Future<dynamic> deleteTechnician(String token, String id) async {
    try {
      final response = await _apiService.delete(
        '/workshop-staff/technician/$id',
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

  Future<dynamic> updateCashier(String token, String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.patch(
        '/workshop-staff/cashier/$id',
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

  Future<dynamic> deleteCashier(String token, String id) async {
    try {
      final response = await _apiService.delete(
        '/workshop-staff/cashier/$id',
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

  // Branches
  Future<dynamic> updateBranch(String token, String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.patch(
        '/workshop-staff/branch/$id',
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

  Future<dynamic> deleteBranch(String token, String id) async {
    try {
      final response = await _apiService.delete(
        '${ApiConstants.deleteBranchEndpoint}/$id',
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

  // Departments
  Future<dynamic> updateDepartment(String token, String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.patch(
        '${ApiConstants.deleteDepartmentEndpoint}/$id',
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

  Future<dynamic> deleteDepartment(String token, String id) async {
    try {
      final response = await _apiService.delete(
        '${ApiConstants.deleteDepartmentEndpoint}/$id',
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

