import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import 'reports_management_view_model.dart';
import '../widgets/owner_app_bar.dart';
import '../owner_shell.dart';

class ReportsManagementView extends StatefulWidget {
  const ReportsManagementView({super.key});

  @override
  State<ReportsManagementView> createState() => _ReportsManagementViewState();
}

class _ReportsManagementViewState extends State<ReportsManagementView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ReportsManagementViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          appBar: OwnerAppBar(
            title: 'Reports & Analytics',
            showGlobalLeft: true,
            showNotification: true,
            showBackButton: false,
            showDrawer: false,
            onNotificationPressed: () => OwnerShell.goToNotifications(context),
            onMenuPressed: () => Scaffold.of(context).openDrawer(),
          ),
          body: vm.isLoading 
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryLight))
            : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Financial Overview'),
                const SizedBox(height: 16),
                _buildSalesChart(vm),
                const SizedBox(height: 32),
                _buildSectionHeader('Operational Performance'),
                const SizedBox(height: 16),
                _buildTechCommissionList(vm),
                const SizedBox(height: 32),
                _buildSectionHeader('Inventory Valuation'),
                const SizedBox(height: 16),
                _buildInventoryStatus(vm),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.h2.copyWith(fontSize: 18, color: AppColors.secondaryLight),
    );
  }

  Widget _buildSalesChart(ReportsManagementViewModel vm) {
    final fin = vm.reportsData?.financialOverview;
    final totalRev = fin?.totalRevenue ?? 0.0;
    final revChange = fin?.revenueChangePercent ?? 0.0;
    final dailyRev = fin?.dailyRevenue ?? [];
    
    // Find max value to determine bar heights correctly
    double maxAmt = 1.0;
    if (dailyRev.isNotEmpty) {
      maxAmt = dailyRev.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
      if (maxAmt == 0) maxAmt = 1.0;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
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
                  const Text('Total Revenue', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text('SAR $totalRev', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                ],
              ),
              if (revChange != 0) Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: (revChange >= 0 ? Colors.green : Colors.red).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                child: Text('${revChange >= 0 ? '+' : ''}$revChange%', style: TextStyle(color: revChange >= 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Dynamic Bar Chart from dailyRev
          SizedBox(
            height: 135, // Increased height to prevent bottom overflow
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: dailyRev.isEmpty 
                  ? [const Text('No data for this week', style: TextStyle(color: Colors.white54))]
                  : dailyRev.map((r) {
                      final isToday = r.date == DateTime.now().toString().split(' ')[0];
                      // If maxAmt is 1 (all zeros), we give a small visual height or just 0
                      double heightRatio = maxAmt > 0 ? (r.amount / maxAmt).clamp(0.0, 1.0) : 0.0;
                      return _buildBar(r.day, heightRatio, r.amount, isToday: isToday);
                    }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String day, double height, double amount, {bool isToday = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          amount >= 1000 ? '${(amount / 1000).toStringAsFixed(1)}k' : amount.toStringAsFixed(0),
          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Container(
          width: 24,
          height: (80 * height).clamp(4.0, 80.0), // Minimum height of 4 so the bar is visible even at 0
          decoration: BoxDecoration(
            color: isToday ? AppColors.primaryLight : Colors.white24,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  Widget _buildTechCommissionList(ReportsManagementViewModel vm) {
    if (vm.reportsData == null || vm.reportsData!.operationalPerformance.isEmpty) {
      return const Text('No operational performance data', style: TextStyle(color: Colors.grey));
    }
    return Column(
      children: vm.reportsData!.operationalPerformance.map((tech) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: AppColors.primaryLight.withOpacity(0.1), child: const Icon(Icons.person_outline, color: AppColors.secondaryLight)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tech.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Total Jobs: ${tech.totalJobs}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('SAR ${tech.commission}', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.green)),
                  const Text('Commission', style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInventoryStatus(ReportsManagementViewModel vm) {
    final inv = vm.reportsData?.inventoryValuation;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _buildInventoryRow('Stock Value (Cost)', 'SAR ${inv?.stockValueCost ?? 0.0}', Colors.blue),
          const SizedBox(height: 32),
          _buildInventoryRow('Potential Profit', 'SAR ${inv?.potentialProfit ?? 0.0}', Colors.green),
          const SizedBox(height: 32),
          _buildInventoryRow('Active SKUs', '${inv?.activeSkus ?? 0} Items', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildInventoryRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 4, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
          ],
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
      ],
    );
  }
}
