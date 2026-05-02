class CorporateBookingResponse {
  final bool success;
  final List<CorporateBooking> bookings;

  CorporateBookingResponse({
    required this.success,
    required this.bookings,
  });

  factory CorporateBookingResponse.fromJson(Map<String, dynamic> json) {
    return CorporateBookingResponse(
      success: json['success'] ?? false,
      bookings: (json['bookings'] as List?)
              ?.map((e) => CorporateBooking.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class CorporateBooking {
  final String id;
  final String bookingCode;
  final String status;
  final String statusDisplay;
  final String companyName;
  final String vehicleName;
  final String vehiclePlate;
  final String department;
  final DateTime bookedDateTime;
  final String branchId;
  final String branchName;
  final DateTime submittedAt;
  final String? orderStatus;
  final String? rejectionReason;
  final List<String>? preSelectedProducts;
  final List<dynamic>? items;

  CorporateBooking({
    required this.id,
    required this.bookingCode,
    required this.status,
    required this.statusDisplay,
    required this.companyName,
    required this.vehicleName,
    required this.vehiclePlate,
    required this.department,
    required this.bookedDateTime,
    required this.branchId,
    required this.branchName,
    required this.submittedAt,
    this.orderStatus,
    this.rejectionReason,
    this.preSelectedProducts,
    this.items,
  });

  factory CorporateBooking.fromJson(Map<String, dynamic> json) {
    List<dynamic>? parseLineItems() {
      final lineItems = json['lineItems'];
      if (lineItems is List && lineItems.isNotEmpty) {
        return List<dynamic>.from(lineItems);
      }
      final items = json['items'];
      if (items is List && items.isNotEmpty) {
        return List<dynamic>.from(items);
      }
      final jobs = json['jobs'];
      if (jobs is List) {
        final collected = <dynamic>[];
        for (final job in jobs) {
          if (job is! Map) continue;
          final ji = job['items'];
          if (ji is List && ji.isNotEmpty) {
            collected.addAll(ji);
          }
        }
        if (collected.isNotEmpty) return collected;
      }
      return null;
    }

    return CorporateBooking(
      id: json['id']?.toString() ?? '',
      bookingCode: json['bookingCode'] ?? '',
      status: json['status'] ?? '',
      statusDisplay: json['statusDisplay'] ?? '',
      companyName: json['corporateName'] ?? '',
      vehicleName: json['vehicle'] ?? '',
      vehiclePlate: json['plate'] ?? '',
      department: json['department'] ?? '',
      bookedDateTime: json['bookedFor'] != null
          ? DateTime.tryParse(json['bookedFor']) ?? DateTime.now()
          : DateTime.now(),
      branchId: json['branchId']?.toString() ?? '',
      branchName: json['branchName'] ?? '',
      submittedAt: json['submittedAt'] != null
          ? DateTime.tryParse(json['submittedAt']) ?? DateTime.now()
          : DateTime.now(),
      orderStatus: _firstNonEmptyString([
        json['orderStatus'],
        json['salesOrderStatus'],
        json['walkInOrderStatus'],
        (json['order'] is Map)
            ? (json['order'] as Map)['status']
            : null,
      ]),
      rejectionReason: _firstNonEmptyString([
        json['rejectionReason'],
        json['rejectReason'],
        json['rejectedReason'],
        json['reason'],
      ]),
      items: parseLineItems(),
    );
  }

  CorporateBooking copyWith({
    String? id,
    String? bookingCode,
    String? status,
    String? statusDisplay,
    String? companyName,
    String? vehicleName,
    String? vehiclePlate,
    String? department,
    DateTime? bookedDateTime,
    String? branchId,
    String? branchName,
    DateTime? submittedAt,
    String? orderStatus,
    String? rejectionReason,
    List<String>? preSelectedProducts,
    List<dynamic>? items,
  }) {
    return CorporateBooking(
      id: id ?? this.id,
      bookingCode: bookingCode ?? this.bookingCode,
      status: status ?? this.status,
      statusDisplay: statusDisplay ?? this.statusDisplay,
      companyName: companyName ?? this.companyName,
      vehicleName: vehicleName ?? this.vehicleName,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      department: department ?? this.department,
      bookedDateTime: bookedDateTime ?? this.bookedDateTime,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      submittedAt: submittedAt ?? this.submittedAt,
      orderStatus: orderStatus ?? this.orderStatus,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      preSelectedProducts: preSelectedProducts ?? this.preSelectedProducts,
      items: items ?? this.items,
    );
  }
}

String? _firstNonEmptyString(List<dynamic> values) {
  for (final v in values) {
    if (v == null) continue;
    final s = v.toString().trim();
    if (s.isNotEmpty) return s;
  }
  return null;
}
