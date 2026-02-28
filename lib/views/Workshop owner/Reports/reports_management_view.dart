import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../Dashboard/owner_dashboard_view_model.dart';
import '../widgets/owner_app_bar.dart';
import '../owner_shell.dart';

class ReportsManagementView extends StatelessWidget {
  const ReportsManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OwnerDashboardViewModel>(
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
          body: SingleChildScrollView(
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

  Widget _buildSalesChart(OwnerDashboardViewModel vm) {
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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Revenue', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text('SAR 268,500', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                child: const Text('+12.5%', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Mock Bar Chart
          SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar('Sun', 0.4),
                _buildBar('Mon', 0.6),
                _buildBar('Tue', 0.8),
                _buildBar('Wed', 0.5),
                _buildBar('Thu', 0.9, isToday: true),
                _buildBar('Fri', 0.3),
                _buildBar('Sat', 0.7),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String day, double height, {bool isToday = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 24,
          height: 80 * height,
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

  Widget _buildTechCommissionList(OwnerDashboardViewModel vm) {
    return Column(
      children: vm.employees.where((e) => e.role == 'Technician').map((tech) {
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
                    const Text('Total Jobs: 48', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('SAR ${(tech.commissionPercent * 250).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.green)),
                  const Text('Commission', style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInventoryStatus(OwnerDashboardViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _buildInventoryRow('Stock Value (Cost)', 'SAR 142,000', Colors.blue),
          const SizedBox(height: 32),
          _buildInventoryRow('Potential Profit', 'SAR 85,400', Colors.green),
          const SizedBox(height: 32),
          _buildInventoryRow('Active SKUs', '1,245 Items', Colors.orange),
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
