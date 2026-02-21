import '../../models/department_model.dart';
import '../network/api_constants.dart';
import '../network/base_api_service.dart';
import '../../models/walk_in_customer_model.dart';
import '../../models/pos_technician_model.dart';
import '../../models/technician_assignment_model.dart';
import '../../models/pos_order_model.dart';
import '../../models/customer_search_model.dart';
import '../../models/pos_product_model.dart';
import '../../models/create_invoice_model.dart';
import '../../models/promo_code_model.dart';
import '../../models/expense_category_model.dart';
import '../../models/wallet_balance_model.dart'; // Added import

class PosRepository {
  final BaseApiService _apiService = BaseApiService();

  Future<WalkInCustomerResponse> createWalkInOrder(WalkInCustomerRequest request, String token) async {
    try {
      final response = await _apiService.post(
        ApiConstants.walkInCustomerEndpoint,
        request.toJson(),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return WalkInCustomerResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<PosTechnicianResponse> getTechnicians(String token) async {
    try {
      final response = await _apiService.get(
        ApiConstants.techniciansEndpoint,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return PosTechnicianResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<AssignTechnicianResponse> assignTechnician(
      String jobId, String employeeId, String token) async {
    try {
      final response = await _apiService.post(
        ApiConstants.assignTechnicianEndpoint(jobId),
        {'employeeId': employeeId},
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return AssignTechnicianResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<CashierOrdersResponse> getCashierOrders(String token) async {
    try {
      final response = await _apiService.get(
        ApiConstants.cashierOrdersEndpoint,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return CashierOrdersResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<CustomerSearchResponse> searchCustomers(Map<String, String> queryParams, String token) async {
    try {
      final response = await _apiService.getWithQueryParams(
        ApiConstants.searchCustomerEndpoint,
        queryParams,
        token,
      );
      return CustomerSearchResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<ProductsResponse> getProducts(String workshopId, String token) async {
    try {
      final response = await _apiService.getWithQueryParams(
        ApiConstants.productsEndpoint,
        {'workshopId': workshopId},
        token,
      );
      return ProductsResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<CreateInvoiceResponse> createInvoice(CreateInvoiceRequest request, String token) async {
    try {
      final response = await _apiService.post(
        ApiConstants.createInvoiceEndpoint,
        request.toJson(),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return CreateInvoiceResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<CreateInvoiceResponse> getInvoiceByOrder(String orderId, String token) async {
    try {
      final response = await _apiService.post(
        ApiConstants.getInvoiceByOrderEndpoint,
        {'orderId': orderId},
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return CreateInvoiceResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<PromoCodeResponse> applyPromoCode(String code, double orderAmount, String token) async {
    try {
      final response = await _apiService.post(
        ApiConstants.promoCodeApplyEndpoint,
        {
          'code': code,
          'orderAmount': orderAmount,
        },
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return PromoCodeResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<ExpenseCategoriesResponse> getExpenseCategories(String token) async {
    try {
      final response = await _apiService.get(
        ApiConstants.expenseCategoriesEndpoint,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return ExpenseCategoriesResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> submitExpense(Map<String, dynamic> data, String token) async {
    try {
      final response = await _apiService.post(
        ApiConstants.expenseSubmitEndpoint,
        data,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response['success'] is bool) {
        return response['success'];
      } else if (response['success'] is String) {
        return response['success'].toString().toLowerCase() == 'true';
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<WalletBalanceResponse> getWalletBalance(String token) async {
    try {
      final response = await _apiService.get(
        ApiConstants.walletBalanceEndpoint,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return WalletBalanceResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<DepartmentResponse> getDepartments(String token) async {
    try {
      final response = await _apiService.get(
        ApiConstants.departmentsEndpoint,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return DepartmentResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
