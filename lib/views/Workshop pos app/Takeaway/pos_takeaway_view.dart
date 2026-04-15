import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_formatters.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/pos_tablet_layout.dart';
import '../../../models/pos_order_model.dart';
import '../../../models/takeaway_models.dart';
import '../../../widgets/pos_widgets.dart';
import '../../../widgets/pos_shell_rail_layout.dart';
import '../Home Screen/pos_view_model.dart';
import '../Order Screen/pos_order_review_view.dart';
import '../Promo/promo_code_dialog.dart';
import '../Promo/promo_view_model.dart';
import 'takeaway_view_model.dart';

extension _TakeawayStockUi on TakeawayProduct {
  Color get _stockColor {
    if (!isActive) return Colors.grey;
    if (qtyOnHand > 5) return const Color(0xFF4CAF50);
    if (qtyOnHand > 0) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  String get _stockLabel {
    if (!isActive) return 'Inactive';
    final q = qtyOnHand == qtyOnHand.roundToDouble()
        ? qtyOnHand.round()
        : qtyOnHand;
    if (qtyOnHand > 5) return 'In Stock ($q)';
    if (qtyOnHand > 0) return 'Low ($q)';
    return 'Out of Stock';
  }
}

/// Same layout & styling as [PosProductGridView] (main tab), wired to takeaway catalog + checkout.
class PosTakeawayView extends StatefulWidget {
  const PosTakeawayView({super.key});

  @override
  State<PosTakeawayView> createState() => _PosTakeawayViewState();
}

class _PosTakeawayViewState extends State<PosTakeawayView> {
  final ScrollController _departmentScrollController = ScrollController();
  final ScrollController _categoryScrollController = ScrollController();
  String? _lastCategoryDeptId;

  @override
  void dispose() {
    _departmentScrollController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final vm = context.watch<TakeawayViewModel>();
    final currentDeptId = vm.selectedDepartmentId;
    if (_lastCategoryDeptId != currentDeptId) {
      _lastCategoryDeptId = currentDeptId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_departmentScrollController.hasClients) {
          _departmentScrollController.jumpTo(0);
        }
        if (_categoryScrollController.hasClients) {
          _categoryScrollController.jumpTo(0);
        }
      });
    }

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: PosTabletLayout.textScaler(context),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F3F0),
        appBar: PosScreenAppBar(
          title: 'Takeaway',
          showBackButton: false,
          showGlobalLeft: true,
          showHamburger: false,
        ),
        body: wrapPosShellRailBody(
          context,
          vm.catalogLoading && vm.catalog == null
              ? const Center(child: CircularProgressIndicator())
              : vm.catalogError != null && vm.catalog == null
                  ? _buildCatalogError(context, vm.catalogError!)
                  : _buildProductSection(context, vm, isTablet),
        ),
        bottomNavigationBar: (isTablet || vm.cartLineCount == 0)
            ? const SizedBox.shrink()
            : _buildBottomBar(context, vm, isTablet),
      ),
    );
  }

  Widget _buildCatalogError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade700),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  context.read<TakeawayViewModel>().loadCatalog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: AppColors.secondaryLight,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSection(
    BuildContext context,
    TakeawayViewModel vm,
    bool isTablet,
  ) {
    if (isTablet) {
      final isPortrait =
          MediaQuery.of(context).orientation == Orientation.portrait;
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 14, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (vm.catalog != null && vm.catalogHasProducts) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: PosSearchBar(
                              controller: vm.searchController,
                              onChanged: vm.setSearchQuery,
                              hintText: 'Search products & services...',
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton.filledTonal(
                            onPressed: () => vm.loadCatalog(),
                            icon: const Icon(Icons.refresh_rounded),
                            tooltip: 'Refresh',
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 14, 22, 6),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            controller: _departmentScrollController,
                            scrollDirection: Axis.horizontal,
                            child: IntrinsicHeight(
                              child: Row(
                                children: [
                                  _buildDeptTab(
                                    context,
                                    vm,
                                    label: 'All',
                                    departmentId: null,
                                    isTablet: true,
                                    minWidth: 88,
                                  ),
                                  for (final d in vm.catalog!.departments)
                                    _buildDeptTab(
                                      context,
                                      vm,
                                      label: d.name,
                                      departmentId: d.id,
                                      isTablet: true,
                                      minWidth: 100,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    _buildCategoryChips(context, vm, true),
                  ],
                  const SizedBox(height: 10),
                  Expanded(
                    child: vm.catalog != null && !vm.catalogHasProducts
                        ? _buildEmptyState(true)
                        : _buildListBody(context, vm, isTablet, isPortrait),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 360,
              child: _buildLiveInvoicePanel(context, vm),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (vm.catalog != null && vm.catalogHasProducts) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: PosSearchBar(
                    controller: vm.searchController,
                    onChanged: vm.setSearchQuery,
                    hintText: 'Search products & services...',
                  ),
                ),
                IconButton(
                  onPressed: () => vm.loadCatalog(),
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: SingleChildScrollView(
                  controller: _departmentScrollController,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildDeptTab(
                        context,
                        vm,
                        label: 'All',
                        departmentId: null,
                        isTablet: false,
                        minWidth: 72,
                      ),
                      for (final d in vm.catalog!.departments)
                        _buildDeptTab(
                          context,
                          vm,
                          label: d.name,
                          departmentId: d.id,
                          isTablet: false,
                          minWidth: 88,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _buildCategoryChips(context, vm, false),
        ],
        const SizedBox(height: 8),
        Expanded(
          child: vm.catalog != null && !vm.catalogHasProducts
              ? _buildEmptyState(false)
              : _buildListBody(context, vm, isTablet, true),
        ),
      ],
    );
  }

  /// Right column on tablet — mirrors Products tab live invoice (narrow panel + totals).
  Widget _buildLiveInvoicePanel(BuildContext context, TakeawayViewModel vm) {
    final currency = vm.catalog?.currency ?? 'SAR';
    
    final subtotal = vm.subtotalBeforeOrderDiscount;
    final orderDiscInput = double.tryParse(vm.orderDiscountValueController.text.trim()) ?? 0.0;
    final isOrderDiscPercent = vm.orderDiscountType == 'percent' || vm.orderDiscountType == 'percentage';
    final orderDisc = isOrderDiscPercent
        ? (subtotal * (orderDiscInput / 100)).clamp(0, subtotal).toDouble()
        : orderDiscInput.clamp(0, subtotal).toDouble();
    final afterOrderDiscount = (subtotal - orderDisc).clamp(0, double.infinity).toDouble();

    final promoDiscount = vm.isPromoPercent
        ? (afterOrderDiscount * (vm.promoDiscountValue / 100))
            .clamp(0, afterOrderDiscount)
            .toDouble()
        : vm.promoDiscountValue.clamp(0, afterOrderDiscount).toDouble();
    final taxable = (afterOrderDiscount - promoDiscount)
        .clamp(0, double.infinity)
        .toDouble();

    final vatPercent = double.tryParse(vm.vatController.text.trim()) ?? vm.catalog?.vatPercentDefault ?? 0.0;
    final vatAmount = taxable * (vatPercent / 100);
    
    Widget buildRow(String label, String value, {Color? color, FontWeight weight = FontWeight.w500}) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color ?? Colors.grey.shade600,
              fontWeight: weight,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color ?? const Color(0xFF1E2124),
            ),
          ),
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Order Items',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.secondaryLight,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${vm.cartLineCount}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E2124),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          Expanded(
            child: vm.cart.isEmpty
                ? Center(
                    child: Text(
                      'No items in invoice',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                    itemCount: vm.cart.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) => _TakeawayCartItemCompactTile(
                      key: ValueKey(vm.cart[index].product.id),
                      line: vm.cart[index],
                      currency: currency,
                      vm: vm,
                      isTablet: false,
                    ),
                  ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildRow('Gross Amount (Excl. VAT)', '$currency ${subtotal.toStringAsFixed(2)}'),
                const SizedBox(height: 6),
                
                // Interactive Discount Row
                Row(
                  children: [
                    const Text(
                      'Total discount',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 50,
                      height: 22,
                      child: TextField(
                        controller: vm.orderDiscountValueController,
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          final d = double.tryParse(val) ?? 0;
                          vm.setOrderDiscountValue(d);
                        },
                        style: const TextStyle(fontSize: 11, color: Colors.green),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          hintText: '0',
                          hintStyle: const TextStyle(color: Colors.green),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(color: Colors.green),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(color: Colors.green),
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        vm.setOrderDiscountType(
                          isOrderDiscPercent ? 'amount' : 'percent',
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: Text(
                          isOrderDiscPercent ? '%' : currency,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 6),
                buildRow('Price after total discount', '$currency ${afterOrderDiscount.toStringAsFixed(2)}'),
                const SizedBox(height: 8),
                
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7E6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFFC145).withOpacity(0.6)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_offer_outlined,
                        size: 16,
                        color: Colors.amber.shade700,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: vm.cart.isEmpty ? null : () => _openTakeawayPromoFromPanel(context),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                              child: Text(
                                vm.promoCodeController.text.trim().isEmpty
                                    ? 'Add Promo Code'
                                    : 'Promo: ${vm.promoCodeController.text.trim()}',
                                style: const TextStyle(
                                  color: Color(0xFF1E2124),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (vm.promoCodeController.text.trim().isNotEmpty)
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          icon: Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              color: AppColors.secondaryLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 14, color: Colors.white),
                          ),
                          onPressed: () {
                            final posVm = context.read<PosViewModel>();
                            final promoVm = context.read<PromoViewModel>();
                            posVm.clearPromoCode(isMainTab: false);
                            promoVm.promoController.clear();
                            promoVm.clearPromoError();
                            vm.clearAppliedPromo();
                            vm.refreshPreview();
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                if (promoDiscount > 0) ...[
                  buildRow('Promo discount', '-$currency ${promoDiscount.toStringAsFixed(2)}', color: Colors.green),
                  const SizedBox(height: 6),
                ],
                buildRow('Price after promo', '$currency ${taxable.toStringAsFixed(2)}'),
                const SizedBox(height: 6),
                buildRow('VAT ($vatPercent%)', '$currency ${vatAmount.toStringAsFixed(2)}'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                    const Spacer(),
                    Text(
                      '$currency ${vm.estimatedDisplayTotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 44,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: vm.cartLineCount == 0 ? null : () => _openCheckout(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryLight,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Generate Invoice',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openTakeawayPromoFromPanel(BuildContext context) async {
    final vm = context.read<TakeawayViewModel>();
    await showDialog<void>(
      context: context,
      builder: (_) => const PromoCodeDialog(isMainTab: false),
    );
    if (!context.mounted) return;
    final posVm = context.read<PosViewModel>();
    final code = posVm.getActivePromoCode(false).trim();
    if (code.isNotEmpty) {
      vm.setAppliedPromo(
        code: code,
        promoId: posVm.activePromoCodeId,
        discount: posVm.promoDiscount,
        isPercent: posVm.isPromoPercent,
      );
    } else {
      vm.clearAppliedPromo();
    }
    vm.refreshPreview();
  }

  Widget _buildDeptTab(
    BuildContext context,
    TakeawayViewModel vm, {
    required String label,
    required String? departmentId,
    required bool isTablet,
    required double minWidth,
  }) {
    final selected = departmentId == null || departmentId.isEmpty
        ? vm.selectedDepartmentId == null || vm.selectedDepartmentId!.isEmpty
        : vm.selectedDepartmentId == departmentId;
    return GestureDetector(
      onTap: () => vm.setSelectedDepartmentId(departmentId),
      child: Container(
        constraints: BoxConstraints(minWidth: minWidth),
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 14 : 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected
                  ? AppColors.secondaryLight
                  : AppColors.secondaryLight.withOpacity(0.6),
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              fontSize: isTablet ? 13 : 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(
    BuildContext context,
    TakeawayViewModel vm,
    bool isTablet,
  ) {
    final subCats = vm.takeawayCategoryChipNames;
    final displaySubCats = ['All', ...subCats];
    return SizedBox(
      height: isTablet ? 56 : 44,
      child: ListView.builder(
        controller: _categoryScrollController,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 22 : 12,
          vertical: 6,
        ),
        itemCount: displaySubCats.length,
        itemBuilder: (context, index) {
          final subCat = displaySubCats[index];
          final isSelected = vm.selectedCategory == subCat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: GestureDetector(
                onTap: () => vm.setSelectedCategory(subCat),
                child: Container(
                  height: isTablet ? 40 : 34,
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.secondaryLight : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.secondaryLight
                          : Colors.grey.shade300,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.secondaryLight.withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    subCat,
                    style: TextStyle(
                      fontSize: isTablet ? 12 : 11,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isTablet) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'No products found',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildListBody(
    BuildContext context,
    TakeawayViewModel vm,
    bool isTablet,
    bool isPortrait,
  ) {
    final filtered = vm.visibleProducts;
    final currency = vm.catalog?.currency ?? 'SAR';

    if (filtered.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => vm.loadCatalog(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.35,
              child: Center(
                child: Text(
                  'No products match your search.',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (isTablet) {
      return RefreshIndicator(
        onRefresh: () => vm.loadCatalog(),
        child: GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isPortrait ? 2 : 3,
            mainAxisExtent: 156,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final product = filtered[index];
            return Consumer<TakeawayViewModel>(
              builder: (context, tvm, _) {
                final qty = tvm.qtyInCartForProduct(product.id);
                return _buildProductCardTablet(
                  context,
                  tvm,
                  product,
                  qty,
                  currency,
                );
              },
            );
          },
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => vm.loadCatalog(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 6),
        itemBuilder: (context, index) {
          final product = filtered[index];
          return Consumer<TakeawayViewModel>(
            builder: (context, tvm, _) {
              final qty = tvm.qtyInCartForProduct(product.id);
              return _buildProductCardMobile(
                context,
                tvm,
                product,
                qty,
                currency,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProductCardMobile(
    BuildContext context,
    TakeawayViewModel vm,
    TakeawayProduct product,
    double cartQty,
    String currency,
  ) {
    final canSelect = product.isActive && product.qtyOnHand > 0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canSelect ? () => vm.addProduct(product) : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: cartQty > 0
                ? Border.all(color: AppColors.primaryLight, width: 2)
                : Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: cartQty > 0 ? 44 : 0,
                                  ),
                                  child: Text(
                                    product.name,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: product.isActive
                                          ? null
                                          : Colors.grey,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          if (product.unit != null &&
                              product.unit!.isNotEmpty) ...[
                            Text(
                              'Unit: ${product.unit}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: product._stockColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              product._stockLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: product._stockColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (cartQty > 0)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              'x${cartQty % 1 == 0 ? cartQty.toInt() : cartQty}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: AppColors.secondaryLight,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$currency ${product.allowDecimalQty ? product.salePrice.toStringAsFixed(2) : product.salePrice.toInt()}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppColors.secondaryLight,
                      ),
                    ),
                    if (canSelect) ...[
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _qtyButton(
                            Icons.remove,
                            false,
                            onTap: cartQty > 0
                                ? () => vm.bumpProductQuantity(
                                      product,
                                      product.allowDecimalQty ? -0.5 : -1,
                                    )
                                : null,
                          ),
                          GestureDetector(
                            onTap: () => _showQtyDialog(context, vm, product, false),
                            child: Container(
                              height: 24,
                              width: 28,
                              alignment: Alignment.center,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Text(
                                (!product.allowDecimalQty || cartQty % 1 == 0)
                                    ? '${cartQty.toInt()}'
                                    : cartQty.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          _qtyButton(
                            Icons.add,
                            false,
                            onTap: () => vm.addProduct(product),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCardTablet(
    BuildContext context,
    TakeawayViewModel vm,
    TakeawayProduct product,
    double cartQty,
    String currency,
  ) {
    final canSelect = product.isActive && product.qtyOnHand > 0;
    return Stack(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: canSelect ? () => vm.addProduct(product) : null,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: cartQty > 0
                    ? Border.all(color: AppColors.primaryLight, width: 2)
                    : Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(9, 8, 9, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 36,
                          child: Text(
                            product.name,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              height: 1.2,
                              color: product.isActive ? null : Colors.grey,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          height: 16,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: (product.unit != null &&
                                    product.unit!.isNotEmpty)
                                ? Text(
                                    'Unit: ${product.unit}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),
                        SizedBox(
                          height: 22,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: product._stockColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                product._stockLabel,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: product._stockColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$currency ${product.allowDecimalQty ? product.salePrice.toStringAsFixed(2) : product.salePrice.toInt()}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            height: 1.1,
                            color: AppColors.secondaryLight,
                          ),
                        ),
                      ],
                    ),
                    if (canSelect)
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            children: [
                              _qtyButton(
                                Icons.remove,
                                true,
                                onTap: cartQty > 0
                                    ? () => vm.bumpProductQuantity(
                                          product,
                                          product.allowDecimalQty
                                              ? -0.5
                                              : -1,
                                        )
                                    : null,
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      _showQtyDialog(context, vm, product, true),
                                  child: Container(
                                    height: 28,
                                    alignment: Alignment.center,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(7),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: Text(
                                      (!product.allowDecimalQty ||
                                              cartQty % 1 == 0)
                                          ? '${cartQty.toInt()}'
                                          : cartQty.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              _qtyButton(
                                Icons.add,
                                true,
                                onTap: () => vm.addProduct(product),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (cartQty > 0)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                'x${cartQty % 1 == 0 ? cartQty.toInt() : cartQty}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppColors.secondaryLight,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _qtyButton(IconData icon, bool isTablet, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: onTap != null ? AppColors.secondaryLight : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(
          icon,
          size: 14,
          color: onTap != null ? Colors.white : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    TakeawayViewModel vm,
    bool isTablet,
  ) {
    final currency = vm.catalog?.currency ?? 'SAR';
    return Container(
      padding: EdgeInsets.fromLTRB(
        isTablet ? 18 : 16,
        12,
        isTablet ? 18 : 16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: isTablet ? 20 : 17,
                  color: const Color(0xFF1E2124),
                ),
                const SizedBox(width: 8),
                Text(
                  '${vm.cartItemCountDisplay} items',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E2124),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: isTablet ? 12 : 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Grand Total',
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 10,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$currency ${vm.estimatedDisplayTotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: isTablet ? 19 : 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E2124),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: isTablet ? 48 : 46,
            child: ElevatedButton.icon(
              onPressed: () => _openCheckout(context, isTablet),
              icon: Icon(
                Icons.receipt_long_outlined,
                size: isTablet ? 20 : 18,
              ),
              label: Text(
                'Generate Invoice',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: isTablet ? 14 : 13,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC145),
                foregroundColor: const Color(0xFF1E2124),
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 18 : 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openCheckout(BuildContext context, bool isTablet) {
    if (context.read<TakeawayViewModel>().cart.isEmpty) return;
    final vm = context.read<TakeawayViewModel>();
    final previewOrder = _buildTakeawayPreviewOrder(vm);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PosOrderReviewView(order: previewOrder),
      ),
    );
  }

  PosOrder _buildTakeawayPreviewOrder(TakeawayViewModel vm) {
    final now = DateTime.now();
    double lineDiscountAmount(TakeawayCartLine line) {
      final gross = line.unitPriceExclVat * line.qty;
      final type = (line.lineDiscountType ?? '').toLowerCase();
      if (type == 'percent' || type == 'percentage') {
        return (gross * (line.lineDiscountValue / 100)).clamp(0, gross);
      }
      return line.lineDiscountValue.clamp(0, gross);
    }

    final grossSubtotal = vm.cart.fold<double>(
      0,
      (s, line) => s + (line.unitPriceExclVat * line.qty),
    );
    final totalItemDiscount = vm.cart.fold<double>(
      0,
      (s, line) => s + lineDiscountAmount(line),
    );
    final double subtotalAfterItemDiscount = max(
      0.0,
      grossSubtotal - totalItemDiscount,
    );

    final orderDiscountInput =
        double.tryParse(vm.orderDiscountValueController.text.trim()) ?? 0;
    final orderDiscountIsPercent =
        vm.orderDiscountType == 'percent' ||
        vm.orderDiscountType == 'percentage';
    final orderDiscountAmountRaw = orderDiscountIsPercent
        ? (subtotalAfterItemDiscount * (orderDiscountInput / 100))
        : orderDiscountInput;
    final double orderDiscountAmount = min(
      subtotalAfterItemDiscount,
      max(0.0, orderDiscountAmountRaw),
    );

    final double afterOrderDiscount = max(
      0.0,
      subtotalAfterItemDiscount - orderDiscountAmount,
    );

    final promoDiscountAmountRaw = vm.isPromoPercent
        ? (afterOrderDiscount * (vm.promoDiscountValue / 100))
        : vm.promoDiscountValue;
    final double promoDiscountAmount = min(
      afterOrderDiscount,
      max(0.0, promoDiscountAmountRaw),
    );
    final double netSubtotal = max(0.0, afterOrderDiscount - promoDiscountAmount);
    final vatPercent = double.tryParse(vm.vatController.text.trim()) ?? 15.0;
    final vatAmount = netSubtotal * (vatPercent / 100);
    final totalAmount = netSubtotal + vatAmount;

    final items = vm.cart
        .map((line) {
          final gross = line.unitPriceExclVat * line.qty;
          final lineDisc = lineDiscountAmount(line);
          final lineNet = max(0.0, gross - lineDisc);
          return PosOrderJobItem(
            id: 'takeaway-${line.product.id}',
            itemType: 'product',
            productId: line.product.id,
            productName: line.product.name,
            departmentId: line.product.department.id,
            departmentName: line.product.department.name,
            qty: line.qty,
            unitPrice: line.unitPrice,
            lineTotal: lineNet,
            discountType: line.lineDiscountType,
            discountValue: line.lineDiscountValue,
          );
        })
        .toList();

    final jobs = <PosOrderJob>[
      PosOrderJob(
        id: 'takeaway-preview-job',
        status: 'draft',
        department: 'Takeaway',
        items: items,
        totalAmount: totalAmount,
        vatAmount: vatAmount,
        vatPercent: vatPercent,
        totalDiscountType:
            orderDiscountAmount > 0 ? vm.orderDiscountType : null,
        totalDiscountValue: orderDiscountAmount > 0
            ? (orderDiscountIsPercent ? orderDiscountInput : orderDiscountAmount)
            : 0.0,
        promoCodeId: vm.appliedPromoCodeId,
        promoCodeName: vm.appliedPromoCode.isEmpty ? null : vm.appliedPromoCode,
        promoDiscountType: vm.isPromoPercent ? 'percent' : 'amount',
        promoDiscountValue: vm.isPromoPercent ? vm.promoDiscountValue : 0.0,
        promoDiscountAmount: promoDiscountAmount,
      ),
    ];

    return PosOrder(
      id: 'takeaway-preview',
      status: 'draft',
      source: 'takeaway',
      odometerReading: 0,
      createdAt: now.toIso8601String(),
      orderDate: now.toIso8601String().split('T').first,
      orderDateTime: now.toIso8601String(),
      customer: OrderCustomer(
        id: 'walkin',
        name: 'Walk-in Customer',
        mobile: '',
      ),
      vehicle: OrderVehicle(
        id: 'na',
        plateNo: '',
        make: '',
        model: '',
      ),
      jobsCount: jobs.length,
      jobs: jobs,
      items: items,
      subtotal: subtotalAfterItemDiscount,
      totalAmount: totalAmount,
      totalDiscountType: orderDiscountAmount > 0 ? vm.orderDiscountType : null,
      totalDiscountValue: orderDiscountAmount > 0
          ? (orderDiscountIsPercent ? orderDiscountInput : orderDiscountAmount)
          : 0.0,
      promoCodeId: vm.appliedPromoCodeId,
      promoCodeName: vm.appliedPromoCode.isEmpty ? null : vm.appliedPromoCode,
      promoDiscountType: vm.isPromoPercent ? 'percent' : 'amount',
      promoDiscountValue: vm.isPromoPercent ? vm.promoDiscountValue : 0.0,
      promoDiscountAmount: promoDiscountAmount,
    );
  }


  void _showQtyDialog(
    BuildContext context,
    TakeawayViewModel vm,
    TakeawayProduct product,
    bool isTablet,
  ) {
    final currentQty = vm.qtyInCartForProduct(product.id);
    final controller = TextEditingController(
      text: (!product.allowDecimalQty || currentQty % 1 == 0)
          ? currentQty.toInt().toString()
          : currentQty.toString(),
    );
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Enter Quantity',
          style: TextStyle(
            fontSize: isTablet ? 22 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              product.name,
              style: TextStyle(
                color: Colors.grey,
                fontSize: isTablet ? 16 : 12,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.numberWithOptions(
                decimal: product.allowDecimalQty,
              ),
              inputFormatters: [
                if (!product.allowDecimalQty)
                  FilteringTextInputFormatter.digitsOnly,
                if (product.allowDecimalQty) EnglishNumberFormatter(),
              ],
              autofocus: true,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isTablet ? 22 : 18,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: '0',
                suffixText: product.unit,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final qty = double.tryParse(controller.text) ?? 0;
              vm.applyProductQuantity(product, qty);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: AppColors.secondaryLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class _TakeawayCartItemCompactTile extends StatefulWidget {
  const _TakeawayCartItemCompactTile({
    super.key,
    required this.line,
    required this.currency,
    required this.vm,
    required this.isTablet,
  });

  final TakeawayCartLine line;
  final String currency;
  final TakeawayViewModel vm;
  final bool isTablet;

  @override
  State<_TakeawayCartItemCompactTile> createState() => _TakeawayCartItemCompactTileState();
}

class _TakeawayCartItemCompactTileState extends State<_TakeawayCartItemCompactTile> {
  late TextEditingController _discController;

  @override
  void initState() {
    super.initState();
    _discController = TextEditingController(
      text: widget.line.lineDiscountValue > 0
          ? (widget.line.lineDiscountValue % 1 == 0
              ? widget.line.lineDiscountValue.toInt().toString()
              : widget.line.lineDiscountValue.toString())
          : '',
    );
  }

  @override
  void didUpdateWidget(_TakeawayCartItemCompactTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.line.lineDiscountValue != widget.line.lineDiscountValue) {
      final text = widget.line.lineDiscountValue > 0
          ? (widget.line.lineDiscountValue % 1 == 0
              ? widget.line.lineDiscountValue.toInt().toString()
              : widget.line.lineDiscountValue.toString())
          : '';
      if (_discController.text != text) {
        _discController.text = text;
      }
    }
  }

  @override
  void dispose() {
    _discController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final line = widget.line;
    final isTablet = widget.isTablet;
    final isPercent = (line.lineDiscountType ?? '') == 'percent' ||
        (line.lineDiscountType ?? '') == 'percentage';
    final grossLineTotal = line.unitPriceExclVat * line.qty;
    final lineDiscountAmount = isPercent
        ? (grossLineTotal * (line.lineDiscountValue / 100))
        : line.lineDiscountValue;
    final safeDiscount = min(grossLineTotal, max(0.0, lineDiscountAmount));
    final discountedLineTotal = max(0.0, grossLineTotal - safeDiscount);
    
    return Container(
      padding: EdgeInsets.only(
        left: isTablet ? 14 : 12,
        right: isTablet ? 12 : 10,
        top: isTablet ? 12 : 10,
        bottom: isTablet ? 12 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 13 : 14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      line.product.name,
                      style: TextStyle(
                        fontSize: isTablet ? 17 : 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E2124),
                        height: isTablet ? 1.2 : 1.15,
                      ),
                      maxLines: isTablet ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (safeDiscount > 0)
                        Text(
                          '${widget.currency} ${grossLineTotal.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: isTablet ? 13 : 10,
                            color: Colors.grey.shade400,
                            decoration: TextDecoration.lineThrough,
                            fontWeight: FontWeight.w600,
                            height: 1.1,
                          ),
                        ),
                      Text(
                        '${widget.currency} ${discountedLineTotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 13,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E2124),
                          height: 1.2,
                        ),
                      ),
                      if (safeDiscount > 0)
                        Text(
                          '-${widget.currency} ${safeDiscount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: isTablet ? 11 : 9,
                            color: Colors.green.shade600,
                            fontWeight: FontWeight.w700,
                            height: 1.05,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => widget.vm.removeLine(line.product.id),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: isTablet ? 22 : 20,
                      height: isTablet ? 22 : 20,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Icon(
                        Icons.close,
                        size: isTablet ? 13 : 12,
                        color: Colors.red.shade400,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 9 : 6,
                      vertical: isTablet ? 5 : 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${line.qty % 1 == 0 ? line.qty.toInt() : line.qty} × ${widget.currency} ${line.unitPrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: isTablet ? 13 : 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                        height: 1.1,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Dis.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 60,
                    height: 28,
                    child: TextFormField(
                      controller: _discController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (val) {
                        final d = double.tryParse(val) ?? 0;
                        widget.vm.updateLineDiscount(
                          line.product.id,
                          discountType: isPercent ? 'percent' : 'amount',
                          discountValue: d,
                        );
                      },
                      style: const TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        hintText: '0',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      widget.vm.updateLineDiscount(
                        line.product.id,
                        discountType: isPercent ? 'amount' : 'percent',
                        discountValue: line.lineDiscountValue,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC145).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        isPercent ? '%' : 'SAR',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E2124),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
        ],
      ),
    );
  }
}
