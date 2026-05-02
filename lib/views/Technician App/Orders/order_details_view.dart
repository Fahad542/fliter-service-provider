import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../models/technician_models.dart';
import '../../../models/technician_order_details_model.dart';
import '../technician_view_model.dart';

class OrderDetailsView extends StatefulWidget {
  final TechOrder order;
  const OrderDetailsView({super.key, required this.order});

  @override
  State<OrderDetailsView> createState() => _OrderDetailsViewState();
}

class _OrderDetailsViewState extends State<OrderDetailsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TechAppViewModel>().fetchOrderDetails(widget.order.jobId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TechAppViewModel>(
      builder: (context, vm, child) {
        final order = vm.currentOrderDetail ?? widget.order;
        final bool isLoading = vm.isLoading && vm.currentOrderDetail == null;

        final orderStatus = order.status.toLowerCase();
        final bool isOrderFinalized =
            orderStatus == 'completed' ||
            orderStatus == 'invoiced' ||
            orderStatus == 'success';

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          appBar: AppBar(
            backgroundColor: AppColors.primaryLight,
            elevation: 0,
            toolbarHeight: 70,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.secondaryLight, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            title: const Text('ORDER DETAILS', style: TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
            centerTitle: true,
            actions: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
                child: Center(child: Image.asset('assets/images/global.png', width: 22, height: 22, color: Colors.black, errorBuilder: (_, __, ___) => const Icon(Icons.language, size: 22, color: Colors.black))),
              ),
              const SizedBox(width: 16),
            ],
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildCustomerCard(order),
                      const SizedBox(height: 16),
                      _buildOrderItemsCard(order),
                      const SizedBox(height: 16),
                      if (isOrderFinalized) ...[
                        _buildCommissionCard(order),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
        );
      },
    );
  }



  Widget _buildCustomerCard(TechOrder order) {
    return _buildCard(
      child: Column(
        children: [
          if (order.customerMobile != null && order.customerMobile!.isNotEmpty) ...[
            _buildInfoRow('Mobile', order.customerMobile!),
            _buildDivider(),
          ],
          _buildInfoRow('Vehicle', order.vehicleModel),
          _buildDivider(),
          _buildInfoRow('Plate No', order.plateNumber, isHighlight: true),
        ],
      ),
    );
  }

  Widget _buildOrderItemsCard(TechOrder order) {
    return _buildCard(
      title: 'ORDER DETAILS',
      icon: Icons.assignment_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Department', order.department),
          _buildDivider(),
          if (order.departments.isEmpty)
            _buildInfoRow('Service Type', order.serviceType ?? 'Standard Service')
          else
            _buildServiceTypeSection(order),
          if (order.completedAt != null && order.completedAt!.isNotEmpty) ...[
            _buildDivider(),
            _buildInfoRow('Completed At', order.completedAt!.split('T').first),
          ],
        ],
      ),
    );
  }



  Widget _buildServiceTypeSection(TechOrder order) {
    final allItems = order.departments.expand((dept) => dept.items).toList();
    final products = allItems.where((i) => i.type.toLowerCase() == 'product').toList();
    final services = allItems.where((i) => i.type.toLowerCase() == 'service').toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (services.isNotEmpty) ...[
            const Text('Services', style: TextStyle(color: Colors.black45, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
            const SizedBox(height: 12),
            ...services.map((item) => _buildItemRow(item)),
            if (products.isNotEmpty) const SizedBox(height: 16),
          ],
          if (products.isNotEmpty) ...[
            const Text('Products', style: TextStyle(color: Colors.black45, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
            const SizedBox(height: 12),
            ...products.map((item) => _buildItemRow(item)),
          ],
        ],
      ),
    );
  }

  Widget _buildItemRow(dynamic item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${item.qty}x',
              style: const TextStyle(color: AppColors.primaryLight, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(
                item.name,
                style: const TextStyle(color: Color(0xFF1E2124), fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Text(
              'SAR ${(item.price * item.qty).toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionCard(TechOrder order) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppColors.secondaryLight.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('YOUR COMMISSION', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
              const SizedBox(height: 4),
              Text('SAR ${order.commission.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.primaryLight, fontSize: 24, fontWeight: FontWeight.w900)),
            ],
          ),
          const Icon(Icons.stars_rounded, color: AppColors.primaryLight, size: 40),
        ],
      ),
    );
  }

  Widget _buildCard({String? title, IconData? icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null && icon != null) ...[
            Row(
              children: [
                Icon(icon, size: 16, color: Colors.black38),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(color: Colors.black38, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
              ],
            ),
            const SizedBox(height: 20),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isHighlight ? AppColors.primaryLight : AppColors.secondaryLight,
                fontSize: 14,
                fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.black.withOpacity(0.05), height: 1));
}
