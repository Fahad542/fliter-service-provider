import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../Orders/assigned_orders_view.dart';
import '../History/performance_view.dart';
import '../History/commission_history_view.dart';
import '../technician_view_model.dart';
import '../Notifications/notifications_view.dart';

class TechDashboardView extends StatelessWidget {
  const TechDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TechAppViewModel>(
      builder: (context, vm, child) {
        if (!vm.isTechDashboardReady) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FD),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.primaryLight),
                  const SizedBox(height: 20),
                  Text(
                    'Loading your dashboard…',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.45),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return Scaffold(
              backgroundColor: const Color(0xFFF8F9FD),
              appBar: AppBar(
                backgroundColor: AppColors.primaryLight,
                elevation: 0,
                toolbarHeight: 90,
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
                      child: const Center(
                        child: Icon(Icons.menu_rounded, color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                ),
                centerTitle: false,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                ),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome Back,',
                      style: TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vm.dashboardGreetingName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.secondaryLight, fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                actions: [
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
                child: RefreshIndicator(
                        color: AppColors.secondaryLight,
                        backgroundColor: Colors.white,
                        onRefresh: () async {
                          await vm.init();
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                          child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            vm.isOfflineLockedByCashier
                                ? _buildOfflineLockedNotice()
                                : _buildDutyToggles(context, vm),
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
        );
      },
    );
  }

  /// Shown when cashier marked the technician offline (presence); duty toggles are hidden.
  Widget _buildOfflineLockedNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.wifi_off_rounded,
              color: AppColors.secondaryLight,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'You are currently offline',
                  style: TextStyle(
                    color: AppColors.secondaryLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'The cashier has set your status to offline. Workshop and on-call duties are unavailable until you are marked online again.',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.48),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildDutyToggles(BuildContext context, TechAppViewModel vm) {
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
                (val) => vm.toggleWorkshopDuty(context, val),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildToggleCard(
                'On-Call Duty',
                '(Emergency)',
                vm.isOnCallDuty,
                Icons.electric_bolt_rounded,
                (val) => vm.toggleOnCallDuty(context, val),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            'Turn workshop or on-call duty on for the jobs you want to receive. Only one can be active at a time.',
            style: TextStyle(
              color: Colors.black.withOpacity(0.35),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
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
          'SAR ${vm.todayRevenue.toStringAsFixed(2)}',
          Icons.payments_rounded,
        ),
        _buildStatCard(
          'Today\'s Earned',
          'SAR ${vm.todayCommission.toStringAsFixed(2)}',
          Icons.star_rounded,
          isHighlight: true,
        ),
        _buildStatCard(
          'Weekly Earned',
          'SAR ${vm.weekCommission.toStringAsFixed(2)}',
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
          MaterialPageRoute(builder: (_) => const AssignedOrdersView(isFromDashboard: true)),
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
