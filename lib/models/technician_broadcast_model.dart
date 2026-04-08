/// Active job broadcast offered to a technician (GET /technician/broadcasts).
class TechBroadcast {
  final String jobId;
  final String? orderId;
  final String? serviceName;
  final String? broadcastMode;
  final DateTime? expiresAt;
  final String? amountLabel;

  TechBroadcast({
    required this.jobId,
    this.orderId,
    this.serviceName,
    this.broadcastMode,
    this.expiresAt,
    this.amountLabel,
  });

  factory TechBroadcast.fromJson(Map<String, dynamic> json) {
    DateTime? exp;
    final rawExp = json['expiresAt'] ?? json['expires_at'] ?? json['expiry'];
    if (rawExp != null) {
      try {
        exp = DateTime.tryParse(rawExp.toString())?.toLocal();
      } catch (_) {}
    }

    final job = json['job'];
    Map<String, dynamic>? jobMap;
    if (job is Map) jobMap = Map<String, dynamic>.from(job);

    String? name = json['serviceName']?.toString() ??
        json['service']?.toString() ??
        jobMap?['serviceName']?.toString() ??
        jobMap?['title']?.toString() ??
        jobMap?['name']?.toString();

    String? mode = json['broadcastType']?.toString() ??
        json['broadcastMode']?.toString() ??
        json['type']?.toString() ??
        jobMap?['broadcastType']?.toString();
    final statusStr = json['status']?.toString();
    if ((mode == null || mode.isEmpty) && statusStr != null) {
      final s = statusStr.toLowerCase();
      if (s.contains('on_call')) {
        mode = 'on_call';
      } else if (s.contains('workshop')) {
        mode = 'workshop';
      }
    }

    String? amt = json['amountLabel']?.toString();
    if (amt == null && json['amount'] != null) {
      amt = 'SAR ${json['amount']}';
    }
    if (amt == null && json['items'] is List) {
      double sum = 0;
      for (final it in json['items'] as List) {
        if (it is Map) {
          final lt = it['lineTotal'] ?? it['line_total'];
          if (lt is num) {
            sum += lt.toDouble();
          } else if (lt != null) {
            sum += double.tryParse(lt.toString()) ?? 0;
          }
        }
      }
      if (sum > 0) {
        amt = sum == sum.roundToDouble() ? 'SAR ${sum.toInt()}' : 'SAR ${sum.toStringAsFixed(2)}';
      }
    }

    return TechBroadcast(
      jobId: json['jobId']?.toString() ??
          json['job_id']?.toString() ??
          jobMap?['id']?.toString() ??
          '',
      orderId: json['orderId']?.toString() ?? json['order_id']?.toString(),
      serviceName: name,
      broadcastMode: mode,
      expiresAt: exp,
      amountLabel: amt,
    );
  }
}
