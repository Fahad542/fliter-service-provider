import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../locker_view_model.dart';
import '../../../models/locker_models.dart';
import '../../../utils/app_colors.dart';

class LockerReportsView extends StatelessWidget {
  const LockerReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        appBar: AppBar(
          backgroundColor: AppColors.primaryLight,
          elevation: 0,
          toolbarHeight: 72,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
          title: const Text('FINANCIAL REPORTS', style: TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 2)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.secondaryLight, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.secondaryLight.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                isScrollable: false,
                indicator: BoxDecoration(
                  color: AppColors.secondaryLight,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: [
                    BoxShadow(color: AppColors.secondaryLight.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.secondaryLight.withOpacity(0.4),
                labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 1),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 1),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelPadding: EdgeInsets.zero,
                tabs: const [
                  Tab(text: 'HISTORY', height: 32),
                  Tab(text: 'ANALYTICS', height: 32),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          physics: const BouncingScrollPhysics(),
          children: [
            _buildCollectionHistoryTab(context),
            _buildPerformanceTab(context),
          ],
        ),
      ),
    );
  }


  Widget _buildCollectionHistoryTab(BuildContext context) {
    return Consumer<LockerViewModel>(
      builder: (context, vm, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black.withOpacity(0.04)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.black.withOpacity(0.2), size: 18),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search by Branch or Ref...',
                                hintStyle: TextStyle(color: Colors.black12, fontSize: 12),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black.withOpacity(0.04)),
                    ),
                    child: const Icon(Icons.tune_rounded, color: AppColors.secondaryLight, size: 18),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('AUDIT LOGS', style: TextStyle(color: Colors.black.withOpacity(0.3), fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 1.5)),
                  Row(
                    children: [
                      _buildMiniExportButton(Icons.picture_as_pdf_outlined, 'PDF'),
                      const SizedBox(width: 8),
                      _buildMiniExportButton(Icons.table_view_outlined, 'EXCEL'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                itemCount: vm.collections.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final col = vm.collections[index];
                  return _buildReportCard(col);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMiniExportButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondaryLight, size: 12),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: AppColors.secondaryLight, fontSize: 8, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildReportCard(LockerCollection col) {
    final isMatched = col.difference == 0;
    final color = isMatched ? Colors.teal : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 0), // Changed from 16 to 0 because ListView.separated handles spacing
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TRANSACTION REF',
                    style: TextStyle(color: Colors.black.withOpacity(0.2), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                  Text(
                    'COL-${col.id.substring(col.id.length - 4).toUpperCase()}',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.secondaryLight),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(
                  isMatched ? 'MATCHED' : col.difference > 0 ? 'OVERAGE' : 'VARIANCE',
                  style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
          const Divider(height: 32, color: Colors.black12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    'SAR ${col.receivedAmount.toInt()}',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: AppColors.secondaryLight),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'RECEIVED FUND',
                    style: TextStyle(color: Colors.black.withOpacity(0.2), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('dd MMM, yy').format(col.collectionDate),
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.secondaryLight),
                  ),
                  Text(
                    DateFormat('hh:mm A').format(col.collectionDate),
                    style: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogCard(LockerCollection collection) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'COLLECTION LOG',
                style: TextStyle(color: AppColors.secondaryLight.withOpacity(0.3), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
              const SizedBox(height: 2),
              Text(
                'SAR ${collection.receivedAmount.toInt()}',
                style: const TextStyle(color: AppColors.secondaryLight, fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('hh:mm A').format(collection.collectionDate),
                style: const TextStyle(color: AppColors.secondaryLight, fontSize: 11, fontWeight: FontWeight.w900),
              ),
              Text(
                'SUCCESSFUL',
                style: TextStyle(color: Colors.teal.withOpacity(0.7), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab(BuildContext context) {
    return Consumer<LockerViewModel>(
      builder: (context, vm, child) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('DIFFERENCES SUMMARY', style: TextStyle(color: Colors.black.withOpacity(0.3), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5)),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildSummaryIndicatorCard('TOTAL SHORT', 'SAR ${vm.calculateTotalShort().toInt()}', Colors.red),
                  const SizedBox(width: 12),
                  _buildSummaryIndicatorCard('TOTAL OVER', 'SAR ${vm.calculateTotalOver().toInt()}', Colors.teal),
                ],
              ),
              const SizedBox(height: 12),
              _buildSummaryIndicatorCard('NET DIFFERENCE', 'SAR ${vm.calculateTotalDifferences().toInt()}', AppColors.secondaryLight, fullWidth: true),
              const SizedBox(height: 32),
              const Text('COLLECTION PERFORMANCE', style: TextStyle(color: AppColors.secondaryLight, fontSize: 13, fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              _buildPerformanceChart(),
              const SizedBox(height: 32),
              const Text('OFFICER COMPLIANCE RATINGS', style: TextStyle(color: AppColors.secondaryLight, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
              const SizedBox(height: 16),
              _buildPerformanceRow('K. SALMAN', '99.2%', Colors.teal),
              _buildPerformanceRow('A. ABDULLAH', '100%', Colors.green),
              _buildPerformanceRow('S. NASSER', '94.5%', Colors.orange),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPerformanceChart() {
    return Consumer<LockerViewModel>(
      builder: (context, vm, child) {
        final collections = vm.collections;
        // Build daily totals for the last 7 days
        final now = DateTime.now();
        final List<String> labels = [];
        final List<double> values = [];
        for (int i = 6; i >= 0; i--) {
          final day = now.subtract(Duration(days: i));
          labels.add(['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][day.weekday % 7]);
          final total = collections
              .where((c) =>
                  c.collectionDate.day == day.day &&
                  c.collectionDate.month == day.month &&
                  c.collectionDate.year == day.year)
              .fold(0.0, (sum, c) => sum + c.receivedAmount);
          // Add mock data to make the chart look populated
          final mock = [5200.0, 3100.0, 8900.0, 4500.0, 7200.0, 2800.0, 6300.0];
          values.add(total > 0 ? total : mock[i]);
        }
        final maxVal = values.reduce(max);

        return Container(
          height: 220,
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black.withOpacity(0.04)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WEEKLY COLLECTION VOLUME',
                style: TextStyle(color: Colors.black.withOpacity(0.25), fontWeight: FontWeight.w900, fontSize: 8, letterSpacing: 1.5),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (i) {
                    final barHeight = maxVal > 0 ? (values[i] / maxVal) : 0.0;
                    final isToday = i == 6;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${(values[i] / 1000).toStringAsFixed(1)}k',
                              style: TextStyle(
                                color: isToday ? AppColors.primaryLight : Colors.black.withOpacity(0.25),
                                fontSize: 7,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeOutCubic,
                              height: 110 * barHeight,
                              decoration: BoxDecoration(
                                color: isToday
                                    ? AppColors.primaryLight
                                    : AppColors.primaryLight.withOpacity(0.15),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(7, (i) {
                  final isToday = i == 6;
                  return Expanded(
                    child: Text(
                      labels[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isToday ? AppColors.secondaryLight : Colors.black.withOpacity(0.25),
                        fontSize: 9,
                        fontWeight: isToday ? FontWeight.w900 : FontWeight.w600,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryIndicatorCard(String label, String value, Color color, {bool fullWidth = false}) {
    Widget card = Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color.withOpacity(0.6), fontWeight: FontWeight.w900, fontSize: 8, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18)),
        ],
      ),
    );

    if (fullWidth) return card;
    return Expanded(child: card);
  }

  Widget _buildStatsSummaryCard() {
    return Consumer<LockerViewModel>(
      builder: (context, vm, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.secondaryLight,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: AppColors.secondaryLight.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
            ],
          ),
          child: Column(
            children: [
              Text(
                'SAR ${vm.calculateTodayCollected().toInt()}',
                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1),
              ),
              const SizedBox(height: 4),
              Text(
                'TOTAL ASSETS AUDITED TODAY',
                style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 2),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPerformanceRow(String name, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
