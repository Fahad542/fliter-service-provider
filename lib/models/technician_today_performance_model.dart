class TechnicianTodayPerformance {
  final bool? success;
  final int? completedJobs;
  final double? dailyRevenue;
  final double? todayEarned;
  final double? weeklyEarned;

  TechnicianTodayPerformance({
    this.success,
    this.completedJobs,
    this.dailyRevenue,
    this.todayEarned,
    this.weeklyEarned,
  });

  factory TechnicianTodayPerformance.fromJson(Map<String, dynamic> json) {
    return TechnicianTodayPerformance(
      success: json['success'],
      completedJobs: json['completedJobs'],
      dailyRevenue: json['dailyRevenue']?.toDouble(),
      todayEarned: json['todayEarned']?.toDouble(),
      weeklyEarned: json['weeklyEarned']?.toDouble(),
    );
  }
}
