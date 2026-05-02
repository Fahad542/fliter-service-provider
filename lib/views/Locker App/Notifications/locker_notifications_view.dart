import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/locker_models.dart';
import '../../../services/session_service.dart';
import '../../../utils/app_colors.dart';
import '../../../data/network/api_response.dart';
import 'locker_notifications_viewmodel.dart';

class LockerNotificationsView extends StatefulWidget {
  const LockerNotificationsView({super.key});

  @override
  State<LockerNotificationsView> createState() =>
      _LockerNotificationsViewState();
}

class _LockerNotificationsViewState extends State<LockerNotificationsView> {
  late final Future<String?> _tokenFuture;

  @override
  void initState() {
    super.initState();
    _tokenFuture = SessionService().getToken(role: 'locker');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<String?>(
      future: _tokenFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _ScaffoldShell(
              titleText: l10n.lockerNotificationsTitle,
              child: const _FullScreenLoader());
        }
        final token = snapshot.data;
        if (token == null || token.isEmpty) {
          return _ScaffoldShell(
            titleText: l10n.lockerNotificationsTitle,
            child: _ErrorBody(
                message: l10n.lockerSessionExpired),
          );
        }
        return ChangeNotifierProvider(
          create: (_) =>
          LockerNotificationsViewModel(token: token)..fetchNotifications(),
          child: const _NotificationsScaffold(),
        );
      },
    );
  }
}

// ── Main scaffold ─────────────────────────────────────────────────────────────

class _NotificationsScaffold extends StatelessWidget {
  const _NotificationsScaffold();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vm   = context.watch<LockerNotificationsViewModel>();

    return _ScaffoldShell(
      titleWidget: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.lockerNotificationsTitle,
            style: const TextStyle(
              color: AppColors.secondaryLight,
              fontWeight: FontWeight.w900,
              fontSize: 15,
              letterSpacing: 2,
            ),
          ),
          if (vm.unreadCount > 0) ...[
            const SizedBox(width: 8),
            _UnreadBadge(count: vm.unreadCount),
          ],
        ],
      ),
      child: _buildBody(context, vm),
    );
  }

  Widget _buildBody(BuildContext context, LockerNotificationsViewModel vm) {
    final l10n = AppLocalizations.of(context)!;
    final state = vm.state;

    if (state.status == Status.loading && vm.notifications.isEmpty) {
      return const _FullScreenLoader();
    }

    if (state.status == Status.error && vm.notifications.isEmpty) {
      return _ErrorBody(
        message: vm.errorMessage ?? l10n.lockerSomethingWentWrong,
        onRetry: vm.fetchNotifications,
      );
    }

    if (state.status == Status.completed && vm.notifications.isEmpty) {
      return const _EmptyBody();
    }

    return Column(
      children: [
        if (state.status == Status.error && vm.notifications.isNotEmpty)
          _ErrorBanner(
              message: vm.errorMessage ?? l10n.lockerCouldNotRefresh),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primaryLight,
            onRefresh: vm.refresh,
            child: _NotificationsList(vm: vm),
          ),
        ),
      ],
    );
  }
}

// ── List ──────────────────────────────────────────────────────────────────────

class _NotificationsList extends StatefulWidget {
  final LockerNotificationsViewModel vm;
  const _NotificationsList({required this.vm});

  @override
  State<_NotificationsList> createState() => _NotificationsListState();
}

class _NotificationsListState extends State<_NotificationsList> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      widget.vm.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifications = widget.vm.notifications;

    return ListView.separated(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      itemCount: notifications.length + (widget.vm.isLoadingMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        if (index == notifications.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryLight),
            ),
          );
        }
        final item = notifications[index];
        return _NotificationCard(
          key: ValueKey(item.id),
          item: item,
          onTap: () => widget.vm.markOneRead(item.id),
        );
      },
    );
  }
}

// ── Card ──────────────────────────────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  final LockerNotification item;
  final VoidCallback onTap;

  const _NotificationCard(
      {super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: item.isUnread ? Colors.white : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: item.isUnread
                ? AppColors.secondaryLight.withOpacity(0.08)
                : Colors.black.withOpacity(0.03),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(item.isUnread ? 0.05 : 0.02),
              blurRadius: item.isUnread ? 18 : 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TypeIcon(type: item.type),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          // title comes from API — already translated by the
                          // LockerTranslationService in the ViewModel
                          item.title.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.secondaryLight,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      if (item.isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFCC247),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    // body comes from API — translated in ViewModel
                    item.body,
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.5),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: Colors.black.withOpacity(0.2),
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(item.time),
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.2),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now  = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays >= 1) return DateFormat('d MMM, hh:mm a').format(dt);
    return DateFormat('hh:mm a').format(dt);
  }
}

// ── Type icon ─────────────────────────────────────────────────────────────────

class _TypeIcon extends StatelessWidget {
  final LockerNotificationType type;
  const _TypeIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(_icon, color: color, size: 22),
    );
  }

  Color get _color {
    switch (type) {
      case LockerNotificationType.newRequest: return Colors.blue;
      case LockerNotificationType.warning:    return Colors.red;
      case LockerNotificationType.status:     return Colors.teal;
      case LockerNotificationType.unknown:    return Colors.grey;
    }
  }

  IconData get _icon {
    switch (type) {
      case LockerNotificationType.newRequest: return Icons.add_moderator_rounded;
      case LockerNotificationType.warning:    return Icons.gpp_maybe_rounded;
      case LockerNotificationType.status:     return Icons.gpp_good_rounded;
      case LockerNotificationType.unknown:    return Icons.notifications_rounded;
    }
  }
}

// ── Unread badge ──────────────────────────────────────────────────────────────

class _UnreadBadge extends StatelessWidget {
  final int count;
  const _UnreadBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFCC247),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

// ── Scaffold shell ────────────────────────────────────────────────────────────

class _ScaffoldShell extends StatelessWidget {
  final Widget child;
  final Widget? titleWidget;
  final String? titleText;

  const _ScaffoldShell({
    required this.child,
    this.titleWidget,
    this.titleText,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: AppColors.primaryLight,
        elevation: 0,
        toolbarHeight: 72,
        title: titleWidget ??
            Text(
              titleText ?? '',
              style: const TextStyle(
                color: AppColors.secondaryLight,
                fontWeight: FontWeight.w900,
                fontSize: 15,
                letterSpacing: 2,
              ),
            ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.secondaryLight,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: child,
    );
  }
}

// ── Full-screen loader ────────────────────────────────────────────────────────

class _FullScreenLoader extends StatelessWidget {
  const _FullScreenLoader();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primaryLight),
    );
  }
}

// ── Error body ────────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _ErrorBody({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black.withOpacity(0.4),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                ),
                child: Text(
                  l10n.lockerTryAgain,
                  style: const TextStyle(
                    color: AppColors.secondaryLight,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Inline error banner ───────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: Colors.red.shade50,
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyBody extends StatelessWidget {
  const _EmptyBody();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_off_rounded,
              size: 56, color: Colors.black.withOpacity(0.15)),
          const SizedBox(height: 16),
          Text(
            l10n.lockerNoNotificationsYet,
            style: TextStyle(
              color: Colors.black.withOpacity(0.35),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}