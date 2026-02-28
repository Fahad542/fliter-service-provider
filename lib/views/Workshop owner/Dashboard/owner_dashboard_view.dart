import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../widgets/widgets.dart'; // Using global shared widgets
import '../widgets/owner_app_bar.dart';
import 'owner_dashboard_view_model.dart';

class OwnerDashboardView extends StatelessWidget {
  const OwnerDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OwnerDashboardViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFFF8F9FD),
            body: Center(child: CircularProgressIndicator(color: AppColors.primaryLight)),
          );
        }
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          appBar: OwnerAppBar(
            title: OwnerDashboardTitle(
              subtitle: vm.selectedBranch?.name ?? 'All Branches',
            ),
            showBackButton: false,
            showNotification: true,
            onMenuPressed: () => Scaffold.of(context).openDrawer(),
          ),
          body: vm.isLoading 
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: vm.init,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(vm),
                      const SizedBox(height: 20),
                      _buildBranchSelector(context, vm),
                      const SizedBox(height: 24),
                      _buildKPIGrid(vm),
                      const SizedBox(height: 32),
                      _buildSectionTitle(vm.selectedBranch == null ? 'Branch Performance' : 'Branch Highlights'),
                      const SizedBox(height: 16),
                      vm.selectedBranch == null ? _buildBranchList(vm) : _buildBranchHighlights(vm),
                    ],
                  ),
                ),
              ),
        );
      },
    );
  }

  // AppBar is now replaced by the shared OwnerAppBar widget

  Widget _buildHeader(OwnerDashboardViewModel vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back, ${vm.ownerName}!',
              style: AppTextStyles.h2.copyWith(fontSize: 22, color: AppColors.secondaryLight),
            ),
            const SizedBox(height: 4),
            Text(
              'Here is what is happening across your business today.',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKPIGrid(OwnerDashboardViewModel vm) {
    if (vm.selectedBranch == null) {
      // Aggregated View
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Total Sales Today',
                  'SAR ${vm.totalSalesToday.toStringAsFixed(0)}',
                  Icons.payments_rounded,
                  AppColors.primaryLight,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'This Month',
                  'SAR ${vm.totalSalesMonth.toStringAsFixed(0)}',
                  Icons.calendar_today_rounded,
                  const Color(0xFF9B51E0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Pending Invoices',
                  vm.pendingInvoices.toString(),
                  Icons.receipt_long_rounded,
                  const Color(0xFF2D9CDB),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Low Stock Alerts',
                  vm.lowStockAlerts.toString(),
                  Icons.inventory_2_rounded,
                  const Color(0xFFEB5757),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      // Per-Branch View
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Today\'s Sales',
                  'SAR ${vm.totalSalesToday.toStringAsFixed(0)}',
                  Icons.payments_rounded,
                  AppColors.primaryLight,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Active Orders',
                  vm.activeOrders.toString(),
                  Icons.assignment_rounded,
                  const Color(0xFF2D9CDB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Tech Workload',
                  '${(vm.technicianWorkload * 100).toStringAsFixed(0)}%',
                  Icons.engineering_rounded,
                  const Color(0xFF27AE60),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Pending Approval',
                  vm.pendingApprovals.toString(),
                  Icons.verified_user_rounded,
                  const Color(0xFFF2994A),
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      height: 128,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
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
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.h2.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.secondaryLight,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.h2.copyWith(fontSize: 18, color: AppColors.secondaryLight),
        ),
        TextButton(
          onPressed: () {},
          child: const Text('View All', style: TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildBranchSelector(BuildContext context, OwnerDashboardViewModel vm) {
    return GestureDetector(
      onTap: () => _showBranchPicker(context, vm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryLight.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_on_rounded, color: AppColors.primaryLight, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Viewing Data For',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    vm.selectedBranch?.name ?? 'All Branches Aggregated',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.secondaryLight),
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.secondaryLight),
          ],
        ),
      ),
    );
  }

  void _showBranchPicker(BuildContext context, OwnerDashboardViewModel vm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Branch', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.secondaryLight)),
            const SizedBox(height: 20),
            _buildPickerItem(
              context, 
              'All Branches', 
              null, 
              vm.selectedBranch == null,
              () => vm.setSelectedBranch(null),
            ),
            ...vm.branches.map((b) => _buildPickerItem(
              context, 
              b.name, 
              b.location, 
              vm.selectedBranch?.id == b.id,
              () => vm.setSelectedBranch(b),
            )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerItem(BuildContext context, String title, String? subtitle, bool isSelected, VoidCallback onTap) {
    return ListTile(
      onTap: () {
        onTap();
        Navigator.pop(context);
      },
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          subtitle == null ? Icons.business_rounded : Icons.location_on_rounded, 
          color: isSelected ? AppColors.secondaryLight : Colors.grey,
          size: 20,
        ),
      ),
      title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600, fontSize: 15)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
      trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryLight) : null,
    );
  }

  Widget _buildBranchHighlights(OwnerDashboardViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryLight.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHighlightRow('Branch Status', vm.selectedBranch?.status.toUpperCase() ?? 'ACTIVE', Icons.info_outline_rounded),
          const SizedBox(height: 16),
          _buildHighlightRow('Total Staff', vm.employees.where((e) => e.branchId == vm.selectedBranch?.id).length.toString(), Icons.people_outline_rounded),
          const SizedBox(height: 16),
          _buildHighlightRow('Sales Target', '85% Achieved', Icons.track_changes_rounded),
        ],
      ),
    );
  }

  Widget _buildBranchList(OwnerDashboardViewModel vm) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: vm.branches.length,
      itemBuilder: (context, index) {
        final branch = vm.branches[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondaryLight.withOpacity(0.03),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: Colors.grey.withOpacity(0.06)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.secondaryLight.withOpacity(0.9), AppColors.secondaryLight],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.store_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      branch.name,
                      style: AppTextStyles.h2.copyWith(fontSize: 15, color: AppColors.secondaryLight),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      branch.location,
                      style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                   Text(
                    'SAR ${branch.salesMTD.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900, 
                      color: AppColors.secondaryLight,
                      fontSize: 14,
                    ),
                  ),
                  const Text(
                    'Monthly Sales',
                    style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHighlightRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryLight, size: 18),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
      ],
    );
  }
}
