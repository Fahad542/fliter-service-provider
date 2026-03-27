import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../utils/app_colors.dart';

class LockerNotificationsView extends StatelessWidget {
  const LockerNotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      _NotifyItem(
        title: 'New Collection Request',
        body: 'Riyadh Central branch has a new cash closing of SAR 5,200.',
        time: DateTime.now().subtract(const Duration(minutes: 15)),
        type: 'new',
        isUnread: true,
      ),
      _NotifyItem(
        title: 'Collection Approved',
        body: 'Your collection (COL-882) for Jeddah North was approved by Admin.',
        time: DateTime.now().subtract(const Duration(hours: 2)),
        type: 'status',
        isUnread: false,
      ),
      _NotifyItem(
        title: 'Difference Alert',
        body: 'A short difference of SAR 200 was recorded for Dammam East.',
        time: DateTime.now().subtract(const Duration(hours: 5)),
        type: 'warning',
        isUnread: false,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: AppColors.primaryLight,
        elevation: 0,
        toolbarHeight: 72,
        title: const Text('NOTIFICATIONS', style: TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 2)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.secondaryLight, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final item = notifications[index];
          return _buildPremiumNotifyCard(item);
        },
      ),
    );
  }

  Widget _buildPremiumNotifyCard(_NotifyItem item) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: item.isUnread ? AppColors.secondaryLight.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getIconColor(item.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(_getIcon(item.type), color: _getIconColor(item.type), size: 22),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.title.toUpperCase(),
                      style: const TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1),
                    ),
                    if (item.isUnread)
                      Container(
                        width: 8, height: 8, 
                        decoration: const BoxDecoration(color: Color(0xFFFCC247), shape: BoxShape.circle),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.body,
                  style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.w600, height: 1.4),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, color: Colors.black.withOpacity(0.2), size: 12),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('hh:mm A').format(item.time),
                      style: TextStyle(color: Colors.black.withOpacity(0.2), fontSize: 10, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getIconColor(String type) {
    if (type == 'new') return Colors.blue;
    if (type == 'warning') return Colors.red;
    return Colors.teal;
  }

  IconData _getIcon(String type) {
    if (type == 'new') return Icons.add_moderator_rounded;
    if (type == 'warning') return Icons.gpp_maybe_rounded;
    return Icons.gpp_good_rounded;
  }
}

class _NotifyItem {
  final String title;
  final String body;
  final DateTime time;
  final String type;
  final bool isUnread;

  _NotifyItem({required this.title, required this.body, required this.time, required this.type, required this.isUnread});
}
