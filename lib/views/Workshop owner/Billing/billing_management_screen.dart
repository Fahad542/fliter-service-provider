import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import 'billing_management_view_model.dart';
import '../Corporate/corporate_management_view_model.dart';
import '../../../models/workshop_owner_models.dart';
import '../widgets/owner_app_bar.dart';
import '../owner_shell.dart';

class BillingManagementView extends StatefulWidget {
  const BillingManagementView({super.key});

  @override
  State<BillingManagementView> createState() => _BillingManagementViewState();
}

class _BillingManagementViewState extends State<BillingManagementView> {
  int _currentScreen = 0; // 0: Dashboard, 1: Generate, 2: List, 3: Overdue

  @override
  Widget build(BuildContext context) {
    return Consumer<BillingManagementViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          appBar: OwnerAppBar(
            title: _getScreenTitle(),
            showGlobalLeft: _currentScreen == 0,
            showNotification: _currentScreen == 0,
            showDrawer: false,
            showBackButton: _currentScreen != 0,
            onNotificationPressed: () => OwnerShell.goToNotifications(context),
            onBackPressed: _currentScreen != 0
                ? () { setState(() => _currentScreen = 0); }
                : null,
            onMenuPressed: () => Scaffold.of(context).openDrawer(),
          ),
          body: _buildCurrentScreen(vm),
        );
      },
    );
  }

  String _getScreenTitle() {
    switch (_currentScreen) {
      case 0: return 'Billing Dashboard';
      case 1: return 'Generate Bills';
      case 2: return 'Monthly Bills';
      case 3: return 'Overdue Payments';
      default: return 'Billing';
    }
  }

  Widget _buildCurrentScreen(BillingManagementViewModel vm) {
    switch (_currentScreen) {
      case 0: return _buildDashboard(vm);
      case 1: return _buildGenerator(vm);
      case 2: return _buildBillsList(vm);
      default: return _buildDashboard(vm);
    }
  }

  // --- SCREEN 1: DASHBOARD ---
  Widget _buildDashboard(BillingManagementViewModel vm) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(vm),
          const SizedBox(height: 32),
          Text('Quick Actions', style: AppTextStyles.h2.copyWith(fontSize: 18)),
          const SizedBox(height: 16),
          _buildActionGrid(),
          const SizedBox(height: 32),
          Text('Recent Billing Activity', style: AppTextStyles.h2.copyWith(fontSize: 18)),
          const SizedBox(height: 16),
          _buildRecentActivity(vm),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BillingManagementViewModel vm) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildSummaryCard('Total Billed', 'SAR ${vm.totalBilledMonth}', Icons.receipt_rounded, Colors.blue)),
            const SizedBox(width: 16),
            Expanded(child: _buildSummaryCard('Total Received', 'SAR ${vm.totalReceivedMonth}', Icons.payments_rounded, Colors.green)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildSummaryCard('Outstanding', 'SAR ${vm.totalOutstanding}', Icons.pending_actions_rounded, Colors.orange)),
            const SizedBox(width: 16),
            Expanded(child: _buildSummaryCard('Overdue', 'SAR ${vm.overdueAmount}', Icons.warning_amber_rounded, Colors.red)),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 2.5,
      children: [
        _buildActionButton('Generate Bills', Icons.add_circle_outline_rounded, () => setState(() => _currentScreen = 1)),
        _buildActionButton('View All Bills', Icons.list_alt_rounded, () => setState(() => _currentScreen = 2)),
        _buildActionButton('Record Payment', Icons.account_balance_wallet_rounded, () {}),
        _buildActionButton('Send Reminders', Icons.notification_important_rounded, () {}),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.secondaryLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryLight, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BillingManagementViewModel vm) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: vm.monthlyBills.length,
      itemBuilder: (context, index) {
        final bill = vm.monthlyBills[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              _getStatusIcon(bill.status),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bill.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('Month: ${bill.month}/${bill.year}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('SAR ${bill.totalAmount}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                  Text(bill.status, style: TextStyle(color: _getStatusColor(bill.status), fontSize: 9, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // --- SCREEN 2: GENERATOR ---
  Widget _buildGenerator(BillingManagementViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Step 1: Select Billing Period', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            value: 'January 2026',
            items: ['January 2026', 'December 2025'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) {},
          ),
          const SizedBox(height: 32),
          const Text('Step 2: Preview Eligible Invoices', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: context.read<CorporateManagementViewModel>().corporateCustomers.length,
              itemBuilder: (context, index) {
                final c = context.read<CorporateManagementViewModel>().corporateCustomers[index];
                return CheckboxListTile(
                  title: Text(c.companyName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Pending Invoices: 15 • Est. Total: SAR 12,450'),
                  value: true,
                  onChanged: (val) {},
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => setState(() => _currentScreen = 0),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryLight,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Confirm & Generate Bills', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- SCREEN 3: BILLS LIST ---
  Widget _buildBillsList(BillingManagementViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(child: _buildRecentActivity(vm)), // Reuse the activity list for simplicity
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Paid': return Colors.green;
      case 'Overdue': return Colors.red;
      case 'Partially Paid': return Colors.orange;
      default: return Colors.blue;
    }
  }

  Widget _getStatusIcon(String status) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: _getStatusColor(status).withOpacity(0.1),
      child: Icon(_getStatusIconData(status), color: _getStatusColor(status), size: 16),
    );
  }

  IconData _getStatusIconData(String status) {
    switch (status) {
      case 'Paid': return Icons.check_rounded;
      case 'Overdue': return Icons.priority_high_rounded;
      case 'Partially Paid': return Icons.hourglass_bottom_rounded;
      default: return Icons.receipt_rounded;
    }
  }
}
