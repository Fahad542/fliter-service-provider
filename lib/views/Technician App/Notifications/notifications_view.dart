import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../models/technician_models.dart';
import '../technician_view_model.dart';

class NotificationsView extends StatefulWidget {
  final bool showDrawerIcon;

  const NotificationsView({super.key, this.showDrawerIcon = false});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TechAppViewModel>().fetchWorkshopNotifications();
    });
  }

  static String _timeLabel(DateTime ts) =>
      DateFormat('MMM d, yyyy · HH:mm').format(ts.toLocal());

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
            leading: Center(
              child: GestureDetector(
                onTap: widget.showDrawerIcon ? () => Scaffold.of(context).openDrawer() : () => Navigator.pop(context),
                child: Container(
                  width: widget.showDrawerIcon ? 44 : 40,
                  height: widget.showDrawerIcon ? 44 : 40,
                  decoration: widget.showDrawerIcon
                      ? BoxDecoration(
                          color: AppColors.secondaryLight,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                                color:
                                    AppColors.secondaryLight.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4)),
                          ],
                        )
                      : BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                  child: Center(
                    child: Icon(
                      widget.showDrawerIcon
                          ? Icons.menu_rounded
                          : Icons.arrow_back_ios_new_rounded,
                      color: widget.showDrawerIcon
                          ? Colors.white
                          : AppColors.secondaryLight,
                      size: widget.showDrawerIcon ? 22 : 20,
                    ),
                  ),
                ),
              ),
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            title: const Text('NOTIFICATIONS',
                style: TextStyle(
                    color: AppColors.secondaryLight,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 1)),
            centerTitle: true,
            actions: [
              if (vm.notifications.isNotEmpty)
                TextButton(
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Clear all?'),
                        content: const Text(
                            'Remove all notifications from this list.'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Clear')),
                        ],
                      ),
                    );
                    if (ok == true && context.mounted) {
                      await vm.clearAllWorkshopNotifications();
                    }
                  },
                  child: const Text('Clear',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.secondaryLight)),
                ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle),
                child: Center(
                    child: Image.asset('assets/images/global.png',
                        width: 22,
                        height: 22,
                        color: Colors.black,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.language, size: 22, color: Colors.black))),
              ),
              const SizedBox(width: 16),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: vm.fetchWorkshopNotifications,
            child: vm.notifications.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 120),
                      _EmptyNotifications(),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    itemCount: vm.notifications.length,
                    itemBuilder: (context, index) {
                      final notification = vm.notifications[index];
                      return Dismissible(
                        key: Key('tnotif-${notification.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red.shade50,
                          child: Icon(Icons.delete_outline,
                              color: Colors.red.shade400),
                        ),
                        onDismissed: (_) =>
                            vm.deleteWorkshopNotification(notification.id),
                        child: GestureDetector(
                          onTap: () {
                            if (!notification.isRead) {
                              vm.markWorkshopNotificationRead(notification.id);
                            }
                          },
                          child: _NotificationCard(
                            notification: notification,
                            timeLabel: _timeLabel(notification.timestamp),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.notifications_none_rounded,
            size: 80, color: Colors.black.withOpacity(0.05)),
        const SizedBox(height: 20),
        const Text('No notifications',
            style: TextStyle(
                color: Colors.black54,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          'Pull down to refresh',
          style: TextStyle(color: Colors.black26, fontSize: 14),
        ),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final TechNotification notification;
  final String timeLabel;

  const _NotificationCard({
    required this.notification,
    required this.timeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
        border: Border.all(
            color: notification.isRead
                ? Colors.black.withOpacity(0.05)
                : AppColors.primaryLight.withOpacity(0.35)),
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
            child: Icon(notification.type == 'Broadcast'
                    ? Icons.campaign_outlined
                    : Icons.notifications_active_outlined,
                color: AppColors.primaryLight,
                size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: const TextStyle(
                            color: AppColors.secondaryLight,
                            fontWeight: FontWeight.w900,
                            fontSize: 14),
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: AppColors.primaryLight,
                            shape: BoxShape.circle),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  timeLabel,
                  style: TextStyle(
                      color: Colors.black26,
                      fontSize: 10,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
