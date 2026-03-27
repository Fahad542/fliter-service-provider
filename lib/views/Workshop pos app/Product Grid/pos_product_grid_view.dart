import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../utils/toast_service.dart';
import '../../../models/pos_product_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/app_formatters.dart';
import '../../../widgets/pos_widgets.dart';

import '../Home Screen/pos_view_model.dart';
import '../Navbar/pos_shell.dart';
import '../Promo/promo_code_dialog.dart';
import '../../../models/pos_order_model.dart';
import '../Technician Assignment/pos_technician_assignment_view.dart';
import 'product_grid_view_model.dart';

class PosProductGridView extends StatefulWidget {
  final String? departmentName;
  final String? departmentId;
  final List<dynamic>? preSelectedItems;
  final String? completingOrderId;
  final PosOrder? completingOrder;
  final bool isReadOnly;
  final bool showBackButton;

  const PosProductGridView({
    super.key,
    this.departmentName,
    this.departmentId,
    this.preSelectedItems,
    this.completingOrderId,
    this.completingOrder,
    this.isReadOnly = false,
    this.showBackButton = true,
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
      
      // Reset product type filters so returning to grid shows all items by default
      vm.setProductType('All');
      context.read<ProductGridViewModel>().setSubCategory('All');

      if (widget.showBackButton && widget.departmentId != null && widget.departmentId != 'All') {
        await vm.fetchProducts(departmentId: widget.departmentId);
      } else if (widget.showBackButton && vm.allProducts.isEmpty) {
        await vm.fetchProducts();
      }

      // Always default to 'All' category when opening the grid to show all available options
      _onCategorySelected(vm, 'All');
      
      if (widget.preSelectedItems != null && widget.preSelectedItems!.isNotEmpty) {
        // Clear cart first so we don't duplicate when repeatedly entering the screen
        vm.clearCart(); 

        final allProducts = vm.allProducts; // Use unfiltered list to guarantee both products and services are found
        for (final item in widget.preSelectedItems!) {
          try
          {
            final productId = item['productId']?.toString() ?? item['serviceId']?.toString() ?? item['id']?.toString();
            final qtyRaw = item['quantity'] ?? item['qty'] ?? 1;
            final double qty = (qtyRaw is num) ? qtyRaw.toDouble() : double.tryParse(qtyRaw.toString()) ?? 1.0;

            if (productId != null && productId.isNotEmpty) {
              final product = allProducts.firstWhere((p) => p.id == productId);
              vm.addToCart(product);
              
              if (qty != 1.0) {
                vm.setSpecificQuantity(product, qty);
              }

              // Load previously applied API discounts into the POS Cart item
              final discountTypeStr = item['discountType']?.toString();
              final discountValStr = item['discountValue']?.toString() ?? '0';
              final discountValue = double.tryParse(discountValStr) ?? 0.0;
              
              if (discountValue > 0 && discountTypeStr != null && discountTypeStr.isNotEmpty) {
                vm.setIndividualDiscount(product, discountValue, discountTypeStr == 'percent');
              }
            }
          } catch (_)
          {
            // Product not found, ignore
          }
        }
      }

      // Hydrate Global Discounts or Promo Codes if they were applied to the previous order
      if (widget.completingOrder != null) {
        PosOrderJob? targetJob;
        if (widget.completingOrderId != null && widget.completingOrder!.jobs.isNotEmpty) {
          try {
            targetJob = widget.completingOrder!.jobs.firstWhere((j) => j.id == widget.completingOrderId);
          } catch (_) {}
        }

        final globalType = targetJob?.totalDiscountType ?? widget.completingOrder!.totalDiscountType;
        final globalValue = (targetJob != null && targetJob.totalDiscountValue > 0) 
            ? targetJob.totalDiscountValue 
            : (widget.completingOrder!.totalDiscountValue ?? 0.0);

        final promoValueAmount = (targetJob != null && targetJob.promoDiscountAmount > 0) 
            ? targetJob.promoDiscountAmount 
            : (widget.completingOrder!.promoDiscountAmount ?? 0.0);

        final promoType = targetJob?.promoDiscountType ?? widget.completingOrder!.promoDiscountType ?? globalType;
        
        if (globalValue > 0 && globalType != null && globalType.isNotEmpty) {
          vm.setGlobalDiscount(globalValue, globalType == 'percent');
        }

        final finalPromoCodeName = targetJob?.promoCodeName ?? widget.completingOrder!.promoCodeName;

        if (finalPromoCodeName != null && finalPromoCodeName.isNotEmpty) {
          final promoValue = (targetJob != null && targetJob.promoDiscountValue > 0) 
              ? targetJob.promoDiscountValue 
              : (widget.completingOrder!.promoDiscountValue ?? 0.0);
              
          final pVal = promoValueAmount > 0 
              ? promoValueAmount 
              : (promoValue > 0 ? promoValue : globalValue);
          
          vm.applyPromoCode(finalPromoCodeName, pVal, promoType == 'percent');
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
    final prods = vm.products;
    if (widget.departmentId != null && widget.departmentId != 'All') {
      return prods.where((p) => p.departmentId == widget.departmentId).toList();
    }
    return prods;
  }

  List<String> get _categories {
    final prods = Provider.of<PosViewModel>(context).allProducts;
    Iterable<PosProduct> filtered = prods;
    if (widget.departmentId != null && widget.departmentId != 'All') {
      filtered = filtered.where((p) => p.departmentId == widget.departmentId);
    }
    
    final vm = Provider.of<PosViewModel>(context);
    filtered = filtered.where((p) {
        if (vm.selectedProductType == 'All') return true;
        return vm.selectedProductType == 'Products' ? !p.isService : p.isService;
    });

    final cats = filtered.map((p) => p.category).toSet().toList();
    cats.sort();
    return ['All', ...cats];
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
    final error = context.read<PosViewModel>().addToCart(product);
    if (error != null) {
      ToastService.showError(context, error);
    }
  }

  void _updateQty(PosProduct product, double delta) {
    final error = context.read<PosViewModel>().updateQuantity(product, delta);
    if (error != null) {
      ToastService.showError(context, error);
    }
  }

  void _onCategorySelected(PosViewModel vm, String cat) {
    vm.setCategory(cat);
    context.read<ProductGridViewModel>().setSubCategory('All');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    final vm = Provider.of<PosViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F0),
      appBar: PosScreenAppBar(
        title: widget.isReadOnly ? 'Products' : 'Add Products',
        showBackButton: widget.showBackButton,
        showGlobalLeft: !widget.showBackButton,
      ),
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
                              final categories = _categories.where((c) => c != 'All').toList();
                              return ListView.builder(
                                itemCount: categories.length,
                                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                itemBuilder: (context, index) {
                                  final cat = categories[index];
                                  final isSelected = vm.selectedCategory == cat;
                                  return GestureDetector(
                                    onTap: () => _onCategorySelected(vm, cat),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(vertical: 3),
                                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                                      decoration: BoxDecoration(
                                        color: isSelected ? AppColors.primaryLight : Colors.transparent,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Column(
                                        children: [
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
      bottomNavigationBar: (_currentProducts.isEmpty || widget.isReadOnly)
          ? const SizedBox.shrink()
          : Container(
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
    bool isSavingDraft = false;
    bool isForwarding = false;

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
              height: MediaQuery.of(context).size.height * (isTablet ? 0.85 : 0.80),
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
                  Builder(
                    builder: (context) {
                      final vm = context.read<PosViewModel>();
                      String orderIdText = '#NEW-ORDER';
                      if (widget.completingOrder?.id != null && widget.completingOrder!.id.isNotEmpty) {
                        orderIdText = '#${widget.completingOrder!.id.length > 8 ? widget.completingOrder!.id.substring(0, 8) : widget.completingOrder!.id}';
                      }
                      
                      String custName = widget.completingOrder?.customerName ?? vm.customerName;
                      if (custName.isEmpty) custName = 'Walk-in Customer';
                      
                      String make = widget.completingOrder?.vehicle?.make ?? vm.make;
                      String model = widget.completingOrder?.vehicle?.model ?? vm.model;
                      String plate = widget.completingOrder?.plateNumber ?? vm.vehicleNumber;
                      String vehicleText = [make, model].where((s) => s.isNotEmpty).join(' ');
                      if (plate.isNotEmpty) {
                        vehicleText = vehicleText.isNotEmpty ? '$vehicleText • $plate' : plate;
                      }
                      if (vehicleText.trim().isEmpty || vehicleText == '•') vehicleText = 'No Vehicle Details';

                      String phoneText = widget.completingOrder?.customer?.mobile ?? vm.mobile;
                      if (phoneText.isEmpty) phoneText = 'No Phone';

                      String statusText = widget.completingOrder?.statusText ?? 'Draft';
                      Color statusColor = widget.completingOrder?.statusColor ?? Colors.blue;

                      return Container(
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
                                      orderIdText,
                                      style: TextStyle(fontSize: isTablet ? 16 : 10, fontWeight: FontWeight.w800, color: const Color(0xFF1E2124)),
                                    ),
                                  ),
                                  SizedBox(width: isTablet ? 8 : 6),
                                  Expanded(
                                    child: Text(
                                      custName,
                                      style: TextStyle(fontSize: isTablet ? 22 : 13, fontWeight: FontWeight.w700, color: const Color(0xFF1E2124)),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(statusText, style: TextStyle(color: statusColor, fontSize: isTablet ? 17 : 11, fontWeight: FontWeight.w700)),
                                  ),
                                ],
                              ),
                              SizedBox(height: isTablet ? 12 : 10),
                              Row(
                                children: [
                                  const Icon(Icons.directions_car_outlined, size: 22, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(vehicleText,
                                        style: TextStyle(color: Colors.grey, fontSize: isTablet ? 17 : 10, fontWeight: FontWeight.w500),
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.phone_outlined, size: 22, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(phoneText, style: TextStyle(color: Colors.grey, fontSize: isTablet ? 19 : 12, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }
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
                                    Text('No items added', style: TextStyle(fontSize: 15, color: Colors.grey.shade400)),
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
                  Consumer<PosViewModel>(
                    builder: (context, vm, child) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 14),
                        padding: EdgeInsets.all(isTablet ? 24 : 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Column(
                          children: [
                            _buildTotalRow('Total Amount Gross', 'SAR ${vm.subtotalExclVat.toStringAsFixed(2)}', isTablet),
                            SizedBox(height: isTablet ? 8 : 6),
                            
                            if (vm.totalIndividualDiscount > 0) ...[
                              _buildTotalRow('Item Discounts', '-SAR ${vm.totalIndividualDiscount.toStringAsFixed(2)}', isTablet, color: Colors.green),
                              SizedBox(height: isTablet ? 8 : 6),
                            ],
                            
                            // Editable Global Discount
                            Row(
                              children: [
                                Text('Discount', style: TextStyle(fontSize: isTablet ? 18 : 10, color: Colors.green)),
                                const Spacer(),
                                SizedBox(
                                  width: isTablet ? 80 : 60,
                                  height: isTablet ? 28 : 24,
                                  child: TextFormField(
                                    key: ValueKey('global_disc_${vm.isGlobalDiscountPercent}_${vm.globalDiscount}'),
                                    initialValue: vm.globalDiscount > 0
                                        ? (vm.globalDiscount % 1 == 0
                                            ? vm.globalDiscount.toInt().toString()
                                            : vm.globalDiscount.toString())
                                        : '',
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    inputFormatters: [EnglishNumberFormatter()],
                                    onChanged: (val) {
                                      final discount = double.tryParse(val) ?? 0.0;
                                      context.read<PosViewModel>().setGlobalDiscount(discount, vm.isGlobalDiscountPercent);
                                    },
                                    style: TextStyle(fontSize: isTablet ? 14 : 11, color: Colors.green),
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.zero,
                                      hintText: '0',
                                      hintStyle: const TextStyle(color: Colors.green),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Colors.green)),
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () {
                                    context.read<PosViewModel>().setGlobalDiscount(vm.globalDiscount, !vm.isGlobalDiscountPercent);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: isTablet ? 8 : 6, vertical: isTablet ? 4 : 3),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      vm.isGlobalDiscountPercent ? '%' : 'SAR',
                                      style: TextStyle(fontSize: isTablet ? 12 : 9, fontWeight: FontWeight.w700, color: Colors.green),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isTablet ? 8 : 6),
                            
                            _buildTotalRow('Price after discount', 'SAR ${(vm.subtotalExclVat - (vm.totalIndividualDiscount + vm.totalGlobalDiscount)).toStringAsFixed(2)}', isTablet),
                            SizedBox(height: isTablet ? 10 : 8),
                            
                            if (vm.totalPromoDiscount > 0) ...[
                              _buildTotalRow('Promo Discount', '-SAR ${vm.totalPromoDiscount.toStringAsFixed(2)}', isTablet, color: Colors.green),
                              SizedBox(height: isTablet ? 10 : 8),
                              _buildTotalRow('Price after promo', 'SAR ${(vm.subtotalExclVat - (vm.totalIndividualDiscount + vm.totalGlobalDiscount + vm.totalPromoDiscount)).toStringAsFixed(2)}', isTablet),
                              SizedBox(height: isTablet ? 10 : 8),
                            ],

                            Divider(height: 1, color: Colors.grey.shade200),
                            SizedBox(height: isTablet ? 10 : 8),
                            
                            _buildTotalRow('Tax (15%)', 'SAR ${vm.totalTax.toStringAsFixed(2)}', isTablet, color: Colors.grey),
                            SizedBox(height: isTablet ? 10 : 8),
                            
                            Row(
                              children: [
                                Text('Total amount', style: TextStyle(fontWeight: FontWeight.w800, fontSize: isTablet ? 24 : 14, color: const Color(0xFF1E2124))),
                                const Spacer(),
                                Text('SAR ${vm.totalAmount.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: isTablet ? 24 : 14, color: const Color(0xFF1E2124))),
                              ],
                            ),
                          ],
                        ),
                      );
                    }
                  ),

                  SizedBox(height: isTablet ? 10 : 8),

                  // ── Promo Code ──
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 14),
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => const PromoCodeDialog(),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Consumer<PosViewModel>(
                          builder: (context, vm, child) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (vm.activePromoCode.isNotEmpty)
                                  SizedBox(width: isTablet ? 36 : 28), // Balance the row
                                
                                Icon(Icons.local_offer_outlined, size: isTablet ? 24 : 16, color: const Color(0xFFFFC145)),
                                SizedBox(width: isTablet ? 10 : 8),
                                Text(
                                  vm.activePromoCode.isEmpty ? 'Add Promo Code' : 'Promo: ${vm.activePromoCode}',
                                  style: TextStyle(
                                    fontSize: isTablet ? 17 : 12,
                                    fontWeight: FontWeight.w600,
                                    color: vm.activePromoCode.isEmpty ? const Color(0xFF1E2124) : Colors.green,
                                  ),
                                ),
                                
                                if (vm.activePromoCode.isNotEmpty) ...[
                                  SizedBox(width: isTablet ? 10 : 8),
                                  GestureDetector(
                                    onTap: () {
                                      vm.clearPromoCode();
                                    },
                                    child: const Icon(Icons.close_rounded, size: 18, color: Colors.red),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: isTablet ? 10 : 8),

                  // ── Action Buttons ──
                  Padding(
                    padding: EdgeInsets.fromLTRB(isTablet ? 32 : 14, 0, isTablet ? 32 : 14, MediaQuery.of(context).padding.bottom + 20),
                    child: widget.completingOrderId != null
                        ? SizedBox(
                            width: double.infinity,
                            height: isTablet ? 60 : 48,
                            child: Consumer<PosViewModel>(
                              builder: (context, vm, child) {
                                return ElevatedButton(
                                  onPressed: vm.isLoading
                                      ? null
                                      : () async {
                                          String jobId = widget.completingOrderId!;
                                          if (widget.completingOrder != null && widget.completingOrder!.jobs.isNotEmpty) {
                                            jobId = widget.completingOrder!.latestJob!.id;
                                          }
                                          final response = await vm.completeCashierJob(jobId);
                                          if (response != null && response.success && context.mounted) {
                                            vm.setShellSelectedIndex(2); // Orders Tab
                                            vm.fetchOrders();
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(builder: (_) => const PosShell(initialIndex: 2)),
                                              (route) => false,
                                            );
                                            ToastService.showSuccess(context, 'Order marked as completed successfully');
                                          } else {
                                            if (context.mounted) {
                                              ToastService.showError(context, response?.message ?? 'Failed to complete job');
                                            }
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryLight,
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
                                      : Text(
                                          'Mark as Complete',
                                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: isTablet ? 18 : 15),
                                        ),
                                );
                              },
                            ),
                          )
                        : Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: isTablet ? 60 : 44,
                                      child: Consumer<PosViewModel>(
                                        builder: (context, vm, child) {
                                          return ElevatedButton(
                                            onPressed: vm.isLoading || isForwarding || isSavingDraft
                                                ? null
                                                : () async {
                                                    setSheetState(() => isSavingDraft = true);
                                                    String finalDeptId = '1';
                                                    if (widget.departmentId != null) {
                                                      finalDeptId = widget.departmentId!;
                                                    } else {
                                                      if (_currentProducts.isNotEmpty) {
                                                        finalDeptId = _currentProducts.first.departmentId ?? '1';
                                                      } else if (vm.products.isNotEmpty) {
                                                        finalDeptId = vm.products.first.departmentId ?? '1';
                                                      }
                                                    }
                                                    final success = await vm.submitWalkInOrder([finalDeptId], context);
                                                    if (success && context.mounted) {
                                                      vm.setShellSelectedIndex(2);
                                                      vm.fetchOrders();
                                                      Navigator.pushAndRemoveUntil(
                                                        context,
                                                        MaterialPageRoute(builder: (_) => const PosShell(initialIndex: 2)),
                                                        (route) => false,
                                                      );
                                                    }
                                                    if (mounted) {
                                                      setSheetState(() => isSavingDraft = false);
                                                    }
                                                  },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.secondaryLight,
                                              foregroundColor: Colors.white,
                                              disabledBackgroundColor: AppColors.secondaryLight.withOpacity(0.7),
                                              disabledForegroundColor: Colors.white,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            child: isSavingDraft
                                                ? const SizedBox(
                                                    height: 18,
                                                    width: 18,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                : Text(
                                                    'Save Draft',
                                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: isTablet ? 16 : 11),
                                                  ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: isTablet ? 8 : 6),
                                  Expanded(
                                    child: SizedBox(
                                      height: isTablet ? 60 : 44,
                                      child: Consumer<PosViewModel>(
                                        builder: (context, vm, child) {
                                          return ElevatedButton(
                                            onPressed: vm.isLoading || isForwarding || isSavingDraft
                                                ? null
                                                : () async {
                                                    setSheetState(() => isForwarding = true);
                                                    String finalDeptId = '1'; // Default fallback
                                                    if (widget.departmentId != null) {
                                                      finalDeptId = widget.departmentId!;
                                                  } else {
                                                      if (_currentProducts.isNotEmpty) {
                                                        finalDeptId = _currentProducts.first.departmentId ?? '1';
                                                      } else if (vm.products.isNotEmpty) {
                                                        finalDeptId = vm.products.first.departmentId ?? '1';
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
                                                    if (mounted) {
                                                      setSheetState(() => isForwarding = false);
                                                    }
                                                  },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFFFFC145),
                                              foregroundColor: const Color(0xFF1E2124),
                                              disabledBackgroundColor: const Color(0xFFFFC145).withOpacity(0.7),
                                              disabledForegroundColor: const Color(0xFF1E2124).withOpacity(0.7),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            child: isForwarding
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
        final vm = Provider.of<PosViewModel>(context);
        return Column(
          children: [
          // Top Controls: Search & Categories
          if (vm.allProducts.isNotEmpty) ...[
            // Search Bar
            Padding(
              padding: EdgeInsets.fromLTRB(isTablet ? 20 : 12, isTablet ? 16 : 12, isTablet ? 20 : 12, 0),
              child: PosSearchBar(
                controller: gridVm.searchController,
                onChanged: (v) => gridVm.setSearchQuery(v),
                hintText: 'Search products & services...',
              ),
            ),

            // Product vs Services Tabs
            Padding(
              padding: EdgeInsets.fromLTRB(isTablet ? 20 : 12, 16, isTablet ? 20 : 12, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          vm.setProductType('All');
                          gridVm.setSubCategory('All');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: vm.selectedProductType == 'All' ? AppColors.secondaryLight : Colors.transparent,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'All',
                            style: TextStyle(
                              color: vm.selectedProductType == 'All' ? Colors.white : Colors.grey.shade600,
                              fontWeight: vm.selectedProductType == 'All' ? FontWeight.w800 : FontWeight.w600,
                              fontSize: isTablet ? 15 : 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          vm.setProductType('Products');
                          gridVm.setSubCategory('All');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: vm.selectedProductType == 'Products' ? AppColors.secondaryLight : Colors.transparent,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Products',
                            style: TextStyle(
                              color: vm.selectedProductType == 'Products' ? Colors.white : Colors.grey.shade600,
                              fontWeight: vm.selectedProductType == 'Products' ? FontWeight.w800 : FontWeight.w600,
                              fontSize: isTablet ? 15 : 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          vm.setProductType('Services');
                          gridVm.setSubCategory('All');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: vm.selectedProductType == 'Services' ? AppColors.secondaryLight : Colors.transparent,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Services',
                            style: TextStyle(
                              color: vm.selectedProductType == 'Services' ? Colors.white : Colors.grey.shade600,
                              fontWeight: vm.selectedProductType == 'Services' ? FontWeight.w800 : FontWeight.w600,
                              fontSize: isTablet ? 15 : 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Mobile category strip natively removed following request.

          // SubCategory Chips
          Consumer<PosViewModel>(
            builder: (context, vm, child) {
              // Get unique subcategories globally for the selected product type unless actively constrained by tablet UI
              List<PosProduct> sourceProducts;
              if (vm.selectedCategory != 'All' && isTablet) {
                sourceProducts = _currentProducts.where((p) => p.category == vm.selectedCategory).toList();
              } else if (vm.selectedProductType != 'All') {
                final isService = vm.selectedProductType == 'Services';
                sourceProducts = _currentProducts.where((p) => p.isServiceType == isService).toList();
              } else {
                sourceProducts = _currentProducts.toList();
              }
              
              Set<String> subCatsSet = {};
              for (var cat in vm.apiCategories) {
                 if (vm.selectedCategory != 'All' && isTablet && cat.name != vm.selectedCategory) continue;
                 // Add all mapped subcategories from API
                 for (var sub in cat.subCategories) {
                    if (sub.name.isNotEmpty) subCatsSet.add(sub.name);
                 }
              }

              // Also ensure we include any distinct subcategories derived directly from the current products list
              for (var p in sourceProducts) {
                final subName = p.subCategoryName?.isNotEmpty == true ? p.subCategoryName! : 'Others';
                subCatsSet.add(subName);
              }

              final subCats = subCatsSet.toList()..sort();
              
              if (subCats.isEmpty) {
                // Return empty only if no subcategories or products exist at all
                return const SizedBox.shrink();
              }

              final displaySubCats = ['All', ...subCats];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: isTablet ? 16 : 8),
                  SizedBox(
                    height: isTablet ? 44 : 32,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 12),
                      itemCount: displaySubCats.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final subCat = displaySubCats[index];
                        final isSelected = gridVm.selectedSubCategory == subCat;
                        return GestureDetector(
                          onTap: () => gridVm.setSubCategory(subCat),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 12, vertical: isTablet ? 8 : 6),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryLight : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? AppColors.primaryLight : Colors.grey.shade300,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                subCat,
                                style: TextStyle(
                                  fontSize: isTablet ? 15 : 11,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? AppColors.secondaryLight : Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          ),

          SizedBox(height: isTablet ? 12 : 8),
        ],

        // Products Grid
        Expanded(
          child: _currentProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text(vm.selectedProductType == 'Services' ? 'No services found' : 'No products found', style: TextStyle(color: Colors.grey.shade400, fontSize: isTablet ? 16 : 14)),
                    ],
                  ),
                )
              : Builder(
                  builder: (context) {
                    // Filter products
                    final filteredProducts = _currentProducts.where((product) {
                      final matchesCategory = gridVm.selectedCategory == 'All' || product.category == gridVm.selectedCategory;
                      
                      final subCatName = product.subCategoryName?.isNotEmpty == true ? product.subCategoryName! : 'Others';
                      final matchesSubCategory = gridVm.selectedSubCategory == 'All' || subCatName == gridVm.selectedSubCategory;

                      final matchesSearch = gridVm.searchQuery.isEmpty || product.name.toLowerCase().contains(gridVm.searchQuery.toLowerCase());
                      
                      return matchesCategory && matchesSubCategory && matchesSearch;
                    }).toList();

                    if (filteredProducts.isEmpty) {
                      return Center(
                        child: Text(
                          'No products match your search.',
                          style: TextStyle(color: Colors.grey.shade400, fontSize: isTablet ? 16 : 14),
                        ),
                      );
                    }

                    if (isTablet) {
                      return GridView.builder(
                        padding: EdgeInsets.fromLTRB(isTablet ? 20 : 12, 0, isTablet ? 20 : 12, 16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isTablet ? 3 : 2,
                          childAspectRatio: isTablet ? 1.4 : 1.25,
                          crossAxisSpacing: isTablet ? 14 : 10,
                          mainAxisSpacing: isTablet ? 14 : 10,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return Consumer<PosViewModel>(
                            builder: (context, vm, child) {
                              final cartItemIndex = vm.cartItems.indexWhere((i) => i.product.id == product.id);
                              final qty = cartItemIndex != -1 ? vm.cartItems[cartItemIndex].quantity : 0.0;
                              return _buildProductCard(product, qty, isTablet);
                            },
                          );
                        },
                      );
                    } else {
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: filteredProducts.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return Consumer<PosViewModel>(
                            builder: (context, vm, child) {
                              final cartItemIndex = vm.cartItems.indexWhere((i) => i.product.id == product.id);
                              final qty = cartItemIndex != -1 ? vm.cartItems[cartItemIndex].quantity : 0.0;
                              return _buildProductCard(product, qty, isTablet);
                            },
                          );
                        },
                      );
                    }
                  },
                ),
        ),
      ],
    );
      },
    );
  }

  Widget _buildProductCard(PosProduct product, double cartQty, bool isTablet) {

    if (!isTablet) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: widget.isReadOnly ? null : () => _addToCart(product),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: (cartQty > 0 && !widget.isReadOnly)
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
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (product.unit != null && product.unit!.isNotEmpty) ...[
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
                        const SizedBox(height: 4),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: product.stockColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product.stockLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: product.stockColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'SAR ${product.allowDecimalQty ? product.price.toStringAsFixed(2) : product.price.toInt()}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppColors.secondaryLight,
                      ),
                    ),
                    if (!widget.isReadOnly) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildQtyButton(Icons.remove, isTablet, onTap: cartQty > 0
                              ? () => _updateQty(product, -1)
                              : null),
                          GestureDetector(
                            onTap: () => _showQtyDialog(product, isTablet),
                            child: Container(
                              height: 28,
                              width: 32,
                              alignment: Alignment.center,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Text(
                                (!product.allowDecimalQty || cartQty % 1 == 0) ? '${cartQty.toInt()}' : cartQty.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
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
      if (cartQty > 0 && !widget.isReadOnly)
        Positioned(
          top: -10,
          right: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.secondaryLight),
            ),
          ),
        ),
        ],
      );
    }
    
    // Tablet View (Grid Item)
    return Stack(
      children: [
        GestureDetector(
          onTap: widget.isReadOnly ? null : () => _addToCart(product),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: (cartQty > 0 && !widget.isReadOnly)
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
              padding: const EdgeInsets.all(14),
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
                            fontSize: 15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  if (product.unit != null && product.unit!.isNotEmpty) ...[
                    Text(
                      'Unit: ${product.unit}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                  ],

                  // Stock indicators
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: product.stockColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      product.stockLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: product.stockColor,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Price
                  Text(
                    'SAR ${product.allowDecimalQty ? product.price.toStringAsFixed(2) : product.price.toInt()}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      color: AppColors.secondaryLight,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // +/- Controls
                  if (!widget.isReadOnly)
                    Row(
                      children: [
                        _buildQtyButton(Icons.remove, true, onTap: cartQty > 0
                            ? () => _updateQty(product, -1)
                            : null),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _showQtyDialog(product, true),
                            child: Container(
                              height: 32,
                              alignment: Alignment.center,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Text(
                                (!product.allowDecimalQty || cartQty % 1 == 0) ? '${cartQty.toInt()}' : cartQty.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        _buildQtyButton(Icons.add, true, onTap: () => _addToCart(product)),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
        if (cartQty > 0 && !widget.isReadOnly)
          Positioned(
            top: -12,
            right: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
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
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.secondaryLight),
              ),
            ),
          ),
      ],
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
                        style: TextStyle(fontSize: isTablet ? 18 : 14, fontWeight: FontWeight.w700, color: const Color(0xFF1E2124)),
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
                            style: TextStyle(fontSize: isTablet ? 14 : 11, fontWeight: FontWeight.w600, color: Colors.grey),
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
                    'SAR ${item.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: isTablet ? 18 : 14, fontWeight: FontWeight.w800, color: const Color(0xFF1E2124)),
                  ),
                  if (item.actualDiscountAmount > 0)
                    Text(
                      '-SAR ${item.actualDiscountAmount.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: isTablet ? 13 : 11, fontWeight: FontWeight.w600, color: Colors.green),
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
              Text('Dis.', style: TextStyle(fontSize: isTablet ? 13 : 11, color: Colors.grey)),
              const SizedBox(width: 8),
              SizedBox(
                width: isTablet ? 60 : 50,
                height: isTablet ? 26 : 24,
                child: TextFormField(
                  key: ValueKey('ind_disc_${item.product.id}_${item.isDiscountPercent}'),
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
                    style: TextStyle(fontSize: isTablet ? 14 : 11, fontWeight: FontWeight.w700, color: const Color(0xFF1E2124)),
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
      text: (!product.allowDecimalQty || currentQty % 1 == 0) ? currentQty.toInt().toString() : currentQty.toString(),
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
              keyboardType: TextInputType.numberWithOptions(decimal: product.allowDecimalQty),
              inputFormatters: [
                if (!product.allowDecimalQty) FilteringTextInputFormatter.digitsOnly,
                if (product.allowDecimalQty) EnglishNumberFormatter(),
              ],
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
              final error = context.read<PosViewModel>().setSpecificQuantity(product, qty);
              if (error != null) {
                ToastService.showError(context, error);
              } else {
                Navigator.pop(ctx);
              }
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
