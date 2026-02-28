import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../technician_view_model.dart';
import '../Notifications/notifications_view.dart';

class TechPerformanceView extends StatelessWidget {
  const TechPerformanceView({super.key});

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
        title: const Text('DAILY PERFORMANCE', style: TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCards(),
            const SizedBox(height: 32),
            _buildSectionTitle('EARNING TREND'),
            const SizedBox(height: 16),
            _buildChartPlaceholder(),
            const SizedBox(height: 32),
            _buildSectionTitle('RECENT JOBS'),
            const SizedBox(height: 16),
            _buildHistoryList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(child: _buildSimpleStat('TOTAL JOBS', '12', Icons.assignment_turned_in_rounded, Colors.blue)),
        const SizedBox(width: 16),
        Expanded(child: _buildSimpleStat('EARNED', 'SAR 420', Icons.stars_rounded, Colors.green)),
      ],
    );
  }

  Widget _buildSimpleStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(color: AppColors.secondaryLight, fontSize: 24, fontWeight: FontWeight.w900)),
          Text(label, style: const TextStyle(color: Colors.black38, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildChartPlaceholder() {
    return Container(
      height: 220,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Weekly Overview', style: TextStyle(color: AppColors.secondaryLight, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: const Text('+8.4%', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBarItem('Sun', 0.4),
                _buildBarItem('Mon', 0.6),
                _buildBarItem('Tue', 0.8),
                _buildBarItem('Wed', 0.5),
                _buildBarItem('Thu', 0.9, isSelected: true),
                _buildBarItem('Fri', 0.3),
                _buildBarItem('Sat', 0.7),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarItem(String day, double heightFactor, {bool isSelected = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: 14,
          height: 100 * heightFactor,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : AppColors.primaryLight.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          day,
          style: TextStyle(
            color: isSelected ? AppColors.secondaryLight : Colors.black26,
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withOpacity(0.03)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Toyota Camry', style: TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w800, fontSize: 14)),
                      Text('Feb 24, 2:30 PM', style: TextStyle(color: Colors.black26, fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
              const Text('SAR 45', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w900, fontSize: 16)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Colors.black38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
    );
  }
}
