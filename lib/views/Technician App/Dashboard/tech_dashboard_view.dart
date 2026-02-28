import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../Orders/assigned_orders_view.dart';
import '../History/performance_view.dart';
import '../History/commission_history_view.dart';
import '../technician_view_model.dart';
import '../Orders/broadcast_overlay.dart';
import '../Notifications/notifications_view.dart';

class TechDashboardView extends StatelessWidget {
  const TechDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TechAppViewModel>(
      builder: (context, vm, child) {
        return Stack(
          children: [
            Scaffold(
              backgroundColor: const Color(0xFFF8F9FD),
              appBar: AppBar(
                backgroundColor: AppColors.primaryLight,
                elevation: 0,
                toolbarHeight: 90,
                automaticallyImplyLeading: false,
                centerTitle: false,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                ),
                title: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back,',
                        style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Ahmad Abdullah',
                        style: TextStyle(color: AppColors.secondaryLight, fontSize: 22, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                actions: [
                  // Global icon — same style as login header
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/global.png',
                        width: 22,
                        height: 22,
                        color: Colors.black,
                        errorBuilder: (_, __, ___) => const Icon(Icons.language, size: 22, color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Notification icon — same style as login header
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotificationsView()),
                    ),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
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
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _buildDutyToggles(vm),
                      const SizedBox(height: 24),
                      _buildQuickAction(context),
                      const SizedBox(height: 32),
                      _buildSectionTitle('TODAY\'S PERFORMANCE'),
                      const SizedBox(height: 16),
                      _buildKPIGrid(vm),
                    ],
                  ),
                ),
              ),
            ),
            const BroadcastOverlay(),
          ],
        );
      },
    );
  }


  Widget _buildDutyToggles(TechAppViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildToggleCard(
                'Workshop Duty',
                '(In-house)',
                vm.isWorkshopDuty,
                Icons.store_rounded,
                (val) => vm.toggleWorkshopDuty(val),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildToggleCard(
                'On-Call Duty',
                '(Emergency)',
                vm.isOnCallDuty,
                Icons.electric_bolt_rounded,
                (val) => vm.toggleOnCallDuty(val),
              ),
            ),
          ],
        ),
        if (vm.isWorkshopDuty || vm.isOnCallDuty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'You can only be active in one mode at a time.',
              style: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }

  Widget _buildToggleCard(String title, String sub, bool isActive, IconData icon, Function(bool) onChanged) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryLight : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isActive ? AppColors.primaryLight.withOpacity(0.2) : Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isActive ? AppColors.primaryLight : Colors.black.withOpacity(0.05),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: isActive ? Colors.black87 : Colors.black38, size: 24),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: isActive,
                  onChanged: onChanged,
                  activeColor: Colors.black87,
                  activeTrackColor: Colors.black.withOpacity(0.1),
                  inactiveThumbColor: Colors.grey[300],
                  inactiveTrackColor: Colors.grey[100],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: isActive ? Colors.black87 : AppColors.secondaryLight,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          Text(
            sub,
            style: TextStyle(
              color: isActive ? Colors.black87.withOpacity(0.6) : Colors.black38,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPIGrid(TechAppViewModel vm) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildStatCard(
          'Completed Jobs',
          vm.todayCompletedJobs.toString(),
          Icons.task_alt_rounded,
        ),
        _buildStatCard(
          'Daily Revenue',
          'SAR ${vm.todayRevenue.toInt()}',
          Icons.payments_rounded,
        ),
        _buildStatCard(
          'Today\'s Earned',
          'SAR ${vm.todayCommission.toInt()}',
          Icons.star_rounded,
          isHighlight: true,
        ),
        _buildStatCard(
          'Weekly Earned',
          'SAR ${vm.weekCommission.toInt()}',
          Icons.trending_up_rounded,
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, {bool isHighlight = false, Function(BuildContext)? onTap}) {
    return Builder(
      builder: (context) {
        return InkWell(
          onTap: onTap != null ? () => onTap(context) : null,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isHighlight ? Colors.green.withOpacity(0.1) : AppColors.primaryLight.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: isHighlight ? Colors.green : AppColors.primaryLight, size: 20),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        color: isHighlight ? Colors.green : AppColors.secondaryLight,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: TextStyle(color: Colors.black38, fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.secondaryLight,
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AssignedOrdersView()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.secondaryLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_rounded, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text(
              'VIEW ASSIGNED ORDERS',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
