import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../technician_view_model.dart';
import '../Notifications/notifications_view.dart';

class CommissionHistoryView extends StatelessWidget {
  const CommissionHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
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
        title: const Text('COMMISSION HISTORY', style: TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
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
      body: Column(
        children: [
          _buildMonthSelector(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: 10,
              itemBuilder: (context, index) {
                return _buildCommissionItem(index % 2 == 0);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            _buildMonthPill('February 2024', true),
            _buildMonthPill('January 2024', false),
            _buildMonthPill('December 2023', false),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthPill(String name, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryLight : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isSelected ? [] : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
      ),
      child: Text(
        name.toUpperCase(),
        style: TextStyle(
          color: isSelected ? Colors.black87 : Colors.black38,
          fontWeight: FontWeight.w900,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCommissionItem(bool isPaid) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isPaid ? Colors.green : Colors.orange).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isPaid ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                  color: isPaid ? Colors.green : Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ORD-9901', style: TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 14)),
                  Text(isPaid ? 'PAID' : 'PENDING', style: TextStyle(color: isPaid ? Colors.green : Colors.orange, fontSize: 10, fontWeight: FontWeight.w900)),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('SAR 125.00', style: TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 16)),
              Text('Feb 24, 2024', style: TextStyle(color: Colors.black26, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
