import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/pos_tablet_layout.dart';
import '../../../utils/app_text_styles.dart';
import '../../../widgets/pos_widgets.dart';

import 'package:provider/provider.dart';
import 'notifications_view_model.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsViewModel>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: PosTabletLayout.textScaler(context),
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: PosScreenAppBar(
          title: 'Notifications',
          showBackButton: true,
          actions: [
            Consumer<NotificationsViewModel>(
              builder: (context, vm, _) {
                if (vm.notifications.isEmpty && !vm.isLoading) {
                  return const SizedBox.shrink();
                }
                return TextButton(
                  onPressed: vm.isLoading
                      ? null
                      : () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Clear all notifications?'),
                              content: const Text(
                                'This removes every notification in your cashier inbox.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(ctx, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(ctx, true),
                                  child: const Text('Clear all'),
                                ),
                              ],
                            ),
                          );
                          if (ok == true && context.mounted) {
                            await vm.clearAll();
                          }
                        },
                  child: const Text(
                    'Clear all',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.secondaryLight,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Consumer<NotificationsViewModel>(
          builder: (context, vm, child) {
            if (vm.isLoading && vm.notifications.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (vm.errorMessage != null && vm.notifications.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    vm.errorMessage!,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            if (vm.notifications.isEmpty) {
              return Center(
                child: Text(
                  'No notifications yet.',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: Colors.grey.shade600),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: vm.refresh,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                itemCount: vm.notifications.length,
                itemBuilder: (context, index) {
                  final n = vm.notifications[index];
                  return Dismissible(
                    key: Key('notif-${n.id}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      color: Colors.red.shade100,
                      child: const Icon(Icons.delete_outline),
                    ),
                    onDismissed: (_) => vm.deleteOne(n.id),
                    child: GestureDetector(
                      onTap: () {
                        if (!n.isRead) vm.markRead(n.id);
                      },
                      child: _buildNotificationCard(n, isTablet),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationCard(PosNotificationRow notification, bool isTablet) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: notification.isRead
            ? null
            : Border.all(
                color: AppColors.primaryLight.withOpacity(0.3),
                width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.secondaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              notification.icon,
              color: AppColors.primaryLight,
              size: 20,
            ),
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
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          notification.timeLabel,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.grey.shade400,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (!notification.isRead) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryLight,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.body,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
