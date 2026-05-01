import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/workshop_owner_models.dart';
import '../../../services/locker_translation_mixin.dart';
import '../widgets/owner_app_bar.dart';

class OwnerNotificationsView extends StatefulWidget {
  final bool showBackButton;
  const OwnerNotificationsView({super.key, this.showBackButton = false});

  @override
  State<OwnerNotificationsView> createState() => _OwnerNotificationsViewState();
}

class _OwnerNotificationsViewState extends State<OwnerNotificationsView> {
  // Raw notifications (titles/messages come from the API in English)
  final List<OwnerNotification> _rawNotifications = [
    OwnerNotification(id: '1', title: 'Expense Submitted', message: 'Ali Hassan submitted an expense of SAR 450 for approval.', type: 'expense', timestamp: DateTime.now().subtract(const Duration(minutes: 15))),
    OwnerNotification(id: '2', title: 'Low Stock Alert', message: 'Engine Oil 5W-30 is critically low at Riyadh Main (3 units left).', type: 'stock', timestamp: DateTime.now().subtract(const Duration(hours: 1)), isRead: true),
    OwnerNotification(id: '3', title: 'Corporate Payment Received', message: 'Gulf Corp. LLC paid SAR 15,000 for January bill.', type: 'payment', timestamp: DateTime.now().subtract(const Duration(hours: 3))),
    OwnerNotification(id: '4', title: 'Locker Difference', message: 'Jeddah Center – SAR 50 difference detected at EOD closing.', type: 'locker', timestamp: DateTime.now().subtract(const Duration(hours: 5))),
    OwnerNotification(id: '5', title: 'Invoice Approved', message: 'Purchase order PO-002 has been approved and stock updated.', type: 'invoice', timestamp: DateTime.now().subtract(const Duration(hours: 8)), isRead: true),
    OwnerNotification(id: '6', title: 'Overdue Bill Alert', message: 'Saudi Aramco Corp. bill of SAR 38,000 is now overdue.', type: 'payment', timestamp: DateTime.now().subtract(const Duration(days: 1))),
  ];

  // Translated copies of the notifications — rebuilt on locale change
  List<OwnerNotification> _displayNotifications = [];
  Locale? _lastLocale;
  bool _translating = false;

  @override
  void initState() {
    super.initState();
    // Start with raw list; translation will happen in didChangeDependencies
    _displayNotifications = List.from(_rawNotifications);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    if (_lastLocale != locale) {
      _lastLocale = locale;
      _translateNotifications(locale);
    }
  }

  Future<void> _translateNotifications(Locale locale) async {
    if (_translating) return;
    _translating = true;

    final isAr = locale.languageCode == 'ar';
    if (!isAr) {
      if (mounted) setState(() => _displayNotifications = List.from(_rawNotifications));
      _translating = false;
      return;
    }

    final translated = await Future.wait(_rawNotifications.map((n) async {
      final title = await AppTranslationService.localizedText(n.title);
      final message = await AppTranslationService.localizedText(n.message);
      return OwnerNotification(
        id: n.id,
        title: title,
        message: message,
        type: n.type,
        timestamp: n.timestamp,
        isRead: n.isRead,
      );
    }));

    if (mounted) setState(() => _displayNotifications = translated);
    _translating = false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: OwnerAppBar(
        title: l10n.notifTitle,
        showBackButton: widget.showBackButton,
        onMenuPressed: () => Scaffold.of(context).openDrawer(),
      ),
      body: _displayNotifications.isEmpty
          ? Center(child: Text(l10n.notifEmpty, style: TextStyle(color: Colors.grey.shade500)))
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _displayNotifications.length,
        itemBuilder: (context, index) =>
            _buildNotifCard(_displayNotifications[index], l10n),
      ),
    );
  }

  Widget _buildNotifCard(OwnerNotification n, AppLocalizations l10n) {
    final data = _getTypeData(n.type);
    final timeAgo = _timeAgo(n.timestamp, l10n);

    return GestureDetector(
      onTap: () {
        // Mark raw notification read too so state is consistent
        final rawIndex = _rawNotifications.indexWhere((r) => r.id == n.id);
        if (rawIndex != -1) _rawNotifications[rawIndex].isRead = true;
        setState(() => n.isRead = true);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
          border: n.isRead
              ? null
              : Border.all(color: AppColors.primaryLight.withOpacity(0.3), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: AppColors.secondaryLight, shape: BoxShape.circle),
              child: Icon(data['icon'] as IconData, color: AppColors.primaryLight, size: 20),
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
                          n.title,
                          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            timeAgo,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.grey.shade400, fontSize: 10, fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (!n.isRead) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 8, height: 8,
                              decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n.message,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.grey.shade600, fontSize: 13, height: 1.3,
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
      case 'expense': return {'icon': Icons.receipt_rounded};
      case 'stock':   return {'icon': Icons.inventory_2_rounded};
      case 'payment': return {'icon': Icons.payments_rounded};
      case 'locker':  return {'icon': Icons.lock_rounded};
      case 'invoice': return {'icon': Icons.description_rounded};
      default:        return {'icon': Icons.notifications_rounded};
    }
  }

  /// Returns a locale-aware "time ago" string using l10n keys.
  String _timeAgo(DateTime date, AppLocalizations l10n) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return l10n.notifTimeDays(diff.inDays);
    if (diff.inHours > 0) return l10n.notifTimeHours(diff.inHours);
    return l10n.notifTimeMinutes(diff.inMinutes);
  }
}