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
    this.preSelectedProducts,
    this.items,
  });

  factory CorporateBooking.fromJson(Map<String, dynamic> json) {
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
      items: json['items'] as List<dynamic>?,
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
    List<String>? preSelectedProducts,
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
      preSelectedProducts: preSelectedProducts ?? this.preSelectedProducts,
      items: items ?? this.items,
    );
  }
}
