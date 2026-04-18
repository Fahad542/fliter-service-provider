import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'dart:ui';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/toast_service.dart';
import '../Home Screen/pos_view_model.dart';
import '../Add Customer Screen/pos_add_customer_view.dart';
import '../Department/department_view_model.dart';
import '../Department/pos_department_view.dart';
import '../Product Grid/pos_product_grid_view.dart';
import '../Technician Assignment/pos_technician_assignment_view.dart';
import '../../../models/pos_order_model.dart';
import '../../../widgets/pos_widgets.dart';
import '../../../widgets/pos_shell_rail_layout.dart';
import 'pos_order_review_view.dart';
import 'pos_invoice_payment_dialog.dart';

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
      appBar: const PosScreenAppBar(
        title: 'Orders',
        showBackButton: false,
      ),
      body: Stack(
        children: [
          wrapPosShellRailBody(
            context,
            isTablet
                ? _OrdersTabletLayout(vm: vm)
                : _buildMobileView(vm),
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
    // Basic list for mobile, tapping opens detail screen (existing flow)
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: PosSearchBar(
            hintText: 'Search orders...',
            onChanged: (val) => vm.setOrderSearchQuery(val),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: vm.orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = vm.orders[index];
              return OrderItemCard(order: order, isTablet: false);
            },
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

  static const double _kOrderListColumnWidth = 184;

  Widget _buildTab(String title) {
    final isSelected = _selectedTab == title;
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          setState(() => _selectedTab = title);
        }
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
            setState(() {
              _selectedTab = selectedIsCompleted ? 'Completed' : 'Pending';
            });
          }
        });
      }
      _lastSelectedOrderId = selected.id;
      _lastSelectedOrderBadge = currentBadge;
    }

    final filteredOrders = vm.orders.where((order) {
      final isCancelled = order.status.toLowerCase() == 'cancelled';
      if (isCancelled) return false;
      if (_selectedTab == 'All') return true;
      final isCompleted = order.jobsAggregateBadgeLabel == 'COMPLETED';
      if (_selectedTab == 'Pending') {
        return !isCompleted;
      } else {
        return isCompleted;
      }
    }).toList();

    const draftColumnWidth = 392.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 12, 20, 10),
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
                    _OrdersNewOrderButton(),
                  ],
                ),
              ),
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
                          child: filteredOrders.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      'No ${_selectedTab.toLowerCase()} orders found',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                )
                              : ListView.separated(
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
                    const VerticalDivider(width: 1, color: Color(0xFFE8ECF3)),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ColoredBox(
                            color: Colors.white,
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(12, 8, 20, 12),
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
                          const Divider(
                              height: 1, color: Color(0xFFE8ECF3)),
                          Expanded(
                            child: _OrderDetailPanel(vm: vm),
                          ),
                        ],
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
            child: vm.selectedOrder == null
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

/// Add customer + Choose payment (order summary footer; above Generate Invoice). Disabled when no order selected.
class _OrdersHeaderCustomerPaymentRow extends StatelessWidget {
  final PosViewModel vm;
  const _OrdersHeaderCustomerPaymentRow({required this.vm});

  @override
  Widget build(BuildContext context) {
    final order = vm.selectedOrder;
    final enabled = order != null;

    Future<void> openAddCustomer() async {
      if (order == null) return;
      if (vm.isStandardWalkInOrderForBilling(order)) {
        final result = await showDialog<WalkInInvoiceFormResult?>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => WalkInInvoiceDetailsDialog(
            order: order,
            posVm: vm,
          ),
        );
        if (!context.mounted) return;
        if (result != null) {
          vm.updateWalkInBillingContact(
            name: result.name,
            mobile: result.mobile,
            vat: result.vat,
            vehicleNumber: result.vehicleNumber,
            vin: result.vin,
            make: result.make,
            model: result.model,
            odometer: result.odometer,
            year: result.year,
            color: result.color,
          );
          ToastService.showSuccess(context, 'Customer details saved');
        }
        return;
      }
      vm.setCustomerData(
        name: order.customer?.name ?? order.customerName,
        vat: order.customer?.vatNumber ?? '',
        mobile: order.customer?.mobile ?? '',
        vehicleNumber: order.plateNumber.isNotEmpty
            ? order.plateNumber
            : vm.vehicleNumber,
        vinNumber: order.vehicle?.vin ?? '',
        make: order.vehicle?.make ?? '',
        model: order.vehicle?.model ?? '',
        odometer: order.odometerReading,
        previousOrderId: order.id,
      );
      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) => const PosAddCustomerView(),
        ),
      );
    }

    Future<void> openPayment() async {
      if (order == null) return;
      final result = await showInvoicePaymentChoiceDialog(
        context,
        initialIsCorporate: vm.invoicePaymentIsCorporate,
        initialPayments:
            vm.invoicePaymentIsCorporate != null ? vm.invoicePaymentMethods : null,
      );
      if (!context.mounted) return;
      if (result != null) {
        vm.setInvoicePaymentPreferences(
          isCorporate: result.isCorporate,
          payments: result.payments,
        );
        ToastService.showSuccess(context, 'Payment method saved');
      }
    }

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: enabled ? openAddCustomer : null,
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
              'Add customer details',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                height: 1.15,
                color: AppColors.onPrimaryLight,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ElevatedButton(
            onPressed: enabled ? openPayment : null,
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
              'Choose payment method',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
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

class _OrdersNewOrderButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFCC247),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFCC247).withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: Color(0xFF23262D), size: 20),
              SizedBox(width: 8),
              Text(
                'New Order',
                style: TextStyle(
                  color: Color(0xFF23262D),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderDetailPanel extends StatelessWidget {
  final PosViewModel vm;
  const _OrderDetailPanel({required this.vm});

  @override
  Widget build(BuildContext context) {
    final order = vm.selectedOrder;

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

              final items = [
                for (final j in order.jobs.where((j) => !j.isCancelledJob))
                  _JobCard(order: order, job: j),
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
  for (final item in job.items) {
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
    make: order.vehicle?.make ?? '',
    model: order.vehicle?.model ?? '',
    odometer: order.odometerReading,
    previousOrderId: order.id,
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
  if (job.items.isEmpty) {
    ToastService.showError(
      context,
      'Add at least one product or service before completing this job.',
    );
    return;
  }

  // Ensure technicians are assigned
  if (job.distinctActiveTechnicians.isEmpty) {
    ToastService.showError(
      context,
      'Assign at least one technician before completing this job.',
    );
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
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFD32F2F), size: 28),
            ),
            const SizedBox(height: 18),
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
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isBusy ? null : () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.secondaryLight,
                      elevation: 0,
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: const Text('NO', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5, fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isBusy ? null : _handleConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: _isBusy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
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

  static String _formatTechnicianCommission(JobTechnician t) {
    if (t.commissionPercent > 0) {
      final p = t.commissionPercent;
      final text = p == p.roundToDouble()
          ? p.toStringAsFixed(0)
          : p.toStringAsFixed(2);
      return '$text%';
    }
    if (t.commissionAmount > 0) {
      return 'SAR ${t.commissionAmount.toStringAsFixed(2)}';
    }
    return '—';
  }

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
    var st = job.status.toLowerCase().trim();
    if (st == 'complete') st = 'completed';
    if (st == 'job_edited') st = 'edited';
    final isInvoiced = st == 'invoiced';
    final isComplete = st == 'completed';
    final isEdited = st == 'edited';
    final isCancelled = job.isCancelledJob;
    final isLocked = isInvoiced || isCancelled;

    final jobLineItems = job.items;
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
                    color: isComplete ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getDepartmentIcon(job.department),
                    color: isComplete ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
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
                      _buildStatusBadge(job.status),
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
                            enabled: !isCancelled && !completing,
                            onTap: () => _onCancelJob(context, job),
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
                          enabled: !completing,
                          onTap: (isComplete || isEdited)
                              ? () => _openJobProductGrid(
                                    context,
                                    order,
                                    job,
                                  )
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

  Widget _buildStatusBadge(String statusRaw) {
    final s = statusRaw.toLowerCase().replaceAll(' ', '_');
    final isComplete = s == 'completed' || s == 'invoiced';
    final isEdited = s == 'edited';
    final isCancelled = s == 'cancelled' || s == 'canceled';
    final isInProgress =
        s == 'in_progress' || s == 'inprogress' || statusRaw.toLowerCase() == 'in progress';

    late Color fg;
    late Color bg;
    late Color border;
    late String label;
    if (isCancelled) {
      fg = Colors.white;
      bg = const Color(0xFFD32F2F);
      border = const Color(0xFFB71C1C);
      label = 'CANCELLED';
    } else if (isComplete) {
      fg = const Color(0xFF4CAF50);
      bg = const Color(0xFF4CAF50).withOpacity(0.1);
      border = const Color(0xFF4CAF50).withOpacity(0.2);
      label = 'COMPLETE';
    } else if (isEdited) {
      fg = const Color(0xFF3949AB);
      bg = const Color(0xFF3949AB).withOpacity(0.1);
      border = const Color(0xFF3949AB).withOpacity(0.2);
      label = 'EDITED';
    } else if (isInProgress) {
      fg = const Color(0xFF1976D2);
      bg = const Color(0xFF2196F3).withOpacity(0.1);
      border = const Color(0xFF2196F3).withOpacity(0.2);
      label = 'IN PROGRESS';
    } else {
      fg = const Color(0xFFFF9800);
      bg = const Color(0xFFFF9800).withOpacity(0.1);
      border = const Color(0xFFFF9800).withOpacity(0.2);
      label = 'PENDING';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: fg,
          letterSpacing: 0.5,
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

double _draftLineDisplayTotal(PosOrderJobItem item) {
  if (item.lineTotal > 0) return item.lineTotal;
  return item.qty * item.unitPrice;
}

/// Readable job status next to department name (e.g. `in_progress` → `In progress`).
String _summaryFormatJobStatus(String raw) {
  final t = raw.trim().replaceAll('_', ' ');
  if (t.isEmpty) return '—';
  return t
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
      .join(' ');
}

String _summaryNormalizeJobStatusKey(String raw) {
  return raw.trim().toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');
}

/// Badge colors: edited → green, in progress → yellow, pending → orange; else secondary.
({Color background, Color foreground}) _summaryJobStatusBadgeColors(
    String raw) {
  final k = _summaryNormalizeJobStatusKey(raw);
  if (k == 'edited' || k == 'job_edited') {
    return (
      background: const Color(0xFF34C759),
      foreground: Colors.white,
    );
  }
  if (k == 'in_progress' || k == 'inprogress') {
    return (
      background: AppColors.primaryLight,
      foreground: AppColors.onPrimaryLight,
    );
  }
  if (k == 'pending') {
    return (
      background: const Color(0xFFFF9500),
      foreground: Colors.white,
    );
  }
  return (
    background: AppColors.secondaryLight,
    foreground: AppColors.onSecondaryLight,
  );
}

String? _draftLineDiscountCaption(PosOrderJobItem item) {
  final dv = item.discountValue ?? 0;
  if (dv <= 0) return null;
  final t = (item.discountType ?? '').toLowerCase();
  if (t == 'percent' || t == 'percentage') {
    final s = dv == dv.roundToDouble() ? dv.toInt().toString() : dv.toStringAsFixed(1);
    return 'Line discount: $s%';
  }
  return 'Line discount: ${dv.toStringAsFixed(2)} SAR';
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

/// Highlight strip for department name / dept total / grand total in the order summary column.
/// [secondaryBackground] uses [AppColors.secondaryLight] for the **grand total** row.
/// [departmentTotalStripe] uses a light neutral strip so it does not match the grand total bar.
Widget _orderSummaryHighlightBox({
  required Widget child,
  bool emphasized = false,
  bool secondaryBackground = false,
  /// Tighter padding & radius (e.g. grand total row).
  bool compact = false,
  /// Per-job "Department total" row — light background, distinct from grand total.
  bool departmentTotalStripe = false,
}) {
  final Color bg;
  final Color borderColor;
  final double borderW;
  if (departmentTotalStripe) {
    bg = const Color(0xFFEFF1F5);
    borderColor = const Color(0xFFD1D9E6);
    borderW = 1;
  } else if (secondaryBackground) {
    bg = AppColors.secondaryLight;
    borderColor = AppColors.primaryLight.withValues(alpha: emphasized ? 0.55 : 0.4);
    borderW = emphasized ? 2 : 1.5;
  } else {
    bg = emphasized
        ? const Color(0xFFFFF3D6)
        : const Color(0xFFFFF9E8);
    borderColor =
        const Color(0xFFFCC247).withValues(alpha: emphasized ? 0.95 : 0.55);
    borderW = emphasized ? 2 : 1.5;
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
      border: Border.all(
        color: borderColor,
        width: borderW,
      ),
      boxShadow: compact || departmentTotalStripe
          ? null
          : emphasized && !secondaryBackground
              ? [
                  BoxShadow(
                    color: const Color(0xFFFCC247).withValues(alpha: 0.22),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : emphasized && secondaryBackground
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
    ),
    child: child,
  );
}

String? _posOrdersInvoiceFooterHint({
  required bool allDepartmentsComplete,
  required PosOrder order,
  required PosViewModel vm,
  required bool meetsPrereq,
  required bool billingOk,
  required bool paymentOk,
}) {
  if (!allDepartmentsComplete) return null;
  if (!meetsPrereq) {
    return 'Add at least one product or service and one technician to each job before generating an invoice.';
  }
  if (!billingOk) {
    return 'Vehicle plate, customer name, and mobile are required. Tap Add customer details.';
  }
  if (!paymentOk) {
    return 'Select customer type and a payment method (Choose payment method).';
  }
  return null;
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
    final paymentOk = vm.invoicePaymentSelectionReady;
    final canGenerateInvoice = allDepartmentsComplete &&
        meetsPrereq &&
        billingOk &&
        paymentOk;
    final invoiceFooterHint = _posOrdersInvoiceFooterHint(
      allDepartmentsComplete: allDepartmentsComplete,
      order: order,
      vm: vm,
      meetsPrereq: meetsPrereq,
      billingOk: billingOk,
      paymentOk: paymentOk,
    );

    final orderPromoName = (order.promoCodeName ?? '').trim();
    final orderPromoAmt = order.promoDiscountAmount ?? 0;
    final orderDiscAmt = _draftOrderLevelDiscountAmount(order);

    final grandTotal = order.draftPosOrderTotalDisplay;

    final detailChildren = <Widget>[];

    if (orderPromoName.isNotEmpty || orderPromoAmt > 0) {
      detailChildren.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ORDER PROMO',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                  color: Colors.grey.shade500,
                ),
              ),
              if (orderPromoName.isNotEmpty)
                Text(
                  orderPromoName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E2124),
                  ),
                ),
              if (orderPromoAmt > 0)
                Text(
                  '− ${orderPromoAmt.toStringAsFixed(2)} SAR',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.green.shade700,
                  ),
                ),
            ],
          ),
        ),
      );
    }

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
      detailChildren.add(_DraftDepartmentSection(job: job));
      if (ji < activeJobs.length - 1) {
        detailChildren.add(const SizedBox(height: 14));
        detailChildren.add(const Divider(height: 1, color: Color(0xFFE8ECF3)));
        detailChildren.add(const SizedBox(height: 14));
      }
    }

    if (activeJobs.any((j) => j.vatAmount > 0)) {
      detailChildren.add(
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            'Includes VAT where shown on jobs (see department lines).',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              height: 1.25,
              color: Colors.grey.shade500,
            ),
          ),
        ),
      );
    }

    final fixedFooter = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
        _OrdersHeaderCustomerPaymentRow(vm: vm),
        if (allDepartmentsComplete) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: canGenerateInvoice
                  ? () {
                      Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              PosOrderReviewView(order: order),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryLight,
                foregroundColor: AppColors.onSecondaryLight,
                disabledBackgroundColor: const Color(0xFFCBD5E1),
                disabledForegroundColor: const Color(0xFF64748B),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text(
                'Generate Invoice',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSecondaryLight,
                ),
              ),
            ),
          ),
          if (invoiceFooterHint != null) ...[
            const SizedBox(height: 8),
            Text(
              invoiceFooterHint,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                height: 1.35,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
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
  const _DraftDepartmentSection({required this.job});

  @override
  Widget build(BuildContext context) {
    final techs = job.distinctActiveTechnicians;
    final techLabel = techs.isEmpty
        ? 'No technicians assigned'
        : techs.map((t) => t.name.trim()).where((n) => n.isNotEmpty).join(', ');

    final jobPromoName = (job.promoCodeName ?? '').trim();
    final jobPromoAmt = job.promoDiscountAmount;
    final jobDiscAmt = _draftJobOrderLevelDiscountAmount(job);

    final items = job.items;
    final statusBadge = _summaryJobStatusBadgeColors(job.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _orderSummaryHighlightBox(
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusBadge.background,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _summaryFormatJobStatus(job.status),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: statusBadge.foreground,
                    letterSpacing: 0.15,
                    height: 1.15,
                  ),
                ),
              ),
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
          ...items.map((item) {
            final cap = _draftLineDiscountCaption(item);
            final lineTot = _draftLineDisplayTotal(item);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                  Text(
                    'Qty ${_draftFmtQty(item.qty)} × ${item.unitPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  if (cap != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      cap,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        const SizedBox(height: 6),
        if (jobPromoName.isNotEmpty || jobPromoAmt > 0) ...[
          Text(
            'Dept promo',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: Colors.grey.shade500,
            ),
          ),
          if (jobPromoName.isNotEmpty)
            Text(
              jobPromoName,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E2124),
              ),
            ),
          if (jobPromoAmt > 0)
            Text(
              '− ${jobPromoAmt.toStringAsFixed(2)} SAR',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.green.shade700,
              ),
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.engineering_outlined, size: 14, color: Colors.grey.shade500),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                techLabel,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _orderSummaryHighlightBox(
          departmentTotalStripe: true,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Department total',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade800,
                ),
              ),
              Text(
                '${job.totalAmount.toStringAsFixed(2)} SAR',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.secondaryLight,
                ),
              ),
            ],
          ),
        ),
        if (job.vatAmount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'VAT ${job.vatPercent.toStringAsFixed(0)}%: ${job.vatAmount.toStringAsFixed(2)} SAR',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
              ),
            ),
          ),
      ],
    );
  }
}

Widget _orderStripStatusBadge(PosOrder order, {required bool isSelected}) {
  final label = order.jobsAggregateBadgeLabel;
  final Color fg;
  final Color bg;

  if (label == 'COMPLETED') {
    fg = Colors.white;
    bg = AppColors.secondaryLight;
  } else if (!isSelected) {
    fg = AppColors.secondaryLight;
    bg = AppColors.secondaryLight.withValues(alpha: 0.08);
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
                      jobProgressLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: isSelected ? const Color(0xFF23262D) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
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
