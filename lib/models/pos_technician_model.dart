// ignore: depend_on_referenced_packages
import '../l10n/app_localizations.dart';

/// Locale-aware last-seen string. Call from the view/widget layer only.
/// Keeps the model itself locale-agnostic so no re-fetch is needed on
/// locale switch — the widget simply rebuilds with the new l10n instance.
String localizedLastSeen(PosTechnician tech, AppLocalizations l10n) {
  if (tech.isOnline) return l10n.posTechCardOnlineNow;
  final dur = tech.lastSeenDuration;
  if (dur == null) return tech.status.lastSeenAt.isEmpty ? l10n.posTechLastSeenNever : '';
  if (dur.inMinutes < 1) return l10n.posTechLastSeenJustNow;
  if (dur.inMinutes < 60) return l10n.posTechLastSeenMinutes(dur.inMinutes);
  if (dur.inHours < 24) return l10n.posTechLastSeenHours(dur.inHours);
  if (dur.inDays < 7) return l10n.posTechLastSeenDays(dur.inDays);
  return tech.formattedLastSeenDate;
}

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
  /// Cashier API: only [true] when technician may be assigned (typically online).
  final bool assignable;

  // Compatibility getters
  String get serviceCategory => technicianType;
  String get statusInfo => status.status;
  bool get isOnline => status.status.toLowerCase() == 'online';

  /// Raw date string fallback (YYYY-MM-DD). Use [localizedLastSeen] in the view layer.
  String get formattedLastSeenDate {
    if (status.lastSeenAt.isEmpty) return '';
    try {
      return status.lastSeenAt.split('T')[0];
    } catch (_) {
      return '';
    }
  }

  /// Duration since last seen. Returns null when timestamp is absent/unparseable.
  Duration? get lastSeenDuration {
    if (status.lastSeenAt.isEmpty) return null;
    try {
      return DateTime.now().difference(DateTime.parse(status.lastSeenAt));
    } catch (_) {
      return null;
    }
  }

  /// Legacy English-only getter kept for unmigrated call sites.
  /// Prefer the view-layer helper [localizedLastSeen] which uses l10n keys.
  String get formattedLastSeen {
    final dur = lastSeenDuration;
    if (dur == null) return status.lastSeenAt.isEmpty ? 'Never' : '';
    if (dur.inMinutes < 1) return 'Just now';
    if (dur.inMinutes < 60) return '${dur.inMinutes}m ago';
    if (dur.inHours < 24) return '${dur.inHours}h ago';
    if (dur.inDays < 7) return '${dur.inDays}d ago';
    return formattedLastSeenDate;
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
    this.assignable = true,
  });

  PosTechnician copyWith({
    int? slotsUsed,
    int? totalSlots,
    PosTechnicianStatus? status,
    bool? assignable,
  }) {
    return PosTechnician(
      id: id,
      name: name,
      mobile: mobile,
      employeeType: employeeType,
      technicianType: technicianType,
      commissionPercent: commissionPercent,
      basicSalary: basicSalary,
      workshopId: workshopId,
      branchId: branchId,
      userId: userId,
      isActive: isActive,
      isEligible: isEligible,
      departments: departments,
      status: status ?? this.status,
      slotsUsed: slotsUsed ?? this.slotsUsed,
      totalSlots: totalSlots ?? this.totalSlots,
      assignable: assignable ?? this.assignable,
    );
  }

  static int _firstInt(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final v = map[key];
      if (v == null) continue;
      final n = int.tryParse(v.toString());
      if (n != null) return n;
    }
    return -1;
  }

  static int _parseSlotsUsed(Map<String, dynamic> json) {
    // Cashier API exposes root slotsUsed (same as slots.active); prefer it.
    final rootUsed = json['slotsUsed'];
    if (rootUsed != null) {
      final n = int.tryParse(rootUsed.toString());
      if (n != null) return n;
    }
    final slots = json['slots'];
    if (slots is Map) {
      final m = Map<String, dynamic>.from(slots as Map);
      final n = _firstInt(m, [
        'active',
        'used',
        'inUse',
        'in_use',
        'assigned',
        'current',
        'count',
        'busy',
      ]);
      if (n >= 0) return n;
    }
    for (final key in ['activeSlots', 'assignedJobs', 'activeJobs']) {
      final v = json[key];
      if (v != null) {
        final n = int.tryParse(v.toString());
        if (n != null) return n;
      }
    }
    return 0;
  }

  static int _parseTotalSlots(Map<String, dynamic> json) {
    final rootTotal = json['totalSlots'];
    if (rootTotal != null) {
      final n = int.tryParse(rootTotal.toString());
      if (n != null && n > 0) return n;
    }
    final slots = json['slots'];
    if (slots is Map) {
      final m = Map<String, dynamic>.from(slots as Map);
      final n = _firstInt(m, ['total', 'max', 'capacity', 'limit', 'maxSlots']);
      if (n > 0) return n;
    }
    return 3;
  }

  factory PosTechnician.fromJson(Map<String, dynamic> json) {
    final parsedStatus = PosTechnicianStatus.fromJson(
      (json['technicianStatus'] is Map<String, dynamic>)
          ? json['technicianStatus'] as Map<String, dynamic>
          : (json['status'] is Map<String, dynamic>)
          ? json['status'] as Map<String, dynamic>
          : {
        'status': json['onlineStatus'] ?? json['status'] ?? 'offline',
        'lastSeenAt': json['lastSeenAt'] ?? '',
      },
    );
    final online =
        parsedStatus.status.toLowerCase() == 'online';
    final assignableRaw = json['assignable'];
    final assignable = assignableRaw is bool
        ? assignableRaw
        : (assignableRaw?.toString().toLowerCase() == 'true')
        ? true
        : (assignableRaw?.toString().toLowerCase() == 'false')
        ? false
        : online;

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
      status: parsedStatus,
      assignable: assignable,
      slotsUsed: _parseSlotsUsed(json),
      totalSlots: _parseTotalSlots(json),
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