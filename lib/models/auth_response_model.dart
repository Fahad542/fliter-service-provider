class AuthResponse {
  final bool? success;
  final String? message;
  final String? token;
  final User? user;

  AuthResponse({this.success, this.message, this.token, this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'],
      message: json['message'],
      token: json['token'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'token': token,
      'user': user?.toJson(),
    };
  }
}

class User {
  final String? id;
  final String? name;
  final String? email;
  final String? userType;
  final String? workshopId;
  final String? branchId;
  final String? workshopName;
  final String? branchName;
  final Cashier? cashier;

  User({
    this.id,
    this.name,
    this.email,
    this.userType,
    this.workshopId,
    this.branchId,
    this.workshopName,
    this.branchName,
    this.cashier,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Handle nested Workshop/Branch objects if they exist
    final workshopObj = json['workshop'] is Map ? json['workshop'] : null;
    final branchObj = json['branch'] is Map ? json['branch'] : null;

    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      userType: json['userType'],
      workshopId: json['workshopId']?.toString() ?? workshopObj?['id']?.toString(),
      branchId: json['branchId']?.toString() ?? branchObj?['id']?.toString() ?? json['cashier']?['branchId']?.toString(),
      workshopName: json['workshopName'] ?? json['workshop_name'] ?? workshopObj?['name'],
      branchName: json['branchName'] ?? json['branch_name'] ?? branchObj?['name'],
      cashier: json['cashier'] != null ? Cashier.fromJson(json['cashier']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'userType': userType,
      'workshopId': workshopId,
      'branchId': branchId,
      'workshopName': workshopName,
      'branchName': branchName,
      'cashier': cashier?.toJson(),
    };
  }
}

class Cashier {
  final String? cashierId;
  final String? cashierName;
  final String? branchId;

  Cashier({this.cashierId, this.cashierName, this.branchId});

  factory Cashier.fromJson(Map<String, dynamic> json) {
    return Cashier(
      cashierId: json['cashierId'],
      cashierName: json['cashierName'],
      branchId: json['branchId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cashierId': cashierId,
      'cashierName': cashierName,
      'branchId': branchId,
    };
  }
}
