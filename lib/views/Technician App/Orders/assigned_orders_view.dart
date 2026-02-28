import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../technician_view_model.dart';
import '../../../models/technician_models.dart';
import 'order_details_view.dart';
import '../Notifications/notifications_view.dart';

class AssignedOrdersView extends StatelessWidget {
  const AssignedOrdersView({super.key});

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
            leading: Container(
              margin: const EdgeInsets.only(left: 12),
              width: 40, height: 40,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
              child: Center(child: Image.asset('assets/images/global.png', width: 22, height: 22, color: Colors.black, errorBuilder: (_, __, ___) => const Icon(Icons.language, size: 22, color: Colors.black))),
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            title: const Text('ASSIGNED ORDERS', style: TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
            centerTitle: true,
            actions: [
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsView())),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
                  child: Center(child: Image.asset('assets/images/notifications.png', width: 22, height: 22, color: Colors.black, errorBuilder: (_, __, ___) => const Icon(Icons.notifications_rounded, size: 22, color: Colors.black))),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
          body: vm.assignedOrders.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: vm.assignedOrders.length,
                  itemBuilder: (context, index) {
                    final order = vm.assignedOrders[index];
                    return _buildOrderCard(context, order);
                  },
                ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 80, color: Colors.black.withOpacity(0.05)),
          const SizedBox(height: 20),
          const Text('No Active Jobs', style: TextStyle(color: Colors.black54, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Assigned jobs will appear here', style: TextStyle(color: Colors.black26, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, TechOrder order) {
    final bool isPending = order.status == 'Pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8)),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order.id,
                      style: const TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.w900, fontSize: 14),
                    ),
                    _buildStatusBadge(order.status),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  order.customerName,
                  style: const TextStyle(color: AppColors.secondaryLight, fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.directions_car_rounded, color: Colors.black38, size: 14),
                    const SizedBox(width: 8),
                    Text(
                      '${order.vehicleModel} • ',
                      style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      order.plateNumber,
                      style: const TextStyle(color: AppColors.primaryLight, fontSize: 13, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoColumn('DEPARTMENT', order.department),
                    _buildInfoColumn('VALUE', 'SAR ${order.totalValue.toInt()}'),
                    _buildInfoColumn('COMMISSION', 'SAR ${order.commission.toInt()}', isPrimary: true),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.03),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Row(
              children: [
                if (isPending)
                  Expanded(
                    child: _buildActionButton('ACCEPT', AppColors.primaryLight, Colors.black87, () {}),
                  ),
                if (isPending) const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'VIEW DETAILS',
                    AppColors.secondaryLight,
                    Colors.white,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailsView(order: order))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.orange;
    if (status == 'In Progress') color = Colors.blue;
    if (status == 'Completed') color = Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, {bool isPrimary = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.black26, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: isPrimary ? Colors.green : AppColors.secondaryLight,
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, Color bg, Color text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(color: text, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5),
          ),
        ),
      ),
    );
  }
}
