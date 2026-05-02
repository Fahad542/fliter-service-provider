import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:filter_service_providers/views/Workshop pos app/Home Screen/pos_view_model.dart';
import 'package:filter_service_providers/views/Workshop pos app/Technician Screen/technician_view_model.dart';
import 'package:filter_service_providers/views/Workshop%20pos%20app/Broadcast/cashier_broadcast_view_model.dart';
import 'package:filter_service_providers/views/Workshop%20pos%20app/Broadcast/pos_cashier_broadcast_view.dart';

import '../../../utils/app_colors.dart';
import '../../../widgets/pos_widgets.dart';
import '../../../widgets/pos_shell_rail_layout.dart';
import '../../../utils/pos_tablet_layout.dart';
import '../../../utils/pos_shell_scaffold.dart' show PosShellScaffoldRegistry;
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
import '../Inventory Sales/inventory_sales_view_model.dart';
import '../Inventory Sales/pos_inventory_sales_view.dart';
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

/// Selects the Orders tab and returns to [PosShell].
///
/// Always resets the **root** navigator to a single [PosShell] at the Orders tab.
/// The previous `while (canPop) pop()` logic could leave the wrong screen (e.g. only
/// [PosDepartmentView] after it replaced the shell) or an empty stack, which made the
/// app fall back to [MenuView] while the session token was still valid.
void navigateToPosShellOrdersTab(BuildContext context) {
  final posVm = context.read<PosViewModel>();
  posVm.setShellSelectedIndex(2);
  final nav = Navigator.of(context, rootNavigator: true);
  nav.pushAndRemoveUntil<void>(
    MaterialPageRoute<void>(
      builder: (_) => const PosShell(initialIndex: 2),
    ),
    (route) => false,
  );
}

/// Cashier broadcast list tab (active technician broadcasts).
void navigateToPosShellBroadcastTab(BuildContext context) {
  final posVm = context.read<PosViewModel>();
  posVm.setShellSelectedIndex(11);
  final nav = Navigator.of(context, rootNavigator: true);
  nav.pushAndRemoveUntil<void>(
    MaterialPageRoute<void>(
      builder: (_) => const PosShell(initialIndex: 11),
    ),
    (route) => false,
  );
}

class PosShell extends StatefulWidget {
  final int initialIndex;
  const PosShell({super.key, this.initialIndex = 0});

  @override
  State<PosShell> createState() => _PosShellState();
}

class _PosShellState extends State<PosShell> {
  bool _didBootstrapShell = false;
  final GlobalKey<ScaffoldState> _shellScaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    PosShellScaffoldRegistry.attach(_shellScaffoldKey);
    _lockPosLandscape();
  }

  @override
  void dispose() {
    _unlockOrientationForOtherPortals();
    PosShellScaffoldRegistry.detach(_shellScaffoldKey);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didBootstrapShell) return;
    _didBootstrapShell = true;
    final idx = widget.initialIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (idx != 0) {
        context.read<PosViewModel>().setShellSelectedIndex(idx);
      }
      _triggerVisitFetch(context, idx);
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
    PosCashierBroadcastView(),
    PosInventorySalesView(),
  ];

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTabletDevice(context);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (!isTablet) {
      return const _PosDeviceRestrictionView(
        title: 'Tablet required',
        message:
            'Workshop POS sirf tablet device par open hota hai.',
      );
    }

    if (!isLandscape) {
      return const _PosDeviceRestrictionView(
        title: 'Landscape required',
        message:
            'Workshop POS ko landscape mode me rotate karein.',
      );
    }

    final posVm = context.watch<PosViewModel>();
    final isReconciled = context.watch<StoreClosingViewModel>().isReconciled;
    final currentIndex = posVm.shellSelectedIndex;

    // Safety check: Ensure index is within bounds of children
    final validIndex = currentIndex < _screens.length ? currentIndex : 0;
    final isStoreClosingTab = validIndex == 3;
    final isLockedInStoreClosing = isStoreClosingTab && isReconciled;

    final hideBottomBar =
        [4, 5, 6, 7, 8, 9, 10, 11, 12].contains(validIndex) ||
            isLockedInStoreClosing;

    final stackBody = PosShellRailLayout(
      bodyLeftPadding: 0,
      child: IndexedStack(
        index: validIndex,
        children: _screens,
      ),
    );

    return PopScope(
      canPop: !isLockedInStoreClosing,
      onPopInvoked: (didPop) {
        if (!didPop && isLockedInStoreClosing) {
          // If we are locked on Store Closing, do not pop
        }
      },
      child: Scaffold(
        key: _shellScaffoldKey,
        drawer: isLockedInStoreClosing ? null : _buildDrawer(isTablet),
        body: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: PosTabletLayout.textScaler(context),
          ),
          child: stackBody,
        ),
        bottomNavigationBar: hideBottomBar || isTablet
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

  bool _isTabletDevice(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= 600;

  void _lockPosLandscape() {
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _unlockOrientationForOtherPortals() {
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
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
      if (vm.corporateAccounts.isEmpty && !vm.isCorpAccountsLoading) {
        vm.fetchCorporateAccounts(silent: true);
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
    } else if (index == 11) {
      context.read<CashierBroadcastViewModel>().fetchActive();
    } else if (index == 12) {
      context.read<InventorySalesViewModel>().fetch();
    }
  }

  // --- DRAWER IMPLEMENTATION ---

  Widget _buildDrawer(bool isTablet) {
    return Drawer(
      width: isTablet ? 300 : 260,
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
                    0, 'Home', Icons.home_rounded, isTablet),
                const SizedBox(height: 8),
                _buildDrawerItem(
                    1, 'Products', Icons.inventory_2_outlined, isTablet),
                const SizedBox(height: 8),
                _buildDrawerItem(
                    2, 'Orders', Icons.receipt_long_outlined, isTablet),
                const SizedBox(height: 8),
                _buildDrawerItem(
                    11,
                    'Broadcast Technician',
                    Icons.podcasts_rounded,
                    isTablet),
                const SizedBox(height: 8),
                _buildDrawerItem(
                  12,
                  'Inventory Sales',
                  Icons.query_stats_rounded,
                  isTablet,
                ),
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
                    6, 'Technicians', Icons.engineering_rounded, isTablet),
                const SizedBox(height: 8),
                _buildDrawerItem(
                    8, 'Current Shift', Icons.access_time_filled_rounded, isTablet),
                const SizedBox(height: 8),
                _buildDrawerItem(
                    3, 'Store Closing', Icons.store_rounded, isTablet),
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
      padding: EdgeInsets.fromLTRB(24, isTablet ? 70 : 52, 24, 24),
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

class _PosDeviceRestrictionView extends StatelessWidget {
  final String title;
  final String message;

  const _PosDeviceRestrictionView({
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.screen_lock_rotation_rounded,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
