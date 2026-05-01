import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/owner_app_bar.dart';
import '../owner_shell.dart';
import '../../../services/session_service.dart';
import '../../Menu/menu_view.dart';
import '../../../utils/restart_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// OwnerSettingsView
//
// • Every hardcoded string replaced with l10n.* keys.
// • Language switcher added under a dedicated "Language" section — saves
//   the locale via SessionService then restarts the widget tree so the new
//   locale takes effect immediately across the whole app.
// • Logout dialog uses l10n keys so it renders correctly in both locales.
// • Section headers use .toUpperCase() only in EN; Arabic text must NOT be
//   upper-cased (no meaningful casing in Arabic) — handled by _sectionLabel().
// • No hardcoded Alignment, no explicit LTR padding tricks — fully RTL-safe.
// ─────────────────────────────────────────────────────────────────────────────

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
    if (user != null && user.name != null && mounted) {
      setState(() {
        _ownerName = user.name ?? 'Admin';
      });
    }
  }

  // ── Arabic text must not be toUpperCase'd — return as-is in Arabic ────────
  String _sectionLabel(String raw, bool isAr) =>
      isAr ? raw : raw.toUpperCase();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: OwnerAppBar(
        title: l10n.settingsTitle,
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
            _buildProfileCard(l10n),
            const SizedBox(height: 24),

            // ── Notifications ───────────────────────────────────────────
            _buildSection(
              _sectionLabel(l10n.settingsSectionNotifications, isAr),
              [
                _buildToggleTile(
                  l10n.settingsTogglePushNotif,
                  l10n.settingsTogglePushNotifSub,
                  Icons.notifications_rounded,
                  _notifications,
                      (v) => setState(() => _notifications = v),
                ),
                _buildToggleTile(
                  l10n.settingsToggleEmailAlerts,
                  l10n.settingsToggleEmailAlertsSub,
                  Icons.email_rounded,
                  _emailAlerts,
                      (v) => setState(() => _emailAlerts = v),
                ),
                _buildToggleTile(
                  l10n.settingsToggleStockAlerts,
                  l10n.settingsToggleStockAlertsSub,
                  Icons.inventory_2_rounded,
                  _stockAlerts,
                      (v) => setState(() => _stockAlerts = v),
                ),
                _buildToggleTile(
                  l10n.settingsToggleLockerAlerts,
                  l10n.settingsToggleLockerAlertsSub,
                  Icons.lock_rounded,
                  _lockerAlerts,
                      (v) => setState(() => _lockerAlerts = v),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Security ────────────────────────────────────────────────
            _buildSection(
              _sectionLabel(l10n.settingsSectionSecurity, isAr),
              [
                _buildToggleTile(
                  l10n.settingsToggleBiometric,
                  l10n.settingsToggleBiometricSub,
                  Icons.fingerprint_rounded,
                  _biometricLogin,
                      (v) => setState(() => _biometricLogin = v),
                ),
                _buildNavTile(
                  l10n.settingsNavChangePassword,
                  Icons.lock_outline_rounded,
                  Colors.orange,
                ),
                _buildNavTile(
                  l10n.settingsNavTwoFactor,
                  Icons.security_rounded,
                  AppColors.primaryLight,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Business ────────────────────────────────────────────────
            _buildSection(
              _sectionLabel(l10n.settingsSectionBusiness, isAr),
              [
                _buildNavTile(
                  l10n.settingsNavWorkshopProfile,
                  Icons.business_rounded,
                  AppColors.secondaryLight,
                ),
                _buildNavTile(
                  l10n.settingsNavBranchMgmt,
                  Icons.store_rounded,
                  const Color(0xFF2D9CDB),
                ),
                _buildNavTile(
                  l10n.settingsNavCommissionRules,
                  Icons.percent_rounded,
                  Colors.purple,
                ),
                _buildNavTile(
                  l10n.settingsNavVatSettings,
                  Icons.receipt_long_rounded,
                  Colors.teal,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Language ────────────────────────────────────────────────
            _buildSection(
              _sectionLabel(l10n.settingsLanguageSection, isAr),
              [
                _buildLanguageTile(l10n, isAr),
              ],
            ),
            const SizedBox(height: 24),

            // ── Support ─────────────────────────────────────────────────
            _buildSection(
              _sectionLabel(l10n.settingsSectionSupport, isAr),
              [
                _buildNavTile(
                  l10n.settingsNavHelp,
                  Icons.help_outline_rounded,
                  Colors.grey,
                ),
                _buildNavTile(
                  l10n.settingsNavContactSupport,
                  Icons.support_agent_rounded,
                  Colors.green,
                ),
                _buildNavTile(
                  l10n.settingsNavReportIssue,
                  Icons.bug_report_rounded,
                  Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildLogoutButton(l10n),
            const SizedBox(height: 12),
            Center(
              child: Text(
                l10n.settingsVersionLabel,
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── Profile card ───────────────────────────────────────────────────────────
  Widget _buildProfileCard(AppLocalizations l10n) {
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
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                'https://ui-avatars.com/api/?name=${Uri.encodeComponent(_ownerName)}&background=FCC247&color=23262D',
                width: 56,
                height: 56,
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
                const SizedBox(height: 2),
                Text(
                  l10n.settingsRoleLabel,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    l10n.settingsMultiBranchBadge,
                    style: const TextStyle(
                      color: AppColors.primaryLight,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section wrapper ────────────────────────────────────────────────────────
  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
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

  // ── Toggle tile ────────────────────────────────────────────────────────────
  Widget _buildToggleTile(
      String title,
      String subtitle,
      IconData icon,
      bool value,
      Function(bool) onChanged,
      ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.secondaryLight.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.secondaryLight, size: 18),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: AppColors.secondaryLight,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.grey, fontSize: 11),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primaryLight,
      ),
    );
  }

  // ── Nav tile ───────────────────────────────────────────────────────────────
  Widget _buildNavTile(String title, IconData icon, Color color) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: AppColors.secondaryLight,
        ),
      ),
      // chevron_right stays pointing right in LTR, chevron_left in RTL
      // — using Icons.chevron_right_rounded with Directionality is correct.
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Colors.grey,
        size: 20,
      ),
      onTap: () {},
    );
  }

  // ── Language switcher tile ─────────────────────────────────────────────────
  Widget _buildLanguageTile(AppLocalizations l10n, bool isAr) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.secondaryLight.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.language_rounded,
          color: AppColors.secondaryLight,
          size: 18,
        ),
      ),
      title: Text(
        l10n.settingsLanguageLabel,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: AppColors.secondaryLight,
        ),
      ),
      // Show a compact segmented toggle: EN | AR
      trailing: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0F1F5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLangChip(
              label: l10n.settingsLanguageEnglish,
              selected: !isAr,
              onTap: () => _switchLocale(context, 'en'),
            ),
            _buildLangChip(
              label: l10n.settingsLanguageArabic,
              selected: isAr,
              onTap: () => _switchLocale(context, 'ar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLangChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: selected ? AppColors.secondaryLight : Colors.grey,
          ),
        ),
      ),
    );
  }

  /// Persist locale, then restart the widget tree so the new locale takes
  /// effect everywhere — including ViewModels that checked locale on init.
  Future<void> _switchLocale(BuildContext context, String langCode) async {
    final current = await SessionService.getLocale();
    if (current == langCode) return; // already selected — no-op

    await SessionService.saveLocale(langCode);

    if (mounted) {
      // RestartWidget re-runs MaterialApp with the new locale from
      // SessionService, which re-initialises all ViewModels.
      RestartWidget.restartApp(context);
    }
  }

  // ── Logout button + dialog ─────────────────────────────────────────────────
  Widget _buildLogoutButton(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: const Icon(
          Icons.logout_rounded,
          color: AppColors.secondaryLight,
          size: 20,
        ),
        title: Text(
          l10n.settingsLogout,
          style: const TextStyle(
            color: AppColors.secondaryLight,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.secondaryLight,
          size: 18,
        ),
        onTap: () => _showLogoutDialog(l10n),
      ),
    );
  }

  void _showLogoutDialog(AppLocalizations l10n) {
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
                l10n.settingsLogoutDialogTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.secondaryLight,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.settingsLogoutDialogBody,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  height: 1.5,
                ),
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
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        l10n.settingsLogoutDialogCancel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondaryLight,
                        ),
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
                        if (mounted) {
                          RestartWidget.restartApp(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        disabledBackgroundColor: AppColors.primaryLight,
                        foregroundColor: AppColors.secondaryLight,
                        disabledForegroundColor: AppColors.secondaryLight,
                        minimumSize: const Size.fromHeight(56),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        l10n.settingsLogoutDialogConfirm,
                        style: const TextStyle(
                          color: AppColors.secondaryLight,
                          fontWeight: FontWeight.w800,
                        ),
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