class WalkInCustomerRequest {
  final String? orderId;
  final String? customerName;
  final String? vatNumber;
  final String? mobile;
  final String? vehicleNumber;
  final String? make;
  final String? model;
  final int? odometerReading;
  final List<String> departmentIds;
  final List<RequestedProduct>? products;
  final List<RequestedService>? services;
  final String? totalDiscountType;
  final double? totalDiscountValue;
  final String? promoCode;

  WalkInCustomerRequest({
    this.orderId,
    this.customerName,
    this.vatNumber,
    this.mobile,
    this.vehicleNumber,
    this.make,
    this.model,
    this.odometerReading,
    required this.departmentIds,
    this.products,
    this.services,
    this.totalDiscountType,
    this.totalDiscountValue,
    this.promoCode,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'departmentIds': departmentIds,
    };
    
    if (orderId != null && orderId!.isNotEmpty) data['orderId'] = orderId;
    if (customerName != null) data['customerName'] = customerName;
    if (vatNumber != null) data['vatNumber'] = vatNumber;
    if (mobile != null) data['mobile'] = mobile;
    if (vehicleNumber != null) data['vehicleNumber'] = vehicleNumber;
    if (make != null) data['make'] = make;
    if (model != null) data['model'] = model;
    if (odometerReading != null) data['odometerReading'] = odometerReading;

    if (products != null && products!.isNotEmpty) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    if (services != null && services!.isNotEmpty) {
      data['services'] = services!.map((v) => v.toJson()).toList();
    }
    
    if (totalDiscountType != null) data['totalDiscountType'] = totalDiscountType;
    if (totalDiscountValue != null) data['totalDiscountValue'] = totalDiscountValue;
    if (promoCode != null) data['promoCode'] = promoCode;

    return data;
  }
}

class RequestedProduct {
  final String productId;
  final String departmentId;
  final double qty;
  final String? discountType;
  final double? discountValue;

  RequestedProduct({
    required this.productId,
    required this.departmentId,
    required this.qty,
    this.discountType,
    this.discountValue,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'productId': productId,
      'departmentId': departmentId,
      'qty': qty,
    };
    if (discountType != null) data['discountType'] = discountType;
    if (discountValue != null) data['discountValue'] = discountValue;
    return data;
  }
}

class RequestedService {
  final String serviceId;
  final String departmentId;
  final double qty;
  final String? discountType;
  final double? discountValue;

  RequestedService({
    required this.serviceId,
    required this.departmentId,
    this.qty = 1.0,
    this.discountType,
    this.discountValue,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'serviceId': serviceId,
      'departmentId': departmentId,
      'qty': qty,
    };
    if (discountType != null) data['discountType'] = discountType;
    if (discountValue != null) data['discountValue'] = discountValue;
    return data;
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
  final String? jobId;
  final String status;
  final String source;
  final int odometerReading;
  final WalkInCustomer? customer;
  final WalkInVehicle? vehicle;
  final List<WalkInDepartment> departments;
  final List<dynamic> items;

  WalkInOrder({
    required this.id,
    this.jobId,
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
      jobId: json['jobId']?.toString(),
      status: json['status'] ?? '',
      source: json['source'] ?? '',
      odometerReading: json['odometerReading'] ?? 0,
      customer: json['customer'] != null ? WalkInCustomer.fromJson(json['customer']) : null,
      vehicle: json['vehicle'] != null ? WalkInVehicle.fromJson(json['vehicle']) : null,
      departments: json['departments'] != null
          ? (json['departments'] as List).map((i) => WalkInDepartment.fromJson(i)).toList()
          : [],
      items: json['items'] ?? [],
    );
  }
}

class WalkInDepartment {
  final String? jobId;
  final String? departmentId;
  final String? name;

  WalkInDepartment({
    this.jobId,
    this.departmentId,
    this.name,
  });

  factory WalkInDepartment.fromJson(Map<String, dynamic> json) {
    return WalkInDepartment(
      jobId: json['jobId']?.toString(),
      departmentId: json['departmentId']?.toString(),
      name: json['name'],
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
