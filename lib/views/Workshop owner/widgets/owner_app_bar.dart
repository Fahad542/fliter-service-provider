import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';

import '../owner_shell.dart';

class OwnerAppBar extends StatelessWidget implements PreferredSizeWidget {
  final dynamic title; // Can be String or Widget
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
    this.showDrawer = true,
    this.showBackButton = false,
    this.showNotification = false,
    this.showGlobalLeft = false,
    this.height = 70,
  });

  @override
  Widget build(BuildContext context) {
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
              // Center Title (Only if it's a String)
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
                
              // Left & Right Icons, plus Custom Title (Dashboard)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (showGlobalLeft) _buildGlobalButton()
                  else if (showDrawer) _buildDrawerButton(context),
                  
                  if (title is Widget) const SizedBox(width: 16),
                  if (title is Widget) Expanded(child: title as Widget),
                  if (title is String) const Spacer(), // Pushes icons to right
                  
                  if (!showGlobalLeft) _buildGlobalButton(),
                  if (!showGlobalLeft && showNotification) const SizedBox(width: 12),
                  if (showNotification) _buildNotificationButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // _buildTitle method removed as it's now handled inline inside the Stack

  Widget _buildDrawerButton(BuildContext context) {
    final onTap = showBackButton
        ? (onBackPressed ?? () => OwnerShell.goHome(context))
        : (onMenuPressed ?? () => Scaffold.maybeOf(context)?.openDrawer());

    if (showBackButton) {
      return IconButton(
        onPressed: onTap,
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.secondaryLight, size: 26),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(), // Removes default extra padding
      );
    }

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
        child: const Icon(Icons.menu_rounded, color: Colors.white, size: 22),
      ),
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
            Image.asset('assets/images/notifications.png', width: 22, color: Colors.black,
              errorBuilder: (_, __, ___) => const Icon(Icons.notifications_rounded, size: 22, color: Colors.black)),
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

  Widget _buildGlobalButton() {
    return InkWell(
      onTap: () {},
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Image.asset('assets/images/global.png', width: 22, color: Colors.black,
            errorBuilder: (_, __, ___) => const Icon(Icons.language, size: 22, color: Colors.black)),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}

// Extension to help with Dashboard's specific title style
class OwnerDashboardTitle extends StatelessWidget {
  final String subtitle;
  const OwnerDashboardTitle({super.key, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'WORKSHOP OWNER',
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
