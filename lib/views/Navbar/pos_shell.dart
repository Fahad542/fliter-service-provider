import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filter_service_providers/views/Workshop pos app/Home Screen/pos_view_model.dart';
import 'package:filter_service_providers/views/Workshop pos app/Technician Screen/technician_view_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../Workshop pos app/Home Screen/pos_home_view.dart';
import '../Workshop pos app/Product Screen/pos_products_view.dart';
import '../Workshop pos app/Order Screen/pos_orders_view.dart';
import '../Workshop pos app/Technician Screen/pos_technician_view.dart';
import '../Workshop pos app/More Tab/pos_more_view.dart';
import '../Workshop pos app/Petty Cash/pos_petty_cash_view.dart';
import '../Workshop pos app/Promo/pos_promo_view.dart';
import '../Workshop pos app/Promo/promo_code_dialog.dart';
import '../Workshop pos app/Petty Cash/petty_cash_view_model.dart';
import '../Workshop pos app/Store Closing/pos_store_closing_view.dart';
import '../../widgets/pos_widgets.dart';

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
  ];

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final posVm = context.watch<PosViewModel>();
    final currentIndex = posVm.shellSelectedIndex;

    // Safety check: Ensure index is within bounds of children
    final validIndex = currentIndex < _screens.length ? currentIndex : 0;

    return Scaffold(
      body: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(isTablet ? 1.4 : 1.0),
        ),
        child: IndexedStack(
          index: validIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: PosBottomBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 4) {
            _showMoreFloatingMenu(context);
          } else {
            posVm.setShellSelectedIndex(index);
            _triggerVisitFetch(context, index);
          }
        },
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

  void _showMoreFloatingMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'More Menu',
      barrierColor: Colors.black.withOpacity(0.1),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 20, bottom: 85),
            child: PosMoreView(
                onSelect: (index) {
                  if (index == 5) {
                    // Index 5 is Promo Code - Show Dialog instead of switching tab
                    showDialog(
                      context: context,
                      builder: (context) => const PromoCodeDialog(),
                    );
                  } else {
                    context.read<PosViewModel>().setShellSelectedIndex(index);
                    _triggerVisitFetch(context, index); // Trigger fetch
                  }
                },
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: anim1,
            alignment: Alignment.bottomRight,
            child: child,
          ),
        );
      },
    );
  }
}
