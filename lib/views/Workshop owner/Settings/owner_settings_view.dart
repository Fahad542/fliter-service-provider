import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../widgets/owner_app_bar.dart';
import '../owner_shell.dart';
import '../../../services/session_service.dart';
import '../../Menu/menu_view.dart';

class OwnerSettingsView extends StatefulWidget {
  const OwnerSettingsView({super.key});

  @override
  State<OwnerSettingsView> createState() => _OwnerSettingsViewState();
}

class _OwnerSettingsViewState extends State<OwnerSettingsView> {
  bool _notifications = true;
  bool _emailAlerts = true;
  bool _stockAlerts = true;
  bool _lockerAlerts = true;
  bool _biometricLogin = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: OwnerAppBar(
        title: 'Settings',
        showGlobalLeft: true,
        showNotification: true,
        showBackButton: false,
        showDrawer: false,
        onNotificationPressed: () => OwnerShell.goToNotifications(context),
        onMenuPressed: () => Scaffold.of(context).openDrawer(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileCard(),
            const SizedBox(height: 24),
            _buildSection('Notifications', [
              _buildToggleTile('Push Notifications', 'Receive in-app notifications', Icons.notifications_rounded, _notifications, (v) => setState(() => _notifications = v)),
              _buildToggleTile('Email Alerts', 'Get critical alerts via email', Icons.email_rounded, _emailAlerts, (v) => setState(() => _emailAlerts = v)),
              _buildToggleTile('Stock Alerts', 'Notify when stock is critical', Icons.inventory_2_rounded, _stockAlerts, (v) => setState(() => _stockAlerts = v)),
              _buildToggleTile('Locker Difference Alerts', 'Notify on EOD locker variance', Icons.lock_rounded, _lockerAlerts, (v) => setState(() => _lockerAlerts = v)),
            ]),
            const SizedBox(height: 24),
            _buildSection('Security', [
              _buildToggleTile('Biometric Login', 'Use fingerprint or face ID', Icons.fingerprint_rounded, _biometricLogin, (v) => setState(() => _biometricLogin = v)),
              _buildNavTile('Change Password', Icons.lock_outline_rounded, Colors.orange),
              _buildNavTile('Two-Factor Authentication', Icons.security_rounded, AppColors.primaryLight),
            ]),
            const SizedBox(height: 24),
            _buildSection('Business', [
              _buildNavTile('Workshop Profile', Icons.business_rounded, AppColors.secondaryLight),
              _buildNavTile('Branch Management', Icons.store_rounded, const Color(0xFF2D9CDB)),
              _buildNavTile('Commission Rules', Icons.percent_rounded, Colors.purple),
              _buildNavTile('VAT Settings', Icons.receipt_long_rounded, Colors.teal),
            ]),
            const SizedBox(height: 24),
            _buildSection('Support', [
              _buildNavTile('Help & Documentation', Icons.help_outline_rounded, Colors.grey),
              _buildNavTile('Contact Support', Icons.support_agent_rounded, Colors.green),
              _buildNavTile('Report an Issue', Icons.bug_report_rounded, Colors.red),
            ]),
            const SizedBox(height: 24),
            _buildLogoutButton(),
            const SizedBox(height: 12),
            const Center(child: Text('Filter Workshop OS • Version 1.0.0', style: TextStyle(color: Colors.grey, fontSize: 11))),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(16)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network('https://ui-avatars.com/api/?name=${Uri.encodeComponent(_ownerName)}&background=FCC247&color=23262D', width: 56, height: 56),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_ownerName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(height: 2),
                Text('Workshop Owner', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                  child: const Text('MULTI-BRANCH ACCESS', style: TextStyle(color: AppColors.primaryLight, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(title.toUpperCase(), style: AppTextStyles.bodyMedium.copyWith(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.2)),
        ),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.withOpacity(0.08)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
          child: Column(
            children: children.asMap().entries.map((e) {
              final isLast = e.key == children.length - 1;
              return Column(
                children: [
                  e.value,
                  if (!isLast) const SizedBox(height: 12),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleTile(String title, String subtitle, IconData icon, bool value, Function(bool) onChanged) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: AppColors.secondaryLight.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: AppColors.secondaryLight, size: 18),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.secondaryLight)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      trailing: Switch.adaptive(value: value, onChanged: onChanged, activeColor: AppColors.primaryLight),
    );
  }

  Widget _buildNavTile(String title, IconData icon, Color color) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.secondaryLight)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
      onTap: () {},
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: const Icon(Icons.logout_rounded, color: AppColors.secondaryLight, size: 20),
        title: const Text('Logout', style: TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w800, fontSize: 14)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.secondaryLight, size: 18),
        onTap: _showLogoutDialog,
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
}
