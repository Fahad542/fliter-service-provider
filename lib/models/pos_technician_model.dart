class PosTechnicianResponse {
  final bool success;
  final List<PosTechnician> technicians;

  PosTechnicianResponse({required this.success, required this.technicians});

  factory PosTechnicianResponse.fromJson(Map<String, dynamic> json) {
    return PosTechnicianResponse(
      success: json['success'] ?? false,
      technicians:
          (json['technicians'] as List?)
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
  final bool isEligible;
  final List<PosDepartmentInfo> departments;
  final PosTechnicianStatus status;
  final int slotsUsed;
  final int totalSlots;

  // Compatibility getters
  String get serviceCategory => technicianType;
  String get statusInfo => status.status;
  bool get isOnline => status.status.toLowerCase() == 'online';

  String get formattedLastSeen {
    if (status.lastSeenAt.isEmpty) return 'Never';
    try {
      final dateTime = DateTime.parse(status.lastSeenAt);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) return 'Just now';
      if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
      if (difference.inHours < 24) return '${difference.inHours}h ago';
      if (difference.inDays < 7) return '${difference.inDays}d ago';

      return status.lastSeenAt.split('T')[0]; // Return YYYY-MM-DD as fallback
    } catch (e) {
      return '';
    }
  }

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
    this.isEligible = true,
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
      isEligible: json['isEligible'] ?? true,
      departments:
          (json['departments'] as List?)
              ?.map((d) => PosDepartmentInfo.fromJson(d))
              .toList() ??
          [],
      status: PosTechnicianStatus.fromJson(
        (json['technicianStatus'] is Map<String, dynamic>)
            ? json['technicianStatus']
            : (json['status'] is Map<String, dynamic>)
            ? json['status']
            : {
                'status': json['onlineStatus'] ?? json['status'] ?? 'offline',
                'lastSeenAt': json['lastSeenAt'] ?? '',
              },
      ),
      slotsUsed: (json['slots'] != null && json['slots'] is Map)
          ? int.tryParse(json['slots']['active']?.toString() ?? '') ?? 0
          : int.tryParse(json['slotsUsed']?.toString() ?? '') ?? 0,
      totalSlots: (json['slots'] != null && json['slots'] is Map)
          ? int.tryParse(json['slots']['total']?.toString() ?? '') ?? 3
          : int.tryParse(json['totalSlots']?.toString() ?? '') ?? 3,
    );
  }
}

class PosDepartmentInfo {
  final String id;
  final String name;

  PosDepartmentInfo({required this.id, required this.name});

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

  const PosTechnicianStatus({required this.status, required this.lastSeenAt});

  const PosTechnicianStatus.empty() : status = 'offline', lastSeenAt = '';

  factory PosTechnicianStatus.fromJson(Map<String, dynamic> json) {
    return PosTechnicianStatus(
      status:
          json['status']?.toString() ??
          json['onlineStatus']?.toString() ??
          'offline',
      lastSeenAt: json['lastSeenAt'] ?? '',
    );
  }
}
