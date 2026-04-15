import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'technician_view_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import 'Notifications/notifications_view.dart';
import 'Profile/tech_profile_view.dart';
import 'Dashboard/tech_dashboard_view.dart';
import 'History/commission_history_view.dart';
import 'History/performance_view.dart';
import 'Orders/assigned_orders_view.dart';
import '../Menu/menu_view.dart';
import '../../services/session_service.dart';
import '../../../utils/restart_widget.dart';

class TechShell extends StatefulWidget {
  const TechShell({super.key});

  @override
  State<TechShell> createState() => TechShellState();
}

class TechShellState extends State<TechShell> {
  int _selectedIndex = 0;
  String _technicianName = '';

  final List<Widget> _screens = [
    const TechDashboardView(),
    const AssignedOrdersView(),
    const TechPerformanceView(),
    const CommissionHistoryView(),
    const NotificationsView(showDrawerIcon: true),
    const TechProfileView(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final vm = context.read<TechAppViewModel>();
      if (!vm.isBootstrapped) {
        vm.init();
      }
    });
  }

  Future<void> _loadUser() async {
    final user = await SessionService().getUser(role: 'tech');
    if (user != null && user.name != null) {
      setState(() {
        _technicianName = user.name ?? '';
      });
    }
  }

  void goToIndex(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      drawer: _buildDrawer(),
      body: _screens[_selectedIndex],
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
                _buildDrawerItem(0, 'Home', Icons.grid_view_rounded),
                const SizedBox(height: 4),
                _buildDrawerItem(1, 'Assigned Orders', Icons.assignment_rounded),
                const SizedBox(height: 4),
                _buildDrawerItem(2, 'Daily Performance', Icons.bar_chart_rounded),
                const SizedBox(height: 4),
                _buildDrawerItem(3, 'Commission History', Icons.payments_rounded),
                const SizedBox(height: 4),
                _buildDrawerItem(4, 'Notifications', Icons.notifications_rounded),
                const SizedBox(height: 4),
                _buildDrawerItem(5, 'Profile', Icons.person_outline_rounded),
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
                'https://ui-avatars.com/api/?name=${Uri.encodeComponent(_technicianName)}&background=FCC247&color=23262D',
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
                  _technicianName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Technician',
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

  Widget _buildDrawerItem(int index, String title, IconData icon, {bool isLogout = false}) {
    final isSelected = _selectedIndex == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context); // Close drawer
          if (isLogout) {
            _showLogoutDialog();
            return;
          }
          if (index < _screens.length) {
            setState(() => _selectedIndex = index);
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

  void _showLogoutDialog() {
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
                        await session.clearSession(role: 'tech');
                        await session.saveLastPortal('');
                        if (mounted) {
                          context.read<TechAppViewModel>().clearSession();
                          RestartWidget.restartApp(context);
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
