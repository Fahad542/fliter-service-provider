import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import 'Dashboard/owner_dashboard_view.dart';
import 'Branches/branch_management_view.dart';
import 'Employees/employee_management_view.dart';
import 'Corporate/corporate_management_view.dart';
import 'Inventory/inventory_management_view.dart';
import 'Billing/billing_management_screen.dart';
import 'Reports/reports_management_view.dart';
import 'POS Monitoring/pos_monitoring_view.dart';
import 'Suppliers/suppliers_view.dart';
import 'Accounting/accounting_view.dart';
import 'Approvals/approvals_view.dart';
import 'Notifications/owner_notifications_view.dart';
import 'Settings/owner_settings_view.dart';
import 'widgets/owner_bottom_bar.dart';
import 'Departments/department_management_view.dart';
import '../../services/session_service.dart';
import 'package:provider/provider.dart';
import '../Menu/menu_view.dart';

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

  @override
  State<OwnerShell> createState() => OwnerShellState();
}

class OwnerShellState extends State<OwnerShell> {
  int _selectedIndex = 0;
  bool _notificationsHasBack = false;
  String _ownerName = 'Admin';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await SessionService().getUser(role: 'owner');
    if (user != null && user.name != null) {
      setState(() {
        _ownerName = user.name ?? 'Admin';
      });
    }
  }

  void goHome() {
    if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
    }
  }

  void goToIndex(int index, {bool withBack = false}) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
        if (index == 11) _notificationsHasBack = withBack;
      });
    }
  }

  final List<Widget> _views = [
    const OwnerDashboardView(),      // 0
    const BranchManagementView(),    // 1
    const EmployeeManagementView(),  // 2
    const CorporateManagementView(), // 3
    const InventoryManagementView(), // 4
    const ReportsManagementView(),   // 5
    const BillingManagementView(),   // 6
    const PosMonitoringView(),       // 7
    const SuppliersView(),           // 8
    const AccountingView(),          // 9
    const ApprovalsView(),           // 10
    const SizedBox(),                // 11 — overridden by _currentView (Notifications)
    const OwnerSettingsView(),       // 12
    const DepartmentManagementView(),// 13
  ];

  // Returns the view for the current index, injecting params where needed
  Widget get _currentView {
    if (_selectedIndex == 11) {
      return OwnerNotificationsView(showBackButton: _notificationsHasBack);
    }
    if (_selectedIndex >= _views.length) return const OwnerDashboardView();
    return _views[_selectedIndex];
  }

  @override
  Widget build(BuildContext context) {
    // Only show bottom navigation bar on these specific tabs: Dashboard, Reports, Billing, Profile
    final bool showBottomBar = [0, 5, 6, 12].contains(_selectedIndex);

    return Scaffold(
      drawer: _buildDrawer(),
      body: _currentView,
      bottomNavigationBar: showBottomBar 
          ? OwnerBottomBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            )
          : null,
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      width: 280,
      backgroundColor: AppColors.secondaryLight,
      child: Column(
        children: [
          _buildDrawerHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                _buildDrawerItem(0, 'Home', Icons.home_rounded),
                const SizedBox(height: 4),
                _buildDrawerItem(1, 'Branches', Icons.account_tree_rounded),
                const SizedBox(height: 4),
                _buildDrawerItem(13, 'Departments', Icons.category_rounded),
                const SizedBox(height: 4),
                _buildDrawerItem(2, 'Employees', Icons.people_alt_rounded),
                const SizedBox(height: 4),
                _buildDrawerItem(3, 'Corporate Customers', Icons.business_center_rounded),
                const SizedBox(height: 4),
                _buildDrawerItem(4, 'Inventory', Icons.inventory_2_rounded),
                const SizedBox(height: 4),
                _buildDrawerItem(7, 'POS Monitoring', Icons.point_of_sale_rounded),
                const SizedBox(height: 4),
                _buildDrawerItem(8, 'Suppliers & Purchases', Icons.local_shipping_rounded),
                const SizedBox(height: 4),
                _buildDrawerItem(9, 'Accounting', Icons.account_balance_rounded),
                const SizedBox(height: 4),
                _buildDrawerItem(11, 'Notifications', Icons.notifications_rounded),
                const SizedBox(height: 4),
                _buildDrawerItem(100, 'Logout', Icons.logout_rounded, isLogout: true),
              ],
            ),
          ),
          _buildDrawerFooter(),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
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
                'https://ui-avatars.com/api/?name=${Uri.encodeComponent(_ownerName)}&background=FCC247&color=23262D',
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
                  _ownerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Workshop Owner',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Log out',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.secondaryLight),
              ),
              const SizedBox(height: 10),
              const Text(
                'Are you sure you want to log out from your account?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.secondaryLight)),
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
                        if (mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const MenuView()),
                            (route) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Log out', style: TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w800)),
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

  Widget _buildDrawerItem(int index, String title, IconData icon, {bool isLogout = false}) {
    final isSelected = _selectedIndex == index;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isLogout) {
            Navigator.pop(context); // Close drawer
            _showLogoutDialog();
            return;
          }
          if (index < _views.length) {
            setState(() => _selectedIndex = index);
            Navigator.pop(context); // Close drawer
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
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.black : Colors.white70,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.white24, size: 16),
          const SizedBox(width: 8),
          Text(
            'Version 1.0.0',
            style: TextStyle(
              color: Colors.white.withOpacity(0.2),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
