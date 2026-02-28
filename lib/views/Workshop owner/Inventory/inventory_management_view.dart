import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import 'inventory_management_view_model.dart';
import '../Departments/department_management_view_model.dart';
import '../../../models/workshop_owner_models.dart';
import '../widgets/owner_app_bar.dart';

class InventoryManagementView extends StatefulWidget {
  const InventoryManagementView({super.key});

  @override
  State<InventoryManagementView> createState() => _InventoryManagementViewState();
}

class _InventoryManagementViewState extends State<InventoryManagementView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

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
          body: Column(
            children: [
              _buildTabHeader(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProductsTab(vm),
                    _buildDepartmentsTab(vm),
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
      case 1: return 'Add Department';
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
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          width: 360, // Fixed width for a more "professional" segmented look
          height: 44,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6F9),
            borderRadius: BorderRadius.circular(14),
          ),
          child: TabBar(
            controller: _tabController,
            onTap: (index) => setState(() {}),
            dividerColor: Colors.transparent,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey.shade500,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
            tabs: const [
              Tab(text: 'PRODUCTS'),
              Tab(text: 'DEPARTMENTS'),
              Tab(text: 'CATEGORIES'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsTab(InventoryManagementViewModel vm) {
    final filteredProducts = vm.products.where((p) => 
      p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      p.category!.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: _buildSearchBar('Search by name or category...'),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              final product = filteredProducts[index];
              return _buildProductCard(product);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(OwnerProduct product) {
    final isStockLow = product.stockQty <= product.criticalLevel;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryLight.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isStockLow ? Colors.red.withOpacity(0.2) : Colors.grey.withOpacity(0.06),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.secondaryLight.withOpacity(0.08),
                        AppColors.secondaryLight.withOpacity(0.03),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.secondaryLight.withOpacity(0.05)),
                  ),
                  child: Icon(
                    product.type == 'product' ? Icons.inventory_2_rounded : Icons.home_repair_service_rounded,
                    color: AppColors.secondaryLight.withOpacity(0.8),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name, 
                        style: AppTextStyles.h2.copyWith(fontSize: 16, color: AppColors.secondaryLight),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              (product.category ?? 'Uncategorized').toUpperCase(),
                              style: const TextStyle(color: AppColors.secondaryLight, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            product.departmentIds.first,
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildPriceTag(product.salePrice),
              ],
            ),
          ),
          Container(height: 1, color: Colors.grey.withOpacity(0.05)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetricItem(
                  'STOCK', 
                  '${product.stockQty.toInt()} ${product.unit}', 
                  isStockLow ? AppColors.errorLight : AppColors.secondaryLight,
                  isAlert: isStockLow,
                ),
                _buildMetricItem('PURCHASE', 'SAR ${product.purchasePrice.toInt()}', Colors.grey.shade500),
                _buildMetricItem('CORPORATE', 'SAR ${product.corporateBasePrice?.toInt() ?? "0"}', AppColors.primaryLight),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceTag(double price) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'SAR ${price.toStringAsFixed(0)}',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: AppColors.secondaryLight,
            letterSpacing: -0.5,
          ),
        ),
        const Text(
          'RETAIL PRICE',
          style: TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5),
        ),
      ],
    );
  }

  Widget _buildMetricItem(String label, String value, Color color, {bool isAlert = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade400, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
        ),
        const SizedBox(height: 4),
        Row(
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
                fontSize: 14,
                color: color == AppColors.primaryLight ? AppColors.secondaryLight : color,
                backgroundColor: color == AppColors.primaryLight ? AppColors.primaryLight.withOpacity(0.2) : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDepartmentsTab(InventoryManagementViewModel vm) {
    return Consumer<DepartmentManagementViewModel>(
      builder: (context, departmentVm, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: departmentVm.departments.length,
          itemBuilder: (context, index) {
            return _buildSimpleActionCard(
              departmentVm.departments[index].name,
              Icons.account_tree_rounded,
              AppColors.primaryLight,
            );
          },
        );
      }
    );
  }

  Widget _buildCategoriesTab(InventoryManagementViewModel vm) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: vm.categories.length,
      itemBuilder: (context, index) {
        return _buildSimpleActionCard(
          vm.categories[index],
          Icons.category_rounded,
          AppColors.primaryLight,
        );
      },
    );
  }

  Widget _buildSimpleActionCard(String title, IconData icon, Color color) {
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.secondaryLight, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.secondaryLight),
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade300, size: 14),
        ],
      ),
    );
  }

  Widget _buildSearchBar(String hint) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        onChanged: (val) => setState(() => _searchQuery = val),
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryLight),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.05)),
          ),
        ),
      ),
    );
  }

  void _showAddAction(BuildContext context, InventoryManagementViewModel vm) {
    if (_tabController.index == 0) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ChangeNotifierProvider.value(
          value: vm,
          child: const _AddProductSheet(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Adding New ${_getAddLabel().split(" ").last}...'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: AppColors.secondaryLight,
        )
      );
    }
  }
}

class _AddProductSheet extends StatefulWidget {
  const _AddProductSheet();

  @override
  State<_AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends State<_AddProductSheet> {
  String? selectedDepartmentId;

  // Placeholder static values until the category APIs are implemented
  String selectedCategoryId = '1';
  String selectedSubCategoryId = '1';

  @override
  void initState() {
    super.initState();
    final deptVm = context.read<DepartmentManagementViewModel>();
    if (deptVm.departments.isNotEmpty) {
      selectedDepartmentId = deptVm.departments.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<InventoryManagementViewModel>();
    final deptVm = context.watch<DepartmentManagementViewModel>();

    return FocusScope(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.90,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            _buildHandle(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Create Product', style: AppTextStyles.h2.copyWith(fontSize: 22)),
                    const SizedBox(height: 8),
                    const Text('Enter product details to add to inventory.', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 30),

                    // Department dropdown
                    if (deptVm.departments.isNotEmpty)
                      _buildDropdown(
                        'Department',
                        deptVm.departments.map((d) => d.name).toList(),
                        value: deptVm.departments.firstWhere(
                          (d) => d.id == selectedDepartmentId,
                          orElse: () => deptVm.departments.first,
                        ).name,
                        onChanged: (val) {
                          setState(() => selectedDepartmentId =
                              deptVm.departments.firstWhere((d) => d.name == val).id);
                        },
                      ),

                    _buildTextField('Category ID', Icons.category_rounded, controller: vm.categoryIdController, isNumber: true),
                    _buildTextField('Sub-Category ID', Icons.subdirectory_arrow_right_rounded, controller: vm.subCategoryIdController, isNumber: true),
                    _buildTextField('Product Name', Icons.inventory_2_rounded, controller: vm.nameController),
                    _buildTextField('Unit (e.g., pcs)', Icons.straighten_rounded, controller: vm.unitController),
                    _buildTextField('Purchase Price', Icons.attach_money_rounded, isNumber: true, controller: vm.purchasePriceController),
                    _buildTextField('Sale Price', Icons.sell_rounded, isNumber: true, controller: vm.salePriceController),
                    _buildTextField('Opening Qty', Icons.format_list_numbered_rounded, isNumber: true, controller: vm.openingQtyController),
                    _buildTextField('Critical Stock Point', Icons.warning_amber_rounded, isNumber: true, controller: vm.criticalStockPointController),
                    _buildTextField('KM Type Value (e.g., 5000)', Icons.speed_rounded, isNumber: true, controller: vm.kmTypeValueController),

                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text('Allow Decimal Qty', style: TextStyle(fontWeight: FontWeight.w600)),
                      activeColor: AppColors.primaryLight,
                      value: vm.allowDecimalQty,
                      onChanged: (value) => vm.toggleAllowDecimal(value),
                      contentPadding: EdgeInsets.zero,
                    ),

                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: vm.isLoading ? null : () => vm.submitProductForm(
                        context,
                        departmentId: selectedDepartmentId,
                        categoryId: selectedCategoryId,
                        subCategoryId: selectedSubCategoryId,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryLight,
                        disabledBackgroundColor: Colors.grey.shade300,
                        minimumSize: const Size.fromHeight(56),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: vm.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Save Product',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                            ),
                    ),
                    const SizedBox(height: 20),
                  ],
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

  Widget _buildTextField(String label, IconData icon, {bool isNumber = false, TextEditingController? controller}) {
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
          labelStyle: const TextStyle(color: Colors.grey),
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
}
