import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/pos_tablet_layout.dart';
import '../../../utils/app_text_styles.dart';
import '../../../widgets/pos_widgets.dart';
// import '../../utils/app_colors.dart';
// import '../../utils/app_text_styles.dart';
// import '../../widgets/pos_widgets.dart';

import 'package:provider/provider.dart';
import 'notifications_view_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/LocalizedApiText.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final l10n = AppLocalizations.of(context)!;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: PosTabletLayout.textScaler(context),
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: PosScreenAppBar(title: l10n.notifTitle),
        body: Consumer<NotificationsViewModel>(
          builder: (context, vm, child) {
            final notifications = vm.notifications;
            final hGap = isTablet ? 8.0 : 6.0;
            final vGap = isTablet ? 8.0 : 6.0;
            final pad = EdgeInsets.fromLTRB(
              isTablet ? 16 : 12,
              isTablet ? 12 : 10,
              isTablet ? 16 : 12,
              isTablet ? 20 : 14,
            );
            final rowCount = (notifications.length + 1) ~/ 2;
            return ListView.separated(
              padding: pad,
              itemCount: rowCount,
              separatorBuilder: (_, _) => SizedBox(height: vGap),
              itemBuilder: (context, rowIndex) {
                final i = rowIndex * 2;
                final left = notifications[i];
                final right = i + 1 < notifications.length ? notifications[i + 1] : null;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: AlignmentDirectional.topCenter,
                        child: _buildNotificationCard(context, left, isTablet),
                      ),
                    ),
                    SizedBox(width: hGap),
                    Expanded(
                      child: right != null
                          ? Align(
                              alignment: AlignmentDirectional.topCenter,
                              child: _buildNotificationCard(context, right, isTablet),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationModel notification, bool isTablet) {
    final pad = isTablet ? 12.0 : 10.0;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(pad),
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
            : Border.all(color: AppColors.primaryLight.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 8 : 7),
                decoration: const BoxDecoration(
                  color: AppColors.secondaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  notification.icon,
                  color: AppColors.primaryLight,
                  size: isTablet ? 19 : 17,
                ),
              ),
              SizedBox(width: isTablet ? 10 : 8),
              Expanded(
                child: LocalizedApiText(
                  notification.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: isTablet ? 14 : 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 6 : 5),
          LocalizedApiText(
            notification.message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey.shade600,
              fontSize: isTablet ? 13 : 12,
              height: 1.25,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
          ),
          SizedBox(height: isTablet ? 6 : 5),
          Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: LocalizedApiText(
                    notification.time,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.grey.shade500,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ),
                if (!notification.isRead) ...[
                  const SizedBox(width: 6),
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
    );
  }
}
