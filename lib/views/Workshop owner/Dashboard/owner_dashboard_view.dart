import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/owner_app_bar.dart';
import '../widgets/owner_branch_performance_tile.dart';
import '../widgets/owner_petty_cash_approval_card.dart';
import '../owner_shell.dart';
import 'owner_branch_performance_list_view.dart';
import 'owner_dashboard_view_model.dart';

class OwnerDashboardView extends StatefulWidget {
  const OwnerDashboardView({super.key});

  @override
  State<OwnerDashboardView> createState() => _OwnerDashboardViewState();
}

class _OwnerDashboardViewState extends State<OwnerDashboardView> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
              subtitle: vm.selectedBranch?.name ?? l10n.dashboardAllBranches,
            ),
            showBackButton: false,
            showNotification: true,
            onMenuPressed: () => Scaffold.of(context).openDrawer(),
          ),
          body: RefreshIndicator(
            onRefresh: vm.init,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBranchSelector(context, vm, l10n),
                  const SizedBox(height: 24),
                  _buildKPIGrid(vm, l10n),
                  const SizedBox(height: 24),
                  _buildPendingApprovalsSection(vm, l10n),
                  if (vm.branches.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    vm.selectedBranch == null
                        ? _buildSectionTitle(
                      l10n.dashboardBranchPerformance,
                      onViewAll: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (ctx) => OwnerBranchPerformanceListView(
                              branches: vm.branches,
                            ),
                          ),
                        );
                      },
                      l10n: l10n,
                    )
                        : _buildSectionTitle(l10n.dashboardBranchHighlights, l10n: l10n),
                    const SizedBox(height: 16),
                    vm.selectedBranch == null
                        ? _buildBranchListPreview(vm)
                        : _buildBranchHighlights(vm, l10n),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildKPIGrid(OwnerDashboardViewModel vm, AppLocalizations l10n) {
    final metrics = vm.selectedBranch == null
        ? <({String title, String value, IconData icon})>[
      (
      title: l10n.dashboardKpiTotalSalesToday,
      value: 'SAR ${vm.totalSalesToday.toStringAsFixed(0)}',
      icon: Icons.payments_rounded,
      ),
      (
      title: l10n.dashboardKpiThisMonth,
      value: 'SAR ${vm.totalSalesMonth.toStringAsFixed(0)}',
      icon: Icons.calendar_today_rounded,
      ),
      (
      title: l10n.dashboardKpiPendingInvoices,
      value: vm.pendingInvoices.toString(),
      icon: Icons.receipt_long_rounded,
      ),
      (
      title: l10n.dashboardKpiLowStockAlerts,
      value: vm.lowStockAlerts.toString(),
      icon: Icons.inventory_2_rounded,
      ),
    ]
        : <({String title, String value, IconData icon})>[
      (
      title: l10n.dashboardKpiTodaysSales,
      value: 'SAR ${vm.totalSalesToday.toStringAsFixed(0)}',
      icon: Icons.payments_rounded,
      ),
      (
      title: l10n.dashboardKpiActiveOrders,
      value: vm.activeOrders.toString(),
      icon: Icons.assignment_rounded,
      ),
      (
      title: l10n.dashboardKpiTechWorkload,
      value: '${(vm.technicianWorkload * 100).toStringAsFixed(0)}%',
      icon: Icons.engineering_rounded,
      ),
      (
      title: l10n.dashboardKpiPendingApproval,
      value: vm.pendingApprovals.toString(),
      icon: Icons.verified_user_rounded,
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < metrics.length; i++) ...[
              SizedBox(
                width: 158,
                child: _buildMetricCard(
                  metrics[i].title,
                  metrics[i].value,
                  metrics[i].icon,
                  AppColors.primaryLight,
                ),
              ),
              if (i < metrics.length - 1) const SizedBox(width: 12),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      constraints: const BoxConstraints(minHeight: 110),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.secondaryLight,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingApprovalsSection(OwnerDashboardViewModel vm, AppLocalizations l10n) {
    final requests = vm.pendingPettyCashRequests;
    final visible = requests.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      l10n.dashboardPendingApprovalsTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.h2.copyWith(
                        fontSize: 18,
                        color: AppColors.secondaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${requests.length}',
                      style: const TextStyle(
                        color: AppColors.secondaryLight,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => OwnerShell.goToApprovals(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                l10n.dashboardViewAll,
                style: const TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (requests.isEmpty)
          Text(
            l10n.dashboardNoPendingApprovals,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          )
        else ...[
          ...visible.map(
                (r) => OwnerPettyCashApprovalCard(
              request: r,
              currency: vm.pettyCashCurrency,
              hasApprovalActionInFlight: vm.hasApprovalActionInFlight,
              isApprovingThis: vm.isApprovingRequest(r.id),
              isRejectingThis: vm.isRejectingRequest(r.id),
              onApprove: () => vm.approvePettyCashRequest(r.id),
              onReject: (reason) => vm.rejectPettyCashRequest(r.id, reason),
            ),
          ),
          if (requests.length > 2)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                l10n.dashboardMoreApprovals(requests.length - 2),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onViewAll, required AppLocalizations l10n}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.h2.copyWith(fontSize: 18, color: AppColors.secondaryLight),
          ),
        ),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              l10n.dashboardViewAll,
              style: const TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  Widget _buildBranchSelector(BuildContext context, OwnerDashboardViewModel vm, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () => _showBranchPicker(context, vm, l10n),
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
                    l10n.dashboardViewingDataFor,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    vm.selectedBranch?.name ?? l10n.dashboardAllBranchesAggregated,
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

  void _showBranchPicker(BuildContext context, OwnerDashboardViewModel vm, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.55),
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dashboardSelectBranch,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.secondaryLight),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPickerItem(
                      context,
                      l10n.dashboardAllBranches,
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerItem(
      BuildContext context,
      String title,
      String? subtitle,
      bool isSelected,
      VoidCallback onTap,
      ) {
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

  Widget _buildBranchHighlights(OwnerDashboardViewModel vm, AppLocalizations l10n) {
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
          _buildHighlightRow(
            l10n.dashboardBranchStatus,
            vm.selectedBranch?.status.toUpperCase() ?? l10n.corporateStatusActive.toUpperCase(),
            Icons.info_outline_rounded,
          ),
          const SizedBox(height: 16),
          _buildHighlightRow(
            l10n.dashboardTotalStaff,
            vm.employees.where((e) => e.branchId == vm.selectedBranch?.id).length.toString(),
            Icons.people_outline_rounded,
          ),
          const SizedBox(height: 16),
          _buildHighlightRow(
            l10n.dashboardSalesTarget,
            l10n.dashboardSalesTargetValue,
            Icons.track_changes_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildBranchListPreview(OwnerDashboardViewModel vm) {
    final preview = vm.branches.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final branch in preview) OwnerBranchPerformanceTile(branch: branch),
      ],
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