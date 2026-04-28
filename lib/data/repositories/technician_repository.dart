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

  Future<TechnicianBroadcastsFetchResult> getBroadcasts(String token) async {
    try {
      final response = await _apiService.get(
        ApiConstants.technicianBroadcastsEndpoint,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      final map = response is Map
          ? Map<String, dynamic>.from(response)
          : <String, dynamic>{};
      final raw = map['broadcasts'] ?? map['data'] ?? map['items'];
      final list = <TechBroadcast>[];
      if (raw is List) {
        for (final e in raw) {
          if (e is! Map) continue;
          final b = TechBroadcast.fromJson(Map<String, dynamic>.from(e));
          if (b.jobId.isNotEmpty) list.add(b);
        }
      }
      return TechnicianBroadcastsFetchResult(
        broadcasts: list,
        windowSeconds: _parseInt(map['windowSeconds'], 300),
        soonThresholdSeconds: _parseInt(map['soonThresholdSeconds'], 60),
        activeCount: _parseInt(map['activeCount'], list.length),
      );
    } catch (e) {
      rethrow;
    }
  }

  int _parseInt(dynamic v, int fallback) {
    if (v is int) return v;
    if (v is double) return v.round();
    return int.tryParse(v?.toString() ?? '') ?? fallback;
  }

  Future<void> acceptBroadcast(String token, String jobId) async {
    await _apiService.post(
      ApiConstants.technicianBroadcastAcceptEndpoint(jobId),
      {},
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  Future<void> rejectBroadcast(String token, String jobId) async {
    await _apiService.post(
      ApiConstants.technicianBroadcastRejectEndpoint(jobId),
      {},
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  static String _commissionQueryDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  /// Query by inclusive date range (`from` / `to` as `yyyy-MM-dd`).
  Future<CommissionHistoryResponse> getCommissionHistory(
    String token, {
    required DateTime from,
    required DateTime to,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final fromStr = _commissionQueryDate(from);
      final toStr = _commissionQueryDate(to);
      final response = await _apiService.get(
        '${ApiConstants.technicianCommissionHistoryEndpoint}?from=$fromStr&to=$toStr&limit=$limit&offset=$offset',
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
