import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../models/workshop_owner_models.dart';
import '../widgets/owner_app_bar.dart';
import 'accounting_view_model.dart';

// ---------------------------------------------------------------------------
// AccountingView
//
// ── Translation safety rules ────────────────────────────────────────────────
// 1. Static UI strings  → AppLocalizations (l10n.*). Never hardcoded.
// 2. Dynamic API data   → entry.translatedParty / entry.translatedStatus
//    (set by AccountingViewModel after translation).
// 3. ALL switch / if-else conditions compare against the RAW entry.status
//    and entry.type fields (English API values: 'overdue', 'settled',
//    'payable', etc.). They NEVER compare translated strings — this ensures
//    Arabic mode never breaks any colour/icon conditional.
// ---------------------------------------------------------------------------

class AccountingView extends StatefulWidget {
  const AccountingView({super.key});

  @override
  State<AccountingView> createState() => _AccountingViewState();
}

class _AccountingViewState extends State<AccountingView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  /// Raw API type keys — used for API calls and switch/if logic.
  /// NEVER translated; NEVER shown directly to the user.
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
    // Pass RAW type key — never a translated string.
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

    /// Tab labels from localizations — order matches [_types].
    /// These are localized display strings only; selection logic always uses
    /// the raw key from [_types].
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

          if (vm.error != null && vm.summaryResponse == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.accountingLoadingError,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      vm.fetchSummary();
                      vm.fetchTransactions(_types[_tabController.index]);
                    },
                    child: Text(l10n.lockerRetry),
                  ),
                ],
              ),
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
                          // Display localized tab label.
                          // Selection/fetch logic uses raw key from [_types].
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
    // [type] is a raw API key — safe for isLoadingType comparison.
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
    // ── Status colour ────────────────────────────────────────────────────────
    // ALWAYS compare against the RAW entry.status (English API value).
    // NEVER compare against the translated string — would break in Arabic.
    Color statusColor;
    switch (entry.status) {
      case 'overdue':
        statusColor = Colors.red;
        break;
      case 'settled':
        statusColor = Colors.green;
        break;
      default: // 'pending' and any future statuses
        statusColor = Colors.orange;
    }

    // ── Type colour + icon ───────────────────────────────────────────────────
    // Same rule: compare against RAW entry.type.
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
      default: // 'advance'
        typeColor = Colors.purple;
        icon = Icons.person_rounded;
    }

    final date    = entry.date;
    final dateStr = '${date.day}/${date.month}/${date.year}';

    // ── Display strings ──────────────────────────────────────────────────────
    // Use the translated fields set by the ViewModel.
    // Fall back to raw fields only as a safety net — the ViewModel always sets
    // translated* fields when translation is available.
    final displayStatus = entry.translatedStatus ?? entry.status;
    final displayParty  = entry.translatedParty  ?? entry.party;

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
                  displayParty,
                  style: AppTextStyles.h2
                      .copyWith(fontSize: 16, color: AppColors.secondaryLight),
                ),
                const SizedBox(height: 3),
                Text(
                  // l10n key handles locale-specific Ref prefix formatting.
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
                  // Display the translated status — already uppercase-friendly.
                  displayStatus.toUpperCase(),
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