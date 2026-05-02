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
import 'package:intl/intl.dart' hide TextDirection;
import 'package:share_plus/share_plus.dart';
import '../utils/toast_service.dart';
import '../utils/pos_tablet_layout.dart';
import '../utils/pos_shell_scaffold.dart' show PosShellScaffoldRegistry;
import '../views/Workshop pos app/Notifications/notifications_view.dart';
import '../views/Workshop pos app/Product Grid/pos_product_grid_view.dart';
import '../views/Workshop pos app/Order Screen/pos_order_review_view.dart';
import '../views/Workshop pos app/Department/pos_department_view.dart';
import '../views/Workshop pos app/Technician Assignment/pos_technician_assignment_view.dart';
import '../views/Workshop pos app/Add Customer Screen/pos_add_customer_view.dart';
import '../services/invoice_network_print.dart';
import '../services/invoice_thermal_escpos.dart';
import '../services/thermal_printer_settings.dart';
import 'cashier_invoice_preview.dart';

/// Drawer menu (hamburger) is always available on tablet; the left rail was removed.
bool kPosHideDrawerMenuTabletLandscape(BuildContext context) => false;

// ── Reusable POS Screen AppBar (Back + Title + Global Icon) ──
class PosScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final FontWeight? titleFontWeight;
  final VoidCallback? onBack;
  final bool showBackButton;
  final bool showHamburger;
  final bool showGlobalLeft;
  final VoidCallback? onMenuPressed;
  final List<Widget>? actions;

  const PosScreenAppBar({
    super.key,
    required this.title,
    this.titleFontWeight,
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
    final double iconContainerSize =
        isTablet ? PosTabletLayout.appBarIconBox : 32;
    final double iconSize =
        isTablet ? PosTabletLayout.appBarIconGlyph : 16;
    final double currentToolbarHeight = PosTabletLayout.appBarHeight;
    final hideDrawerMenu = kPosHideDrawerMenuTabletLandscape(context) &&
        !showBackButton &&
        !showGlobalLeft;
    final showMenuLeading =
        (showHamburger || onMenuPressed != null) && !hideDrawerMenu;

    return PreferredSize(
      preferredSize: Size.fromHeight(currentToolbarHeight),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(
                isTablet ? PosTabletLayout.appBarBottomRadius : 24),
          ),
        ),
        child: AppBar(
          toolbarHeight: currentToolbarHeight,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leadingWidth: showBackButton
              ? (isTablet ? 56 : 48)
              : showGlobalLeft
                  ? (isTablet ? 80 : 56)
                  : showMenuLeading
                      ? (isTablet ? 80 : 56)
                      : (isTablet ? 18 : 12),
          leading: showBackButton
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: isTablet ? PosTabletLayout.appBarBackIcon : 28,
                  ),
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
                              width: isTablet ? PosTabletLayout.appBarIconBox : 40,
                              height: isTablet ? PosTabletLayout.appBarIconBox : 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.35),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/images/global.png',
                                  width: isTablet ? 26 : 22,
                                  color: Colors.black,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                        Icons.language_rounded,
                                        size: isTablet ? 26 : 22,
                                        color: Colors.black,
                                      ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : showMenuLeading
                      ? Padding(
                          padding: EdgeInsets.only(left: isTablet ? 14 : 14),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: onMenuPressed ??
                                  PosShellScaffoldRegistry.openDrawer,
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
                      : Padding(
                          padding: EdgeInsets.only(left: isTablet ? 10 : 6),
                          child: const SizedBox.shrink(),
                        ),
          title: InkWell(
            onTap: PosShellScaffoldRegistry.openDrawer,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: titleFontWeight ?? FontWeight.bold,
                  fontSize:
                      isTablet ? PosTabletLayout.appBarTitleSize : 19,
                ),
              ),
            ),
          ),
          centerTitle: true,
          actions: [
            ...?actions,
            Padding(
              padding: EdgeInsets.only(right: isTablet ? 18 : 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!showGlobalLeft)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
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
                              width: isTablet
                                  ? PosTabletLayout.appBarIconBox
                                  : 40,
                              height: isTablet
                                  ? PosTabletLayout.appBarIconBox
                                  : 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.35),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/images/global.png',
                                  width: isTablet ? 26 : 22,
                                  color: Colors.black,
                                  errorBuilder:
                                      (context, error, stackTrace) => Icon(
                                    Icons.language_rounded,
                                    size: isTablet ? 26 : 22,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  InkWell(
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
                      width: isTablet ? PosTabletLayout.appBarIconBox : 40,
                      height: isTablet ? PosTabletLayout.appBarIconBox : 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.35),
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/notifications.png',
                            width: isTablet ? 26 : 22,
                            color: Colors.black,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(
                              Icons.notifications_rounded,
                              size: isTablet ? 26 : 22,
                              color: Colors.black,
                            ),
                          ),
                          Positioned(
                            top: isTablet ? 9 : 8,
                            right: isTablet ? 9 : 8,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(PosTabletLayout.appBarHeight);
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
    final double iconContainerSize =
        isTablet ? PosTabletLayout.menuIconBox : 36;
    final double iconSize =
        isTablet ? PosTabletLayout.menuIconGlyph : 18;
    final double currentToolbarHeight =
        customHeight ?? PosTabletLayout.appBarHeight;
    final hideDrawerMenu =
        showDrawer && kPosHideDrawerMenuTabletLandscape(context);
    final showDrawerLeading = showDrawer && !hideDrawerMenu;
    // Home (etc.): rail replaces drawer — put FILTER logo at start of app bar.
    final alignTitleStart =
        hideDrawerMenu && !showGlobalLeft && !showBackButton;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.primaryLight,
      elevation: 0,
      centerTitle: !alignTitleStart,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(
              isTablet ? PosTabletLayout.appBarBottomRadius : 24),
        ),
      ),
      toolbarHeight: currentToolbarHeight,
      leadingWidth: showGlobalLeft
          ? (isTablet ? 74 : 64)
          : showDrawerLeading
              ? (isTablet ? 74 : 64)
              : hideDrawerMenu
                  ? (isTablet ? 20 : 12)
                  : 0,
      leading: showGlobalLeft
          ? Padding(
              padding: EdgeInsets.only(
                left: 10,
                top: isTablet ? 8 : 8,
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
                      width: isTablet ? PosTabletLayout.appBarIconBox : 40,
                      height: isTablet ? PosTabletLayout.appBarIconBox : 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.35),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/global.png',
                          width: isTablet ? 26 : 22,
                          color: Colors.black,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(
                                Icons.language_rounded,
                                size: isTablet ? 26 : 22,
                                color: Colors.black,
                              ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          : showDrawerLeading
              ? Padding(
                  padding: EdgeInsets.only(left: isTablet ? 14 : 14),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onMenuPressed ??
                          PosShellScaffoldRegistry.openDrawer,
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
              : hideDrawerMenu
                  ? const SizedBox.shrink()
                  : null,
      title: Padding(
        padding: EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: showDrawer && !showBackButton
                ? PosShellScaffoldRegistry.openDrawer
                : null,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: customTitle != null
                  ? Text(
                      customTitle!,
                      style: AppTextStyles.h2.copyWith(
                        color: Colors.black,
                        fontSize: isTablet
                            ? PosTabletLayout.appBarTitleSize
                            : 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    )
                  : SizedBox(
                      height:
                          isTablet ? PosTabletLayout.appBarLogoHeight : 28,
                      child: Image.asset(
                        'assets/images/icons.png',
                        color: AppColors.secondaryLight,
                        colorBlendMode: BlendMode.srcIn,
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        filterQuality: FilterQuality.high,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(
                          'assets/images/Icon.png',
                          color: AppColors.secondaryLight,
                          colorBlendMode: BlendMode.srcIn,
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.store,
                            color: AppColors.secondaryLight,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: isTablet ? 18 : 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!showGlobalLeft)
                Consumer<SettingsViewModel>(
                  builder: (context, settings, _) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InkWell(
                        onTap: () {
                          final newLocale =
                              settings.locale.languageCode == 'en'
                                  ? const Locale('ar')
                                  : const Locale('en');
                          settings.updateLocale(newLocale);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: isTablet
                              ? PosTabletLayout.appBarIconBox
                              : 40,
                          height: isTablet
                              ? PosTabletLayout.appBarIconBox
                              : 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.35),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/global.png',
                              width: isTablet ? 26 : 22,
                              color: Colors.black,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                Icons.language_rounded,
                                size: isTablet ? 26 : 22,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              InkWell(
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
                  width: isTablet ? PosTabletLayout.appBarIconBox : 40,
                  height: isTablet ? PosTabletLayout.appBarIconBox : 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.35),
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/images/notifications.png',
                        width: isTablet ? 26 : 22,
                        color: Colors.black,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(
                          Icons.notifications_rounded,
                          size: isTablet ? 26 : 22,
                          color: Colors.black,
                        ),
                      ),
                      Positioned(
                        top: isTablet ? 9 : 8,
                        right: isTablet ? 9 : 8,
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
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize {
    if (customHeight != null) return Size.fromHeight(customHeight!);
    return const Size.fromHeight(PosTabletLayout.appBarHeight);
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
  final String? phone;
  final String lastVisit;
  final String lastService;
  final bool isCorporate;

  const SearchHistoryData({
    required this.vehicle,
    required this.plate,
    required this.customer,
    this.phone,
    required this.lastVisit,
    required this.lastService,
    required this.isCorporate,
  });
}

class SearchHistoryItem extends StatelessWidget {
  final String vehicle;
  final String plate;
  final String customer;
  final String? phone;
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
    this.phone,
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
    return FractionallySizedBox(
      widthFactor: 0.94,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              customer,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
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
                          const SizedBox(width: 6),
                          Material(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: onViewHistory ?? () {},
                              borderRadius: BorderRadius.circular(10),
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Icon(
                                  Icons.keyboard_arrow_right,
                                  color: AppColors.secondaryLight,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (vehicle.trim().isNotEmpty &&
                          vehicle.toLowerCase() != 'no vehicle') ...[
                        const SizedBox(height: 6),
                        Text(
                          vehicle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 9),
                      Text(
                        'Plate: $plate${(phone != null && phone!.trim().isNotEmpty) ? '  •  ${phone!.trim()}' : ''}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
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
            const SizedBox(height: 14),
            Row(
              children: [
              if (onContinue != null) ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLight,
                      foregroundColor: AppColors.secondaryLight,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: const Size(0, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continue Order',
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: AppColors.secondaryLight,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: onSalesReturn ?? () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryLight,
                    foregroundColor: AppColors.onSecondaryLight,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    minimumSize: const Size(0, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Sales Return',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: AppColors.onSecondaryLight,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              ],
            ),
          ],
        ),
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
              size: isTablet ? 25 : 22,
              color: isSelected ? AppColors.primaryLight : Colors.grey,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: isTablet ? 11 : 10,
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
    final fieldFont = isTablet ? 13.0 : 14.0;

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
              style: TextStyle(
                fontSize: fieldFont,
                color: const Color(0xFF1E2124),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: fieldFont,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 16 : 20,
                  vertical: isTablet ? 12 : 14,
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
  PosOrderJob? _getHighestJobById() {
    if (widget.order.jobs.isEmpty) return null;
    final sorted = List<PosOrderJob>.from(widget.order.jobs);
    sorted.sort(
      (a, b) =>
          (int.tryParse(a.id) ?? 0).compareTo(int.tryParse(b.id) ?? 0),
    );
    return sorted.last;
  }

  void _openEditOrderFlow(BuildContext context) {
    final posVm = context.read<pvm.PosViewModel>();

    String departmentId = '1';
    String departmentName = 'All';

    if (widget.order.jobs.isNotEmpty) {
      final latestJob = _getHighestJobById()!;
      if (latestJob.department.isNotEmpty) {
        departmentName = latestJob.department;
      }
      if (latestJob.items.isNotEmpty &&
          latestJob.items.first.departmentId.isNotEmpty) {
        departmentId = latestJob.items.first.departmentId;
      }
    }

    if (departmentId == '1' && widget.order.items.isNotEmpty) {
      for (final item in widget.order.items) {
        final itemDepartmentId = item['departmentId']?.toString();
        if (itemDepartmentId != null && itemDepartmentId.isNotEmpty) {
          departmentId = itemDepartmentId;
          final itemDepartmentName = item['departmentName']?.toString();
          if (itemDepartmentName != null && itemDepartmentName.isNotEmpty) {
            departmentName = itemDepartmentName;
          }
          break;
        }
      }
    }

    List<dynamic> preSelectedItems = [];
    if (widget.order.jobs.isNotEmpty) {
      final highestJob = _getHighestJobById()!;
      for (final item in dedupeCashierServiceLinesForPosDisplay(highestJob.items)) {
        preSelectedItems.add({
          item.itemType == 'service' ? 'serviceId' : 'productId': item.productId,
          'quantity': item.qty,
          'discountType': item.discountType,
          'discountValue': item.discountValue ?? 0.0,
          if (item.itemType == 'service' && item.unitPrice > 0) 'unitPrice': item.unitPrice,
        });
      }
    } else if (widget.order.items.isNotEmpty) {
      preSelectedItems = widget.order.items;
    }

    posVm.clearCart();
    posVm.setCustomerData(
      name: widget.order.customerName,
      vat: widget.order.customer?.vatNumber ?? '',
      mobile: widget.order.customer?.mobile ?? '',
      vehicleNumber: widget.order.plateNumber,
      vinNumber: widget.order.vehicle?.vin ?? '',
      make: widget.order.vehicle?.make ?? '',
      model: widget.order.vehicle?.model ?? '',
      odometer: widget.order.odometerReading,
      previousOrderId: widget.order.id,
      vehicleYear: widget.order.vehicle?.year ?? '',
      vehicleColor: widget.order.vehicle?.color ?? '',
    );
    posVm.setEditOrderContext(
      departmentId: departmentId,
      preSelectedItems: preSelectedItems,
      order: widget.order,
      completingOrderId: widget.order.jobs.isNotEmpty
          ? _getHighestJobById()!.id
          : widget.order.id,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PosAddCustomerView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isInvoiced = widget.order.status.toLowerCase() == 'invoiced';

    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.02)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
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
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                widget.isTablet ? 12 : 16,
                widget.isTablet ? 9 : 14,
                widget.isTablet ? 12 : 16,
                widget.isTablet ? 8 : 14,
              ),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Order #${widget.order.id.split('-').last.toUpperCase()}',
                                  style: TextStyle(
                                    fontSize: widget.isTablet ? 10 : 8.5,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1,
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
                                      size: widget.isTablet ? 13 : 9,
                                      color: const Color(0xFF1E2124),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${widget.order.jobsCount} JOB',
                                      style: TextStyle(
                                        fontSize: widget.isTablet ? 8 : 7.5,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF1E2124),
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              _buildStatusPill(widget.order),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.order.plateNumber.trim().isNotEmpty
                                ? widget.order.plateNumber.toUpperCase()
                                : '—',
                            style: TextStyle(
                              fontSize: widget.isTablet ? 13 : 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E2124),
                              height: 1.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (posOrderCanCashierCancel(widget.order))
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => showCashierCancelOrderDialog(
                              context,
                              widget.order.id,
                            ),
                            customBorder: const CircleBorder(),
                            child: Container(
                              width: widget.isTablet ? 28 : 26,
                              height: widget.isTablet ? 28 : 26,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: Color(0xFF1E2124),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: widget.isTablet ? 16 : 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: widget.isTablet ? 8 : 10),
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: _buildPremiumDetailItem(
                        widget.order.customerName == 'Unknown'
                            ? (widget.order.carModel.isNotEmpty
                                ? widget.order.carModel
                                : '—')
                            : widget.order.customerName,
                        subtitle: widget.order.carModel.isNotEmpty &&
                                widget.order.customerName != 'Unknown'
                            ? widget.order.carModel
                            : null,
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
                SizedBox(height: widget.isTablet ? 5 : 4),
                if (widget.order.isCorporateWalkIn &&
                    widget.order.selectedDepartmentNames.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.isTablet ? 10 : 8,
                      vertical: widget.isTablet ? 8 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected departments',
                          style: TextStyle(
                            fontSize: widget.isTablet ? 10 : 9,
                            color: const Color(0xFF475569),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: widget.isTablet ? 6 : 5),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: widget.order.selectedDepartmentNames
                              .map(
                                (name) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: widget.isTablet ? 9.5 : 9,
                                      color: const Color(0xFF1E3A8A),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: widget.isTablet ? 6 : 5),
                ],
                if (widget.order.isCorporateWalkIn &&
                    widget.order.selectedDepartmentNames.isEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.isTablet ? 10 : 8,
                      vertical: widget.isTablet ? 8 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEFCE8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFEF08A)),
                    ),
                    child: Text(
                      'Departments not returned in order list payload.',
                      style: TextStyle(
                        fontSize: widget.isTablet ? 10 : 9,
                        color: const Color(0xFF854D0E),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(height: widget.isTablet ? 6 : 5),
                ],
                Builder(
                  builder: (_) {
                    return Row(
                      children: [
                        Icon(
                          Icons.engineering_rounded,
                          size: widget.isTablet ? 11 : 11,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Technician: ${widget.order.assignedTechnicianNames.trim().isEmpty ? 'None' : widget.order.assignedTechnicianNames}',
                            style: TextStyle(
                              fontSize: widget.isTablet ? 8.5 : 8,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                              height: 1.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: widget.isTablet ? 8 : 10),
                Builder(
                  builder: (context) {
                    String displayStatus = widget.order.displayJobStatus
                        .toLowerCase();
                    final isCorporateOrder = widget.order.isCorporateWalkIn;
                    final isCorporateUnapproved =
                        isCorporateOrder && widget.order.isCorporateUnapproved;
                    final isCorporateWaiting =
                        isCorporateOrder && widget.order.isWaitingCorporateApproval;
                    final isCorporateRejected =
                        isCorporateOrder && widget.order.isRejectedByCorporate;
                    final canShowCancelOrder =
                        posOrderCanCashierCancel(widget.order);
                    final canShowOrderDetails =
                        displayStatus != 'completed' &&
                        displayStatus != 'completed by technician' &&
                        displayStatus != 'invoiced' &&
                        displayStatus != 'pending assignment' &&
                        displayStatus != 'cancelled';

                    if (displayStatus == 'completed by technician') {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: widget.isTablet ? 5 : 4),
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
                                                      _getHighestJobById()!;
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
                                                  final highestJob =
                                                      _getHighestJobById()!;
                                                  for (var item
                                                      in highestJob.items) {
                                                    preSelected.add({
                                                      item.itemType == 'service'
                                                          ? 'serviceId'
                                                          : 'productId':
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
                                                posVm.clearCart();
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
                                                                    .jobs
                                                                    .reduce((a, b) => (int.tryParse(a.id) ?? 0) > (int.tryParse(b.id) ?? 0) ? a : b)
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
                                      label: 'Complete',
                                      color: AppColors.secondaryLight,
                                      isSecondary: true,
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: widget.isTablet ? 10 : 8),
                              Expanded(
                                child: _buildActionButton(
                                  onPressed: () {
                                    _showOrderDetailsSheet(
                                      context,
                                      widget.order,
                                      widget.isTablet,
                                    );
                                  },
                                  icon: Icons.visibility_outlined,
                                  label: 'Order Details',
                                  color: AppColors.primaryLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }

                    if (displayStatus == 'completed' ||
                        displayStatus == 'invoiced' ||
                        displayStatus.contains('pending') ||
                        isCorporateUnapproved ||
                        isCorporateWaiting ||
                        isCorporateRejected) {
                      final isInvoiced =
                          widget.order.status.toLowerCase() == 'invoiced';
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: widget.isTablet ? 5 : 4),
                          if (isCorporateWaiting)
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: widget.isTablet ? 10 : 8,
                              ),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: const Text(
                                  'Waiting corporate approval',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              ),
                            ),
                          if (isCorporateRejected)
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: widget.isTablet ? 10 : 8,
                              ),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFFECACA)),
                                ),
                                child: Text(
                                  widget.order.corporateApprovalRejectionReason
                                              ?.trim()
                                              .isNotEmpty ==
                                          true
                                      ? 'Rejected by corporate: ${widget.order.corporateApprovalRejectionReason!.trim()}'
                                      : 'Rejected by corporate',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF991B1B),
                                  ),
                                ),
                              ),
                            ),
                          if (isCorporateUnapproved)
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: widget.isTablet ? 10 : 8,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildActionButton(
                                      onPressed: () => _openEditOrderFlow(context),
                                      icon: Icons.edit_rounded,
                                      label: 'Edit Order',
                                      color: AppColors.primaryLight,
                                      labelFontSize: 12,
                                    ),
                                  ),
                                  SizedBox(width: widget.isTablet ? 10 : 8),
                                  Expanded(
                                    child: Consumer<pvm.PosViewModel>(
                                      builder: (context, vm, _) {
                                        return _buildActionButton(
                                          onPressed: vm.isLoading
                                              ? null
                                              : () => vm.sendCorporateOrderForApproval(
                                                    context,
                                                    orderId: widget.order.id,
                                                  ),
                                          icon: Icons.send_rounded,
                                          label: 'Send for Approval',
                                          color: AppColors.secondaryLight,
                                          isSecondary: true,
                                          labelFontSize: 11,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if ((displayStatus.contains('pending') ||
                                  displayStatus.contains('draft')) &&
                              !isCorporateWaiting &&
                              !isCorporateRejected &&
                              !isCorporateUnapproved)
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: widget.isTablet ? 10 : 8,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildActionButton(
                                      onPressed: () {
                                        if (displayStatus ==
                                            'pending assignment') {
                                          _openEditOrderFlow(context);
                                          return;
                                        }
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) {
                                              final j = widget
                                                      .order.jobs.isNotEmpty
                                                  ? _getHighestJobById()
                                                  : null;
                                              return PosTechnicianAssignmentView(
                                                jobId: j?.id ?? widget.order.id,
                                                departmentName: j?.department ??
                                                    widget.order.latestJob
                                                        ?.department,
                                                departmentId: j?.departmentId,
                                                initialAssignedTechnicians:
                                                    j?.distinctActiveTechnicians ??
                                                        const [],
                                              );
                                            },
                                          ),
                                        );
                                      },
                                      icon: Icons.assignment_ind_rounded,
                                      label: displayStatus == 'pending assignment'
                                          ? 'Edit Order'
                                          : 'Forward to Technician',
                                      color: AppColors.primaryLight,
                                      labelFontSize: 12,
                                    ),
                                  ),
                                  if (canShowCancelOrder) ...[
                                    SizedBox(width: widget.isTablet ? 10 : 8),
                                    Expanded(
                                      child: _buildActionButton(
                                        onPressed: () =>
                                            showCashierCancelOrderDialog(
                                          context,
                                          widget.order.id,
                                        ),
                                        icon: Icons.cancel_outlined,
                                        label: 'Cancel Order',
                                        color: AppColors.secondaryLight,
                                        isSecondary: true,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          if (canShowOrderDetails) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildActionButton(
                                    onPressed: () {
                                      _showOrderDetailsSheet(
                                        context,
                                        widget.order,
                                        widget.isTablet,
                                      );
                                    },
                                    icon: Icons.visibility_outlined,
                                    label: 'Order Details',
                                    color: AppColors.primaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (!(displayStatus.contains('pending') ||
                                  displayStatus.contains('draft')) &&
                              !isCorporateWaiting &&
                              !isCorporateRejected &&
                              !isCorporateUnapproved)
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
                                                          maintenanceChecksFallback:
                                                              widget.order
                                                                  .maintenanceChecks,
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
                                                if (!widget.order
                                                    .meetsCashierInvoicePrerequisites) {
                                                  ToastService.showError(
                                                    context,
                                                    'Order is not ready for invoicing.',
                                                  );
                                                  return;
                                                }
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
                              if (!isInvoiced)
                                SizedBox(width: widget.isTablet ? 10 : 8),
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
                                                widget.order.customer?.vatNumber ??
                                                '',
                                            mobile:
                                                widget.order.customer?.mobile ??
                                                '',
                                            vehicleNumber:
                                                widget.order.plateNumber,
                                            vinNumber:
                                                widget.order.vehicle?.vin ?? '',
                                            make:
                                                widget.order.vehicle?.make ??
                                                '',
                                            model:
                                                widget.order.vehicle?.model ??
                                                '',
                                            odometer:
                                                widget.order.odometerReading,
                                            previousOrderId: widget.order.id,
                                            vehicleYear:
                                                widget.order.vehicle?.year ??
                                                '',
                                            vehicleColor:
                                                widget.order.vehicle?.color ??
                                                '',
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
                    if (canShowCancelOrder) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: widget.isTablet ? 5 : 4),
                          Row(
                            children: [
                              Expanded(
                                child: _buildActionButton(
                                  onPressed: canShowOrderDetails
                                      ? () {
                                          _showOrderDetailsSheet(
                                            context,
                                            widget.order,
                                            widget.isTablet,
                                          );
                                        }
                                      : null,
                                  icon: Icons.visibility_outlined,
                                  label: 'Order Details',
                                  color: AppColors.primaryLight,
                                ),
                              ),
                              SizedBox(width: widget.isTablet ? 10 : 8),
                              Expanded(
                                child: _buildActionButton(
                                  onPressed: () =>
                                      showCashierCancelOrderDialog(
                                    context,
                                    widget.order.id,
                                  ),
                                  icon: Icons.cancel_outlined,
                                  label: 'Cancel Order',
                                  color: AppColors.secondaryLight,
                                  isSecondary: true,
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
      ),
    );
  }
}

/// Whether the cashier may cancel the whole order (`POST /cashier/order/:id/cancel`).
bool posOrderCanCashierCancel(PosOrder order) {
  final normalizedStatus = order.status.toLowerCase();
  if (normalizedStatus == 'cancelled' || normalizedStatus == 'invoiced') {
    return false;
  }
  if (order.isCorporateWalkIn && order.isRejectedByCorporate) {
    return true;
  }
  if (order.isCorporateWalkIn && order.isCorporateUnapproved) {
    return true;
  }
  final badge = order.jobsAggregateBadgeLabel;
  return badge == 'PENDING' || badge == 'COMPLETED';
}

void showCashierCancelOrderDialog(BuildContext context, String orderId) {
  _showCancelOrderDialog(context, orderId);
}

void _showCancelOrderDialog(BuildContext context, String orderId) {
  bool isLoading = false;

  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            titlePadding: const EdgeInsets.fromLTRB(28, 28, 28, 8),
            contentPadding: const EdgeInsets.fromLTRB(28, 12, 28, 20),
            actionsPadding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
            title: const Text(
              'Cancel Order',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to cancel this order?',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                ),
              ],
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryLight,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Go Back', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              setDialogState(() => isLoading = true);
                              final vm = ctx.read<pvm.PosViewModel>();
                              const defaultReason = 'Cancelled by cashier';
                              final success = await vm.cancelOrder(
                                context,
                                orderId,
                                defaultReason,
                              );
                              if (success && dialogContext.mounted) {
                                Navigator.pop(dialogContext);
                              } else {
                                setDialogState(() => isLoading = false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        foregroundColor: AppColors.secondaryLight,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text('Confirm Cancel', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    },
  );
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
      final sortedJobs = List<PosOrderJob>.from(order.jobs)
        ..sort((a, b) {
          final aId = int.tryParse(a.id) ?? -1;
          final bId = int.tryParse(b.id) ?? -1;
          final byNumericId = bId.compareTo(aId); // greatest id first
          if (byNumericId != 0) return byNumericId;
          return b.id.compareTo(a.id);
        });
      final latestId = order.latestJob?.id;

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
                          order.plateNumber.trim().isNotEmpty
                              ? order.plateNumber.toUpperCase()
                              : '—',
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
                          () {
                            final model =
                                '${order.vehicle?.make ?? ""} ${order.vehicle?.model ?? ""}'
                                    .trim();
                            final cust = order.customerName;
                            if (cust != 'Unknown' && cust.isNotEmpty) {
                              return model.isEmpty
                                  ? cust
                                  : '$cust  •  $model';
                            }
                            return model.isEmpty
                                ? 'Walk-in'
                                : model;
                          }(),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                job.department,
                                                style: AppTextStyles.bodyLarge
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppColors
                                                          .secondaryLight,
                                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Job ID: ${job.id}',
                                                style: AppTextStyles.bodySmall
                                                    .copyWith(
                                                      color:
                                                          Colors.grey.shade600,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                            ],
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
                                        if (job.distinctActiveTechnicians.isNotEmpty) ...[
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
                                          ...job.distinctActiveTechnicians.map(
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
  PosOrderJob? highestJob;
  if (order.jobs.isNotEmpty) {
    final sorted = List<PosOrderJob>.from(order.jobs);
    sorted.sort(
      (a, b) =>
          (int.tryParse(a.id) ?? 0).compareTo(int.tryParse(b.id) ?? 0),
    );
    highestJob = sorted.last;
  }

  // Parse latest job items for display (fallback to order items)
  final List<Map<String, dynamic>> parsedItems = [];
  if (highestJob != null && highestJob.items.isNotEmpty) {
    for (final item in highestJob.items) {
      parsedItems.add({
        'name': item.productName,
        'price': item.unitPrice,
        'qty': item.qty,
      });
    }
  } else if (order.items.isNotEmpty) {
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

  final String jobIdForComplete =
      highestJob != null ? highestJob.id : order.id;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setSheetState) {
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
                                  order.plateNumber.trim().isNotEmpty
                                      ? order.plateNumber.toUpperCase()
                                      : '—',
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
                                  () {
                                    final m = order.carModel.trim();
                                    final c = order.customerName;
                                    if (c != 'Unknown' && c.isNotEmpty) {
                                      return m.isEmpty ? c : '$m • $c';
                                    }
                                    return m.isEmpty ? '—' : m;
                                  }(),
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
                            child: Consumer<pvm.PosViewModel>(
                              builder: (context, vm, _) {
                                final busy =
                                    vm.isCashierCompletingJob(jobIdForComplete);
                                return ElevatedButton(
                                  onPressed: busy
                                      ? null
                                      : () async {
                                          if (order.isCorporateWalkIn &&
                                              !order.isCorporateBookingOrder &&
                                              (order.isCorporateUnapproved ||
                                                  order.isWaitingCorporateApproval ||
                                                  order.isRejectedByCorporate)) {
                                            if (ctx.mounted) {
                                              ToastService.showError(
                                                ctx,
                                                'Corporate order must be approved before completing jobs.',
                                              );
                                            }
                                            return;
                                          }
                                          try {
                                            final response =
                                                await vm.completeCashierJob(
                                              jobIdForComplete,
                                              sourceOrder: order,
                                            );
                                            if (response != null &&
                                                response.success) {
                                              if (ctx.mounted) {
                                                Navigator.of(ctx).pop();
                                                ToastService.showSuccess(
                                                  ctx,
                                                  'Order marked as completed successfully',
                                                );
                                              }
                                            } else {
                                              if (ctx.mounted) {
                                                ToastService.showError(
                                                  ctx,
                                                  response?.message ??
                                                      'Failed to complete job',
                                                );
                                              }
                                            }
                                          } catch (e) {
                                            if (ctx.mounted) {
                                              ToastService.showError(
                                                ctx,
                                                e.toString(),
                                              );
                                            }
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
                                  child: busy
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
                                );
                              },
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
  if (order.jobs.isNotEmpty) {
    final label = order.jobsAggregateBadgeLabel;
    final Color textColor;
    final Color bgColor;
    if (label == 'DRAFT') {
      textColor = const Color(0xFF64748B);
      bgColor = const Color(0xFFF1F5F9);
    } else if (label == 'COMPLETED') {
      textColor = const Color(0xFF15803D);
      bgColor = const Color(0xFFDCFCE7);
    } else {
      textColor = Colors.white;
      bgColor = AppColors.secondaryLight;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 8,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  String statusStr = order.displayJobStatus.replaceAll('_', ' ').toUpperCase();

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
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      statusStr.replaceAll(' ACCEPTION', ''),
      style: TextStyle(
        color: textColor,
        fontSize: 8,
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
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: isTablet ? 12 : 11,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1E2124),
          height: 1.15,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      if (subtitle != null) ...[
        SizedBox(height: isTablet ? 3 : 2),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: isTablet ? 10 : 9,
            fontWeight: FontWeight.w400,
            color: Colors.grey.shade400,
            height: 1.1,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
  double labelFontSize = 12,
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
    height: 30,
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(8),
    ),
    child: TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: isLoading
          ? SizedBox(
              height: 13,
              width: 13,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: textColor,
              ),
            )
          : Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: labelFontSize,
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

class _InvoiceThermalActionBar extends StatefulWidget {
  final Invoice invoice;
  final String paymentMethodText;
  final VoidCallback? onDone;

  const _InvoiceThermalActionBar({
    required this.invoice,
    required this.paymentMethodText,
    this.onDone,
  });

  @override
  State<_InvoiceThermalActionBar> createState() =>
      _InvoiceThermalActionBarState();
}

class _InvoiceThermalActionBarState extends State<_InvoiceThermalActionBar> {
  bool _printing = false;

  Future<void> _openThermalSettings() async {
    final cfg = await ThermalPrinterSettings.load();
    final ipCtrl = TextEditingController(text: cfg.host);
    final portCtrl = TextEditingController(text: '${cfg.port}');
    if (!mounted) {
      ipCtrl.dispose();
      portCtrl.dispose();
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Thermal printer (Wi‑Fi)'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: ipCtrl,
                decoration: const InputDecoration(
                  labelText: 'Printer IP',
                  hintText: 'e.g. 192.168.8.55',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: portCtrl,
                decoration: const InputDecoration(
                  labelText: 'Port',
                  helperText: '9100 for most Epson network receipt printers',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final p = int.tryParse(portCtrl.text.trim()) ??
                  ThermalPrinterSettings.defaultPort;
              await ThermalPrinterSettings.save(ipCtrl.text.trim(), p);
              if (dialogCtx.mounted) Navigator.pop(dialogCtx);
              if (!mounted) return;
              ToastService.showSuccess(context, 'Printer address saved.');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    ipCtrl.dispose();
    portCtrl.dispose();
  }

  Future<void> _sendToThermalPrinter() async {
    setState(() => _printing = true);
    try {
      await executeInvoiceThermalPrint(
        invoice: widget.invoice,
        paymentMethodText: widget.paymentMethodText,
      );
      if (!mounted) return;
      ToastService.showSuccess(context, 'Receipt sent to Wi‑Fi printer.');
    } catch (e) {
      if (!mounted) return;
      ToastService.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Tooltip(
              message:
                  'Tap: print to Wi‑Fi thermal printer. Long‑press: IP / port.',
              child: GestureDetector(
                onLongPress: _printing ? null : _openThermalSettings,
                child: ElevatedButton(
                  onPressed: _printing ? null : _sendToThermalPrinter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E3237),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: _printing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Print',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: _printing
                  ? null
                  : () {
                      printThermalInvoicePreviewToStdout(
                        invoice: widget.invoice,
                        paymentMethodText: widget.paymentMethodText,
                      );
                      if (widget.onDone == null) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pop(context);
                        widget.onDone!();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: AppColors.secondaryLight,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Done',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InvoiceDialog extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback? onDone;
  final String? requestedPaymentMethod;
  final List<bool>? maintenanceChecksFallback;

  const InvoiceDialog({
    super.key,
    required this.invoice,
    this.onDone,
    this.requestedPaymentMethod,
    this.maintenanceChecksFallback,
  });

  @override
  Widget build(BuildContext context) {
    final paymentMethodText = invoice.payments.isNotEmpty
        ? invoice.payments.map((p) => p.method).join(', ')
        : (invoice.paymentMethod ?? requestedPaymentMethod ?? 'Unpaid');

    final mq = MediaQuery.sizeOf(context);
    final shellMaxW = mq.width.clamp(280.0, 940.0);
    final shellMaxH = mq.height * 0.88;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: shellMaxW,
          maxHeight: shellMaxH,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2B2B2B), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 16,
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: CashierInvoicePreview(
                      invoice: invoice,
                      paymentMethodText: paymentMethodText,
                      maintenanceChecksFallback: maintenanceChecksFallback,
                    ),
                  ),
                ),
              ),
              _InvoiceThermalActionBar(
                invoice: invoice,
                paymentMethodText: paymentMethodText,
                onDone: onDone,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

bool _techCanToggleWorkshop(PosTechnician tech) {
  final t = tech.technicianType.toLowerCase();
  if (t.isEmpty) return true;
  return t == 'workshop' || t == 'both';
}

bool _techCanToggleOnCall(PosTechnician tech) {
  final t = tech.technicianType.toLowerCase();
  if (t.isEmpty) return true;
  return t == 'on_call' || t == 'both';
}

class _CashierDutyToggle extends StatelessWidget {
  final String label;
  final bool isTablet;
  final bool compact;
  final bool enabled;
  final bool value;
  final bool busy;
  final bool technicianOnline;
  /// False when this duty row does not apply (e.g. on-call row for workshop-only tech).
  final bool roleAllowsDuty;
  final ValueChanged<bool>? onChanged;

  const _CashierDutyToggle({
    required this.label,
    required this.isTablet,
    required this.compact,
    required this.enabled,
    required this.value,
    required this.busy,
    required this.technicianOnline,
    required this.roleAllowsDuty,
    required this.onChanged,
  });

  String get _statusCaption {
    if (!roleAllowsDuty) return 'Not applicable';
    if (!technicianOnline) {
      return 'Unavailable while offline';
    }
    if (value) return 'Active';
    return 'Not available';
  }

  @override
  Widget build(BuildContext context) {
    final toggleWidth = isTablet ? 46.0 : (compact ? 40.0 : 42.0);
    final toggleHeight = compact ? 24.0 : 27.0;
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: compact ? 26 : 30,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isTablet ? 9.5 : 8.5,
                    fontWeight: FontWeight.w600,
                    color: enabled
                        ? const Color(0xFF475569)
                        : Colors.grey.shade400,
                  ),
                ),
                Text(
                  _statusCaption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isTablet ? 8.0 : 7.5,
                    fontWeight: FontWeight.w600,
                    color: !roleAllowsDuty
                        ? Colors.grey.shade400
                        : (!technicianOnline
                            ? Colors.grey.shade500
                            : (value
                                ? Colors.green.shade700
                                : Colors.grey.shade600)),
                  ),
                ),
              ],
            ),
          ),
          if (busy)
            SizedBox(
              width: compact ? 32 : 36,
              child: Center(
                child: SizedBox(
                  width: compact ? 18 : 20,
                  height: compact ? 18 : 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              width: toggleWidth,
              height: toggleHeight,
              child: FittedBox(
                fit: BoxFit.contain,
                alignment: Alignment.centerRight,
                child: Switch(
                  value: value,
                  onChanged: enabled ? onChanged : null,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  thumbColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.disabled)) {
                      return Colors.grey.shade400;
                    }
                    if (states.contains(MaterialState.selected)) {
                      return Colors.white;
                    }
                    return Colors.grey.shade200;
                  }),
                  trackColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.disabled)) {
                      return Colors.grey.shade300;
                    }
                    if (states.contains(MaterialState.selected)) {
                      return Colors.green.shade600;
                    }
                    return Colors.grey.shade500;
                  }),
                  trackOutlineColor:
                      MaterialStateProperty.all(Colors.transparent),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class TechnicianCard extends StatelessWidget {
  final PosTechnician tech;
  final bool compact;
  /// When true (e.g. POS Technicians tab), shows online/offline switch.
  final bool showPresenceToggle;
  final bool presenceBusy;
  final ValueChanged<bool>? onPresenceChanged;
  /// Cashier: workshop / on-call duty toggles (can show together with [showPresenceToggle]).
  final bool showDutyToggles;
  final bool dutyBusy;
  final ValueChanged<bool>? onWorkshopDutyChanged;
  final ValueChanged<bool>? onOnCallDutyChanged;

  const TechnicianCard({
    super.key,
    required this.tech,
    this.compact = false,
    this.showPresenceToggle = false,
    this.presenceBusy = false,
    this.onPresenceChanged,
    this.showDutyToggles = false,
    this.dutyBusy = false,
    this.onWorkshopDutyChanged,
    this.onOnCallDutyChanged,
  });

  Color _cashierPresenceDotColor(PosTechnician tech) {
    if (!tech.isOnline) return Colors.grey.shade500;
    final dm = _effectiveDutyModeForCard(tech);
    if (dm == 'workshop') return Colors.green.shade600;
    if (dm == 'on_call') return Colors.deepOrange.shade600;
    return Colors.grey.shade600;
  }

  String _effectiveDutyModeForCard(PosTechnician tech) {
    var dm = tech.dutyMode?.toLowerCase().trim() ?? '';
    if (dm.isNotEmpty) return dm;
    if (tech.workshopDuty) return 'workshop';
    if (tech.onCallDuty) return 'on_call';
    return 'inactive';
  }

  /// Workshop → active floor; on-call only → **On call**; otherwise **Not available** (still not cashier-offline).
  String _cashierPresenceHeadline(PosTechnician tech) {
    if (!tech.isOnline) {
      return 'Last seen: ${tech.formattedLastSeen}';
    }
    final dm = _effectiveDutyModeForCard(tech);
    if (dm == 'workshop') {
      return 'Online now';
    }
    if (dm == 'on_call') {
      return 'On call';
    }
    return 'Not available';
  }

  Color _cashierPresenceHeadlineColor(PosTechnician tech) {
    if (!tech.isOnline) return Colors.grey.shade600;
    final dm = _effectiveDutyModeForCard(tech);
    if (dm == 'workshop') {
      return Colors.green.shade700;
    }
    if (dm == 'on_call') {
      return Colors.deepOrange.shade800;
    }
    return Colors.grey.shade700;
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final presenceDotColor = _cashierPresenceDotColor(tech);
    final departmentText = tech.departments.isNotEmpty
        ? tech.departments.map((d) => d.name).where((e) => e.isNotEmpty).join(', ')
        : 'No department';
    final presenceHeadline = _cashierPresenceHeadline(tech);
    final presenceHeadlineColor = _cashierPresenceHeadlineColor(tech);
    final slotsFull = tech.totalSlots > 0 && tech.slotsUsed >= tech.totalSlots;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 12 : 10,
        vertical: isTablet ? 9 : 8,
      ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: isTablet ? 48 : 40,
                height: isTablet ? 48 : 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.person,
                  size: isTablet ? 24 : 20,
                  color: AppColors.onPrimaryLight,
                ),
              ),
              Positioned(
                right: -1,
                bottom: -1,
                child: Container(
                  width: isTablet ? 11 : 9,
                  height: isTablet ? 11 : 9,
                  decoration: BoxDecoration(
                    color: presenceDotColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        presenceHeadline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isTablet ? 10.0 : 9.0,
                          fontWeight: FontWeight.w600,
                          color: presenceHeadlineColor,
                        ),
                      ),
                    ),
                    if (showPresenceToggle && onPresenceChanged != null)
                      SizedBox(
                        height: compact ? 30 : 34,
                        width: presenceBusy ? (compact ? 36 : 40) : null,
                        child: presenceBusy
                            ? Center(
                                child: SizedBox(
                                  width: compact ? 20 : 22,
                                  height: compact ? 20 : 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.primaryLight,
                                  ),
                                ),
                              )
                            : FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: Switch(
                                  value: tech.isOnline,
                                  onChanged: onPresenceChanged,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  thumbColor:
                                      MaterialStateProperty.resolveWith(
                                    (states) {
                                      if (states
                                          .contains(MaterialState.disabled)) {
                                        return Colors.grey.shade400;
                                      }
                                      if (states
                                          .contains(MaterialState.selected)) {
                                        return Colors.white;
                                      }
                                      return Colors.grey.shade200;
                                    },
                                  ),
                                  trackColor:
                                      MaterialStateProperty.resolveWith(
                                    (states) {
                                      if (states
                                          .contains(MaterialState.disabled)) {
                                        return Colors.grey.shade300;
                                      }
                                      if (states
                                          .contains(MaterialState.selected)) {
                                        return Colors.green.shade600;
                                      }
                                      return Colors.grey.shade500;
                                    },
                                  ),
                                  trackOutlineColor:
                                      MaterialStateProperty.all(
                                          Colors.transparent),
                                ),
                              ),
                      ),
                  ],
                ),
                SizedBox(height: isTablet ? 4 : 2),
                Text(
                  tech.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isTablet ? 14.5 : 11.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E2124),
                  ),
                ),
                if (!compact) ...[
                  SizedBox(height: isTablet ? 4 : 2),
                  Row(
                    children: [
                      Icon(
                        Icons.apartment_rounded,
                        size: isTablet ? 14 : 10,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          departmentText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isTablet ? 10.0 : 9.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isTablet ? 3 : 2),
                ] else
                  SizedBox(height: isTablet ? 3 : 2),
                Row(
                  children: [
                    Icon(
                      Icons.event_seat_rounded,
                      size: isTablet ? 14 : 10,
                      color: slotsFull ? Colors.red.shade400 : Colors.green.shade600,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        'Slots ${tech.slotsUsed}/${tech.totalSlots}',
                        style: TextStyle(
                          fontSize: isTablet ? 10.0 : 9.0,
                          fontWeight: FontWeight.w700,
                          color: slotsFull ? Colors.red.shade500 : Colors.green.shade700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (showDutyToggles &&
                    (onWorkshopDutyChanged != null ||
                        onOnCallDutyChanged != null)) ...[
                  SizedBox(height: isTablet ? 6 : 5),
                  _CashierDutyToggle(
                    label: 'Workshop Duty',
                    isTablet: isTablet,
                    compact: compact,
                    enabled:
                        _techCanToggleWorkshop(tech) && tech.isOnline,
                    value: tech.workshopDuty,
                    busy: dutyBusy,
                    technicianOnline: tech.isOnline,
                    roleAllowsDuty: _techCanToggleWorkshop(tech),
                    onChanged: onWorkshopDutyChanged,
                  ),
                  SizedBox(height: isTablet ? 3 : 2),
                  _CashierDutyToggle(
                    label: 'On Call Duty',
                    isTablet: isTablet,
                    compact: compact,
                    enabled: _techCanToggleOnCall(tech) && tech.isOnline,
                    value: tech.onCallDuty,
                    busy: dutyBusy,
                    technicianOnline: tech.isOnline,
                    roleAllowsDuty: _techCanToggleOnCall(tech),
                    onChanged: onOnCallDutyChanged,
                  ),
                ],
              ],
            ),
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
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(14),
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
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: textColor ?? Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: AppTextStyles.h2.copyWith(
                    fontSize: 20,
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
