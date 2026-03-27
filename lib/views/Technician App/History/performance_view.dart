import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../utils/app_colors.dart';
import '../technician_view_model.dart';
import '../Notifications/notifications_view.dart';
import 'recent_jobs_view.dart';

class TechPerformanceView extends StatefulWidget {
  const TechPerformanceView({super.key});

  @override
  State<TechPerformanceView> createState() => _TechPerformanceViewState();
}

class _TechPerformanceViewState extends State<TechPerformanceView> {
  @override
  void initState() {
    super.initState();
    // Fetch data only when this tab is accessed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TechAppViewModel>().fetchDailyPerformance();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TechAppViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          appBar: _buildAppBar(context),
          body: vm.isLoading 
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryLight))
              : RefreshIndicator(
                  onRefresh: () => vm.fetchDailyPerformance(),
                  color: AppColors.primaryLight,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryCards(vm),
                        const SizedBox(height: 32),
                        _buildSectionHeader('EARNING TREND'),
                        const SizedBox(height: 16),
                        _buildChart(vm),
                        const SizedBox(height: 32),
                        _buildSectionHeader(
                          'RECENT JOBS', 
                          onSeeAll: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const RecentJobsView()));
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildHistoryList(vm),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryLight,
      elevation: 0,
      toolbarHeight: 70,
      automaticallyImplyLeading: false,
      leadingWidth: 70,
      leading: Center(
        child: GestureDetector(
          onTap: () => Scaffold.of(context).openDrawer(),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.secondaryLight,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondaryLight.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(child: Icon(Icons.menu_rounded, color: Colors.white, size: 22)),
          ),
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      title: const Text(
        'DAILY PERFORMANCE',
        style: TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1),
      ),
      centerTitle: true,
      actions: [
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsView())),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
            child: Center(
              child: Image.asset(
                'assets/images/notifications.png',
                width: 22,
                height: 22,
                color: Colors.black,
                errorBuilder: (_, __, ___) => const Icon(Icons.notifications_rounded, size: 22, color: Colors.black),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildSummaryCards(TechAppViewModel vm) {
    return Row(
      children: [
        Expanded(
          child: _buildSimpleStat(
            'TOTAL JOBS',
            vm.todayCompletedJobs.toString(),
            Icons.assignment_turned_in_rounded,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSimpleStat(
            'EARNED',
            'SAR ${vm.todayRevenue.toInt()}',
            Icons.stars_rounded,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(color: AppColors.secondaryLight, fontSize: 24, fontWeight: FontWeight.w900),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.black38, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(TechAppViewModel vm) {
    // Determine the max amount to calculate bar heights
    double maxAmt = 1.0;
    if (vm.weeklyOverview.isNotEmpty) {
      maxAmt = vm.weeklyOverview.fold(1.0, (max, e) => (e.amount ?? 0) > max ? (e.amount ?? 0) : max);
      if (maxAmt == 0) maxAmt = 1.0;
    }

    // A simple mock for revenue change just to match UI (Optional, can be removed if not needed)
    const double revChangePercent = 0.0; 

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight, // Dark Theme background
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Weekly Overview', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text('SAR ${vm.weekCommission.toInt()}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                ],
              ),
              if (revChangePercent != 0) 
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: (revChangePercent >= 0 ? Colors.green : Colors.red).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: Text('${revChangePercent >= 0 ? '+' : ''}$revChangePercent%', style: TextStyle(color: revChangePercent >= 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 24),
          // Dynamic Bar Chart
          SizedBox(
            height: 135,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: vm.weeklyOverview.isEmpty
                  ? [const Text('No data for this week', style: TextStyle(color: Colors.white54))]
                  : vm.weeklyOverview.map((item) {
                      final isToday = item.day == DateFormat('EEE').format(DateTime.now()); // Using standard date formatting idea, but can be skipped if day string just matched
                      double heightRatio = ((item.amount ?? 0) / maxAmt).clamp(0.0, 1.0);
                      // In tech app, the current 'day' format is often just day name (e.g. "Sun")
                      return _buildBarItem(item.day ?? '', heightRatio, item.amount ?? 0.0, isSelected: false); // you can add true isSelected logic if needed
                    }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarItem(String day, double height, double amount, {bool isSelected = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          amount >= 1000 ? '${(amount / 1000).toStringAsFixed(1)}k' : amount.toStringAsFixed(0),
          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: 24,
          height: (80 * height).clamp(4.0, 80.0), // Minimum height of 4 to keep it visible
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : Colors.white24,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day, 
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white54, 
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList(TechAppViewModel vm) {
    if (vm.assignedOrders.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 20),
          child: Text('No recent jobs found', style: TextStyle(color: Colors.grey, fontSize: 14)),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: vm.assignedOrders.length > 3 ? 3 : vm.assignedOrders.length,
      itemBuilder: (context, index) {
        final order = vm.assignedOrders[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withOpacity(0.03)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.vehicleModel,
                            style: const TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w800, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            order.id,
                            style: const TextStyle(color: Colors.black26, fontSize: 11, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Text('SAR ${order.commission.toInt()}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w900, fontSize: 16)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.black38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: const Text('See All', style: TextStyle(color: AppColors.primaryLight, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
      ],
    );
  }
}
