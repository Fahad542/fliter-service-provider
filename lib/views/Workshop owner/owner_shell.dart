import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/app_colors.dart';
import 'Dashboard/owner_dashboard_view.dart';
import 'Branches/branch_management_view.dart';
import 'Branches/branch_management_view_model.dart';
import 'Employees/employee_management_view.dart';
import 'Corporate/corporate_management_view.dart';
import 'Inventory/inventory_management_view.dart';
import 'Billing/billing_management_screen.dart';
import 'Billing/billing_management_view_model.dart';
import 'Reports/reports_management_view.dart';
import 'POS Monitoring/pos_monitoring_view.dart';
import 'Suppliers/suppliers_view.dart';
import 'Accounting/accounting_view.dart';
import 'Promo/owner_promo_view.dart';
import 'Approvals/approvals_view.dart';
import 'Approvals/approvals_view_model.dart';
import 'Notifications/owner_notifications_view.dart';
import 'Settings/owner_settings_view.dart';
import 'widgets/owner_bottom_bar.dart';
import 'Departments/department_management_view.dart';
import '../../services/session_service.dart';
import 'package:provider/provider.dart';
import 'Suppliers/suppliers_view_model.dart';
import 'Accounting/accounting_view_model.dart';
import '../../data/repositories/owner_repository.dart';
import '../../services/owner_data_service.dart';
import '../../utils/restart_widget.dart';
import '../Workshop pos app/More Tab/settings_view_model.dart';

class OwnerShell extends StatefulWidget {
  const OwnerShell({super.key});

  static void goHome(BuildContext context) {
    final state = context.findAncestorStateOfType<OwnerShellState>();
    if (state != null) {
      state.goHome();
    } else {
      Navigator.maybePop(context);
    }
  }

  static void goToNotifications(BuildContext context) {
    final state = context.findAncestorStateOfType<OwnerShellState>();
    state?.goToIndex(11, withBack: true);
  }

  static void goToApprovals(BuildContext context) {
    final state = context.findAncestorStateOfType<OwnerShellState>();
    state?.goToIndex(10);
  }

  static void openDrawer(BuildContext context) {
    final state = context.findAncestorStateOfType<OwnerShellState>();
    state?._scaffoldKey.currentState?.openDrawer();
  }

  @override
  State<OwnerShell> createState() => OwnerShellState();
}

class OwnerShellState extends State<OwnerShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  bool _notificationsHasBack = false;
  String _ownerName = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await SessionService().getUser(role: 'owner');
    if (user != null && mounted) {
      setState(() => _ownerName = user.name ?? '');
    }
  }

  void goHome() {
    if (_selectedIndex != 0) setState(() => _selectedIndex = 0);
  }

  void goToIndex(int index, {bool withBack = false}) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
        if (index == 11) _notificationsHasBack = withBack;
      });
    }
  }

  List<Widget>? _cachedViews;

  List<Widget> _buildViews(BuildContext context) {
    if (_cachedViews != null) return _cachedViews!;

    final settingsViewModel = context.read<SettingsViewModel>();

    _cachedViews = [
      // 0 — Dashboard
      const OwnerDashboardView(),

      // 1 — Branches
      // BranchManagementViewModel now receives settingsViewModel so it can
      // re-translate branch names / locations when the locale changes.
      ChangeNotifierProvider(
        create: (ctx) => BranchManagementViewModel(
          ownerRepository:  ctx.read<OwnerRepository>(),
          sessionService:   ctx.read<SessionService>(),
          ownerDataService: ctx.read<OwnerDataService>(),
          settingsViewModel: settingsViewModel,
        ),
        child: const BranchManagementView(),
      ),

      // 2 — Employees
      const EmployeeManagementView(),

      // 3 — Corporate
      const CorporateManagementView(),

      // 4 — Inventory
      const InventoryManagementView(),

      // 5 — Reports
      const ReportsManagementView(),

      // 6 — Billing
      // BillingManagementViewModel now receives settingsViewModel so it can
      // re-translate customer names / statuses when the locale changes.
      ChangeNotifierProvider(
        create: (ctx) => BillingManagementViewModel(
          ownerRepository:   ctx.read<OwnerRepository>(),
          sessionService:    ctx.read<SessionService>(),
          settingsViewModel: settingsViewModel,
        ),
        child: const BillingManagementView(),
      ),

      // 7 — POS Monitoring
      const PosMonitoringView(),

      // 8 — Suppliers
      ChangeNotifierProvider(
        create: (ctx) => SuppliersViewModel(
          ownerRepository: ctx.read<OwnerRepository>(),
          sessionService:  ctx.read<SessionService>(),
        ),
        child: const SuppliersView(),
      ),

      // 9 — Accounting
      ChangeNotifierProvider(
        create: (ctx) => AccountingViewModel(
          ownerRepository:  ctx.read<OwnerRepository>(),
          sessionService:   ctx.read<SessionService>(),
          settingsViewModel: settingsViewModel,
        ),
        child: const AccountingView(),
      ),

      // 10 — Approvals
      ChangeNotifierProvider(
        create: (ctx) => ApprovalsViewModel(
          ownerRepository:  ctx.read<OwnerRepository>(),
          sessionService:   ctx.read<SessionService>(),
          settingsViewModel: settingsViewModel,
        ),
        child: const ApprovalsView(),
      ),

      // 11 — Notifications (rendered separately via _currentView)
      const SizedBox(),

      // 12 — Settings
      const OwnerSettingsView(),

      // 13 — Departments
      const DepartmentManagementView(),

      // 14 — Promo
      const OwnerPromoView(),
    ];

    return _cachedViews!;
  }

  Widget _currentView(BuildContext context) {
    if (_selectedIndex == 11) {
      return OwnerNotificationsView(showBackButton: _notificationsHasBack);
    }
    final views = _buildViews(context);
    if (_selectedIndex >= views.length) return const OwnerDashboardView();
    return views[_selectedIndex];
  }

  @override
  Widget build(BuildContext context) {
    final bool showBottomBar = [0, 5, 6, 12].contains(_selectedIndex);
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(context),
      body: _currentView(context),
      bottomNavigationBar: showBottomBar
          ? OwnerBottomBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      )
          : null,
    );
  }

  // ── Drawer ────────────────────────────────────────────────────────────────

  Widget _buildDrawer(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Drawer(
      width: 280,
      backgroundColor: AppColors.secondaryLight,
      child: Column(
        children: [
          _buildDrawerHeader(l10n),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                _drawerItem(context, 0,   l10n.ownerShellHome,          Icons.home_rounded),
                const SizedBox(height: 4),
                _drawerItem(context, 1,   l10n.ownerShellBranches,      Icons.account_tree_rounded),
                const SizedBox(height: 4),
                _drawerItem(context, 13,  l10n.ownerShellDepartments,   Icons.category_rounded),
                const SizedBox(height: 4),
                _drawerItem(context, 2,   l10n.ownerShellEmployees,     Icons.people_alt_rounded),
                const SizedBox(height: 4),
                _drawerItem(context, 3,   l10n.ownerShellCorporate,     Icons.business_center_rounded),
                const SizedBox(height: 4),
                _drawerItem(context, 4,   l10n.ownerShellInventory,     Icons.inventory_2_rounded),
                const SizedBox(height: 4),
                _drawerItem(context, 7,   l10n.ownerShellPosMonitoring, Icons.point_of_sale_rounded),
                const SizedBox(height: 4),
                _drawerItem(context, 8,   l10n.ownerShellSuppliers,     Icons.local_shipping_rounded),
                const SizedBox(height: 4),
                _drawerItem(context, 9,   l10n.ownerShellAccounting,    Icons.account_balance_rounded),
                const SizedBox(height: 4),
                _drawerItem(context, 14,  l10n.ownerShellPromoCodes,    Icons.local_offer_rounded),
                const SizedBox(height: 4),
                _drawerItem(context, 10,  l10n.ownerShellApprovals,     Icons.approval_rounded),
                const SizedBox(height: 4),
                _drawerItem(context, 11,  l10n.ownerShellNotifications, Icons.notifications_rounded),
                const SizedBox(height: 4),
                _drawerItem(context, 100, l10n.ownerShellLogout,        Icons.logout_rounded, isLogout: true),
              ],
            ),
          ),
          _buildDrawerFooter(l10n),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(AppLocalizations l10n) {
    final displayName =
    _ownerName.isNotEmpty ? _ownerName : l10n.lockerDefaultUser;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                'https://ui-avatars.com/api/?name=${Uri.encodeComponent(displayName)}&background=FCC247&color=23262D',
                width: 48,
                height: 48,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16),
                ),
                Text(
                  l10n.ownerShellRoleLabel,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerFooter(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.white24, size: 16),
          const SizedBox(width: 8),
          Text(
            l10n.ownerShellVersion,
            style: TextStyle(
                color: Colors.white.withOpacity(0.2),
                fontSize: 11,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
      BuildContext context,
      int index,
      String title,
      IconData icon, {
        bool isLogout = false,
      }) {
    final isSelected = _selectedIndex == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isLogout) {
            Navigator.pop(context);
            _showLogoutDialog(context);
            return;
          }
          final views = _buildViews(context);
          if (index < views.length) {
            setState(() => _selectedIndex = index);
            Navigator.pop(context);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon,
                  size: 20,
                  color: isSelected ? Colors.black : Colors.white70),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color:
                  isSelected ? Colors.black : Colors.white70,
                  fontWeight:
                  isSelected ? FontWeight.w800 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.white,
        child: Container(
          width: 400,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.ownerShellLogoutTitle,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.secondaryLight),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.ownerShellLogoutBody,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.grey, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        l10n.ownerShellLogoutCancel,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondaryLight),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final session = SessionService();
                        await session.clearSession(role: 'owner');
                        await session.saveLastPortal('');
                        if (mounted) RestartWidget.restartApp(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        disabledBackgroundColor: AppColors.primaryLight,
                        foregroundColor: AppColors.secondaryLight,
                        disabledForegroundColor: AppColors.secondaryLight,
                        minimumSize: const Size.fromHeight(56),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        l10n.ownerShellLogoutConfirm,
                        style: const TextStyle(
                            color: AppColors.secondaryLight,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}