import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filter_service_providers/views/Workshop pos app/Home Screen/pos_view_model.dart';
import 'package:filter_service_providers/views/Workshop pos app/Technician Screen/technician_view_model.dart';

import '../../../utils/app_colors.dart';
import '../../../widgets/pos_widgets.dart';
import '../Home Screen/pos_home_view.dart';
import '../Order Screen/pos_orders_view.dart';
import '../Petty Cash/petty_cash_view_model.dart';
import '../Petty Cash/pos_petty_cash_view.dart';
import '../Product Grid/pos_product_grid_view.dart';
import '../Product Grid/product_grid_view_model.dart';
import '../Promo/pos_promo_view.dart';
import '../Promo/promo_view_model.dart';
import '../Sales Return/pos_sales_return_view.dart';
import '../Store Closing/pos_store_closing_view.dart';
import '../Store Closing/store_closing_view_model.dart';
import '../Technician Screen/pos_technician_view.dart';
import '../Current Shift/pos_current_shift_view.dart';
import '../Current Shift/current_shift_view_model.dart';
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
  ];

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final posVm = context.watch<PosViewModel>();
    final isReconciled = context.watch<StoreClosingViewModel>().isReconciled;
    final currentIndex = posVm.shellSelectedIndex;

    // Safety check: Ensure index is within bounds of children
    final validIndex = currentIndex < _screens.length ? currentIndex : 0;
    final isStoreClosingTab = validIndex == 3;
    final isLockedInStoreClosing = isStoreClosingTab && isReconciled;

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
            textScaler: TextScaler.linear(isTablet ? 1.4 : 1.0),
          ),
          child: IndexedStack(
            index: validIndex,
            children: _screens,
          ),
        ),
        bottomNavigationBar: [4, 5, 6, 7, 8].contains(validIndex) || isLockedInStoreClosing
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
      if (vm.orders.isEmpty) {
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
                    7, 'Sales Return', Icons.assignment_return_rounded, isTablet),
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
