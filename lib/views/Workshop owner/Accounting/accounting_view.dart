import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../models/workshop_owner_models.dart';
import '../widgets/owner_app_bar.dart';
import 'accounting_view_model.dart';

class AccountingView extends StatefulWidget {
  const AccountingView({super.key});

  @override
  State<AccountingView> createState() => _AccountingViewState();
}

class _AccountingViewState extends State<AccountingView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = ['Payables', 'Receivables', 'Expenses', 'Advances'];
  final List<String> _types = ['payable', 'receivable', 'expense', 'advance'];

  int _lastFetchedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final vm = Provider.of<AccountingViewModel>(context, listen: false);
        vm.fetchSummary();
        vm.fetchTransactions(_types[0]);
      }
    });
  }

  void _onTabChanged() {
    if (_tabController.index == _lastFetchedIndex) return;
    _lastFetchedIndex = _tabController.index;
    final vm = Provider.of<AccountingViewModel>(context, listen: false);
    vm.fetchTransactions(_types[_tabController.index]);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: OwnerAppBar(
        title: 'Accounting',
        onMenuPressed: () => Scaffold.of(context).openDrawer(),
      ),
      body: Consumer<AccountingViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryLight));
          }

          return Column(
            children: [
              _buildSummaryRow(vm),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: _types.map((type) => _buildEntryList(type, vm)).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(AccountingViewModel vm) {
    final payables = vm.summaryResponse?.summary.payables ?? 0.0;
    final receivables = vm.summaryResponse?.summary.receivables ?? 0.0;
    final overdue = vm.summaryResponse?.summary.overdue ?? 0.0;
    final currency = vm.summaryResponse?.currency ?? 'SAR';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _buildSumCard('Payables', '$currency ${payables.toInt()}', Icons.arrow_upward_rounded, Colors.orange),
          const SizedBox(width: 12),
          _buildSumCard('Receivables', '$currency ${receivables.toInt()}', Icons.arrow_downward_rounded, Colors.green),
          const SizedBox(width: 12),
          _buildSumCard('Overdue', '$currency ${overdue.toInt()}', Icons.warning_rounded, Colors.red),
        ],
      ),
    );
  }

  Widget _buildSumCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.08)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value, style: AppTextStyles.h2.copyWith(fontSize: 16, color: AppColors.secondaryLight)),
            ),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.withOpacity(0.1))),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        labelColor: AppColors.secondaryLight,
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
        tabs: _tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }

  Widget _buildEntryList(String type, AccountingViewModel vm) {
    if (vm.isLoadingType(type)) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryLight));
    }

    final filtered = vm.getTransactionsFor(type);
    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            Icon(Icons.account_balance_wallet_outlined, size: 60, color: Colors.black.withOpacity(0.07)), 
            const SizedBox(height: 16), 
            const Text('No entries found', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600))
          ]
        )
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20), 
      itemCount: filtered.length, 
      itemBuilder: (context, i) => _buildEntryCard(filtered[i])
    );
  }

  Widget _buildEntryCard(AccountEntry entry) {
    Color statusColor = entry.status == 'overdue' ? Colors.red : entry.status == 'settled' ? Colors.green : Colors.orange;
    Color typeColor = entry.type == 'payable' ? Colors.orange : entry.type == 'receivable' ? Colors.green : entry.type == 'expense' ? Colors.red : Colors.purple;
    IconData icon = entry.type == 'payable' ? Icons.arrow_upward_rounded : entry.type == 'receivable' ? Icons.arrow_downward_rounded : entry.type == 'expense' ? Icons.receipt_rounded : Icons.person_rounded;
    final date = entry.date;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.grey.withOpacity(0.08)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: typeColor.withOpacity(0.08), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: typeColor, size: 18)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(entry.party, style: AppTextStyles.h2.copyWith(fontSize: 16, color: AppColors.secondaryLight)),
            const SizedBox(height: 3),
            Text('Ref: ${entry.reference} • ${date.day}/${date.month}/${date.year}', style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('SAR ${entry.amount.toInt()}', style: AppTextStyles.h2.copyWith(fontSize: 15, color: AppColors.secondaryLight)),
            const SizedBox(height: 4),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(entry.status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.w900))),
          ]),
        ],
      ),
    );
  }
}
