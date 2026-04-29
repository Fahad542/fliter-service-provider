import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import 'reports_management_view_model.dart';
import '../widgets/owner_app_bar.dart';
import '../owner_shell.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ReportsManagementView
//
// All static UI strings use l10n.* keys.
// Dynamic API data (tech names, day labels) uses pre-translated fields from
// the ViewModel so that:
//   • Arabic locale → translated values.
//   • Locale switch → ViewModel.onLocaleChanged() re-translates and notifies.
//   • No async calls inside build() → zero overflow / jank risk.
// ─────────────────────────────────────────────────────────────────────────────

class ReportsManagementView extends StatefulWidget {
  const ReportsManagementView({super.key});

  @override
  State<ReportsManagementView> createState() => _ReportsManagementViewState();
}

class _ReportsManagementViewState extends State<ReportsManagementView> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Consumer<ReportsManagementViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          appBar: OwnerAppBar(
            // ── Static string → l10n key ──────────────────────────────────
            title: l10n.reportsTitle,
            showGlobalLeft: true,
            showNotification: true,
            showBackButton: false,
            showDrawer: false,
            onNotificationPressed: () => OwnerShell.goToNotifications(context),
            onMenuPressed: () => Scaffold.of(context).openDrawer(),
          ),
          body: vm.isLoading
              ? const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryLight,
            ),
          )
              : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(l10n.reportsFinancialOverview),
                const SizedBox(height: 16),
                _buildSalesChart(vm, l10n, isAr),
                const SizedBox(height: 32),
                _buildSectionHeader(l10n.reportsOperationalPerformance),
                const SizedBox(height: 16),
                _buildTechCommissionList(vm, l10n),
                const SizedBox(height: 32),
                _buildSectionHeader(l10n.reportsInventoryValuation),
                const SizedBox(height: 16),
                _buildInventoryStatus(vm, l10n),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Section header ─────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.h2.copyWith(
        fontSize: 18,
        color: AppColors.secondaryLight,
      ),
    );
  }

  // ── Financial Overview / bar chart ─────────────────────────────────────────
  Widget _buildSalesChart(
      ReportsManagementViewModel vm,
      AppLocalizations l10n,
      bool isAr,
      ) {
    final fin = vm.reportsData?.financialOverview;
    final totalRev = fin?.totalRevenue ?? 0.0;
    final revChange = fin?.revenueChangePercent ?? 0.0;
    final dailyRev = fin?.dailyRevenue ?? [];

    // Translated day labels — same length as dailyRev; fallback to raw value.
    final dayLabels = vm.translatedDayLabels;

    double maxAmt = 1.0;
    if (dailyRev.isNotEmpty) {
      maxAmt = dailyRev.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
      if (maxAmt == 0) maxAmt = 1.0;
    }

    // ── Revenue-change badge ──────────────────────────────────────────────
    // Use l10n helpers to build the badge label so + / − are locale-aware.
    final String revBadgeLabel;
    if (revChange > 0) {
      revBadgeLabel = l10n.reportsRevChangePositive(revChange.toStringAsFixed(1));
    } else if (revChange < 0) {
      revBadgeLabel = l10n.reportsRevChangeNegative(revChange.toStringAsFixed(1));
    } else {
      revBadgeLabel = '';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.reportsTotalRevenue,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  // Amount string — uses l10n.reportsAmountSar so SAR / ر.س
                  // is locale-aware. toStringAsFixed avoids spurious decimals.
                  Text(
                    l10n.reportsAmountSar(totalRev.toStringAsFixed(2)),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              if (revChange != 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (revChange >= 0 ? Colors.green : Colors.red)
                        .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    revBadgeLabel,
                    style: TextStyle(
                      color: revChange >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          // ── Bar chart ─────────────────────────────────────────────────
          SizedBox(
            height: 135,
            child: dailyRev.isEmpty
                ? Align(
              alignment: isAr
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Text(
                l10n.reportsNoDataThisWeek,
                style: const TextStyle(color: Colors.white54),
              ),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              // Reverse row in RTL so bars match reading direction
              children: (isAr
                  ? dailyRev.asMap().entries.toList().reversed
                  : dailyRev.asMap().entries.toList())
                  .map((entry) {
                final idx = entry.key;
                final r = entry.value;
                final isToday =
                    r.date == DateTime.now().toString().split(' ')[0];
                final heightRatio = maxAmt > 0
                    ? (r.amount / maxAmt).clamp(0.0, 1.0)
                    : 0.0;
                // Use translated day label if available, else raw.
                final dayLabel = (idx < dayLabels.length)
                    ? dayLabels[idx]
                    : r.day;
                return _buildBar(
                  dayLabel,
                  heightRatio,
                  r.amount,
                  isToday: isToday,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(
      String day,
      double heightRatio,
      double amount, {
        bool isToday = false,
      }) {
    // Format amount compactly (1k, 2.5k …) — numbers are language-neutral.
    final amountLabel = amount >= 1000
        ? '${(amount / 1000).toStringAsFixed(1)}k'
        : amount.toStringAsFixed(0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          amountLabel,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 24,
          height: (80 * heightRatio).clamp(4.0, 80.0),
          decoration: BoxDecoration(
            color: isToday ? AppColors.primaryLight : Colors.white24,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
      ],
    );
  }

  // ── Operational Performance list ───────────────────────────────────────────
  Widget _buildTechCommissionList(
      ReportsManagementViewModel vm,
      AppLocalizations l10n,
      ) {
    final perf = vm.reportsData?.operationalPerformance;
    if (perf == null || perf.isEmpty) {
      return Text(
        l10n.reportsNoOperationalData,
        style: const TextStyle(color: Colors.grey),
      );
    }

    return Column(
      children: List.generate(perf.length, (idx) {
        final tech = perf[idx];
        // Use pre-translated name; fallback to raw if lists out of sync.
        final translatedName = idx < vm.translatedTechNames.length
            ? vm.translatedTechNames[idx]
            : tech.name;

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
              CircleAvatar(
                backgroundColor: AppColors.primaryLight.withOpacity(0.1),
                child: const Icon(
                  Icons.person_outline,
                  color: AppColors.secondaryLight,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      translatedName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      // Use parameterised l10n key so count is always a number
                      l10n.reportsTotalJobs(tech.totalJobs),
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.reportsAmountSar(tech.commission.toStringAsFixed(2)),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    l10n.reportsCommissionLabel,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  // ── Inventory Valuation ────────────────────────────────────────────────────
  Widget _buildInventoryStatus(
      ReportsManagementViewModel vm,
      AppLocalizations l10n,
      ) {
    final inv = vm.reportsData?.inventoryValuation;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _buildInventoryRow(
            l10n.reportsStockValueCost,
            l10n.reportsAmountSar(
              (inv?.stockValueCost ?? 0.0).toStringAsFixed(2),
            ),
            Colors.blue,
          ),
          const SizedBox(height: 32),
          _buildInventoryRow(
            l10n.reportsPotentialProfit,
            l10n.reportsAmountSar(
              (inv?.potentialProfit ?? 0.0).toStringAsFixed(2),
            ),
            Colors.green,
          ),
          const SizedBox(height: 32),
          _buildInventoryRow(
            l10n.reportsActiveSkus,
            // Use l10n helper so "Items" / "منتج" is locale-aware
            l10n.reportsItemsUnit(inv?.activeSkus ?? 0),
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Coloured indicator bar stays on the logical-start side in RTL
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        // Value — may be long in Arabic; allow it to shrink without overflow
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          ),
        ),
      ],
    );
  }
}