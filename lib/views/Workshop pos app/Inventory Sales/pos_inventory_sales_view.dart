import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/pos_tablet_layout.dart';
import '../../../widgets/pos_widgets.dart';
import '../../../widgets/pos_shell_rail_layout.dart';
import '../../../utils/pos_shell_scaffold.dart' show PosShellScaffoldRegistry;
import '../../Technician App/Notifications/notifications_view.dart';
import '../../../models/inventory_sales_api_model.dart';
import 'inventory_sales_view_model.dart';

/// Cashier drawer tab: quantities sold per product, grouped by day.
class PosInventorySalesView extends StatefulWidget {
  const PosInventorySalesView({super.key});

  @override
  State<PosInventorySalesView> createState() => _PosInventorySalesViewState();
}

class _PosInventorySalesViewState extends State<PosInventorySalesView> {
  DateTime? _draftFrom;
  DateTime? _draftTo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncDraftFromVm());
  }

  void _syncDraftFromVm() {
    if (!mounted) return;
    final vm = context.read<InventorySalesViewModel>();
    final r = vm.resolveDateRange();
    setState(() {
      _draftFrom = r.from;
      _draftTo = r.toInclusive;
    });
  }

  Future<void> _openCustomRange(InventorySalesViewModel vm) async {
    final now = DateTime.now();
    final r = vm.resolveDateRange();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year, now.month, now.day),
      initialDateRange: DateTimeRange(start: r.from, end: r.toInclusive),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.secondaryLight,
            brightness: Brightness.light,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;
    await vm.setCustomRange(picked.start, picked.end);
    if (mounted) _syncDraftFromVm();
  }

  Future<void> _pickDraftFrom() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final vm = context.read<InventorySalesViewModel>();
    final basis = vm.resolveDateRange();
    final last = (_draftTo ?? basis.toInclusive).isAfter(today)
        ? today
        : (_draftTo ?? basis.toInclusive);
    final earliest = DateTime(now.year - 4);
    var cur = _draftFrom ?? basis.from;
    if (cur.isBefore(earliest)) cur = earliest;
    if (cur.isAfter(last)) cur = last;

    final picked = await showDatePicker(
      context: context,
      firstDate: earliest,
      lastDate: last.isBefore(earliest) ? earliest : last,
      initialDate: cur,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.secondaryLight,
            brightness: Brightness.light,
          ),
        ),
        child: child!,
      ),
    );
    if (!mounted || picked == null) return;
    setState(() => _draftFrom = DateTime(picked.year, picked.month, picked.day));
    if (_draftTo != null && _draftFrom!.isAfter(_draftTo!)) {
      setState(() => _draftTo = _draftFrom);
    }
  }

  Future<void> _pickDraftTo() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final vm = context.read<InventorySalesViewModel>();
    final basis = vm.resolveDateRange();
    final cur = _draftTo ?? basis.toInclusive;
    final floor = _draftFrom ?? basis.from;

    final picked = await showDatePicker(
      context: context,
      firstDate: floor.isAfter(today)
          ? today.subtract(const Duration(days: 1))
          : floor,
      lastDate: today,
      initialDate:
      cur.isAfter(today) ? today : (cur.isBefore(floor) ? floor : cur),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.secondaryLight,
            brightness: Brightness.light,
          ),
        ),
        child: child!,
      ),
    );
    if (!mounted || picked == null) return;
    setState(() => _draftTo = DateTime(picked.year, picked.month, picked.day));
    if (_draftFrom != null && _draftTo!.isBefore(_draftFrom!)) {
      setState(() => _draftFrom = _draftTo);
    }
  }

  Future<void> _applyLoadRange(InventorySalesViewModel vm) async {
    final basis = vm.resolveDateRange();
    final a = _draftFrom ?? basis.from;
    final b = _draftTo ?? basis.toInclusive;
    await vm.setExplicitRangeAndFetch(a, b);
    if (mounted) _syncDraftFromVm();
  }

  Future<void> _onPresetChip(
      InventorySalesViewModel vm,
      InventorySalesPreset preset,
      ) async {
    await vm.setPreset(preset);
    if (mounted) _syncDraftFromVm();
  }

  Future<void> _onCustomChip(InventorySalesViewModel vm) async =>
      _openCustomRange(vm);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vm = context.watch<InventorySalesViewModel>();
    final cs = Theme.of(context).colorScheme;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: PosTabletLayout.textScaler(context),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: PosScreenAppBar(
          title: l10n.posInvSalesTitle,
          showBackButton: false,
          showHamburger: true,
          onMenuPressed: () => PosShellScaffoldRegistry.openDrawer(),
          actions: [
            IconButton(
              tooltip: l10n.posInvSalesRefreshTooltip,
              onPressed: vm.isLoading ? null : () => vm.fetch(),
              icon: Icon(
                Icons.refresh_rounded,
                color: vm.isLoading
                    ? Colors.white54
                    : AppColors.secondaryLight,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const NotificationsView(),
                ),
              ),
              child: Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.35),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  size: 21,
                  color: AppColors.secondaryLight,
                ),
              ),
            ),
          ],
        ),
        body: wrapPosShellRailBody(context, _buildBody(context, vm, cs, l10n)),
      ),
    );
  }

  /// Resolves a structured [InventorySalesVmError] into a localized string,
  /// falling back to [vm.errorMessage] for free-text server errors.
  String? _resolveError(InventorySalesViewModel vm, AppLocalizations l10n) {
    if (vm.vmError != null) {
      switch (vm.vmError!) {
        case InventorySalesVmError.startAfterEnd:
          return l10n.posInvSalesErrStartBeforeEnd;
        case InventorySalesVmError.rangeExceeded:
          return l10n.posInvSalesErrRangeExceeded(
              InventorySalesViewModel.maxRangeDaysInclusive);
        case InventorySalesVmError.sessionExpired:
          return l10n.posInvSalesSessionExpiredError;
      }
    }
    return vm.errorMessage;
  }

  Widget _buildBody(
      BuildContext context,
      InventorySalesViewModel vm,
      ColorScheme cs,
      AppLocalizations l10n,
      ) {
    final resolvedError = _resolveError(vm, l10n);

    if (vm.isLoading && vm.lines.isEmpty && resolvedError == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryLight),
      );
    }

    final range = vm.resolveDateRange();
    final rangeStr =
        '${DateFormat.yMMMd().format(range.from)}  —  ${DateFormat.yMMMd().format(range.toInclusive)}';

    final header = Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.posInvSalesPeriodLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: cs.outlineVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            rangeStr,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.25,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );

    // Build preset label list from l10n — keeps switch statement safe for AR
    final presetLabels = _presetLabels(l10n);

    final chips = Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final p in InventorySalesViewModel.presets)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _RangeChip(
                    label: presetLabels[p.$2] ?? p.$1,
                    selected: vm.preset == p.$2,
                    onTap: () => _onPresetChip(vm, p.$2),
                  ),
                ),
              _RangeChip(
                label: l10n.posInvSalesPresetCustom,
                selected: vm.isCustomRange,
                onTap: () => _onCustomChip(vm),
              ),
            ],
          ),
        ),
      ),
    );

    final manualStrip = Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
      child: _ManualRangeStrip(
        draftFromLabel: DateFormat('y-MM-dd').format(_draftFrom ?? range.from),
        draftToLabel: DateFormat('y-MM-dd').format(_draftTo ?? range.toInclusive),
        fromTitle: l10n.posInvSalesFromLabel,
        toTitle: l10n.posInvSalesToLabel,
        loadLabel: l10n.posInvSalesLoadButton,
        loadingLabel: l10n.posInvSalesLoadingButton,
        onTapFrom: _pickDraftFrom,
        onTapTo: _pickDraftTo,
        onLoad: () => _applyLoadRange(vm),
        isLoading: vm.isLoading,
      ),
    );

    final stats = Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth > 720;
          final children = [
            _StatCard(
              icon: Icons.shopping_bag_outlined,
              label: l10n.posInvSalesStatTotalUnits,
              value: _fmtQty(vm.totalQuantitySold),
              accent: const Color(0xFF059669),
            ),
            _StatCard(
              icon: Icons.category_outlined,
              label: l10n.posInvSalesStatUniqueProducts,
              value: '${vm.distinctProductsInPeriod}',
              accent: AppColors.secondaryLight,
            ),
            _StatCard(
              icon: Icons.calendar_today_outlined,
              label: l10n.posInvSalesStatDaysActive,
              value: '${vm.groupedByDay.length}',
              accent: const Color(0xFF7C3AED),
            ),
          ];
          if (wide) {
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < children.length; i++) ...[
                    Expanded(child: children[i]),
                    if (i < children.length - 1) const SizedBox(width: 12),
                  ],
                ],
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                SizedBox(height: i == 0 ? 0 : 10),
                children[i],
              ],
            ],
          );
        },
      ),
    );

    Widget? banner;
    if (resolvedError != null && vm.lines.isNotEmpty) {
      banner = Material(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Colors.red.shade800, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  resolvedError!,
                  style: TextStyle(
                    color: Colors.red.shade900,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
              IconButton(
                tooltip: l10n.posInvSalesDismissTooltip,
                onPressed: vm.dismissErrorBanner,
                icon: Icon(Icons.close_rounded, color: Colors.red.shade800),
              ),
            ],
          ),
        ),
      );
    }

    if (resolvedError != null && vm.lines.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (vm.isLoading)
            const LinearProgressIndicator(
                minHeight: 3, color: AppColors.primaryLight),
          header,
          chips,
          manualStrip,
          stats,
          if (banner != null) banner,
          Expanded(
            child: _ErrorBlock(
              message: resolvedError!,
              retryLabel: l10n.posInvSalesRetry,
              onRetry: vm.fetch,
            ),
          ),
        ],
      );
    }

    final groups = vm.groupedByDay;
    final listArea = Expanded(
      child: RefreshIndicator(
        color: AppColors.primaryLight,
        onRefresh: () => vm.fetch(),
        child: groups.isEmpty
            ? ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(32, 48, 32, 32),
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 72,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.posInvSalesNoSalesTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.posInvSalesNoSalesSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                height: 1.45,
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        )
            : ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          itemCount: groups.length,
          itemBuilder: (context, i) => _DaySection(
            day: groups[i].day,
            rows: groups[i].rows,
            colProduct: l10n.posInvSalesColProduct,
            colSku: l10n.posInvSalesColSku,
            colQty: l10n.posInvSalesColQty,
            daySummaryBuilder: (lineCount, qty) {
              final linesLabel = lineCount == 1
                  ? l10n.posInvSalesDayLines(lineCount)
                  : l10n.posInvSalesDayLinesPlural(lineCount);
              return l10n.posInvSalesDaySummary(linesLabel, qty);
            },
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (vm.isLoading)
          const LinearProgressIndicator(
              minHeight: 3, color: AppColors.primaryLight),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              chips,
              manualStrip,
              stats,
              if (banner != null) banner,
              listArea,
            ],
          ),
        ),
      ],
    );
  }

  /// Maps each preset enum value to its localized label.
  /// Using a Map (not a switch on enum.index) prevents off-by-one mistakes
  /// in Arabic when enum order is reused in other widgets.
  static Map<InventorySalesPreset, String> _presetLabels(AppLocalizations l10n) {
    return {
      InventorySalesPreset.today: l10n.posInvSalesPresetToday,
      InventorySalesPreset.yesterday: l10n.posInvSalesPresetYesterday,
      InventorySalesPreset.last7: l10n.posInvSalesPresetLast7,
      InventorySalesPreset.last30: l10n.posInvSalesPresetLast30,
      InventorySalesPreset.thisMonth: l10n.posInvSalesPresetThisMonth,
      InventorySalesPreset.custom: l10n.posInvSalesPresetCustom,
    };
  }

  static String _fmtQty(num v) {
    if (v == v.round()) return '${v.round()}';
    return v.toDouble().toStringAsFixed(2);
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ManualRangeStrip extends StatelessWidget {
  const _ManualRangeStrip({
    required this.draftFromLabel,
    required this.draftToLabel,
    required this.fromTitle,
    required this.toTitle,
    required this.loadLabel,
    required this.loadingLabel,
    required this.onTapFrom,
    required this.onTapTo,
    required this.onLoad,
    required this.isLoading,
  });

  final String draftFromLabel;
  final String draftToLabel;
  final String fromTitle;
  final String toTitle;
  final String loadLabel;
  final String loadingLabel;
  final VoidCallback onTapFrom;
  final VoidCallback onTapTo;
  final VoidCallback onLoad;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final action = FilledButton.icon(
      onPressed: isLoading ? null : onLoad,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.secondaryLight,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: const Icon(Icons.download_done_rounded, size: 18),
      label: Text(
        isLoading ? loadingLabel : loadLabel,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.07)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth > 620;
          final fromBtn = _DatePill(
            title: fromTitle,
            value: draftFromLabel,
            onTap: isLoading ? null : onTapFrom,
          );
          final toBtn = _DatePill(
            title: toTitle,
            value: draftToLabel,
            onTap: isLoading ? null : onTapTo,
          );
          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: fromBtn),
                const SizedBox(width: 10),
                Expanded(child: toBtn),
                const SizedBox(width: 10),
                action,
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: fromBtn),
                  const SizedBox(width: 10),
                  Expanded(child: toBtn),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(width: double.infinity, child: action),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DatePill extends StatelessWidget {
  const _DatePill({
    required this.title,
    required this.value,
    required this.onTap,
  });

  final String title;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.35,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: 0.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _RangeChip extends StatelessWidget {
  const _RangeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryLight : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primaryLight : Colors.black12,
              width: selected ? 0 : 1,
            ),
            boxShadow: selected
                ? [
              BoxShadow(
                color: AppColors.primaryLight.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: selected
                  ? const Color(0xFF14181F)
                  : const Color(0xFF475569),
              letterSpacing: 0.1,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.35,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DaySection extends StatelessWidget {
  const _DaySection({
    required this.day,
    required this.rows,
    required this.colProduct,
    required this.colSku,
    required this.colQty,
    required this.daySummaryBuilder,
  });

  final DateTime day;
  final List<InventorySaleLine> rows;
  final String colProduct;
  final String colSku;
  final String colQty;
  final String Function(int lineCount, String qty) daySummaryBuilder;

  @override
  Widget build(BuildContext context) {
    var qtySum = 0.0;
    for (final e in rows) {
      qtySum += e.quantitySold.toDouble();
    }

    // Date header uses the active locale automatically via DateFormat
    final dayHeader = DateFormat('EEEE • d MMM yyyy').format(day);

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 5,
                height: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primaryLight,
                      AppColors.secondaryLight,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayHeader,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.25,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('yyyy-MM-dd').format(day),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      daySummaryBuilder(rows.length, _qtyLabel(qtySum)),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withOpacity(0.05)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TableHead(
                  colProduct: colProduct,
                  colSku: colSku,
                  colQty: colQty,
                ),
                Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.grey.shade200),
                for (var i = 0; i < rows.length; i++)
                  _ProductRow(
                    entry: rows[i],
                    stripe: i.isOdd,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _qtyLabel(num q) {
    if (q == q.round()) return '${q.round()}';
    return q.toStringAsFixed(2);
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _TableHead extends StatelessWidget {
  const _TableHead({
    required this.colProduct,
    required this.colSku,
    required this.colQty,
  });

  final String colProduct;
  final String colSku;
  final String colQty;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              colProduct,
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 0.75,
                fontWeight: FontWeight.w800,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              colSku,
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 0.75,
                fontWeight: FontWeight.w800,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          SizedBox(
            width: 92,
            child: Text(
              colQty,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 0.75,
                fontWeight: FontWeight.w800,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.entry,
    required this.stripe,
  });

  final InventorySaleLine entry;
  final bool stripe;

  @override
  Widget build(BuildContext context) {
    // productName comes from the API in English.
    // AppTranslationService.localizedText() handles on-the-fly Arabic
    // translation via TranslatableMixin in the ViewModel — the ViewModel stores
    // raw lines plus translated display strings, so the view simply reads what
    // the ViewModel exposes. See inventory_sales_view_model.dart for the
    // retranslation logic triggered on locale switch.
    final skuText = entry.sku != null && entry.sku!.trim().isNotEmpty
        ? entry.sku!.trim()
        : '—';
    return Material(
      color: stripe ? const Color(0xFFF8FAFC) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Text(
                entry.productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.22,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(
                  skuText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 92,
              child: Text(
                entry.quantityDisplay(),
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.25,
                  color: AppColors.secondaryLight,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ErrorBlock extends StatelessWidget {
  const _ErrorBlock({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_rounded, size: 68, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          SelectableText(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red.shade800, height: 1.35),
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: () => onRetry(),
            icon: const Icon(Icons.refresh_rounded),
            label: Text(retryLabel),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.secondaryLight,
              foregroundColor: Colors.white,
              padding:
              const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}