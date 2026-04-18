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
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/expense_category_model.dart';
import '../../models/cashier_expense_models.dart';
import '../../models/wallet_balance_model.dart'; // Added import
import '../../models/corporate_booking_model.dart'; // Added import
import '../../models/store_closing_api_model.dart'; // Added import
import '../../models/cashier_complete_job_model.dart';
import '../../models/cashier_corporate_accounts_api_model.dart';
import '../../models/invoiced_orders_model.dart';
import '../../models/submit_sales_return_model.dart';
import '../../models/sales_return_list_model.dart';
import '../../models/takeaway_models.dart';


class PosRepository {
  final BaseApiService _apiService = BaseApiService();

  String _safeEncode(Object? data) {
    try {
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      return data.toString();
    }
  }

  void _logWalkInRequest(String endpoint, Object? body) {
    debugPrint('[WALKIN][REQUEST] $endpoint');
    if (body != null) {
      debugPrint(_safeEncode(body));
    }
  }

  void _logWalkInResponse(String endpoint, Object? response) {
    debugPrint('[WALKIN][RESPONSE] $endpoint');
    debugPrint(_safeEncode(response));
  }

  void _logWalkInError(String endpoint, Object error) {
    debugPrint('[WALKIN][ERROR] $endpoint');
    debugPrint(error.toString());
  }

  Future<WalkInCustomerResponse> createWalkInOrder(WalkInCustomerRequest request, String token) async {
    const endpoint = ApiConstants.walkInCustomerEndpoint;
    final body = request.toJson();
    _logWalkInRequest(endpoint, body);
    try {
      final response = await _apiService.post(
        endpoint,
        body,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      _logWalkInResponse(endpoint, response);
      return WalkInCustomerResponse.fromJson(response);
    } catch (e) {
      _logWalkInError(endpoint, e);
      rethrow;
    }
  }

  /// POST /cashier/walk-in-order with an explicit JSON body (e.g. shell create: vehicle + departmentIds only).
  Future<WalkInCustomerResponse> postWalkInOrder(
    Map<String, dynamic> body,
    String token,
  ) async {
    const endpoint = ApiConstants.walkInCustomerEndpoint;
    _logWalkInRequest(endpoint, body);
    try {
      final response = await _apiService.post(
        endpoint,
        body,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      _logWalkInResponse(endpoint, response);
      return WalkInCustomerResponse.fromJson(response);
    } catch (e) {
      _logWalkInError(endpoint, e);
      rethrow;
    }
  }

  /// POST /cashier/order/:orderId/jobs — append departments as new pending jobs.
  Future<Map<String, dynamic>> addJobsToCashierOrder(
    String orderId,
    List<String> departmentIds,
    String token,
  ) async {
    final endpoint = ApiConstants.cashierOrderJobsEndpoint(orderId);
    final body = {'departmentIds': departmentIds};
    _logWalkInRequest(endpoint, body);
    try {
      final response = await _apiService.post(
        endpoint,
        body,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      _logWalkInResponse(endpoint, response);
      return response;
    } catch (e) {
      _logWalkInError(endpoint, e);
      rethrow;
    }
  }

  /// GET /cashier/technicians?departmentId=…
  Future<PosTechnicianResponse> getCashierTechnicians(
    String token, {
    String? departmentId,
  }) async {
    final endpoint = ApiConstants.cashierTechniciansEndpoint;
    _logWalkInRequest(endpoint, {'departmentId': departmentId});
    try {
      final Map<String, String> qp = {};
      if (departmentId != null && departmentId.trim().isNotEmpty) {
        qp['departmentId'] = departmentId.trim();
      }
      final dynamic response = qp.isEmpty
          ? await _apiService.get(
              ApiConstants.cashierTechniciansEndpoint,
              headers: {'Authorization': 'Bearer $token'},
            )
          : await _apiService.getWithQueryParams(
              ApiConstants.cashierTechniciansEndpoint,
              qp,
              token,
            );
      if (kDebugMode) {
        final m = response as Map<String, dynamic>;
        final list = m['technicians'];
        final n = list is List ? list.length : 0;
        debugPrint('[POS] GET $endpoint → $n technicians');
      }
      return PosTechnicianResponse.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      _logWalkInError(endpoint, e);
      rethrow;
    }
  }

  /// PATCH /cashier/job/:jobId/cancel
  Future<Map<String, dynamic>> cancelCashierJob(
    String jobId,
    String reason,
    String token,
  ) async {
    final endpoint = ApiConstants.cashierJobCancelEndpoint(jobId);
    final body = {'reason': reason};
    _logWalkInRequest(endpoint, body);
    try {
      final response = await _apiService.patch(
        endpoint,
        body,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      _logWalkInResponse(endpoint, response);
      return response;
    } catch (e) {
      _logWalkInError(endpoint, e);
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

  /// POST body includes `{ employeeIds: [...], sync: true }` when [ApiConstants.cashierAssignSendSyncReplace].
  /// Response may include `sync`, `removedCount`, and a detailed `message` (roster synced / unchanged).
  Future<AssignTechnicianResponse> assignTechnicians(
      String jobId, List<String> employeeIds, String token) async {
    final endpoint = ApiConstants.assignTechnicianEndpoint(jobId);
    final body = <String, dynamic>{'employeeIds': employeeIds};
    if (ApiConstants.cashierAssignSendSyncReplace) {
      body['sync'] = true;
    }
    _logWalkInRequest(endpoint, body);
    try {
      final response = await _apiService.post(
        endpoint,
        body,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      _logWalkInResponse(endpoint, response);
      return AssignTechnicianResponse.fromJson(response);
    } catch (e) {
      _logWalkInError(endpoint, e);
      rethrow;
    }
  }

  /// [dutyMode] e.g. `workshop` or `on_call` — sent as JSON `type` per backend.
  Future<Map<String, dynamic>> postJobBroadcast(
    String jobId,
    String dutyMode,
    String token,
  ) async {
    try {
      return await _apiService.post(
        ApiConstants.cashierJobBroadcastEndpoint(jobId),
        {'type': dutyMode},
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> cancelJobBroadcast(String jobId, String token) async {
    try {
      return await _apiService.post(
        ApiConstants.cashierJobBroadcastCancelEndpoint(jobId),
        {},
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<CashierCompleteJobResponse> completeCashierJob(String jobId, String token, {Map<String, dynamic>? body}) async {
    final endpoint = ApiConstants.cashierCompleteJobEndpoint(jobId);
    final reqBody = body ?? {};
    _logWalkInRequest(endpoint, reqBody);
    try {
      final response = await _apiService.post(
        endpoint,
        reqBody,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      _logWalkInResponse(endpoint, response);
      return CashierCompleteJobResponse.fromJson(response);
    } catch (e) {
      _logWalkInError(endpoint, e);
      rethrow;
    }
  }

  /// POST body replaces line items for that job when the backend implements replace-all semantics.
  /// If the server **merges** lines instead, clearing/removing products from the cashier cart
  /// may not remove old lines — confirm with backend.
  Future<Map<String, dynamic>> updateJobPricing(
    String jobId,
    Map<String, dynamic> body,
    String token,
  ) async {
    final endpoint = ApiConstants.cashierJobPricingEndpoint(jobId);
    _logWalkInRequest(endpoint, body);
    try {
      final response = await _apiService.post(
        endpoint,
        body,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      _logWalkInResponse(endpoint, response);
      return response;
    } catch (e) {
      _logWalkInError(endpoint, e);
      rethrow;
    }
  }

  /// Unlocks a **completed** job for pricing/technician edits (`completed` → `edited`).
  ///
  /// Tries **PATCH** first (contract); if production only registered **POST** (common mismatch),
  /// retries once with POST on the same path. A **404** on both means the route is not deployed
  /// on that server — backend must expose `/cashier/job/:jobId/mark-edited`.
  Future<Map<String, dynamic>> markCashierJobEdited(String jobId, String token) async {
    final endpoint = ApiConstants.cashierJobMarkEditedEndpoint(jobId);
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    try {
      final response = await _apiService.patch(
        endpoint,
        <String, dynamic>{},
        headers: headers,
      );
      _logWalkInResponse(endpoint, response);
      return response as Map<String, dynamic>;
    } catch (e) {
      final lower = e.toString().toLowerCase();
      // Express: "Cannot PATCH /cashier/job/…/mark-edited" when no PATCH handler exists.
      if (lower.contains('cannot patch')) {
        try {
          if (kDebugMode) {
            debugPrint('[WALKIN] mark-edited: PATCH unavailable, retrying POST $endpoint');
          }
          final response = await _apiService.post(
            endpoint,
            <String, dynamic>{},
            headers: headers,
          );
          _logWalkInResponse('$endpoint (POST)', response);
          return response as Map<String, dynamic>;
        } catch (e2) {
          _logWalkInError('$endpoint (POST fallback)', e2);
          rethrow;
        }
      }
      _logWalkInError(endpoint, e);
      rethrow;
    }
  }

  Future<CashierJobReadyResponse> checkJobCompleteReady(
    String jobId,
    String token,
  ) async {
    try {
      final response = await _apiService.patch(
        ApiConstants.cashierCompleteReadyEndpoint(jobId),
        {},
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return CashierJobReadyResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<CashierOrdersResponse> getCashierOrders(
    String token, {
    String? status,
    int? limit,
    int? offset,
  }) async {
    final endpoint = ApiConstants.cashierOrdersEndpoint;
    _logWalkInRequest(endpoint, {'status': status, 'limit': limit, 'offset': offset});
    try {
      final Map<String, String> qp = {};
      if (status != null && status.trim().isNotEmpty) {
        qp['status'] = status.trim();
      }
      if (limit != null) qp['limit'] = limit.toString();
      if (offset != null) qp['offset'] = offset.toString();

      final dynamic response = qp.isEmpty
          ? await _apiService.get(
              ApiConstants.cashierOrdersEndpoint,
              headers: {'Authorization': 'Bearer $token'},
            )
          : await _apiService.getWithQueryParams(
              ApiConstants.cashierOrdersEndpoint,
              qp,
              token,
            );
      // Do not _logWalkInResponse here: payload is large and JsonEncoder blocks the UI isolate.
      if (kDebugMode) {
        final m = response as Map<String, dynamic>;
        final raw = m['orders'];
        final n = raw is List ? raw.length : 0;
        debugPrint('[POS] GET $endpoint → $n orders');
      }
      return CashierOrdersResponse.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      _logWalkInError(endpoint, e);
      rethrow;
    }
  }

  /// GET /cashier/order/:orderId — jobs, pendingDepartments, corporate fields.
  Future<Map<String, dynamic>> getCashierOrderDetail(String orderId, String token) async {
    final endpoint = ApiConstants.cashierOrderDetailEndpoint(orderId);
    _logWalkInRequest(endpoint, null);
    try {
      final response = await _apiService.get(
        endpoint,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      _logWalkInResponse(endpoint, response);
      return response as Map<String, dynamic>;
    } catch (e) {
      _logWalkInError(endpoint, e);
      rethrow;
    }
  }

  /// Corporate walk-in quote (no jobs until approved + start-department).
  Future<WalkInCustomerResponse> submitWalkInCorporateForApproval(
    WalkInCustomerRequest request,
    String token,
  ) async {
    try {
      final response = await _apiService.post(
        ApiConstants.cashierWalkInCorporateSubmitForApprovalEndpoint,
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

  /// After corporate approval — create one job for a department with pending lines.
  Future<Map<String, dynamic>> startCorporateWalkInDepartment(
    String orderId,
    String departmentId,
    String token,
  ) async {
    try {
      final response = await _apiService.post(
        ApiConstants.cashierWalkInCorporateStartDepartmentEndpoint(orderId),
        {'departmentId': departmentId},
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return response as Map<String, dynamic>;
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

  Future<Map<String, dynamic>> editOrder(String orderId, String jobId, Map<String, dynamic> body, String token) async {
    final endpoint = ApiConstants.editOrderEndpoint(orderId, jobId);
    _logWalkInRequest(endpoint, body);
    try {
      final response = await _apiService.patch(
        endpoint,
        body,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      _logWalkInResponse(endpoint, response);
      return response as Map<String, dynamic>;
    } catch (e) {
      _logWalkInError(endpoint, e);
      rethrow;
    }
  }

  /// PATCH /cashier/order/:orderId/billing — walk_in orders without corporate account only.
  Future<Map<String, dynamic>> patchWalkInOrderBilling(
    String orderId,
    Map<String, dynamic> body,
    String token,
  ) async {
    final endpoint = ApiConstants.cashierOrderBillingEndpoint(orderId);
    _logWalkInRequest(endpoint, body);
    try {
      final response = await _apiService.patch(
        endpoint,
        body,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      _logWalkInResponse(endpoint, response);
      return response as Map<String, dynamic>;
    } catch (e) {
      _logWalkInError(endpoint, e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> cancelOrder(String orderId, String reason, String token) async {
    final endpoint = ApiConstants.cancelOrderEndpoint(orderId);
    final body = {'reason': reason};
    _logWalkInRequest(endpoint, body);
    try {
      final response = await _apiService.post(
        endpoint,
        body,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      _logWalkInResponse(endpoint, response);
      return response as Map<String, dynamic>;
    } catch (e) {
      _logWalkInError(endpoint, e);
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
      return ExpenseCategoriesResponse.fromDynamic(response);
    } catch (e) {
      rethrow;
    }
  }

  /// [employeeId] only for Salary Advances; omitted when null/empty.
  /// Receipt: multipart field `proof` when [receiptFilePath] exists; else JSON (optional proofUrl in [extraJson]).
  Future<Map<String, dynamic>> submitExpense({
    required double amount,
    required String categoryId,
    required String description,
    String? employeeId,
    String? receiptFilePath,
    Map<String, dynamic>? extraJson,
    required String token,
  }) async {
    try {
      final path = receiptFilePath?.trim() ?? '';
      final hasFile = path.isNotEmpty && File(path).existsSync();
      final emp = employeeId?.trim();

      if (hasFile) {
        final fields = <String, String>{
          'amount': amount.toString(),
          'categoryId': categoryId,
          'description': description,
        };
        if (emp != null && emp.isNotEmpty) fields['employeeId'] = emp;
        final file = await http.MultipartFile.fromPath('proof', path);
        final response = await _apiService.postMultipart(
          ApiConstants.expenseSubmitEndpoint,
          fields,
          [file],
          token,
        );
        return Map<String, dynamic>.from(response as Map<dynamic, dynamic>);
      }

      final data = <String, dynamic>{
        'amount': amount,
        'categoryId': categoryId,
        'description': description,
        if (extraJson != null) ...extraJson,
      };
      if (emp != null && emp.isNotEmpty) {
        data['employeeId'] = emp;
      } else {
        data.remove('employeeId');
      }
      final response = await _apiService.post(
        ApiConstants.expenseSubmitEndpoint,
        data,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return Map<String, dynamic>.from(response as Map<dynamic, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<BranchEmployeesResponse> getExpenseBranchEmployees(String token) async {
    try {
      final response = await _apiService.get(
        ApiConstants.expenseBranchEmployeesEndpoint,
        headers: {'Authorization': 'Bearer $token'},
      );
      return BranchEmployeesResponse.fromDynamic(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<CashierExpenseHistoryResponse> getExpenseHistory(
    String token, {
    String? status,
    String? from,
    String? to,
    String? categoryId,
    int limit = 30,
    int offset = 0,
  }) async {
    try {
      final params = <String, String>{
        'limit': '$limit',
        'offset': '$offset',
      };
      if (status != null && status.isNotEmpty) params['status'] = status;
      if (from != null && from.isNotEmpty) params['from'] = from;
      if (to != null && to.isNotEmpty) params['to'] = to;
      if (categoryId != null && categoryId.isNotEmpty) params['categoryId'] = categoryId;
      final response = await _apiService.getWithQueryParams(
        ApiConstants.expenseHistoryEndpoint,
        params,
        token,
      );
      return CashierExpenseHistoryResponse.fromDynamic(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> requestPettyCashFund(
    Map<String, dynamic> data,
    String token,
  ) async {
    try {
      final response = await _apiService.post(
        ApiConstants.pettyCashRequestFundEndpoint,
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

  Future<WalletBalanceResponse> getWalletBalance(String token) async {
    try {
      final response = await _apiService.getWithQueryParams(
        ApiConstants.walletBalanceEndpoint,
        {'currency': 'SAR'},
        token,
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

  /// Raw JSON variant so callers can access fields the typed model doesn't parse.
  Future<Map<String, dynamic>> getStoreClosingRaw(String token, String date, String workshopId) async {
    try {
      final response = await _apiService.getWithQueryParams(
        ApiConstants.storeClosingEndpoint,
        {
          'date': date,
          if (workshopId.isNotEmpty) 'workshopId': workshopId,
        },
        token,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> submitCounterClosing(String token, Map<String, dynamic> body) async {
    try {
      final response = await _apiService.post(
        ApiConstants.counterClosingEndpoint,
        body,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<SalesReturnListResponse> getSalesReturns(String token, {int limit = 50, int offset = 0, String? invoiceId}) async {
    try {
      final queryParams = {
        'limit': limit.toString(),
        'offset': offset.toString(),
        if (invoiceId != null && invoiceId.isNotEmpty) 'invoiceId': invoiceId,
      };
      
      final response = await _apiService.getWithQueryParams(
        ApiConstants.salesReturnListEndpoint,
        queryParams,
        token,
      );
      return SalesReturnListResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<TakeawayCatalogData> getTakeawayProductsCatalog(String token) async {
    try {
      final response = await _apiService.get(
        ApiConstants.cashierTakeawayProductsCatalogEndpoint,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return TakeawayCatalogData.fromJson(
        Map<String, dynamic>.from(response as Map),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<TakeawayCheckoutResponse> postTakeawayCheckout(
    TakeawayCheckoutRequest request,
    String token,
  ) async {
    try {
      final response = await _apiService.post(
        ApiConstants.cashierTakeawayCheckoutEndpoint,
        request.toJson(),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return TakeawayCheckoutResponse.fromJson(
        Map<String, dynamic>.from(response as Map),
      );
    } catch (e) {
      rethrow;
    }
  }
}

