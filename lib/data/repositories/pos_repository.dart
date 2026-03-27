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
import '../../models/corporate_booking_model.dart'; // Added import
import '../../models/store_closing_api_model.dart'; // Added import
import '../../models/cashier_complete_job_model.dart';
import '../../models/cashier_corporate_accounts_api_model.dart';
import '../../models/invoiced_orders_model.dart';
import '../../models/submit_sales_return_model.dart';

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

  Future<AssignTechnicianResponse> assignTechnicians(
      String jobId, List<String> employeeIds, String token) async {
    try {
      final response = await _apiService.post(
        ApiConstants.assignTechnicianEndpoint(jobId),
        {'employeeIds': employeeIds},
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

  Future<CashierCompleteJobResponse> completeCashierJob(String jobId, String token) async {
    try {
      final response = await _apiService.post(
        ApiConstants.cashierCompleteJobEndpoint(jobId),
        {}, // No payload explicitly mapping per docs, just the URL parameter
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return CashierCompleteJobResponse.fromJson(response);
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

  Future<InvoicedOrderResponse> getInvoicedOrdersByCustomer(String customerId, String token) async {
    try {
      final response = await _apiService.get(
        ApiConstants.invoicedOrdersEndpoint(customerId),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return InvoicedOrderResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<SubmitSalesReturnResponse> submitSalesReturn(SubmitSalesReturnRequest request, String token) async {
    try {
      final response = await _apiService.post(
        ApiConstants.submitSalesReturnEndpoint,
        request.toJson(),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return SubmitSalesReturnResponse.fromJson(response);
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

  Future<ProductsResponse> getProducts(String workshopId, String token, {String? departmentId, String? branchId}) async {
    try {
      if (branchId != null && branchId.isNotEmpty) {
        final queryParams = <String, String>{};
        if (departmentId != null && departmentId.isNotEmpty) {
          queryParams['departmentId'] = departmentId;
        }
        
        final response = await _apiService.getWithQueryParams(
          ApiConstants.branchCatalogEndpoint(branchId),
          queryParams,
          token,
        );
        return ProductsResponse.fromJson(response);
      } else {
        final queryParams = {'workshopId': workshopId};
        if (departmentId != null && departmentId.isNotEmpty) {
          queryParams['departmentId'] = departmentId;
        }
        final response = await _apiService.getWithQueryParams(
          ApiConstants.productsEndpoint,
          queryParams,
          token,
        );
        return ProductsResponse.fromJson(response);
      }
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

  Future<PromoCodeListResponse> getPromoCodes(String token) async {
    try {
      final response = await _apiService.get(
        ApiConstants.cashierPromoCodesEndpoint,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return PromoCodeListResponse.fromJson(response);
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

  Future<CorporateBookingResponse> getCorporateBookings(String filter, String branchId, String token, {int limit = 20, int offset = 0}) async {
    try {
      final response = await _apiService.getWithQueryParams(
        ApiConstants.corporateBookingsEndpoint,
        {
          'filter': filter,
          'branchId': branchId,
          'limit': limit.toString(),
          'offset': offset.toString(),
        },
        token,
      );
      return CorporateBookingResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> approveCorporateBooking(String bookingId, String token) async {
    try {
      final response = await _apiService.post(
        ApiConstants.approveCorporateBookingEndpoint(bookingId),
        {},
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

  Future<bool> rejectCorporateBooking(String bookingId, String reason, String token) async {
    try {
      final response = await _apiService.post(
        ApiConstants.rejectCorporateBookingEndpoint(bookingId),
        {
          'reason': reason,
        },
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

  Future<CashierCorporateAccountsResponse> getCashierCorporateAccounts(String token) async {
    try {
      final response = await _apiService.get(
        ApiConstants.cashierCorporateAccountsEndpoint,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return CashierCorporateAccountsResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<StoreClosingApiResponse> getStoreClosing(String token, String date, String workshopId) async {
    try {
      final response = await _apiService.getWithQueryParams(
        ApiConstants.storeClosingEndpoint,
        {
          'date': date,
          if (workshopId.isNotEmpty) 'workshopId': workshopId,
        },
        token,
      );
      return StoreClosingApiResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
