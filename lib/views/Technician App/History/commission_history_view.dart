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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<TechAppViewModel>();
      vm.fetchCommissionHistory(
        month: vm.selectedCommissionMonth.month,
        year: vm.selectedCommissionMonth.year,
      );
    });
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
              width: 40, height: 40,
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
              _buildMonthSelector(vm),
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
                            padding: const EdgeInsets.all(20),
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

  Widget _buildMonthSelector(TechAppViewModel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: vm.availableCommissionMonths.map((dt) {
            final name = DateFormat('MMMM yyyy').format(dt);
            final isSelected = dt.year == vm.selectedCommissionMonth.year &&
                dt.month == vm.selectedCommissionMonth.month;
            return _buildMonthPill(name, isSelected, () {
              vm.selectCommissionMonth(dt);
            });
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMonthPill(String name, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? []
              : [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.02), blurRadius: 5)
                ],
        ),
        child: Text(
          name.toUpperCase(),
          style: TextStyle(
            color: isSelected ? Colors.black87 : Colors.black38,
            fontWeight: FontWeight.w900,
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildCommissionItem(CommissionEntry entry) {
    final isPaid = entry.isPaid;
    final statusColor = isPaid ? Colors.green : Colors.orange;

    String formattedDate = '';
    try {
      final dt = DateTime.parse(entry.displayDate).toLocal();
      formattedDate = DateFormat('MMM d, yyyy').format(dt);
    } catch (_) {
      formattedDate = entry.displayDate;
    }

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
