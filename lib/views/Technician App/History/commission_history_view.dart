import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../technician_view_model.dart';
import '../Notifications/notifications_view.dart';
import 'package:intl/intl.dart';
import '../../../models/technician_commission_history_model.dart';

class CommissionHistoryView extends StatefulWidget {
  const CommissionHistoryView({super.key});

  @override
  State<CommissionHistoryView> createState() => _CommissionHistoryViewState();
}

class _CommissionHistoryViewState extends State<CommissionHistoryView> {
  /// Shared height so Row children get bounded constraints (avoids semantics / hit-test layout errors).
  static const double _kCommissionFilterRowHeight = 52;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TechAppViewModel>().fetchCommissionHistory();
    });
  }

  Future<void> _pickFrom(TechAppViewModel vm) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: vm.commissionHistoryFrom,
      firstDate: DateTime(2020),
      lastDate: vm.commissionHistoryTo,
    );
    if (picked != null) vm.setCommissionHistoryFrom(picked);
  }

  Future<void> _pickTo(TechAppViewModel vm) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: vm.commissionHistoryTo,
      firstDate: vm.commissionHistoryFrom,
      lastDate: DateTime.now(),
    );
    if (picked != null) vm.setCommissionHistoryTo(picked);
  }

  @override
  Widget build(BuildContext context) {
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
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.secondaryLight,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondaryLight.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(child: Icon(Icons.menu_rounded, color: Colors.white, size: 22)),
            ),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        title: const Text('COMMISSION HISTORY', style: TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsView())),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
              child: Center(child: Image.asset('assets/images/notifications.png', width: 22, height: 22, color: Colors.black, errorBuilder: (_, __, ___) => const Icon(Icons.notifications_rounded, size: 22, color: Colors.black))),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Consumer<TechAppViewModel>(
        builder: (context, vm, child) {
          return Column(
            children: [
              _buildDateRangeFilter(context, vm),
              Expanded(
                child: vm.isLoadingCommission
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryLight,
                        ),
                      )
                    : vm.commissionHistory.isEmpty
                        ? const Center(
                            child: Text(
                              'No commissions found',
                              style: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            itemCount: vm.commissionHistory.length,
                            itemBuilder: (context, index) {
                              return _buildCommissionItem(
                                  vm.commissionHistory[index]);
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateRangeFilter(BuildContext context, TechAppViewModel vm) {
    final fmt = DateFormat.yMMMd();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'DATE RANGE',
            style: TextStyle(
              color: Colors.black38,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SizedBox(
                  height: _kCommissionFilterRowHeight,
                  child: _buildDateField(
                    label: 'From',
                    value: fmt.format(vm.commissionHistoryFrom),
                    onTap: () => _pickFrom(vm),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: _kCommissionFilterRowHeight,
                  child: _buildDateField(
                    label: 'To',
                    value: fmt.format(vm.commissionHistoryTo),
                    onTap: () => _pickTo(vm),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 84,
                height: _kCommissionFilterRowHeight,
                child: ElevatedButton(
                  onPressed: vm.isLoadingCommission ? null : () => vm.fetchCommissionHistory(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryLight,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Apply',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          if (vm.commissionHistoryBusinessTimeZone != null &&
              vm.commissionHistoryBusinessTimeZone!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Listed dates match the server (${vm.commissionHistoryBusinessTimeZone!.trim()}); range uses calendar days only.',
              style: TextStyle(
                color: Colors.black.withOpacity(0.38),
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Prefer API [CommissionEntry.displayYmd] (no clock); fall back to legacy timestamps.
  String _formatCommissionRowDate(CommissionEntry entry) {
    final ymd = entry.displayYmd.trim();
    if (ymd.length == 10 && RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(ymd)) {
      try {
        final p = ymd.split('-');
        final dt = DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
        return DateFormat.yMMMd().format(dt);
      } catch (_) {}
    }
    try {
      return DateFormat.yMMMd().format(DateTime.parse(entry.displayDate).toLocal());
    } catch (_) {
      return entry.displayDate.isNotEmpty ? entry.displayDate : ymd;
    }
  }

  Widget _buildDateField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FD),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.secondaryLight,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey.shade500),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommissionItem(CommissionEntry entry) {
    final isPaid = entry.isPaid;
    final statusColor = isPaid ? Colors.green : Colors.orange;
    final formattedDate = _formatCommissionRowDate(entry);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
        border: Border.all(
          color: isPaid
              ? Colors.green.withOpacity(0.15)
              : Colors.black.withOpacity(0.04),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isPaid
                      ? Icons.check_circle_rounded
                      : Icons.pending_actions_rounded,
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.orderId,
                    style: const TextStyle(
                        color: AppColors.secondaryLight,
                        fontWeight: FontWeight.w900,
                        fontSize: 14),
                  ),
                  if (isPaid && entry.invoiceId != null)
                    Text(
                      'INV-${entry.invoiceId}',
                      style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 10,
                          fontWeight: FontWeight.w600),
                    ),
                  Text(
                    entry.status.toUpperCase(),
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'SAR ${entry.commission.toStringAsFixed(2)}',
                style: const TextStyle(
                    color: AppColors.secondaryLight,
                    fontWeight: FontWeight.w900,
                    fontSize: 16),
              ),
              Text(
                formattedDate,
                style: const TextStyle(
                    color: Colors.black26,
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
              ),
              if (isPaid)
                Text(
                  'Credited to wallet',
                  style: TextStyle(
                      color: Colors.green.shade400,
                      fontSize: 10,
                      fontWeight: FontWeight.w700),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
