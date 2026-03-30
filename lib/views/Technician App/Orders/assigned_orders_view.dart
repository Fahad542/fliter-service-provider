import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../technician_view_model.dart';
import '../../../models/technician_models.dart';
import 'order_details_view.dart';
import '../Notifications/notifications_view.dart';
import '../../../utils/toast_service.dart';

class AssignedOrdersView extends StatelessWidget {
  final bool isFromDashboard;
  const AssignedOrdersView({super.key, this.isFromDashboard = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<TechAppViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          appBar: AppBar(
            backgroundColor: AppColors.primaryLight,
            elevation: 0,
            toolbarHeight: 70,
            automaticallyImplyLeading: false,
            leadingWidth: 70,
            leading: isFromDashboard
                ? Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Center(
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20,
                            color: AppColors.secondaryLight,
                          ),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: GestureDetector(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryLight,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondaryLight.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.menu_rounded,
                            size: 22,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            title: const Text(
              'ASSIGNED ORDERS',
              style: TextStyle(
                color: AppColors.secondaryLight,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                letterSpacing: 1,
              ),
            ),
            centerTitle: true,
            actions: [
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsView()),
                ),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/notifications.png',
                      width: 22,
                      height: 22,
                      color: Colors.black,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.notifications_rounded,
                        size: 22,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => vm.fetchAssignedOrders(),
            color: AppColors.primaryLight,
            child: vm.isLoading && vm.assignedOrders.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryLight,
                    ),
                  )
                : vm.assignedOrders.isEmpty
                ? SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: _buildEmptyState(context),
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    itemCount: vm.assignedOrders.length,
                    itemBuilder: (context, index) {
                      final order = vm.assignedOrders[index];
                      return _buildOrderCard(context, order, vm);
                    },
                  ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 80,
            color: Colors.black.withOpacity(0.05),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Active Jobs',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Assigned jobs will appear here',
            style: TextStyle(color: Colors.black26, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    TechOrder order,
    TechAppViewModel vm,
  ) {
    final status = order.assignmentStatus.toLowerCase();
    final bool isPending = status == 'pending' || status == 'assigned';
    final bool isAccepted = status == 'accepted';
    final bool isInProgress =
        status == 'in progress' || status == 'in_progress';

    // Normalize and decide which status to show
    final orderStatus = order.status.toLowerCase();
    final bool isOrderFinalized =
        orderStatus == 'completed' ||
        orderStatus == 'invoiced' ||
        orderStatus == 'success';

    final String displayStatus = isOrderFinalized
        ? 'COMPLETED'
        : order.assignmentStatus;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.02)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            vm.fetchOrderDetails(order.jobId);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => OrderDetailsView(order: order)),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order.id,
                      style: TextStyle(
                        color: Colors.orange.shade300,
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                      ),
                    ),
                    _buildStatusBadge(displayStatus),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  order.customerName,
                  style: const TextStyle(
                    color: AppColors.secondaryLight,
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.directions_car_rounded,
                        color: Colors.black38,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${order.vehicleModel} • ',
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text: order.plateNumber,
                              style: TextStyle(
                                color: Colors.orange.shade300,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isOrderFinalized) ...[
                      _buildInfoColumn(
                        'COMMISSION',
                        'SAR ${order.commission.toStringAsFixed(2)}',
                        isPrimary: true,
                      ),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoColumn(
                          'DEPARTMENT',
                          order.department.isEmpty
                              ? 'General'
                              : order.department,
                        ),
                        _buildInfoColumn(
                          'VALUE',
                          'SAR ${order.totalValue.toStringAsFixed(2)}',
                        ),
                        const SizedBox(
                          width: 1,
                        ), // Invisible spacer to balance the Row
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (isPending)
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          'CANCEL',
                          AppColors.secondaryLight,
                          Colors.white,
                          () async {
                            final success = await vm.cancelOrder(order.jobId);
                            if (!context.mounted) return;
                            if (success) {
                              ToastService.showSuccess(
                                context,
                                'Order cancelled',
                              );
                            } else {
                              ToastService.showError(
                                context,
                                vm.cancelMessage ?? 'Failed to cancel order',
                              );
                            }
                          },
                          isLoading: vm.cancellingJobId == order.jobId,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          'ACCEPT',
                          AppColors.primaryLight,
                          Colors.black87,
                          () async {
                            final success = await vm.acceptOrder(order.jobId);
                            if (!context.mounted) return;
                            if (success) {
                              ToastService.showSuccess(
                                context,
                                'Order accepted successfully',
                              );
                            } else {
                              ToastService.showError(
                                context,
                                vm.acceptMessage ?? 'Failed to accept order',
                              );
                            }
                          },
                          isLoading: vm.acceptingJobId == order.jobId,
                        ),
                      ),
                    ],
                  )
                else if (isAccepted)
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          'VIEW DETAILS',
                          AppColors.secondaryLight,
                          Colors.white,
                          () {
                            vm.fetchOrderDetails(order.jobId);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OrderDetailsView(order: order),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          'START',
                          AppColors.primaryLight,
                          Colors.black87,
                          () async {
                            final success = await vm.startOrder(order.jobId);
                            if (!context.mounted) return;
                            if (success) {
                              ToastService.showSuccess(
                                context,
                                'Job started successfully',
                              );
                              vm.fetchOrderDetails(order.jobId);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      OrderDetailsView(order: order),
                                ),
                              );
                            } else {
                              ToastService.showError(
                                context,
                                vm.startMessage ?? 'Failed to start job',
                              );
                            }
                          },
                          isLoading: vm.startingJobId == order.jobId,
                        ),
                      ),
                    ],
                  )
                else if (isInProgress)
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          'VIEW DETAILS',
                          AppColors.secondaryLight,
                          Colors.white,
                          () {
                            vm.fetchOrderDetails(order.jobId);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OrderDetailsView(order: order),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          'TASK COMPLETE',
                          AppColors.primaryLight,
                          Colors.black87,
                          () async {
                            final success = await vm.completeOrder(order.jobId);
                            if (!context.mounted) return;
                            if (success) {
                              ToastService.showSuccess(
                                context,
                                'Job completed successfully',
                              );
                            } else {
                              ToastService.showError(
                                context,
                                vm.completeMessage ?? 'Failed to complete job',
                              );
                            }
                          },
                          isLoading: vm.completingJobId == order.jobId,
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          'VIEW DETAILS',
                          AppColors.secondaryLight,
                          Colors.white,
                          () {
                            vm.fetchOrderDetails(order.jobId);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OrderDetailsView(order: order),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    status = status.toUpperCase();
    Color textColor = Colors.orange.shade600;
    Color bgColor = Colors.orange.shade50;

    if (status == 'COMPLETED' || status == 'SUCCESS' || status == 'INVOICED') {
      textColor = Colors.green.shade700;
      bgColor = Colors.green.shade50;
      // Overwrite display text to just "COMPLETED" for consistency
      status = 'COMPLETED';
    } else if (status == 'COMPLETED BY TECHNICIAN' ||
        status == 'COMPLETED_BY_TECHNICIAN') {
      textColor = Colors.orange.shade800;
      bgColor = Colors.orange.shade50;
      status = 'COMPLETED BY TECHNICIAN';
    } else if (status == 'TASK COMPLETE') {
      textColor = Colors.orange.shade700;
      bgColor = Colors.orange.shade50;
    } else if (status == 'IN PROGRESS' || status == 'IN_PROGRESS') {
      textColor = Colors.blue.shade600;
      bgColor = Colors.blue.shade50;
    } else if (status == 'ACCEPTED') {
      textColor = Colors.teal.shade600;
      bgColor = Colors.teal.shade50;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInfoColumn(
    String label,
    String value, {
    bool isPrimary = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black26,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: isPrimary ? Colors.green.shade500 : AppColors.secondaryLight,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    Color bg,
    Color text,
    VoidCallback onTap, {
    bool isLoading = false,
    Color? borderColor,
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: borderColor != null
              ? Border.all(color: borderColor, width: 1.2)
              : null,
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: text, strokeWidth: 2),
                )
              : Text(
                  label,
                  style: TextStyle(
                    color: text,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }
}
