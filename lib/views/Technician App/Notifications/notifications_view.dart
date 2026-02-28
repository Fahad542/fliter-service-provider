import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../models/technician_models.dart';
import '../technician_view_model.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.secondaryLight, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            title: const Text('NOTIFICATIONS', style: TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
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
          body: vm.notifications.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: vm.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = vm.notifications[index];
                    return _buildNotificationCard(notification);
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
          Icon(Icons.notifications_none_rounded, size: 80, color: Colors.black.withOpacity(0.05)),
          const SizedBox(height: 20),
          const Text('No New Alerts', style: TextStyle(color: Colors.black54, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('You are all caught up!', style: TextStyle(color: Colors.black26, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(TechNotification notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.flash_on_rounded, color: AppColors.primaryLight, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      notification.title,
                      style: const TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 14),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.4, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  '2 minutes ago',
                  style: TextStyle(color: Colors.black26, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
