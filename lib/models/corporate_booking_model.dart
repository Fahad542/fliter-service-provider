class CorporateBooking {
  final String id;
  final String companyName;
  final String vehicleName;
  final String vehiclePlate;
  final String department;
  final DateTime bookedDateTime;
  final String status;
  final List<String>? preSelectedProducts; // Added to hold product IDs

  CorporateBooking({
    required this.id,
    required this.companyName,
    required this.vehicleName,
    required this.vehiclePlate,
    required this.department,
    required this.bookedDateTime,
    required this.status,
    this.preSelectedProducts,
  });

  CorporateBooking copyWith({
    String? id,
    String? companyName,
    String? vehicleName,
    String? vehiclePlate,
    String? department,
    DateTime? bookedDateTime,
    String? status,
    List<String>? preSelectedProducts,
  }) {
    return CorporateBooking(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      vehicleName: vehicleName ?? this.vehicleName,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      department: department ?? this.department,
      bookedDateTime: bookedDateTime ?? this.bookedDateTime,
      status: status ?? this.status,
      preSelectedProducts: preSelectedProducts ?? this.preSelectedProducts,
    );
  }
}
