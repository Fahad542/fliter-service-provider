import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../services/session_service.dart';
import '../../Menu/menu_view.dart';
import '../Requests/locker_requests_list_view.dart';
import '../Reports/locker_reports_view.dart';
import '../Notifications/locker_notifications_view.dart';
import '../Requests/requests_approval_view.dart';
import 'locker_dashboard_view_model.dart';
// Import your SettingsViewModel so the language toggle actually works
import '../../Workshop pos app/More Tab/settings_view_model.dart';

class LockerDashboardView extends StatelessWidget {
  const LockerDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LockerDashboardViewModel(),
      child: const _LockerDashboardBody(),
    );
  }
}

class _LockerDashboardBody extends StatefulWidget {
  const _LockerDashboardBody();

  @override
  State<_LockerDashboardBody> createState() => _LockerDashboardBodyState();
}

class _LockerDashboardBodyState extends State<_LockerDashboardBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<LockerDashboardViewModel>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LockerDashboardViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF0F2F5),
          appBar: _buildAppBar(context, vm),
          body: Stack(
            children: [
              _buildBackgroundAccent(),
              _buildBody(context, vm),
            ],
          ),
        );
      },
    );
  }

  // ── Body dispatcher ───────────────────────────────────────────────────────

  Widget _buildBody(BuildContext context, LockerDashboardViewModel vm) {
    switch (vm.state) {
      case LockerDashboardState.loading:
      // Show skeleton/loader but still render chrome once session loaded
        if (!vm.isSessionLoaded) return _buildLoader(context);
        return _buildLoader(context);
      case LockerDashboardState.error:
        return _buildError(context, vm);
      case LockerDashboardState.success:
      case LockerDashboardState.idle:
        return _buildContent(context, vm);
    }
  }

  Widget _buildLoader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primaryLight),
          const SizedBox(height: 16),
          Text(
            l10n.lockerLoadingDashboard,
            style: const TextStyle(color: Colors.black45, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, LockerDashboardViewModel vm) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.wifi_off_rounded,
                  size: 40, color: Colors.red.shade400),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.lockerFailedLoadDashboard,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.secondaryLight),
            ),
            const SizedBox(height: 8),
            Text(
              vm.errorMessage ?? l10n.lockerUnexpectedError,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black45, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: vm.refresh,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.lockerRetry),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryLight,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, LockerDashboardViewModel vm) {
    return RefreshIndicator(
      color: AppColors.primaryLight,
      onRefresh: vm.refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(context, vm),
            const SizedBox(height: 32),
            _buildKPIGrid(context, vm),
            const SizedBox(height: 32),
            _buildQuickActions(context, vm),
          ],
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(
      BuildContext context, LockerDashboardViewModel vm) {
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      backgroundColor: AppColors.primaryLight,
      elevation: 0,
      toolbarHeight: 72,
      automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.lockerPortalAppBarTitle,
            style: const TextStyle(
                color: AppColors.secondaryLight,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                fontSize: 17),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.lockerSecureAssetManagement,
            style: TextStyle(
                color: AppColors.secondaryLight.withOpacity(0.4),
                fontWeight: FontWeight.bold,
                fontSize: 9,
                letterSpacing: 1),
          ),
        ],
      ),
      actions: [
        // ── Notifications ──────────────────────────────────────────────────
        InkWell(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const LockerNotificationsView())),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondaryLight.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.secondaryLight.withOpacity(0.1), width: 1),
            ),
            child: Image.asset('assets/images/notifications.png',
                height: 18, width: 18, color: AppColors.secondaryLight),
          ),
        ),
        const SizedBox(width: 8),

        // ── Language toggle ────────────────────────────────────────────────
        // FIX: was a dead Container — now wired to SettingsViewModel so the
        // locale actually changes and SessionService.saveLocale() is called.
        Consumer<SettingsViewModel>(
          builder: (context, settings, _) {
            return InkWell(
              onTap: () async {
                final newLocale = settings.locale.languageCode == 'en'
                    ? const Locale('ar')
                    : const Locale('en');
                settings.updateLocale(newLocale);
                // Persist for background translation service
                await SessionService.saveLocale(newLocale.languageCode);
              },
              borderRadius: BorderRadius.circular(50),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight.withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.secondaryLight.withOpacity(0.1),
                      width: 1),
                ),
                child: Image.asset('assets/images/global.png',
                    height: 18, width: 18, color: AppColors.secondaryLight),
              ),
            );
          },
        ),
        const SizedBox(width: 8),

        // ── Logout ─────────────────────────────────────────────────────────
        InkWell(
          onTap: () => _confirmLogout(context, vm),
          borderRadius: BorderRadius.circular(50),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.red.withOpacity(0.15), width: 1),
            ),
            child: const Icon(Icons.logout_rounded,
                size: 18, color: Colors.redAccent),
          ),
        ),
        const SizedBox(width: 16),
      ],
      bottom: (vm.isSessionLoaded && vm.canSwitchView)
          ? PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppColors.secondaryLight.withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppColors.secondaryLight.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              _buildTab(context, vm, 'supervisor',
                  l10n.lockerSupervisorTab),
              _buildTab(context, vm, 'collector',
                  l10n.lockerCollectorTab),
            ],
          ),
        ),
      )
          : null,
    );
  }

  Widget _buildTab(BuildContext context, LockerDashboardViewModel vm,
      String view, String label) {
    final isActive = vm.activeView == view;
    return Expanded(
      child: GestureDetector(
        onTap: () => vm.switchView(view),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.secondaryLight : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive
                  ? AppColors.primaryLight
                  : AppColors.secondaryLight.withOpacity(0.4),
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  // ── Logout confirm ────────────────────────────────────────────────────────

  Future<void> _confirmLogout(
      BuildContext context, LockerDashboardViewModel vm) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.lockerLogOut,
            style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.secondaryLight)),
        content: Text(l10n.lockerLogOutConfirm,
            style: const TextStyle(color: Colors.black54)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.lockerCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            child: Text(l10n.lockerLogOutButton,
                style: const TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await vm.logout();
      if (context.mounted)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MenuView()),
              (route) => false,
        );
    }
  }

  // ── Welcome header ────────────────────────────────────────────────────────

  Widget _buildWelcomeHeader(
      BuildContext context, LockerDashboardViewModel vm) {
    final l10n = AppLocalizations.of(context)!;
    // Translate raw userType token into a human-readable, translated label
    final userTypeLabel = _localizedUserType(context, vm.userType);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: const Icon(Icons.lock_outline_rounded,
              color: AppColors.secondaryLight, size: 26),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.lockerWelcomeBack,
              style: TextStyle(
                  color: Colors.black.withOpacity(0.3),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2),
            ),
            // userName getter returns translatedUserName ?? rawName
            Text(
              vm.userName ?? l10n.lockerDefaultUser,
              style: const TextStyle(
                  color: AppColors.secondaryLight,
                  fontSize: 18,
                  fontWeight: FontWeight.w900),
            ),
            if (vm.userType != null)
              Text(
                userTypeLabel,
                style: TextStyle(
                    color: Colors.black.withOpacity(0.25),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1),
              ),
          ],
        ),
      ],
    );
  }

  /// Converts raw API userType strings into translated, readable labels.
  String _localizedUserType(BuildContext context, String? userType) {
    final l10n = AppLocalizations.of(context)!;
    switch (userType?.toLowerCase()) {
      case 'supervisor':           return l10n.lockerRoleSupervisor;
      case 'manager':              return l10n.lockerRoleManager;
      case 'workshop_owner':       return l10n.lockerRoleWorkshopOwner;
      case 'workshop_supervisor':  return l10n.lockerRoleWorkshopSupervisor;
      case 'collector':            return l10n.lockerRoleCollector;
      case 'collection_officer':   return l10n.lockerRoleCollectionOfficer;
      case 'workshop_collector':   return l10n.lockerRoleWorkshopCollector;
      default:
        return userType?.toUpperCase().replaceAll('_', ' ') ?? '';
    }
  }

  // ── KPI grid ──────────────────────────────────────────────────────────────

  Widget _buildKPIGrid(BuildContext context, LockerDashboardViewModel vm) {
    final l10n = AppLocalizations.of(context)!;
    final kpis =
    vm.isSupervisor ? _supervisorKPIs(context, vm) : _collectorKPIs(context, vm);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          vm.isSupervisor
              ? l10n.lockerSupervisorOverview
              : l10n.lockerMyPerformance,
          style: const TextStyle(
              color: AppColors.secondaryLight,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 2),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: kpis,
        ),
      ],
    );
  }

  List<Widget> _supervisorKPIs(
      BuildContext context, LockerDashboardViewModel vm) {
    final l10n = AppLocalizations.of(context)!;
    final s = vm.supervisorStats;
    return [
      _buildKPICard(
        label: l10n.lockerKpiPending,
        value: '${s.pending}',
        icon: Icons.pending_actions_rounded,
        accent: Colors.orange,
        isAlert: s.pending > 0,
      ),
      _buildKPICard(
        label: l10n.lockerKpiAwaiting,
        value: '${s.awaiting}',
        icon: Icons.assignment_ind_outlined,
        accent: Colors.blue,
      ),
      _buildKPICard(
        label: l10n.lockerKpiOverdue,
        value: '${s.overdue}',
        icon: Icons.history_rounded,
        accent: Colors.red,
        isAlert: s.overdue > 0,
      ),
      _buildKPICard(
        label: l10n.lockerKpiVariance,
        value: '${l10n.lockerSarCurrency} ${s.varianceAmount.toStringAsFixed(0)}',
        icon: Icons.warning_amber_rounded,
        accent: Colors.orange,
        isAlert: s.varianceAmount != 0,
      ),
    ];
  }

  List<Widget> _collectorKPIs(
      BuildContext context, LockerDashboardViewModel vm) {
    final l10n = AppLocalizations.of(context)!;
    final c = vm.collectorStats;
    final t = vm.todaysCollections;
    return [
      _buildKPICard(
        label: l10n.lockerKpiOpenAssignments,
        value: '${c.myOpenAssignments}',
        icon: Icons.assignment_outlined,
        accent: Colors.blue,
      ),
      _buildKPICard(
        label: l10n.lockerKpiPendingApproval,
        value: '${vm.pendingApprovals}',
        icon: Icons.hourglass_empty_rounded,
        accent: Colors.orange,
      ),
      _buildKPICard(
        label: l10n.lockerKpiTodaysCollections,
        value: '${t.requestCount}',
        icon: Icons.payments_outlined,
        accent: Colors.teal,
      ),
      _buildKPICard(
        label: l10n.lockerKpiMonthlyCollected,
        value: '${l10n.lockerSarCurrency} ${vm.monthlyCollected.toStringAsFixed(0)}',
        icon: Icons.bar_chart_rounded,
        accent: Colors.indigo,
      ),
    ];
  }

  Widget _buildKPICard({
    required String label,
    required String value,
    required IconData icon,
    required Color accent,
    bool isAlert = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -10,
            right: -10,
            child: Icon(icon, color: accent.withOpacity(0.05), size: 80),
          ),
          if (isAlert)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle),
              ),
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
                      style: const TextStyle(
                          color: AppColors.secondaryLight,
                          fontSize: 18,
                          fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      label,
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.3),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1),
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

  // ── Quick actions ─────────────────────────────────────────────────────────

  Widget _buildQuickActions(BuildContext context, LockerDashboardViewModel vm) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.lockerCoreOperations,
          style: const TextStyle(
              color: AppColors.secondaryLight,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 2),
        ),
        const SizedBox(height: 12),

        _buildActionButton(
          context: context,
          label: vm.isSupervisor
              ? l10n.lockerManageAllRequests
              : l10n.lockerStartCollection,
          icon: vm.isSupervisor
              ? Icons.view_sidebar_rounded
              : Icons.add_task_rounded,
          color: AppColors.secondaryLight,
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const LockerRequestsListView())),
        ),

        if (vm.isSupervisor) ...[
          const SizedBox(height: 12),
          _buildActionButton(
            context: context,
            label: l10n.lockerAssignOfficers,
            icon: Icons.person_add_alt_1_rounded,
            color: Colors.white,
            textColor: AppColors.secondaryLight,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const LockerRequestsListView(
                      filterMode: LockerListFilterMode.assignPending,
                    ))),
          ),

          const SizedBox(height: 12),

          _buildActionButton(
            context: context,
            label: l10n.lockerManageVarianceRequests,
            icon: Icons.compare_arrows_rounded,
            color: Colors.white,
            textColor: Colors.orange.shade800,
            accentColor: Colors.orange,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                    const LockerVarianceApprovalsView())),
          ),
        ],

        const SizedBox(height: 12),
        _buildActionButton(
          context: context,
          label: l10n.lockerFinancialAnalytics,
          icon: Icons.analytics_outlined,
          color: Colors.white,
          textColor: AppColors.secondaryLight,
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const LockerReportsView())),
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
    Color? accentColor,
    required VoidCallback onTap,
  }) {
    final effective = accentColor ?? textColor;
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
            side: color == Colors.white
                ? BorderSide(color: Colors.black.withOpacity(0.05))
                : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: effective.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: effective),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: textColor.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  // ── Background accent ─────────────────────────────────────────────────────

  Widget _buildBackgroundAccent() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 160,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius:
          const BorderRadius.vertical(bottom: Radius.circular(32)),
        ),
      ),
    );
  }
}