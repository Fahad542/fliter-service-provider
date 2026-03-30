import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';
import '../models/pos_order_model.dart';
import '../utils/app_text_styles.dart';
import '../views/Workshop pos app/More Tab/settings_view_model.dart';
import 'package:provider/provider.dart';
import '../utils/app_formatters.dart';
import '../views/Workshop pos app/Home Screen/pos_view_model.dart' as pvm;
import '../models/create_invoice_model.dart';
import '../models/pos_technician_model.dart'; // Added import for TechnicianCard
import '../models/pos_product_model.dart'; // Added import for ProductCard
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/toast_service.dart';
import '../views/Workshop pos app/Notifications/notifications_view.dart';
import '../views/Workshop pos app/Product Grid/pos_product_grid_view.dart';
import '../views/Workshop pos app/Order Screen/pos_order_review_view.dart';
import '../views/Workshop pos app/Department/pos_department_view.dart';
import '../views/Workshop pos app/Technician Assignment/pos_technician_assignment_view.dart';

// ── Reusable POS Screen AppBar (Back + Title + Global Icon) ──
class PosScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final bool showBackButton;
  final bool showHamburger;
  final bool showGlobalLeft;
  final VoidCallback? onMenuPressed;
  final List<Widget>? actions;

  const PosScreenAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.showBackButton = true,
    this.showHamburger = true,
    this.showGlobalLeft = false,
    this.onMenuPressed,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final double iconContainerSize = isTablet ? 54 : 32;
    final double iconSize = isTablet ? 28 : 16;
    final double currentToolbarHeight = isTablet ? 80 : kToolbarHeight;

    return PreferredSize(
      preferredSize: Size.fromHeight(currentToolbarHeight),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(isTablet ? 32 : 24),
          ),
        ),
        child: AppBar(
          toolbarHeight: currentToolbarHeight,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leadingWidth: isTablet ? 80 : 56,
          leading: showBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: onBack ?? () => Navigator.pop(context),
                )
              : showGlobalLeft
                  ? Padding(
                      padding: EdgeInsets.only(left: isTablet ? 14 : 10),
                      child: Consumer<SettingsViewModel>(
                        builder: (context, settings, _) {
                          return InkWell(
                            onTap: () {
                              final newLocale =
                                  settings.locale.languageCode == 'en'
                                      ? const Locale('ar')
                                      : const Locale('en');
                              settings.updateLocale(newLocale);
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: isTablet ? 54 : 40,
                              height: isTablet ? 54 : 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.35),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/images/global.png',
                                  width: isTablet ? 30 : 22,
                                  color: Colors.black,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                        Icons.language_rounded,
                                        size: isTablet ? 30 : 22,
                                        color: Colors.black,
                                      ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : (showHamburger || onMenuPressed != null)
                      ? Padding(
                          padding: EdgeInsets.only(left: isTablet ? 14 : 14),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: onMenuPressed ??
                                  () => Scaffold.of(context).openDrawer(),
                              child: Container(
                                width: iconContainerSize,
                                height: iconContainerSize,
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryLight,
                                  borderRadius:
                                      BorderRadius.circular(isTablet ? 16 : 14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.secondaryLight
                                          .withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.menu_rounded,
                                  color: Colors.white,
                                  size: iconSize,
                                ),
                              ),
                            ),
                          ),
                        )
                      : null,
          title: Text(
            title,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 21 : 19,
            ),
          ),
          centerTitle: true,
          actions: [
            ...?actions,
            if (!showGlobalLeft)
              Consumer<SettingsViewModel>(
                builder: (context, settings, _) {
                  return InkWell(
                    onTap: () {
                      final newLocale = settings.locale.languageCode == 'en'
                          ? const Locale('ar')
                          : const Locale('en');
                      settings.updateLocale(newLocale);
                    },
                    child: Container(
                      width: isTablet ? 54 : 40,
                      height: isTablet ? 54 : 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.35),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/global.png',
                          width: isTablet ? 30 : 22,
                          color: Colors.black,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.language_rounded,
                            size: isTablet ? 30 : 22,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(width: 8),
            Padding(
              padding: EdgeInsets.only(right: isTablet ? 24 : 12),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsView(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: isTablet ? 54 : 40,
                  height: isTablet ? 54 : 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.35),
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/images/notifications.png',
                        width: isTablet ? 30 : 22,
                        color: Colors.black,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.notifications_rounded,
                          size: isTablet ? 30 : 22,
                          color: Colors.black,
                        ),
                      ),
                      Positioned(
                        top: isTablet ? 12 : 8,
                        right: isTablet ? 12 : 8,
                        child: Container(
                          width: isTablet ? 10 : 8,
                          height: isTablet ? 10 : 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (!showGlobalLeft) const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize {
    // This is called before build, so we use a basic check or just kToolbarHeight
    // but the PreferredSize widget above handles the actual height used in layout.
    return const Size.fromHeight(80); 
  }
}

class PosAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? userName;
  final String? infoTitle;
  final String? infoBranch;
  final String? infoTime;
  final double? customHeight;
  final bool showBackButton;
  final VoidCallback? onMenuPressed;
  final bool showDrawer;
  final bool showGlobalLeft;
  final String? customTitle;

  const PosAppBar({
    super.key,
    this.userName,
    this.infoTitle,
    this.infoBranch,
    this.infoTime,
    this.customHeight,
    this.showBackButton = false,
    this.onMenuPressed,
    this.showDrawer = true,
    this.showGlobalLeft = false,
    this.customTitle,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final double iconContainerSize = isTablet ? 56 : 36;
    final double iconSize = isTablet ? 28 : 18;
    final bool hasInfo = infoTitle != null;
    final double currentToolbarHeight = isTablet ? 110 : 70;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.primaryLight,
      elevation: 0,
      centerTitle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(isTablet ? 40 : 32),
        ),
      ),
      toolbarHeight: currentToolbarHeight,
      leadingWidth: showGlobalLeft
          ? (isTablet ? 74 : 64)
          : (showDrawer ? (isTablet ? 74 : 64) : 0),
      leading: showGlobalLeft
          ? Padding(
              padding: EdgeInsets.only(
                left: 10,
                top: isTablet ? 20 : 8,
                bottom: isTablet ? 8 : 8,
              ),
              child: Consumer<SettingsViewModel>(
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
                      width: isTablet ? 54 : 40,
                      height: isTablet ? 54 : 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.35),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/global.png',
                          width: isTablet ? 30 : 22,
                          color: Colors.black,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(
                                Icons.language_rounded,
                                size: isTablet ? 30 : 22,
                                color: Colors.black,
                              ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          : showDrawer
          ? Padding(
              padding: EdgeInsets.only(left: isTablet ? 14 : 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap:
                      onMenuPressed ?? () => Scaffold.of(context).openDrawer(),
                  child: Container(
                    width: iconContainerSize,
                    height: iconContainerSize,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryLight,
                      borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondaryLight.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.menu_rounded,
                      color: Colors.white,
                      size: iconSize,
                    ),
                  ),
                ),
              ),
            )
          : null,
      title: Padding(
        padding: EdgeInsets.only(top: isTablet ? 25 : 0),
        child: customTitle != null
            ? Text(
                customTitle!,
                style: AppTextStyles.h2.copyWith(
                  color: Colors.black,
                  fontSize: isTablet ? 24 : 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              )
            : SizedBox(
                height: isTablet ? 45 : 28,
                child: Image.asset(
                  'assets/images/icon.png',
                  color: Colors.black,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.store, color: Colors.black),
                ),
              ),
      ),
      actions: [
        if (!showGlobalLeft) ...[
          // Language Pill
          Padding(
            padding: EdgeInsets.only(
              top: isTablet ? 20 : 0,
              bottom: isTablet ? 8 : 0,
            ),
            child: Consumer<SettingsViewModel>(
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
                    width: isTablet ? 54 : 40,
                    height: isTablet ? 54 : 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.35),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/global.png',
                        width: isTablet ? 30 : 22,
                        color: Colors.black,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(
                              Icons.language_rounded,
                              size: isTablet ? 30 : 22,
                              color: Colors.black,
                            ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
        ],

        Padding(
          padding: EdgeInsets.only(
            top: isTablet ? 20 : 0,
            bottom: isTablet ? 8 : 0,
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsView(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: isTablet ? 54 : 40,
              height: isTablet ? 54 : 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.35),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/images/notifications.png',
                    width: isTablet ? 30 : 22,
                    color: Colors.black,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.notifications_rounded,
                      size: isTablet ? 30 : 22,
                      color: Colors.black,
                    ),
                  ),
                  Positioned(
                    top: isTablet ? 12 : 8,
                    right: isTablet ? 12 : 8,
                    child: Container(
                      width: isTablet ? 10 : 8,
                      height: isTablet ? 10 : 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize {
    if (customHeight != null) return Size.fromHeight(customHeight!);
    // Return a height that works for both mobile and tablet, or detect here if possible
    // Using a dynamic value based on kToolbarHeight is usually safer
    return const Size.fromHeight(110); 
  }
}

class PosInfoBar extends StatelessWidget {
  final String title;
  final String branch;
  final String? time;

  const PosInfoBar({
    super.key,
    required this.title,
    required this.branch,
    this.time,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, isTablet ? 12 : 8),
      decoration: const BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Row(
        mainAxisAlignment: isTablet
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
        children: [
          Flexible(child: _buildInfoChip(context, Icons.person, title)),
          const Spacer(),
          Flexible(child: _buildInfoChip(context, null, branch)),
        ],
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context,
    IconData? icon,
    String text, {
    bool isBlack = false,
  }) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 12 : 6,
        vertical: isTablet ? 6 : 4,
      ), // Reduced horizontal padding on mobile to fit 3 items
      decoration: BoxDecoration(
        color: isBlack
            ? const Color(0xFF212529)
            : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(30),
        border: isBlack
            ? null
            : Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: isTablet ? 15 : 11, color: Colors.white),
            SizedBox(width: isTablet ? 8 : 4),
          ],
          Flexible(
            // Use Flexible to prevent overflow if text is long
            child: Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isBlack ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: isTablet ? 11.5 : 10,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class UserChip extends StatelessWidget {
  final String name;
  final bool isTablet;

  const UserChip({super.key, required this.name, this.isTablet = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: isTablet ? 220 : 140),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const CircleAvatar(
              radius: 10,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                size: 14,
                color: AppColors.secondaryLight,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 14 : 11,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchHistoryData {
  final String vehicle;
  final String plate;
  final String customer;
  final String lastVisit;
  final String lastService;
  final bool isCorporate;

  const SearchHistoryData({
    required this.vehicle,
    required this.plate,
    required this.customer,
    required this.lastVisit,
    required this.lastService,
    required this.isCorporate,
  });
}

class SearchHistoryItem extends StatelessWidget {
  final String vehicle;
  final String plate;
  final String customer;
  final String lastVisit;
  final String lastService;
  final String? orderNumber;
  final bool isCorporate;
  final VoidCallback? onContinue;
  final VoidCallback? onViewHistory;
  final VoidCallback? onSalesReturn;

  const SearchHistoryItem({
    super.key,
    required this.vehicle,
    required this.plate,
    required this.customer,
    required this.lastVisit,
    required this.lastService,
    this.orderNumber,
    required this.isCorporate,
    this.onContinue,
    this.onViewHistory,
    this.onSalesReturn,
  });

  @override
  Widget build(BuildContext context) {
    // Reverting to compact scaling for both mobile and tablet as per user request
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Icon(
                  Icons.directions_car,
                  color: AppColors.primaryLight,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          vehicle,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        if (isCorporate) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.blue.shade100),
                            ),
                            child: const Text(
                              'CORP',
                              style: TextStyle(
                                color: Color(0xFF1E88E5), // Blue.shade700
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Plate: $plate  •  $customer',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history,
                            size: 14,
                            color: Colors.amber.shade700,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              orderNumber != null
                                  ? '$lastVisit ($lastService)  •  Order: #$orderNumber'
                                  : '$lastVisit ($lastService)',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onContinue ?? () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: AppColors.secondaryLight,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue Order',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onViewHistory ?? () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryLight,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Full History',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: onSalesReturn ?? () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade400,
                    side: BorderSide(color: Colors.red.shade200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Sales Return / Credit Note',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PosBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const PosBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, 0, Icons.home_rounded, 'Home'),
              _buildNavItem(context, 1, Icons.inventory_2_outlined, 'Products'),
              _buildNavItem(context, 2, Icons.receipt_long_outlined, 'Orders'),
              _buildNavItem(context, 3, Icons.store_rounded, 'Store Closing'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
  ) {
    final isSelected = currentIndex == index;
    final isTablet = MediaQuery.of(context).size.width > 600;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryLight.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isTablet ? 28 : 22,
              color: isSelected ? AppColors.primaryLight : Colors.grey,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: isTablet ? 12 : 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.secondaryLight : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PosSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String hintText;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;

  const PosSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.hintText = 'Search...',
    this.focusNode,
    this.onTap,
    this.inputFormatters,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: autofocus,
              textAlign: TextAlign.left,
              onTap: onTap,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1E2124),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
              inputFormatters: inputFormatters ?? [EnglishNumberFormatter()],
              onChanged: onChanged,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFCC247), // Updated matched yellow
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.search,
              color: Color(0xFF1E2124), // Updated dark color
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class OrderItemCard extends StatefulWidget {
  final PosOrder order;
  final bool isTablet;
  const OrderItemCard({super.key, required this.order, required this.isTablet});

  @override
  State<OrderItemCard> createState() => _OrderItemCardState();
}

class _OrderItemCardState extends State<OrderItemCard> {
  @override
  Widget build(BuildContext context) {
    final displayStatus = widget.order.statusText.toLowerCase();
    final isInvoiced = widget.order.status.toLowerCase() == 'invoiced';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.02)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: isInvoiced
              ? null
              : () {
                  _showOrderDetailsSheet(
                    context,
                    widget.order,
                    widget.isTablet,
                  );
                },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: widget.isTablet ? 24 : 16,
              vertical: widget.isTablet ? 16 : 14,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${widget.order.id.split('-').last.toUpperCase()}',
                            style: TextStyle(
                              fontSize: widget.isTablet ? 14 : 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  widget.order.customerName,
                                  style: TextStyle(
                                    fontSize: widget.isTablet ? 18 : 16,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1E2124),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.layers_rounded,
                                      size: widget.isTablet ? 14 : 10,
                                      color: const Color(0xFF1E2124),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${widget.order.jobsCount} JOBS',
                                      style: TextStyle(
                                        fontSize: widget.isTablet ? 11 : 9,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF1E2124),
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusPill(widget.order),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: _buildPremiumDetailItem(
                        widget.order.carModel,
                        subtitle:
                            'Plate: ${widget.order.plateNumber.toUpperCase()}',
                        isTablet: widget.isTablet,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: _buildPremiumDetailItem(
                        DateFormat(
                          'yyyy-MM-dd',
                        ).format(DateTime.parse(widget.order.date)),
                        subtitle: 'Odo: ${widget.order.odometerReading} km',
                        crossAxisAlignment: CrossAxisAlignment.end,
                        isTablet: widget.isTablet,
                      ),
                    ),
                  ],
                ),
                Builder(
                  builder: (context) {
                    String displayStatus = widget.order.statusText
                        .toLowerCase();

                    if (displayStatus == 'completed by technician') {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Consumer<pvm.PosViewModel>(
                                  builder: (context, posVm, child) {
                                    final isCurrentOrderLoading =
                                        posVm.isInvoiceLoading &&
                                        posVm.loadingOrderId == widget.order.id;

                                    return _buildActionButton(
                                      onPressed: isCurrentOrderLoading
                                          ? null
                                          : () async {
                                              if (context.mounted) {
                                                // Get department info from items first, then Jobs, then fallback
                                                String deptName = 'All';
                                                String deptId = '1';

                                                bool foundDept = false;

                                                if (widget
                                                    .order
                                                    .jobs
                                                    .isNotEmpty) {
                                                  final job =
                                                      widget.order.latestJob!;
                                                  if (job
                                                      .department
                                                      .isNotEmpty) {
                                                    deptName = job.department;
                                                  }
                                                  if (job.items.isNotEmpty &&
                                                      job
                                                          .items
                                                          .first
                                                          .departmentId
                                                          .isNotEmpty) {
                                                    deptId = job
                                                        .items
                                                        .first
                                                        .departmentId;
                                                    foundDept = true;
                                                    if (job
                                                        .items
                                                        .first
                                                        .departmentName
                                                        .isNotEmpty) {
                                                      deptName = job
                                                          .items
                                                          .first
                                                          .departmentName;
                                                    }
                                                  }
                                                }

                                                if (!foundDept &&
                                                    widget
                                                        .order
                                                        .items
                                                        .isNotEmpty) {
                                                  for (final item
                                                      in widget.order.items) {
                                                    if (item['departmentId'] !=
                                                            null &&
                                                        item['departmentId']
                                                            .toString()
                                                            .isNotEmpty) {
                                                      deptId =
                                                          item['departmentId']
                                                              .toString();
                                                      if (item['departmentName'] !=
                                                          null) {
                                                        deptName =
                                                            item['departmentName']
                                                                .toString();
                                                      }
                                                      foundDept = true;
                                                      break;
                                                    }
                                                  }
                                                }

                                                if (!foundDept &&
                                                    widget
                                                        .order
                                                        .jobs
                                                        .isNotEmpty) {
                                                  try {
                                                    final matchedProduct = posVm
                                                        .allProducts
                                                        .firstWhere(
                                                          (p) =>
                                                              p.departmentName
                                                                      ?.toLowerCase() ==
                                                                  deptName
                                                                      .toLowerCase() &&
                                                              p.departmentId !=
                                                                  null,
                                                        );
                                                    deptId = matchedProduct
                                                        .departmentId!;
                                                  } catch (e) {
                                                    // Ensure valid fallback
                                                  }
                                                }

                                                List<dynamic> preSelected = [];
                                                if (widget
                                                    .order
                                                    .jobs
                                                    .isNotEmpty) {
                                                  for (var item
                                                      in widget
                                                          .order
                                                          .latestJob!
                                                          .items) {
                                                    preSelected.add({
                                                      'productId':
                                                          item.productId,
                                                      'quantity': item.qty,
                                                      'discountType':
                                                          item.discountType,
                                                      'discountValue':
                                                          item.discountValue ?? 0.0,
                                                    });
                                                  }
                                                } else if (widget
                                                    .order
                                                    .items
                                                    .isNotEmpty) {
                                                  preSelected =
                                                      widget.order.items;
                                                }
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        PosProductGridView(
                                                          departmentName:
                                                              deptName,
                                                          departmentId: deptId,
                                                          preSelectedItems:
                                                              preSelected,
                                                          completingOrderId:
                                                              widget
                                                                  .order
                                                                  .jobs
                                                                  .isNotEmpty
                                                              ? widget
                                                                    .order
                                                                    .latestJob!
                                                                    .id
                                                              : widget.order.id,
                                                          completingOrder:
                                                              widget.order,
                                                        ),
                                                  ),
                                                );
                                              }
                                            },
                                      isLoading: isCurrentOrderLoading,
                                      icon: Icons.check_circle_outline_rounded,
                                      label: 'Service Completed',
                                      color: AppColors.primaryLight,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }

                    if (displayStatus == 'completed' ||
                        displayStatus == 'invoiced' ||
                        displayStatus.contains('pending')) {
                      final isInvoiced =
                          widget.order.status.toLowerCase() == 'invoiced';
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          if (displayStatus.contains('pending') || displayStatus.contains('draft'))
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildActionButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => PosTechnicianAssignmentView(
                                              jobId: widget.order.jobs.isNotEmpty
                                                  ? widget.order.latestJob!.id
                                                  : widget.order.id,
                                              departmentName: widget
                                                  .order.latestJob?.department,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: Icons.assignment_ind_rounded,
                                      label: 'Forward to Technician',
                                      color: AppColors.primaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (!(displayStatus.contains('pending') || displayStatus.contains('draft')))
                            Row(
                              children: [
                              Expanded(
                                child: Consumer<pvm.PosViewModel>(
                                  builder: (context, posVm, child) {
                                    final isCurrentOrderLoading =
                                        posVm.isInvoiceLoading &&
                                        posVm.loadingOrderId == widget.order.id;

                                    return _buildActionButton(
                                      onPressed: posVm.isInvoiceLoading
                                          ? null
                                          : () async {
                                              if (isInvoiced) {
                                                // Fetch and show existing invoice
                                                final response = await posVm
                                                    .fetchInvoiceByOrder(
                                                      widget.order.id,
                                                    );
                                                if (response != null &&
                                                    response.success &&
                                                    response.invoice != null &&
                                                    context.mounted) {
                                                  await showDialog(
                                                    context: context,
                                                    builder: (ctx) =>
                                                        InvoiceDialog(
                                                          invoice:
                                                              response.invoice!,
                                                        ),
                                                  );
                                                } else if (response != null &&
                                                    !response.success &&
                                                    context.mounted) {
                                                  ToastService.showError(
                                                    context,
                                                    response.message,
                                                  );
                                                }
                                              } else {
                                                // Navigate to the Final Review Screen - no API call
                                                if (context.mounted) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          PosOrderReviewView(
                                                            order: widget.order,
                                                          ),
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                      isLoading: isCurrentOrderLoading,
                                      icon: isInvoiced
                                          ? Icons.receipt_long_rounded
                                          : Icons.auto_awesome_rounded,
                                      label: isInvoiced
                                          ? 'Invoice'
                                          : 'Gen. Invoice',
                                      color: isInvoiced
                                          ? AppColors.secondaryLight
                                          : AppColors.primaryLight,
                                    );
                                  },
                                ),
                              ),
                              if (!isInvoiced) const SizedBox(width: 10),
                              if (!isInvoiced)
                                Expanded(
                                  child: Consumer<pvm.PosViewModel>(
                                    builder: (context, posVm, child) {
                                      return _buildActionButton(
                                        onPressed: () {
                                          posVm.clearCart();
                                          posVm.setCustomerData(
                                            name: widget.order.customerName,
                                            vat:
                                                '', // VAT doesn't seem to be in PosOrder list model directly
                                            mobile:
                                                widget.order.customer?.mobile ??
                                                '',
                                            vehicleNumber:
                                                widget.order.plateNumber,
                                            make:
                                                widget.order.vehicle?.make ??
                                                '',
                                            model:
                                                widget.order.vehicle?.model ??
                                                '',
                                            odometer:
                                                widget.order.odometerReading,
                                            previousOrderId: widget.order.id,
                                          );
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const PosDepartmentView(),
                                            ),
                                          );
                                        },
                                        icon: Icons.add_business_rounded,
                                        label: 'Add Dept.',
                                        color: AppColors.secondaryLight,
                                        isSecondary: true,
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _showOrderDetailsSheet(
  BuildContext context,
  PosOrder order,
  bool isTablet,
) {
  Widget buildStatusBadge(String status, {bool isPreviousCompleted = false}) {
    Color bgColor;
    Color textColor;
    switch (status.toLowerCase()) {
      case 'completed':
      case 'invoiced':
      case 'completed by technician':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        break;
      case 'pending assignment':
      case 'waiting for technician acception':
      case 'waiting for technician':
      case 'draft':
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        break;
      case 'in progress':
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        break;
      case 'cancelled':
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
    }

    String displayStatus = status.replaceAll('_', ' ').toUpperCase();
    if (displayStatus == 'WAITING FOR TECHNICIAN ACCEPTION') {
      displayStatus = 'WAITING FOR TECHNICIAN';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayStatus,
        style: AppTextStyles.bodySmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final sortedJobs = List<PosOrderJob>.from(order.jobs);
      final latestId = order.latestJob?.id;
      if (latestId != null) {
        sortedJobs.sort((a, b) {
          if (a.id == latestId) return -1;
          if (b.id == latestId) return 1;
          return 0; // maintain relative order
        });
      }

      return Container(
        constraints: BoxConstraints(
          maxHeight:
              MediaQuery.of(context).size.height * (isTablet ? 0.8 : 0.9),
        ),
        decoration: const BoxDecoration(
          color: Color(0xFFF8F9FA), // Soft beautiful light backdrop
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 48,
                height: 5,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order Details',
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.secondaryLight,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 1,
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Dark Premium Header Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF2C3036),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.customerName,
                          style: AppTextStyles.h3.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${order.vehicle?.make ?? ""} ${order.vehicle?.model ?? ""}'
                                  .trim()
                                  .isEmpty
                              ? "Walk-in${order.plateNumber.isNotEmpty ? '  •  ${order.plateNumber}' : ''}"
                              : '${order.vehicle?.make ?? ""} ${order.vehicle?.model ?? ""}  •  ${order.plateNumber.isNotEmpty ? order.plateNumber : 'N/A'}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Order #${order.id.split('-').last.toUpperCase()}',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: sortedJobs.isEmpty
                  ? Center(
                      child: Text(
                        'No departmental data found.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.grey.shade500,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
                      itemCount: sortedJobs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final job = sortedJobs[index];
                        final hasItems = job.items.isNotEmpty;
                        final isCompleted =
                            job.status.toLowerCase().contains('completed') &&
                            job.id != latestId;

                        Widget jobCard = Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Department Header Background Fill
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight.withOpacity(
                                        0.05,
                                      ),
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16),
                                      ),
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey.shade100,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryLight
                                                .withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.business_center_rounded,
                                            size: 16,
                                            color: AppColors.secondaryLight,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            job.department,
                                            style: AppTextStyles.bodyLarge
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      AppColors.secondaryLight,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        buildStatusBadge(
                                          job.status,
                                          isPreviousCompleted: isCompleted,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Items Body
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (!hasItems)
                                          Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                  ),
                                              child: Text(
                                                'No items bound to this department.',
                                                style: AppTextStyles.bodySmall
                                                    .copyWith(
                                                      color:
                                                          Colors.grey.shade400,
                                                    ),
                                              ),
                                            ),
                                          )
                                        else
                                          ...job.items.map((item) {
                                            final isLast =
                                                job.items.last == item;
                                            return Padding(
                                              padding: EdgeInsets.only(
                                                bottom: isLast ? 0 : 16,
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade300,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          item.productName,
                                                          style: AppTextStyles
                                                              .bodyMedium
                                                              .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: AppColors
                                                                    .secondaryLight,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        6,
                                                                    vertical: 2,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                color: Colors
                                                                    .grey
                                                                    .shade100,
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      4,
                                                                    ),
                                                              ),
                                                              child: Text(
                                                                "Qty: ${item.qty.toInt()}",
                                                                style: AppTextStyles
                                                                    .bodySmall
                                                                    .copyWith(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w800,
                                                                      color: Colors
                                                                          .grey
                                                                          .shade600,
                                                                      fontSize:
                                                                          10,
                                                                    ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 8,
                                                            ),
                                                            Text(
                                                              'SAR ${item.unitPrice.toStringAsFixed(2)} / ea',
                                                              style: AppTextStyles
                                                                  .bodySmall
                                                                  .copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: Colors
                                                                        .grey
                                                                        .shade500,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Text(
                                                    'SAR ${item.lineTotal.toStringAsFixed(2)}',
                                                    style: AppTextStyles
                                                        .bodyMedium
                                                        .copyWith(
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          color: AppColors
                                                              .secondaryLight,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),

                                        // Render Technicians if any
                                        if (job.technicians.isNotEmpty) ...[
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            child: Divider(
                                              height: 1,
                                              color: Color(0xFFEEEBE6),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.handyman_rounded,
                                                size: 16,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Assigned Technicians',
                                                style: AppTextStyles.bodySmall
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          ...job.technicians.map(
                                            (tech) => Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 8,
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 24,
                                                    height: 24,
                                                    decoration: BoxDecoration(
                                                      color: AppColors
                                                          .primaryLight
                                                          .withOpacity(0.15),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      Icons.person,
                                                      size: 14,
                                                      color: AppColors
                                                          .primaryLight,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      tech.name,
                                                      style: AppTextStyles
                                                          .bodyMedium
                                                          .copyWith(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: AppColors
                                                                .secondaryLight,
                                                          ),
                                                    ),
                                                  ),
                                                  Builder(
                                                    builder: (context) {
                                                      final s = tech.status?.toLowerCase() ?? '';
                                                      Color bgColor = Colors.orange.withOpacity(0.1);
                                                      Color textColor = Colors.orange.shade700;
                                                      String displayText = s.isEmpty ? 'PENDING' : tech.status!.toUpperCase();

                                                      if (displayText == 'ACCEPTED_BY_TECHNICIAN') {
                                                        displayText = 'ACCEPTED';
                                                      } else if (displayText == 'IN_PROGRESS' || displayText == 'IN PROGRESS') {
                                                        displayText = 'IN PROGRESS';
                                                      }

                                                      if (s.contains('completed') || s.contains('accepted')) {
                                                        bgColor = Colors.green.withOpacity(0.1);
                                                        textColor = Colors.green.shade700;
                                                      } else if (s.contains('progress')) {
                                                        bgColor = Colors.purple.withOpacity(0.1);
                                                        textColor = Colors.purple.shade700;
                                                      }

                                                      return Container(
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: bgColor,
                                                          borderRadius: BorderRadius.circular(6),
                                                        ),
                                                        child: Text(
                                                          displayText,
                                                          style: AppTextStyles.bodySmall.copyWith(
                                                            fontWeight: FontWeight.w800,
                                                            color: textColor,
                                                            fontSize: 10,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (latestId == job.id && !job.status.toLowerCase().contains('complete') && !job.status.toLowerCase().contains('invoice'))
                              Positioned(
                                top: -12,
                                right: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF27AE60),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF27AE60,
                                        ).withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'ACTIVE',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 9,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        );

                        return jobCard;
                      },
                    ),
            ),
          ],
        ),
      );
    },
  );
}

void _showCompletionBottomSheet(
  BuildContext context,
  PosOrder order,
  pvm.PosViewModel posVm,
) {
  final isTablet = MediaQuery.of(context).size.width > 600;

  // Parse order items for display
  final List<Map<String, dynamic>> parsedItems = [];
  if (order.items.isNotEmpty) {
    for (var item in order.items) {
      final priceDynamic = item['price'] ?? item['unitPrice'] ?? 0.0;
      final double price = (priceDynamic as num?)?.toDouble() ?? 0.0;
      parsedItems.add({
        'name': item['productName'] ?? item['name'] ?? 'Item',
        'price': price,
        'qty': item['quantity'] ?? item['qty'] ?? 1,
      });
    }
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setSheetState) {
          bool isLoading = false;
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              constraints: BoxConstraints(
                maxHeight:
                    MediaQuery.of(context).size.height *
                    (isTablet ? 0.70 : 0.85),
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFFBF9F6),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(top: 10, bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Customer & Vehicle Card
                  Container(
                    margin: EdgeInsets.fromLTRB(
                      isTablet ? 32 : 14,
                      6,
                      isTablet ? 32 : 14,
                      0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 16 : 14,
                        vertical: isTablet ? 14 : 12,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '#${order.id.split('-').last.toUpperCase()}',
                                  style: TextStyle(
                                    fontSize: isTablet ? 16 : 10,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1E2124),
                                  ),
                                ),
                              ),
                              SizedBox(width: isTablet ? 8 : 6),
                              Expanded(
                                child: Text(
                                  order.customerName,
                                  style: TextStyle(
                                    fontSize: isTablet ? 22 : 13,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1E2124),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  order.statusText.toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: isTablet ? 15 : 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isTablet ? 12 : 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.directions_car_outlined,
                                size: 22,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${order.carModel} • ${order.plateNumber.toUpperCase()}',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: isTablet ? 17 : 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.phone_outlined,
                                size: 22,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                order.customer?.mobile ?? 'N/A',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: isTablet ? 17 : 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (parsedItems.isNotEmpty) ...[
                    // Order Items Header
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        isTablet ? 36 : 18,
                        isTablet ? 24 : 12,
                        isTablet ? 36 : 18,
                        10,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Order Items',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 20 : 14,
                              color: const Color(0xFF1E2124),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${parsedItems.length}',
                              style: TextStyle(
                                fontSize: isTablet ? 16 : 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1E2124),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Order Items List
                    Flexible(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 32 : 14,
                        ),
                        shrinkWrap: true,
                        itemCount: parsedItems.length,
                        itemBuilder: (context, index) {
                          final item = parsedItems[index];
                          final qty = item['qty'] as num;
                          final price = item['price'] as double;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: EdgeInsets.all(isTablet ? 16 : 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade100),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'] as String,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: isTablet ? 14 : 12,
                                          color: const Color(0xFF1E2124),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF3F4F6),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          '$qty × SAR ${price.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: isTablet ? 11 : 9,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'SAR ${(price * qty).toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: isTablet ? 14 : 12,
                                    color: const Color(0xFF1E2124),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Action Buttons (Confirm only)
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      isTablet ? 32 : 14,
                      16,
                      isTablet ? 32 : 14,
                      MediaQuery.of(ctx).padding.bottom + 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: isTablet ? 56 : 48,
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      setSheetState(() => isLoading = true);
                                      try {
                                        final String jobIdToComplete =
                                            order.jobs.isNotEmpty
                                            ? order.latestJob!.id
                                            : order.id;
                                        final response = await posVm
                                            .completeCashierJob(
                                              jobIdToComplete,
                                            );
                                        if (response != null &&
                                            response.success) {
                                          posVm.fetchOrders();
                                          if (ctx.mounted) {
                                            Navigator.of(ctx).pop();
                                            ToastService.showSuccess(
                                              ctx,
                                              'Order marked as completed successfully',
                                            );
                                          }
                                        } else {
                                          if (ctx.mounted)
                                            ToastService.showError(
                                              ctx,
                                              response?.message ??
                                                  'Failed to complete job',
                                            );
                                        }
                                      } catch (e) {
                                        if (ctx.mounted)
                                          ToastService.showError(
                                            ctx,
                                            e.toString(),
                                          );
                                      } finally {
                                        if (ctx.mounted)
                                          setSheetState(
                                            () => isLoading = false,
                                          );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFC145),
                                foregroundColor: const Color(0xFF1E2124),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Color(0xFF1E2124),
                                      ),
                                    )
                                  : Text(
                                      'Confirm Completion',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: isTablet ? 16 : 14,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildStatusPill(PosOrder order) {
  String statusStr = order.statusText;

  String status = statusStr.toLowerCase();

  Color textColor = AppColors.secondaryLight;
  Color bgColor = AppColors.primaryLight;

  if (status == 'draft' ||
      status == 'pending' ||
      status.contains('waiting') ||
      status.contains('accepted')) {
    textColor = const Color(0xFFE67E22); // Orange for waiting
    bgColor = const Color(0xFFE67E22).withOpacity(0.15);
  } else if (status == 'in progress' || status == 'ready for invoice') {
    textColor = AppColors.secondaryLight;
    bgColor = const Color(0xFF2D9CDB).withOpacity(0.15);
  } else if (status.contains('completed') ||
      status == 'invoiced' ||
      status == 'delivered') {
    textColor = const Color(0xFF27AE60);
    bgColor = const Color(0xFF27AE60).withOpacity(0.15);
  } else if (status.contains('rejected') || status.contains('cancelled')) {
    textColor = Colors.red.shade700;
    bgColor = Colors.red.withOpacity(0.15);
  } else {
    textColor = Colors.grey.shade700;
    bgColor = Colors.grey.shade200;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      statusStr.toUpperCase().replaceAll(' ACCEPTION', ''),
      style: TextStyle(
        color: textColor,
        fontSize: 9,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      ),
    ),
  );
}

Widget _buildPremiumDetailItem(
  String title, {
  String? subtitle,
  CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
  bool isTablet = false,
}) {
  return Column(
    crossAxisAlignment: crossAxisAlignment,
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: isTablet ? 15 : 12,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1E2124),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      if (subtitle != null) ...[
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: isTablet ? 13 : 10,
            fontWeight: FontWeight.w400,
            color: Colors.grey.shade400,
          ),
        ),
      ],
    ],
  );
}

Widget _buildActionButton({
  required VoidCallback? onPressed,
  required IconData icon,
  required String label,
  required Color color,
  bool isLoading = false,
  bool isSecondary = false,
}) {
  Color bgColor = color;
  Color textColor = Colors.white;

  if (isSecondary && color == AppColors.secondaryLight) {
    bgColor = AppColors.secondaryLight;
    textColor = Colors.white;
  } else if (color == const Color(0xFF27AE60)) {
    bgColor = const Color(0xFF27AE60);
    textColor = Colors.white;
  } else if (color == AppColors.primaryLight && !isSecondary) {
    bgColor = AppColors.primaryLight;
    textColor = AppColors.secondaryLight;
  }

  return Container(
    height: 42,
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
    ),
    child: TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoading
          ? SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: textColor,
              ),
            )
          : Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: textColor,
              ),
            ),
    ),
  );
}

void _showCommissionPopup(BuildContext context, dynamic commissionData) {
  if (commissionData == null) {
    ToastService.showSuccess(context, 'Job approved successfully!');
    return;
  }

  final String techName = commissionData.technicianName;
  final double amount = commissionData.commissionAmount;

  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF27AE60),
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Job Approved!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.secondaryLight,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Technician commission has been logged.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FD),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TECHNICIAN',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        techName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondaryLight,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'COMMISSION',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'SAR ${amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF27AE60),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryLight,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class InvoiceDialog extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback? onDone;
  final String? requestedPaymentMethod;

  const InvoiceDialog({
    super.key,
    required this.invoice,
    this.onDone,
    this.requestedPaymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: 'SAR ',
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final DateTime? invDate = DateTime.tryParse(invoice.invoiceDate);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Gradient
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 20,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.secondaryLight, Color(0xFF2C3E50)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'INVOICE READY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      invoice.invoiceDate.isNotEmpty
                          ? '${invoice.invoiceNo}  •  ${invoice.invoiceDate.split('T').first}'
                          : invoice.invoiceNo,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildMetaItem(
                            'Date',
                            invDate != null
                                ? dateFormat.format(invDate)
                                : invoice.invoiceDate,
                          ),
                          _buildMetaItem(
                            'Status',
                            invoice.paymentStatus.toUpperCase(),
                            color: Colors.green,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'CUSTOMER & VEHICLE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              Icons.person_outline,
                              'Customer',
                              invoice.customerName,
                            ),
                            if (invoice.customerMobile != null &&
                                invoice.customerMobile!.isNotEmpty) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Divider(height: 1),
                              ),
                              _buildInfoRow(
                                Icons.phone_outlined,
                                'Phone',
                                invoice.customerMobile!,
                              ),
                            ],
                            if (invoice.customerTaxId != null &&
                                invoice.customerTaxId!.isNotEmpty) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Divider(height: 1),
                              ),
                              _buildInfoRow(
                                Icons.receipt_long_outlined,
                                'Tax ID',
                                invoice.customerTaxId!,
                              ),
                            ],
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Divider(height: 1),
                            ),
                            _buildInfoRow(
                              Icons.directions_car_outlined,
                              'Vehicle',
                              invoice.vehicleInfo,
                            ),
                            if (invoice.odometerReading != null) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Divider(height: 1),
                              ),
                              _buildInfoRow(
                                Icons.speed_outlined,
                                'Odometer',
                                '${invoice.odometerReading} km',
                              ),
                            ],
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Divider(height: 1),
                            ),
                            _buildInfoRow(
                              Icons.pin_outlined,
                              'Plate No',
                              invoice.plateNo.toUpperCase(),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Divider(height: 1),
                            ),
                            _buildInfoRow(
                              Icons.business_center_outlined,
                              'Billing',
                              invoice.customerType.toLowerCase().contains(
                                        'corporate',
                                      ) ||
                                      (requestedPaymentMethod != null &&
                                          requestedPaymentMethod!.contains(
                                            'Corporate',
                                          ))
                                  ? 'Corporate (Monthly)'
                                  : 'Individual',
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Divider(height: 1),
                            ),
                            _buildInfoRow(
                              Icons.payment_outlined,
                              'Method',
                              invoice.payments.isNotEmpty
                                  ? invoice.payments
                                        .map((p) => p.method)
                                        .join(', ')
                                  : ((invoice.paymentMethod?.isNotEmpty == true)
                                        ? invoice.paymentMethod!
                                        : ((requestedPaymentMethod
                                                      ?.isNotEmpty ==
                                                  true)
                                              ? requestedPaymentMethod!
                                              : 'Unpaid')),
                            ),
                            if (invoice.cashierName != null) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Divider(height: 1),
                              ),
                              _buildInfoRow(
                                Icons.person_pin_outlined,
                                'Cashier',
                                invoice.cashierName!,
                              ),
                            ],
                            if (invoice.branchName != null) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Divider(height: 1),
                              ),
                              _buildInfoRow(
                                Icons.storefront_outlined,
                                'Branch',
                                invoice.branchName!,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'ORDER ITEMS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (invoice.departments.isNotEmpty)
                        ...invoice.departments.map(
                          (dept) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Department Header
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.label_important_rounded,
                                        size: 14,
                                        color: Colors.grey.shade700,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          (dept.departmentName.isEmpty
                                                  ? 'General Services'
                                                  : dept.departmentName)
                                              .toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.grey.shade800,
                                            letterSpacing: 0.8,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Department Items
                                ...dept.items.map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 8,
                                      left: 4,
                                      right: 4,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.productName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Qty: ${item.qty.toInt()}   |   Unit Price: SAR ${currencyFormat.format(item.unitPrice).replaceAll('SAR', '').trim()}',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              'Total: SAR ${currencyFormat.format(item.lineTotal).replaceAll('SAR', '').trim()}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else // FLAT OLD ITEMS
                        ...invoice.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Qty: ${item.qty.toInt()}   |   Unit Price: SAR ${currencyFormat.format(item.unitPrice).replaceAll('SAR', '').trim()}',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      'Total: SAR ${currencyFormat.format(item.lineTotal).replaceAll('SAR', '').trim()}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Column(
                          children: [
                            _buildPriceRow(
                              'Subtotal',
                              currencyFormat.format(invoice.subtotal),
                            ),
                            const SizedBox(height: 8),
                            _buildPriceRow(
                              'VAT (15%)',
                              currencyFormat.format(invoice.vatAmount),
                            ),
                            if (invoice.discountAmount > 0) ...[
                              const SizedBox(height: 8),
                              _buildPriceRow(
                                'Discount',
                                '-${currencyFormat.format(invoice.discountAmount)}',
                                isDiscount: true,
                              ),
                            ],
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(),
                            ),
                            _buildPriceRow(
                              'Total Amount',
                              currencyFormat.format(invoice.totalAmount),
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Implement actual Bluetooth/PDF Print logic
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Printing functionality coming soon!',
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryLight,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Print',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          if (onDone != null) onDone!();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          foregroundColor: AppColors.secondaryLight,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.secondaryLight),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1E2124),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildMetaItem(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color ?? const Color(0xFF1E2124),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    bool isTotal = false,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
            color: isTotal ? const Color(0xFF1E2124) : Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20 : 14,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w800,
            color: isDiscount
                ? Colors.red
                : (isTotal
                      ? AppColors.secondaryLight
                      : const Color(0xFF1E2124)),
          ),
        ),
      ],
    );
  }
}

class TechnicianCard extends StatelessWidget {
  final PosTechnician tech;
  const TechnicianCard({super.key, required this.tech});

  Color _getStatusColor(String status) {
    final lowerStatus = status.toLowerCase();
    if (lowerStatus.contains('online') ||
        lowerStatus.contains('available') ||
        lowerStatus.contains('active')) {
      return Colors.green.shade600;
    } else if (lowerStatus.contains('busy') ||
        lowerStatus.contains('working') ||
        lowerStatus.contains('ongoing')) {
      return Colors.orange.shade600;
    }
    return Colors.grey.shade500;
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final statusColor = _getStatusColor(tech.statusInfo);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: isTablet ? 28 : 24,
            backgroundColor: AppColors.primaryLight.withOpacity(0.15),
            child: Icon(
              Icons.person,
              size: isTablet ? 28 : 24,
              color: AppColors.secondaryLight,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tech.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isTablet ? 19 : 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E2124),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: isTablet ? 8 : 6,
                      height: isTablet ? 8 : 6,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tech.statusInfo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isTablet ? 11 : 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey.shade300,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
    this.width,
    this.height,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 95,
      height: height ?? 85, // Use provided height or fallback
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: accentColor.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background icon removed as per request
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: textColor ?? Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: AppTextStyles.h2.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: textColor ?? AppColors.secondaryLight,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return PosSearchBar(
      hintText: 'Search item or service',
      onChanged: (val) => context.read<pvm.PosViewModel>().setSearchQuery(val),
    );
  }
}

class CategorySelector extends StatelessWidget {
  const CategorySelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<pvm.PosViewModel>(
      builder: (context, vm, child) {
        final categories = vm.uniqueCategories;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((cat) {
              final isSelected = vm.selectedCategory == cat;
              return GestureDetector(
                onTap: () => vm.setCategory(cat),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFCC247) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFCC247)
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Text(
                    cat,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isSelected
                          ? const Color(0xFF1E2124)
                          : Colors.grey.shade500,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final PosProduct product;
  const ProductCard({super.key, required this.product});

  Color _getStockColor(int stock) {
    if (stock >= 30) return const Color(0xFF27AE60); // Green
    if (stock >= 10) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final stockColor = _getStockColor(product.stock);
    final currencyFormat = NumberFormat.currency(symbol: '', decimalDigits: 2);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E2124),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: stockColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Stock: ${product.stock}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: stockColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (product.subtitle.isNotEmpty)
                Expanded(
                  child: Text(
                    product.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'SAR ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1E2124),
                ),
              ),
              Text(
                currencyFormat.format(product.price * 1.15), // Price incl. VAT
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E2124),
                ),
              ),
              Text(
                ' (Inc. VAT)',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DottedContainer extends StatelessWidget {
  final Widget child;
  const DottedContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: CustomPaint(painter: DottedPainter(), child: child),
    );
  }
}

class DottedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 5;
    const dashSpace = 3;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(16),
        ),
      );

    for (var i = 0; i < path.computeMetrics().length; i++) {
      final metric = path.computeMetrics().elementAt(i);
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
