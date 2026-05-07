import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../models/technician_models.dart';
import '../technician_view_model.dart';

class NotificationsView extends StatelessWidget {
  final bool showDrawerIcon;
  const NotificationsView({super.key, this.showDrawerIcon = false});

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
                onTap: () => showDrawerIcon ? Scaffold.of(context).openDrawer() : Navigator.pop(context),
                child: Container(
                  width: showDrawerIcon ? 44 : 40,
                  height: showDrawerIcon ? 44 : 40,
                  decoration: showDrawerIcon
                      ? BoxDecoration(
                          color: AppColors.secondaryLight,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(color: AppColors.secondaryLight.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
                          ],
                        )
                      : BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                  child: Center(
                    child: Icon(
                      showDrawerIcon ? Icons.menu_rounded : Icons.arrow_back_ios_new_rounded,
                      color: showDrawerIcon ? Colors.white : AppColors.secondaryLight,
                      size: showDrawerIcon ? 22 : 20,
                    ),
                  ),
                ),
              ),
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
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 600;
                    final list = vm.notifications;
                    final hGap = isWide ? 8.0 : 6.0;
                    final vGap = isWide ? 8.0 : 6.0;
                    final pad = EdgeInsets.fromLTRB(
                      isWide ? 16 : 12,
                      isWide ? 12 : 10,
                      isWide ? 16 : 12,
                      isWide ? 20 : 14,
                    );
                    final rowCount = (list.length + 1) ~/ 2;
                    return ListView.separated(
                      padding: pad,
                      itemCount: rowCount,
                      separatorBuilder: (_, _) => SizedBox(height: vGap),
                      itemBuilder: (context, rowIndex) {
                        final i = rowIndex * 2;
                        final left = list[i];
                        final right = i + 1 < list.length ? list[i + 1] : null;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: AlignmentDirectional.topCenter,
                                child: _buildNotificationCard(left),
                              ),
                            ),
                            SizedBox(width: hGap),
                            Expanded(
                              child: right != null
                                  ? Align(
                                      alignment: AlignmentDirectional.topCenter,
                                      child: _buildNotificationCard(right),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        );
                      },
                    );
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
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.flash_on_rounded, color: AppColors.primaryLight, size: 17),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  notification.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 13),
                ),
              ),
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            notification.message,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black54, fontSize: 12, height: 1.28, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              '2 minutes ago',
              style: TextStyle(color: Colors.black26, fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
