import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
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

class _AccountingViewState extends State<AccountingView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  /// Keys sent to the API — never translated.
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
    if (_tabController.indexIsChanging) return;
    final idx = _tabController.index;
    if (idx == _lastFetchedIndex) return;
    _lastFetchedIndex = idx;
    final vm = Provider.of<AccountingViewModel>(context, listen: false);
    vm.fetchTransactions(_types[idx]);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    /// Tab labels resolved from localizations — order matches [_types].
    final List<String> tabs = [
      l10n.accountingTabPayables,
      l10n.accountingTabReceivables,
      l10n.accountingTabExpenses,
      l10n.accountingTabAdvances,
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: OwnerAppBar(
        title: l10n.accountingTitle,
        onMenuPressed: () => Scaffold.of(context).openDrawer(),
      ),
      body: Consumer<AccountingViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryLight),
            );
          }

          return Column(
            children: [
              _buildSummaryRow(vm, l10n),
              _buildTabBar(tabs),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: _types
                      .map((type) => _buildEntryList(type, vm, l10n))
                      .toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(AccountingViewModel vm, AppLocalizations l10n) {
    final payables    = vm.summaryResponse?.summary.payables    ?? 0.0;
    final receivables = vm.summaryResponse?.summary.receivables ?? 0.0;
    final overdue     = vm.summaryResponse?.summary.overdue     ?? 0.0;
    final currency    = vm.summaryResponse?.currency            ?? 'SAR';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _buildSumCard(
            l10n.accountingPayables,
            '$currency ${payables.toInt()}',
            Icons.arrow_upward_rounded,
            Colors.orange,
          ),
          const SizedBox(width: 12),
          _buildSumCard(
            l10n.accountingReceivables,
            '$currency ${receivables.toInt()}',
            Icons.arrow_downward_rounded,
            Colors.green,
          ),
          const SizedBox(width: 12),
          _buildSumCard(
            l10n.accountingOverdue,
            '$currency ${overdue.toInt()}',
            Icons.warning_rounded,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildSumCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: AppTextStyles.h2
                    .copyWith(fontSize: 16, color: AppColors.secondaryLight),
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(List<String> tabs) {
    final pillRadius = BorderRadius.circular(12);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200.withValues(alpha: 0.85),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _tabController,
          builder: (context, _) {
            return Row(
              children: List.generate(tabs.length, (i) {
                final selected = _tabController.index == i;
                return Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _tabController.animateTo(i),
                      borderRadius: pillRadius,
                      splashColor:
                      AppColors.primaryLight.withValues(alpha: 0.2),
                      highlightColor:
                      AppColors.primaryLight.withValues(alpha: 0.06),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 2),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primaryLight
                              : Colors.transparent,
                          borderRadius: pillRadius,
                        ),
                        child: Text(
                          tabs[i],
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: selected ? 12.5 : 11,
                            fontWeight: selected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: selected
                                ? AppColors.secondaryLight
                                : const Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEntryList(
      String type, AccountingViewModel vm, AppLocalizations l10n) {
    if (vm.isLoadingType(type)) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryLight),
      );
    }

    final filtered = vm.getTransactionsFor(type);
    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 60,
              color: Colors.black.withOpacity(0.07),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.accountingNoEntries,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filtered.length,
      itemBuilder: (context, i) => _buildEntryCard(filtered[i], l10n),
    );
  }

  Widget _buildEntryCard(AccountEntry entry, AppLocalizations l10n) {
    // Status colour — driven by translated status key from VM.
    Color statusColor;
    switch (entry.status) {
      case 'overdue':
        statusColor = Colors.red;
        break;
      case 'settled':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.orange;
    }

    // Type colour + icon.
    Color typeColor;
    IconData icon;
    switch (entry.type) {
      case 'payable':
        typeColor = Colors.orange;
        icon = Icons.arrow_upward_rounded;
        break;
      case 'receivable':
        typeColor = Colors.green;
        icon = Icons.arrow_downward_rounded;
        break;
      case 'expense':
        typeColor = Colors.red;
        icon = Icons.receipt_rounded;
        break;
      default: // advance
        typeColor = Colors.purple;
        icon = Icons.person_rounded;
    }

    final date = entry.date;
    final dateStr = '${date.day}/${date.month}/${date.year}';

    // Translated status label (resolved by VM in Arabic locale).
    final translatedStatus = entry.translatedStatus;
    // Translated party name (resolved by VM in Arabic locale).
    final displayParty = entry.translatedParty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: typeColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayParty!,
                  style: AppTextStyles.h2
                      .copyWith(fontSize: 16, color: AppColors.secondaryLight),
                ),
                const SizedBox(height: 3),
                Text(
                  l10n.accountingRefPrefix(entry.reference, dateStr),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'SAR ${entry.amount.toInt()}',
                style: AppTextStyles.h2
                    .copyWith(fontSize: 15, color: AppColors.secondaryLight),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  translatedStatus!.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}