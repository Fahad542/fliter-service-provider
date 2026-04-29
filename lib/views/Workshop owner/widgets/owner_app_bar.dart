import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../views/Workshop pos app/More Tab/settings_view_model.dart';
import '../owner_shell.dart';

// ─────────────────────────────────────────────────────────────────────────────
// OwnerAppBar
//
// The app bar used across all Workshop Owner screens.
//
// The globe (🌐) button in the top-right toggles between English and Arabic.
// When the locale changes, SettingsViewModel notifies all listeners, which
// causes every ChangeNotifier-based ViewModel (AccountingViewModel,
// ApprovalsViewModel, etc.) that observes locale to re-translate their cached
// API data automatically.
// ─────────────────────────────────────────────────────────────────────────────

class OwnerAppBar extends StatelessWidget implements PreferredSizeWidget {
  final dynamic title; // String or Widget
  final List<Widget>? actions;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onBackPressed;
  final bool showDrawer;
  final bool showBackButton;
  final bool showNotification;
  final bool showGlobalLeft;
  final double height;

  const OwnerAppBar({
    super.key,
    required this.title,
    this.actions,
    this.onMenuPressed,
    this.onNotificationPressed,
    this.onBackPressed,
    this.showDrawer      = true,
    this.showBackButton  = false,
    this.showNotification = false,
    this.showGlobalLeft  = false,
    this.height          = 70,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              // ── Centred String title ──────────────────────────────────────
              if (title is String)
                Center(
                  child: Text(
                    (title as String).toUpperCase(),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.h2.copyWith(
                      fontSize: 16,
                      color: AppColors.secondaryLight,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              // ── Left / Right icons + Widget title (Dashboard) ─────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (showGlobalLeft)
                    _buildGlobalButton(context)
                  else if (showDrawer || showBackButton)
                    _buildDrawerButton(context),

                  if (title is Widget) const SizedBox(width: 16),
                  if (title is Widget) Expanded(child: title as Widget),
                  if (title is String) const Spacer(),

                  if (!showGlobalLeft) _buildGlobalButton(context),
                  if (!showGlobalLeft && showNotification)
                    const SizedBox(width: 12),
                  if (showNotification) _buildNotificationButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerButton(BuildContext context) {
    if (showBackButton) {
      final onTap = onBackPressed ?? () => OwnerShell.goHome(context);
      return IconButton(
        onPressed: onTap,
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: AppColors.secondaryLight,
          size: 30,
        ),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      );
    }

    return Builder(
      builder: (innerContext) {
        final onTap =
            onMenuPressed ?? () => OwnerShell.openDrawer(innerContext);
        return InkWell(
          onTap: onTap,
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
            child:
            const Icon(Icons.menu_rounded, color: Colors.white, size: 22),
          ),
        );
      },
    );
  }

  Widget _buildNotificationButton() {
    return InkWell(
      onTap: onNotificationPressed ?? () {},
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/images/notifications.png',
              width: 22,
              color: Colors.black,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.notifications_rounded,
                size: 22,
                color: Colors.black,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Globe / language toggle ───────────────────────────────────────────────
  //
  // Reads the current locale from SettingsViewModel and toggles between
  // 'en' and 'ar' on tap — identical to the implementation in CustomAppBar.
  // Using Consumer so the button itself re-renders when locale changes,
  // though the visual is the same globe icon in both locales.

  Widget _buildGlobalButton(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, settings, _) {
        return InkWell(
          onTap: () {
            final newLocale = settings.locale.languageCode == 'en'
                ? const Locale('ar')
                : const Locale('en');
            settings.updateLocale(newLocale);
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                'assets/images/global.png',
                width: 22,
                color: Colors.black,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.language,
                  size: 22,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}

// ─────────────────────────────────────────────────────────────────────────────
// OwnerDashboardTitle — used as a Widget title on the dashboard screen.
// ─────────────────────────────────────────────────────────────────────────────

class OwnerDashboardTitle extends StatelessWidget {
  final String subtitle;
  const OwnerDashboardTitle({super.key, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.ownerDashboardRoleLabel,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: AppColors.secondaryLight.withOpacity(0.6),
          ),
        ),
        Text(
          subtitle,
          style: AppTextStyles.h2.copyWith(
            fontSize: 16,
            color: AppColors.secondaryLight,
          ),
        ),
      ],
    );
  }
}