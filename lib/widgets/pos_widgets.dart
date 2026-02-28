import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';
import '../models/pos_order_model.dart';
import '../utils/app_text_styles.dart';
import '../views/Workshop pos app/Department/pos_department_view.dart';
import '../views/Workshop pos app/More Tab/settings_view_model.dart';
import 'package:provider/provider.dart';
// import '../views/Notifications/notifications_view.dart';
import '../utils/app_formatters.dart';
// import '../views/Department/pos_department_view.dart';
import '../views/Workshop pos app/Home Screen/pos_view_model.dart' as pvm;
import '../models/create_invoice_model.dart';
import '../models/pos_technician_model.dart'; // Added import for TechnicianCard
import '../models/pos_product_model.dart'; // Added import for ProductCard
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/toast_service.dart';
import '../views/Workshop pos app/Notifications/notifications_view.dart'; // Added import
import '../views/Workshop pos app/Order Screen/pos_order_review_view.dart';

// ── Reusable POS Screen AppBar (Back + Title + Global Icon) ──
class PosScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final bool showBackButton;
  final bool showHamburger;
  final VoidCallback? onMenuPressed;

  const PosScreenAppBar({
    super.key, 
    required this.title, 
    this.onBack, 
    this.showBackButton = true,
    this.showHamburger = false,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final double iconContainerSize = isTablet ? 46 : 32;
    final double iconSize = isTablet ? 24 : 16;

    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: showBackButton,
          leading: showBackButton 
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: onBack ?? () => Navigator.pop(context),
              )
            : showHamburger
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: InkWell(
                      onTap: onMenuPressed ?? () => Scaffold.of(context).openDrawer(),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.secondaryLight,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondaryLight.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.menu_rounded, color: Colors.white, size: 20),
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
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/global.png',
                        width: 20,
                        color: Colors.black,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.language_rounded, size: 20, color: Colors.black),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
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
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final double iconContainerSize = isTablet ? 52 : 36;
    final double iconSize = isTablet ? 32 : 18;
    final bool hasInfo = infoTitle != null;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.primaryLight,
      elevation: 0,
      centerTitle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
      ),
      toolbarHeight: isTablet ? kToolbarHeight + 40 : 60,
      leadingWidth: showGlobalLeft ? (isTablet ? 74 : 64) : (showDrawer ? (isTablet ? 74 : 64) : 0),
      leading: showGlobalLeft 
        ? Padding(
            padding: EdgeInsets.only(left: 10, top: isTablet ? 20 : 8, bottom: isTablet ? 8 : 8),
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
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/global.png',
                        width: 20,
                        color: Colors.black,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.language_rounded, size: 20, color: Colors.black),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        : showDrawer ? Padding(
          padding: EdgeInsets.only(left: 10, top: isTablet ? 20 : 8, bottom: isTablet ? 8 : 8),
          child: InkWell(
            onTap: onMenuPressed ?? () => Scaffold.of(context).openDrawer(),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.secondaryLight,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondaryLight.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.menu_rounded, color: Colors.white, size: 22),
            ),
          ),
        ) : null,
      title: Padding(
        padding: EdgeInsets.only(top: isTablet ? 25 : 0),
        child: SizedBox(
          height: isTablet ? 45 : 28,
          child: Image.asset(
            'assets/images/icon.png',
            color: Colors.black,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.store, color: Colors.black),
          ),
        ),
      ),
      actions: [
      if (!showGlobalLeft) ...[
        // Language Pill
        Padding(
          padding: EdgeInsets.only(top: isTablet ? 20 : 0, bottom: isTablet ? 8 : 0),
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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/global.png',
                      width: 20,
                      color: Colors.black,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.language_rounded, size: 20, color: Colors.black),
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
        padding: EdgeInsets.only(top: isTablet ? 20 : 0, bottom: isTablet ? 8 : 0),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationsView()),
            );
          },
          borderRadius: BorderRadius.circular(20),
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
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.notifications_rounded, size: 22, color: Colors.black),
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
        ),
      ),
      const SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize {
    if (customHeight != null) return Size.fromHeight(customHeight!);
    return Size.fromHeight(kToolbarHeight + 10);
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
        mainAxisAlignment: isTablet ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          Flexible(child: _buildInfoChip(context, Icons.person, title)),
          const Spacer(),
          Flexible(child: _buildInfoChip(context, null, branch)),
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData? icon, String text, {bool isBlack = false}) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 12 : 6, vertical: isTablet ? 6 : 4), // Reduced horizontal padding on mobile to fit 3 items
      decoration: BoxDecoration(
        color: isBlack ? const Color(0xFF212529) : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(30),
        border: isBlack ? null : Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: isTablet ? 15 : 11, color: Colors.white),
            SizedBox(width: isTablet ? 8 : 4),
          ],
          Flexible( // Use Flexible to prevent overflow if text is long
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
              child: Icon(Icons.person, size: 14, color: AppColors.secondaryLight),
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
    return Container(
      padding: const EdgeInsets.all(16), // Reduced from 24
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // Increased radius from 16
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
                padding: const EdgeInsets.all(8), // Reduced from 12
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Icon(Icons.directions_car, color: AppColors.primaryLight, size: 24), // Increased from 20
              ),
              const SizedBox(width: 16), // Increased from 12
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
                            fontSize: 15, // Reduced from 17
                          ),
                        ),
                        if (isCorporate) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.blue.shade100),
                            ),
                            child: Text(
                              'CORP',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6), // Increased from 4
                    Text(
                      'Plate: $plate  •  $customer',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.grey.shade600,
                        fontSize: 12, // Reduced from 14
                      ),
                    ),
                    const SizedBox(height: 8), // Reduced from 10
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), // Reduced from 12, 8
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.history, size: 14, color: Colors.amber.shade700), // Reduced from 16
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              orderNumber != null
                                  ? '$lastVisit ($lastService)  •  Order: #$orderNumber'
                                  : '$lastVisit ($lastService)',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                fontSize: 11, // Reduced from 12
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
          const SizedBox(height: 20), // Increased from 16
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onContinue ?? () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: AppColors.secondaryLight,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10), // Reduced from 14
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Continue Order', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)), // Reduced from 14
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
                    padding: const EdgeInsets.symmetric(vertical: 10), // Reduced from 14
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Full History', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)), // Reduced from 14
                ),
              ),
            ],
          ),
          if (onSalesReturn != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSalesReturn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red.shade700,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.red.shade200),
                  ),
                ),
                child: const Text('Sales Return / Credit Note', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
              ),
            ),
          ],
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
              _buildNavItem(context, 3, Icons.engineering_outlined, 'Technician'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label) {
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
          color: isSelected ? AppColors.primaryLight.withOpacity(0.15) : Colors.transparent,
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.grey.shade400,
                  fontSize: isTablet ? 15 : 13,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              inputFormatters: inputFormatters ?? [EnglishNumberFormatter()],
              onChanged: onChanged,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 6),
            padding: EdgeInsets.all(isTablet ? 10 : 8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.search, color: AppColors.secondaryLight, size: isTablet ? 20 : 18),
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
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.order.customerName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF1E2124),
                                      letterSpacing: -0.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Order #${widget.order.id.split('-').last.toUpperCase()}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildStatusPill(widget.order),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildPremiumDetailItem(
                              widget.order.carModel,
                              subtitle: widget.order.plateNumber.toUpperCase(),
                            ),
                            const Spacer(),
                            _buildPremiumDetailItem(
                              widget.order.date,
                              subtitle: '${widget.order.odometerReading} km',
                              crossAxisAlignment: CrossAxisAlignment.end,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.layers_rounded, size: 12, color: Colors.white),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${widget.order.jobsCount} JOBS',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                              color: Colors.grey.shade300,
                              size: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (_isExpanded) ...[
                      const SizedBox(height: 12),
                      Divider(height: 1, color: Colors.grey.withOpacity(0.08)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Consumer<pvm.PosViewModel>(
                              builder: (context, posVm, child) {
                                final isInvoiced = widget.order.status.toLowerCase() == 'invoiced';
                                final isCurrentOrderLoading = posVm.isInvoiceLoading && posVm.loadingOrderId == widget.order.id;
                                
                                return _buildActionButton(
                                  onPressed: posVm.isInvoiceLoading 
                                    ? null
                                    : () async {
                                        if (isInvoiced) {
                                          // Fetch and show existing invoice
                                          final response = await posVm.fetchInvoiceByOrder(widget.order.id);
                                          if (response != null && response.success && response.invoice != null && context.mounted) {
                                            await showDialog(
                                              context: context,
                                              builder: (ctx) => InvoiceDialog(invoice: response.invoice!),
                                            );
                                          } else if (response != null && !response.success && context.mounted) {
                                            ToastService.showError(context, response.message);
                                          }
                                        } else {
                                          // Navigate to the Final Review Screen - no API call
                                          if (context.mounted) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => PosOrderReviewView(order: widget.order),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                  isLoading: isCurrentOrderLoading,
                                  icon: isInvoiced ? Icons.receipt_long_rounded : Icons.auto_awesome_rounded,
                                  label: isInvoiced ? 'Invoice' : 'Gen. Invoice',
                                  color: isInvoiced ? AppColors.secondaryLight : const Color(0xFF1E2124),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Consumer<pvm.PosViewModel>(
                              builder: (context, posVm, child) {
                                return _buildActionButton(
                                  onPressed: () {
                                    posVm.setCustomerData(
                                      name: widget.order.customerName,
                                      vat: '', // VAT doesn't seem to be in PosOrder list model directly
                                      mobile: widget.order.customer?.mobile ?? '',
                                      vehicleNumber: widget.order.plateNumber,
                                      make: widget.order.vehicle?.make ?? '',
                                      model: widget.order.vehicle?.model ?? '',
                                      odometer: widget.order.odometerReading,
                                    );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const PosDepartmentView()),
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPill(PosOrder order) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        order.statusText.toUpperCase(),
        style: TextStyle(
          color: AppColors.secondaryLight,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildPremiumDetailItem(String title, {String? subtitle, CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start}) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E2124),
          ),
        ),
        if (subtitle != null) ...[
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
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
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isSecondary ? AppColors.primaryLight.withOpacity(0.2) : color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextButton.icon(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: color,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: isLoading 
          ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1E2124)))
          : Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
      ),
    );
  }
}

class InvoiceDialog extends StatelessWidget {
  final Invoice invoice;

  const InvoiceDialog({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: 'SAR ', decimalDigits: 2);
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
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
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
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      invoice.invoiceNo,
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
                          _buildMetaItem('Date', invDate != null ? dateFormat.format(invDate) : invoice.invoiceDate),
                          _buildMetaItem('Status', invoice.paymentStatus.toUpperCase(), color: Colors.green),
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
                            _buildInfoRow(Icons.person_outline, 'Customer', invoice.customerName),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Divider(height: 1),
                            ),
                            _buildInfoRow(Icons.directions_car_outlined, 'Vehicle', invoice.vehicleInfo),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Divider(height: 1),
                            ),
                            _buildInfoRow(Icons.pin_outlined, 'Plate No', invoice.plateNo.toUpperCase()),
                            if (invoice.cashierName != null) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Divider(height: 1),
                              ),
                              _buildInfoRow(Icons.person_pin_outlined, 'Cashier', invoice.cashierName!),
                            ],
                            if (invoice.branchName != null) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Divider(height: 1),
                              ),
                              _buildInfoRow(Icons.storefront_outlined, 'Branch', invoice.branchName!),
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
                      ...invoice.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                  ),
                                  Text(
                                    '${item.qty.toInt()} x ${currencyFormat.format(item.unitPrice)}',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              currencyFormat.format(item.lineTotal),
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                            ),
                          ],
                        ),
                      )),
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
                            _buildPriceRow('Subtotal', currencyFormat.format(invoice.subtotal)),
                            const SizedBox(height: 8),
                            _buildPriceRow('VAT (15%)', currencyFormat.format(invoice.vatAmount)),
                            if (invoice.discountAmount > 0) ...[
                              const SizedBox(height: 8),
                              _buildPriceRow('Discount', '-${currencyFormat.format(invoice.discountAmount)}', isDiscount: true),
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
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final buffer = StringBuffer();
                          buffer.writeln('INVOICE: ${invoice.invoiceNo}');
                          buffer.writeln('Date: ${invoice.invoiceDate}');
                          buffer.writeln('---------------------------');
                          buffer.writeln('Customer: ${invoice.customerName}');
                          buffer.writeln('Vehicle: ${invoice.vehicleInfo}');
                          buffer.writeln('Plate No: ${invoice.plateNo}');
                          if (invoice.cashierName != null) buffer.writeln('Cashier: ${invoice.cashierName}');
                          if (invoice.branchName != null) buffer.writeln('Branch: ${invoice.branchName}');
                          buffer.writeln('---------------------------');
                          buffer.writeln('ITEMS:');
                          for (var item in invoice.items) {
                            buffer.writeln('- ${item.productName}: ${item.qty.toInt()} x SAR ${item.unitPrice.toStringAsFixed(2)} = SAR ${item.lineTotal.toStringAsFixed(2)}');
                          }
                          buffer.writeln('---------------------------');
                          buffer.writeln('Subtotal: SAR ${invoice.subtotal.toStringAsFixed(2)}');
                          buffer.writeln('VAT (15%): SAR ${invoice.vatAmount.toStringAsFixed(2)}');
                          if (invoice.discountAmount > 0) {
                            buffer.writeln('Discount: -SAR ${invoice.discountAmount.toStringAsFixed(2)}');
                          }
                          buffer.writeln('TOTAL AMOUNT: SAR ${invoice.totalAmount.toStringAsFixed(2)}');
                          buffer.writeln('Status: ${invoice.paymentStatus.toUpperCase()}');
                          buffer.writeln('---------------------------');
                          buffer.writeln('Thank you for choosing our service!');

                          Share.share(buffer.toString(), subject: 'Invoice ${invoice.invoiceNo}');
                        },
                        icon: const Icon(Icons.share_outlined, size: 18),
                        label: const Text('Share'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          foregroundColor: AppColors.secondaryLight,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
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
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Color(0xFF1E2124), fontSize: 13, fontWeight: FontWeight.w700),
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
        Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w600)),
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

  Widget _buildPriceRow(String label, String value, {bool isTotal = false, bool isDiscount = false}) {
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
            color: isDiscount ? Colors.red : (isTotal ? AppColors.secondaryLight : const Color(0xFF1E2124)),
          ),
        ),
      ],
    );
  }
}

class TechnicianCard extends StatelessWidget {
  final PosTechnician tech;
  const TechnicianCard({super.key, required this.tech});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: isTablet ? 20 : 24,
            backgroundColor: AppColors.primaryLight.withOpacity(0.1),
            child: Icon(Icons.person, size: isTablet ? 20 : 24, color: AppColors.secondaryLight),
          ),
          const SizedBox(width: 12),
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
                    fontSize: isTablet ? 13 : 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E2124),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tech.statusInfo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isTablet ? 10 : 12,
                    color: tech.statusInfo.contains('Castrol') ? Colors.black54 : Colors.grey,
                  ),
                ),
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

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 125,
      height: 115, // Slightly increased height to prevent overflow
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
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
          // Subtle Background Decorative Icon
          Positioned(
            right: -5,
            bottom: -5,
            child: Icon(
              icon,
              size: 50,
              color: accentColor.withOpacity(0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: accentColor,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  value,
                  style: AppTextStyles.h2.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppColors.secondaryLight,
                    letterSpacing: -0.5,
                  ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryLight : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryLight : Colors.grey.shade200,
                    ),
                  ),
                  child: Text(
                    cat,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isSelected ? AppColors.secondaryLight : Colors.grey.shade600,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 12,
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
    if (stock >= 30) return Colors.green;
    if (stock >= 10) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final stockColor = _getStockColor(product.stock);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  product.name,
                  style: AppTextStyles.h2.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: stockColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Stock: ${product.stock}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: stockColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        product.subtitle,
                        style: AppTextStyles.bodyMedium.copyWith(fontSize: 10, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'SAR ',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryLight,
                      ),
                    ),
                    Text(
                      (product.price * 1.15).toStringAsFixed(2), // Price incl. VAT
                      style: AppTextStyles.h2.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      ' (Inc. VAT)',
                      style: TextStyle(fontSize: 8, color: Colors.grey.shade400),
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
}

class DottedContainer extends StatelessWidget {
  final Widget child;
  const DottedContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: CustomPaint(
        painter: DottedPainter(),
        child: child,
      ),
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
      ..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(16)));

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
