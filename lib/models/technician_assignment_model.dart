class AssignTechnicianRequest {
  final String employeeId;

  AssignTechnicianRequest({required this.employeeId});

  Map<String, dynamic> toJson() => {
        'employeeId': employeeId,
      };
}

class AssignTechnicianResponse {
  final bool success;
  final String message;
  final TechnicianAssignment? assignment;

  AssignTechnicianResponse({
    required this.success,
    required this.message,
    this.assignment,
  });

  factory AssignTechnicianResponse.fromJson(Map<String, dynamic> json) {
    return AssignTechnicianResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      assignment: json['assignment'] != null
          ? TechnicianAssignment.fromJson(json['assignment'])
          : null,
    );
  }
}

class TechnicianAssignment {
  final String id;
  final String jobId;
  final String departmentName;
  final String employeeId;
  final String employeeName;
  final String employeeMobile;
  final String status;
  final String assignedAt;

  TechnicianAssignment({
    required this.id,
    required this.jobId,
    required this.departmentName,
    required this.employeeId,
    required this.employeeName,
    required this.employeeMobile,
    required this.status,
    required this.assignedAt,
  });

  factory TechnicianAssignment.fromJson(Map<String, dynamic> json) {
    return TechnicianAssignment(
      id: json['id']?.toString() ?? '',
      jobId: json['jobId']?.toString() ?? '',
      departmentName: json['departmentName'] ?? '',
      employeeId: json['employeeId']?.toString() ?? '',
      employeeName: json['employeeName'] ?? '',
      employeeMobile: json['employeeMobile'] ?? '',
      status: json['status'] ?? '',
      assignedAt: json['assignedAt'] ?? '',
    );
  }
}
