import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../models/technician_models.dart';
import '../technician_view_model.dart';

class OrderDetailsView extends StatelessWidget {
  final TechOrder order;
  const OrderDetailsView({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildStatusHeader(),
            const SizedBox(height: 24),
            _buildCustomerCard(),
            const SizedBox(height: 16),
            _buildOrderItemsCard(),
            const SizedBox(height: 16),
            _buildCommissionCard(),
            const SizedBox(height: 32),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(
            order.status.toUpperCase(),
            style: const TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard() {
    return _buildCard(
      title: 'CUSTOMER & VEHICLE',
      icon: Icons.person_outline_rounded,
      child: Column(
        children: [
          _buildInfoRow('Name', order.customerName),
          _buildDivider(),
          _buildInfoRow('Vehicle', order.vehicleModel),
          _buildDivider(),
          _buildInfoRow('Plate No', order.plateNumber, isHighlight: true),
        ],
      ),
    );
  }

  Widget _buildOrderItemsCard() {
    return _buildCard(
      title: 'ORDER DETAILS',
      icon: Icons.assignment_outlined,
      child: Column(
        children: [
          _buildInfoRow('Department', order.department),
          _buildDivider(),
          _buildInfoRow('Service Type', 'Standard Service'),
          _buildDivider(),
          _buildInfoRow('Arrival Time', '10:30 AM'),
        ],
      ),
    );
  }

  Widget _buildCommissionCard() {
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
              Text('SAR ${order.commission.toInt()}', style: const TextStyle(color: AppColors.primaryLight, fontSize: 24, fontWeight: FontWeight.w900)),
            ],
          ),
          const Icon(Icons.stars_rounded, color: AppColors.primaryLight, size: 40),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required IconData icon, required Widget child}) {
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
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.black38),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.black38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 20),
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
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w600)),
          Text(
            value,
            style: TextStyle(
              color: isHighlight ? AppColors.primaryLight : AppColors.secondaryLight,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.black.withOpacity(0.05), height: 1));

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton(
            onPressed: () => _showCompleteConfirmation(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: const Text('MARK AS COMPLETED', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1)),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 64,
          child: OutlinedButton(
            onPressed: () {
              // Handle cancel action
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.secondaryLight,
              side: BorderSide(color: AppColors.secondaryLight.withOpacity(0.2)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: const Text('CANCEL ORDER', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1)),
          ),
        ),
      ],
    );
  }

  void _showCompleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Job Completed?', style: TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900)),
        content: const Text('Are you sure the job is done? This will send the order back to the cashier.', style: TextStyle(color: Colors.black54)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.black38, fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Job Completed! Forwarded to Cashier.'),
                  backgroundColor: AppColors.secondaryLight,
                ),
              );
            },
            child: const Text('YES, COMPLETED', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
