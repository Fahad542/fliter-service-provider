import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_formatters.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/pos_tablet_layout.dart';
import '../../../models/takeaway_models.dart';
import '../../../widgets/pos_widgets.dart';
import '../../../widgets/pos_shell_rail_layout.dart';
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
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final vm = context.watch<TakeawayViewModel>();

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
        bottomNavigationBar: vm.cartLineCount == 0
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
      return Column(
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
            _buildCategoryChips(context, vm, true),
          ],
          SizedBox(height: isTablet ? 10 : 8),
          Expanded(
            child: vm.catalog != null && !vm.catalogHasProducts
                ? _buildEmptyState(true)
                : _buildListBody(context, vm, isTablet, isPortrait),
          ),
        ],
      );
    }

    return Column(
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
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: SingleChildScrollView(
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
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 100),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isPortrait ? 2 : 4,
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: product.isActive ? () => vm.addProduct(product) : null,
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
                    if (product.isActive) ...[
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
    return Stack(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: product.isActive ? () => vm.addProduct(product) : null,
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
                    if (product.isActive)
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
                'Checkout',
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
    showDialog<void>(
      context: context,
      builder: (ctx) => _TakeawayCheckoutSheet(isTablet: isTablet),
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

/// Checkout sheet (unchanged flow; kept at bottom of file).
class _TakeawayCheckoutSheet extends StatefulWidget {
  const _TakeawayCheckoutSheet({required this.isTablet});

  final bool isTablet;

  @override
  State<_TakeawayCheckoutSheet> createState() => _TakeawayCheckoutSheetState();
}

class _TakeawayCheckoutSheetState extends State<_TakeawayCheckoutSheet> {
  double _parse(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TakeawayViewModel>();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final currency = vm.catalog?.currency ?? 'SAR';
    final subtotal = vm.subtotalBeforeOrderDiscount;
    final orderDisc = _parse(vm.orderDiscountValueController);
    final vatPercent = _parse(vm.vatController);
    final vatAmount = ((subtotal - orderDisc).clamp(0, double.infinity)) * (vatPercent / 100);
    final grandTotal = ((subtotal - orderDisc).clamp(0, double.infinity)) + vatAmount;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: widget.isTablet ? 40 : 16,
        vertical: widget.isTablet ? 24 : 16,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent,
      child: Container(
        width: widget.isTablet ? 900 : double.infinity,
        height: MediaQuery.of(context).size.height * 0.92,
        decoration: BoxDecoration(
          color: const Color(0xFFFBF9F6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
              // Handle bar sits at the very top, outside the main padding but inside the dialog.
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 10, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: widget.isTablet ? 20 : 12),
                child: Row(
                  children: [
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      iconSize: widget.isTablet ? 24 : 20,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                  ],
                ),
              ),
              if (vm.checkoutError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Material(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              vm.checkoutError!,
                              style: TextStyle(
                                color: Colors.red.shade900,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(widget.isTablet ? 16 : 0, 6, widget.isTablet ? 16 : 0, 0),
                      padding: EdgeInsets.symmetric(horizontal: widget.isTablet ? 16 : 14, vertical: widget.isTablet ? 14 : 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '#NEW-ORDER',
                                  style: TextStyle(
                                    fontSize: widget.isTablet ? 16 : 10,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1E2124),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  vm.customerNameController.text.isNotEmpty
                                      ? vm.customerNameController.text
                                      : 'Walk-in Customer',
                                  style: TextStyle(
                                    fontSize: widget.isTablet ? 22 : 13,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1E2124),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Draft',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: widget.isTablet ? 17 : 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.directions_car_outlined, size: 22, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'No Vehicle Details',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: widget.isTablet ? 17 : 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.phone_outlined, size: 22, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                vm.customerMobileController.text.isNotEmpty
                                    ? vm.customerMobileController.text
                                    : 'No Phone',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: widget.isTablet ? 19 : 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: EdgeInsets.fromLTRB(widget.isTablet ? 24 : 16, widget.isTablet ? 12 : 10, widget.isTablet ? 24 : 16, widget.isTablet ? 6 : 8),
                      child: Row(
                        children: [
                          Text(
                            'Order Items',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: widget.isTablet ? 20 : 14,
                              color: const Color(0xFF1E2124),
                            ),
                          ),
                          const Spacer(),
                          if (vm.cartLineCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${vm.cartLineCount}',
                                style: TextStyle(
                                  fontSize: widget.isTablet ? 16 : 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1E2124),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
                        final useTwoCols = widget.isTablet || isLandscape;
                        final gap = widget.isTablet ? 10.0 : 8.0;
                        final hPad = widget.isTablet ? 16.0 : 0.0;
                        
                        if (useTwoCols) {
                          final innerWidth = constraints.maxWidth - (2 * hPad);
                          final itemWidth = (innerWidth - gap) / 2;
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: hPad),
                            child: Wrap(
                              spacing: gap,
                              runSpacing: gap,
                              children: [
                                for (final line in vm.cart)
                                  SizedBox(
                                    width: itemWidth,
                                    child: _TakeawayCartItemCompactTile(
                                      key: ValueKey(line.product.id),
                                      line: line,
                                      currency: currency,
                                      vm: vm,
                                      isTablet: widget.isTablet,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: vm.cart.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            return _TakeawayCartItemCompactTile(
                              key: ValueKey(vm.cart[index].product.id),
                              line: vm.cart[index],
                              currency: currency,
                              vm: vm,
                              isTablet: widget.isTablet,
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: widget.isTablet ? 16 : 0),
                      padding: EdgeInsets.all(widget.isTablet ? 24 : 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          _buildTotalRow('Total Amount Gross', '$currency ${subtotal.toStringAsFixed(2)}', widget.isTablet),
                          const SizedBox(height: 8),
                          
                          // Interactive Discount Row
                          Row(
                            children: [
                              Text(
                                'Discount',
                                style: TextStyle(
                                  fontSize: widget.isTablet ? 18 : 10,
                                  color: Colors.green,
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: widget.isTablet ? 80 : 60,
                                height: widget.isTablet ? 28 : 24,
                                child: TextFormField(
                                  initialValue: orderDisc > 0 ? (orderDisc % 1 == 0 ? orderDisc.toInt().toString() : orderDisc.toString()) : '',
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) {
                                    final d = double.tryParse(val) ?? 0;
                                    vm.setOrderDiscountValue(d);
                                  },
                                  style: TextStyle(fontSize: widget.isTablet ? 14 : 11, color: Colors.green),
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    hintText: '0',
                                    hintStyle: const TextStyle(color: Colors.green),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: const BorderSide(color: Colors.green),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: const BorderSide(color: Colors.green),
                                    ),
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: widget.isTablet ? 8 : 6, vertical: widget.isTablet ? 4 : 3),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                                ),
                                child: Text(
                                  'SAR', // For now keep SAR as takeaway uses simpler discount
                                  style: TextStyle(
                                    fontSize: widget.isTablet ? 12 : 9,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          
                          _buildTotalRow('Tax ($vatPercent%)', '$currency ${vatAmount.toStringAsFixed(2)}', widget.isTablet, color: Colors.grey),
                          const SizedBox(height: 10),
                          
                          Divider(height: 1, color: Colors.grey.shade200),
                          const SizedBox(height: 10),
                          
                          Row(
                            children: [
                              Text(
                                'Total amount',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: widget.isTablet ? 24 : 14,
                                  color: const Color(0xFF1E2124),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '$currency ${grandTotal.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: widget.isTablet ? 24 : 14,
                                  color: const Color(0xFF1E2124),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_offer_outlined, color: Colors.amber.shade700, size: 18),
                          const SizedBox(width: 6),
                          Text('Add Promo Code', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: vm.customerNameController,
                      decoration: const InputDecoration(labelText: 'Customer Name *', border: OutlineInputBorder(), isDense: true),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: vm.customerMobileController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(labelText: 'Mobile', border: OutlineInputBorder(), isDense: true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: vm.vatController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'VAT %', border: OutlineInputBorder(), isDense: true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: vm.paymentMethod,
                      decoration: const InputDecoration(
                        labelText: 'Payment method *',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: [
                        for (final m in TakeawayViewModel.paymentMethods)
                          DropdownMenuItem(value: m, child: Text(m)),
                      ],
                      onChanged: (v) {
                        if (v != null) vm.setPaymentMethod(v);
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: ElevatedButton(
                              onPressed: vm.checkoutLoading ? null : () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF23262D),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Save Draft'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: ElevatedButton(
                              onPressed: vm.checkoutLoading
                                  ? null
                                  : () async {
                                      vm.clearCheckoutError();
                                      final res = await vm.submitCheckout();
                                      if (!context.mounted) return;
                                      final invoice = vm.lastInvoice;
                                      if (res?.success == true && invoice != null) {
                                        Navigator.pop(context);
                                        await Future<void>.delayed(const Duration(milliseconds: 150));
                                        if (!context.mounted) return;
                                        showDialog<void>(
                                          context: context,
                                          builder: (dCtx) => InvoiceDialog(
                                            invoice: invoice,
                                            requestedPaymentMethod: vm.paymentMethod,
                                          ),
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFCC247),
                                foregroundColor: const Color(0xFF23262D),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: vm.checkoutLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87),
                                    )
                                  : const Text('Forward to Technician'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, bool isTablet, {Color? color}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 18 : 10,
            color: color ?? Colors.grey.shade600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: isTablet ? 18 : 10,
            fontWeight: FontWeight.w600,
            color: color ?? const Color(0xFF1E2124),
          ),
        ),
      ],
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
    
    return Container(
      padding: EdgeInsets.only(
        left: isTablet ? 14 : 12,
        right: isTablet ? 44 : 38,
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
                  Text(
                    '${widget.currency} ${(line.unitPrice * line.qty).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 13,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E2124),
                      height: 1.2,
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
                        widget.vm.updateLineDiscount(line.product.id, discountType: 'amount', discountValue: d);
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC145).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Text(
                      'SAR',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E2124),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: -4,
            right: -34,
            child: GestureDetector(
              onTap: () => widget.vm.removeLine(line.product.id),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(Icons.close, size: isTablet ? 17 : 15, color: Colors.red.shade400),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
