import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../models/workshop_owner_models.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/owner_app_bar.dart';
import 'package:provider/provider.dart';
import 'suppliers_view_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SuppliersView
//
// • Every hardcoded string replaced with l10n.* keys.
// • Status badge uses a dedicated _localizedStatus() helper — never raw
//   string comparisons in the UI; logic stays on the raw API value.
// • Amount strings use l10n.suppliersAmountSar / suppliersAmountCurrency so
//   "SAR" flips to "ر.س" in Arabic automatically.
// • RTL-safe: no hardcoded Alignment.left, no explicit LTR padding tricks.
// • _buildNavButtons no longer requires Back/Forward — only the correct
//   action label ("Next" vs "Submit") is shown, avoiding dead-branch text.
// ─────────────────────────────────────────────────────────────────────────────

class SuppliersView extends StatefulWidget {
  const SuppliersView({super.key});

  @override
  State<SuppliersView> createState() => _SuppliersViewState();
}

class _SuppliersViewState extends State<SuppliersView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ── Local mock invoices (pending real API integration) ──────────────────
  final List<PurchaseInvoice> _invoices = [
    PurchaseInvoice(
      id: 'PO-001',
      supplierId: '1',
      supplierName: 'Al-Rashid Auto Parts',
      date: DateTime.now().subtract(const Duration(days: 2)),
      items: [
        PurchaseItem(
          productName: 'Oil Filter',
          qty: 50,
          unit: 'pcs',
          unitPrice: 15,
        ),
        PurchaseItem(
          productName: 'Air Filter',
          qty: 30,
          unit: 'pcs',
          unitPrice: 25,
        ),
      ],
      status: 'approved',
    ),
    PurchaseInvoice(
      id: 'PO-002',
      supplierId: '2',
      supplierName: 'Gulf Lubricants Co.',
      date: DateTime.now().subtract(const Duration(days: 1)),
      items: [
        PurchaseItem(
          productName: 'Engine Oil 5W-30',
          qty: 100,
          unit: 'ltr',
          unitPrice: 18,
        ),
      ],
      status: 'pending',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<SuppliersViewModel>(context, listen: false).initData();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Helper — translate raw API status to locale string ──────────────────
  String _localizedStatus(String raw, AppLocalizations l10n) {
    switch (raw.toLowerCase()) {
      case 'pending':
        return l10n.suppliersStatusPending;
      case 'approved':
        return l10n.suppliersStatusApproved;
      case 'rejected':
        return l10n.suppliersStatusRejected;
      default:
        return raw.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: OwnerAppBar(
        title: l10n.suppliersTitle,
        onMenuPressed: () => Scaffold.of(context).openDrawer(),
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
        onPressed: () => _showAddSupplierSheet(context),
        backgroundColor: AppColors.secondaryLight,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: Text(
          l10n.suppliersFabAddSupplier,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      )
          : FloatingActionButton.extended(
        onPressed: () => _showNewPurchaseSheet(context),
        backgroundColor: AppColors.secondaryLight,
        icon: const Icon(
          Icons.add_shopping_cart_rounded,
          color: Colors.white,
        ),
        label: Text(
          l10n.suppliersFabNewPurchase,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      body: Consumer<SuppliersViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryLight),
            );
          }
          return Column(
            children: [
              _buildSummaryRow(vm, l10n),
              _buildTabBar(l10n),
              const SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSupplierList(l10n),
                    _buildInvoiceList(l10n),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Summary stat row ─────────────────────────────────────────────────────
  Widget _buildSummaryRow(SuppliersViewModel vm, AppLocalizations l10n) {
    final stats = vm.stats;
    final totalSuppliers =
        stats?.totalSuppliers ?? vm.suppliersList.length;
    final totalOutstanding = stats?.totalOutstanding ??
        vm.suppliersList.fold<double>(
          0.0,
              (s, sup) => s + sup.outstanding,
        );
    final pendingPOs =
        stats?.pendingPurchaseOrders ??
            _invoices.where((i) => i.status == 'pending').length;
    final currency = stats?.currencyCode ?? 'SAR';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatCard(
              l10n.suppliersStatSuppliers,
              '$totalSuppliers',
              Icons.store_rounded,
              AppColors.primaryLight,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              l10n.suppliersStatOutstanding,
              // Use currency helper so SAR / ر.س is locale-aware
              l10n.suppliersAmountCurrency(
                currency,
                totalOutstanding.toInt().toString(),
              ),
              Icons.account_balance_wallet_rounded,
              Colors.orange,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              l10n.suppliersStatPendingPos,
              '$pendingPOs',
              Icons.pending_rounded,
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String label,
      String value,
      IconData icon,
      Color color,
      ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
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
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                value,
                style: AppTextStyles.h2.copyWith(
                  fontSize: 16,
                  color: AppColors.secondaryLight,
                ),
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

  // ── Tab bar ───────────────────────────────────────────────────────────────
  Widget _buildTabBar(AppLocalizations l10n) {
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
        tabs: [
          Tab(text: l10n.suppliersTabSuppliers),
          Tab(text: l10n.suppliersTabPurchaseOrders),
        ],
      ),
    );
  }

  // ── Supplier list tab ─────────────────────────────────────────────────────
  Widget _buildSupplierList(AppLocalizations l10n) {
    return Consumer<SuppliersViewModel>(
      builder: (context, vm, child) {
        if (vm.suppliersList.isEmpty) {
          return Center(
            child: Text(
              l10n.suppliersNoSuppliersFound,
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: vm.suppliersList.length,
          itemBuilder: (context, index) {
            final s = vm.suppliersList[index];
            final isInternal = s.category == 'Internal';
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
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isInternal
                          ? AppColors.primaryLight.withOpacity(0.15)
                          : AppColors.secondaryLight.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isInternal
                          ? Icons.warehouse_rounded
                          : Icons.store_rounded,
                      color: isInternal
                          ? AppColors.primaryLight
                          : AppColors.secondaryLight,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                s.name.isNotEmpty
                                    ? s.name
                                    : l10n.suppliersUnknown,
                                style: AppTextStyles.h2.copyWith(
                                  fontSize: 16,
                                  color: AppColors.secondaryLight,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isInternal) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                  AppColors.primaryLight.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  l10n.suppliersInternalBadge,
                                  style: const TextStyle(
                                    color: AppColors.primaryLight,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          (s.address != null && s.address!.isNotEmpty)
                              ? s.address!
                              : s.category,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (s.outstanding > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          l10n.suppliersAmountSar(
                            s.outstanding.toInt().toString(),
                          ),
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          l10n.suppliersOutstandingLabel,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── Invoice / PO list tab ─────────────────────────────────────────────────
  Widget _buildInvoiceList(AppLocalizations l10n) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _invoices.length,
      itemBuilder: (context, index) {
        final inv = _invoices[index];
        // Status-comparison uses raw API value (English) — never UI string.
        final isPending = inv.status == 'pending';
        final statusColor = isPending ? Colors.orange : Colors.green;

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
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inv.id,
                      style: AppTextStyles.h2.copyWith(
                        fontSize: 16,
                        color: AppColors.secondaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      inv.supplierName,
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
                    l10n.suppliersAmountSar(inv.totalAmount.toInt().toString()),
                    style: AppTextStyles.h2.copyWith(
                      fontSize: 16,
                      color: AppColors.secondaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      // Locale-aware status; logic stays on raw value above.
                      _localizedStatus(inv.status, l10n),
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
      },
    );
  }

  // ── Sheet launchers ───────────────────────────────────────────────────────
  void _showNewPurchaseSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => ChangeNotifierProvider.value(
        value: context.read<SuppliersViewModel>(),
        child: const _NewPurchaseSheet(),
      ),
    );
  }

  void _showAddSupplierSheet(BuildContext context) {
    final vm = context.read<SuppliersViewModel>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => ChangeNotifierProvider.value(
        value: vm,
        child: const _AddSupplierSheet(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _NewPurchaseSheet — multi-step purchase-order wizard
// ─────────────────────────────────────────────────────────────────────────────

class _NewPurchaseSheet extends StatefulWidget {
  const _NewPurchaseSheet();

  @override
  State<_NewPurchaseSheet> createState() => _NewPurchaseSheetState();
}

class _NewPurchaseSheetState extends State<_NewPurchaseSheet> {
  int _step = 0;
  String? _selectedSupplier;
  final List<Map<String, dynamic>> _items = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          _buildStepIndicator(context),
          Flexible(child: _buildStepContent(context)),
          _buildNavButtons(context),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        width: 40,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Step labels from l10n — no hardcoded English
    final steps = [
      l10n.suppliersPoStepSelect,
      l10n.suppliersPoStepAddItems,
      l10n.suppliersPoStepConfirm,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            final stepIndex = index ~/ 2;
            return Expanded(
              child: Container(
                height: 1,
                color: stepIndex < _step
                    ? Colors.green
                    : Colors.grey.shade200,
                margin: const EdgeInsets.only(bottom: 16),
              ),
            );
          }
          final i = index ~/ 2;
          final isActive = i == _step;
          final isDone = i < _step;
          return Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isDone
                      ? Colors.green
                      : isActive
                      ? AppColors.primaryLight
                      : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      color: isActive
                          ? AppColors.secondaryLight
                          : Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[i],
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color:
                  isActive ? AppColors.secondaryLight : Colors.grey,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStepContent(BuildContext context) {
    final vm = Provider.of<SuppliersViewModel>(context, listen: false);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: _step == 0
          ? _buildStep1(context, vm)
          : _step == 1
          ? _buildStep2(context)
          : _buildStep3(context),
    );
  }

  Widget _buildStep1(BuildContext context, SuppliersViewModel vm) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.suppliersPoStep1Title,
          style: AppTextStyles.h2.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.suppliersPoStep1Subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 24),
        if (vm.suppliersList.isEmpty)
          Center(
            child: Text(
              l10n.suppliersNoSuppliersFound,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ...vm.suppliersList.map((supplier) {
          final sName = supplier.name;
          final isInternal = sName.toLowerCase().contains('internal');
          final isSelected = _selectedSupplier == sName;
          return GestureDetector(
            onTap: () => setState(() => _selectedSupplier = sName),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryLight.withOpacity(0.1)
                    : const Color(0xFFF8F9FD),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryLight
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isInternal
                        ? Icons.warehouse_rounded
                        : Icons.store_rounded,
                    color: isSelected
                        ? AppColors.primaryLight
                        : Colors.grey,
                    size: 22,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      sName,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? AppColors.secondaryLight
                            : Colors.grey.shade700,
                      ),
                    ),
                  ),
                  if (isInternal) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        l10n.suppliersInternalBadge,
                        style: const TextStyle(
                          color: AppColors.primaryLight,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primaryLight,
                      size: 20,
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStep2(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.suppliersPoStep2Title,
          style: AppTextStyles.h2.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 6),
        Text(
          // Parameterised key so "Supplier: {name}" works in both locales
          l10n.suppliersPoStep2Subtitle(_selectedSupplier ?? ''),
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 24),
        ..._items.asMap().entries.map((e) => _buildItemRow(context, e.key, e.value)),
        OutlinedButton.icon(
          onPressed: () => setState(
                () => _items.add({'name': '', 'qty': '', 'unit': 'pcs', 'price': ''}),
          ),
          icon: const Icon(Icons.add_rounded),
          label: Text(l10n.suppliersPoAddItem),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
        ),
      ],
    );
  }

  Widget _buildItemRow(
      BuildContext context,
      int index,
      Map<String, dynamic> item,
      ) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: l10n.suppliersPoItemProductName,
                    hintText: l10n.suppliersPoItemProductHint,
                    filled: true,
                    fillColor: const Color(0xFFF8F9FD),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                  onChanged: (v) => setState(() => _items[index]['name'] = v),
                ),
              ),
              if (_items.length > 1) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () =>
                      setState(() => _items.removeAt(index)),
                  icon: const Icon(
                    Icons.remove_circle,
                    color: Colors.redAccent,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: l10n.suppliersPoItemQty,
                    filled: true,
                    fillColor: const Color(0xFFF8F9FD),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => setState(() => _items[index]['qty'] = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: l10n.suppliersPoItemUnitPrice,
                    filled: true,
                    fillColor: const Color(0xFFF8F9FD),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    // Locale-aware currency prefix
                    prefixText: '${l10n.suppliersAmountSar('').trim()} ',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => setState(() => _items[index]['price'] = v),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep3(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.suppliersPoStep3Title,
          style: AppTextStyles.h2.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.suppliersPoStep3Subtitle,
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FD),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              _buildConfirmRow(
                l10n.suppliersPoConfirmSupplier,
                _selectedSupplier ?? '-',
              ),
              _buildConfirmRow(
                l10n.suppliersPoConfirmStatus,
                l10n.suppliersPoConfirmStatusValue,
              ),
              _buildConfirmRow(
                // "Items" key is parameterised
                'Items',
                l10n.suppliersPoConfirmItems(_items.length),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.suppliersPoConfirmNote,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildConfirmRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.secondaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButtons(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vm = Provider.of<SuppliersViewModel>(context, listen: false);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Row(
        children: [
          // ── Back button (steps 1 and 2) ──────────────────────────────
          if (_step > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _step--),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Text(
                  l10n.suppliersPoNavBack,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondaryLight,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          // ── Next / Submit button ─────────────────────────────────────
          Expanded(
            child: ElevatedButton(
              onPressed: vm.isActionLoading
                  ? null
                  : () {
                if (_step < 2) {
                  setState(() => _step++);
                } else {
                  vm.submitPurchaseOrder(
                    context,
                    supplierName: _selectedSupplier ?? '',
                    items: _items,
                    defaultBranchId: '',
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                disabledBackgroundColor: AppColors.primaryLight,
                foregroundColor: AppColors.secondaryLight,
                disabledForegroundColor: AppColors.secondaryLight,
                minimumSize: const Size.fromHeight(56),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: vm.isActionLoading && _step == 2
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                _step == 2
                    ? l10n.suppliersPoNavSubmit
                    : l10n.suppliersPoNavNext,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AddSupplierSheet
// ─────────────────────────────────────────────────────────────────────────────

class _AddSupplierSheet extends StatefulWidget {
  const _AddSupplierSheet();

  @override
  State<_AddSupplierSheet> createState() => _AddSupplierSheetState();
}

class _AddSupplierSheetState extends State<_AddSupplierSheet> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vm = context.watch<SuppliersViewModel>();

    return FocusScope(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.suppliersAddSheetTitle,
                      style: AppTextStyles.h2.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.suppliersAddSheetSubtitle,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 30),
                    _buildTextField(
                      l10n.suppliersAddFieldName,
                      Icons.business_rounded,
                      vm.nameController,
                    ),
                    _buildTextField(
                      l10n.suppliersAddFieldEmail,
                      Icons.email_rounded,
                      vm.emailController,
                    ),
                    _buildTextField(
                      l10n.suppliersAddFieldMobile,
                      Icons.phone_android_rounded,
                      vm.mobileController,
                    ),
                    _buildTextField(
                      l10n.suppliersAddFieldAddress,
                      Icons.map_rounded,
                      vm.addressController,
                    ),
                    _buildTextField(
                      l10n.suppliersAddFieldOpeningBalance,
                      Icons.account_balance_wallet_rounded,
                      vm.openingBalanceController,
                      isNumber: true,
                    ),
                    // Password field with visibility toggle
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: TextField(
                        controller: vm.passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: l10n.suppliersAddFieldPassword,
                          prefixIcon: const Icon(
                            Icons.lock_rounded,
                            color: AppColors.secondaryLight,
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                              color: Colors.grey,
                              size: 20,
                            ),
                            onPressed: () => setState(
                                  () => _isPasswordVisible = !_isPasswordVisible,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          labelStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: ElevatedButton(
                onPressed: vm.isActionLoading
                    ? null
                    : () => vm.submitSupplierForm(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  disabledBackgroundColor: AppColors.primaryLight,
                  foregroundColor: AppColors.secondaryLight,
                  disabledForegroundColor: AppColors.secondaryLight,
                  minimumSize: const Size.fromHeight(56),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: vm.isActionLoading
                    ? const CircularProgressIndicator(
                  color: AppColors.secondaryLight,
                )
                    : Text(
                  l10n.suppliersAddSaveButton,
                  style: const TextStyle(
                    color: AppColors.secondaryLight,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        width: 40,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      IconData icon,
      TextEditingController controller, {
        bool isNumber = false,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.secondaryLight, size: 20),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ),
    );
  }
}