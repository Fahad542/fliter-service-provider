class WalkInCustomerRequest {
  final String customerName;
  final String vatNumber;
  final String mobile;
  final String vehicleNumber;
  final String make;
  final String model;
  final int odometerReading;
  final List<String> departmentIds;
  final List<RequestedProduct>? products;

  WalkInCustomerRequest({
    required this.customerName,
    required this.vatNumber,
    required this.mobile,
    required this.vehicleNumber,
    required this.make,
    required this.model,
    required this.odometerReading,
    required this.departmentIds,
    this.products,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'customerName': customerName,
      'vatNumber': vatNumber,
      'mobile': mobile,
      'vehicleNumber': vehicleNumber,
      'make': make,
      'model': model,
      'odometerReading': odometerReading,
      'departmentIds': departmentIds,
    };

    if (products != null && products!.isNotEmpty) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class RequestedProduct {
  final String productId;
  final String departmentId;
  final double qty;

  RequestedProduct({
    required this.productId,
    required this.departmentId,
    required this.qty,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'departmentId': departmentId,
      'qty': qty,
    };
  }
}

class WalkInCustomerResponse {
  final bool success;
  final String message;
  final WalkInOrder? order;

  WalkInCustomerResponse({
    required this.success,
    required this.message,
    this.order,
  });

  factory WalkInCustomerResponse.fromJson(Map<String, dynamic> json) {
    return WalkInCustomerResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      order: json['order'] != null ? WalkInOrder.fromJson(json['order']) : null,
    );
  }
}

class WalkInOrder {
  final String id;
  final String status;
  final String source;
  final int odometerReading;
  final WalkInCustomer? customer;
  final WalkInVehicle? vehicle;
  final List<dynamic> departments;
  final List<dynamic> items;

  WalkInOrder({
    required this.id,
    required this.status,
    required this.source,
    required this.odometerReading,
    this.customer,
    this.vehicle,
    required this.departments,
    required this.items,
  });

  factory WalkInOrder.fromJson(Map<String, dynamic> json) {
    return WalkInOrder(
      id: json['id']?.toString() ?? '',
      status: json['status'] ?? '',
      source: json['source'] ?? '',
      odometerReading: json['odometerReading'] ?? 0,
      customer: json['customer'] != null ? WalkInCustomer.fromJson(json['customer']) : null,
      vehicle: json['vehicle'] != null ? WalkInVehicle.fromJson(json['vehicle']) : null,
      departments: json['departments'] ?? [],
      items: json['items'] ?? [],
    );
  }
}

class WalkInCustomer {
  final String id;
  final String name;
  final String mobile;
  final String taxId;

  WalkInCustomer({
    required this.id,
    required this.name,
    required this.mobile,
    required this.taxId,
  });

  factory WalkInCustomer.fromJson(Map<String, dynamic> json) {
    return WalkInCustomer(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      mobile: json['mobile'] ?? '',
      taxId: json['taxId'] ?? '',
    );
  }
}

class WalkInVehicle {
  final String id;
  final String plateNo;
  final String make;
  final String model;

  WalkInVehicle({
    required this.id,
    required this.plateNo,
    required this.make,
    required this.model,
  });

  factory WalkInVehicle.fromJson(Map<String, dynamic> json) {
    return WalkInVehicle(
      id: json['id']?.toString() ?? '',
      plateNo: json['plateNo'] ?? '',
      make: json['make'] ?? '',
      model: json['model'] ?? '',
    );
  }
}
