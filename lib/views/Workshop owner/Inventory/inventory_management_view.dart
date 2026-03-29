import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import 'inventory_management_view_model.dart';
import '../Departments/department_management_view_model.dart';
import '../../../models/workshop_owner_models.dart';
import '../../../utils/toast_service.dart';
import '../widgets/owner_app_bar.dart';
import '../widgets/custom_search_bar.dart';

class InventoryManagementView extends StatefulWidget {
  const InventoryManagementView({super.key});

  @override
  State<InventoryManagementView> createState() => _InventoryManagementViewState();
}

class _InventoryManagementViewState extends State<InventoryManagementView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
  Widget build(BuildContext context) {
    return Consumer<InventoryManagementViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          appBar: OwnerAppBar(
            title: 'Inventory & Products',
            onMenuPressed: () => Scaffold.of(context).openDrawer(),
          ),
          body: vm.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryLight),
                )
              : Column(
                  children: [
                    _buildTabHeader(),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildProductsTab(vm),
                          _buildServicesTab(vm),
                          _buildCategoriesTab(vm),
                        ],
                      ),
                    ),
                  ],
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddAction(context, vm),
            backgroundColor: AppColors.secondaryLight,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: Text(_getAddLabel(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      },
    );
  }

  String _getAddLabel() {
    switch (_tabController.index) {
      case 0: return 'Add Product';
      case 1: return 'Add Service';
      case 2: return 'Add Category';
      default: return 'Add';
    }
  }

  Widget _buildTabHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
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
            onTap: (index) => setState(() {}),
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
              Tab(text: 'PRODUCTS'),
              Tab(text: 'SERVICES'),
              Tab(text: 'CATEGORY'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsTab(InventoryManagementViewModel vm) {
    return Column(
      children: [
        if (vm.products.isNotEmpty || vm.searchQuery.isNotEmpty) 
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: CustomSearchBar(
              onChanged: (val) => vm.updateSearchQuery(val),
              hintText: 'Search by name or category...',
            ),
          ),
        Expanded(
          child: vm.products.isEmpty && vm.searchQuery.isNotEmpty
              ? const Center(child: Text('No products found matching your search.'))
              : vm.products.isEmpty
                  ? const Center(child: Text('No products found.'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: vm.products.length,
                      itemBuilder: (context, index) {
                        final product = vm.products[index];
                        return _buildProductCard(product, vm, isService: false);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildServicesTab(InventoryManagementViewModel vm) {
    return Column(
      children: [
        if (vm.services.isNotEmpty || vm.searchQuery.isNotEmpty) 
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: CustomSearchBar(
              onChanged: (val) => vm.updateSearchQuery(val),
              hintText: 'Search services...',
            ),
          ),
        Expanded(
          child: vm.services.isEmpty && vm.searchQuery.isNotEmpty
              ? const Center(child: Text('No services found matching your search.'))
              : vm.services.isEmpty
                  ? const Center(child: Text('No services found.'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: vm.services.length,
                      itemBuilder: (context, index) {
                        final service = vm.services[index];
                        return _buildProductCard(service, vm, isService: true);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildProductCard(OwnerProduct product, InventoryManagementViewModel vm, {required bool isService}) {
    final isStockLow = product.stockQty <= product.criticalLevel;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header: Image/Icon, Name, Badge
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon or Image
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
                      ? Image.network(product.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallbackIcon(isService ? 'service' : product.type))
                      : _fallbackIcon(isService ? 'service' : product.type),
                ),
                const SizedBox(width: 16),
                // Titles
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name, 
                        style: AppTextStyles.h2.copyWith(fontSize: 16, color: AppColors.secondaryLight),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.business_rounded, color: Colors.grey.shade400, size: 10),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              product.departmentName ?? (product.departmentIds.isNotEmpty ? product.departmentIds.first : ''),
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
                _buildActionMenu(product, vm),
              ],
            ),
          ),
          
          Container(height: 1, color: Colors.grey.withOpacity(0.06)),
          
          // Metrics Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                if (!isService) ...[
                  Expanded(child: _buildMetricItem('STOCK', '${product.stockQty.toInt()} ${product.unit}', isStockLow ? AppColors.errorLight : Colors.green.shade700, isAlert: isStockLow)),
                  Container(width: 1, height: 30, color: Colors.grey.withOpacity(0.1)),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: _buildMetricItem('PURCHASE', 'SAR ${product.purchasePrice.toInt()}', Colors.grey.shade600),
                    ),
                  ),
                  Container(width: 1, height: 30, color: Colors.grey.withOpacity(0.1)),
                ],
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: isService ? 0 : 12),
                    child: _buildMetricItem(isService ? 'PRICE' : 'RETAIL', 'SAR ${product.salePrice.toInt()}', Colors.grey.shade600, centered: isService),
                  ),
                ),
                Container(width: 1, height: 30, color: Colors.grey.withOpacity(0.1)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: _buildMetricItem('CORPORATE', 
                      (product.corporateLowerLimit != null && product.corporateLowerLimit! > 0)
                          ? 'SAR ${product.corporateLowerLimit!.toInt()} - ${product.corporateUpperLimit?.toInt() ?? ""}'
                          : 'SAR ${product.corporateBasePrice?.toInt() ?? "0"}', 
                      AppColors.primaryLight, centered: isService),
                  ),
                ),
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
        color: AppColors.primaryLight,
        size: 26,
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, Color color, {bool isAlert = false, bool centered = false}) {
    return Column(
      crossAxisAlignment: centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade400, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: centered ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            if (isAlert) 
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.warning_amber_rounded, color: AppColors.errorLight, size: 14),
              ),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoriesTab(InventoryManagementViewModel vm) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: _buildInnerTab(
                  title: 'Products',
                  isSelected: vm.selectedInnerTab == 0,
                  onTap: () => vm.setInnerTab(0),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInnerTab(
                  title: 'Services',
                  isSelected: vm.selectedInnerTab == 1,
                  onTap: () => vm.setInnerTab(1),
                ),
              ),
            ],
          ),
        ),
        if (vm.displayedSubCategories.isNotEmpty || vm.searchQuery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: CustomSearchBar(
              onChanged: (val) => vm.updateSearchQuery(val),
              hintText: 'Search categories...',
            ),
          ),
        Expanded(
          child: vm.isSubCategoriesLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryLight))
              : vm.displayedSubCategories.isEmpty && vm.searchQuery.isNotEmpty
                  ? const Center(child: Text('No categories found matching your search.'))
                  : vm.displayedSubCategories.isEmpty
                      ? const Center(child: Text('No categories found.'))
                      : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: vm.displayedSubCategories.length,
                      itemBuilder: (context, index) {
                        final cat = vm.displayedSubCategories[index];
                        return _buildSimpleActionCard(
                          cat.name, 
                          vm.selectedInnerTab == 0 ? Icons.inventory_2_rounded : Icons.build_rounded,
                          AppColors.primaryLight, 
                          onEdit: () {
                          vm.setEditCategory(OwnerCategory(
                            id: cat.id,
                            name: cat.name,
                            type: vm.selectedInnerTab == 0 ? 'product' : 'service',
                            workshopId: '',
                          ));
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
                        }, onDelete: () {
                          _showDeleteConfirmation(context, vm, cat.name, () {
                            vm.deleteCategory(context, cat.id);
                          });
                        });
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

  Widget _buildSimpleActionCard(String title, IconData iconData, Color color, {VoidCallback? onEdit, VoidCallback? onDelete}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.secondaryLight.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
             child: Icon(iconData, color: AppColors.primaryLight, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.secondaryLight),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (onEdit != null || onDelete != null)
            PopupMenuButton<String>(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 8,
              offset: const Offset(0, 40),
              icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade400, size: 20),
              onSelected: (value) {
                if (value == 'edit') onEdit?.call();
                if (value == 'delete') onDelete?.call();
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.edit_rounded, size: 16, color: AppColors.secondaryLight),
                      ),
                      const SizedBox(width: 12),
                      const Text('Edit', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.secondaryLight)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.delete_rounded, size: 16, color: AppColors.secondaryLight),
                      ),
                      const SizedBox(width: 12),
                      const Text('Delete', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.secondaryLight)),
                    ],
                  ),
                ),
              ],
            )
          else
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade300, size: 14),
        ],
      ),
    );
  }

  void _showAddAction(BuildContext context, InventoryManagementViewModel vm) {
    if (_tabController.index == 0) {
      vm.setEditProduct(null);
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ChangeNotifierProvider.value(
          value: vm,
          child: const _AddProductSheet(),
        ),
      );
    } else if (_tabController.index == 1) {
      vm.setEditService(null);
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ChangeNotifierProvider.value(
          value: vm,
          child: const _AddServiceSheet(),
        ),
      );
    } else if (_tabController.index == 2) {
      vm.setEditCategory(null);
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
    }
  }

  Widget _buildActionMenu(OwnerProduct product, InventoryManagementViewModel vm) {
    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      offset: const Offset(0, 40),
      icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade400, size: 20),
      onSelected: (value) {
        if (value == 'edit') {
          if (product.type == 'service') {
            vm.setEditService(product);
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useRootNavigator: true,
              backgroundColor: Colors.transparent,
              builder: (context) => ChangeNotifierProvider.value(
                value: vm,
                child: const _AddServiceSheet(),
              ),
            );
          } else {
            vm.setEditProduct(product);
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useRootNavigator: true,
              backgroundColor: Colors.transparent,
              builder: (context) => ChangeNotifierProvider.value(
                value: vm,
                child: const _AddProductSheet(),
              ),
            );
          }
        } else if (value == 'delete') {
          _showDeleteConfirmation(context, vm, product.name, () {
            vm.deleteProduct(context, product.id);
          });
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit_rounded, size: 16, color: AppColors.secondaryLight),
              ),
              const SizedBox(width: 12),
              const Text('Edit', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.secondaryLight)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_rounded, size: 16, color: AppColors.secondaryLight),
              ),
              const SizedBox(width: 12),
              const Text('Delete', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.secondaryLight)),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, InventoryManagementViewModel vm, String name, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 32),
            ),
            const SizedBox(height: 16),
            const Text('Confirm Deletion', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "$name"? This action cannot be undone.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onConfirm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    disabledBackgroundColor: AppColors.primaryLight,
                    foregroundColor: AppColors.secondaryLight,
                    disabledForegroundColor: AppColors.secondaryLight,
                    minimumSize: const Size.fromHeight(56),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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

  @override
  void initState() {
    super.initState();
    final deptVm = context.read<DepartmentManagementViewModel>();
    if (deptVm.departments.isNotEmpty) {
      selectedDepartmentId = deptVm.departments.first.id;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<InventoryManagementViewModel>();
      if (vm.branches.isNotEmpty) {
        setState(() {
          selectedBranchId = vm.branches.first.id;
        });
      }
      if (vm.displayedSubCategories.isNotEmpty) {
        setState(() {
          final first = vm.displayedSubCategories.first;
          OwnerCategory? parentCat;
          for (var c in vm.categories) {
            if (c.subCategories.any((sub) => sub.id == first.id)) {
              parentCat = c;
              break;
            }
          }
          if (parentCat != null) {
            selectedCategoryId = parentCat.id;
            selectedSubCategoryId = first.id;
          } else {
            selectedCategoryId = first.id;
            selectedSubCategoryId = null;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<InventoryManagementViewModel>();
    final deptVm = context.watch<DepartmentManagementViewModel>();

    return FocusScope(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
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
                        Text(vm.isEditingProduct ? 'Update Product' : 'Create Product', style: AppTextStyles.h2.copyWith(fontSize: 18)),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(vm.isEditingProduct ? 'Modify existing product details.' : 'Enter product details to add to inventory.', style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 30),

                    // Branch dropdown
                    if (vm.branches.isNotEmpty)
                      _buildDropdown(
                        'Branch',
                        vm.branches.map((b) => b.name).toSet().toList(),
                        value: vm.branches.firstWhere(
                          (b) => b.id == selectedBranchId,
                          orElse: () => vm.branches.first,
                        ).name,
                        onChanged: (val) {
                          setState(() => selectedBranchId =
                              vm.branches.firstWhere((b) => b.name == val).id);
                        },
                      ),

                    // Department dropdown
                    if (deptVm.departments.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: DropdownButtonFormField<String>(
                          value: deptVm.departments.firstWhere(
                            (d) => d.id == selectedDepartmentId,
                            orElse: () => deptVm.departments.first,
                          ).name,
                          decoration: InputDecoration(
                            labelText: 'Department',
                            labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.05),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          ),
                          items: deptVm.departments.map((d) => d.name).toSet().toList().map((item) {
                            return DropdownMenuItem(value: item, child: Text(item));
                          }).toList(),
                          onChanged: (val) {
                            setState(() => selectedDepartmentId =
                                deptVm.departments.firstWhere((d) => d.name == val).id);
                          },
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.secondaryLight),
                        ),
                      ),

                    // Unified Category Dropdown (Sub-category logic)
                    if (vm.isSubCategoriesLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator(color: AppColors.primaryLight)),
                      )
                    else if (vm.displayedSubCategories.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: DropdownButtonFormField<String>(
                          value: vm.displayedSubCategories.any((s) => s.id == selectedSubCategoryId) 
                              ? vm.displayedSubCategories.firstWhere((s) => s.id == selectedSubCategoryId).name
                              : vm.displayedSubCategories.any((s) => s.id == selectedCategoryId)
                                ? vm.displayedSubCategories.firstWhere((s) => s.id == selectedCategoryId).name
                                : vm.displayedSubCategories.first.name,
                          decoration: InputDecoration(
                            labelText: 'Category',
                            labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.05),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          ),
                          items: vm.displayedSubCategories.map((s) {
                            return DropdownMenuItem(value: s.name, child: Text(s.name));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              final selected = vm.displayedSubCategories.firstWhere((s) => s.name == val);
                              OwnerCategory? parentCat;
                              for (var c in vm.categories) {
                                if (c.subCategories.any((sub) => sub.id == selected.id)) {
                                  parentCat = c;
                                  break;
                                }
                              }
                              setState(() {
                                if (parentCat != null) {
                                  selectedCategoryId = parentCat.id;
                                  selectedSubCategoryId = selected.id;
                                } else {
                                  selectedCategoryId = selected.id;
                                  selectedSubCategoryId = null;
                                }
                              });
                            }
                          },
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.secondaryLight),
                        ),
                      ),

                    _buildTextField('Product Name', Icons.inventory_2_rounded, controller: vm.nameController),
                    Row(
                      children: [
                        Expanded(child: _buildTextField('Stock Quantity', Icons.numbers_rounded, isNumber: true, controller: vm.openingQtyController)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTextField('Unit (e.g. pcs)', Icons.straighten_rounded, controller: vm.unitController)),
                      ],
                    ),
                    _buildTextField('Critical Stock Point', Icons.warning_amber_rounded, isNumber: true, controller: vm.criticalStockPointController),
                    
                    const SizedBox(height: 12),
                    _buildSectionTitle('Pricing Details'),
                    const SizedBox(height: 16),
                    _buildTextField('Purchase Price', Icons.shopping_cart_rounded, isNumber: true, controller: vm.purchasePriceController),
                    _buildTextField('Sale Price', Icons.sell_rounded, isNumber: true, controller: vm.salePriceController),
                    
                    Row(
                      children: [
                        Expanded(child: _buildTextField('Min Corp Price', Icons.business_center_rounded, isNumber: true, controller: vm.minCorporatePriceController)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTextField('Max Corp Price', Icons.business_center_rounded, isNumber: true, controller: vm.maxCorporatePriceController)),
                      ],
                    ),

                    const SizedBox(height: 12),
                    _buildToggleRow('Allow Decimal Point', vm.allowDecimalQty, (val) => vm.toggleAllowDecimal(val)),
                    const SizedBox(height: 32),
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
                onPressed: vm.isActionLoading ? null : () => vm.submitProductForm(
                  context,
                  departmentId: selectedDepartmentId,
                  categoryId: selectedCategoryId,
                  subCategoryId: selectedSubCategoryId,
                  branchId: selectedBranchId,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  disabledBackgroundColor: AppColors.primaryLight,
                  foregroundColor: AppColors.secondaryLight,
                  disabledForegroundColor: AppColors.secondaryLight,
                  minimumSize: const Size.fromHeight(56),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: vm.isActionLoading
                    ? const CircularProgressIndicator(color: AppColors.secondaryLight)
                    : Text(
                        vm.isEditingProduct ? 'Update Product' : 'Save Product',
                        style: const TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

  @override
  void initState() {
    super.initState();
    final deptVm = context.read<DepartmentManagementViewModel>();
    if (deptVm.departments.isNotEmpty) {
      selectedDepartmentId = deptVm.departments.first.id;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<InventoryManagementViewModel>();
      if (vm.branches.isNotEmpty) {
        setState(() {
          selectedBranchId = vm.branches.first.id;
        });
      }
      if (vm.displayedSubCategories.isNotEmpty) {
        setState(() {
          final first = vm.displayedSubCategories.first;
          OwnerCategory? parentCat;
          for (var c in vm.categories) {
            if (c.subCategories.any((sub) => sub.id == first.id)) {
              parentCat = c;
              break;
            }
          }
          if (parentCat != null) {
            selectedCategoryId = parentCat.id;
            selectedSubCategoryId = first.id;
          } else {
            selectedCategoryId = first.id;
            selectedSubCategoryId = null;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<InventoryManagementViewModel>();
    final deptVm = context.watch<DepartmentManagementViewModel>();

    return FocusScope(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 5,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(vm.isEditingService ? 'Update Service' : 'Create Service', style: AppTextStyles.h2.copyWith(fontSize: 18)),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(vm.isEditingService ? 'Modify existing service details.' : 'Enter service details.', style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 30),

                    // Branch dropdown
                    if (vm.branches.isNotEmpty)
                      _buildDropdown(
                        'Branch',
                        vm.branches.map((b) => b.name).toSet().toList(),
                        value: vm.branches.firstWhere(
                          (b) => b.id == selectedBranchId,
                          orElse: () => vm.branches.first,
                        ).name,
                        onChanged: (val) {
                          setState(() => selectedBranchId =
                              vm.branches.firstWhere((b) => b.name == val).id);
                        },
                      ),

                    // Department dropdown
                    if (deptVm.departments.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: DropdownButtonFormField<String>(
                          value: deptVm.departments.firstWhere(
                            (d) => d.id == selectedDepartmentId,
                            orElse: () => deptVm.departments.first,
                          ).name,
                          decoration: InputDecoration(
                            labelText: 'Department',
                            labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.05),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          ),
                          items: deptVm.departments.map((d) => d.name).toSet().toList().map((item) {
                            return DropdownMenuItem(value: item, child: Text(item));
                          }).toList(),
                          onChanged: (val) {
                            setState(() => selectedDepartmentId =
                                deptVm.departments.firstWhere((d) => d.name == val).id);
                          },
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.secondaryLight),
                        ),
                      ),

                    // Unified Category Dropdown
                    if (vm.isSubCategoriesLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator(color: AppColors.primaryLight)),
                      )
                    else if (vm.displayedSubCategories.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: DropdownButtonFormField<String>(
                          value: vm.displayedSubCategories.any((s) => s.id == selectedSubCategoryId) 
                              ? vm.displayedSubCategories.firstWhere((s) => s.id == selectedSubCategoryId).name
                              : vm.displayedSubCategories.any((s) => s.id == selectedCategoryId)
                                ? vm.displayedSubCategories.firstWhere((s) => s.id == selectedCategoryId).name
                                : vm.displayedSubCategories.first.name,
                          decoration: InputDecoration(
                            labelText: 'Category',
                            labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.05),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          ),
                          items: vm.displayedSubCategories.map((s) {
                            return DropdownMenuItem(value: s.name, child: Text(s.name));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              final selected = vm.displayedSubCategories.firstWhere((s) => s.name == val);
                              OwnerCategory? parentCat;
                              for (var c in vm.categories) {
                                if (c.subCategories.any((sub) => sub.id == selected.id)) {
                                  parentCat = c;
                                  break;
                                }
                              }
                              setState(() {
                                if (parentCat != null) {
                                  selectedCategoryId = parentCat.id;
                                  selectedSubCategoryId = selected.id;
                                } else {
                                  selectedCategoryId = selected.id;
                                  selectedSubCategoryId = null;
                                }
                              });
                            }
                          },
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.secondaryLight),
                        ),
                      ),

                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: TextField(
                        controller: vm.nameController,
                        decoration: InputDecoration(
                          labelText: 'Service Name',
                          prefixIcon: const Icon(Icons.home_repair_service_rounded, color: AppColors.secondaryLight, size: 20),
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.05),
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
                          labelText: 'Service Price',
                          prefixIcon: const Icon(Icons.sell_rounded, color: AppColors.secondaryLight, size: 20),
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: TextField(
                        controller: vm.minCorporatePriceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Min Corporate Price',
                          prefixIcon: const Icon(Icons.attach_money_rounded, color: AppColors.secondaryLight, size: 20),
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: TextField(
                        controller: vm.maxCorporatePriceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Max Corporate Price',
                          prefixIcon: const Icon(Icons.attach_money_rounded, color: AppColors.secondaryLight, size: 20),
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
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
                onPressed: vm.isActionLoading ? null : () => vm.submitServiceForm(
                  context,
                  departmentId: selectedDepartmentId,
                  categoryId: selectedCategoryId,
                  subCategoryId: selectedSubCategoryId,
                  branchId: selectedBranchId,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  disabledBackgroundColor: AppColors.primaryLight,
                  foregroundColor: AppColors.secondaryLight,
                  disabledForegroundColor: AppColors.secondaryLight,
                  minimumSize: const Size.fromHeight(56),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: vm.isActionLoading
                    ? const CircularProgressIndicator(color: AppColors.secondaryLight)
                    : Text(
                        vm.isEditingService ? 'Update Service' : 'Save Service',
                        style: const TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddCategorySheet extends StatefulWidget {
  const _AddCategorySheet();

  @override
  State<_AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<_AddCategorySheet> {

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<InventoryManagementViewModel>();

    return FocusScope(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 5,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(vm.isEditingCategory ? 'Update Category' : 'Create Category', style: AppTextStyles.h2.copyWith(fontSize: 18)),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(vm.isEditingCategory ? 'Modify existing category details.' : 'Enter details for the new category.', style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 30),

                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: TextField(
                        controller: vm.categoryNameController,
                        decoration: InputDecoration(
                          labelText: 'Category Name',
                          prefixIcon: const Icon(Icons.account_tree_rounded, color: AppColors.secondaryLight, size: 20),
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.05),
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
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
            child: ElevatedButton(
              onPressed: vm.isActionLoading ? null : () => vm.submitCategoryForm(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  disabledBackgroundColor: AppColors.primaryLight,
                  foregroundColor: AppColors.secondaryLight,
                  disabledForegroundColor: AppColors.secondaryLight,
                  minimumSize: const Size.fromHeight(56),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: vm.isActionLoading
                  ? const CircularProgressIndicator(color: AppColors.secondaryLight)
                  : Text(
                      vm.isEditingCategory ? 'Update Category' : 'Save Category',
                      style: const TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _AddSubCategorySheet extends StatefulWidget {
  final String categoryId;
  const _AddSubCategorySheet({required this.categoryId});

  @override
  State<_AddSubCategorySheet> createState() => _AddSubCategorySheetState();
}

class _AddSubCategorySheetState extends State<_AddSubCategorySheet> {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<InventoryManagementViewModel>();

    return FocusScope(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 5,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Create Sub Category', style: AppTextStyles.h2.copyWith(fontSize: 18)),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Enter details for the new sub category.', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 30),

                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: TextField(
                        controller: vm.categoryNameController,
                        decoration: InputDecoration(
                          labelText: 'Sub Category Name',
                          prefixIcon: const Icon(Icons.account_tree_rounded, color: AppColors.secondaryLight, size: 20),
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.05),
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
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: ElevatedButton(
                onPressed: vm.isActionLoading ? null : () => vm.submitSubCategoryForm(context, categoryId: widget.categoryId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  disabledBackgroundColor: AppColors.primaryLight,
                  foregroundColor: AppColors.secondaryLight,
                  disabledForegroundColor: AppColors.secondaryLight,
                  minimumSize: const Size.fromHeight(56),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: vm.isActionLoading
                    ? const CircularProgressIndicator(color: AppColors.secondaryLight)
                    : const Text(
                        'Save Sub Category',
                        style: TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildHandle() {
  return Center(
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      width: 40,
      height: 5,
      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
    ),
  );
}

Widget _buildSectionTitle(String title) {
  return Text(
    title,
    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.secondaryLight),
  );
}

Widget _buildTextField(String label, IconData iconData, {bool isNumber = false, TextEditingController? controller}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    child: TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(iconData, color: AppColors.secondaryLight, size: 20),
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

Widget _buildDropdown(String label, List<String> items, {required String value, required void Function(String?) onChanged}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    child: DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.secondaryLight),
    ),
  );
}

Widget _buildToggleRow(String label, bool value, Function(bool) onChanged) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.secondaryLight,
      ),
    ],
  );
}
