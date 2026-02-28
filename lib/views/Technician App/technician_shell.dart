import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import 'Notifications/notifications_view.dart';
import 'Dashboard/tech_dashboard_view.dart';
import 'History/commission_history_view.dart';
import 'History/performance_view.dart';
import 'Orders/assigned_orders_view.dart';

class TechShell extends StatefulWidget {
  const TechShell({super.key});

  @override
  State<TechShell> createState() => _TechShellState();
}

class _TechShellState extends State<TechShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const TechDashboardView(),
    const AssignedOrdersView(),
    const TechPerformanceView(),
    const CommissionHistoryView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: _screens[_selectedIndex],
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.grid_view_rounded, 'Home'),
              _buildNavItem(1, Icons.assignment_rounded, 'Orders'),
              _buildNavItem(2, Icons.bar_chart_rounded, 'Performance'),
              _buildNavItem(3, Icons.payments_rounded, 'Commission'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    final isTablet = MediaQuery.of(context).size.width > 600;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isTablet ? 28 : 22,
              color: isSelected ? AppColors.primaryLight : Colors.grey,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: isTablet ? 12 : 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.secondaryLight : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
