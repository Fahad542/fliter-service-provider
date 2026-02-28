import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../models/workshop_owner_models.dart';
import '../widgets/owner_app_bar.dart';

class ApprovalsView extends StatefulWidget {
  const ApprovalsView({super.key});

  @override
  State<ApprovalsView> createState() => _ApprovalsViewState();
}

class _ApprovalsViewState extends State<ApprovalsView> {
  final List<OwnerApproval> _approvals = [
    OwnerApproval(id: '1', type: 'Expense', submittedBy: 'Ali Hassan', branchName: 'Riyadh Main', amount: 450, date: DateTime.now().subtract(const Duration(hours: 2)), description: 'Office supplies purchase'),
    OwnerApproval(id: '2', type: 'PurchaseInvoice', submittedBy: 'Omar Saeed', branchName: 'Jeddah Center', amount: 8400, date: DateTime.now().subtract(const Duration(hours: 4)), description: 'Oil filters batch – Al-Rashid Parts'),
    OwnerApproval(id: '3', type: 'Advance', submittedBy: 'Sami Khalid', branchName: 'Riyadh Main', amount: 1200, date: DateTime.now().subtract(const Duration(hours: 6)), description: 'Salary advance request'),
    OwnerApproval(id: '4', type: 'Locker', submittedBy: 'Rami Yousef', branchName: 'Dammam Branch', amount: 50, date: DateTime.now().subtract(const Duration(hours: 1)), description: 'Locker difference – EOD closing'),
    OwnerApproval(id: '5', type: 'PhysicalCount', submittedBy: 'Tariq Nasser', branchName: 'Jeddah Center', amount: 0, date: DateTime.now().subtract(const Duration(hours: 3)), description: 'Engine oil 5W-30 variance: -12 ltr'),
  ];

  String _filter = 'All';
  final List<String> _filters = ['All', 'Expense', 'PurchaseInvoice', 'Advance', 'Locker', 'PhysicalCount'];

  @override
  Widget build(BuildContext context) {
    final pending = _approvals.where((a) => a.status == 'pending').toList();
    final filtered = _filter == 'All' ? pending : pending.where((a) => a.type == _filter).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: OwnerAppBar(
        title: 'Approvals',
        showGlobalLeft: true,
        showNotification: true,
        showBackButton: false,
        showDrawer: false,
      ),
      body: Column(
        children: [
          _buildSummaryBanner(pending.length),
          _buildFilterChips(),
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => _buildApprovalCard(filtered[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBanner(int count) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: count > 0 ? Colors.orange.withOpacity(0.08) : Colors.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: count > 0 ? Colors.orange.withOpacity(0.2) : Colors.green.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(count > 0 ? Icons.pending_actions_rounded : Icons.check_circle_rounded, color: count > 0 ? Colors.orange : Colors.green, size: 22),
          const SizedBox(width: 12),
          Text(count > 0 ? '$count items awaiting your approval' : 'All caught up! No pending approvals.', style: TextStyle(fontWeight: FontWeight.w700, color: count > 0 ? Colors.orange.shade800 : Colors.green.shade800)),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 44,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        children: _filters.map((f) {
          final isSelected = _filter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filter = f),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.secondaryLight : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? AppColors.secondaryLight : Colors.grey.withOpacity(0.2)),
                ),
                child: Text(f.replaceAll('Invoice', ' Invoice'), style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade700, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600, fontSize: 12)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildApprovalCard(OwnerApproval approval) {
    final typeData = _getTypeData(approval.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 16, top: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.08)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: typeData['color'].withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(typeData['icon'], color: typeData['color'], size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(approval.type.replaceAll('Invoice', ' Invoice'), style: TextStyle(fontWeight: FontWeight.w900, color: typeData['color'], fontSize: 12, letterSpacing: 0.5)),
                    Text(approval.submittedBy, style: AppTextStyles.h2.copyWith(fontSize: 15, color: AppColors.secondaryLight)),
                  ],
                ),
              ),
              if (approval.amount > 0)
                Text('SAR ${approval.amount.toInt()}', style: AppTextStyles.h2.copyWith(fontSize: 15, color: AppColors.secondaryLight)),
            ],
          ),
          const SizedBox(height: 12),
          Text(approval.description, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text('${approval.branchName} • ${_timeAgo(approval.date)}', style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => approval.status = 'rejected'),
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => setState(() => approval.status = 'approved'),
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline_rounded, size: 72, color: Colors.green.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text('No pending approvals', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          Text('All caught up for $_filter!', style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  Map<String, dynamic> _getTypeData(String type) {
    switch (type) {
      case 'Expense': return {'color': Colors.orange, 'icon': Icons.receipt_rounded};
      case 'PurchaseInvoice': return {'color': const Color(0xFF2D9CDB), 'icon': Icons.shopping_cart_rounded};
      case 'Advance': return {'color': Colors.purple, 'icon': Icons.person_rounded};
      case 'Locker': return {'color': Colors.red, 'icon': Icons.lock_rounded};
      case 'PhysicalCount': return {'color': Colors.teal, 'icon': Icons.inventory_rounded};
      default: return {'color': Colors.grey, 'icon': Icons.pending_rounded};
    }
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }
}
