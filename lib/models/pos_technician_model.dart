class PosTechnicianResponse {
  final bool success;
  final List<PosTechnician> technicians;

  PosTechnicianResponse({
    required this.success,
    required this.technicians,
  });

  factory PosTechnicianResponse.fromJson(Map<String, dynamic> json) {
    return PosTechnicianResponse(
      success: json['success'] ?? false,
      technicians: (json['technicians'] as List?)
              ?.map((t) => PosTechnician.fromJson(t))
              .toList() ??
          [],
    );
  }
}

class PosTechnician {
  final String id;
  final String name;
  final String mobile;
  final String employeeType;
  final String technicianType;
  final String commissionPercent;
  final String basicSalary;
  final String workshopId;
  final String branchId;
  final String userId;
  final bool isActive;
  final List<PosDepartmentInfo> departments;
  final PosTechnicianStatus status;
  final int slotsUsed;
  final int totalSlots;

  // Compatibility getters
  String get serviceCategory => technicianType;
  String get statusInfo => status.status;

  PosTechnician({
    required this.id,
    required this.name,
    this.mobile = '',
    this.employeeType = '',
    this.technicianType = '',
    this.commissionPercent = '0',
    this.basicSalary = '0',
    this.workshopId = '',
    this.branchId = '',
    this.userId = '',
    this.isActive = true,
    this.departments = const [],
    this.status = const PosTechnicianStatus(status: 'offline', lastSeenAt: ''),
    this.slotsUsed = 0,
    this.totalSlots = 3,
  });

  factory PosTechnician.fromJson(Map<String, dynamic> json) {
    return PosTechnician(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      mobile: json['mobile'] ?? '',
      employeeType: json['employeeType'] ?? '',
      technicianType: json['technicianType'] ?? '',
      commissionPercent: json['commissionPercent']?.toString() ?? '0',
      basicSalary: json['basicSalary']?.toString() ?? '0',
      workshopId: json['workshopId']?.toString() ?? '',
      branchId: json['branchId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      isActive: json['isActive'] ?? false,
      departments: (json['departments'] as List?)
              ?.map((d) => PosDepartmentInfo.fromJson(d))
              .toList() ??
          [],
      status: PosTechnicianStatus.fromJson(json['status'] ?? {}),
      slotsUsed: (json['slotsUsed'] as int?) ?? ((json['id']?.toString() ?? '').hashCode % 4), // Mock 0 to 3
      totalSlots: (json['totalSlots'] as int?) ?? 3, // Mock default 3
    );
  }
}

class PosDepartmentInfo {
  final String id;
  final String name;

  PosDepartmentInfo({
    required this.id,
    required this.name,
  });

  factory PosDepartmentInfo.fromJson(Map<String, dynamic> json) {
    return PosDepartmentInfo(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
    );
  }
}

class PosTechnicianStatus {
  final String status;
  final String lastSeenAt;

  const PosTechnicianStatus({
    required this.status,
    required this.lastSeenAt,
  });

  const PosTechnicianStatus.empty()
      : status = 'offline',
        lastSeenAt = '';

  factory PosTechnicianStatus.fromJson(Map<String, dynamic> json) {
    return PosTechnicianStatus(
      status: json['status'] ?? 'offline',
      lastSeenAt: json['lastSeenAt'] ?? '',
    );
  }
}
