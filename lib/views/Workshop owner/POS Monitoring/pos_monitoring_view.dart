import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../models/workshop_owner_models.dart';
import '../widgets/owner_app_bar.dart';
import 'pos_monitoring_view_model.dart';

class PosMonitoringView extends StatefulWidget {
  const PosMonitoringView({super.key});

  @override
  State<PosMonitoringView> createState() => _PosMonitoringViewState();
}

class _PosMonitoringViewState extends State<PosMonitoringView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<PosCounter> _liveCounters = [
    PosCounter(id: '1', cashierName: 'Ali Hassan', branchName: 'Riyadh Main', status: 'open', shiftSales: 4250, openOrders: 3, openedAt: DateTime.now().subtract(const Duration(hours: 4))),
    PosCounter(id: '2', cashierName: 'Omar Saeed', branchName: 'Jeddah Center', status: 'open', shiftSales: 2100, openOrders: 1, openedAt: DateTime.now().subtract(const Duration(hours: 2))),
    PosCounter(id: '3', cashierName: 'Sami Khalid', branchName: 'Riyadh Main', status: 'closing', shiftSales: 6800, openOrders: 0, openedAt: DateTime.now().subtract(const Duration(hours: 8))),
  ];

  final List<PosCounter> _closingReports = [
    PosCounter(id: '4', cashierName: 'Rami Yousef', branchName: 'Dammam Branch', status: 'closed', shiftSales: 5200, openOrders: 0, openedAt: DateTime.now().subtract(const Duration(hours: 10)), closedAt: DateTime.now().subtract(const Duration(hours: 1)), systemTotalSales: 5200, physicalCash: 5150),
    PosCounter(id: '5', cashierName: 'Tariq Nasser', branchName: 'Jeddah Center', status: 'closed', shiftSales: 3100, openOrders: 0, openedAt: DateTime.now().subtract(const Duration(hours: 11)), closedAt: DateTime.now().subtract(const Duration(hours: 2)), systemTotalSales: 3100, physicalCash: 3100),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final vm = Provider.of<PosMonitoringViewModel>(context, listen: false);
        vm.fetchPosMonitoring();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: OwnerAppBar(
        title: 'POS Monitoring',
        onMenuPressed: () => Scaffold.of(context).openDrawer(),
      ),
      body: Consumer<PosMonitoringViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryLight));
          }

          return Column(
            children: [
              _buildSummaryBar(vm),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLiveCounters(vm),
                    _buildClosingReports(vm),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryBar(PosMonitoringViewModel vm) {
    final int activeCounters = vm.monitoringResponse?.liveCountersCount ?? _liveCounters.where((c) => c.status == 'open').length;
    final int openOrders = vm.monitoringResponse?.openOrdersCount ?? _liveCounters.fold<int>(0, (s, c) => s + c.openOrders);
    final double totalSales = vm.monitoringResponse?.todaySales ?? _liveCounters.fold<double>(0.0, (s, c) => s + c.shiftSales);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          _buildSummaryCard('Live Counters', '$activeCounters', Icons.point_of_sale_rounded, Colors.green),
          const SizedBox(width: 12),
          _buildSummaryCard('Open Orders', '$openOrders', Icons.pending_actions_rounded, Colors.orange),
          const SizedBox(width: 12),
          _buildSummaryCard('Today Sales', 'SAR ${(totalSales).toInt()}', Icons.payments_rounded, AppColors.primaryLight),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
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
            Text(value, style: AppTextStyles.h2.copyWith(fontSize: 16, color: AppColors.secondaryLight)),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        labelColor: AppColors.secondaryLight,
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        tabs: const [
          Tab(text: 'Live Counters'),
          Tab(text: 'Closing Reports'),
        ],
      ),
    );
  }

  Widget _buildLiveCounters(PosMonitoringViewModel vm) {
    final counters = vm.monitoringResponse?.liveCounters ?? _liveCounters;

    if (counters.isEmpty) {
      return const Center(
        child: Text('No active live counters', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: counters.length,
      itemBuilder: (context, index) => _buildLiveCounterCard(counters[index]),
    );
  }

  Widget _buildLiveCounterCard(PosCounter counter) {
    final isOpen = counter.status == 'open';
    final isClosing = counter.status == 'closing';
    final color = isOpen ? Colors.green : isClosing ? Colors.orange : Colors.grey;

    final elapsed = DateTime.now().difference(counter.openedAt);
    final hours = elapsed.inHours;
    final mins = elapsed.inMinutes % 60;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.person_rounded, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(counter.cashierName, style: AppTextStyles.h2.copyWith(fontSize: 15, color: AppColors.secondaryLight)),
                    const SizedBox(height: 2),
                    Text(counter.branchName, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Text(counter.status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCounterStat('SHIFT SALES', 'SAR ${counter.shiftSales.toInt()}', AppColors.primaryLight),
              _buildCounterStat('OPEN ORDERS', '${counter.openOrders}', Colors.orange),
              _buildCounterStat('ELAPSED', '${hours}h ${mins}m', Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildClosingReports(PosMonitoringViewModel vm) {
    final reports = vm.monitoringResponse?.closingReports ?? _closingReports;

    if (reports.isEmpty) {
      return const Center(
        child: Text('No closing reports available', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: reports.length,
      itemBuilder: (context, index) => _buildClosingCard(reports[index]),
    );
  }

  Widget _buildClosingCard(PosCounter counter) {
    final netDiff = counter.effectiveDiff;
    final isShort = netDiff > 0.01;
    final isExcess = netDiff < -0.01;
    final hasDiff = isShort || isExcess;
    final diffColor = hasDiff ? (isShort ? Colors.red : Colors.green) : Colors.green;
    final diffLabel = isShort ? 'SHORT' : (isExcess ? 'EXCESS' : 'BALANCED');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: hasDiff ? Colors.red.withOpacity(0.18) : Colors.grey.withOpacity(0.08)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: Colors.grey.withOpacity(0.08), shape: BoxShape.circle),
                child: const Icon(Icons.receipt_long_rounded, color: Colors.grey, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(counter.cashierName, style: AppTextStyles.h2.copyWith(fontSize: 15, color: AppColors.secondaryLight)),
                    Text('${counter.branchName} • Closed', style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: diffColor.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                child: Text(
                  diffLabel,
                  style: TextStyle(color: diffColor, fontSize: 10, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Reconciliation table ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFF8F9FD), borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                // Table header
                Row(
                  children: [
                    const Expanded(child: Text('Category', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey))),
                    _tableHeader('System'),
                    _tableHeader('Physical'),
                    _tableHeader('Diff'),
                  ],
                ),
                const Divider(height: 12),
                _reconcRow('Cash',      counter.systemCash,      counter.physicalCash,      counter.diffCash),
                _reconcRow('Bank/Cards', counter.systemBank,     counter.physicalBank,      counter.diffBank),
                _reconcRow('Corporate', counter.systemCorporate, counter.physicalCorporate, counter.diffCorporate),
                _reconcRow('Tamara',    counter.systemTamara,    counter.physicalTamara,    counter.diffTamara),
                _reconcRow('Tabby',     counter.systemTabby,     counter.physicalTabby,     counter.diffTabby),
                const Divider(height: 12),
                // Total sales row
                Row(
                  children: [
                    const Expanded(child: Text('Total Sales', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800))),
                    SizedBox(
                      width: 64,
                      child: Text(
                        'SAR ${counter.effectiveSystemTotal.toStringAsFixed(0)}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.secondaryLight),
                      ),
                    ),
                    SizedBox(
                      width: 64,
                      child: Text(
                        'SAR ${counter.effectivePhysicalTotal.toStringAsFixed(0)}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.green),
                      ),
                    ),
                    SizedBox(
                      width: 52,
                      child: Text(
                        isShort ? '− SAR ${netDiff.abs().toStringAsFixed(0)}' : (isExcess ? '+ SAR ${netDiff.abs().toStringAsFixed(0)}' : '—'),
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: diffColor),
                      ),
                    ),
                  ],
                ),
                if (!counter.isV2) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '⚠ Full breakdown unavailable — deploy latest backend to see per-category data',
                      style: TextStyle(fontSize: 9, color: Colors.orange, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(String label) {
    return SizedBox(
      width: label == 'Diff' ? 52 : 64,
      child: Text(
        label,
        textAlign: TextAlign.right,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey),
      ),
    );
  }

  Widget _reconcRow(String label, double system, double physical, double diff) {
    // diff = system − physical: positive = short (red), negative = excess (green)
    final diffColor = diff.abs() < 0.01 ? Colors.green : (diff > 0 ? Colors.red : Colors.green);
    final diffStr = diff.abs() < 0.01 ? '—' : '${diff > 0 ? "−" : "+"}${diff.abs().toStringAsFixed(0)}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w500))),
          SizedBox(
            width: 64,
            child: Text(
              system.toStringAsFixed(0),
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            width: 64,
            child: Text(
              physical.toStringAsFixed(0),
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(
            width: 52,
            child: Text(
              diffStr,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: diffColor),
            ),
          ),
        ],
      ),
    );
  }
}
