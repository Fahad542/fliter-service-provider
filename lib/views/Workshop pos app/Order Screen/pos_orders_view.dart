import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'dart:math' as math;
import 'dart:ui';
import '../../../utils/app_colors.dart';
import '../../../utils/invoice_maintenance_checklist.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/toast_service.dart';
import '../Home Screen/pos_view_model.dart';
import '../Add Customer Screen/pos_add_customer_view.dart';
import '../Department/department_view_model.dart';
import '../Department/pos_department_view.dart';
import '../Product Grid/pos_product_grid_view.dart';
import '../Technician Assignment/pos_technician_assignment_view.dart';
import '../../../models/pos_order_model.dart';
import '../../../data/repositories/pos_repository.dart';
import '../../../services/session_service.dart';
import '../../../widgets/pos_widgets.dart';
import '../../../widgets/pos_shell_rail_layout.dart';
import '../../../models/pos_payment_method.dart';
import 'pos_invoice_payment_dialog.dart';
import 'pos_order_review_view.dart'
    show WalkInInvoiceDetailsDialog, WalkInInvoiceFormResult;

bool _orderIsListableForOrdersList(PosOrder o) =>
    o.status.toLowerCase() != 'cancelled' &&
    (o.jobsAggregateBadgeLabel != 'DRAFT' ||
        (o.isCorporateWalkIn &&
            (o.isCorporateUnapproved ||
                o.isWaitingCorporateApproval ||
                o.isRejectedByCorporate)));

/// Matches [WalkInInvoiceDetailsDialog] / Final Review: walk-in PATCH allowed (not cashier corporate-quote lockout).
bool _ordersWalkInBillingEditable(PosOrder order) =>
    !(order.isCorporateWalkIn && !order.isCorporateBookingOrder);

/// Payroll retail walk-in — hide "Select payment method" (same toggle as Invoice details branch employee customer).
bool _ordersIsRetailWalkInBranchEmployee(PosViewModel vm, PosOrder order) {
  if (!vm.isStandardWalkInOrderForBilling(order)) return false;
  if (!_ordersWalkInBillingEditable(order)) return false;
  final snap = vm.walkInBillingSnapshotForOrder(order.id);
  if (snap?.billingCustomerIsEmployee == true) return true;
  return order.customer?.isCustomerEmployee == true;
}

String? _ordersBranchEmployeeIdForPayroll(PosViewModel vm, PosOrder order) {
  final snap = vm.walkInBillingSnapshotForOrder(order.id);
  final a = snap?.billingEmployeeId?.trim();
  if (a != null && a.isNotEmpty) return a;
  final b = order.customer?.branchEmployeeId?.trim();
  return b != null && b.isNotEmpty ? b : null;
}

bool _ordersRetailEmployeeInvoiceReady(PosViewModel vm, PosOrder order) {
  if (!_ordersIsRetailWalkInBranchEmployee(vm, order)) return false;
  final id = _ordersBranchEmployeeIdForPayroll(vm, order);
  return id != null && id.isNotEmpty;
}

/// Same 6 bilingual rows as the printable invoice / Final Review checklist.
/// **Save** calls `PATCH /cashier/order/:id/maintenance-checklist` then refreshes orders.
Future<void> _showOrdersMaintenanceChecklistDialog(
  BuildContext context,
  PosOrder order,
) async {
  final mc = order.maintenanceChecks;
  final checks = (mc != null &&
          mc.length == InvoiceMaintenanceChecklist.rows.length)
      ? List<bool>.from(mc)
      : List<bool>.filled(InvoiceMaintenanceChecklist.rows.length, false);

  final savingRef = <bool>[false];

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (ctx, setModalState) {
        Future<void> save() async {
          if (savingRef[0]) return;
          final session =
              Provider.of<SessionService>(context, listen: false);
          final repo = Provider.of<PosRepository>(context, listen: false);
          final vm = Provider.of<PosViewModel>(context, listen: false);
          savingRef[0] = true;
          setModalState(() {});
          final token = await session.getToken(role: 'cashier');
          if (!context.mounted || token == null) {
            savingRef[0] = false;
            if (ctx.mounted) setModalState(() {});
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please sign in again.')),
              );
            }
            return;
          }
          try {
            await repo.patchOrderMaintenanceChecklist(
              orderId: order.id,
              checks: List<bool>.from(checks),
              token: token,
            );
            await vm.fetchOrders(
              silent: true,
              preferredOrderId: order.id,
            );
            if (!context.mounted) return;
            savingRef[0] = false;
            if (ctx.mounted) setModalState(() {});
            Navigator.of(dialogContext).pop();
            ToastService.showSuccess(
              context,
              'Maintenance checklist saved.',
            );
          } catch (e) {
            savingRef[0] = false;
            if (ctx.mounted) setModalState(() {});
            if (!context.mounted) return;
            ToastService.showError(
              context,
              e.toString().replaceFirst('Exception: ', ''),
            );
          }
        }

        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.playlist_add_check_rounded, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Maintenance checklist',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'These items appear on the printed invoice – tick each that applies.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (var i = 0;
                      i < InvoiceMaintenanceChecklist.rows.length;
                      i++)
                    CheckboxListTile(
                      value: checks[i],
                      onChanged: savingRef[0]
                          ? null
                          : (v) {
                              setModalState(() => checks[i] = v ?? false);
                            },
                      title: Text(
                        InvoiceMaintenanceChecklist.rows[i].en,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: Text(
                        InvoiceMaintenanceChecklist.rows[i].ar,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed:
                  savingRef[0] ? null : () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: savingRef[0] ? null : save,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: savingRef[0]
                  ? const SizedBox(
                      width: 52,
                      height: 22,
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  : const Text('Save'),
            ),
          ],
        );
      },
    ),
  );
}

/// Detail panel when this tab has no orders but other tabs do.
String _ordersTabDetailEmptyMessage(String tab) {
  switch (tab) {
    case 'Pending':
      return 'No pending orders found';
    case 'Completed':
      return 'No completed orders found';
    case 'All':
    default:
      return 'No orders found';
  }
}

class PosOrdersView extends StatefulWidget {
  const PosOrdersView({super.key});

  @override
  State<PosOrdersView> createState() => _PosOrdersViewState();
}

class _PosOrdersViewState extends State<PosOrdersView> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 900; // Master-Detail only on tablets/desktops
    final vm = context.watch<PosViewModel>();
    final showOrdersLoader = !vm.ordersApiFetchCompleted ||
        (vm.isLoading && vm.orders.isEmpty);

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD),
      appBar: PosScreenAppBar(
        title: 'Orders Hub',
        showBackButton: false,
        actions: [
          Consumer<PosViewModel>(
            builder: (context, vmRefresh, _) {
              final isBarTablet = MediaQuery.of(context).size.width > 600;
              return IconButton(
                tooltip: 'Refresh orders',
                onPressed: vmRefresh.isOrdersScreenRefreshing
                    ? null
                    : () => vmRefresh.refreshOrdersScreen(),
                icon: vmRefresh.isOrdersScreenRefreshing
                    ? SizedBox(
                        width: isBarTablet ? 24 : 22,
                        height: isBarTablet ? 24 : 22,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.black,
                        ),
                      )
                    : Icon(
                        Icons.refresh_rounded,
                        color: Colors.black,
                        size: isBarTablet ? 26 : 24,
                      ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          wrapPosShellRailBody(
            context,
            isTablet
                ? _OrdersTabletLayout(vm: vm)
                : _buildMobileView(vm),
          ),
          if (vm.isOrdersScreenRefreshing)
            Positioned.fill(
              child: AbsorbPointer(
                child: Container(
                  color: Colors.white.withValues(alpha: 0.5),
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            ),
          if (showOrdersLoader)
            Positioned.fill(
              child: Container(
                color: Colors.white,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMobileView(PosViewModel vm) {
    Future<void> onRefresh() => vm.refreshOrdersScreen();

    if (!vm.orders.any(_orderIsListableForOrdersList)) {
      return ColoredBox(
        color: const Color(0xFFFBFBFD),
        child: RefreshIndicator(
          color: AppColors.primaryLight,
          onRefresh: onRefresh,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: const Center(
                    child: _OrdersEmptyStateBody(title: 'No orders found'),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
    final visibleOrders = vm.orders.where(_orderIsListableForOrdersList).toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: PosSearchBar(
                  hintText: 'Search orders...',
                  onChanged: (val) => vm.setOrderSearchQuery(val),
                ),
              ),
              const SizedBox(width: 10),
              const _OrdersNewOrderButton(),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primaryLight,
            onRefresh: onRefresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: visibleOrders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = visibleOrders[index];
                return OrderItemCard(order: order, isTablet: false);
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Tablet: search + tabs on top; vertical order list in the first column (beside shell rail), then
/// job detail and draft totals.
class _OrdersTabletLayout extends StatefulWidget {
  final PosViewModel vm;
  const _OrdersTabletLayout({required this.vm});

  @override
  State<_OrdersTabletLayout> createState() => _OrdersTabletLayoutState();
}

class _OrdersTabletLayoutState extends State<_OrdersTabletLayout> {
  String _selectedTab = 'All';
  String? _lastSelectedOrderId;
  String? _lastSelectedOrderBadge;

  static const double _kOrderListColumnWidth = 204;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.vm.ordersListTab;
  }

  void _setSelectedTab(String title) {
    if (_selectedTab == title) return;
    setState(() => _selectedTab = title);
    widget.vm.setOrdersListTab(title);
  }

  Widget _buildTab(String title) {
    final isSelected = _selectedTab == title;
    return GestureDetector(
      onTap: () {
        _setSelectedTab(title);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFCC247) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(color: const Color(0xFFE8ECF3), width: 1.5),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? const Color(0xFF23262D) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    // Auto-follow: only switch tab when the *same* order's status changes
    // (e.g. after mark-complete), not when the user manually switches tabs.
    final selected = vm.selectedOrder;
    if (selected != null && _selectedTab != 'All') {
      final currentBadge = selected.jobsAggregateBadgeLabel;
      if (_lastSelectedOrderId == selected.id &&
          _lastSelectedOrderBadge != null &&
          _lastSelectedOrderBadge != currentBadge) {
        final selectedIsCompleted = currentBadge == 'COMPLETED';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _setSelectedTab(selectedIsCompleted ? 'Completed' : 'Pending');
          }
        });
      }
      _lastSelectedOrderId = selected.id;
      _lastSelectedOrderBadge = currentBadge;
    }

    final filteredOrders = vm.orders.where((order) {
      if (!_orderIsListableForOrdersList(order)) return false;
      if (_selectedTab == 'All') return true;
      final isCompleted = order.jobsAggregateBadgeLabel == 'COMPLETED';
      if (_selectedTab == 'Pending') {
        return !isCompleted;
      } else {
        return isCompleted;
      }
    }).toList();

    const draftColumnWidth = 392.0;

    final hasAnyListableOrder =
        vm.orders.any(_orderIsListableForOrdersList);

    if (!hasAnyListableOrder) {
      return ColoredBox(
        color: const Color(0xFFFBFBFD),
        child: RefreshIndicator(
          color: AppColors.primaryLight,
          onRefresh: () => widget.vm.refreshOrdersScreen(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      child: const _OrdersEmptyStateBody(
                        title: 'No orders found',
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    final selectedInFilter = vm.selectedOrder != null &&
        filteredOrders.any((o) => o.id == vm.selectedOrder!.id);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 12, 20, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: PosSearchBar(
                          hintText: 'Search plate, name, ID...',
                          onChanged: (val) =>
                              vm.setOrderSearchQuery(val),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const _OrdersNewOrderButton(),
                  ],
                ),
              ),
              ColoredBox(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 20, 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTab('All'),
                          const SizedBox(width: 12),
                          _buildTab('Pending'),
                          const SizedBox(width: 12),
                          _buildTab('Completed'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE8ECF3)),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: SizedBox(
                        width: _kOrderListColumnWidth,
                        child: ColoredBox(
                          color: Colors.white,
                          child: RefreshIndicator(
                            color: AppColors.primaryLight,
                            onRefresh: () => widget.vm.refreshOrdersScreen(),
                            child: ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(
                                14,
                                8,
                                12,
                                16,
                              ),
                              itemCount: filteredOrders.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final order = filteredOrders[index];
                                final isSelected =
                                    vm.selectedOrder?.id == order.id;
                                return _HorizontalOrderTile(
                                  order: order,
                                  isSelected: isSelected,
                                  fullWidth: true,
                                  onTap: () => vm.selectOrder(order),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    const VerticalDivider(
                        width: 1, color: Color(0xFFE8ECF3)),
                    Expanded(
                      flex: 3,
                      child: ColoredBox(
                        color: Colors.white,
                        child: _OrderDetailPanel(
                          vm: vm,
                          filteredOrders: filteredOrders,
                          selectedTab: _selectedTab,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1, color: Color(0xFFE8ECF3)),
        SizedBox(
          width: draftColumnWidth,
          child: ColoredBox(
            color: const Color(0xFFFBFBFD),
            child: !selectedInFilter
                ? const SizedBox.expand()
                : Padding(
                    padding: const EdgeInsets.fromLTRB(10, 12, 14, 12),
                    child: _OrderSummaryPanel(vm: vm),
                  ),
          ),
        ),
      ],
    );
  }
}

/// Edit customer + optional payment row (order summary footer; above checklist & Generate Invoice).
/// Payment label is [Select payment method] until [PosViewModel.invoicePaymentSelectionReady], then [Edit payment].
/// When [showPaymentMethodButton] is false (retail branch-employee payroll), only the customer button is shown.
class _OrdersHeaderCustomerPaymentRow extends StatelessWidget {
  final PosViewModel vm;
  final bool showPaymentMethodButton;
  const _OrdersHeaderCustomerPaymentRow({
    required this.vm,
    required this.showPaymentMethodButton,
  });

  @override
  Widget build(BuildContext context) {
    final order = vm.selectedOrder;
    final enabled = order != null;
    final isRejectedCorporateOrder = order != null &&
        order.isCorporateWalkIn &&
        order.isRejectedByCorporate;
    // Only block payment for corporate **walk-in** while waiting on corporate approval
    // (or rejected). Corporate bookings and post-approval walk-in behave like normal checkout.
    final corporateBillingLocked = order != null &&
        order.isCorporateWalkIn &&
        !order.isCorporateBookingOrder &&
        (order.isCorporateUnapproved ||
            order.isWaitingCorporateApproval ||
            order.isRejectedByCorporate);

    Future<void> openAddCustomer() async {
      if (order == null) return;
      final result = await showDialog<WalkInInvoiceFormResult?>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => WalkInInvoiceDetailsDialog(
          order: order,
          posVm: vm,
        ),
      );
      if (!context.mounted) return;
      if (result == null) return;
      ToastService.showSuccess(context, 'Customer details saved');
    }

    Future<void> openPayment() async {
      if (order == null) return;
      vm.ensureInvoicePaymentPrefillForOrder(order);
      final result = await showInvoicePaymentChoiceDialog(
        context,
        initialIsCorporate: vm.invoicePaymentIsCorporate,
        initialPayments: vm.invoicePaymentMethods,
        initialPaymentAmounts: vm.invoicePaymentAmounts,
        initialEmployeeIds: vm.invoicePaymentEmployeeIds,
        totalAmount: order.draftPosOrderTotalDisplay,
        persistDraftFn: (proposal) {
          return vm.persistCashierOrderPaymentDraft(
            orderId: order.id,
            isCorporate: proposal.isCorporate,
            methods: proposal.payments,
            paymentAmounts: proposal.paymentAmounts,
            payableTotal: order.draftPosOrderTotalDisplay,
          );
        },
        clearPersistedDraftFn: () =>
            vm.clearCashierOrderPaymentDraft(order.id),
      );
      if (!context.mounted) return;
      if (result != null) {
        vm.setInvoicePaymentPreferences(
          isCorporate: result.isCorporate,
          payments: result.payments,
          paymentAmounts: result.paymentAmounts,
          employeeIds: result.employeeIds,
        );
        ToastService.showSuccess(context, 'Payment method saved');
      }
    }

    final addCustomerBtn = Expanded(
      child: ElevatedButton(
        onPressed: (enabled && !isRejectedCorporateOrder) ? openAddCustomer : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.onPrimaryLight,
          disabledBackgroundColor: const Color(0xFFE8ECF3),
          disabledForegroundColor: const Color(0xFF94A3B8),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Edit customer details',
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            height: 1.15,
            color: AppColors.onPrimaryLight,
          ),
        ),
      ),
    );

    if (!showPaymentMethodButton) {
      return Row(children: [addCustomerBtn]);
    }

    return Row(
      children: [
        addCustomerBtn,
        const SizedBox(width: 6),
        Expanded(
          child: ElevatedButton(
            onPressed: (enabled && !corporateBillingLocked) ? openPayment : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: AppColors.onPrimaryLight,
              disabledBackgroundColor: const Color(0xFFE8ECF3),
              disabledForegroundColor: const Color(0xFF94A3B8),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              vm.invoicePaymentSelectionReady
                  ? 'Edit payment'
                  : 'Select payment method',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                height: 1.15,
                color: AppColors.onPrimaryLight,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Centered title + [New Order] for empty order list (tablet + mobile).
class _OrdersEmptyStateBody extends StatelessWidget {
  final String title;

  const _OrdersEmptyStateBody({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade500,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 20),
          const _OrdersNewOrderButton(),
        ],
      ),
    );
  }
}

class _OrdersNewOrderButton extends StatelessWidget {
  const _OrdersNewOrderButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFCC247),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          final vm = context.read<PosViewModel>();
          vm.clearCustomerData();
          vm.clearEditOrderContext();
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => const PosAddCustomerView(),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFCC247).withOpacity(0.18),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: Color(0xFF23262D), size: 18),
              SizedBox(width: 6),
              Text(
                'New Order',
                style: TextStyle(
                  color: Color(0xFF23262D),
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Job status chip — same look in department cards and ORDER SUMMARY.
Widget posOrdersJobStatusBadge(String statusRaw) {
  var s = statusRaw.toLowerCase().replaceAll(' ', '_');
  if (s == 'complete') s = 'completed';
  if (s == 'job_edited') s = 'edited';
  final isRejected =
      s == 'rejected_by_corporate' ||
      s == 'rejected' ||
      statusRaw.toLowerCase().contains('rejected');
  final isComplete = s == 'completed' || s == 'invoiced';
  final isEdited = s == 'edited';
  final isCancelled = s == 'cancelled' || s == 'canceled';
  final isInProgress =
      s == 'in_progress' || s == 'inprogress' || statusRaw.toLowerCase() == 'in progress';

  late Color fg;
  late Color bg;
  late Color border;
  late String label;

  if (isRejected) {
    fg = Colors.white;
    bg = const Color(0xFFD32F2F);
    border = const Color(0xFFB71C1C);
    label = 'REJECTED';
  } else if (isCancelled) {
    fg = Colors.white;
    bg = const Color(0xFFD32F2F);
    border = const Color(0xFFB71C1C);
    label = 'CANCELLED';
  } else if (isComplete) {
    fg = Colors.white;
    bg = const Color(0xFF4CAF50);
    border = const Color(0xFF388E3C);
    label = 'COMPLETE';
  } else if (isEdited) {
    fg = Colors.white;
    bg = const Color(0xFF4CAF50);
    border = const Color(0xFF388E3C);
    label = 'EDITED';
  } else if (isInProgress) {
    fg = Colors.white;
    bg = AppColors.primaryLight;
    border = const Color(0xFFE6B03A);
    label = 'IN PROGRESS';
  } else {
    fg = Colors.white;
    bg = const Color(0xFFFF9800);
    border = const Color(0xFFF57C00);
    label = 'PENDING';
  }

  final textStyle = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w800,
    color: fg,
    letterSpacing: 0.5,
  );

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: border),
    ),
    child: Text(label, style: textStyle),
  );
}

/// Same in-progress rule as [posOrdersJobStatusBadge]; [statusRaw] is trimmed so detection matches the chip.
bool _posOrdersStatusIsInProgress(String statusRaw) {
  final t = statusRaw.trim();
  var s = t.toLowerCase().replaceAll(' ', '_');
  if (s == 'complete') s = 'completed';
  if (s == 'job_edited') s = 'edited';
  return s == 'in_progress' ||
      s == 'inprogress' ||
      t.toLowerCase() == 'in progress';
}

class _OrderDetailPanel extends StatelessWidget {
  final PosViewModel vm;
  final List<PosOrder> filteredOrders;
  final String selectedTab;

  const _OrderDetailPanel({
    required this.vm,
    required this.filteredOrders,
    required this.selectedTab,
  });

  @override
  Widget build(BuildContext context) {
    final hasListable =
        vm.orders.any(_orderIsListableForOrdersList);

    if (filteredOrders.isEmpty && hasListable) {
      return ColoredBox(
        color: Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _ordersTabDetailEmptyMessage(selectedTab),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade500,
                height: 1.35,
              ),
            ),
          ),
        ),
      );
    }

    final sel = vm.selectedOrder;
    final order = sel != null &&
            filteredOrders.any((o) => o.id == sel.id)
        ? sel
        : null;

    return Column(
      children: [
        if (order == null)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.assignment_rounded, size: 64, color: Colors.grey.shade200),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No Order Selected',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select an order from the list on the left to view details',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const pad = EdgeInsets.fromLTRB(28, 12, 28, 24);
              const crossSpacing = 16.0;
              const runSpacing = 16.0;
              final innerW = constraints.maxWidth - pad.horizontal;
              final tileW = (innerW - crossSpacing) / 2;
              final showAdd = _canAddDepartmentToOrder(order);
              final hasRealJobs =
                  order.jobs.any((j) => !j.isCancelledJob);
              final showCorporateProposalCards = order.isCorporateWalkIn &&
                  !hasRealJobs &&
                  order.selectedDepartmentNames.isNotEmpty;

              final items = [
                for (final j in order.jobs.where((j) => !j.isCancelledJob))
                  _JobCard(order: order, job: j),
                if (showCorporateProposalCards)
                  for (final dept in order.selectedDepartmentEntries)
                    _CorporatePendingJobCard(
                      order: order,
                      departmentName: dept['name'] ?? '',
                      departmentId: dept['id'] ?? '',
                    ),
                if (showAdd) _AddDepartmentCard(order: order),
              ];

              return SingleChildScrollView(
                padding: pad,
                child: Column(
                  children: [
                    for (int i = 0; i < items.length; i += 2) ...[
                      if (i > 0) SizedBox(height: runSpacing),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: items[i]),
                            const SizedBox(width: crossSpacing),
                            Expanded(
                              child: i + 1 < items.length
                                  ? items[i + 1]
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

String _normalizeDeptKey(String value) =>
    value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

bool _canAddDepartmentToOrder(PosOrder order) {
  if (order.id.trim().isEmpty) return false;
  final src = order.source.toLowerCase().replaceAll('-', '_');
  if (!src.contains('walk')) return false;
  if (order.isCorporateWalkIn && order.isRejectedByCorporate) return false;
  final st = order.status.toLowerCase();
  if (st == 'invoiced' || st == 'cancelled' || st == 'completed' || st == 'edited') return false;
  if ((order.invoiceNo ?? '').trim().isNotEmpty) return false;
  return true;
}

Future<void> _onAddDepartmentTap(BuildContext context, PosOrder order) async {
  if (!_canAddDepartmentToOrder(order)) return;

  final deptVm = context.read<DepartmentViewModel>();
  if (deptVm.departments.isEmpty) {
    await deptVm.fetchDepartments();
  }
  if (!context.mounted) return;

  final blockedIds = <String>{};
  final blockedNameKeys = <String>{};
  for (final j in order.jobs) {
    if (j.isCancelledJob) continue;
    final r = _resolveDepartmentForJob(context, j);
    if (r != null) {
      blockedIds.add(r.id);
      blockedNameKeys.add(_normalizeDeptKey(r.name));
    } else if (j.department.trim().isNotEmpty) {
      blockedNameKeys.add(_normalizeDeptKey(j.department));
    }
  }

  final anyAvailable = deptVm.departments.any((d) {
    if (!d.isActive) return false;
    if (blockedIds.contains(d.id)) return false;
    if (blockedNameKeys.contains(_normalizeDeptKey(d.name))) return false;
    return true;
  });
  if (!anyAvailable) {
    ToastService.showError(context, 'No departments available to add.');
    return;
  }

  await Navigator.push<void>(
    context,
    MaterialPageRoute<void>(
      builder: (_) => PosDepartmentView(
        addJobsToOrderId: order.id,
        excludedDepartmentIds: blockedIds.toList(),
        excludedNormalizedNameKeys: blockedNameKeys.toList(),
      ),
    ),
  );
}

class _AddDepartmentCard extends StatelessWidget {
  final PosOrder order;
  const _AddDepartmentCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onAddDepartmentTap(context, order),
        borderRadius: BorderRadius.circular(18),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: const Color(0xFFC5CAD3),
            strokeWidth: 1.5,
            borderRadius: 18,
            dashPattern: [6, 4],
          ),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add_rounded, color: Color(0xFFFCC247), size: 28),
                ),
                const SizedBox(height: 14),
                Text(
                  'ADD DEPARTMENT',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CorporatePendingJobCard extends StatelessWidget {
  final PosOrder order;
  final String departmentName;
  final String departmentId;
  const _CorporatePendingJobCard({
    required this.order,
    required this.departmentName,
    required this.departmentId,
  });

  @override
  Widget build(BuildContext context) {
    final isRejectedCorporateOrder =
        order.isCorporateWalkIn && order.isRejectedByCorporate;
    final orderItems = order.items
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    final deptId = departmentId.trim();
    final deptNameLower = departmentName.trim().toLowerCase();
    final deptItems = orderItems.where((item) {
      final itemDeptId = (item['departmentId'] ?? '').toString().trim();
      final itemDeptName =
          (item['departmentName'] ?? '').toString().trim().toLowerCase();
      if (deptId.isNotEmpty && itemDeptId.isNotEmpty) {
        return itemDeptId == deptId;
      }
      return itemDeptName == deptNameLower;
    }).toList();
    final hasDeptItems = deptItems.isNotEmpty;
    final deptItemCount = deptItems.length;
    final deptTotal = deptItems.fold<double>(0.0, (sum, item) {
      final lineTotal = double.tryParse(item['lineTotal']?.toString() ?? '');
      if (lineTotal != null) return sum + lineTotal;
      final qty = double.tryParse(item['qty']?.toString() ?? '0') ?? 0;
      final unitPrice =
          double.tryParse(item['unitPrice']?.toString() ?? '0') ?? 0;
      return sum + (qty * unitPrice);
    });

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE8ECF3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.settings_rounded,
                      color: Color(0xFFFF9800),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          departmentName.toUpperCase(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                            color: Color(0xFF1E2124),
                          ),
                        ),
                        const SizedBox(height: 6),
                        posOrdersJobStatusBadge('pending'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 2, 12, 6),
              child: Column(
                children: [
                  _ModernActionChip(
                    icon: Icons.add_shopping_cart_rounded,
                    label: hasDeptItems
                        ? '$deptItemCount ${deptItemCount == 1 ? 'item' : 'items'}'
                        : 'Products & Services',
                    trailing: hasDeptItems
                        ? Text(
                            'SAR ${deptTotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E2124),
                            ),
                          )
                        : null,
                    onTap: () async {
                      if (isRejectedCorporateOrder) {
                        ToastService.showError(
                          context,
                          'Rejected corporate orders are read-only. Remove the order from the list.',
                        );
                        return;
                      }
                      final vm = context.read<PosViewModel>();
                      vm.primeCorporateWalkInDraftFromOrder(order);
                      vm.clearCart();
                      PosOrderJob? matchedJob;

                      PosOrder sourceOrder = order;
                      var latestOrder = await vm.loadCashierOrderDetail(order.id);
                      if (latestOrder != null) {
                        sourceOrder = latestOrder;
                      }

                      for (final j in sourceOrder.jobs) {
                        final jid = (j.departmentId ?? '').trim();
                        final jname = j.department.trim().toLowerCase();
                        final wantId = departmentId.trim();
                        final wantName = departmentName.trim().toLowerCase();
                        if (wantId.isNotEmpty && jid.isNotEmpty && jid == wantId) {
                          matchedJob = j;
                          break;
                        }
                        if (jname.isNotEmpty && jname == wantName) {
                          matchedJob = j;
                          break;
                        }
                      }

                      if (matchedJob != null && matchedJob.id.trim().isNotEmpty) {
                        final preSelected = <dynamic>[];
                        for (final item in matchedJob.items) {
                          preSelected.add({
                            item.itemType == 'service' ? 'serviceId' : 'productId':
                                item.productId,
                            'quantity': item.qty,
                            'discountType': item.discountType,
                            'discountValue': item.discountValue ?? 0.0,
                            if (item.itemType == 'service' && item.unitPrice > 0)
                              'unitPrice': item.unitPrice,
                          });
                        }
                        vm.setEditOrderContext(
                          departmentId: departmentId.trim().isNotEmpty
                              ? departmentId
                              : (matchedJob.departmentId ?? ''),
                          preSelectedItems: preSelected,
                          order: sourceOrder,
                          completingOrderId: matchedJob.id,
                        );
                      } else {
                        vm.clearEditOrderContext(notify: false);
                        if (context.mounted) {
                          ToastService.showError(
                            context,
                            'Job ID not available for this department yet. Pricing API cannot run without job.',
                          );
                        }
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => PosProductGridView(
                            departmentName: departmentName,
                            departmentId:
                                departmentId.trim().isNotEmpty ? departmentId : null,
                            selectedDepartmentIds: order.selectedDepartmentEntries
                                .map((e) => e['id'] ?? '')
                                .where((id) => id.trim().isNotEmpty)
                                .toList(),
                            selectedDepartmentNames: order.selectedDepartmentEntries
                                .map((e) => e['name'] ?? '')
                                .where((name) => name.trim().isNotEmpty)
                                .toList(),
                            completingOrder: matchedJob != null ? sourceOrder : null,
                            completingOrderId: matchedJob?.id,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _ModernActionChip(
                    icon: Icons.engineering_rounded,
                    label: 'Assign Technicians',
                    onTap: () => ToastService.showError(
                      context,
                      isRejectedCorporateOrder
                          ? 'Rejected corporate orders are read-only. Remove the order from the list.'
                          : 'This corporate walk-in has no real jobId yet. Send for approval first, then assign technicians as normal.',
                    ),
                  ),
                ],
              ),
            ),
            if (!isRejectedCorporateOrder) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 2, 12, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: _JobFooterButton(
                        label: 'Cancel',
                        backgroundColor: const Color(0xFF23262D),
                        textColor: Colors.white,
                        enabled: true,
                        onTap: () => showCashierCancelOrderDialog(context, order.id),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _JobFooterButton(
                        label: 'Mark Complete',
                        backgroundColor: const Color(0xFFFCC247),
                        textColor: const Color(0xFF23262D),
                        enabled: true,
                        onTap: () => ToastService.showError(
                          context,
                          'Corporate order must be approved before completing jobs.',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double borderRadius;
  final List<double> dashPattern;

  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.borderRadius,
    required this.dashPattern,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(borderRadius),
      ));

    for (final segment in _calculateDashes(path, dashPattern)) {
      canvas.drawPath(segment, paint);
    }
  }

  List<Path> _calculateDashes(Path source, List<double> pattern) {
    final List<Path> result = [];
    final PathMetrics metrics = source.computeMetrics();
    for (final PathMetric metric in metrics) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final double len = pattern[result.length % pattern.length];
        if (draw) {
          result.add(metric.extractPath(distance, distance + len));
        }
        distance += len;
        draw = !draw;
      }
    }
    return result;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Resolved department id + display name for a job (job payload → line items → department list → catalog).
({String id, String name})? _resolveDepartmentForJob(BuildContext context, PosOrderJob job) {
  final posVm = context.read<PosViewModel>();
  final deptVm = context.read<DepartmentViewModel>();

  String deptId = job.departmentId?.trim() ?? '';
  String deptName = job.department;

  for (final item in job.items) {
    if (item.departmentId.isNotEmpty) {
      deptId = item.departmentId;
      if (item.departmentName.isNotEmpty) {
        deptName = item.departmentName;
      }
      break;
    }
  }

  if (deptId.isEmpty && deptVm.departments.isNotEmpty) {
    final jobKey = _normalizeDeptKey(job.department);
    for (final d in deptVm.departments) {
      final dk = _normalizeDeptKey(d.name);
      if (dk == jobKey || dk.contains(jobKey) || jobKey.contains(dk)) {
        deptId = d.id;
        deptName = d.name;
        break;
      }
    }
  }

  if (deptId.isEmpty && posVm.allProducts.isNotEmpty) {
    final jobKey = _normalizeDeptKey(job.department);
    for (final p in posVm.allProducts) {
      final pd = (p.departmentId ?? '').trim();
      if (pd.isEmpty) continue;
      final pKey = _normalizeDeptKey(p.departmentName ?? '');
      if (pKey == jobKey || pKey.contains(jobKey) || jobKey.contains(pKey)) {
        deptId = pd;
        if ((p.departmentName ?? '').trim().isNotEmpty) {
          deptName = p.departmentName!.trim();
        }
        break;
      }
    }
  }

  if (deptId.isEmpty) return null;
  return (id: deptId, name: deptName);
}

void _openJobTechnicianAssignment(BuildContext context, PosOrder order, PosOrderJob job) {
  final resolved = _resolveDepartmentForJob(context, job);
  if (resolved == null) {
    ToastService.showError(
      context,
      'Could not resolve department for "${job.department}".',
    );
    return;
  }
  if (job.id.trim().isEmpty) {
    ToastService.showError(context, 'Job ID missing.');
    return;
  }

  Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => PosTechnicianAssignmentView(
        jobId: job.id,
        departmentName: resolved.name,
        departmentId: resolved.id,
        isWalkIn: false,
        initialAssignedTechnicians: job.distinctActiveTechnicians,
      ),
    ),
  );
}

void _openJobProductGrid(BuildContext context, PosOrder order, PosOrderJob job) {
  final posVm = context.read<PosViewModel>();

  if (posVm.vehicleNumber.trim().isEmpty && order.plateNumber.trim().isEmpty) {
    ToastService.showError(
      context,
      'Please add vehicle number first (Add Customer)',
    );
    return;
  }

  final resolved = _resolveDepartmentForJob(context, job);
  if (resolved == null) {
    ToastService.showError(
      context,
      'Could not resolve department for "${job.department}".',
    );
    return;
  }
  final deptId = resolved.id.trim();
  final deptName = resolved.name;

  final preSelected = <dynamic>[];
  for (final item in dedupeCashierServiceLinesForPosDisplay(job.items)) {
    preSelected.add({
      item.itemType == 'service' ? 'serviceId' : 'productId': item.productId,
      'quantity': item.qty,
      'discountType': item.discountType,
      'discountValue': item.discountValue ?? 0.0,
      if (item.itemType == 'service' && item.unitPrice > 0) 'unitPrice': item.unitPrice,
    });
  }

  posVm.clearCart();
  posVm.setCustomerData(
    name: order.customerName,
    vat: order.customer?.vatNumber ?? '',
    mobile: order.customer?.mobile ?? '',
    vehicleNumber: order.plateNumber.trim().isNotEmpty ? order.plateNumber : posVm.vehicleNumber,
    vinNumber: order.vehicle?.vin ?? '',
    make: order.vehicle?.make ?? '',
    model: order.vehicle?.model ?? '',
    odometer: order.odometerReading,
    previousOrderId: order.id,
    vehicleYear: order.vehicle?.year ?? '',
    vehicleColor: order.vehicle?.color ?? '',
  );
  posVm.setEditOrderContext(
    departmentId: deptId,
    preSelectedItems: preSelected,
    order: order,
    completingOrderId: job.id,
  );

  // Catalog loads on PosProductGridView (overlay loader there), not on Orders.
  Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => PosProductGridView(
        departmentName: deptName,
        departmentId: deptId,
        selectedDepartmentIds: [deptId],
        selectedDepartmentNames: [deptName],
        preSelectedItems: preSelected,
        completingOrderId: job.id,
        completingOrder: order,
      ),
    ),
  );
}

Future<void> _onMarkJobComplete(
  BuildContext context,
  PosOrder order,
  PosOrderJob job,
) async {
  if (order.isCorporateWalkIn &&
      !order.isCorporateBookingOrder &&
      (order.isCorporateUnapproved ||
          order.isWaitingCorporateApproval ||
          order.isRejectedByCorporate)) {
    ToastService.showError(
      context,
      'Corporate order must be approved before completing jobs.',
    );
    return;
  }
  if (job.items.isEmpty) {
    ToastService.showError(context, 'This job has no line items.');
    return;
  }

  // Ensure technicians are assigned
  if (job.distinctActiveTechnicians.isEmpty) {
    ToastService.showError(context, 'Technician assignment is required.');
    return;
  }
  final vm = context.read<PosViewModel>();
  final response = await vm.completeCashierJob(
    job.id,
    sourceOrder: order,
  );
  if (!context.mounted) return;
  if (response != null && response.success) {
    ToastService.showSuccess(
      context,
      response.message.isNotEmpty ? response.message : 'Job marked complete',
    );
  } else {
    ToastService.showError(
      context,
      response?.message ?? 'Failed to complete job',
    );
  }
}

Future<void> _onCancelJob(
  BuildContext context,
  PosOrderJob job,
) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _CancelJobConfirmDialog(jobId: job.id),
  );
}

class _CancelJobConfirmDialog extends StatefulWidget {
  final String jobId;
  const _CancelJobConfirmDialog({required this.jobId});

  @override
  State<_CancelJobConfirmDialog> createState() => _CancelJobConfirmDialogState();
}

class _CancelJobConfirmDialogState extends State<_CancelJobConfirmDialog> {
  bool _isBusy = false;

  Future<void> _handleConfirm() async {
    setState(() => _isBusy = true);
    try {
      final vm = context.read<PosViewModel>();
      final success = await vm.cancelCashierJob(context, widget.jobId);
      if (mounted && success) {
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Delete Job',
              style: AppTextStyles.h2.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to delete this job? This action cannot be undone.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (!_isBusy) Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.secondaryLight,
                      elevation: 0,
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      minimumSize: const Size(0, 40),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('NO', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5, fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isBusy ? null : _handleConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLight,
                      foregroundColor: AppColors.onPrimaryLight,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      minimumSize: const Size(0, 40),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: _isBusy
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.onPrimaryLight,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('YES, DELETE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5, fontSize: 13)),
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

class _JobCard extends StatelessWidget {
  final PosOrder order;
  final PosOrderJob job;
  const _JobCard({required this.order, required this.job});

  IconData _getDepartmentIcon(String dept) {
    final d = dept.toLowerCase();
    if (d.contains('mechanical')) return Icons.build_rounded;
    if (d.contains('paint') || d.contains('body')) return Icons.format_paint_rounded;
    if (d.contains('electrical')) return Icons.electrical_services_rounded;
    if (d.contains('wash') || d.contains('detail')) return Icons.local_car_wash_rounded;
    if (d.contains('ac')) return Icons.ac_unit_rounded;
    return Icons.settings_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final statusForUi =
        (order.isCorporateWalkIn && order.isRejectedByCorporate)
            ? order.status
            : job.status;
    var st = job.status.toLowerCase().trim();
    if (st == 'complete') st = 'completed';
    if (st == 'job_edited') st = 'edited';
    final isInvoiced = st == 'invoiced';
    final isComplete = st == 'completed';
    final isEdited = st == 'edited';
    final isInProgressCard = _posOrdersStatusIsInProgress(statusForUi);
    final isCancelled = job.isCancelledJob;
    final isRejectedCorporateOrder =
        order.isCorporateWalkIn && order.isRejectedByCorporate;
    final isLocked = isInvoiced || isCancelled || isRejectedCorporateOrder;

    final jobLineItems = dedupeCashierServiceLinesForPosDisplay(job.items);
    final hasLineItems = jobLineItems.isNotEmpty;
    final lineItemCount = jobLineItems.length;
    final linesSubtotalFallback = jobLineItems.fold<double>(
      0.0,
      (sum, i) => sum + (i.lineTotal > 0 ? i.lineTotal : i.qty * i.unitPrice),
    );
    // Same as DRAFT TOTALS per department row (`job.totalAmount` from API, incl. VAT / job-level pricing).
    final jobTotalDisplay =
        job.totalAmount > 0 ? job.totalAmount : linesSubtotalFallback;

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE8ECF3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          // 1. Premium Header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: (isComplete || isEdited)
                        ? const Color(0xFFE8F5E9)
                        : isInProgressCard
                            ? AppColors.primaryLight.withValues(alpha: 0.28)
                            : const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getDepartmentIcon(job.department),
                    color: (isComplete || isEdited)
                        ? const Color(0xFF4CAF50)
                        : isInProgressCard
                            ? AppColors.primaryLight
                            : const Color(0xFFFF9800),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        job.department.toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                          color: Color(0xFF1E2124),
                        ),
                      ),
                      const SizedBox(height: 6),
                      posOrdersJobStatusBadge(statusForUi),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 2. Action Chips (no Expanded — avoids empty stretch above footer)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 2, 12, 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ModernActionChip(
                  icon: Icons.add_shopping_cart_rounded,
                  label: hasLineItems
                      ? '$lineItemCount ${lineItemCount == 1 ? 'item' : 'items'}'
                      : 'Products & Services',
                  trailing: hasLineItems
                      ? Text(
                          'SAR ${jobTotalDisplay.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E2124),
                          ),
                        )
                      : null,
                  onTap: isLocked
                      ? () => ToastService.showError(
                            context,
                            'This job cannot be edited.',
                          )
                      : () => _openJobProductGrid(
                            context,
                            order,
                            job,
                          ),
                ),
                const SizedBox(height: 8),
                _ModernActionChip(
                  icon: Icons.engineering_rounded,
                  label: job.distinctActiveTechnicians.isEmpty
                      ? 'Assign Technicians'
                      : '${job.distinctActiveTechnicians.length} ${job.distinctActiveTechnicians.length == 1 ? 'technician' : 'technicians'}',
                  onTap: isLocked
                      ? () => ToastService.showError(
                            context,
                            'This job cannot be edited.',
                          )
                      : () => _openJobTechnicianAssignment(
                            context,
                            order,
                            job,
                          ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // 3. Footer Action Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 2, 12, 10),
            child: Consumer<PosViewModel>(
              builder: (context, posVm, _) {
                final completing = posVm.isCashierCompletingJob(job.id);
                return Row(
                  children: [
                    if (!isInvoiced && !isComplete && !isEdited) ...[
                      Expanded(
                        child: _JobFooterButton(
                          label: 'Cancel',
                        backgroundColor: isCancelled
                                ? const Color(0xFF23262D).withValues(alpha: 0.45)
                                : const Color(0xFF23262D),
                            textColor: Colors.white,
                            isBusy: false, // Cancellation happens in a dialog now
                            enabled:
                                !isCancelled && !completing && !isRejectedCorporateOrder,
                            onTap: () {
                              if (isRejectedCorporateOrder) {
                                ToastService.showError(
                                  context,
                                  'Rejected corporate orders are read-only. Remove the order from the list.',
                                );
                                return;
                              }
                              _onCancelJob(context, job);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    if (!isInvoiced)
                      Expanded(
                        child: _JobFooterButton(
                          label: (isComplete || isEdited)
                              ? 'Edit'
                              : isCancelled
                                  ? 'Cancelled'
                                  : 'Mark Complete',
                          backgroundColor: (isComplete || isEdited)
                              ? const Color(0xFF23262D)
                              : isCancelled
                                  ? const Color(0xFFD32F2F)
                                  : const Color(0xFFFCC247),
                          textColor: (isComplete || isEdited)
                              ? Colors.white
                              : isCancelled
                                  ? Colors.white
                                  : const Color(0xFF23262D),
                          isBusy: (isComplete || isEdited)
                              ? false
                              : completing &&
                                  !isInvoiced &&
                                  !isComplete &&
                                  !isEdited &&
                                  !isCancelled,
                          enabled: !completing && !isRejectedCorporateOrder,
                          onTap: (isComplete || isEdited)
                              ? () {
                                  if (isRejectedCorporateOrder) {
                                    ToastService.showError(
                                      context,
                                      'Rejected corporate orders are read-only. Remove the order from the list.',
                                    );
                                    return;
                                  }
                                  _openJobProductGrid(
                                    context,
                                    order,
                                    job,
                                  );
                                }
                              : isCancelled
                                  ? () {}
                                  : () => _onMarkJobComplete(context, order, job),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
        ),
      ),
    );
  }

}

class _ModernActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  /// When null, shows the default edit (pen) icon.
  final Widget? trailing;
  /// When set, replaces the default [label] text (e.g. multi-line technicians).
  final Widget? labelWidget;

  const _ModernActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.labelWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(icon, color: const Color(0xFF64748B), size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: labelWidget ??
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF475569),
                      ),
                    ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: trailing ??
                    const Icon(
                      Icons.mode_edit_outline_rounded,
                      color: Color(0xFFCBD5E1),
                      size: 14,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JobFooterButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;
  final bool isBusy;
  /// When false, button is non-interactive (e.g. Cancel after job already cancelled).
  final bool enabled;

  const _JobFooterButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
    this.isBusy = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: (isBusy || !enabled) ? null : onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          alignment: Alignment.center,
          child: isBusy
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
                    color: textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
        ),
      ),
    );
  }
}

// --- Draft totals panel: amounts follow GET /cashier/orders job & order fields (VAT excl. where noted on model). ---

String _draftFmtQty(double q) =>
    q == q.roundToDouble() ? q.toInt().toString() : q.toStringAsFixed(2);

double _draftLineDisplayTotal(PosOrderJob job, PosOrderJobItem item) {
  if (item.lineTotalExcludingVat > 0.0001) return item.lineTotalExcludingVat;
  final exVatFromUnit = _draftLineUnitPriceExVat(job, item) * item.qty;
  if (exVatFromUnit > 0.0001) return exVatFromUnit;
  if (item.lineTotal > 0) {
    final pct = job.vatPercent;
    if (pct > 0) {
      return item.lineTotal / (1.0 + pct / 100.0);
    }
    return item.lineTotal;
  }
  return item.qty * item.unitPrice;
}

/// Unit price for ORDER SUMMARY qty row — line [unitPrice] from API is often VAT-inclusive.
double _draftLineUnitPriceExVat(PosOrderJob job, PosOrderJobItem item) {
  if (item.unitPriceExcludingVat > 0.0001) return item.unitPriceExcludingVat;
  final pct = job.vatPercent;
  if (pct <= 0 || item.unitPrice <= 0) return item.unitPrice;
  return item.unitPrice / (1.0 + pct / 100.0);
}

String? _draftLineDiscountLabel(PosOrderJobItem item) {
  final dv = item.discountValue ?? 0;
  if (dv <= 0) return null;
  final t = (item.discountType ?? '').toLowerCase();
  if (t == 'percent' || t == 'percentage') {
    final s = dv == dv.roundToDouble() ? dv.toInt().toString() : dv.toStringAsFixed(1);
    return 'Line discount ($s%)';
  }
  return 'Line discount';
}

/// SAR amount for the line discount row (fixed value or % of `qty × unitPrice`).
double? _draftLineDiscountAmountSar(PosOrderJobItem item) {
  final dv = item.discountValue ?? 0;
  if (dv <= 0) return null;
  final t = (item.discountType ?? '').toLowerCase();
  if (t == 'percent' || t == 'percentage') {
    final base = item.qty * item.unitPrice;
    if (base <= 0) return null;
    return base * (dv / 100.0);
  }
  return dv;
}

double _draftJobOrderLevelDiscountAmount(PosOrderJob job) {
  final v = job.totalDiscountValue;
  if (v <= 0) return 0;
  final t = (job.totalDiscountType ?? '').toLowerCase();
  if (t == 'percent' || t == 'percentage') {
    if (job.amountAfterDiscount <= 0) return 0;
    return job.amountAfterDiscount * (v / 100);
  }
  return v;
}

double _draftOrderLevelDiscountAmount(PosOrder order) {
  final raw = order.totalDiscountValue;
  if (raw == null || raw <= 0) return 0;
  final t = (order.totalDiscountType ?? '').toLowerCase();
  if (t == 'percent' || t == 'percentage') {
    var base = order.subtotal;
    if (base <= 0) {
      base = order.jobs
          .where((j) => !j.isCancelledJob)
          .fold<double>(0, (s, j) => s + j.amountAfterPromo);
    }
    if (base <= 0) return 0;
    return base * (raw / 100);
  }
  return raw;
}

/// Per job: taxable total after discounts/promo, before VAT ([PosOrderJob.amountAfterPromo]).
double _draftJobTotalBeforeVat(PosOrderJob job) {
  if (job.amountAfterPromo > 0.0001) return job.amountAfterPromo;
  final apiDerived = (job.totalAmount - job.vatAmount).clamp(0.0, double.infinity);
  if (apiDerived > 0.0001) return apiDerived;
  final lineFallback = dedupeCashierServiceLinesForPosDisplay(job.items)
      .fold<double>(
    0.0,
    (s, item) => s + _draftLineDisplayTotal(job, item),
  );
  return lineFallback.clamp(0.0, double.infinity);
}

/// Per job total including VAT, matching the department summary rows exactly.
double _draftJobTotalInclVat(PosOrderJob job) {
  final beforeVat = _draftJobTotalBeforeVat(job);
  final vatFromLines = dedupeCashierServiceLinesForPosDisplay(job.items).fold<double>(
    0.0,
    (s, item) => s + item.lineVatAmount,
  );
  final vatAmount = job.vatAmount > 0.0001
      ? job.vatAmount
      : vatFromLines > 0.0001
          ? vatFromLines
          : (job.vatPercent > 0 ? beforeVat * (job.vatPercent / 100.0) : 0.0);
  return job.totalAmount > 0.0001 ? job.totalAmount : (beforeVat + vatAmount);
}

/// Cashier **order summary preview only** — same numeric base as invoice commission
/// (`job.totalAmount` incl. VAT when set). Does **not** credit wallets; technician app unchanged.
double _draftJobCommissionPreviewBaseTotal(PosOrderJob job) {
  if (job.totalAmount > 0.0001) return job.totalAmount;
  return _draftJobTotalInclVat(job);
}

/// Preview SAR per technician: `(base × commissionPercent / 100) ÷ technicianCount`.
double _draftPerTechnicianCommissionPreviewSar(
  PosOrderJob job,
  JobTechnician tech,
  int technicianCount,
) {
  if (technicianCount <= 0) return 0;
  final base = _draftJobCommissionPreviewBaseTotal(job);
  return (base * tech.commissionPercent / 100.0) / technicianCount;
}

/// Plain totals under dept discount (no highlight strip) — same label typography as dept discount.
Widget _draftDeptTotalsPlainTextRows(PosOrderJob job) {
  final labelStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: Colors.grey.shade600,
    height: 1.25,
  );
  final valueStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w800,
    color: Colors.grey.shade800,
    height: 1.25,
  );
  final pct = job.vatPercent;
  final pctLabel = (pct - pct.round()).abs() < 0.001
      ? pct.round().toString()
      : pct.toStringAsFixed(1);
  final beforeVat = _draftJobTotalBeforeVat(job);
  final vatFromLines = dedupeCashierServiceLinesForPosDisplay(job.items)
      .fold<double>(
    0.0,
    (s, item) => s + item.lineVatAmount,
  );
  final vatAmount = job.vatAmount > 0.0001
      ? job.vatAmount
      : vatFromLines > 0.0001
          ? vatFromLines
      : (pct > 0 ? beforeVat * (pct / 100.0) : 0.0);
  final totalInclVat = _draftJobTotalInclVat(job);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text('Total before VAT', style: labelStyle)),
          Text(
            '${beforeVat.toStringAsFixed(2)} SAR',
            style: valueStyle,
          ),
        ],
      ),
      const SizedBox(height: 4),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text('VAT ($pctLabel%)', style: labelStyle)),
          Text(
            '+ ${vatAmount.toStringAsFixed(2)} SAR',
            style: valueStyle.copyWith(color: Colors.red.shade700),
          ),
        ],
      ),
      const SizedBox(height: 4),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Total (incl. VAT)',
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.grey.shade800,
                height: 1.25,
              ),
            ),
          ),
          Text(
            '${totalInclVat.toStringAsFixed(2)} SAR',
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E2124),
              height: 1.25,
            ),
          ),
        ],
      ),
    ],
  );
}

/// Light fill for ORDER SUMMARY department name row (matches badge hue).
Color _orderSummaryDeptHeaderFillForStatus(String statusRaw) {
  var s = statusRaw.toLowerCase().replaceAll(' ', '_');
  if (s == 'complete') s = 'completed';
  if (s == 'job_edited') s = 'edited';
  final isComplete = s == 'completed' || s == 'invoiced';
  final isEdited = s == 'edited';
  final isCancelled = s == 'cancelled' || s == 'canceled';
  final isInProgress =
      s == 'in_progress' || s == 'inprogress' || statusRaw.toLowerCase() == 'in progress';

  if (isCancelled) return const Color(0xFFFFEBEE);
  if (isComplete || isEdited) return const Color(0xFFE8F5E9);
  if (isInProgress) return const Color(0xFFFFF9E8);
  return const Color(0xFFFFF3E0);
}

/// Highlight strip for department name / dept total / grand total in the order summary column.
/// [secondaryBackground] uses [AppColors.secondaryLight] for the **grand total** row.
/// [departmentTotalStripe] uses a light neutral strip so it does not match the grand total bar.
/// [departmentStatusHeaderTint] when set, tints the strip to the same hue as the job status badge.
Widget _orderSummaryHighlightBox({
  required Widget child,
  bool emphasized = false,
  bool secondaryBackground = false,
  /// Tighter padding & radius (e.g. grand total row).
  bool compact = false,
  /// Per-job "Department total" row — light background, distinct from grand total.
  bool departmentTotalStripe = false,
  String? departmentStatusHeaderTint,
}) {
  final useDeptStatusTint = !departmentTotalStripe &&
      !secondaryBackground &&
      (departmentStatusHeaderTint?.trim().isNotEmpty ?? false);

  final Color bg;
  final Color borderColor;
  final double borderW;
  List<BoxShadow>? boxShadow;

  if (departmentTotalStripe) {
    bg = const Color(0xFFEFF1F5);
    borderColor = const Color(0xFFD1D9E6);
    borderW = 1;
    boxShadow = null;
  } else if (secondaryBackground) {
    bg = AppColors.secondaryLight;
    borderColor = AppColors.primaryLight.withValues(alpha: emphasized ? 0.55 : 0.4);
    borderW = emphasized ? 2 : 1.5;
    boxShadow = emphasized
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
        : null;
  } else if (useDeptStatusTint) {
    bg = _orderSummaryDeptHeaderFillForStatus(departmentStatusHeaderTint!);
    borderColor = Colors.transparent;
    borderW = 0;
    boxShadow = null;
  } else {
    bg = emphasized
        ? const Color(0xFFFFF3D6)
        : const Color(0xFFFFF9E8);
    borderColor =
        const Color(0xFFFCC247).withValues(alpha: emphasized ? 0.95 : 0.55);
    borderW = emphasized ? 2 : 1.5;
    boxShadow = emphasized
        ? [
            BoxShadow(
              color: const Color(0xFFFCC247).withValues(alpha: 0.22),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
        : null;
  }

  final hPad = compact
      ? 10.0
      : (emphasized ? 14.0 : 12.0);
  final vPad = compact
      ? 8.0
      : (emphasized ? 12.0 : 10.0);
  final radius = compact
      ? 10.0
      : (departmentTotalStripe ? 10.0 : 12.0);

  return Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(
      horizontal: hPad,
      vertical: vPad,
    ),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(radius),
      border: useDeptStatusTint
          ? null
          : Border.all(
              color: borderColor,
              width: borderW,
            ),
      boxShadow: compact || departmentTotalStripe || useDeptStatusTint
          ? null
          : boxShadow,
    ),
    child: child,
  );
}

String? _ordersRequestedPaymentLabelForInvoice(
  bool? isCorporate,
  Set<PaymentMethod> methods,
) {
  if (isCorporate == true) {
    if (methods.isEmpty) return 'Corporate';
    if (methods.length > 1) {
      return 'Corporate — Split (${methods.map((p) => p.label).join(' + ')})';
    }
    return 'Corporate — ${methods.first.label}';
  }
  if (methods.length > 1) {
    return 'Split (${methods.map((p) => p.label).join(' + ')})';
  }
  if (methods.length == 1) return methods.first.label;
  return null;
}

/// Confirm payment amount(s) before invoice (always shown for non-corporate from Orders).
///
/// Controllers are owned by [_OrdersSplitPaymentDialog] so they are disposed only after
/// the route is unmounted — disposing in `showDialog`'s `finally` caused
/// `_dependents.isEmpty` when Cancel was pressed.
Future<List<Map<String, dynamic>>?> _showOrdersSplitPaymentDialog(
  BuildContext context, {
  required List<PaymentMethod> methods,
  required double invoiceTotal,
}) {
  return showDialog<List<Map<String, dynamic>>>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _OrdersSplitPaymentDialog(
      methods: methods,
      invoiceTotal: invoiceTotal,
    ),
  );
}

class _OrdersSplitPaymentDialog extends StatefulWidget {
  final List<PaymentMethod> methods;
  final double invoiceTotal;

  const _OrdersSplitPaymentDialog({
    required this.methods,
    required this.invoiceTotal,
  });

  @override
  State<_OrdersSplitPaymentDialog> createState() => _OrdersSplitPaymentDialogState();
}

class _OrdersSplitPaymentDialogState extends State<_OrdersSplitPaymentDialog> {
  late final Map<PaymentMethod, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final pm in widget.methods) pm: TextEditingController(),
    };
    if (widget.methods.length == 1) {
      _controllers[widget.methods.first]!.text =
          widget.invoiceTotal.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double currentSum = 0;
    for (final c in _controllers.values) {
      currentSum += double.tryParse(c.text.trim()) ?? 0.0;
    }
    final remaining = widget.invoiceTotal - currentSum;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.surfaceLight,
      title: Text(
        widget.methods.length > 1 ? 'Split Payment' : 'Payment',
        style: AppTextStyles.h3.copyWith(color: AppColors.secondaryLight),
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Invoice Total', style: AppTextStyles.bodyMedium),
                  Text(
                    '${widget.invoiceTotal.toStringAsFixed(2)} SAR',
                    style: AppTextStyles.bodyLarge
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...widget.methods.map((pm) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 120,
                      child: Row(
                        children: [
                          Icon(pm.icon, size: 20, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          Text(
                            pm.label,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _controllers[pm],
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          isDense: true,
                          labelText: 'Amount (SAR)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (remaining.abs() > 0.05)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  remaining > 0
                      ? 'Remaining: ${remaining.toStringAsFixed(2)} SAR'
                      : 'Exceeds total by ${remaining.abs().toStringAsFixed(2)} SAR',
                  style: TextStyle(
                    color: remaining > 0 ? Colors.orange.shade700 : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: Text(
            'Cancel',
            style: AppTextStyles.button.copyWith(color: AppColors.secondaryLight),
          ),
        ),
        FilledButton(
          onPressed: remaining.abs() > 0.05
              ? null
              : () {
                  final result = <Map<String, dynamic>>[];
                  for (final pm in widget.methods) {
                    result.add({
                      'method': pm.label,
                      'amount':
                          double.tryParse(_controllers[pm]!.text.trim()) ?? 0.0,
                    });
                  }
                  Navigator.pop(context, result);
                },
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryLight,
            foregroundColor: AppColors.onPrimaryLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Confirm amounts'),
        ),
      ],
    );
  }
}

Future<void> _generateInvoiceFromOrdersSummary(
  BuildContext context,
  PosViewModel vm,
  PosOrder order,
) async {
  if (order.isCorporateWalkIn &&
      !order.isCorporateBookingOrder &&
      (order.isCorporateUnapproved ||
          order.isWaitingCorporateApproval ||
          order.isRejectedByCorporate)) {
    ToastService.showError(
      context,
      'Corporate order must be approved before invoicing.',
    );
    return;
  }
  if (!order.meetsCashierInvoicePrerequisites) {
    ToastService.showError(context, 'Order is not ready for invoicing.');
    return;
  }

  final totalAmount = order.draftPosOrderTotalDisplay;

  final isRetailEmployee = _ordersIsRetailWalkInBranchEmployee(vm, order);
  bool? isCorporate;
  Set<PaymentMethod> methodsForDialogLabel = {};
  late final List<Map<String, dynamic>> paymentSplits;

  if (isRetailEmployee) {
    final eid = _ordersBranchEmployeeIdForPayroll(vm, order);
    if (eid == null || eid.isEmpty) {
      ToastService.showError(
        context,
        'Select the branch employee customer first.',
      );
      return;
    }
    isCorporate = false;
    methodsForDialogLabel = {PaymentMethod.employees};
    paymentSplits = <Map<String, dynamic>>[
      <String, dynamic>{
        'method': PaymentMethod.employees.label,
        'amount': totalAmount,
        'employeeIds': <String>[eid],
      },
    ];
  } else {
    isCorporate = vm.invoicePaymentIsCorporate;
    final methods = vm.invoicePaymentMethods;
    if (isCorporate == null || methods.isEmpty) {
      ToastService.showError(
        context,
        'Select customer type and payment method first.',
      );
      return;
    }
    methodsForDialogLabel = methods;
    final amounts = vm.invoicePaymentAmounts;
    if (methods.length == 1) {
      paymentSplits = <Map<String, dynamic>>[
        <String, dynamic>{
          'method': methods.first.label,
          'amount': totalAmount,
        },
      ];
    } else {
      paymentSplits = methods
          .map(
            (m) => <String, dynamic>{
              'method': m.label,
              'amount': (amounts[m] ?? 0),
            },
          )
          .where((p) => (p['amount'] as num) > 0)
          .toList();
      final splitSum = paymentSplits.fold<double>(
        0,
        (s, p) => s + ((p['amount'] as num).toDouble()),
      );
      if ((splitSum - totalAmount).abs() > 0.05) {
        ToastService.showError(
          context,
          'Split amounts must equal total (${totalAmount.toStringAsFixed(2)} SAR).',
        );
        return;
      }
    }
  }

  try {
    final response = await vm.generateInvoice(
      order.id,
      orderForBilling: order,
      isCorporate: isCorporate,
      paymentMethod: paymentSplits.length == 1
          ? paymentSplits.first['method'] as String?
          : null,
      payments: paymentSplits,
    );

    if (!context.mounted) return;
    if (response != null && response.success) {
      await vm.fetchOrders(silent: true, preferredOrderId: order.id);
      if (!context.mounted) return;
      final inv = response.invoice;
      if (inv != null) {
        final fresh = vm.selectedOrder;
        final mcFallback = (fresh != null && fresh.id == order.id)
            ? fresh.maintenanceChecks
            : order.maintenanceChecks;
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => InvoiceDialog(
            invoice: inv,
            maintenanceChecksFallback: mcFallback,
            requestedPaymentMethod:
                _ordersRequestedPaymentLabelForInvoice(
                  isCorporate,
                  methodsForDialogLabel,
                ),
            onDone: () {},
          ),
        );
      } else {
        ToastService.showSuccess(
          context,
          'Invoice was saved, but receipt details were not returned. '
          'The order should appear as invoiced after refresh.',
        );
      }
    } else {
      ToastService.showError(
        context,
        response?.message ?? 'Failed to generate invoice',
      );
    }
  } catch (e) {
    if (context.mounted) ToastService.showError(context, e.toString());
  }
}

class _OrderSummaryPanel extends StatelessWidget {
  final PosViewModel vm;
  const _OrderSummaryPanel({required this.vm});

  @override
  Widget build(BuildContext context) {
    final order = vm.selectedOrder;
    if (order == null) return const SizedBox();

    final activeJobs = order.jobs.where((j) => !j.isCancelledJob).toList();
    final totalJobs = activeJobs.length;
    final completedJobs = activeJobs
        .where((j) {
          final s = j.status.toLowerCase();
          return s == 'completed' || s == 'invoiced' || s == 'edited';
        })
        .length;
    final progress = totalJobs > 0 ? completedJobs / totalJobs : 0.0;
    final allDepartmentsComplete =
        totalJobs > 0 && completedJobs == totalJobs;
    final meetsPrereq = order.meetsCashierInvoicePrerequisites;
    final billingOk = vm.walkInBillingReadyForInvoice(order);
    final hideRetailPaymentPicker =
        _ordersIsRetailWalkInBranchEmployee(vm, order);
    final employeePayrollReady = _ordersRetailEmployeeInvoiceReady(vm, order);
    final paymentOk =
        vm.invoicePaymentSelectionReady ||
            (hideRetailPaymentPicker && employeePayrollReady);
    // Same rule as payment: only block invoicing for corporate **walk-in** while waiting on
    // corporate approval (or rejected). Do not require literal `corporate approved` status
    // (cashier orders often stay `in progress` / `completed` on jobs while invoice is due).
    final corporateApprovedForBilling = !(order.isCorporateWalkIn &&
        !order.isCorporateBookingOrder &&
        (order.isCorporateUnapproved ||
            order.isWaitingCorporateApproval ||
            order.isRejectedByCorporate));
    final canSendForApproval = order.isCorporateWalkIn &&
        !order.isCorporateBookingOrder &&
        order.isCorporateUnapproved;
    final maintenanceChecklistSaved =
        order.isTakeawaySource ||
            (order.maintenanceChecks != null &&
                order.maintenanceChecks!.length ==
                    InvoiceMaintenanceChecklist.rows.length);
    final canGenerateInvoice = allDepartmentsComplete &&
        meetsPrereq &&
        billingOk &&
        paymentOk &&
        corporateApprovedForBilling;

    final orderDiscAmt = _draftOrderLevelDiscountAmount(order);

    final grandTotalFromJobs = activeJobs.fold<double>(
      0.0,
      (sum, job) => sum + _draftJobTotalInclVat(job),
    );
    // Keep footer in sync with department sections shown above.
    final grandTotal = grandTotalFromJobs > 0.0001
        ? grandTotalFromJobs
        : order.draftPosOrderTotalDisplay;

    final detailChildren = <Widget>[];

    if (orderDiscAmt > 0) {
      final dt = (order.totalDiscountType ?? '').toLowerCase();
      final dv = order.totalDiscountValue ?? 0;
      final label = (dt == 'percent' || dt == 'percentage')
          ? 'Order discount (${dv.toStringAsFixed(0)}%)'
          : 'Order discount';
      detailChildren.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              Text(
                '− ${orderDiscAmt.toStringAsFixed(2)} SAR',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.green.shade800,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (detailChildren.isNotEmpty) {
      detailChildren.add(const Divider(height: 20, thickness: 1, color: Color(0xFFE8ECF3)));
    }

    for (var ji = 0; ji < activeJobs.length; ji++) {
      final job = activeJobs[ji];
      detailChildren.add(_DraftDepartmentSection(job: job, sourceOrder: order));
      if (ji < activeJobs.length - 1) {
        detailChildren.add(const SizedBox(height: 14));
        detailChildren.add(const Divider(height: 1, color: Color(0xFFE8ECF3)));
        detailChildren.add(const SizedBox(height: 14));
      }
    }

    final fixedFooter = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canSendForApproval) ...[
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              onPressed: vm.isLoading
                  ? null
                  : () => vm.sendCorporateOrderForApproval(
                        context,
                        orderId: order.id,
                      ),
              icon: const Icon(Icons.send_rounded, size: 16),
              label: const Text(
                'Send for Approval',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryLight,
                foregroundColor: AppColors.onSecondaryLight,
                disabledBackgroundColor: const Color(0xFFCBD5E1),
                disabledForegroundColor: const Color(0xFF64748B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        _orderSummaryHighlightBox(
          emphasized: true,
          secondaryBackground: true,
          compact: true,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: Text(
                  'Grand total',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.onSecondaryLight,
                  ),
                ),
              ),
              Text(
                '${grandTotal.toStringAsFixed(2)} SAR',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryLight,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _OrdersHeaderCustomerPaymentRow(
          vm: vm,
          showPaymentMethodButton: !hideRetailPaymentPicker,
        ),
        const SizedBox(height: 12),
        Consumer<PosViewModel>(
          builder: (context, posVm, _) {
            final invoicingThisOrder =
                posVm.isInvoiceLoading && posVm.loadingOrderId == order.id;
            final checklistButton = Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton(
                  onPressed: posVm.isLoading
                      ? null
                      : () => _showOrdersMaintenanceChecklistDialog(
                            context,
                            order,
                          ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.secondaryLight,
                    side: BorderSide(
                      color: maintenanceChecklistSaved
                          ? Colors.green.shade700
                          : Colors.blueGrey.shade400,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    maintenanceChecklistSaved
                        ? 'Checklist saved (tap to edit)'
                        : 'Checklist (optional)',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.secondaryLight,
                    ),
                  ),
                ),
              ),
            );
            if (!allDepartmentsComplete) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [checklistButton],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                checklistButton,
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: canGenerateInvoice && !invoicingThisOrder
                          ? () => _generateInvoiceFromOrdersSummary(
                                context,
                                posVm,
                                order,
                              )
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryLight,
                        foregroundColor: AppColors.onSecondaryLight,
                        disabledBackgroundColor: const Color(0xFFCBD5E1),
                        disabledForegroundColor: const Color(0xFF64748B),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: invoicingThisOrder
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.onSecondaryLight,
                              ),
                            )
                          : const Text(
                              'Generate Invoice',
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.onSecondaryLight,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );

    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8ECF3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                flex: 2,
                child: Text(
                  'ORDER SUMMARY',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: const Color(0xFFF1F4F9),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF34C759),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$completedJobs/$totalJobs',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: detailChildren,
              ),
            ),
          ),
          fixedFooter,
        ],
      ),
    );
  }
}

class _DraftDepartmentSection extends StatelessWidget {
  final PosOrderJob job;
  final PosOrder? sourceOrder;
  const _DraftDepartmentSection({required this.job, this.sourceOrder});

  static String _fmtCommissionPercent(double p) {
    if (p <= 0) return '0%';
    final text = p == p.roundToDouble()
        ? p.toStringAsFixed(0)
        : p.toStringAsFixed(2);
    return '$text%';
  }

  @override
  Widget build(BuildContext context) {
    final statusForUi = (sourceOrder != null &&
            sourceOrder!.isCorporateWalkIn &&
            sourceOrder!.isRejectedByCorporate)
        ? sourceOrder!.status
        : job.status;
    final techs = job.distinctActiveTechnicians;

    final jobPromoNameRaw = (job.promoCodeName ?? '').trim();
    var jobPromoAmt = job.promoDiscountAmount;
    final useOrderPromoFallback = sourceOrder != null &&
        jobPromoNameRaw.isEmpty &&
        jobPromoAmt <= 0.0001 &&
        sourceOrder!.jobs.where((j) => !j.isCancelledJob).length == 1;
    final displayPromoName = useOrderPromoFallback
        ? (sourceOrder!.promoCodeName ?? '').trim()
        : jobPromoNameRaw;
    final displayPromoAmt = useOrderPromoFallback
        ? (sourceOrder!.promoDiscountAmount ?? 0.0)
        : jobPromoAmt;

    final jobDiscAmt = _draftJobOrderLevelDiscountAmount(job);

    final items = dedupeCashierServiceLinesForPosDisplay(job.items);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _orderSummaryHighlightBox(
          departmentStatusHeaderTint: statusForUi,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  job.department.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                    color: Color(0xFF1E2124),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              posOrdersJobStatusBadge(statusForUi),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          Text(
            'No products or services',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
            ),
          )
        else
          ...List<Widget>.generate(items.length, (i) {
            final item = items[i];
            final discLabel = _draftLineDiscountLabel(item);
            final discAmt = _draftLineDiscountAmountSar(item);
            final lineTot = _draftLineDisplayTotal(job, item);
            final isLast = i == items.length - 1;
            return Padding(
              padding: EdgeInsets.only(
                top: i == 0 ? 0 : 12,
                bottom: isLast ? 10 : 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5, right: 6),
                        child: Icon(
                          Icons.circle,
                          size: 5,
                          color: AppColors.secondaryLight,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item.productName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E2124),
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        lineTot.toStringAsFixed(2),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E2124),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade500,
                        ),
                        children: [
                          TextSpan(
                            text:
                                'Qty ${_draftFmtQty(item.qty)} × ${_draftLineUnitPriceExVat(job, item).toStringAsFixed(2)}',
                          ),
                          TextSpan(
                            text: ' Without VAT',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (discLabel != null &&
                      discAmt != null &&
                      discAmt > 0.0001) ...[
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              discLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          Text(
                            '− ${discAmt.toStringAsFixed(2)} SAR',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        if (techs.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'TECHNICIAN COMMISSION',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                ...techs.map((t) {
                  final name =
                      t.name.trim().isEmpty ? 'Technician' : t.name.trim();
                  final n = techs.length;
                  final previewSar =
                      _draftPerTechnicianCommissionPreviewSar(job, t, n);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _DraftDepartmentSection._fmtCommissionPercent(
                            t.commissionPercent,
                          ),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${previewSar.toStringAsFixed(2)} SAR',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E2124),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 6),
          child: Divider(
            height: 1,
            thickness: 0.5,
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ),
        if (displayPromoAmt > 0.0001) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  displayPromoName.isNotEmpty
                      ? 'Dept promo ($displayPromoName)'
                      : 'Dept promo',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              Text(
                '− ${displayPromoAmt.toStringAsFixed(2)} SAR',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.green.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
        if (jobDiscAmt > 0) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  () {
                    final dt = (job.totalDiscountType ?? '').toLowerCase();
                    final dv = job.totalDiscountValue;
                    if (dt == 'percent' || dt == 'percentage') {
                      return 'Dept discount (${dv.toStringAsFixed(0)}%)';
                    }
                    return 'Dept discount';
                  }(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              Text(
                '− ${jobDiscAmt.toStringAsFixed(2)} SAR',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.green.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
        _draftDeptTotalsPlainTextRows(job),
      ],
    );
  }
}

Widget _orderStripStatusBadge(PosOrder order, {required bool isSelected}) {
  String label = order.jobsAggregateBadgeLabel;
  if (order.isCorporateWalkIn) {
    if (order.isCorporateUnapproved) {
      label = 'UNAPPROVED';
    } else if (order.isWaitingCorporateApproval) {
      label = 'WAITING APPROVAL';
    } else if (order.isCorporateApproved) {
      label = 'CORP APPROVED';
    } else if (order.isRejectedByCorporate) {
      label = 'REJECTED';
    }
  }
  final Color fg;
  final Color bg;

  // Unselected tiles: same soft grey pill for PENDING, COMPLETED, and DRAFT.
  if (!isSelected) {
    fg = AppColors.secondaryLight;
    bg = AppColors.secondaryLight.withValues(alpha: 0.08);
  } else if (label == 'COMPLETED') {
    fg = Colors.white;
    bg = AppColors.secondaryLight;
  } else if (label == 'DRAFT') {
    fg = const Color(0xFF23262D).withValues(alpha: 0.8);
    bg = const Color(0xFF23262D).withValues(alpha: 0.1);
  } else {
    fg = Colors.white;
    bg = AppColors.secondaryLight;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 7,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.2,
        height: 1,
        color: fg,
      ),
    ),
  );
}

class _HorizontalOrderTile extends StatelessWidget {
  final PosOrder order;
  final bool isSelected;
  final VoidCallback onTap;
  /// When true (tablet vertical list), tile spans the column width.
  final bool fullWidth;

  const _HorizontalOrderTile({
    required this.order,
    required this.isSelected,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final activeJobs = order.jobs.where((j) => !j.isCancelledJob).toList();
    final completedActive = activeJobs
        .where((j) {
          final s = j.status.toLowerCase();
          return s == 'completed' || s == 'invoiced' || s == 'edited';
        })
        .length;
    final jobProgressLabel = '$completedActive/${activeJobs.length}';
    final deptNames = order.selectedDepartmentNames;
    final showDeptLine = order.isCorporateWalkIn && deptNames.isNotEmpty;
    final rightMetaLabel = showDeptLine ? '${deptNames.length} dept' : jobProgressLabel;
    final canCancel = posOrderCanCashierCancel(order);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: fullWidth ? double.infinity : 162,
            padding: EdgeInsets.fromLTRB(10, 7, canCancel ? 24 : 10, 7),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFCC247) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? const Color(0xFFFCC247) : const Color(0xFFE8ECF3),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFCC247).withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        '#${order.id.split('-').last.toUpperCase()}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                          color: isSelected ? const Color(0xFF23262D).withOpacity(0.7) : Colors.grey.shade500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _orderStripStatusBadge(order, isSelected: isSelected),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Image.asset(
                      'assets/images/car icon.png',
                      width: 18,
                      height: 18,
                      color: isSelected ? const Color(0xFF23262D) : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        order.vehicle?.plateNo ?? 'No Plate',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 0.5,
                          color: isSelected ? const Color(0xFF23262D) : const Color(0xFF1E2124),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      rightMetaLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: isSelected ? const Color(0xFF23262D) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                if (showDeptLine) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Dept: ${deptNames.join(', ')}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 8,
                      height: 1.1,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? const Color(0xFF23262D).withOpacity(0.78)
                          : const Color(0xFF475569),
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _formatDateForStrip(order),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 7,
                          height: 1,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? const Color(0xFF23262D).withOpacity(0.55) : Colors.grey.shade400,
                        ),
                      ),
                    ),
                    Text(
                      ' · ',
                      style: TextStyle(
                        fontSize: 7,
                        height: 1,
                        color: isSelected ? const Color(0xFF23262D).withOpacity(0.35) : Colors.grey.shade400,
                      ),
                    ),
                    Text(
                      _formatTime(order),
                      style: TextStyle(
                        fontSize: 7,
                        height: 1,
                        color: isSelected ? const Color(0xFF23262D).withOpacity(0.6) : Colors.grey.shade400,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (canCancel)
          Positioned(
            top: 2,
            right: 2,
            child: Material(
              color: Colors.transparent,
              elevation: 0,
              child: InkWell(
                onTap: () => showCashierCancelOrderDialog(context, order.id),
                customBorder: const CircleBorder(),
                child: Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E2124),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _formatDateForStrip(PosOrder order) {
    try {
      final dStr = order.date;
      if (dStr.isNotEmpty) {
        final dt = DateTime.tryParse(dStr);
        if (dt != null) {
          return DateFormat('dd MMM yyyy').format(dt);
        }
      }
      final dt = DateTime.tryParse(order.createdAt);
      if (dt != null) {
        return DateFormat('dd MMM yyyy').format(dt);
      }
    } catch (e) {
      debugPrint('Error formatting date: $e');
    }
    return '—';
  }

  String _formatTime(PosOrder order) {
    try {
      if (order.orderDate.isNotEmpty && order.orderTime.isNotEmpty) {
        // Try parsing combining date and time
        final dateTimeStr = '${order.orderDate} ${order.orderTime}';
        // Check if it's already in a parsable format
        final dt = DateTime.tryParse(dateTimeStr) ?? DateTime.tryParse(order.createdAt);
        if (dt != null) {
          return DateFormat('hh:mm a').format(dt);
        }
        
        // Fallback: manually parse HH:mm if orderTime is just that
        if (order.orderTime.contains(':')) {
          final parts = order.orderTime.split(':');
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          final now = DateTime.now();
          final dt = DateTime(now.year, now.month, now.day, hour, minute);
          return DateFormat('hh:mm a').format(dt);
        }
      }
      
      // Ultimate fallback: check createdAt
      final dt = DateTime.tryParse(order.createdAt);
      if (dt != null) {
        return DateFormat('hh:mm a').format(dt);
      }
    } catch (e) {
      debugPrint('Error formatting time: $e');
    }
    return order.orderTime.isNotEmpty ? order.orderTime : '16:55';
  }
}
