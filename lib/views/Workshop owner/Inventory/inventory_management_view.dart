import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import 'inventory_management_view_model.dart';
import '../Departments/department_management_view_model.dart';
import '../../../models/workshop_owner_models.dart';
import '../widgets/owner_app_bar.dart';
import '../widgets/custom_search_bar.dart';

class InventoryManagementView extends StatefulWidget {
  const InventoryManagementView({super.key});

  @override
  State<InventoryManagementView> createState() => _InventoryManagementViewState();
}

class _InventoryManagementViewState extends State<InventoryManagementView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Locale? _lastLocale;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-translate API data whenever the locale changes
    final currentLocale = Localizations.localeOf(context);
    if (_lastLocale != null && _lastLocale != currentLocale) {
      context.read<InventoryManagementViewModel>().retranslate();
    }
    _lastLocale = currentLocale;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<InventoryManagementViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          appBar: OwnerAppBar(
            title: l10n.invTitle,
            onMenuPressed: () => Scaffold.of(context).openDrawer(),
          ),
          body: vm.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryLight))
              : Column(
            children: [
              _buildTabHeader(l10n),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProductsTab(vm, l10n),
                    _buildServicesTab(vm, l10n),
                    _buildCategoriesTab(vm, l10n),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddAction(context, vm),
            backgroundColor: AppColors.secondaryLight,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: Text(
              _getAddLabel(l10n),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      },
    );
  }

  String _getAddLabel(AppLocalizations l10n) {
    switch (_tabController.index) {
      case 0: return l10n.invAddProduct;
      case 1: return l10n.invAddService;
      case 2: return l10n.invAddCategory;
      default: return l10n.invAdd;
    }
  }

  Widget _buildTabHeader(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: Colors.white),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: TabBar(
            controller: _tabController,
            onTap: (index) {
              context.read<InventoryManagementViewModel>().onTabChanged(index);
              setState(() {});
            },
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
              Tab(text: l10n.invTabProducts),
              Tab(text: l10n.invTabServices),
              Tab(text: l10n.invTabCategory),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsTab(InventoryManagementViewModel vm, AppLocalizations l10n) {
    return Column(
      children: [
        if (vm.products.isNotEmpty || vm.searchQuery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: CustomSearchBar(
              onChanged: (val) => vm.updateSearchQuery(val),
              hintText: l10n.invSearchProductsHint,
            ),
          ),
        Expanded(
          child: vm.products.isEmpty && vm.searchQuery.isNotEmpty
              ? Center(child: Text(l10n.invNoProductsMatchSearch))
              : vm.products.isEmpty
              ? Center(child: Text(l10n.invNoProductsFound))
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: vm.products.length,
            itemBuilder: (context, index) =>
                _buildProductCard(vm.products[index], vm, l10n, isService: false),
          ),
        ),
      ],
    );
  }

  Widget _buildServicesTab(InventoryManagementViewModel vm, AppLocalizations l10n) {
    return Column(
      children: [
        if (vm.services.isNotEmpty || vm.searchQuery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: CustomSearchBar(
              onChanged: (val) => vm.updateSearchQuery(val),
              hintText: l10n.invSearchServicesHint,
            ),
          ),
        Expanded(
          child: vm.services.isEmpty && vm.searchQuery.isNotEmpty
              ? Center(child: Text(l10n.invNoServicesMatchSearch))
              : vm.services.isEmpty
              ? Center(child: Text(l10n.invNoServicesFound))
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: vm.services.length,
            itemBuilder: (context, index) =>
                _buildProductCard(vm.services[index], vm, l10n, isService: true),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(
      OwnerProduct product,
      InventoryManagementViewModel vm,
      AppLocalizations l10n, {
        required bool isService,
      }) {
    final isStockLow = product.stockQty <= product.criticalLevel;
    final String departmentTag =
        product.departmentName ?? (product.departmentIds.isNotEmpty ? product.departmentIds.first : '');
    final String categoryTag = (product.subCategoryName?.isNotEmpty == true)
        ? product.subCategoryName!
        : ((product.category?.isNotEmpty == true) ? product.category! : '');
    final String displayTag =
    [departmentTag, categoryTag].where((e) => e.trim().isNotEmpty).join(' • ');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primaryLight.withOpacity(0.2)),
                      ),
                      child: product.imageUrl != null
                          ? Image.network(product.imageUrl!, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _fallbackIcon(isService ? 'service' : product.type))
                          : _fallbackIcon(isService ? 'service' : product.type),
                    ),
                    Positioned(
                      right: 0, bottom: 0,
                      child: Container(
                        width: 14, height: 14,
                        decoration: BoxDecoration(
                          color: product.isActive ? Colors.green : Colors.grey.shade400,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: AppTextStyles.h2.copyWith(fontSize: 16, color: AppColors.secondaryLight),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.business_rounded, color: Colors.grey.shade400, size: 10),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              displayTag,
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildActionMenu(product, vm, l10n, isService: isService),
              ],
            ),
          ),
          Container(height: 1, color: Colors.grey.withOpacity(0.06)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                if (!isService) ...[
                  Expanded(child: _buildMetricItem(
                    l10n.invMetricStock,
                    '${product.stockQty.toInt()} ${product.unit}',
                    isStockLow ? AppColors.errorLight : Colors.green.shade700,
                    isAlert: isStockLow,
                  )),
                  Container(width: 1, height: 30, color: Colors.grey.withOpacity(0.1)),
                  Expanded(child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: _buildMetricItem(l10n.invMetricPurchase, 'SAR ${product.purchasePrice.toInt()}', Colors.grey.shade600),
                  )),
                  Container(width: 1, height: 30, color: Colors.grey.withOpacity(0.1)),
                  Expanded(child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: _buildMetricItem(l10n.invMetricRetail, 'SAR ${product.salePrice.toInt()}', Colors.grey.shade600),
                  )),
                  Container(width: 1, height: 30, color: Colors.grey.withOpacity(0.1)),
                  Expanded(child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: _buildMetricItem(
                      l10n.invMetricCorporate,
                      (product.corporateLowerLimit != null && product.corporateLowerLimit! > 0)
                          ? 'SAR ${product.corporateLowerLimit!.toInt()} - ${product.corporateUpperLimit?.toInt() ?? ""}'
                          : 'SAR ${product.corporateBasePrice?.toInt() ?? "0"}',
                      AppColors.primaryLight,
                    ),
                  )),
                ],
                if (isService) ...[
                  Expanded(child: _buildMetricItem(
                    l10n.invMetricPrice, 'SAR ${product.salePrice.toInt()}', Colors.grey.shade600, centered: true,
                  )),
                  Container(width: 1, height: 30, color: Colors.grey.withOpacity(0.1)),
                  Expanded(child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: _buildMetricItem(
                      l10n.invMetricCorpRange,
                      (product.minPriceCorporate != null && product.minPriceCorporate! > 0)
                          ? 'SAR ${product.minPriceCorporate!.toInt()} - ${product.maxPriceCorporate?.toInt() ?? 0}'
                          : '-',
                      AppColors.primaryLight,
                      centered: true,
                    ),
                  )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackIcon(String? type) {
    final isService = type?.toLowerCase() == 'service';
    return Center(
      child: Icon(
        isService ? Icons.build_rounded : Icons.inventory_2_rounded,
        color: AppColors.primaryLight, size: 26,
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, Color color,
      {bool isAlert = false, bool centered = false}) {
    return Column(
      crossAxisAlignment: centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: centered ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            if (isAlert)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.warning_amber_rounded, color: AppColors.errorLight, size: 14),
              ),
            Flexible(
              child: Text(value,
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: color),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoriesTab(InventoryManagementViewModel vm, AppLocalizations l10n) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              Expanded(child: _buildInnerTab(
                title: l10n.invCategoryTabProducts,
                isSelected: vm.selectedInnerTab == 0,
                onTap: () => vm.setInnerTab(0),
              )),
              const SizedBox(width: 12),
              Expanded(child: _buildInnerTab(
                title: l10n.invCategoryTabServices,
                isSelected: vm.selectedInnerTab == 1,
                onTap: () => vm.setInnerTab(1),
              )),
            ],
          ),
        ),
        if (vm.displayedSubCategories.isNotEmpty || vm.searchQuery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: CustomSearchBar(
              onChanged: (val) => vm.updateSearchQuery(val),
              hintText: l10n.invSearchCategoriesHint,
            ),
          ),
        Expanded(
          child: vm.isSubCategoriesLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryLight))
              : vm.displayedSubCategories.isEmpty && vm.searchQuery.isNotEmpty
              ? Center(child: Text(l10n.invNoCategoriesMatchSearch))
              : vm.displayedSubCategories.isEmpty
              ? Center(child: Text(l10n.invNoCategoriesFound))
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: vm.displayedSubCategories.length,
            itemBuilder: (context, index) {
              final cat = vm.displayedSubCategories[index];
              return _buildSimpleActionCard(
                cat.name,
                vm.selectedInnerTab == 0 ? Icons.inventory_2_rounded : Icons.build_rounded,
                AppColors.primaryLight,
                l10n,
                subtitle: cat.departmentName,
                onEdit: () {
                  vm.setEditCategory(
                    OwnerCategory(
                      id: cat.id,
                      name: cat.name,
                      type: vm.selectedInnerTab == 0 ? 'product' : 'service',
                      workshopId: '',
                    ),
                    departmentId: cat.departmentId,
                  );
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useRootNavigator: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => ChangeNotifierProvider.value(
                      value: vm,
                      child: const _AddCategorySheet(),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInnerTab({required String title, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.2)),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: isSelected ? AppColors.secondaryLight : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleActionCard(
      String title,
      IconData iconData,
      Color color,
      AppLocalizations l10n, {
        String? subtitle,
        VoidCallback? onEdit,
        VoidCallback? onDelete,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.secondaryLight.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Icon(iconData, color: AppColors.primaryLight, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.secondaryLight),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (subtitle != null && subtitle.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.store_rounded, size: 12, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(subtitle,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis, maxLines: 1),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_rounded, size: 18),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primaryLight.withOpacity(0.12),
                foregroundColor: AppColors.primaryLight,
                padding: const EdgeInsets.all(8),
              ),
              tooltip: l10n.invEditTooltip,
            ),
          if (onDelete != null) ...[
            const SizedBox(width: 6),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              style: IconButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.08),
                foregroundColor: Colors.red.shade400,
                padding: const EdgeInsets.all(8),
              ),
              tooltip: l10n.invDeleteTooltip,
            ),
          ],
        ],
      ),
    );
  }

  void _showAddAction(BuildContext context, InventoryManagementViewModel vm) {
    if (_tabController.index == 0) {
      vm.setEditProduct(null);
      showModalBottomSheet(
        context: context, isScrollControlled: true, useRootNavigator: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ChangeNotifierProvider.value(value: vm, child: const _AddProductSheet()),
      );
    } else if (_tabController.index == 1) {
      vm.setEditService(null);
      showModalBottomSheet(
        context: context, isScrollControlled: true, useRootNavigator: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ChangeNotifierProvider.value(value: vm, child: const _AddServiceSheet()),
      );
    } else if (_tabController.index == 2) {
      vm.setEditCategory(null);
      showModalBottomSheet(
        context: context, isScrollControlled: true, useRootNavigator: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ChangeNotifierProvider.value(value: vm, child: const _AddCategorySheet()),
      );
    }
  }

  Widget _buildActionMenu(
      OwnerProduct product,
      InventoryManagementViewModel vm,
      AppLocalizations l10n, {
        bool isService = false,
      }) {
    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      offset: const Offset(0, 40),
      icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade400, size: 20),
      onSelected: (value) {
        if (value == 'edit') {
          if (isService || product.type.toLowerCase() == 'service') {
            vm.setEditService(product);
            showModalBottomSheet(
              context: context, isScrollControlled: true, useRootNavigator: true,
              backgroundColor: Colors.transparent,
              builder: (context) => ChangeNotifierProvider.value(value: vm, child: const _AddServiceSheet()),
            );
          } else {
            vm.setEditProduct(product);
            showModalBottomSheet(
              context: context, isScrollControlled: true, useRootNavigator: true,
              backgroundColor: Colors.transparent,
              builder: (context) => ChangeNotifierProvider.value(value: vm, child: const _AddProductSheet()),
            );
          }
        } else if (value == 'delete') {
          _showDeleteConfirmation(context, vm, l10n, product.name, () {
            if (isService || product.type.toLowerCase() == 'service') {
              vm.deleteService(context, product.id);
            } else {
              vm.deleteProduct(context, product.id);
            }
          });
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppColors.primaryLight.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.edit_rounded, size: 16, color: AppColors.secondaryLight),
            ),
            const SizedBox(width: 12),
            Text(l10n.invMenuEdit, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.secondaryLight)),
          ]),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppColors.primaryLight.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.delete_rounded, size: 16, color: AppColors.secondaryLight),
            ),
            const SizedBox(width: 12),
            Text(l10n.invMenuDelete, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.secondaryLight)),
          ]),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(
      BuildContext context,
      InventoryManagementViewModel vm,
      AppLocalizations l10n,
      String name,
      VoidCallback onConfirm,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(children: [
          const SizedBox(height: 16),
          Text(l10n.invConfirmDeleteTitle, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        ]),
        content: Text(
          l10n.invConfirmDeleteBody(name),
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(l10n.invCancel, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () { Navigator.pop(context); onConfirm(); },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  disabledBackgroundColor: AppColors.primaryLight,
                  foregroundColor: AppColors.secondaryLight,
                  disabledForegroundColor: AppColors.secondaryLight,
                  minimumSize: const Size.fromHeight(56),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(l10n.invConfirm, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Product Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _AddProductSheet extends StatefulWidget {
  const _AddProductSheet();
  @override
  State<_AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends State<_AddProductSheet> {
  String? selectedBranchId;
  String? selectedDepartmentId;
  String? selectedCategoryId;
  String? selectedSubCategoryId;

  void _applyInitialCategorySelection(InventoryManagementViewModel vm) {
    if (vm.displayedSubCategories.isEmpty) return;
    OwnerSubCategory? matched;
    final subName = vm.editingSubCategoryName?.trim().toLowerCase();
    final catName = vm.editingCategoryName?.trim().toLowerCase();
    if (subName != null && subName.isNotEmpty) {
      for (final s in vm.displayedSubCategories) {
        if (s.name.trim().toLowerCase() == subName) { matched = s; break; }
      }
    }
    if (matched == null && catName != null && catName.isNotEmpty) {
      for (final s in vm.displayedSubCategories) {
        if (s.name.trim().toLowerCase() == catName) { matched = s; break; }
      }
    }
    final selected = matched ?? vm.displayedSubCategories.first;
    OwnerCategory? parent;
    for (final c in vm.categories) {
      if (c.subCategories.any((s) => s.id == selected.id)) { parent = c; break; }
    }
    setState(() {
      if (parent != null) { selectedCategoryId = parent.id; selectedSubCategoryId = selected.id; }
      else { selectedCategoryId = selected.id; selectedSubCategoryId = null; }
    });
  }

  @override
  void initState() {
    super.initState();
    final deptVm = context.read<DepartmentManagementViewModel>();
    if (deptVm.departments.isNotEmpty) selectedDepartmentId = deptVm.departments.first.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<InventoryManagementViewModel>();
      if (vm.branches.isNotEmpty) setState(() => selectedBranchId = vm.branches.first.id);
      if (vm.displayedSubCategories.isNotEmpty) _applyInitialCategorySelection(vm);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vm = context.watch<InventoryManagementViewModel>();
    final deptVm = context.watch<DepartmentManagementViewModel>();
    if (selectedCategoryId == null && vm.displayedSubCategories.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || selectedCategoryId != null) return;
        _applyInitialCategorySelection(vm);
      });
    }

    return FocusScope(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.70,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            _buildHandle(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(
                          vm.isEditingProduct ? l10n.invUpdateProduct : l10n.invCreateProduct,
                          style: AppTextStyles.h2.copyWith(fontSize: 18), overflow: TextOverflow.ellipsis,
                        )),
                        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(vm.isEditingProduct ? l10n.invUpdateProductSubtitle : l10n.invCreateProductSubtitle,
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 30),

                    if (!vm.isEditingProduct && vm.branches.isNotEmpty)
                      _buildDropdown(l10n.invFieldBranch,
                        vm.branches.map((b) => b.name).toSet().toList(),
                        value: vm.branches.firstWhere((b) => b.id == selectedBranchId, orElse: () => vm.branches.first).name,
                        onChanged: (val) => setState(() =>
                        selectedBranchId = vm.branches.firstWhere((b) => b.name == val).id),
                      ),

                    if (!vm.isEditingProduct && deptVm.departments.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: DropdownButtonFormField<String>(
                          value: deptVm.departments.firstWhere((d) => d.id == selectedDepartmentId,
                              orElse: () => deptVm.departments.first).name,
                          decoration: InputDecoration(
                            labelText: l10n.invFieldDepartment,
                            labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                            filled: true, fillColor: Colors.grey.withOpacity(0.05),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          ),
                          items: deptVm.departments.map((d) => d.name).toSet().toList()
                              .map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() {
                              selectedDepartmentId = deptVm.departments.firstWhere((d) => d.name == val).id;
                              selectedCategoryId = null; selectedSubCategoryId = null;
                            });
                          },
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.secondaryLight),
                        ),
                      ),

                    if (vm.isSubCategoriesLoading)
                      const Padding(padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator(color: AppColors.primaryLight)))
                    else
                      Builder(builder: (context) {
                        final filtered = selectedDepartmentId != null
                            ? vm.displayedSubCategories.where((s) => s.departmentId == selectedDepartmentId).toList()
                            : vm.displayedSubCategories;
                        if (filtered.isEmpty) return const SizedBox.shrink();
                        final hasSub = filtered.any((s) => s.id == selectedSubCategoryId);
                        final hasCat = filtered.any((s) => s.id == selectedCategoryId);
                        final dropVal = hasSub
                            ? filtered.firstWhere((s) => s.id == selectedSubCategoryId).name
                            : hasCat
                            ? filtered.firstWhere((s) => s.id == selectedCategoryId).name
                            : filtered.first.name;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: DropdownButtonFormField<String>(
                            value: dropVal,
                            decoration: InputDecoration(
                              labelText: l10n.invFieldCategory,
                              labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                              filled: true, fillColor: Colors.grey.withOpacity(0.05),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            ),
                            items: filtered.map((s) => DropdownMenuItem(value: s.name, child: Text(s.name))).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                final sel = filtered.firstWhere((s) => s.name == val);
                                OwnerCategory? parent;
                                for (var c in vm.categories) {
                                  if (c.subCategories.any((s) => s.id == sel.id)) { parent = c; break; }
                                }
                                setState(() {
                                  if (parent != null) { selectedCategoryId = parent.id; selectedSubCategoryId = sel.id; }
                                  else { selectedCategoryId = sel.id; selectedSubCategoryId = null; }
                                });
                              }
                            },
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.secondaryLight),
                          ),
                        );
                      }),

                    _buildTextField(l10n.invFieldProductName, Icons.inventory_2_rounded, controller: vm.nameController),
                    Row(children: [
                      Expanded(child: _buildTextField(l10n.invFieldStockQty, Icons.numbers_rounded, isNumber: true, controller: vm.openingQtyController)),
                      const SizedBox(width: 12),
                      Expanded(child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: DropdownButtonFormField<String>(
                          value: (vm.productUnits.isNotEmpty && vm.productUnits.any(
                                  (u) => u.toLowerCase() == vm.unitController.text.trim().toLowerCase()))
                              ? vm.productUnits.firstWhere((u) => u.toLowerCase() == vm.unitController.text.trim().toLowerCase())
                              : (vm.productUnits.isNotEmpty ? vm.productUnits.first : 'pcs'),
                          decoration: InputDecoration(
                            labelText: l10n.invFieldUnit,
                            labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                            filled: true, fillColor: Colors.grey.withOpacity(0.05),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            prefixIcon: const Icon(Icons.straighten_rounded, color: AppColors.secondaryLight, size: 20),
                          ),
                          items: (vm.productUnits.isNotEmpty ? vm.productUnits : ['pcs'])
                              .map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                          onChanged: (v) { if (v != null) vm.unitController.text = v; },
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.secondaryLight),
                        ),
                      )),
                    ]),
                    _buildTextField(l10n.invFieldCriticalStock, Icons.warning_amber_rounded, isNumber: true, controller: vm.criticalStockPointController),
                    const SizedBox(height: 12),
                    _buildSectionTitle(l10n.invSectionPricing),
                    const SizedBox(height: 16),
                    _buildTextField(l10n.invFieldPurchasePrice, Icons.shopping_cart_rounded, isNumber: true, controller: vm.purchasePriceController),
                    _buildTextField(l10n.invFieldSalePrice, Icons.sell_rounded, isNumber: true, controller: vm.salePriceController),
                    Row(children: [
                      Expanded(child: _buildTextField(l10n.invFieldMinCorpPrice, Icons.business_center_rounded, isNumber: true, controller: vm.minCorporatePriceController)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField(l10n.invFieldMaxCorpPrice, Icons.business_center_rounded, isNumber: true, controller: vm.maxCorporatePriceController)),
                    ]),
                    const SizedBox(height: 12),
                    _buildToggleRow(l10n.invToggleDecimal, vm.allowDecimalQty, (val) => vm.toggleAllowDecimal(val)),
                    const SizedBox(height: 12),
                    _buildToggleRow(l10n.invToggleActive, vm.isActive, (val) => vm.toggleIsActive(val)),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            _buildSubmitButton(context, vm,
              label: vm.isEditingProduct ? l10n.invUpdateProduct : l10n.invSaveProduct,
              onPressed: () => vm.submitProductForm(context,
                  departmentId: selectedDepartmentId, categoryId: selectedCategoryId,
                  subCategoryId: selectedSubCategoryId, branchId: selectedBranchId),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Service Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _AddServiceSheet extends StatefulWidget {
  const _AddServiceSheet();
  @override
  State<_AddServiceSheet> createState() => _AddServiceSheetState();
}

class _AddServiceSheetState extends State<_AddServiceSheet> {
  String? selectedBranchId;
  String? selectedDepartmentId;
  String? selectedCategoryId;
  String? selectedSubCategoryId;

  void _applyInitialCategorySelection(InventoryManagementViewModel vm) {
    if (vm.displayedSubCategories.isEmpty) return;
    OwnerSubCategory? matched;
    final subName = vm.editingSubCategoryName?.trim().toLowerCase();
    final catName = vm.editingCategoryName?.trim().toLowerCase();
    if (subName != null && subName.isNotEmpty) {
      for (final s in vm.displayedSubCategories) {
        if (s.name.trim().toLowerCase() == subName) { matched = s; break; }
      }
    }
    if (matched == null && catName != null && catName.isNotEmpty) {
      for (final s in vm.displayedSubCategories) {
        if (s.name.trim().toLowerCase() == catName) { matched = s; break; }
      }
    }
    final selected = matched ?? vm.displayedSubCategories.first;
    OwnerCategory? parent;
    for (final c in vm.categories) {
      if (c.subCategories.any((s) => s.id == selected.id)) { parent = c; break; }
    }
    setState(() {
      if (parent != null) { selectedCategoryId = parent.id; selectedSubCategoryId = selected.id; }
      else { selectedCategoryId = selected.id; selectedSubCategoryId = null; }
    });
  }

  @override
  void initState() {
    super.initState();
    final deptVm = context.read<DepartmentManagementViewModel>();
    if (deptVm.departments.isNotEmpty) selectedDepartmentId = deptVm.departments.first.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<InventoryManagementViewModel>();
      if (vm.branches.isNotEmpty) setState(() => selectedBranchId = vm.branches.first.id);
      if (vm.displayedSubCategories.isNotEmpty) _applyInitialCategorySelection(vm);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vm = context.watch<InventoryManagementViewModel>();
    final deptVm = context.watch<DepartmentManagementViewModel>();
    if (selectedCategoryId == null && vm.displayedSubCategories.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || selectedCategoryId != null) return;
        _applyInitialCategorySelection(vm);
      });
    }

    return FocusScope(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.60,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Center(child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12), width: 40, height: 5,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
            )),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(
                          vm.isEditingService ? l10n.invUpdateService : l10n.invCreateService,
                          style: AppTextStyles.h2.copyWith(fontSize: 18), overflow: TextOverflow.ellipsis,
                        )),
                        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(vm.isEditingService ? l10n.invUpdateServiceSubtitle : l10n.invCreateServiceSubtitle,
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 18),

                    if (!vm.isEditingService && vm.branches.isNotEmpty)
                      _buildDropdown(l10n.invFieldBranch,
                        vm.branches.map((b) => b.name).toSet().toList(),
                        value: vm.branches.firstWhere((b) => b.id == selectedBranchId, orElse: () => vm.branches.first).name,
                        onChanged: (val) => setState(() =>
                        selectedBranchId = vm.branches.firstWhere((b) => b.name == val).id),
                      ),

                    if (!vm.isEditingService && deptVm.departments.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: DropdownButtonFormField<String>(
                          value: deptVm.departments.firstWhere((d) => d.id == selectedDepartmentId,
                              orElse: () => deptVm.departments.first).name,
                          decoration: InputDecoration(
                            labelText: l10n.invFieldDepartment,
                            labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                            filled: true, fillColor: Colors.grey.withOpacity(0.05),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          ),
                          items: deptVm.departments.map((d) => d.name).toSet().toList()
                              .map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() {
                              selectedDepartmentId = deptVm.departments.firstWhere((d) => d.name == val).id;
                              selectedCategoryId = null; selectedSubCategoryId = null;
                            });
                          },
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.secondaryLight),
                        ),
                      ),

                    if (vm.isSubCategoriesLoading)
                      const Padding(padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator(color: AppColors.primaryLight)))
                    else
                      Builder(builder: (context) {
                        final filtered = selectedDepartmentId != null
                            ? vm.displayedSubCategories.where((s) => s.departmentId == selectedDepartmentId).toList()
                            : vm.displayedSubCategories;
                        if (filtered.isEmpty) return const SizedBox.shrink();
                        final hasSub = filtered.any((s) => s.id == selectedSubCategoryId);
                        final hasCat = filtered.any((s) => s.id == selectedCategoryId);
                        final dropVal = hasSub
                            ? filtered.firstWhere((s) => s.id == selectedSubCategoryId).name
                            : hasCat
                            ? filtered.firstWhere((s) => s.id == selectedCategoryId).name
                            : filtered.first.name;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: DropdownButtonFormField<String>(
                            value: dropVal,
                            decoration: InputDecoration(
                              labelText: l10n.invFieldCategory,
                              labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                              filled: true, fillColor: Colors.grey.withOpacity(0.05),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            ),
                            items: filtered.map((s) => DropdownMenuItem(value: s.name, child: Text(s.name))).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                final sel = filtered.firstWhere((s) => s.name == val);
                                OwnerCategory? parent;
                                for (var c in vm.categories) {
                                  if (c.subCategories.any((s) => s.id == sel.id)) { parent = c; break; }
                                }
                                setState(() {
                                  if (parent != null) { selectedCategoryId = parent.id; selectedSubCategoryId = sel.id; }
                                  else { selectedCategoryId = sel.id; selectedSubCategoryId = null; }
                                });
                              }
                            },
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.secondaryLight),
                          ),
                        );
                      }),

                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: TextField(
                        controller: vm.nameController,
                        decoration: InputDecoration(
                          labelText: l10n.invFieldServiceName,
                          prefixIcon: const Icon(Icons.home_repair_service_rounded, color: AppColors.secondaryLight, size: 20),
                          filled: true, fillColor: Colors.grey.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: TextField(
                        controller: vm.salePriceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.invFieldServicePrice,
                          prefixIcon: const Icon(Icons.sell_rounded, color: AppColors.secondaryLight, size: 20),
                          filled: true, fillColor: Colors.grey.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ),
                    ),
                    Row(children: [
                      Expanded(child: Container(
                        margin: const EdgeInsets.only(bottom: 16, right: 8),
                        child: TextField(
                          controller: vm.minCorporatePriceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.invFieldMinCorpPrice,
                            prefixIcon: const Icon(Icons.business_center_rounded, color: AppColors.secondaryLight, size: 20),
                            filled: true, fillColor: Colors.grey.withOpacity(0.05),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ),
                      )),
                      Expanded(child: Container(
                        margin: const EdgeInsets.only(bottom: 16, left: 8),
                        child: TextField(
                          controller: vm.maxCorporatePriceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.invFieldMaxCorpPrice,
                            prefixIcon: const Icon(Icons.business_center_rounded, color: AppColors.secondaryLight, size: 20),
                            filled: true, fillColor: Colors.grey.withOpacity(0.05),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ),
                      )),
                    ]),
                    const SizedBox(height: 16),
                    _buildToggleRow(l10n.invTogglePriceEditable, vm.isPriceEditable, (val) => vm.toggleIsPriceEditable(val)),
                    const SizedBox(height: 12),
                    _buildToggleRow(l10n.invToggleActive, vm.isActive, (val) => vm.toggleIsActive(val)),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildSubmitButton(context, vm,
              label: vm.isEditingService ? l10n.invUpdateService : l10n.invSaveService,
              onPressed: () => vm.submitServiceForm(context,
                  departmentId: selectedDepartmentId, categoryId: selectedCategoryId,
                  subCategoryId: selectedSubCategoryId, branchId: selectedBranchId),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Category Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _AddCategorySheet extends StatefulWidget {
  const _AddCategorySheet();
  @override
  State<_AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<_AddCategorySheet> {
  String? selectedDepartmentId;

  @override
  void initState() {
    super.initState();
    final deptVm = context.read<DepartmentManagementViewModel>();
    final vm = context.read<InventoryManagementViewModel>();
    if (vm.isEditingCategory && vm.editingCategoryDepartmentId != null) {
      final id = vm.editingCategoryDepartmentId!;
      selectedDepartmentId = deptVm.departments.any((d) => d.id == id)
          ? id
          : (deptVm.departments.isNotEmpty ? deptVm.departments.first.id : null);
    } else if (deptVm.departments.isNotEmpty) {
      selectedDepartmentId = deptVm.departments.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vm = context.watch<InventoryManagementViewModel>();
    final deptVm = context.watch<DepartmentManagementViewModel>();

    return FocusScope(
      child: Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12), width: 40, height: 5,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
            )),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(
                          vm.isEditingCategory ? l10n.invUpdateCategory : l10n.invCreateCategory,
                          style: AppTextStyles.h2.copyWith(fontSize: 18), overflow: TextOverflow.ellipsis,
                        )),
                        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(vm.isEditingCategory ? l10n.invUpdateCategorySubtitle : l10n.invCreateCategorySubtitle,
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 30),
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: TextField(
                        controller: vm.categoryNameController,
                        decoration: InputDecoration(
                          labelText: l10n.invFieldCategoryName,
                          prefixIcon: const Icon(Icons.account_tree_rounded, color: AppColors.secondaryLight, size: 20),
                          filled: true, fillColor: Colors.grey.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ),
                    ),
                    if (deptVm.departments.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: DropdownButtonFormField<String>(
                          value: deptVm.departments.any((d) => d.id == selectedDepartmentId)
                              ? deptVm.departments.firstWhere((d) => d.id == selectedDepartmentId).name
                              : deptVm.departments.first.name,
                          decoration: InputDecoration(
                            labelText: l10n.invFieldDepartment,
                            labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                            filled: true, fillColor: Colors.grey.withOpacity(0.05),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          ),
                          items: deptVm.departments.map((d) => d.name).toSet().toList()
                              .map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                          onChanged: (val) => setState(() =>
                          selectedDepartmentId = deptVm.departments.firstWhere((d) => d.name == val).id),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.secondaryLight),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 24, right: 24, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
              child: ElevatedButton(
                onPressed: vm.isActionLoading ? null : () => vm.submitCategoryForm(context, departmentId: selectedDepartmentId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight, disabledBackgroundColor: AppColors.primaryLight,
                  foregroundColor: AppColors.secondaryLight, disabledForegroundColor: AppColors.secondaryLight,
                  minimumSize: const Size.fromHeight(56), elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: vm.isActionLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.secondaryLight, strokeWidth: 2))
                    : Text(vm.isEditingCategory ? l10n.invUpdateCategory : l10n.invSaveCategory,
                    style: const TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Sub-Category Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _AddSubCategorySheet extends StatefulWidget {
  final String categoryId;
  const _AddSubCategorySheet({required this.categoryId});
  @override
  State<_AddSubCategorySheet> createState() => _AddSubCategorySheetState();
}

class _AddSubCategorySheetState extends State<_AddSubCategorySheet> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vm = context.watch<InventoryManagementViewModel>();
    return FocusScope(
      child: Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12), width: 40, height: 5,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
            )),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(l10n.invCreateSubCategory,
                            style: AppTextStyles.h2.copyWith(fontSize: 18), overflow: TextOverflow.ellipsis)),
                        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(l10n.invCreateSubCategorySubtitle, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 30),
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: TextField(
                        controller: vm.categoryNameController,
                        decoration: InputDecoration(
                          labelText: l10n.invFieldSubCategoryName,
                          prefixIcon: const Icon(Icons.account_tree_rounded, color: AppColors.secondaryLight, size: 20),
                          filled: true, fillColor: Colors.grey.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 24, right: 24, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
              child: ElevatedButton(
                onPressed: vm.isActionLoading ? null : () => vm.submitSubCategoryForm(context, categoryId: widget.categoryId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight, disabledBackgroundColor: AppColors.primaryLight,
                  foregroundColor: AppColors.secondaryLight, disabledForegroundColor: AppColors.secondaryLight,
                  minimumSize: const Size.fromHeight(56), elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: vm.isActionLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.secondaryLight, strokeWidth: 2))
                    : Text(l10n.invSaveSubCategory,
                    style: const TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared module-level helpers (used by all sheets)
// ─────────────────────────────────────────────────────────────────────────────

Widget _buildHandle() => Center(
  child: Container(
    margin: const EdgeInsets.symmetric(vertical: 12), width: 40, height: 5,
    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
  ),
);

Widget _buildSectionTitle(String title) => Text(
  title,
  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.secondaryLight),
);

Widget _buildTextField(String label, IconData iconData,
    {bool isNumber = false, TextEditingController? controller}) =>
    Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(iconData, color: AppColors.secondaryLight, size: 20),
          filled: true, fillColor: Colors.grey.withOpacity(0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ),
    );

Widget _buildDropdown(String label, List<String> items,
    {required String value, required void Function(String?) onChanged}) =>
    Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          filled: true, fillColor: Colors.grey.withOpacity(0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.secondaryLight),
      ),
    );

Widget _buildToggleRow(String label, bool value, Function(bool) onChanged) => Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Expanded(
      child: Text(label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          overflow: TextOverflow.ellipsis),
    ),
    Switch.adaptive(value: value, onChanged: onChanged, activeColor: AppColors.secondaryLight),
  ],
);

Widget _buildSubmitButton(
    BuildContext context,
    InventoryManagementViewModel vm, {
      required String label,
      required VoidCallback onPressed,
    }) => Padding(
  padding: EdgeInsets.only(
    left: 24, right: 24, top: 16,
    bottom: MediaQuery.of(context).viewInsets.bottom + 24,
  ),
  child: ElevatedButton(
    onPressed: vm.isActionLoading ? null : onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryLight, disabledBackgroundColor: AppColors.primaryLight,
      foregroundColor: AppColors.secondaryLight, disabledForegroundColor: AppColors.secondaryLight,
      minimumSize: const Size.fromHeight(56), elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    child: vm.isActionLoading
        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.secondaryLight, strokeWidth: 2))
        : Text(label, style: const TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 16)),
  ),
);