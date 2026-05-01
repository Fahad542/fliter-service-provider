import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/pos_tablet_layout.dart';
import '../../../widgets/pos_widgets.dart';
import '../../../l10n/app_localizations.dart';
import 'notifications_view_model.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isTablet = MediaQuery.of(context).size.width > 600;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: PosTabletLayout.textScaler(context),
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: PosScreenAppBar(
          title: l10n.notifTitle,
          actions: [
            // "Mark all as read" action
            TextButton(
              onPressed: () =>
                  context.read<NotificationsViewModel>().markAllAsRead(),
              child: Text(
                l10n.notifMarkRead,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        body: Consumer<NotificationsViewModel>(
          builder: (context, vm, _) {
            final notifications = vm.notifications;

            if (notifications.isEmpty) {
              return Center(
                child: Text(
                  l10n.notifEmpty,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return _NotificationCard(
                  notification: notifications[index],
                  isTablet: isTablet,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card widget — extracted as a separate stateless widget to keep
// the build method readable and avoid closure captures.
// ─────────────────────────────────────────────────────────────────────────────
class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final bool isTablet;

  const _NotificationCard({
    required this.notification,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    // Use Directionality to handle RTL Arabic text correctly.
    // Row children are automatically mirrored in RTL; no manual adjustment needed.
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
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Icon bubble ────────────────────────────────────────────────
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

          // ── Text block ─────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row + time + unread dot
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Title — flex so it never overflows in long Arabic text
                    Expanded(
                      child: Text(
                        notification.displayTitle,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Time + unread indicator — kept in a Row so they
                    // stay together and do NOT grow.
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          notification.time,
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

                // Message body — softWrap handles long Arabic sentences
                Text(
                  notification.displayMessage,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    height: 1.4,
                  ),
                  // Allow wrapping — Arabic text can be longer than English.
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}