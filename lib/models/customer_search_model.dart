class CustomerSearchResponse {
  final bool success;
  final String message;
  final List<SearchedCustomer> customers;

  CustomerSearchResponse({
    required this.success,
    required this.message,
    required this.customers,
  });

  factory CustomerSearchResponse.fromJson(Map<String, dynamic> json) {
    return CustomerSearchResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      customers: (json['customers'] as List? ?? [])
          .map((c) => SearchedCustomer.fromJson(c))
          .toList(),
    );
  }
}

class SearchedCustomer {
  final String id;
  final String name;
  final String mobile;
  final String? taxId;
  final String? whatsapp;
  final String customerType;
  final List<SearchedCustomerOrder> orders;

  SearchedCustomer({
    required this.id,
    required this.name,
    required this.mobile,
    this.taxId,
    this.whatsapp,
    required this.customerType,
    required this.orders,
  });

  factory SearchedCustomer.fromJson(Map<String, dynamic> json) {
    return SearchedCustomer(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      mobile: json['mobile'] ?? '',
      taxId: json['taxId'],
      whatsapp: json['whatsapp'],
      customerType: json['customerType'] ?? 'regular',
      orders: (json['orders'] as List? ?? [])
          .map((o) => SearchedCustomerOrder.fromJson(o))
          .toList(),
    );
  }
}

class SearchedCustomerOrder {
  final String id;
  final String status;
  final String source;
  final int odometerReading;
  final String createdAt;
  final SearchedCustomerVehicle? vehicle;
  final String? invoiceNo;

  SearchedCustomerOrder({
    required this.id,
    required this.status,
    required this.source,
    required this.odometerReading,
    required this.createdAt,
    this.vehicle,
    this.invoiceNo,
  });

  factory SearchedCustomerOrder.fromJson(Map<String, dynamic> json) {
    return SearchedCustomerOrder(
      id: json['id']?.toString() ?? '',
      status: json['status'] ?? '',
      source: json['source'] ?? '',
      odometerReading: json['odometerReading'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      vehicle: json['vehicle'] != null
          ? SearchedCustomerVehicle.fromJson(json['vehicle'])
          : null,
      invoiceNo:
          json['invoiceNo']?.toString() ??
          json['invoice_no']?.toString() ??
          json['invoiceId']?.toString() ??
          json['invoice_id']?.toString(),
    );
  }
}

class SearchedCustomerVehicle {
  final String id;
  final String plateNo;
  final String make;
  final String model;
  final String? year;
  final String? vin;

  SearchedCustomerVehicle({
    required this.id,
    required this.plateNo,
    required this.make,
    required this.model,
    this.year,
    this.vin,
  });

  factory SearchedCustomerVehicle.fromJson(Map<String, dynamic> json) {
    String? opt(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }

    return SearchedCustomerVehicle(
      id: json['id']?.toString() ?? '',
      plateNo: json['plateNo']?.toString() ?? '',
      make: json['make']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      year: opt(json['year']),
      vin: opt(json['vin']) ?? opt(json['carNo']),
    );
  }
}
