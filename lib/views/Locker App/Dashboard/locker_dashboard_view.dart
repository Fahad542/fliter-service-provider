import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../locker_view_model.dart';
import '../../../models/locker_models.dart';
import '../../../utils/app_colors.dart';
import '../Requests/locker_requests_list_view.dart';
import '../Reports/locker_reports_view.dart';
import '../Notifications/locker_notifications_view.dart';

class LockerDashboardView extends StatelessWidget {
  const LockerDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LockerViewModel>(
      builder: (context, vm, child) {
        final isManager = vm.currentUser?.role == 'Manager';

        return Scaffold(
          backgroundColor: const Color(0xFFF0F2F5),
          appBar: _buildProfessionalAppBar(context, vm),
          body: Stack(
            children: [
              _buildBackgroundAccent(),
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeHeader(vm),
                    const SizedBox(height: 32),
                    _buildKPIGrid(context, vm, isManager),
                    const SizedBox(height: 32),
                    _buildQuickActions(context, isManager),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  Widget _buildBackgroundAccent() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 160,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        ),
      ),
    );
  }


  PreferredSizeWidget _buildProfessionalAppBar(BuildContext context, LockerViewModel vm) {
    return AppBar(
      backgroundColor: AppColors.primaryLight,
      elevation: 0,
      toolbarHeight: 72,
      automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LOCKER PORTAL',
            style: TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 17),
          ),
          const SizedBox(height: 2),
          Text(
            'SECURE ASSET MANAGEMENT',
            style: TextStyle(color: AppColors.secondaryLight.withOpacity(0.4), fontWeight: FontWeight.bold, fontSize: 9, letterSpacing: 1),
          ),
        ],
      ),
      actions: [
        InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LockerNotificationsView())),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondaryLight.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.secondaryLight.withOpacity(0.1), width: 1),
            ),
            child: Image.asset(
              'assets/images/notifications.png',
              height: 18,
              width: 18,
              color: AppColors.secondaryLight,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.secondaryLight.withOpacity(0.05),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.secondaryLight.withOpacity(0.1), width: 1),
          ),
          child: Image.asset(
            'assets/images/global.png',
            height: 18,
            width: 18,
            color: AppColors.secondaryLight,
          ),
        ),
        const SizedBox(width: 20),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppColors.secondaryLight.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _buildAppBarToggleItem(vm, 'Manager', 'SUPERVISOR'),
              _buildAppBarToggleItem(vm, 'Officer', 'COLLECTOR'),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildWelcomeHeader(LockerViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WELCOME BACK',
          style: TextStyle(color: AppColors.secondaryLight.withOpacity(0.5), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2),
        ),
        const SizedBox(height: 2),
        Text(
          vm.currentUser?.name ?? 'Guest User',
          style: const TextStyle(color: AppColors.secondaryLight, fontSize: 24, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  Widget _buildKPIGrid(BuildContext context, LockerViewModel vm, bool isManager) {
    if (isManager) {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
        children: [
          _buildProfessionalKPICard('PENDING', vm.allRequests.where((r) => r.status == LockerStatus.pending).length.toString(), Icons.timer_outlined, Colors.blue),
          _buildProfessionalKPICard('AWAITING', vm.allRequests.where((r) => r.status == LockerStatus.awaitingApproval).length.toString(), Icons.pending_actions_rounded, AppColors.primaryLight),
          _buildProfessionalKPICard('OVERDUE', '0', Icons.history_rounded, Colors.red, isAlert: true),
          _buildProfessionalKPICard('VARIANCE', 'SAR ${vm.calculateTotalDifferences().toInt()}', Icons.warning_amber_rounded, Colors.orange, isAlert: true),
        ],
      );
    } else {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
        children: [
          _buildProfessionalKPICard('ASSIGNED TODAY', vm.filteredRequests.length.toString(), Icons.assignment_outlined, Colors.blue),
          _buildProfessionalKPICard('PENDING APPROVAL', vm.allRequests.where((r) => r.status == LockerStatus.awaitingApproval && r.assignedOfficerId == vm.currentUser?.id).length.toString(), Icons.hourglass_empty_rounded, Colors.orange),
          _buildProfessionalKPICard('COLLECTED', 'SAR 0', Icons.payments_outlined, Colors.teal),
          _buildProfessionalKPICard('SHORT/OVER', 'SAR 0', Icons.error_outline_rounded, Colors.red, isAlert: true),
        ],
      );
    }
  }

  Widget _buildProfessionalKPICard(String label, String value, IconData icon, Color accent, {bool isAlert = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -10,
            right: -10,
            child: Icon(icon, color: accent.withOpacity(0.05), size: 80),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: accent, size: 18),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(color: AppColors.secondaryLight, fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      label,
                      style: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isManager) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CORE OPERATIONS',
          style: TextStyle(color: AppColors.secondaryLight, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          context: context,
          label: isManager ? 'MANAGE ALL REQUESTS' : 'START COLLECTION',
          icon: isManager ? Icons.view_sidebar_rounded : Icons.add_task_rounded,
          color: AppColors.secondaryLight,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LockerRequestsListView())),
        ),
        if (isManager) ...[
          const SizedBox(height: 12),
          _buildActionButton(
            context: context,
            label: 'ASSIGN OFFICERS',
            icon: Icons.person_add_alt_1_rounded,
            color: Colors.white,
            textColor: AppColors.secondaryLight,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LockerRequestsListView())), // Placeholder to list
          ),
        ],
        const SizedBox(height: 12),
        _buildActionButton(
          context: context,
          label: 'FINANCIAL ANALYTICS',
          icon: Icons.analytics_outlined,
          color: Colors.white,
          textColor: AppColors.secondaryLight,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LockerReportsView())),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    Color textColor = Colors.white,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      height: 58,
      margin: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: color == Colors.white ? BorderSide(color: Colors.black.withOpacity(0.05)) : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: textColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarToggleItem(LockerViewModel vm, String role, String display) {
    final isSelected = vm.currentUser?.role == role;
    return Expanded(
      child: InkWell(
        onTap: () => vm.switchRole(role),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondaryLight : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected ? [
              BoxShadow(color: AppColors.secondaryLight.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2)),
            ] : null,
          ),
          child: Text(
            display,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.secondaryLight.withOpacity(0.35),
              fontWeight: FontWeight.w900,
              fontSize: 9,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminToggle(LockerViewModel vm) => const SizedBox.shrink(); // Legacy cleanup
  Widget _buildToggleItem(LockerViewModel vm, String role, String display) => const SizedBox.shrink(); // Legacy cleanup
}
