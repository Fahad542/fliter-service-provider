import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../models/workshop_owner_models.dart';
import '../widgets/owner_app_bar.dart';

class OwnerNotificationsView extends StatefulWidget {
  final bool showBackButton;
  const OwnerNotificationsView({super.key, this.showBackButton = false});

  @override
  State<OwnerNotificationsView> createState() => _OwnerNotificationsViewState();
}

class _OwnerNotificationsViewState extends State<OwnerNotificationsView> {
  final List<OwnerNotification> _notifications = [
    OwnerNotification(id: '1', title: 'Expense Submitted', message: 'Ali Hassan submitted an expense of SAR 450 for approval.', type: 'expense', timestamp: DateTime.now().subtract(const Duration(minutes: 15))),
    OwnerNotification(id: '2', title: 'Low Stock Alert', message: 'Engine Oil 5W-30 is critically low at Riyadh Main (3 units left).', type: 'stock', timestamp: DateTime.now().subtract(const Duration(hours: 1)), isRead: true),
    OwnerNotification(id: '3', title: 'Corporate Payment Received', message: 'Gulf Corp. LLC paid SAR 15,000 for January bill.', type: 'payment', timestamp: DateTime.now().subtract(const Duration(hours: 3))),
    OwnerNotification(id: '4', title: 'Locker Difference', message: 'Jeddah Center – SAR 50 difference detected at EOD closing.', type: 'locker', timestamp: DateTime.now().subtract(const Duration(hours: 5))),
    OwnerNotification(id: '5', title: 'Invoice Approved', message: 'Purchase order PO-002 has been approved and stock updated.', type: 'invoice', timestamp: DateTime.now().subtract(const Duration(hours: 8)), isRead: true),
    OwnerNotification(id: '6', title: 'Overdue Bill Alert', message: 'Saudi Aramco Corp. bill of SAR 38,000 is now overdue.', type: 'payment', timestamp: DateTime.now().subtract(const Duration(days: 1))),
  ];

  @override
  Widget build(BuildContext context) {
    final unread = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: OwnerAppBar(
        title: 'Notifications',
        showBackButton: widget.showBackButton,
        onMenuPressed: () => Scaffold.of(context).openDrawer(),
      ),
      body: Column(
        children: [
          if (unread > 0) _buildUnreadBanner(unread),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final n = _notifications[index];
                return _buildNotifCard(n);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnreadBanner(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: GestureDetector(
        onTap: () => setState(() { for (final n in _notifications) { n.isRead = true; } }),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.mark_email_unread_rounded, color: AppColors.primaryLight, size: 18),
              const SizedBox(width: 10),
              Text(
                '$count unread notifications',
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.secondaryLight, fontSize: 13),
              ),
              const Spacer(),
              const Text(
                'Mark all read',
                style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotifCard(OwnerNotification n) {
    final data = _getTypeData(n.type);
    final timeAgo = _timeAgo(n.timestamp);

    return GestureDetector(
      onTap: () => setState(() => n.isRead = true),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [
            if (!n.isRead)
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Icon(data['icon'], color: data['color'], size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          n.title,
                          style: AppTextStyles.h2.copyWith(
                            fontSize: 14,
                            color: AppColors.secondaryLight,
                            fontWeight: n.isRead ? FontWeight.w600 : FontWeight.w800,
                          ),
                        ),
                      ),
                      if (!n.isRead)
                        Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryLight,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    n.message,
                    style: TextStyle(
                      color: n.isRead ? Colors.grey.shade500 : Colors.grey.shade700,
                      fontSize: 12,
                      height: 1.4,
                      fontWeight: n.isRead ? FontWeight.normal : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    timeAgo,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getTypeData(String type) {
    switch (type) {
      case 'expense': return {'color': Colors.orange, 'icon': Icons.receipt_rounded};
      case 'stock': return {'color': Colors.red, 'icon': Icons.inventory_2_rounded};
      case 'payment': return {'color': Colors.green, 'icon': Icons.payments_rounded};
      case 'locker': return {'color': Colors.purple, 'icon': Icons.lock_rounded};
      case 'invoice': return {'color': const Color(0xFF2D9CDB), 'icon': Icons.description_rounded};
      default: return {'color': Colors.grey, 'icon': Icons.notifications_rounded};
    }
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }
}
