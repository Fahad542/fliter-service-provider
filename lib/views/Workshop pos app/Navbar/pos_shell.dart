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
import '../Product Screen/pos_products_view.dart';
import '../Promo/pos_promo_view.dart';
import '../Sales Return/pos_sales_return_view.dart';
import '../Store Closing/pos_store_closing_view.dart';
import '../Store Closing/store_closing_view_model.dart';
import '../Technician Screen/pos_technician_view.dart';
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
    PosProductsView(),
    PosOrdersView(),
    PosTechnicianView(),
    PosPettyCashView(),
    PosPromoView(),
    PosStoreClosingView(),
    PosSalesReturnView(),
  ];

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final posVm = context.watch<PosViewModel>();
    final isReconciled = context.watch<StoreClosingViewModel>().isReconciled;
    final currentIndex = posVm.shellSelectedIndex;

    // Safety check: Ensure index is within bounds of children
    final validIndex = currentIndex < _screens.length ? currentIndex : 0;
    final isLockedInStoreClosing = validIndex == 6 && isReconciled;

    return PopScope(
      canPop: !isLockedInStoreClosing,
      onPopInvoked: (didPop) {
        if (!didPop && isLockedInStoreClosing) {
          // If we are locked on Store Closing, do not pop
        }
      },
      child: Scaffold(
        drawer: isLockedInStoreClosing ? null : _buildDrawer(),
        body: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(isTablet ? 1.4 : 1.0),
          ),
          child: IndexedStack(
            index: validIndex,
            children: _screens,
          ),
        ),
        bottomNavigationBar: [4, 5, 6, 7].contains(validIndex)
            ? const SizedBox.shrink()
            : PosBottomBar(
                currentIndex: currentIndex,
                onTap: (index) {
                  posVm.setShellSelectedIndex(index);
                  _triggerVisitFetch(context, index);
                },
              ),
      ),
    );
  }

  void _triggerVisitFetch(BuildContext context, int index) {
    if (index == 1) {
      final vm = context.read<PosViewModel>();
      if (vm.products.isEmpty) {
        vm.fetchProducts();
      }
    } else if (index == 2) {
      final vm = context.read<PosViewModel>();
      if (vm.orders.isEmpty) {
        vm.fetchOrders();
      }
    } else if (index == 3) {
      final vm = context.read<TechnicianViewModel>();
      if (vm.technicians.isEmpty) {
        vm.fetchTechnicians();
      }
    } else if (index == 4) {
      // Always fetch for Petty Cash as per user request
      context.read<PettyCashViewModel>().initPettyCash();
    }
  }

  // --- DRAWER IMPLEMENTATION ---

  Widget _buildDrawer() {
    return Drawer(
      width: 280,
      backgroundColor: AppColors.secondaryLight,
      child: Column(
        children: [
          _buildDrawerHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                _buildDrawerItem(0, 'Dashboard', Icons.dashboard_rounded),
                const SizedBox(height: 4),
                _buildDrawerItem(7, 'Sales Return', Icons.assignment_return_rounded),
                const SizedBox(height: 4),
                _buildDrawerItem(4, 'Petty Cash', Icons.payments_rounded),
                const SizedBox(height: 4),
                _buildDrawerItem(5, 'Promo Codes', Icons.local_offer_rounded),
                const SizedBox(height: 4),
                _buildDrawerItem(6, 'Store Closing', Icons.store_rounded),
                const SizedBox(height: 4),
              ],
            ),
          ),
          _buildDrawerFooter(),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    final posVm = context.watch<PosViewModel>();
    final userName = posVm.cashierName;
    final workshopName = posVm.workshopName;
    final branchName = posVm.branchName;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                'https://ui-avatars.com/api/?name=${Uri.encodeComponent(userName)}&background=FCC247&color=23262D',
                width: 48,
                height: 48,
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  workshopName,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                if (branchName.isNotEmpty)
                  Text(
                    'Branch: $branchName',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
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

  Widget _buildDrawerItem(int index, String title, IconData icon, {bool isLogout = false}) {
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
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.black : Colors.white70,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.white24, size: 16),
          const SizedBox(width: 8),
          Text(
            'Version 1.0.0',
            style: TextStyle(
              color: Colors.white.withOpacity(0.2),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
