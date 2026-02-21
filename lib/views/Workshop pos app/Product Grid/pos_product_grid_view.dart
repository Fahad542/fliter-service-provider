import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/pos_product_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../widgets/pos_widgets.dart';
import '../../Navbar/pos_shell.dart';
import '../Home Screen/pos_view_model.dart';
import '../Promo/pos_promo_view.dart';
import '../Technician Assignment/pos_technician_assignment_view.dart';
import 'product_grid_view_model.dart';

class PosProductGridView extends StatefulWidget {
  final String departmentName;
  final String departmentId;
  final List<String>? preSelectedProducts;

  const PosProductGridView({
    super.key,
    required this.departmentName,
    required this.departmentId,
    this.preSelectedProducts,
  });

  @override
  State<PosProductGridView> createState() => _PosProductGridViewState();
}

class _PosProductGridViewState extends State<PosProductGridView> {
  // All state moved to ProductGridViewModel and PosViewModel

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<PosViewModel>();
      await vm.fetchProducts();

      // Attempt to auto-select the category based on departmentName
      if (vm.uniqueCategories.contains(widget.departmentName)) {
        vm.setCategory(widget.departmentName);
      } else {
        vm.setCategory('All'); // Fallback
      }
      
      if (widget.preSelectedProducts != null && widget.preSelectedProducts!.isNotEmpty) {
        // Clear cart first so we don't duplicate when repeatedly entering the screen
        vm.clearCart(); 

        final allProducts = vm.products;
        for (final productId in widget.preSelectedProducts!) {
          try {
            final product = allProducts.firstWhere((p) => p.id == productId);
            vm.addToCart(product);
          } catch (_) {
            // Product not found, ignore
          }
        }
      }
    });
  }

  // Mock departments - REMOVED
  // final List<Map<String, dynamic>> _departments = [
  //   {'name': 'Oil Change', 'icon': Icons.oil_barrel_outlined},
  //   {'name': 'Car Wash', 'icon': Icons.local_car_wash_outlined},
  //   {'name': 'Repair', 'icon': Icons.build_outlined},
  //   {'name': 'Tyre Service', 'icon': Icons.tire_repair_outlined},
  //   {'name': 'AC Service', 'icon': Icons.ac_unit_outlined},
  //   {'name': 'Detailing', 'icon': Icons.auto_awesome_outlined},
  //   {'name': 'Battery', 'icon': Icons.battery_charging_full_outlined},
  // ];

  // Mock products per department - REMOVED
  // final Map<String, List<PosProduct>> _departmentProducts = {
  //   'Oil Change': [
  //     const PosProduct(name: 'Engine Oil 5W-30', category: 'Oils', price: 85, stock: 24, unit: 'Litre'),
  //     const PosProduct(name: 'Engine Oil 10W-40', category: 'Oils', price: 65, stock: 18, unit: 'Litre'),
  //     const PosProduct(name: 'Synthetic Oil 0W-20', category: 'Oils', price: 120, stock: 8, unit: 'Litre'),
  //     const PosProduct(name: 'Oil Filter', category: 'Filters', price: 35, stock: 30, unit: 'Piece'),
  //     const PosProduct(name: 'Air Filter', category: 'Filters', price: 45, stock: 3, reorderLevel: 5, unit: 'Piece'),
  //     const PosProduct(name: 'Cabin Filter', category: 'Filters', price: 55, stock: 0, unit: 'Piece'),
  //     const PosProduct(name: 'Drain Plug Gasket', category: 'Parts', price: 8, stock: 50, unit: 'Piece'),
  //     const PosProduct(name: 'Oil Change - Standard', category: 'Labour', price: 50, isService: true),
  //     const PosProduct(name: 'Oil Change - Full Synthetic', category: 'Labour', price: 80, isService: true),
  //     const PosProduct(name: 'Engine Flush', category: 'Labour', price: 60, isService: true),
  //   ],
  //   'Car Wash': [
  //     const PosProduct(name: 'Basic Exterior Wash', category: 'Wash', price: 35, isService: true),
  //     const PosProduct(name: 'Full Interior + Exterior', category: 'Wash', price: 75, isService: true),
  //     const PosProduct(name: 'Premium Detailing Wash', category: 'Wash', price: 150, isService: true),
  //     const PosProduct(name: 'Car Shampoo', category: 'Consumables', price: 25, stock: 15, unit: 'Bottle'),
  //     const PosProduct(name: 'Wax Polish', category: 'Consumables', price: 40, stock: 8, unit: 'Bottle'),
  //     const PosProduct(name: 'Air Freshener', category: 'Extras', price: 15, stock: 40, unit: 'Piece'),
  //   ],
  //   'Repair': [
  //     const PosProduct(name: 'Brake Pad Set (Front)', category: 'Brakes', price: 180, stock: 6, unit: 'Set'),
  //     const PosProduct(name: 'Brake Pad Set (Rear)', category: 'Brakes', price: 160, stock: 4, unit: 'Set'),
  //     const PosProduct(name: 'Brake Disc (Front)', category: 'Brakes', price: 250, stock: 2, reorderLevel: 3, unit: 'Piece'),
  //     const PosProduct(name: 'Spark Plug Set', category: 'Engine', price: 120, stock: 10, unit: 'Set'),
  //     const PosProduct(name: 'Belt Tensioner', category: 'Engine', price: 95, stock: 3, reorderLevel: 5, unit: 'Piece'),
  //     const PosProduct(name: 'Diagnostic Scan', category: 'Labour', price: 100, isService: true),
  //     const PosProduct(name: 'Brake Service Labour', category: 'Labour', price: 120, isService: true),
  //   ],
  // };

  List<PosProduct> get _currentProducts {
    final vm = Provider.of<PosViewModel>(context);
    return vm.products;
  }

  List<String> get _categories {
    final vm = Provider.of<PosViewModel>(context);
    return vm.uniqueCategories;
  }

  double get _subtotal => Provider.of<PosViewModel>(context).subtotalExclVat;
  double get _totalVat => Provider.of<PosViewModel>(context).totalTax;

  double get _discountAmount {
    final vm = Provider.of<PosViewModel>(context);
    return vm.totalIndividualDiscount + vm.totalGlobalDiscount;
  }

  double get _grandTotal {
    final vm = Provider.of<PosViewModel>(context);
    return vm.totalAmount;
  }

  void _addToCart(PosProduct product) {
    context.read<PosViewModel>().addToCart(product);
  }

  void _updateQty(PosProduct product, double qty) {
    context.read<PosViewModel>().setSpecificQuantity(product, qty);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    final vm = Provider.of<PosViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F0),
      appBar: const PosScreenAppBar(title: 'Point of Sale'),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : isTablet
          // ─── TABLET: Left sidebar + product grid ───
          ? Row(
              children: [
                // Left Department Sidebar (tablet only)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 110,
                    margin: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryLight,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Expanded(
                          child: Consumer<PosViewModel>(
                            builder: (context, vm, child) {
                              final categories = vm.uniqueCategories;
                              return ListView.builder(
                                itemCount: categories.length,
                                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                itemBuilder: (context, index) {
                                  final cat = categories[index];
                                  final isSelected = vm.selectedCategory == cat;
                                  return GestureDetector(
                                    onTap: () => vm.setCategory(cat),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(vertical: 3),
                                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                                      decoration: BoxDecoration(
                                        color: isSelected ? AppColors.primaryLight : Colors.transparent,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(Icons.category_outlined, size: 28, color: isSelected ? AppColors.secondaryLight : Colors.grey.shade400),
                                          const SizedBox(height: 8),
                                          Text(
                                            cat,
                                            style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? AppColors.secondaryLight : Colors.grey.shade400),
                                            textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Product grid (tablet)
                Expanded(
                  flex: 5,
                  child: _buildProductSection(isTablet),
                ),
              ],
            )
          // ─── MOBILE: Departments horizontal + product grid ───
          : _buildProductSection(isTablet),
      // ─── Bottom Bar (Cart Summary) ───
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(isTablet ? 20 : 14, 12, isTablet ? 20 : 14, MediaQuery.of(context).padding.bottom + 12),
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
            // Cart count badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: isTablet ? 22 : 16, color: const Color(0xFF1E2124)),
                  const SizedBox(width: 8),
                  Text(
                    '${context.watch<PosViewModel>().cartItems.length} items',
                    style: TextStyle(fontSize: isTablet ? 15 : 11, fontWeight: FontWeight.w700, color: const Color(0xFF1E2124)),
                  ),
                ],
              ),
            ),
            SizedBox(width: isTablet ? 16 : 12),
            // Grand total
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Grand Total', style: TextStyle(fontSize: isTablet ? 12 : 9, color: Colors.grey, fontWeight: FontWeight.w500)),
                  Text(
                    'SAR ${_grandTotal.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: isTablet ? 22 : 16, fontWeight: FontWeight.w800, color: const Color(0xFF1E2124)),
                  ),
                ],
              ),
            ),
            // View Invoice button
            SizedBox(
              height: isTablet ? 54 : 42,
              child: ElevatedButton.icon(
                onPressed: () => _showInvoiceBottomSheet(context, isTablet),
                icon: Icon(Icons.receipt_long_outlined, size: isTablet ? 22 : 16),
                label: Text('View Invoice', style: TextStyle(fontWeight: FontWeight.w700, fontSize: isTablet ? 16 : 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC145),
                  foregroundColor: const Color(0xFF1E2124),
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Invoice Bottom Sheet ──
  void _showInvoiceBottomSheet(BuildContext context, bool isTablet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
              height: MediaQuery.of(context).size.height * (isTablet ? 0.9 : 0.85),
              decoration: const BoxDecoration(
                color: Color(0xFFFBF9F6),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle bar
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

                  // ── Customer & Vehicle Card ──
                  Container(
                    margin: EdgeInsets.fromLTRB(isTablet ? 32 : 14, 6, isTablet ? 32 : 14, 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 14, vertical: isTablet ? 14 : 12),
                      child: Column(
                        children: [
                          // ID + Name + Status
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '#INV-001',
                                  style: TextStyle(fontSize: isTablet ? 16 : 10, fontWeight: FontWeight.w800, color: const Color(0xFF1E2124)),
                                ),
                              ),
                              SizedBox(width: isTablet ? 8 : 6),
                              Expanded(
                                child: Text(
                                  'Ahmed Al Rashid',
                                  style: TextStyle(fontSize: isTablet ? 22 : 13, fontWeight: FontWeight.w700, color: const Color(0xFF1E2124)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text('Draft', style: TextStyle(color: Colors.blue, fontSize: isTablet ? 15 : 9, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                          SizedBox(height: isTablet ? 12 : 10),
                          Row(
                            children: [
                              const Icon(Icons.directions_car_outlined, size: 22, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text('Toyota Camry • ABC 1234',
                                    style: TextStyle(color: Colors.grey, fontSize: isTablet ? 17 : 10, fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.phone_outlined, size: 22, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text('055 123 4567', style: TextStyle(color: Colors.grey, fontSize: isTablet ? 17 : 10, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Order Items Header ──
                  Padding(
                    padding: EdgeInsets.fromLTRB(isTablet ? 36 : 18, isTablet ? 24 : 12, isTablet ? 36 : 18, 10),
                    child: Row(
                      children: [
                        Text('Order Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isTablet ? 20 : 14, color: const Color(0xFF1E2124))),
                        const Spacer(),
                        if (context.read<PosViewModel>().cartItems.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(10)),
                            child: Text('${context.read<PosViewModel>().cartItems.length}', style: TextStyle(fontSize: isTablet ? 16 : 11, fontWeight: FontWeight.w700, color: const Color(0xFF1E2124))),
                          ),
                      ],
                    ),
                  ),

                  // ── Cart Items ──
                  Expanded(
                    child: Consumer<PosViewModel>(
                      builder: (context, vm, child) {
                        return vm.cartItems.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.shade300),
                                    const SizedBox(height: 8),
                                    Text('No items added', style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 14),
                                itemCount: vm.cartItems.length,
                                itemBuilder: (context, index) {
                                  final item = vm.cartItems[index];
                                  return _buildCartItem(item, isTablet);
                                },
                              );
                      },
                    ),
                  ),




                  // ── Totals ──
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 14),
                    padding: EdgeInsets.all(isTablet ? 24 : 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      children: [
                        _buildTotalRow('Total Amount Gross', 'SAR ${_subtotal.toStringAsFixed(2)}', isTablet),
                        SizedBox(height: isTablet ? 8 : 6),
                        
                        // New Discount 
                        _buildTotalRow('Discount', '- SAR ${_discountAmount.toStringAsFixed(2)}', isTablet, color: Colors.green),
                        SizedBox(height: isTablet ? 8 : 6),
                        
                        _buildTotalRow('Price after discount', 'SAR ${(_subtotal - _discountAmount).toStringAsFixed(2)}', isTablet),
                        SizedBox(height: isTablet ? 10 : 8),
                        
                        Divider(height: 1, color: Colors.grey.shade200),
                        SizedBox(height: isTablet ? 10 : 8),
                        
                        _buildTotalRow('Tax (15%)', 'SAR ${_totalVat.toStringAsFixed(2)}', isTablet, color: Colors.grey),
                        SizedBox(height: isTablet ? 10 : 8),
                        
                        Row(
                          children: [
                            Text('Total amount', style: TextStyle(fontWeight: FontWeight.w800, fontSize: isTablet ? 24 : 14, color: const Color(0xFF1E2124))),
                            const Spacer(),
                            Text('SAR ${_grandTotal.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: isTablet ? 24 : 14, color: const Color(0xFF1E2124))),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isTablet ? 10 : 8),

                  // ── Promo Code ──
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 14),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PosPromoView()),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.local_offer_outlined, size: isTablet ? 24 : 14, color: const Color(0xFFFFC145)),
                            SizedBox(width: isTablet ? 10 : 6),
                            Consumer<PosViewModel>(
                              builder: (context, vm, child) {
                                return Text(
                                  vm.activePromoCode.isEmpty ? 'Add Promo Code' : 'Promo: ${vm.activePromoCode}',
                                  style: TextStyle(
                                    fontSize: isTablet ? 17 : 10,
                                    fontWeight: FontWeight.w600,
                                    color: vm.activePromoCode.isEmpty ? const Color(0xFF1E2124) : Colors.green,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: isTablet ? 10 : 8),

                  // ── Action Buttons ──
                  Padding(
                    padding: EdgeInsets.fromLTRB(isTablet ? 32 : 14, 0, isTablet ? 32 : 14, MediaQuery.of(context).padding.bottom + 20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: isTablet ? 56 : 38,
                                child: OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.grey.shade300),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Text(
                                    'Save Draft',
                                    style: TextStyle(color: const Color(0xFF1E2124), fontWeight: FontWeight.w600, fontSize: isTablet ? 16 : 11),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: isTablet ? 8 : 6),
                            Expanded(
                              child: SizedBox(
                                height: isTablet ? 56 : 38,
                                child: Consumer<PosViewModel>(
                                  builder: (context, vm, child) {
                                    return ElevatedButton(
                                      onPressed: vm.isLoading
                                          ? null
                                          : () async {
                                              String finalDeptId = widget.departmentId;
                                              if (finalDeptId == 'dept-mock-id') {
                                                if (vm.products.isNotEmpty) {
                                                  finalDeptId = vm.products.first.departmentId ?? '1';
                                                } else {
                                                  finalDeptId = '1'; // Fallback to a valid BigInt string
                                                }
                                              }
                                              final success = await vm.submitWalkInOrder([finalDeptId], context);
                                              final orderId = vm.currentJobId ?? '';
                                              if (success && context.mounted) {
                                                if (orderId.isNotEmpty) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (_) => PosTechnicianAssignmentView(jobId: orderId)),
                                                  );
                                                } else {
                                                  vm.setShellSelectedIndex(2); // Orders Tab
                                                  vm.fetchOrders();
                                                  Navigator.pushAndRemoveUntil(
                                                    context,
                                                    MaterialPageRoute(builder: (_) => const PosShell(initialIndex: 2)),
                                                    (route) => false,
                                                  );
                                                }
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFFFC145),
                                        foregroundColor: const Color(0xFF1E2124),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      child: vm.isLoading
                                          ? const SizedBox(
                                              height: 18,
                                              width: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Color(0xFF1E2124),
                                              ),
                                            )
                                          : const Text(
                                              'Forward to Technician',
                                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                                            ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            );
          },
        );
      },
    );
  }
  // ── Product Section (shared by tablet & mobile) ──
  Widget _buildProductSection(bool isTablet) {
    return Consumer<ProductGridViewModel>(
      builder: (context, gridVm, child) {
        return Column(
      children: [
        // Search Bar
        Padding(
          padding: EdgeInsets.fromLTRB(isTablet ? 20 : 12, isTablet ? 16 : 12, isTablet ? 20 : 12, 0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: gridVm.searchController,
              onChanged: (v) => gridVm.setSearchQuery(v),
              style: AppTextStyles.bodyMedium.copyWith(fontSize: isTablet ? 15 : 13),
              decoration: InputDecoration(
                hintText: 'Search products & services...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: isTablet ? 17 : 13),
                prefixIcon: Icon(Icons.search, size: isTablet ? 26 : 18, color: Colors.grey.shade400),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isTablet ? 20 : 12),
                suffixIcon: gridVm.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, size: isTablet ? 18 : 16),
                        onPressed: () => gridVm.clearSearch(),
                      )
                    : null,
              ),
            ),
          ),
        ),

        // ── Mobile: Horizontal Department Strip ──
        if (!isTablet) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 44,
            child: Consumer<PosViewModel>(
              builder: (context, vm, child) {
                final categories = vm.uniqueCategories;
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = vm.selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => vm.setCategory(cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryLight : AppColors.secondaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.category_outlined, size: 18, color: isSelected ? AppColors.secondaryLight : Colors.grey.shade400),
                            const SizedBox(width: 6),
                            Text(
                              cat,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? AppColors.secondaryLight : Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            ),
          ),
        ],

        // Category Chips
        SizedBox(height: isTablet ? 16 : 8),
        SizedBox(
          height: isTablet ? 44 : 32,
          child: Consumer<PosViewModel>(
            builder: (context, vm, child) {
              final categories = vm.uniqueCategories;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 12),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = vm.selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => vm.setCategory(cat),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 12, vertical: isTablet ? 8 : 6),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryLight : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryLight : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: isTablet ? 15 : 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppColors.secondaryLight : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          ),
        ),

        SizedBox(height: isTablet ? 12 : 8),

        // Products Grid
        Expanded(
          child: _currentProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text('No products found', style: TextStyle(color: Colors.grey.shade400, fontSize: isTablet ? 16 : 14)),
                      const SizedBox(height: 20),
                      Consumer<PosViewModel>(
                        builder: (context, vm, child) {
                          return ElevatedButton.icon(
                            onPressed: vm.isLoading
                                ? null
                                : () async {
                                    String finalDeptId = widget.departmentId;
                                    if (finalDeptId == 'dept-mock-id') {
                                      if (vm.products.isNotEmpty) {
                                        finalDeptId = vm.products.first.departmentId ?? '1';
                                      } else {
                                        finalDeptId = '1'; // Fallback to a valid BigInt string
                                      }
                                    }
                                    final success = await vm.submitWalkInOrder([finalDeptId], context);
                                    final orderId = vm.currentJobId ?? '';
                                    if (success && context.mounted) {
                                      if (orderId.isNotEmpty) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => PosTechnicianAssignmentView(jobId: orderId)),
                                        );
                                      } else {
                                        // Fallback if orderId is missing for some reason
                                        vm.setShellSelectedIndex(2); // Orders Tab
                                        vm.fetchOrders();
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(builder: (_) => const PosShell(initialIndex: 2)),
                                          (route) => false,
                                        );
                                      }
                                    }
                                  },
                            icon: vm.isLoading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Icon(Icons.person_search_outlined, size: isTablet ? 22 : 18),
                            label: Text(
                              'Continue to Technician',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: isTablet ? 15 : 13,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondaryLight,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 24 : 16,
                                vertical: isTablet ? 14 : 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: EdgeInsets.fromLTRB(isTablet ? 20 : 12, 0, isTablet ? 20 : 12, 16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isTablet ? 3 : 2,
                    childAspectRatio: isTablet ? 1.1 : 0.95,
                    crossAxisSpacing: isTablet ? 14 : 10,
                    mainAxisSpacing: isTablet ? 14 : 10,
                  ),
                  itemCount: _currentProducts.length,
                  itemBuilder: (context, index) {
                    final allProducts = _currentProducts;
                    // Apply filtering using ViewModel manually since we get base products from PosViewModel
                    final product = allProducts[index];
                    
                    final matchesCategory = gridVm.selectedCategory == 'All' || product.category == gridVm.selectedCategory;
                    final matchesSearch = gridVm.searchQuery.isEmpty || product.name.toLowerCase().contains(gridVm.searchQuery.toLowerCase());
                    
                    if (!matchesCategory || !matchesSearch) return const SizedBox.shrink();

                    return Consumer<PosViewModel>(
                      builder: (context, vm, child) {
                        final cartItemIndex = vm.cartItems.indexWhere((i) => i.product.id == product.id);
                        final qty = cartItemIndex != -1 ? vm.cartItems[cartItemIndex].quantity : 0.0;
                        return _buildProductCard(product, qty, isTablet);
                      },
                    );
                  },
                ),
        ),
      ],
    );
      },
    );
  }

  Widget _buildProductCard(PosProduct product, double cartQty, bool isTablet) {

    return GestureDetector(
      onTap: () => _addToCart(product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
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
          padding: EdgeInsets.all(isTablet ? 14 : 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name + Stock badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: isTablet ? 16 : 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (cartQty > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'x${cartQty % 1 == 0 ? cartQty.toInt() : cartQty}',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.secondaryLight),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 4),

              // Stock indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: product.stockColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  product.stockLabel,
                  style: TextStyle(
                    fontSize: isTablet ? 10 : 8,
                    fontWeight: FontWeight.w600,
                    color: product.stockColor,
                  ),
                ),
              ),

              const Spacer(),

              // Price
              Text(
                'SAR ${product.priceInclVat.toStringAsFixed(2)}',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: isTablet ? 18 : 14,
                  color: AppColors.secondaryLight,
                ),
              ),
              Text(
                'incl. VAT',
                style: TextStyle(fontSize: isTablet ? 9 : 8, color: Colors.grey),
              ),

              SizedBox(height: isTablet ? 8 : 6),

              // +/- Controls
              Row(
                children: [
                  _buildQtyButton(Icons.remove, isTablet, onTap: cartQty > 0
                      ? () => context.read<PosViewModel>().updateQuantity(product, -1)
                      : null),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showQtyDialog(product, isTablet),
                      child: Container(
                        height: isTablet ? 32 : 28,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          cartQty % 1 == 0 ? '${cartQty.toInt()}' : cartQty.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: isTablet ? 13 : 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  _buildQtyButton(Icons.add, isTablet, onTap: () => _addToCart(product)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQtyButton(IconData icon, bool isTablet, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isTablet ? 32 : 28,
        height: isTablet ? 32 : 28,
        decoration: BoxDecoration(
          color: onTap != null ? AppColors.secondaryLight : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: isTablet ? 16 : 14, color: onTap != null ? Colors.white : Colors.grey),
      ),
    );
  }

  // ── Cart Item ──
  Widget _buildCartItem(CartItem item, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 12 : 6),
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 10, vertical: isTablet ? 14 : 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.product.name,
                        style: TextStyle(fontSize: isTablet ? 16 : 12, fontWeight: FontWeight.w700, color: const Color(0xFF1E2124)),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${item.quantity % 1 == 0 ? item.quantity.toInt() : item.quantity} × SAR ${item.product.price.toStringAsFixed(0)}',
                            style: TextStyle(fontSize: isTablet ? 12 : 9, fontWeight: FontWeight.w600, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'SAR ${item.totalPrice.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: isTablet ? 16 : 12, fontWeight: FontWeight.w800, color: const Color(0xFF1E2124)),
                  ),
                  if (item.actualDiscountAmount > 0)
                    Text(
                      '-SAR ${item.actualDiscountAmount.toStringAsFixed(0)}',
                      style: TextStyle(fontSize: isTablet ? 11 : 9, fontWeight: FontWeight.w600, color: Colors.green),
                    ),
                ],
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => context.read<PosViewModel>().removeFromCart(item.product),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.close, size: isTablet ? 18 : 14, color: Colors.red.shade400),
                ),
              ),
            ],
          ),
          
          // Discount Row Inside Item
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Dis.', style: TextStyle(fontSize: isTablet ? 12 : 10, color: Colors.grey)),
              const SizedBox(width: 8),
              SizedBox(
                width: isTablet ? 60 : 50,
                height: isTablet ? 26 : 24,
                child: TextFormField(
                  initialValue: item.discount > 0 
                      ? (item.discount % 1 == 0 ? item.discount.toInt().toString() : item.discount.toString())
                      : '',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (val) {
                    final discount = double.tryParse(val) ?? 0.0;
                    context.read<PosViewModel>().setIndividualDiscount(item.product, discount, item.isDiscountPercent);
                  },
                  style: TextStyle(fontSize: isTablet ? 13 : 11),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    hintText: '0',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey.shade300)),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  context.read<PosViewModel>().setIndividualDiscount(item.product, item.discount, !item.isDiscountPercent);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 8 : 6, vertical: isTablet ? 4 : 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC145).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.isDiscountPercent ? '%' : 'SAR',
                    style: TextStyle(fontSize: isTablet ? 12 : 9, fontWeight: FontWeight.w700, color: const Color(0xFF1E2124)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Helpers ──
  Widget _buildTotalRow(String label, String value, bool isTablet, {Color? color}) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontSize: isTablet ? 18 : 10, color: color ?? Colors.grey.shade600)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: isTablet ? 18 : 10, fontWeight: FontWeight.w600, color: color ?? AppColors.secondaryLight)),
      ],
    );
  }

  void _showQtyDialog(PosProduct product, bool isTablet) {
    final vm = context.read<PosViewModel>();
    final currentQty = vm.cartItems.firstWhere((item) => item.product.id == product.id, orElse: () => CartItem(product: product, quantity: 0, isDiscountPercent: false)).quantity;

    final controller = TextEditingController(
      text: currentQty % 1 == 0 ? currentQty.toInt().toString() : currentQty.toString(),
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Enter Quantity', style: TextStyle(fontSize: isTablet ? 22 : 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(product.name, style: TextStyle(color: Colors.grey, fontSize: isTablet ? 16 : 12)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: isTablet ? 22 : 18, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: '0',
                suffixText: product.unit,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final qty = double.tryParse(controller.text) ?? 0;
              context.read<PosViewModel>().setSpecificQuantity(product, qty);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: AppColors.secondaryLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
