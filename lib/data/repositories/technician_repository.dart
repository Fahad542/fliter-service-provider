import '../network/api_constants.dart';
import '../network/base_api_service.dart';
import '../../models/technician_performance_model.dart';
import '../../models/technician_today_performance_model.dart';
import '../../models/technician_profile_model.dart';
import '../../models/technician_assigned_orders_model.dart';
import '../../models/technician_order_details_model.dart';
import '../../models/technician_commission_history_model.dart';
import '../../models/technician_broadcast_model.dart';

class TechnicianRepository {
  final BaseApiService _apiService = BaseApiService();

  Future<TechnicianPerformance> getDailyPerformance(String token) async {
    try {
      final response = await _apiService.get(
        ApiConstants.technicianDailyPerformanceEndpoint,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return TechnicianPerformance.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<TechnicianTodayPerformance> getTodayPerformance(String token) async {
    try {
      final response = await _apiService.get(
        ApiConstants.technicianTodayPerformanceEndpoint,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return TechnicianTodayPerformance.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<TechnicianProfileResponse> getTechnicianProfile(String token) async {
    try {
      final response = await _apiService.get(
        ApiConstants.technicianProfileEndpoint,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return TechnicianProfileResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> updateDutyStatus(String token, String dutyMode) async {
    try {
      final response = await _apiService.patch(
        ApiConstants.technicianDutyStatusEndpoint,
        {'dutyMode': dutyMode},
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

  Future<dynamic> updateOnlineStatus(String token, String status) async {
    try {
      final response = await _apiService.patch(
        ApiConstants.technicianOnlineStatusEndpoint,
        {'status': status},
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

  Future<dynamic> getOnlineStatus(String token) async {
    try {
      final response = await _apiService.get(
        ApiConstants.technicianOnlineStatusEndpoint,
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

  Future<TechnicianAssignedOrdersResponse> getAssignedOrders(String token) async {
    try {
      final response = await _apiService.get(
        ApiConstants.technicianAssignedOrdersEndpoint,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return TechnicianAssignedOrdersResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<TechnicianOrderDetailsResponse> getOrderDetails(String token, String jobId) async {
    try {
      final response = await _apiService.get(
        ApiConstants.technicianOrderDetailsEndpoint(jobId),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return TechnicianOrderDetailsResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> completeOrder(String token, String jobId) async {
    try {
      await _apiService.post(
        ApiConstants.technicianCompleteOrderEndpoint(jobId),
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

  Future<void> acceptOrder(String token, String jobId) async {
    try {
      await _apiService.post(
        ApiConstants.technicianAcceptOrderEndpoint(jobId),
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

  Future<void> cancelOrder(String token, String jobId) async {
    try {
      final response = await _apiService.post(
        ApiConstants.technicianCancelOrderEndpoint(jobId),
        {},
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to cancel order');
      }
    } catch (e) {
      throw Exception('Error cancelling order: $e');
    }
  }

  Future<void> startOrder(String token, String jobId) async {
    try {
      final response = await _apiService.post(
        ApiConstants.technicianStartOrderEndpoint(jobId),
        {},
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to start order');
      }
    } catch (e) {
      throw Exception('Error starting order: $e');
    }
  }

  Future<List<TechBroadcast>> getBroadcasts(String token) async {
    try {
      final response = await _apiService.get(
        ApiConstants.technicianBroadcastsEndpoint,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      final raw = response['broadcasts'] ?? response['data'] ?? response['items'];
      if (raw is! List) return [];
      return raw
          .map((e) {
            if (e is! Map) return null;
            return TechBroadcast.fromJson(Map<String, dynamic>.from(e));
          })
          .whereType<TechBroadcast>()
          .where((b) => b.jobId.isNotEmpty)
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<CommissionHistoryResponse> getCommissionHistory(String token, int month, int year, {int limit = 50, int offset = 0}) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.technicianCommissionHistoryEndpoint}?month=$month&year=$year&limit=$limit&offset=$offset',
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return CommissionHistoryResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
