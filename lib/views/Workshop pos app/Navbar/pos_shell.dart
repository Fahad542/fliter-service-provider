import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filter_service_providers/views/Workshop pos app/Home Screen/pos_view_model.dart';
import 'package:filter_service_providers/views/Workshop pos app/Technician Screen/technician_view_model.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../widgets/pos_widgets.dart';
import '../../../widgets/pos_shell_rail_layout.dart';
import '../../../utils/pos_tablet_layout.dart';
import '../Home Screen/pos_home_view.dart';
import '../Order Screen/pos_orders_view.dart';
import '../Petty Cash/petty_cash_view_model.dart';
import '../Petty Cash/pos_petty_cash_view.dart';
import '../Product Grid/pos_product_grid_view.dart';
import '../Product Grid/product_grid_view_model.dart';
import '../Promo/pos_promo_view.dart';
import '../Promo/promo_view_model.dart';
import '../Sales Return/pos_sales_return_view.dart';
import '../Sales Return/pos_sales_return_list_view.dart';
import '../Sales Return/sales_return_list_view_model.dart';
import '../Store Closing/pos_store_closing_view.dart';
import '../Store Closing/store_closing_view_model.dart';
import '../Technician Screen/pos_technician_view.dart';
import '../Current Shift/pos_current_shift_view.dart';
import '../Current Shift/current_shift_view_model.dart';
import '../Takeaway/pos_takeaway_view.dart';
import '../Takeaway/takeaway_view_model.dart';
// import '../../utils/app_colors.dart';
// import '../../utils/app_text_styles.dart';
// import '../Workshop pos app/Home Screen/pos_home_view.dart';
// import '../Workshop pos app/Product Screen/pos_products_view.dart';
// import '../Workshop pos app/Order Screen/pos_orders_view.dart';
// import '../Workshop pos app/Technician Screen/pos_technician_view.dart';
//
// import '../Workshop pos app/Petty Cash/pos_petty_cash_view.dart';
// import '../Workshop pos app/Promo/pos_promo_view.dart';
// import '../Workshop pos app/Petty Cash/petty_cash_view_model.dart';
// import '../Workshop pos app/Store Closing/pos_store_closing_view.dart';
// import '../Workshop pos app/Sales Return/pos_sales_return_view.dart';
// import '../Workshop pos app/Store Closing/store_closing_view_model.dart';
// import '../../widgets/pos_widgets.dart';

class PosShell extends StatefulWidget {
  final int initialIndex;
  const PosShell({super.key, this.initialIndex = 0});

  @override
  State<PosShell> createState() => _PosShellState();
}

/// Tablet landscape overlay rail (full-width AppBar above; rail below it).
const double _kShellRailWidth = 110;
const double _kShellRailMarginLeft = 12;
const double _kShellRailMarginBottom = 12;
const double _kShellRailGapAfter = 12;
/// Vertical gap between full-width AppBar bottom and top of the nav rail.
const double _kShellRailGapBelowAppBar = 10;

class _PosShellState extends State<PosShell> {
  @override
  void initState() {
    super.initState();
    // Initialize view model index if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialIndex != 0) {
        context.read<PosViewModel>().setShellSelectedIndex(widget.initialIndex);
      }
      _triggerVisitFetch(context, widget.initialIndex);
    });
  }

  List<Widget> get _screens => const [
    PosHomeView(),
    PosProductGridView(
      isReadOnly: false,
      showBackButton: false,
      isMainTab: true,
    ),
    PosOrdersView(),
    PosStoreClosingView(),
    PosPettyCashView(),
    PosPromoView(),
    PosTechnicianView(),
    PosSalesReturnView(),
    PosCurrentShiftView(),
    PosSalesReturnListView(),
    PosTakeawayView(),
  ];

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final useLeftNavRail = isTablet && isLandscape;
    final posVm = context.watch<PosViewModel>();
    final takeawayVm = context.watch<TakeawayViewModel>();
    final isReconciled = context.watch<StoreClosingViewModel>().isReconciled;
    final currentIndex = posVm.shellSelectedIndex;

    // Safety check: Ensure index is within bounds of children
    final validIndex = currentIndex < _screens.length ? currentIndex : 0;
    final isStoreClosingTab = validIndex == 3;
    final isLockedInStoreClosing = isStoreClosingTab && isReconciled;

    final hideBottomBar = [4, 5, 6, 7, 8, 9, 10].contains(validIndex) ||
        isLockedInStoreClosing;

    Widget stackBody = IndexedStack(
      index: validIndex,
      children: _screens,
    );

    // Tablet landscape: AppBar spans full width; rail is stacked below AppBar with rounded corners.
    if (useLeftNavRail && !isLockedInStoreClosing) {
      final bodyLeftInset =
          _kShellRailMarginLeft + _kShellRailWidth + _kShellRailGapAfter;
      final railTop = _shellRailTop(context, validIndex, isReconciled);
      final railBottom =
          _shellRailBottom(context, validIndex, posVm, takeawayVm);
      stackBody = Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          PosShellRailLayout(
            bodyLeftPadding: bodyLeftInset,
            child: IndexedStack(
              index: validIndex,
              children: _screens,
            ),
          ),
          Positioned(
            left: _kShellRailMarginLeft,
            top: railTop,
            bottom: railBottom,
            width: _kShellRailWidth,
            child: Material(
              elevation: 10,
              shadowColor: Colors.black26,
              borderRadius: BorderRadius.circular(22),
              clipBehavior: Clip.antiAlias,
              color: Colors.transparent,
              child: _TabletLandscapeNavRail(
                selectedIndex: validIndex,
                onSelect: (index) {
                  _triggerVisitFetch(context, index);
                  posVm.setShellSelectedIndex(index);
                },
              ),
            ),
          ),
        ],
      );
    }

    return PopScope(
      canPop: !isLockedInStoreClosing,
      onPopInvoked: (didPop) {
        if (!didPop && isLockedInStoreClosing) {
          // If we are locked on Store Closing, do not pop
        }
      },
      child: Scaffold(
        drawer: isStoreClosingTab ? null : _buildDrawer(isTablet),
        body: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: PosTabletLayout.textScaler(context),
          ),
          child: stackBody,
        ),
        bottomNavigationBar: hideBottomBar || useLeftNavRail
            ? const SizedBox.shrink()
            : PosBottomBar(
                currentIndex: currentIndex,
                onTap: (index) {
                  _triggerVisitFetch(context, index);
                  posVm.setShellSelectedIndex(index);
                },
              ),
      ),
    );
  }

  double _shellRailTop(
      BuildContext context, int index, bool storeClosingReconciled) {
    final topSafe = MediaQuery.paddingOf(context).top;
    if (MediaQuery.sizeOf(context).width <= 600) return topSafe;
    // Toolbar heights must match PosAppBar / PosScreenAppBar / Store reconciled AppBar.
    if (index == 0) {
      return topSafe + PosTabletLayout.appBarHeight + _kShellRailGapBelowAppBar;
    }
    if (index == 3 && storeClosingReconciled) {
      return topSafe + PosTabletLayout.appBarHeight + _kShellRailGapBelowAppBar;
    }
    return topSafe + PosTabletLayout.appBarHeight + _kShellRailGapBelowAppBar;
  }

  double _shellRailBottom(
    BuildContext context,
    int index,
    PosViewModel posVm,
    TakeawayViewModel takeawayVm,
  ) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;
    if (index == 1 && posVm.getCartCount(true) > 0) {
      return bottomSafe + 88;
    }
    if (index == 10 && takeawayVm.cartLineCount > 0) {
      return bottomSafe + 88;
    }
    return bottomSafe + _kShellRailMarginBottom;
  }

  void _triggerVisitFetch(BuildContext context, int index) {
    if (index == 1) {
      final posVm = context.read<PosViewModel>();
      final gridVm = context.read<ProductGridViewModel>();
      
      // Reset all filters
      posVm.initMainProductsTab();
      gridVm.setDepartment('All');
      gridVm.setCategory('All');
      gridVm.setSubCategory('All');
      gridVm.clearSearch();
    } else if (index == 2) {
      final vm = context.read<PosViewModel>();
      if (!vm.ordersApiFetchCompleted) {
        vm.fetchOrders();
      }
    } else if (index == 6) {
      final vm = context.read<TechnicianViewModel>();
      if (vm.technicians.isEmpty) {
        vm.fetchTechnicians();
      }
    } else if (index == 4) {
      // Always fetch for Petty Cash as per user request
      context.read<PettyCashViewModel>().initPettyCash();
    } else if (index == 5) {
      final vm = context.read<PromoViewModel>();
      if (vm.availablePromotions.isEmpty) {
        vm.fetchAvailablePromos();
      }
    } else if (index == 8) {
      context.read<CurrentShiftViewModel>().fetchCurrentSession();
    } else if (index == 9) {
      context.read<SalesReturnListViewModel>().fetchReturns(refresh: true);
    } else if (index == 10) {
      context.read<TakeawayViewModel>().loadCatalog();
    }
  }

  // --- DRAWER IMPLEMENTATION ---

  Widget _buildDrawer(bool isTablet) {
    return Drawer(
      width: isTablet ? 360 : 280,
      backgroundColor: AppColors.secondaryLight,
      child: Column(
        children: [
          _buildDrawerHeader(isTablet),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 20 : 16, vertical: 20),
              children: [
                _buildDrawerItem(
                    0, 'Dashboard', Icons.dashboard_rounded, isTablet),
                const SizedBox(height: 8),
                _buildDrawerItem(
                    2, 'Orders', Icons.receipt_long_outlined, isTablet),
                const SizedBox(height: 8),
                _buildDrawerItem(
                    10,
                    'Takeaway',
                    Icons.takeout_dining_rounded,
                    isTablet),
                const SizedBox(height: 8),
                _buildDrawerItem(
                    7, 'Sales Return', Icons.assignment_return_rounded, isTablet),
                const SizedBox(height: 8),
                _buildDrawerItem(
                    9, 'Returns List', Icons.list_alt_rounded, isTablet),
                const SizedBox(height: 8),
                _buildDrawerItem(
                    4, 'Petty Cash', Icons.payments_rounded, isTablet),
                const SizedBox(height: 8),
                _buildDrawerItem(
                    5, 'Promo Codes', Icons.local_offer_rounded, isTablet),
                const SizedBox(height: 8),
                _buildDrawerItem(
                    8, 'Current Shift', Icons.access_time_filled_rounded, isTablet),
                const SizedBox(height: 8),
                _buildDrawerItem(
                    6, 'Technicians', Icons.engineering_rounded, isTablet),
                const SizedBox(height: 8),
              ],
            ),
          ),
          _buildDrawerFooter(isTablet),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(bool isTablet) {
    final posVm = context.watch<PosViewModel>();
    final userName = posVm.cashierName;
    final workshopName = posVm.workshopName;
    final branchName = posVm.branchName;

    return Container(
      padding: EdgeInsets.fromLTRB(24, isTablet ? 80 : 60, 24, 30),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isTablet ? 14 : 10),
              child: Image.network(
                'https://ui-avatars.com/api/?name=${Uri.encodeComponent(userName)}&background=FCC247&color=23262D',
                width: isTablet ? 64 : 48,
                height: isTablet ? 64 : 48,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: isTablet ? 22 : 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  workshopName,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: isTablet ? 15 : 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                if (branchName.isNotEmpty)
                  Text(
                    'Branch: $branchName',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: isTablet ? 14 : 12,
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

  Widget _buildDrawerItem(int index, String title, IconData icon, bool isTablet,
      {bool isLogout = false}) {
    final posVm = context.watch<PosViewModel>();
    final isSelected = posVm.shellSelectedIndex == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (index < _screens.length) {
            posVm.setShellSelectedIndex(index);
            _triggerVisitFetch(context, index);
            Navigator.pop(context); // Close drawer
          }
        },
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
              horizontal: 16, vertical: isTablet ? 16 : 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : Colors.transparent,
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
            boxShadow: isSelected && isTablet
                ? [
                    BoxShadow(
                      color: AppColors.primaryLight.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: isTablet ? 26 : 20,
                color: isSelected ? Colors.black : Colors.white70,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  fontSize: isTablet ? 17 : 14,
                  letterSpacing: isTablet ? 0.3 : 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerFooter(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      child: Row(
        children: [
          Icon(Icons.info_outline,
              color: Colors.white24, size: isTablet ? 20 : 16),
          const SizedBox(width: 8),
          Text(
            'Version 1.0.0',
            style: TextStyle(
              color: Colors.white.withOpacity(0.2),
              fontSize: isTablet ? 14 : 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// All POS shell routes (indices match [_screens] / drawer).
/// Display order for the landscape rail; [index] still matches [_screens] / shell API.
const List<({int index, IconData icon, String label})> _kLandscapeNavEntries = [
  (index: 0, icon: Icons.home_rounded, label: 'Home'),
  (index: 1, icon: Icons.inventory_2_outlined, label: 'Products'),
  (index: 2, icon: Icons.receipt_long_outlined, label: 'Orders'),
  (index: 10, icon: Icons.takeout_dining_rounded, label: 'Takeaway'),
  (index: 7, icon: Icons.assignment_return_rounded, label: 'Sales Return'),
  (index: 9, icon: Icons.list_alt_rounded, label: 'Returns List'),
  (index: 4, icon: Icons.payments_rounded, label: 'Petty Cash'),
  (index: 5, icon: Icons.local_offer_rounded, label: 'Promo Codes'),
  (index: 6, icon: Icons.engineering_rounded, label: 'Technicians'),
  (index: 8, icon: Icons.access_time_filled_rounded, label: 'Current Shift'),
  (index: 3, icon: Icons.store_rounded, label: 'Store Closing'),
];

/// Left rail for tablet landscape — every tab (scrollable), polished layout.
class _TabletLandscapeNavRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _TabletLandscapeNavRail({
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.secondaryLight,
      elevation: 0,
      child: SizedBox.expand(
        child: ListView(
              padding: const EdgeInsets.fromLTRB(6, 8, 6, 12),
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              children: [
                for (final e in _kLandscapeNavEntries)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 3),
                    child: _item(e.index, e.icon, e.label),
                  ),
              ],
            ),
      ),
    );
  }

  Widget _item(int index, IconData icon, String label) {
    final isSelected = selectedIndex == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSelect(index),
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? Colors.black87 : Colors.white70,
              ),
              const SizedBox(height: 5),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 9.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.black87 : Colors.white70,
                  height: 1.18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
