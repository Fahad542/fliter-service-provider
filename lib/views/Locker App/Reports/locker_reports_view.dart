import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart' as xl;
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/locker_financial_models.dart';
import '../../../data/repositories/locker_repository.dart' show LockerBranch;
import '../../../utils/app_colors.dart';
import 'locker_reports_view_model.dart';

// ── Entry point ───────────────────────────────────────────────────────────────

class LockerReportsView extends StatelessWidget {
  const LockerReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LockerReportsViewModel(),
      child: const _LockerReportsBody(),
    );
  }
}

class _LockerReportsBody extends StatefulWidget {
  const _LockerReportsBody();

  @override
  State<_LockerReportsBody> createState() => _LockerReportsBodyState();
}

class _LockerReportsBodyState extends State<_LockerReportsBody>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool _roleResolved = false;
  final _searchController     = TextEditingController();
  final _listScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _listScrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final vm = context.read<LockerReportsViewModel>();
      await vm.init();
      if (!mounted) return;
      final tabCount = vm.isCollector ? 1 : 2;
      _tabController = TabController(length: tabCount, vsync: this);
      setState(() { _roleResolved = true; });
    });
  }

  void _onScroll() {
    if (_listScrollController.position.pixels >=
        _listScrollController.position.maxScrollExtent - 200) {
      context.read<LockerReportsViewModel>().loadMoreHistory();
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _searchController.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vm   = context.watch<LockerReportsViewModel>();

    if (!_roleResolved || _tabController == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FD),
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryLight)),
      );
    }

    final isCollector = vm.isCollector;
    final tabCtrl     = _tabController!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: AppColors.primaryLight,
        elevation: 0,
        toolbarHeight: 72,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        title: Text(
          l10n.lockerFinancialReports,
          style: const TextStyle(
            color: AppColors.secondaryLight,
            fontWeight: FontWeight.w900,
            fontSize: 15,
            letterSpacing: 2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.secondaryLight, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: isCollector
            ? null
            : PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.secondaryLight.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: tabCtrl,
              isScrollable: false,
              indicator: BoxDecoration(
                color: AppColors.secondaryLight,
                borderRadius: BorderRadius.circular(9),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondaryLight.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.secondaryLight.withOpacity(0.4),
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 1),
              unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 1),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelPadding: EdgeInsets.zero,
              tabs: [
                Tab(text: l10n.lockerTabHistory,   height: 32),
                Tab(text: l10n.lockerTabAnalytics, height: 32),
              ],
            ),
          ),
        ),
      ),
      body: isCollector
          ? _buildAnalyticsTab()
          : TabBarView(
        controller: tabCtrl,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildHistoryTab(),
          _buildAnalyticsTab(),
        ],
      ),
    );
  }

  // ── History tab ───────────────────────────────────────────────────────────

  Widget _buildHistoryTab() {
    return Consumer<LockerReportsViewModel>(
      builder: (context, vm, _) {
        return Column(
          children: [
            _buildHistoryFilters(context, vm),
            _buildHistoryToolbar(context, vm),
            Expanded(child: _buildHistoryList(context, vm)),
          ],
        );
      },
    );
  }

  Widget _buildHistoryFilters(
      BuildContext context, LockerReportsViewModel vm) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _SearchField(
                  controller: _searchController,
                  hintText: l10n.lockerSearchByRefOrOfficer,
                  onChanged: vm.onSearchChanged,
                ),
              ),
              const SizedBox(width: 10),
              _SortButton(vm: vm),
            ],
          ),
          const SizedBox(height: 10),
          _BranchDropdown(
            selectedBranchId: vm.selectedBranchId,
            branches: vm.branches,
            isLoading: vm.branchesLoading,
            onChanged: (branchId) => vm.setSelectedBranch(branchId),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _DateRangeChip(
                  from: vm.historyFrom,
                  to:   vm.historyTo,
                  onTap: () => _pickHistoryDateRange(context, vm),
                ),
              ),
              if (vm.hasActiveHistoryFilters) ...[
                const SizedBox(width: 10),
                _ClearButton(onTap: () {
                  _searchController.clear();
                  vm.clearHistoryFilters();
                }),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryToolbar(
      BuildContext context, LockerReportsViewModel vm) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.lockerAuditLogs,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.3),
                  fontWeight: FontWeight.w900,
                  fontSize: 9,
                  letterSpacing: 1.5,
                ),
              ),
              if (vm.isHistorySuccess)
                Text(
                  l10n.lockerRecordsCount(vm.totalItems),
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.4),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          Row(
            children: [
              _ExportButton(
                icon: Icons.picture_as_pdf_outlined,
                label: l10n.lockerExportPdf,
                isLoading: vm.isExporting,
                onTap: vm.isHistorySuccess && !vm.isExporting
                    ? () => _exportPdf(context, vm)
                    : null,
              ),
              const SizedBox(width: 8),
              _ExportButton(
                icon: Icons.table_view_outlined,
                label: l10n.lockerExportExcel,
                isLoading: vm.isExporting,
                onTap: vm.isHistorySuccess && !vm.isExporting
                    ? () => _exportExcel(context, vm)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(
      BuildContext context, LockerReportsViewModel vm) {
    final l10n = AppLocalizations.of(context)!;
    if (vm.isHistoryLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryLight));
    }
    if (vm.isHistoryError) {
      return _ErrorState(
        message: vm.historyError ?? l10n.lockerAnErrorOccurred,
        onRetry: vm.refreshHistory,
      );
    }
    final items = vm.sortedHistory;
    if (items.isEmpty) {
      return _EmptyState(
        message: vm.hasActiveHistoryFilters
            ? l10n.lockerNoResultsMatchFilters
            : l10n.lockerNoAuditLogsFound,
        onRefresh: vm.refreshHistory,
      );
    }
    return RefreshIndicator(
      color: AppColors.primaryLight,
      onRefresh: vm.refreshHistory,
      child: ListView.separated(
        controller: _listScrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        itemCount: items.length + (vm.isHistoryLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, i) {
          if (i == items.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primaryLight),
              ),
            );
          }
          return _AuditLogCard(entry: items[i]);
        },
      ),
    );
  }

  // ── Analytics tab ─────────────────────────────────────────────────────────

  Widget _buildAnalyticsTab() {
    return Consumer<LockerReportsViewModel>(
      builder: (context, vm, _) {
        final l10n = AppLocalizations.of(context)!;
        if (vm.isAnalyticsLoading) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryLight));
        }
        if (vm.isAnalyticsError) {
          return _ErrorState(
            message: vm.analyticsError ?? l10n.lockerAnErrorOccurred,
            onRetry: vm.refreshAnalytics,
          );
        }
        final data = vm.analytics;
        return RefreshIndicator(
          color: AppColors.primaryLight,
          onRefresh: vm.refreshAnalytics,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 48 -
                          (vm.hasActiveAnalyticsFilters ? 90 : 0),
                      child: _DateRangeChip(
                        from: vm.analyticsFrom,
                        to:   vm.analyticsTo,
                        onTap: () => _pickAnalyticsDateRange(context, vm),
                      ),
                    ),
                    if (vm.hasActiveAnalyticsFilters)
                      _ClearButton(onTap: vm.clearAnalyticsFilters),
                  ],
                ),
                const SizedBox(height: 24),
                if (data != null) _RangeLabel(range: data.range),
                const SizedBox(height: 8),

                Text(
                  l10n.lockerDifferencesSummary,
                  style: const TextStyle(
                    color: AppColors.secondaryLight,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount:
                  MediaQuery.of(context).size.width < 380 ? 1 : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio:
                  MediaQuery.of(context).size.width < 380 ? 2.8 : 1.0,
                  children: [
                    _buildKPICard(
                      label: l10n.lockerTotalShort,
                      value:
                      '${l10n.lockerSarCurrency} ${_fmt(data?.differencesSummary.totalShort ?? 0)}',
                      icon: Icons.arrow_downward_rounded,
                      accent: Colors.red,
                      isAlert:
                      (data?.differencesSummary.totalShort ?? 0) != 0,
                    ),
                    _buildKPICard(
                      label: l10n.lockerTotalOver,
                      value:
                      '${l10n.lockerSarCurrency} ${_fmt(data?.differencesSummary.totalOver ?? 0)}',
                      icon: Icons.arrow_upward_rounded,
                      accent: Colors.teal,
                    ),
                    _buildKPICard(
                      label: l10n.lockerNetDifference,
                      value:
                      '${l10n.lockerSarCurrency} ${_fmt(data?.differencesSummary.netDifference ?? 0)}',
                      icon: Icons.compare_arrows_rounded,
                      accent: AppColors.secondaryLight,
                      isAlert:
                      (data?.differencesSummary.netDifference ?? 0) != 0,
                    ),
                    _buildKPICard(
                      label: l10n.lockerTotalCollections,
                      value:
                      '${data?.weeklyCollectionVolume.fold<double>(0, (s, e) => s + e.totalReceived).toInt() ?? 0}',
                      icon: Icons.payments_outlined,
                      accent: Colors.indigo,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                Text(
                  vm.isCollector
                      ? l10n.lockerMyCollectionPerformance
                      : l10n.lockerCollectionPerformance,
                  style: const TextStyle(
                    color: AppColors.secondaryLight,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                if (data != null && data.weeklyCollectionVolume.isNotEmpty)
                  _WeeklyChart(entries: data.weeklyCollectionVolume)
                else
                  _WeeklyChart(entries: const []),
                const SizedBox(height: 32),

                if (!vm.isCollector) ...[
                  Text(
                    l10n.lockerOfficerComplianceRatings,
                    style: const TextStyle(
                      color: AppColors.secondaryLight,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (data == null || data.officerCompliance.isEmpty)
                    _EmptyInline(message: l10n.lockerNoComplianceData)
                  else
                    ...data.officerCompliance
                        .map((e) => _OfficerComplianceRow(entry: e))
                        .toList(),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ── KPI card ──────────────────────────────────────────────────────────────

  Widget _buildKPICard({
    required String label,
    required String value,
    required IconData icon,
    required Color accent,
    bool isAlert = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -10, right: -10,
            child: Icon(icon, color: accent.withOpacity(0.05), size: 80),
          ),
          if (isAlert)
            Positioned(
              top: 10, right: 10,
              child: Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: accent, size: 18),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value,
                        style: const TextStyle(
                            color: AppColors.secondaryLight,
                            fontSize: 18,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: 1),
                    Text(label,
                        style: TextStyle(
                            color: Colors.black.withOpacity(0.3),
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Date range pickers ────────────────────────────────────────────────────

  Future<void> _pickHistoryDateRange(
      BuildContext context, LockerReportsViewModel vm) async {
    final picked = await _showDateRangeDialog(context,
        initialRange: vm.historyFrom != null && vm.historyTo != null
            ? DateTimeRange(start: vm.historyFrom!, end: vm.historyTo!)
            : null);
    if (picked != null) await vm.setHistoryDateRange(picked.start, picked.end);
  }

  Future<void> _pickAnalyticsDateRange(
      BuildContext context, LockerReportsViewModel vm) async {
    final picked = await _showDateRangeDialog(context,
        initialRange: vm.analyticsFrom != null && vm.analyticsTo != null
            ? DateTimeRange(start: vm.analyticsFrom!, end: vm.analyticsTo!)
            : null);
    if (picked != null) await vm.setAnalyticsDateRange(picked.start, picked.end);
  }

  Future<DateTimeRange?> _showDateRangeDialog(BuildContext context,
      {DateTimeRange? initialRange}) async {
    return showDialog<DateTimeRange>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (ctx) => _DateRangeDialog(
        initialFrom: initialRange?.start,
        initialTo:   initialRange?.end,
      ),
    );
  }

  // ── Export ────────────────────────────────────────────────────────────────

  Future<bool> _ensureStoragePermission(BuildContext context) async {
    if (!Platform.isAndroid) return true;
    final sdkInt = await _getAndroidSdkInt();
    if (sdkInt >= 29) return true;
    final status = await Permission.storage.status;
    if (status.isGranted) return true;
    final result = await Permission.storage.request();
    if (result.isGranted) return true;
    if (result.isPermanentlyDenied && context.mounted) {
      _showPermissionDeniedDialog(context);
    }
    return false;
  }

  Future<int> _getAndroidSdkInt() async {
    try { return 33; } catch (_) { return 33; }
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.lockerStoragePermissionRequired,
            style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 15,
                color: AppColors.secondaryLight)),
        content: Text(l10n.lockerStoragePermissionBody,
            style: const TextStyle(fontSize: 13, color: Colors.black54)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.lockerCancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryLight,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text(l10n.lockerOpenSettings),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAndOpen(BuildContext context,
      {required List<int> bytes,
        required String fileName,
        required String mimeType}) async {
    final dir  = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    if (Platform.isAndroid) {
      final sdkInt = await _getAndroidSdkInt();
      if (sdkInt >= 29) {
        await Share.shareXFiles([XFile(file.path, mimeType: mimeType)],
            subject: fileName);
        return;
      }
    }
    await OpenFile.open(file.path);
  }

  Future<void> _exportPdf(
      BuildContext context, LockerReportsViewModel vm) async {
    if (!await _ensureStoragePermission(context)) return;
    vm.setExportState(ExportState.exporting);
    try {
      final items = vm.sortedHistory;
      final doc   = pw.Document();
      final fmt   = DateFormat('dd MMM yyyy');
      final now   = fmt.format(DateTime.now());
      final l10n  = AppLocalizations.of(context)!;

      doc.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(l10n.lockerFinancialHistoryPdfTitle,
                style: pw.TextStyle(
                    fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text(_buildFilterLabel(vm, l10n),
                style: const pw.TextStyle(
                    fontSize: 9, color: PdfColors.grey600)),
            pw.Text(
                '${l10n.lockerPdfGenerated}: $now   |   ${l10n.lockerPdfTotal}: ${items.length} ${l10n.lockerPdfRecords}',
                style: const pw.TextStyle(
                    fontSize: 9, color: PdfColors.grey600)),
            pw.SizedBox(height: 8),
            pw.Divider(),
          ],
        ),
        build: (_) => [
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(1.4),
              1: const pw.FlexColumnWidth(1.2),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(1),
              4: const pw.FlexColumnWidth(1),
              5: const pw.FlexColumnWidth(1),
              6: const pw.FlexColumnWidth(1.5),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  l10n.lockerPdfRef,
                  l10n.lockerPdfDate,
                  l10n.lockerPdfBranch,
                  l10n.lockerPdfReceived,
                  l10n.lockerPdfExpected,
                  l10n.lockerPdfDiff,
                  l10n.lockerPdfStatus,
                ].map((h) => _pdfCell(h, isHeader: true)).toList(),
              ),
              ...items.map((e) => pw.TableRow(children: [
                _pdfCell(e.transactionRef),
                _pdfCell(DateFormat('dd MMM yy').format(e.collectedAt)),
                _pdfCell(e.branchName),
                _pdfCell('${e.currency} ${e.receivedFund.toInt()}'),
                _pdfCell('${e.currency} ${e.expectedAmount.toInt()}'),
                _pdfCell('${e.currency} ${e.difference.toInt()}'),
                _pdfCell(_localizedMatchStatus(e.matchStatus, l10n),
                    color: _pdfStatusColor(e.matchStatus)),
              ])),
            ],
          ),
        ],
      ));

      final pdfBytes = await doc.save();
      final fileName =
          'locker_history_${DateTime.now().millisecondsSinceEpoch}.pdf';
      vm.setExportState(ExportState.done);
      if (!context.mounted) return;
      await _saveAndOpen(context,
          bytes: pdfBytes, fileName: fileName, mimeType: 'application/pdf');
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      vm.setExportState(ExportState.error,
          error: '${l10n.lockerPdfExportFailed}: $e');
      if (context.mounted) _showExportError(context, vm.exportError!);
    }
  }

  Future<void> _exportExcel(
      BuildContext context, LockerReportsViewModel vm) async {
    if (!await _ensureStoragePermission(context)) return;
    vm.setExportState(ExportState.exporting);
    try {
      final l10n  = AppLocalizations.of(context)!;
      final items = vm.sortedHistory;
      final excel = xl.Excel.createExcel();
      final sheet = excel[l10n.lockerExcelSheetName];

      final headers = [
        l10n.lockerPdfRef,
        l10n.lockerPdfDate,
        l10n.lockerPdfBranch,
        l10n.lockerExcelOfficer,
        l10n.lockerExcelReceivedSar,
        l10n.lockerExcelExpectedSar,
        l10n.lockerExcelDiffSar,
        l10n.lockerPdfStatus,
        l10n.lockerExcelRequestRef,
      ];
      for (var i = 0; i < headers.length; i++) {
        final cell = sheet.cell(
            xl.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = xl.TextCellValue(headers[i]);
        cell.cellStyle = xl.CellStyle(bold: true);
      }

      for (var r = 0; r < items.length; r++) {
        final e   = items[r];
        final row = [
          e.transactionRef,
          DateFormat('dd MMM yyyy HH:mm').format(e.collectedAt.toLocal()),
          e.branchName,
          e.officerName,
          e.receivedFund.toStringAsFixed(2),
          e.expectedAmount.toStringAsFixed(2),
          e.difference.toStringAsFixed(2),
          _localizedMatchStatus(e.matchStatus, l10n),
          e.requestRef,
        ];
        for (var c = 0; c < row.length; c++) {
          sheet
              .cell(xl.CellIndex.indexByColumnRow(
              columnIndex: c, rowIndex: r + 1))
              .value = xl.TextCellValue(row[c]);
        }
      }

      if (excel.sheets.containsKey('Sheet1')) excel.delete('Sheet1');
      final bytes    = excel.save();
      if (bytes == null) throw Exception('Excel encoder returned null bytes.');
      final fileName =
          'locker_history_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      vm.setExportState(ExportState.done);
      if (!context.mounted) return;
      await _saveAndOpen(context,
          bytes: bytes,
          fileName: fileName,
          mimeType:
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      vm.setExportState(ExportState.error,
          error: '${l10n.lockerExcelExportFailed}: $e');
      if (context.mounted) _showExportError(context, vm.exportError!);
    }
  }

  void _showExportError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red.shade700,
      behavior: SnackBarBehavior.floating,
    ));
  }

  String _buildFilterLabel(LockerReportsViewModel vm, AppLocalizations l10n) {
    final parts = <String>[];
    if (vm.searchQuery.isNotEmpty) {
      parts.add('${l10n.lockerFilterSearch}: "${vm.searchQuery}"');
    }
    if (vm.branchFilter != null) {
      parts.add('${l10n.lockerFilterBranch}: ${vm.branchFilter}');
    }
    if (vm.historyFrom != null || vm.historyTo != null) {
      final f = vm.historyFrom != null
          ? DateFormat('dd MMM yy').format(vm.historyFrom!)
          : '…';
      final t = vm.historyTo != null
          ? DateFormat('dd MMM yy').format(vm.historyTo!)
          : '…';
      parts.add('$f → $t');
    }
    return parts.isEmpty ? l10n.lockerAllRecords : parts.join('  •  ');
  }

  pw.Widget _pdfCell(String text,
      {bool isHeader = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(text,
          style: pw.TextStyle(
            fontSize: isHeader ? 8 : 7,
            fontWeight:
            isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: color,
          )),
    );
  }

  PdfColor _pdfStatusColor(String status) {
    switch (status) {
      case 'MATCHED': return PdfColors.teal;
      case 'OVER':    return PdfColors.green;
      case 'SHORT':   return PdfColors.red;
      default:        return PdfColors.orange;
    }
  }

  String _fmt(double v) => v.toInt().toString();

  /// Translates raw API match-status strings to localized labels.
  String _localizedMatchStatus(String status, AppLocalizations l10n) {
    switch (status.toUpperCase()) {
      case 'MATCHED': return l10n.lockerStatusMatched;
      case 'SHORT':   return l10n.lockerShortLabel;
      case 'OVER':    return l10n.lockerOverLabel;
      default:        return status.replaceAll('_', ' ');
    }
  }
}

// ── Date range dialog ─────────────────────────────────────────────────────────

class _DateRangeDialog extends StatefulWidget {
  final DateTime? initialFrom;
  final DateTime? initialTo;
  const _DateRangeDialog({this.initialFrom, this.initialTo});

  @override
  State<_DateRangeDialog> createState() => _DateRangeDialogState();
}

class _DateRangeDialogState extends State<_DateRangeDialog> {
  DateTime? _from;
  DateTime? _to;
  final _fmt = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _from = widget.initialFrom;
    _to   = widget.initialTo;
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final initial = isFrom
        ? (_from ?? DateTime.now())
        : (_to ?? _from ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.secondaryLight,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
          dialogTheme: DialogThemeData(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _from = picked;
        if (_to != null && _to!.isBefore(_from!)) _to = null;
      } else {
        _to = picked;
        if (_from != null && _from!.isAfter(_to!)) _from = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryLight.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.date_range_rounded,
                      color: AppColors.secondaryLight, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.lockerSelectDateRange,
                  style: const TextStyle(
                    color: AppColors.secondaryLight,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _DatePickerTile(
                    label: l10n.lockerDateFrom,
                    date: _from,
                    fmt: _fmt,
                    onTap: () => _pickDate(isFrom: true),
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward_rounded,
                    size: 16, color: Colors.black26),
                const SizedBox(width: 12),
                Expanded(
                  child: _DatePickerTile(
                    label: l10n.lockerDateTo,
                    date: _to,
                    fmt: _fmt,
                    onTap: () => _pickDate(isFrom: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.black.withOpacity(0.1)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(l10n.lockerCancel,
                        style: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _from != null && _to != null
                        ? () => Navigator.pop(
                        context, DateTimeRange(start: _from!, end: _to!))
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryLight,
                      disabledBackgroundColor:
                      AppColors.secondaryLight.withOpacity(0.3),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: Text(l10n.lockerApplyFilter,
                        style: const TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  final String label;
  final DateTime? date;
  final DateFormat fmt;
  final VoidCallback onTap;

  const _DatePickerTile({
    required this.label,
    required this.date,
    required this.fmt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n   = AppLocalizations.of(context)!;
    final hasDate = date != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: hasDate
              ? AppColors.secondaryLight.withOpacity(0.05)
              : Colors.black.withOpacity(0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasDate
                ? AppColors.secondaryLight.withOpacity(0.2)
                : Colors.black.withOpacity(0.06),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: hasDate
                      ? AppColors.secondaryLight.withOpacity(0.7)
                      : Colors.black26,
                )),
            const SizedBox(height: 4),
            Text(
              hasDate ? fmt.format(date!) : l10n.lockerTapToSet,
              style: TextStyle(
                fontSize: 11,
                fontWeight: hasDate ? FontWeight.w800 : FontWeight.normal,
                color: hasDate ? AppColors.secondaryLight : Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable widgets ──────────────────────────────────────────────────────────

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final ValueChanged<String> onChanged;

  const _SearchField({
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.prefixIcon = Icons.search,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Icon(prefixIcon, color: Colors.black.withOpacity(0.2), size: 17),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: Colors.black12, fontSize: 12),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BranchDropdown extends StatelessWidget {
  final String? selectedBranchId;
  final List<LockerBranch> branches;
  final bool isLoading;
  final ValueChanged<String?> onChanged;

  const _BranchDropdown({
    required this.selectedBranchId,
    required this.branches,
    required this.onChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n     = AppLocalizations.of(context)!;
    final isActive = selectedBranchId != null;

    final items = <DropdownMenuItem<String?>>[
      DropdownMenuItem<String?>(
        value: null,
        child: Text(l10n.lockerAllBranches,
            style: const TextStyle(
                fontSize: 12,
                color: Colors.black38,
                fontWeight: FontWeight.normal)),
      ),
      ...branches.map((b) => DropdownMenuItem<String?>(
        value: b.id,
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined,
                size: 14, color: Colors.black38),
            const SizedBox(width: 8),
            Expanded(
              child: Text(b.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      )),
    ];

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.secondaryLight.withOpacity(0.04)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? AppColors.secondaryLight.withOpacity(0.2)
              : Colors.black.withOpacity(0.04),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on_outlined,
              color: isActive
                  ? AppColors.secondaryLight
                  : Colors.black.withOpacity(0.2),
              size: 17),
          const SizedBox(width: 8),
          if (isLoading)
            Expanded(
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 1.5, color: Colors.black26),
                  ),
                  const SizedBox(width: 8),
                  Text(l10n.lockerLoadingBranches,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black26)),
                ],
              ),
            )
          else
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: selectedBranchId,
                  hint: Text(l10n.lockerFilterByBranch,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black26)),
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 18, color: Colors.black26),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                    isActive ? FontWeight.w700 : FontWeight.normal,
                    color: isActive
                        ? AppColors.secondaryLight
                        : Colors.black54,
                  ),
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  menuMaxHeight: 280,
                  items: items,
                  onChanged: onChanged,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  final LockerReportsViewModel vm;
  const _SortButton({required this.vm});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSortSheet(context),
      child: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withOpacity(0.04)),
        ),
        child: const Icon(Icons.sort_rounded,
            color: AppColors.secondaryLight, size: 18),
      ),
    );
  }

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: vm,
        child: const _SortSheet(),
      ),
    );
  }
}

class _SortSheet extends StatelessWidget {
  const _SortSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vm   = context.watch<LockerReportsViewModel>();
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text(l10n.lockerSortBy,
              style: const TextStyle(
                color: AppColors.secondaryLight,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 2,
              )),
          const SizedBox(height: 16),
          ..._sortOptions(vm, context, l10n),
        ],
      ),
    );
  }

  List<Widget> _sortOptions(LockerReportsViewModel vm, BuildContext context,
      AppLocalizations l10n) {
    final options = [
      (field: HistorySortField.date, label: l10n.lockerSortDate),
      (field: HistorySortField.amount, label: l10n.lockerSortReceivedAmount),
      (field: HistorySortField.difference, label: l10n.lockerSortDifference),
    ];
    return options.map((opt) {
      final isActive = vm.sortField == opt.field;
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          isActive
              ? (vm.sortOrder == HistorySortOrder.asc
              ? Icons.arrow_upward_rounded
              : Icons.arrow_downward_rounded)
              : Icons.swap_vert_rounded,
          color: isActive ? AppColors.secondaryLight : Colors.black26,
          size: 20,
        ),
        title: Text(opt.label,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
              color: isActive ? AppColors.secondaryLight : Colors.black54,
              fontSize: 13,
            )),
        trailing: isActive
            ? Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.secondaryLight.withOpacity(0.08),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            vm.sortOrder == HistorySortOrder.asc
                ? l10n.lockerSortAsc
                : l10n.lockerSortDesc,
            style: const TextStyle(
                color: AppColors.secondaryLight,
                fontSize: 9,
                fontWeight: FontWeight.w900),
          ),
        )
            : null,
        onTap: () {
          vm.toggleSort(opt.field);
          Navigator.pop(context);
        },
      );
    }).toList();
  }
}

class _DateRangeChip extends StatelessWidget {
  final DateTime? from;
  final DateTime? to;
  final VoidCallback onTap;

  const _DateRangeChip(
      {required this.from, required this.to, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n     = AppLocalizations.of(context)!;
    final hasRange = from != null || to != null;
    final fmt      = DateFormat('dd MMM yy');
    final label    = hasRange
        ? '${from != null ? fmt.format(from!) : '…'}  →  ${to != null ? fmt.format(to!) : '…'}'
        : l10n.lockerSelectDateRange;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: hasRange
              ? AppColors.secondaryLight.withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasRange
                ? AppColors.secondaryLight.withOpacity(0.2)
                : Colors.black.withOpacity(0.04),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.date_range_rounded,
                size: 16,
                color:
                hasRange ? AppColors.secondaryLight : Colors.black26),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight:
                    hasRange ? FontWeight.w700 : FontWeight.normal,
                    color: hasRange
                        ? AppColors.secondaryLight
                        : Colors.black26,
                  )),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 16, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}

class _ClearButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ClearButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(Icons.close_rounded, size: 14, color: Colors.red.shade400),
            const SizedBox(width: 6),
            Text(l10n.lockerClearFilters,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: Colors.red.shade400,
                  letterSpacing: 1,
                )),
          ],
        ),
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isLoading;
  final VoidCallback? onTap;

  const _ExportButton({
    required this.icon,
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: onTap != null
              ? AppColors.secondaryLight.withOpacity(0.06)
              : Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(8),
        ),
        child: isLoading
            ? SizedBox(
          width: 12, height: 12,
          child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: AppColors.secondaryLight.withOpacity(0.5)),
        )
            : Row(
          children: [
            Icon(icon,
                color: onTap != null
                    ? AppColors.secondaryLight
                    : Colors.black26,
                size: 12),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                  color: onTap != null
                      ? AppColors.secondaryLight
                      : Colors.black26,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                )),
          ],
        ),
      ),
    );
  }
}

class _AuditLogCard extends StatelessWidget {
  final AuditLogEntry entry;
  const _AuditLogCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(entry.matchStatus);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4)),
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
                    AppLocalizations.of(context)!.lockerTransactionRef,
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.2),
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1),
                  ),
                  Text(entry.transactionRef,
                      style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: AppColors.secondaryLight)),
                ],
              ),
              _StatusBadge(status: entry.matchStatus, color: color),
            ],
          ),
          Divider(height: 24, color: Colors.black.withOpacity(0.05)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.currency} ${entry.receivedFund.toInt()}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: AppColors.secondaryLight),
                  ),
                  Text(
                    AppLocalizations.of(context)!.lockerReceivedFundLabel,
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.2),
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(DateFormat('dd MMM, yy').format(entry.collectedAt),
                      style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          color: AppColors.secondaryLight)),
                  Text(DateFormat('hh:mm a').format(entry.collectedAt),
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.3),
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.02),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _MetaItem(
                      icon: Icons.location_on_outlined, value: entry.branchName),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MetaItem(
                      icon: Icons.person_outline_rounded,
                      value: entry.officerName),
                ),
                _DifferenceChip(
                    difference: entry.difference, currency: entry.currency),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'MATCHED': return Colors.teal;
      case 'OVER':    return Colors.green;
      case 'SHORT':   return Colors.red;
      default:        return Colors.orange;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;
  const _StatusBadge({required this.status, required this.color});

  /// Maps raw API match-status strings to localized labels.
  String _localizedLabel(AppLocalizations l10n) {
    switch (status.toUpperCase()) {
      case 'MATCHED': return l10n.lockerStatusMatched;
      case 'SHORT':   return l10n.lockerShortLabel;
      case 'OVER':    return l10n.lockerOverLabel;
      default:        return status.replaceAll('_', ' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(_localizedLabel(l10n),
          style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 8,
              letterSpacing: 0.5)),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String value;
  const _MetaItem({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.black26),
        const SizedBox(width: 4),
        Expanded(
          child: Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Colors.black.withOpacity(0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

class _DifferenceChip extends StatelessWidget {
  final double difference;
  final String currency;
  const _DifferenceChip(
      {required this.difference, required this.currency});

  @override
  Widget build(BuildContext context) {
    final isZero     = difference == 0;
    final isPositive = difference > 0;
    final color      = isZero
        ? Colors.teal
        : (isPositive ? Colors.green : Colors.red);
    final sign = isPositive ? '+' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text('$sign${difference.toInt()} $currency',
          style: TextStyle(
              color: color, fontSize: 9, fontWeight: FontWeight.w900)),
    );
  }
}

class _RangeLabel extends StatelessWidget {
  final AnalyticsRange range;
  const _RangeLabel({required this.range});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yy');
    return Text(
      '${fmt.format(range.from.toLocal())}  –  ${fmt.format(range.to.toLocal())}',
      style: TextStyle(
          color: Colors.black.withOpacity(0.35),
          fontSize: 11,
          fontWeight: FontWeight.w700),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final List<WeeklyVolumeEntry> entries;
  const _WeeklyChart({required this.entries});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (entries.isEmpty) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black.withOpacity(0.04)),
        ),
        child: Center(
          child: Text(l10n.lockerNoData,
              style: const TextStyle(color: Colors.black26, fontSize: 12)),
        ),
      );
    }

    final values  = entries.map((e) => e.totalReceived).toList();
    final labels  = entries.map((e) => e.day).toList();
    final maxVal  = values.reduce(max);
    final lastIdx = values.length - 1;

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
          Text(l10n.lockerWeeklyCollectionVolume,
              style: TextStyle(
                  color: Colors.black.withOpacity(0.25),
                  fontWeight: FontWeight.w900,
                  fontSize: 8,
                  letterSpacing: 1.5)),
          const SizedBox(height: 12),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(values.length, (i) {
                final barH  = maxVal > 0 ? (values[i] / maxVal) : 0.0;
                final isLast = i == lastIdx;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          values[i] >= 1000
                              ? '${(values[i] / 1000).toStringAsFixed(1)}k'
                              : values[i].toInt().toString(),
                          style: TextStyle(
                              color: isLast
                                  ? AppColors.primaryLight
                                  : Colors.black.withOpacity(0.25),
                              fontSize: 7,
                              fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutCubic,
                          height: max(2.0, 110 * barH),
                          decoration: BoxDecoration(
                            color: isLast
                                ? AppColors.primaryLight
                                : AppColors.primaryLight.withOpacity(0.15),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6)),
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
            children: List.generate(labels.length, (i) {
              final isLast = i == lastIdx;
              return Expanded(
                child: Text(labels[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isLast
                          ? AppColors.secondaryLight
                          : Colors.black.withOpacity(0.25),
                      fontSize: 9,
                      fontWeight:
                      isLast ? FontWeight.w900 : FontWeight.w600,
                    )),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _OfficerComplianceRow extends StatelessWidget {
  final OfficerComplianceEntry entry;
  const _OfficerComplianceRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final l10n  = AppLocalizations.of(context)!;
    final pct   = entry.compliancePercent;
    final color = pct >= 95
        ? Colors.green
        : pct >= 80
        ? Colors.orange
        : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // officer name comes from API — translated in VM
                Text(entry.name,
                    style: const TextStyle(
                        color: AppColors.secondaryLight,
                        fontWeight: FontWeight.w900,
                        fontSize: 12)),
                Text(
                  entry.collectionsCount == 1
                      ? l10n.lockerOneCollection
                      : l10n.lockerNCollections(entry.collectionsCount),
                  style: TextStyle(
                      color: Colors.black.withOpacity(0.3),
                      fontSize: 10,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('${pct.toStringAsFixed(1)}%',
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration:
              BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
              child: Icon(Icons.wifi_off_rounded,
                  size: 32, color: Colors.red.shade400),
            ),
            const SizedBox(height: 16),
            Text(l10n.lockerFailedToLoad,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.secondaryLight)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.black45, fontSize: 12)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text(l10n.lockerRetry),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryLight,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final VoidCallback onRefresh;
  const _EmptyState({required this.message, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_rounded, size: 48, color: Colors.black12),
          const SizedBox(height: 12),
          Text(message,
              style: const TextStyle(color: Colors.black38, fontSize: 13)),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: Text(l10n.lockerRefresh),
            style: TextButton.styleFrom(
                foregroundColor: AppColors.secondaryLight),
          ),
        ],
      ),
    );
  }
}

class _EmptyInline extends StatelessWidget {
  final String message;
  const _EmptyInline({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Center(
        child: Text(message,
            style: const TextStyle(color: Colors.black38, fontSize: 12)),
      ),
    );
  }
}