enum LockerStatus {
  pending,
  assigned,
  collected,
  awaitingApproval,
  approved,
  rejected
}

class LockerRequest {
  final String id;
  final String branchName;
  final String cashierName;
  final DateTime closingDate;
  final double lockedCashAmount;
  final LockerStatus status;
  final String? assignedOfficerId;

  LockerRequest({
    required this.id,
    required this.branchName,
    required this.cashierName,
    required this.closingDate,
    required this.lockedCashAmount,
    this.status = LockerStatus.pending,
    this.assignedOfficerId,
  });

  LockerRequest copyWith({
    LockerStatus? status,
    String? assignedOfficerId,
  }) {
    return LockerRequest(
      id: id,
      branchName: branchName,
      cashierName: cashierName,
      closingDate: closingDate,
      lockedCashAmount: lockedCashAmount,
      status: status ?? this.status,
      assignedOfficerId: assignedOfficerId ?? this.assignedOfficerId,
    );
  }
}

class LockerCollection {
  final String id;
  final String requestId;
  final String officerId;
  final double receivedAmount;
  final DateTime collectionDate;
  final double difference;
  final String? proofUrl;
  final String? notes;

  LockerCollection({
    required this.id,
    required this.requestId,
    required this.officerId,
    required this.receivedAmount,
    required this.collectionDate,
    required this.difference,
    this.proofUrl,
    this.notes,
  });
}

class LockerOfficer {
  final String id;
  final String name;
  final String mobile;
  final String role; // 'Manager' or 'Officer'

  LockerOfficer({
    required this.id,
    required this.name,
    required this.mobile,
    required this.role,
  });
}
