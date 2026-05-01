import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../utils/toast_service.dart';
import '../../../models/pos_product_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/app_formatters.dart';
import '../../../utils/pos_tablet_layout.dart';
import '../../../widgets/pos_widgets.dart';
import '../../../widgets/pos_shell_rail_layout.dart';

import '../../../data/repositories/pos_repository.dart';
import '../../../services/session_service.dart';
import '../Home Screen/pos_view_model.dart';
import '../Navbar/pos_shell.dart';
import '../Promo/promo_code_dialog.dart';
import '../../../models/pos_order_model.dart';
import '../Technician Assignment/pos_technician_assignment_view.dart';
import '../Department/department_view_model.dart';
import '../Department/pos_department_view.dart';
import 'product_grid_view_model.dart';

/// Same typography as order list empty state ([PosOrdersView] `_OrdersEmptyStateBody`).
TextStyle _posCatalogEmptyMessageTextStyle() => TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w700,
      color: Colors.grey.shade500,
      height: 1.35,
    );

class PosProductGridView extends StatefulWidget {
  final String? departmentName;
  final String? departmentId;
  final List<String>? selectedDepartmentIds;
  final List<String>? selectedDepartmentNames;
  final List<dynamic>? preSelectedItems;
  final String? completingOrderId;
  final PosOrder? completingOrder;
  final bool isReadOnly;
  final bool showBackButton;
  final bool isMainTab;

  const PosProductGridView({
    super.key,
    this.departmentName,
    this.departmentId,
    this.selectedDepartmentIds,
    this.selectedDepartmentNames,
    this.preSelectedItems,
    this.completingOrderId,
    this.completingOrder,
    this.isReadOnly = false,
    this.showBackButton = true,
    this.isMainTab = false,
  });

  @override
  State<PosProductGridView> createState() => _PosProductGridViewState();
}

class _PosProductGridViewState extends State<PosProductGridView> {
  // All state moved to ProductGridViewModel and PosViewModel
  String? _activeDepartmentTabId;
  late final bool _isDepartmentSelectionMode;
  late List<String> _departmentIds;

  /// Cached for [dispose] — do not call [context.read] after the element is deactivated.
  PosViewModel? _posVmRef;

  List<String> _resolveInitialDepartmentIds() {
    final ids = (widget.selectedDepartmentIds ?? const [])
        .where((e) => e.trim().isNotEmpty)
        .toList();
    if (ids.isNotEmpty) return ids;
    if (widget.departmentId != null && widget.departmentId!.trim().isNotEmpty) {
      return [widget.departmentId!];
    }
    return const [];
  }

  List<String> get _selectedDepartmentIds => _departmentIds;

  Map<String, String> get _selectedDepartmentNameById {
    final map = <String, String>{};
    final ids = widget.selectedDepartmentIds ?? const <String>[];
    final names = widget.selectedDepartmentNames ?? const <String>[];
    final count = ids.length < names.length ? ids.length : names.length;
    for (var i = 0; i < count; i++) {
      final id = ids[i];
      if (id.trim().isEmpty) continue;
      map[id] = names[i];
    }
    if (widget.departmentId != null &&
        widget.departmentId!.trim().isNotEmpty &&
        widget.departmentName != null &&
        widget.departmentName!.trim().isNotEmpty) {
      map.putIfAbsent(widget.departmentId!, () => widget.departmentName!);
    }
    return map;
  }

  bool get _hasMultiSelectedDepartments => _selectedDepartmentIds.length > 1;
  Future<bool> _confirmBackNavigation() async {
    return true;
  }

  List<JobTechnician> _initialAssignedForWalkInTechnicianScreen() {
    final o = widget.completingOrder;
    final jid = widget.completingOrderId?.trim();
    if (o == null || jid == null || jid.isEmpty) return const [];
    for (final j in o.jobs) {
      if (j.id == jid) return j.distinctActiveTechnicians;
    }
    return const [];
  }

  void _openTechniciansPage() {
    final vm = context.read<PosViewModel>();

    String deptId = widget.departmentId?.trim() ?? '';
    String? deptName = widget.departmentName;
    if (deptId.isEmpty) {
      final cart = widget.isMainTab ? vm.mainTabCartItems : vm.cartItems;
      if (cart.isNotEmpty) {
        final p = cart.first.product;
        deptId = (p.departmentId ?? '').trim();
        final dn = (p.departmentName ?? '').trim();
        if (dn.isNotEmpty) deptName = dn;
      }
      if (deptId.isEmpty && vm.products.isNotEmpty) {
        final p = vm.products.first;
        deptId = (p.departmentId ?? '').trim();
        if ((deptName ?? '').trim().isEmpty) {
          final dn = (p.departmentName ?? '').trim();
          if (dn.isNotEmpty) deptName = dn;
        }
      }
      if (deptId.isEmpty) deptId = '1';
    }

    String jobId = '';
    List<JobTechnician> initial = const [];
    bool isWalkIn = true;

    final completingId = widget.completingOrderId?.trim();
    final completingOrder = widget.completingOrder;
    if (completingOrder != null &&
        completingId != null &&
        completingId.isNotEmpty) {
      PosOrderJob? job;
      for (final j in completingOrder.jobs) {
        if (j.id == completingId) {
          job = j;
          break;
        }
      }
      if (job != null && job.id.trim().isNotEmpty) {
        jobId = job.id.trim();
        initial = job.distinctActiveTechnicians;
        isWalkIn = false;
      } else {
        initial = _initialAssignedForWalkInTechnicianScreen();
      }
    } else {
      final placed = vm.jobIdForPlacedDepartment(deptId);
      if (placed != null && placed.trim().isNotEmpty) {
        jobId = placed.trim();
        isWalkIn = false;
        final sel = vm.selectedOrder;
        if (sel != null) {
          for (final j in sel.jobs) {
            if (j.id == jobId) {
              initial = j.distinctActiveTechnicians;
              break;
            }
          }
        }
      } else {
        final cur = vm.currentJobId?.trim() ?? '';
        if (cur.isNotEmpty) {
          jobId = cur;
          isWalkIn = false;
          final sel = vm.selectedOrder;
          if (sel != null) {
            for (final j in sel.jobs) {
              if (j.id == jobId) {
                initial = j.distinctActiveTechnicians;
                break;
              }
            }
          }
        }
      }
    }

    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => PosTechnicianAssignmentView(
          jobId: jobId,
          departmentName: deptName,
          departmentId: deptId,
          isWalkIn: isWalkIn,
          initialAssignedTechnicians: initial,
        ),
      ),
    );
  }

  Widget _buildAddTechnicianButton(bool isTablet) {
    final child = Material(
      color: AppColors.primaryLight,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _openTechniciansPage,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 12 : 8,
            vertical: isTablet ? 10 : 9,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_add_alt_1_rounded,
                color: AppColors.onPrimaryLight,
                size: isTablet ? 18 : 16,
              ),
              if (isTablet) ...[
                const SizedBox(width: 6),
                Text(
                  'Add Technician',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.onPrimaryLight,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
    if (isTablet) return child;
    return Tooltip(message: 'Add Technician', child: child);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _posVmRef = context.read<PosViewModel>();
  }

  @override
  void initState() {
    super.initState();
    _isDepartmentSelectionMode =
        (widget.selectedDepartmentIds?.isNotEmpty ?? false);
    _departmentIds = List<String>.from(_resolveInitialDepartmentIds());
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<PosViewModel>();
      vm.setPromoContextDepartment(
        _isDepartmentSelectionMode ? _activeDepartmentTabId : null,
        isMainTab: widget.isMainTab,
      );
      
      // Reset product type filters so returning to grid shows all items by default
      vm.setProductType('All');
      final gridVm = context.read<ProductGridViewModel>();
      gridVm.setSubCategory('All');
      
      // Set the department from widget parameter if provided
      if (widget.departmentName != null && widget.departmentName != 'All') {
        gridVm.setDepartment(widget.departmentName!);
      }

      if (_isDepartmentSelectionMode && _selectedDepartmentIds.isNotEmpty) {
        final d = _selectedDepartmentIds.first.trim();
        _activeDepartmentTabId = d;
        vm.setPromoContextDepartment(
          _activeDepartmentTabId,
          isMainTab: widget.isMainTab,
        );
        final skipFetch =
            vm.lastFetchedDepartmentId?.trim() == d && vm.allProducts.isNotEmpty;
        if (!skipFetch) {
          await vm.fetchProducts(departmentId: d);
        }
      } else if (widget.showBackButton && widget.departmentId != null && widget.departmentId != 'All') {
        final d = widget.departmentId!.trim();
        _activeDepartmentTabId = widget.departmentId;
        vm.setPromoContextDepartment(
          _activeDepartmentTabId,
          isMainTab: widget.isMainTab,
        );
        final skipFetch =
            vm.lastFetchedDepartmentId?.trim() == d && vm.allProducts.isNotEmpty;
        if (!skipFetch) {
          await vm.fetchProducts(departmentId: widget.departmentId);
        }
      } else if (widget.showBackButton && vm.allProducts.isEmpty) {
        _activeDepartmentTabId = null;
        vm.setPromoContextDepartment(null, isMainTab: widget.isMainTab);
        await vm.fetchProducts();
      }

      // Always default to 'All' category when opening the grid to show all available options
      _onCategorySelected(vm, 'All');
      
      if (!widget.isMainTab && widget.preSelectedItems != null && widget.preSelectedItems!.isNotEmpty) {
        // Clear cart first so we don't duplicate when repeatedly entering the screen
        vm.clearCart(isMainTab: false); 

        final allProducts = vm.allProducts; // Use unfiltered list to guarantee both products and services are found
        for (final item in widget.preSelectedItems!) {
          try
          {
            final productId = item['productId']?.toString();
            final serviceId = item['serviceId']?.toString();
            final fallbackId = item['id']?.toString();
            final lookupId = productId ?? serviceId ?? fallbackId;
            final qtyRaw = item['quantity'] ?? item['qty'] ?? 1;
            final double qty = (qtyRaw is num) ? qtyRaw.toDouble() : double.tryParse(qtyRaw.toString()) ?? 1.0;

            if (lookupId != null && lookupId.isNotEmpty) {
              final bool? mustBeService = serviceId != null && serviceId.isNotEmpty
                  ? true
                  : (productId != null && productId.isNotEmpty ? false : null);

              final product = allProducts.firstWhere((p) {
                final idMatches = p.id == lookupId;
                if (!idMatches) return false;
                if (mustBeService == null) return true;
                return p.isServiceType == mustBeService;
              });
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

              final upRaw = item['unitPrice'];
              if (product.isService &&
                  product.isPriceEditable &&
                  upRaw != null) {
                final u = (upRaw is num)
                    ? upRaw.toDouble()
                    : double.tryParse(upRaw.toString());
                if (u != null && u > 0) {
                  vm.setServiceUnitPrice(product, u, isMainTab: false);
                }
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
            : 0.0;
        final finalPromoCodeId = targetJob?.promoCodeId;

        final promoType = targetJob?.promoDiscountType ?? globalType;
        
        if (globalValue > 0 && globalType != null && globalType.isNotEmpty) {
          vm.setGlobalDiscount(globalValue, globalType == 'percent');
        }

        final finalPromoCodeName = targetJob?.promoCodeName;
        final promoValue = (targetJob != null && targetJob.promoDiscountValue > 0)
            ? targetJob.promoDiscountValue
            : promoValueAmount;
        final hasValidPromo =
            finalPromoCodeName != null &&
            finalPromoCodeName.isNotEmpty &&
            finalPromoCodeId != null &&
            finalPromoCodeId.trim().isNotEmpty &&
            promoValue > 0;

        if (hasValidPromo) {
          vm.applyPromoCode(
            finalPromoCodeName,
            promoValue,
            promoType == 'percent',
            promoCodeId: finalPromoCodeId,
          );
        } else {
          // Prevent stale promo from a previously edited/completed job.
          vm.clearPromoCode();
        }
      }

      vm.refreshGlobalDiscountFieldText(widget.isMainTab);
    });
  }

  @override
  void dispose() {
    _posVmRef?.setPromoContextDepartment(
      null,
      isMainTab: widget.isMainTab,
    );
    super.dispose();
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

  double get _subtotal => Provider.of<PosViewModel>(context).getSubtotalExclVat(widget.isMainTab);
  double get _totalVat => Provider.of<PosViewModel>(context).getTotalTaxValue(widget.isMainTab);

  double get _discountAmount {
    final vm = Provider.of<PosViewModel>(context);
    return vm.getTotalIndividualDiscount(widget.isMainTab) + vm.getTotalGlobalDiscountValue(widget.isMainTab);
  }

  double get _grandTotal {
    final vm = Provider.of<PosViewModel>(context);
    return vm.getTotalAmountValue(widget.isMainTab);
  }

  void _addToCart(PosProduct product) {
    final error = context.read<PosViewModel>().addToCart(product, isMainTab: widget.isMainTab);
    if (error != null) {
      ToastService.showError(context, error);
    }
  }

  void _updateQty(PosProduct product, double delta) {
    final error = context.read<PosViewModel>().updateQuantity(product, delta, isMainTab: widget.isMainTab);
    if (error != null) {
      ToastService.showError(context, error);
    }
  }

  /// + button / card tap: block out-of-stock products and service already at qty 1.
  bool _canIncrementProduct(PosProduct product, double cartQty) {
    if (widget.isReadOnly) return false;
    if (!product.isService && product.stock <= 0) return false;
    if (product.isService && cartQty >= 1) return false;
    if (!product.isService && cartQty >= product.stock) return false;
    return true;
  }

  void _onCategorySelected(PosViewModel vm, String cat) {
    vm.setCategory(cat);
    context.read<ProductGridViewModel>().setSubCategory('All');
  }

  List<String> _resolveDepartmentIdsForSave(PosViewModel vm) {
    final fromWidget = (widget.selectedDepartmentIds ?? const <String>[])
        .where((e) => e.trim().isNotEmpty)
        .toList();
    if (fromWidget.isNotEmpty) return fromWidget;
    final single = widget.departmentId?.trim() ?? '';
    if (single.isNotEmpty && single != 'All') return [single];
    final seen = <String>{};
    for (final i in vm.cartItems) {
      final d = i.product.departmentId;
      if (d != null && d.isNotEmpty) seen.add(d);
    }
    if (seen.isNotEmpty) return seen.toList();
    if (_currentProducts.isNotEmpty) {
      final d = _currentProducts.first.departmentId;
      if (d != null && d.isNotEmpty) return [d];
    }
    if (vm.products.isNotEmpty) {
      final d = vm.products.first.departmentId;
      if (d != null && d.isNotEmpty) return [d];
    }
    return const ['1'];
  }

  Future<void> _saveInvoiceFromPanel(BuildContext context) async {
    final vm = context.read<PosViewModel>();
    if (vm.isLoading || vm.isInvoicePanelSaveBusy) return;
    if (widget.isMainTab || widget.isReadOnly) return;

    final deptIds = _resolveDepartmentIdsForSave(vm);
    final isEdit = vm.editingOrder != null &&
        vm.editingCompletingOrderId != null &&
        vm.editingCompletingOrderId!.trim().isNotEmpty;

    if (isEdit) {
      await vm.submitEditOrder(
        deptIds,
        context,
        forInvoicePanelSave: true,
      );
      if (!context.mounted) return;
    } else {
      final keepDraftContext = vm.corporateAccountId != null &&
          (vm.walkInDraftOrderId?.trim().isNotEmpty ?? false);
      final ok = await vm.submitWalkInOrder(
        deptIds,
        context,
        clearCustomerOnSuccess: !keepDraftContext,
        forInvoicePanelSave: true,
      );
      if (!context.mounted) return;
      if (ok) {
        // Stay on this screen — do not switch shell to Orders or replace the route stack.
        await vm.fetchOrders(silent: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    final vm = context.watch<PosViewModel>();
    final catalogLoading = vm.isLoading && !vm.isInvoicePanelSaveBusy;

    return WillPopScope(
      onWillPop: _confirmBackNavigation,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: PosTabletLayout.textScaler(context),
        ),
        child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFFF5F3F0),
        appBar: PosScreenAppBar(
          title: (widget.departmentName != null &&
                  widget.departmentName!.trim().isNotEmpty &&
                  widget.departmentName!.trim().toLowerCase() != 'all')
              ? widget.departmentName!
              : 'Inventory',
          showBackButton: widget.showBackButton,
          showGlobalLeft: false,
          showHamburger: !widget.showBackButton,
          onBack: () async {
            final canPop = await _confirmBackNavigation();
            if (canPop && mounted) Navigator.pop(context);
          },
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: wrapPosShellRailBody(
                context,
                isTablet
                    ? _buildTabletSplitLayout(vm)
                    : _buildProductSection(false),
              ),
            ),
            if (vm.isLoading && !vm.isInvoicePanelSaveBusy)
              Positioned.fill(
                child: Container(
                  color: Colors.white,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryLight,
                    ),
                  ),
                ),
              ),
          ],
        ),
        // ─── Bottom Bar (Cart Summary) ───
        bottomNavigationBar: (isTablet || vm.getCartCount(widget.isMainTab) == 0 || widget.isReadOnly)
            ? const SizedBox.shrink()
            : Container(
              padding: EdgeInsets.fromLTRB(isTablet ? 18 : 16, 12, isTablet ? 18 : 16, MediaQuery.of(context).padding.bottom + 12),
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: isTablet ? 20 : 17, color: const Color(0xFF1E2124)),
                        const SizedBox(width: 8),
                        Text(
                          '${context.watch<PosViewModel>().getCartCount(widget.isMainTab)} items',
                          style: TextStyle(fontSize: isTablet ? 14 : 12, fontWeight: FontWeight.w700, color: const Color(0xFF1E2124)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: isTablet ? 12 : 10),
                  // Grand total
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Grand Total', style: TextStyle(fontSize: isTablet ? 12 : 10, color: Colors.grey, fontWeight: FontWeight.w500)),
                        Text(
                          'SAR ${context.watch<PosViewModel>().getTotalAmountValue(widget.isMainTab).toStringAsFixed(2)}',
                          style: TextStyle(fontSize: isTablet ? 19 : 18, fontWeight: FontWeight.w800, color: const Color(0xFF1E2124)),
                        ),
                      ],
                    ),
                  ),
                  // View Invoice button
                  SizedBox(
                    height: isTablet ? 48 : 46,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final isLandscape =
                            MediaQuery.of(context).orientation ==
                            Orientation.landscape;
                        // Landscape tablets use compact sheet typography so order list stays visible.
                        final useTabletSizing = isTablet && !isLandscape;
                        _showInvoiceBottomSheet(context, useTabletSizing);
                      },
                      icon: Icon(Icons.receipt_long_outlined, size: isTablet ? 20 : 18),
                      label: Text('View Invoice', style: TextStyle(fontWeight: FontWeight.w700, fontSize: isTablet ? 14 : 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC145),
                        foregroundColor: const Color(0xFF1E2124),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: isTablet ? 18 : 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      ),
      ),
    );
  }

  Widget _buildTabletSplitLayout(PosViewModel vm) {
    // Row intrinsic height ignores Expanded children; without an explicit height the
    // row stays short and the invoice column leaves empty space at the bottom.
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 14, 0),
          child: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: vm.allProducts.isEmpty
                ? _buildEmptyState(vm)
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildProductSection(true),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 360,
                        child: _buildLiveInvoicePanel(vm),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildLiveInvoicePanel(PosViewModel vm) {
    final fullCart = widget.isMainTab ? vm.mainTabCartItems : vm.cartItems;
    final activeDeptId = _isDepartmentSelectionMode ? _activeDepartmentTabId : null;
    final promoContextDeptId = activeDeptId ??
        (widget.departmentId != null &&
                widget.departmentId!.trim().isNotEmpty &&
                widget.departmentId != 'All'
            ? widget.departmentId!.trim()
            : null);
    final activeCart = (activeDeptId == null)
        ? fullCart
        : fullCart
            .where((i) => (i.product.departmentId ?? '') == activeDeptId)
            .toList();

    final gross = activeCart.fold<double>(0.0, (s, i) => s + i.lineSubtotalExclVat);
    final itemDiscount = activeCart.fold<double>(0.0, (s, i) => s + i.actualDiscountAmount);
    final afterItemDiscount = (gross - itemDiscount).clamp(0, double.infinity).toDouble();

    // Allocate order-level discounts proportionally so each department shows its own live invoice.
    final allAfterItemDiscount = fullCart.fold<double>(
      0.0,
      (s, i) => s + i.totalPriceExclVat,
    ).clamp(0, double.infinity).toDouble();
    final globalDiscountAll = vm.getTotalGlobalDiscountValue(widget.isMainTab);
    final globalRatio = allAfterItemDiscount <= 0 ? 0.0 : (afterItemDiscount / allAfterItemDiscount);
    final globalDiscount = (globalDiscountAll * globalRatio)
        .clamp(0, afterItemDiscount)
        .toDouble();
    final afterGlobal = (afterItemDiscount - globalDiscount)
        .clamp(0, double.infinity)
        .toDouble();

    final afterGlobalAll = vm.getPriceAfterJobDiscount(widget.isMainTab);
    final promoDiscountAll = vm.getTotalPromoDiscountValue(widget.isMainTab);
    final promoRatio = afterGlobalAll <= 0 ? 0.0 : (afterGlobal / afterGlobalAll);
    final fallbackPromoDiscount = (promoDiscountAll * promoRatio)
        .clamp(0, afterGlobal)
        .toDouble();
    final promoDiscount = activeDeptId == null
        ? fallbackPromoDiscount
        : vm.getPromoDiscountForBase(
            afterGlobal,
            isMainTab: widget.isMainTab,
            departmentId: activeDeptId,
          );
    final taxable = (afterGlobal - promoDiscount)
        .clamp(0, double.infinity)
        .toDouble();
    final vat = taxable * 0.15;
    final total = taxable + vat;

    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        final w = constraints.maxWidth;
        return ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: w,
            maxWidth: w,
            minHeight: h.isFinite ? h : 0,
            maxHeight: h.isFinite ? h : double.infinity,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
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
                    '${activeCart.length}',
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
            child: activeCart.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    child: Center(
                      child: Text(
                        'No items in invoice',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    children: [
                      for (var i = 0; i < activeCart.length; i++) ...[
                        _buildCartItem(activeCart[i], false),
                        if (i != activeCart.length - 1) const SizedBox(height: 8),
                      ],
                    ],
                  ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          Padding(
            padding: EdgeInsets.fromLTRB(
              12,
              10,
              12,
              10 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTotalRow(
                  'Gross Amount (Excl. VAT)',
                  'SAR ${gross.toStringAsFixed(2)}',
                  false,
                ),
                const SizedBox(height: 6),
                _buildTotalRow(
                  'Line discount',
                  '-SAR ${itemDiscount.toStringAsFixed(2)}',
                  false,
                  color: itemDiscount > 0 ? Colors.green : Colors.grey.shade600,
                ),
                const SizedBox(height: 6),
                _buildTotalRow(
                  'Price after line discount',
                  'SAR ${afterItemDiscount.toStringAsFixed(2)}',
                  false,
                ),
                const SizedBox(height: 8),
                _buildInteractiveTotalDiscountRow(context, vm, false),
                const SizedBox(height: 6),
                if (globalDiscount > 0) ...[
                  _buildTotalRow(
                    'Total discount applied',
                    '-SAR ${globalDiscount.toStringAsFixed(2)}',
                    false,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 6),
                ],
                _buildTotalRow(
                  'Price after total discount',
                  'SAR ${afterGlobal.toStringAsFixed(2)}',
                  false,
                ),
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
                            onTap: activeCart.isEmpty
                                ? null
                                : () {
                                    vm.setPromoContextDepartment(
                                      promoContextDeptId,
                                      isMainTab: widget.isMainTab,
                                    );
                                    showDialog(
                                      context: context,
                                      builder: (_) =>
                                          PromoCodeDialog(isMainTab: widget.isMainTab),
                                    );
                                  },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 6,
                              ),
                              child: Text(
                                vm.getActivePromoCode(
                                          widget.isMainTab,
                                          departmentId: promoContextDeptId,
                                        )
                                        .trim()
                                        .isEmpty
                                    ? 'Add Promo Code'
                                    : 'Promo: ${vm.getActivePromoCode(widget.isMainTab, departmentId: promoContextDeptId).trim()}',
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
                      if (vm.getActivePromoCode(
                            widget.isMainTab,
                            departmentId: promoContextDeptId,
                          ).trim().isNotEmpty)
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          icon: Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              color: AppColors.secondaryLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () {
                            vm.clearPromoCode(
                              isMainTab: widget.isMainTab,
                              departmentId: promoContextDeptId,
                            );
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                if (promoDiscount > 0) ...[
                  _buildTotalRow(
                    'Promo discount',
                    '-SAR ${promoDiscount.toStringAsFixed(2)}',
                    false,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 6),
                ],
                _buildTotalRow(
                  'Price after promo',
                  'SAR ${taxable.toStringAsFixed(2)}',
                  false,
                ),
                const SizedBox(height: 6),
                _buildTotalRow(
                  'VAT (15%)',
                  'SAR ${vat.toStringAsFixed(2)}',
                  false,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                    const Spacer(),
                    Text(
                      'SAR ${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                if (!widget.isReadOnly && !widget.isMainTab) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: Consumer<PosViewModel>(
                      builder: (context, vm, _) {
                        final saving = vm.isInvoicePanelSaveBusy;
                        return ElevatedButton(
                          onPressed: saving ? null : () => _saveInvoiceFromPanel(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondaryLight,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppColors.secondaryLight,
                            disabledForegroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: saving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Save',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
            ),
          ),
        );
      },
    );
  }

  // ── Invoice Bottom Sheet ──
  void _showInvoiceBottomSheet(BuildContext context, bool isTablet) {
    bool isSavingDraft = false;
    bool isForwarding = false;
    final actualIsTablet = MediaQuery.of(context).size.width > 600;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Dialog(
              insetPadding: EdgeInsets.symmetric(
                horizontal: actualIsTablet ? 16 : 14,
                vertical: actualIsTablet ? 12 : 24,
              ),
              backgroundColor: Colors.transparent,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom,
                ),
                child: Container(
                height: MediaQuery.of(context).size.height *
                    (actualIsTablet ? 0.90 : 0.80),
                width: actualIsTablet
                    ? (MediaQuery.of(ctx).size.width - 32)
                    : (MediaQuery.of(ctx).size.width - 28),
                decoration: const BoxDecoration(
                  color: Color(0xFFFBF9F6),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(
                      MediaQuery.of(context).orientation == Orientation.landscape
                          ? 1.12
                          : 1.14,
                    ),
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
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 12),
                    child: Row(
                      children: [
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: const Icon(Icons.close_rounded),
                          iconSize: isTablet ? 24 : 20,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.grey.shade700,
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                      ],
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
                          
                          String custName = vm.customerName.isNotEmpty
                              ? vm.customerName
                              : (widget.completingOrder?.customerName ?? '');
                          if (custName.isEmpty) custName = 'Walk-in Customer';
                          
                          String make = vm.make.isNotEmpty
                              ? vm.make
                              : (widget.completingOrder?.vehicle?.make ?? '');
                          String model = vm.model.isNotEmpty
                              ? vm.model
                              : (widget.completingOrder?.vehicle?.model ?? '');
                          String plate = vm.vehicleNumber.isNotEmpty
                              ? vm.vehicleNumber
                              : (widget.completingOrder?.plateNumber ?? '');
                          String vehicleText = [make, model].where((s) => s.isNotEmpty).join(' ');
                          if (plate.isNotEmpty) {
                            vehicleText = vehicleText.isNotEmpty ? '$vehicleText • $plate' : plate;
                          }
                          if (vehicleText.trim().isEmpty || vehicleText == '•') vehicleText = 'No Vehicle Details';

                          String phoneText = vm.mobile.isNotEmpty
                              ? vm.mobile
                              : (widget.completingOrder?.customer?.mobile ?? '');
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
                                          style: TextStyle(fontSize: isLandscape ? (isTablet ? 18 : 12) : (isTablet ? 16 : 10), fontWeight: FontWeight.w800, color: const Color(0xFF1E2124)),
                                        ),
                                      ),
                                      SizedBox(width: isTablet ? 8 : 6),
                                      Expanded(
                                        child: Text(
                                          custName,
                                          style: TextStyle(fontSize: isLandscape ? (isTablet ? 24 : 15) : (isTablet ? 22 : 13), fontWeight: FontWeight.w700, color: const Color(0xFF1E2124)),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(statusText, style: TextStyle(color: statusColor, fontSize: isLandscape ? (isTablet ? 18 : 12) : (isTablet ? 17 : 11), fontWeight: FontWeight.w700)),
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
                        padding: EdgeInsets.fromLTRB(isTablet ? 24 : 16, isTablet ? 10 : 10, isTablet ? 24 : 16, isTablet ? 6 : 8),
                        child: Row(
                          children: [
                            Text('Order Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isTablet ? 20 : 14, color: const Color(0xFF1E2124))),
                            const Spacer(),
                            Consumer<PosViewModel>(
                              builder: (context, vm, _) {
                                final c = widget.isMainTab ? vm.mainTabCartItems : vm.cartItems;
                                if (c.isEmpty) return const SizedBox.shrink();
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(10)),
                                  child: Text(
                                    '${c.length}',
                                    style: TextStyle(fontSize: isTablet ? 16 : 11, fontWeight: FontWeight.w700, color: const Color(0xFF1E2124)),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // ── Cart Items ──
                      Expanded(
                        child: Consumer<PosViewModel>(
                          builder: (context, vm, child) {
                            final activeCart = widget.isMainTab ? vm.mainTabCartItems : vm.cartItems;
                            final isLandscape =
                                MediaQuery.of(context).orientation ==
                                Orientation.landscape;
                            final cartTwoCols =
                                MediaQuery.sizeOf(context).width > 600 ||
                                isLandscape;

                            return activeCart.isEmpty
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
                                : (!isTablet && !isLandscape)
                                    ? ListView.separated(
                                        padding: const EdgeInsets.fromLTRB(12, 2, 12, 8),
                                        itemCount: activeCart.length,
                                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                                        itemBuilder: (context, index) {
                                          return _buildCartItem(activeCart[index], isTablet);
                                        },
                                      )
                                    : cartTwoCols
                                        ? LayoutBuilder(
                                            builder: (context, constraints) {
                                              final hPad = isTablet ? 16.0 : 12.0;
                                              final gap = isTablet ? 5.0 : 8.0;
                                              final contentW =
                                                  constraints.maxWidth - 2 * hPad;
                                              final cellW = (contentW - gap) / 2;
                                              return SingleChildScrollView(
                                                padding: EdgeInsets.fromLTRB(
                                                  hPad,
                                                  isTablet ? 0 : 2,
                                                  hPad,
                                                  isTablet ? 4 : 8,
                                                ),
                                                child: Wrap(
                                                  spacing: gap,
                                                  runSpacing: gap,
                                                  children: [
                                                    for (final item in activeCart)
                                                      SizedBox(
                                                        width: cellW,
                                                        child: _buildCartItem(
                                                          item,
                                                          isTablet,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              );
                                            },
                                          )
                                        : ListView.separated(
                                            padding: const EdgeInsets.fromLTRB(
                                              12,
                                              2,
                                              12,
                                              8,
                                            ),
                                            itemCount: activeCart.length,
                                            separatorBuilder: (_, __) =>
                                                const SizedBox(height: 8),
                                            itemBuilder: (context, index) {
                                              return _buildCartItem(
                                                activeCart[index],
                                                isTablet,
                                              );
                                            },
                                          );
                          },
                        ),
                      ),

                      // ── Totals ──
                      Consumer<PosViewModel>(
                        builder: (context, vm, child) {
                          final sheetActiveDeptId = _isDepartmentSelectionMode
                              ? _activeDepartmentTabId
                              : null;
                          final sheetPromoContextDeptId = sheetActiveDeptId ??
                              (widget.departmentId != null &&
                                      widget.departmentId!.trim().isNotEmpty &&
                                      widget.departmentId != 'All'
                                  ? widget.departmentId!.trim()
                                  : null);
                          final promoCode = vm.getActivePromoCode(
                            widget.isMainTab,
                            departmentId: sheetPromoContextDeptId,
                          );
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 14),
                            padding: EdgeInsets.all(isTablet ? 24 : 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade100),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildTotalRow(
                                  'Gross Amount (Excl. VAT)',
                                  'SAR ${vm.getSubtotalGross(widget.isMainTab).toStringAsFixed(2)}',
                                  isTablet,
                                ),
                                SizedBox(height: isTablet ? 8 : 6),
                                _buildTotalRow(
                                  'Line discount',
                                  '-SAR ${vm.getTotalIndividualDiscount(widget.isMainTab).toStringAsFixed(2)}',
                                  isTablet,
                                  color: vm.getTotalIndividualDiscount(widget.isMainTab) > 0
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                SizedBox(height: isTablet ? 8 : 6),
                                _buildTotalRow(
                                  'Price after line discount',
                                  'SAR ${vm.getPriceAfterItemDiscounts(widget.isMainTab).toStringAsFixed(2)}',
                                  isTablet,
                                ),
                                SizedBox(height: isTablet ? 10 : 8),
                                _buildInteractiveTotalDiscountRow(context, vm, isTablet),
                                SizedBox(height: isTablet ? 8 : 6),
                                if (vm.getTotalGlobalDiscountValue(widget.isMainTab) > 0) ...[
                                  _buildTotalRow(
                                    'Total discount applied',
                                    '-SAR ${vm.getTotalGlobalDiscountValue(widget.isMainTab).toStringAsFixed(2)}',
                                    isTablet,
                                    color: Colors.green,
                                  ),
                                  SizedBox(height: isTablet ? 8 : 6),
                                ],
                                _buildTotalRow(
                                  'Price after total discount',
                                  'SAR ${vm.getPriceAfterJobDiscount(widget.isMainTab).toStringAsFixed(2)}',
                                  isTablet,
                                ),
                                SizedBox(height: isTablet ? 12 : 10),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isTablet ? 8 : 6,
                                    vertical: isLandscape
                                        ? (isTablet ? 6 : 4)
                                        : (isTablet ? 5 : 4),
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF7E6),
                                    border: Border.all(
                                      color: const Color(0xFFFFC145)
                                          .withOpacity(0.6),
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.local_offer_outlined,
                                        size: isTablet ? 18 : 15,
                                        color: const Color(0xFFFFC145)
                                            .withOpacity(0.75),
                                      ),
                                      SizedBox(width: isTablet ? 8 : 6),
                                      Expanded(
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              vm.setPromoContextDepartment(
                                                sheetPromoContextDeptId,
                                                isMainTab: widget.isMainTab,
                                              );
                                              showDialog(
                                                context: context,
                                                builder: (_) =>
                                                    PromoCodeDialog(
                                                      isMainTab: widget.isMainTab,
                                                    ),
                                              );
                                            },
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                vertical: isLandscape
                                                    ? (isTablet ? 10 : 8)
                                                    : (isTablet ? 9 : 8),
                                                horizontal: 4,
                                              ),
                                              child: Text(
                                                promoCode.isEmpty
                                                    ? 'Add Promo Code'
                                                    : 'Promo: $promoCode',
                                                style: TextStyle(
                                                  fontSize: isTablet ? 17 : 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: promoCode.isEmpty
                                                      ? const Color(0xFF1E2124)
                                                      : Colors.green,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (promoCode.isNotEmpty)
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(
                                            minWidth: isTablet ? 40 : 36,
                                            minHeight: isTablet ? 40 : 36,
                                          ),
                                          icon: Icon(
                                            Icons.close_rounded,
                                            size: isTablet ? 22 : 18,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            vm.clearPromoCode(
                                              isMainTab: widget.isMainTab,
                                              departmentId:
                                                  sheetPromoContextDeptId,
                                            );
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: isTablet ? 10 : 8),
                                if (vm.getTotalPromoDiscountValue(
                                      widget.isMainTab,
                                    ) >
                                    0) ...[
                                  _buildTotalRow(
                                    'Promo discount',
                                    '-SAR ${vm.getTotalPromoDiscountValue(widget.isMainTab).toStringAsFixed(2)}',
                                    isTablet,
                                    color: Colors.green,
                                  ),
                                  SizedBox(height: isTablet ? 8 : 6),
                                ],
                                _buildTotalRow(
                                  'Price after promo',
                                  'SAR ${vm.getTotalTaxableAmountValue(widget.isMainTab).toStringAsFixed(2)}',
                                  isTablet,
                                ),
                                Divider(height: 1, color: Colors.grey.shade200),
                                SizedBox(height: isTablet ? 10 : 8),
                                _buildTotalRow(
                                  'VAT (15%)',
                                  'SAR ${vm.getTotalTaxValue(widget.isMainTab).toStringAsFixed(2)}',
                                  isTablet,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: isTablet ? 10 : 8),
                                Row(
                                  children: [
                                    Text(
                                      'Total amount',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: isLandscape
                                            ? (isTablet ? 27 : 17)
                                            : (isTablet ? 24 : 14),
                                        color: const Color(0xFF1E2124),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      'SAR ${vm.getTotalAmountValue(widget.isMainTab).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: isLandscape
                                            ? (isTablet ? 27 : 17)
                                            : (isTablet ? 24 : 14),
                                        color: const Color(0xFF1E2124),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }
                      ),

                      SizedBox(height: isTablet ? 10 : 8),

                      // ── Action Buttons ──
                      Padding(
                        padding: EdgeInsets.fromLTRB(isTablet ? 32 : 14, 0, isTablet ? 32 : 14, MediaQuery.of(context).padding.bottom + 20),
                        child: (widget.completingOrderId != null &&
                                !(widget.completingOrder?.statusText
                                        .toLowerCase()
                                        .contains('pending assignment') ??
                                    false))
                            ? SizedBox(
                                width: double.infinity,
                                height: isTablet ? 60 : 48,
                                child: Consumer<PosViewModel>(
                                  builder: (context, vm, child) {
                                    var jobId = widget.completingOrderId!;
                                    if (widget.completingOrder != null &&
                                        widget.completingOrder!.jobs.isNotEmpty) {
                                      jobId = widget.completingOrder!.latestJob!.id;
                                    }
                                    final completing = vm.isCashierCompletingJob(jobId);
                                    return ElevatedButton(
                                      onPressed: completing
                                          ? null
                                          : () async {
                                              final response = await vm.completeCashierJob(
                                                jobId,
                                                isMainTab: widget.isMainTab,
                                              );
                                              if (response != null && response.success && context.mounted) {
                                                navigateToPosShellOrdersTab(context);
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
                                      child: completing
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
                                  if (!widget.isMainTab) 
                                    Row(
                                      children: [
                                        if (widget.completingOrderId == null) ...[
                                          Expanded(
                                            child: SizedBox(
                                              height: isLandscape
                                                  ? (isTablet ? 64 : 50)
                                                  : (isTablet ? 60 : 44),
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
                                                            final keepDraftContext = vm.corporateAccountId != null &&
                                                                (vm.walkInDraftOrderId?.trim().isNotEmpty ?? false);
                                                            final success = await vm.submitWalkInOrder(
                                                              [finalDeptId],
                                                              context,
                                                              clearCustomerOnSuccess: !keepDraftContext,
                                                              forInvoicePanelSave: true,
                                                            );
                                                            if (success && context.mounted) {
                                                              vm.fetchOrders();
                                                              navigateToPosShellOrdersTab(context);
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
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.w600,
                                                              fontSize: isLandscape
                                                                  ? (isTablet ? 18 : 13)
                                                                  : (isTablet ? 16 : 11),
                                                            ),
                                                          ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: isTablet ? 8 : 6),
                                        ],
                                        Expanded(
                                          child: SizedBox(
                                            height: isLandscape
                                                ? (isTablet ? 64 : 50)
                                                : (isTablet ? 60 : 44),
                                            child: Consumer<PosViewModel>(
                                              builder: (context, vm, child) {
                                                return ElevatedButton(
                                                  onPressed: vm.isLoading || isSavingDraft
                                                      ? null
                                                      : () {
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
                                                          // Navigate directly — walk-in API called on "Assign to Technician"
                                                          Navigator.of(ctx).pop();
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (_) => PosTechnicianAssignmentView(
                                                                jobId: '',
                                                                departmentName: widget.departmentName,
                                                                departmentId: finalDeptId,
                                                                isWalkIn: true,
                                                                initialAssignedTechnicians:
                                                                    _initialAssignedForWalkInTechnicianScreen(),
                                                              ),
                                                            ),
                                                          );
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
                                                      : Text(
                                                          'Forward to Technician',
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.w600,
                                                            fontSize: isLandscape
                                                                ? (isTablet ? 18 : 13)
                                                                : (isTablet ? 16 : 11),
                                                          ),
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
              ),
            ));
          },
        );
      },
    );
  }

  // ── Product Section (shared by tablet & mobile) ──

  Widget _buildProductSection(bool isTablet) {
    final gridVm = context.watch<ProductGridViewModel>();
    final vm = Provider.of<PosViewModel>(context);
    final selectedDeptIds = _selectedDepartmentIds;
    final allowedDeptSet = selectedDeptIds.toSet();
    final hasDeptRestriction = allowedDeptSet.isNotEmpty;
    if (_isDepartmentSelectionMode && selectedDeptIds.isEmpty) {
      return _buildNoDepartmentState(isTablet);
    }

    // Common Filtering Logic
    final filteredProducts = vm.allProducts.where((product) {
      if (vm.selectedProductType != 'All') {
        final isService = vm.selectedProductType == 'Services';
        if (product.isServiceType != isService) return false;
      }
      final productDeptId = product.departmentId ?? '';
      if (hasDeptRestriction && !allowedDeptSet.contains(productDeptId)) {
        return false;
      }
      final selectedDept = gridVm.selectedDepartment.trim().toLowerCase();
      final productDept = (product.departmentName ?? '').trim().toLowerCase();
      final matchesDept = _isDepartmentSelectionMode
          ? (_activeDepartmentTabId == null || productDeptId == _activeDepartmentTabId)
          : (selectedDept == 'all' ||
              productDept == selectedDept ||
              (widget.departmentId != null &&
                  widget.departmentId != 'All' &&
                  productDeptId == widget.departmentId));
      final matchesCategory =
          gridVm.selectedCategory == 'All' ||
          product.category == gridVm.selectedCategory;
      final matchesSearch = gridVm.searchQuery.isEmpty || product.name.toLowerCase().contains(gridVm.searchQuery.toLowerCase());
      return matchesDept && matchesCategory && matchesSearch;
    }).toList();

    filteredProducts.sort((a, b) {
      final deptA = a.departmentName ?? 'ZZZ';
      final deptB = b.departmentName ?? 'ZZZ';
      if (deptA != deptB) return deptA.compareTo(deptB);
      return a.name.compareTo(b.name);
    });

    if (isTablet) {
      final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
      return Column(
        children: [
          if (vm.allProducts.isNotEmpty) ...[
            // ─── FIXED HEADERS: Search, Tabs & Categories ───
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: PosSearchBar(
                      controller: gridVm.searchController,
                      onChanged: (v) => gridVm.setSearchQuery(v),
                      hintText: 'Search products & services...',
                    ),
                  ),
                  if (!widget.isMainTab) ...[
                    const SizedBox(width: 12),
                    _buildAddTechnicianButton(true),
                  ],
                ],
              ),
            ),
            if (_isDepartmentSelectionMode)
              _buildDepartmentTabs(isTablet, vm, gridVm),
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
                child: Row(
                  children: [
                    _buildTabItem(vm, gridVm, 'All', true),
                    _buildTabItem(vm, gridVm, 'Products', true),
                    _buildTabItem(vm, gridVm, 'Services', true),
                  ],
                ),
              ),
            ),
            // Category Chips (ALSO FIXED)
            _buildSubCategoryChips(true, vm, gridVm),
          ],

          SizedBox(height: isTablet ? 10 : 8),
          Expanded(
            child: vm.allProducts.isEmpty
                ? _buildEmptyState(vm)
                : filteredProducts.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: Text(
                            'No products match your search.',
                            textAlign: TextAlign.center,
                            style: _posCatalogEmptyMessageTextStyle(),
                          ),
                        ),
                      )
                    : Builder(
                        builder: (context) {
                          Widget grid = GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            clipBehavior: Clip.hardEdge,
                            padding: const EdgeInsets.fromLTRB(22, 8, 22, 100),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isPortrait ? 2 : 3,
                              // Match tablet card content + small flex gap; extra height = empty band under qty row.
                              mainAxisExtent: 156,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];
                              return Consumer<PosViewModel>(
                                builder: (context, vm, child) {
                                  final activeCart = widget.isMainTab ? vm.mainTabCartItems : vm.cartItems;
                                  final cartItemIndex = activeCart.indexWhere(
                                    (i) =>
                                        i.product.id == product.id &&
                                        i.product.isServiceType ==
                                            product.isServiceType &&
                                        (i.product.departmentId ?? '') ==
                                            (product.departmentId ?? ''),
                                  );
                                  final qty = cartItemIndex != -1 ? activeCart[cartItemIndex].quantity : 0.0;
                                  return _buildProductCard(product, qty, true);
                                },
                              );
                            },
                          );

                          return grid;
                        },
                      ),
          ),
        ],
      );
    }

    // ─── MOBILE: Standard Column with everything fixed ───
    return Column(
      children: [
        if (vm.allProducts.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: PosSearchBar(
                    controller: gridVm.searchController,
                    onChanged: (v) => gridVm.setSearchQuery(v),
                    hintText: 'Search products & services...',
                  ),
                ),
                if (!widget.isMainTab) ...[
                  const SizedBox(width: 8),
                  _buildAddTechnicianButton(false),
                ],
              ],
            ),
          ),
          if (_isDepartmentSelectionMode)
            _buildDepartmentTabs(isTablet, vm, gridVm),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  _buildTabItem(vm, gridVm, 'All', false),
                  _buildTabItem(vm, gridVm, 'Products', false),
                  _buildTabItem(vm, gridVm, 'Services', false),
                ],
              ),
            ),
          ),
          _buildSubCategoryChips(false, vm, gridVm),
        ],

        const SizedBox(height: 8),
        Expanded(
          child: vm.allProducts.isEmpty
              ? _buildEmptyState(vm)
              : filteredProducts.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Text(
                          'No products match your search.',
                          textAlign: TextAlign.center,
                          style: _posCatalogEmptyMessageTextStyle(),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: filteredProducts.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return Consumer<PosViewModel>(
                          builder: (context, vm, child) {
                            final activeCart = widget.isMainTab ? vm.mainTabCartItems : vm.cartItems;
                            final cartItemIndex = activeCart.indexWhere(
                              (i) =>
                                  i.product.id == product.id &&
                                  i.product.isServiceType ==
                                      product.isServiceType &&
                                  (i.product.departmentId ?? '') ==
                                      (product.departmentId ?? ''),
                            );
                            final qty = cartItemIndex != -1 ? activeCart[cartItemIndex].quantity : 0.0;
                            return _buildProductCard(product, qty, false);
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }

  // Refactored Helper Methods to avoid duplication
  Widget _buildTabItem(PosViewModel vm, ProductGridViewModel gridVm, String type, bool isTablet) {
    final isSelected = vm.selectedProductType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          vm.setProductType(type);
          gridVm.setCategory('All');
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            type,
            style: TextStyle(
              color: isSelected ? AppColors.secondaryLight : AppColors.secondaryLight.withOpacity(0.6),
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              fontSize: isTablet ? 13 : 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubCategoryChips(bool isTablet, PosViewModel vm, ProductGridViewModel gridVm) {
    return Consumer<PosViewModel>(
      builder: (context, vm, child) {
        List<PosProduct> sourceProducts;
        if (vm.selectedProductType != 'All') {
          final isService = vm.selectedProductType == 'Services';
          sourceProducts = vm.allProducts.where((p) => p.isServiceType == isService).toList();
        } else {
          sourceProducts = vm.allProducts.toList();
        }

        // Keep category chips scoped to the currently selected department.
        if (_hasMultiSelectedDepartments) {
          sourceProducts = sourceProducts
              .where((p) => (_activeDepartmentTabId == null || p.departmentId == _activeDepartmentTabId))
              .toList();
        } else if (widget.departmentId != null && widget.departmentId != 'All') {
          sourceProducts = sourceProducts
              .where((p) => p.departmentId == widget.departmentId)
              .toList();
        } else {
          sourceProducts = sourceProducts.where((p) {
            return gridVm.selectedDepartment == 'All' ||
                p.departmentName == gridVm.selectedDepartment;
          }).toList();
        }

        Set<String> subCatsSet = {};
        for (var p in sourceProducts) {
          final catName = p.category;
          if (catName.isNotEmpty) subCatsSet.add(catName);
        }

        final subCats = subCatsSet.toList();
        subCats.sort();
        if (subCats.isEmpty && sourceProducts.isEmpty) return const SizedBox.shrink();

        final displaySubCats = ['All', ...subCats];
        return Column(
          children: [
            SizedBox(
              height: isTablet ? 56 : 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 22 : 12, vertical: 6),
                itemCount: displaySubCats.length,
                itemBuilder: (context, index) {
                  final subCat = displaySubCats[index];
                  final isSelected = gridVm.selectedCategory == subCat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Center(
                      child: GestureDetector(
                        onTap: () => gridVm.setCategory(subCat),
                        child: Container(
                          height: isTablet ? 40 : 34,
                          padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 16),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.secondaryLight : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSelected ? AppColors.secondaryLight : Colors.grey.shade300),
                            boxShadow: isSelected ? [
                              BoxShadow(
                                color: AppColors.secondaryLight.withOpacity(0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ] : null,
                          ),
                          child: Text(
                            subCat,
                            style: TextStyle(
                              fontSize: isTablet ? 12 : 11,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? Colors.white : Colors.grey.shade600,
                            ),
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
      },
    );
  }

  Widget _buildDepartmentTabs(
    bool isTablet,
    PosViewModel vm,
    ProductGridViewModel gridVm,
  ) {
    return const SizedBox.shrink();
  }

  Widget _buildNoDepartmentState(bool isTablet) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Department not found',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: isTablet ? 48 : 44,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const PosDepartmentView()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  foregroundColor: AppColors.secondaryLight,
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 18 : 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Add Department'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(PosViewModel vm) {
    return ColoredBox(
      color: const Color(0xFFFBFBFD),
      child: SizedBox.expand(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Text(
              vm.selectedProductType == 'Services' ? 'No services found' : 'No products found',
              textAlign: TextAlign.center,
              style: _posCatalogEmptyMessageTextStyle(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(PosProduct product, double cartQty, bool isTablet) {
    final outOfStock = !product.isService && product.stock <= 0;
    if (!isTablet) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isReadOnly || !_canIncrementProduct(product, cartQty)
              ? null
              : () => _addToCart(product),
          borderRadius: BorderRadius.circular(14),
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
                                      right: cartQty > 0 && !widget.isReadOnly ? 44 : 0,
                                    ),
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
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
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
                              const SizedBox(height: 2),
                            ],
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: product.stockColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                product.stockLabel,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: product.stockColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (cartQty > 0 && !widget.isReadOnly)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                                'x${_formatGridQuantityLabel(product, cartQty)}',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.secondaryLight),
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
                            'SAR ${product.price.toStringAsFixed(2)}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: AppColors.secondaryLight,
                            ),
                          ),
                          if (!widget.isReadOnly) ...[
                            const SizedBox(height: 6),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildQtyButton(Icons.remove, isTablet, onTap: cartQty > 0
                                    ? () => _updateQty(product, -1)
                                    : null),
                                _InlineGridQtyField(
                                  product: product,
                                  cartQty: cartQty,
                                  isMainTab: widget.isMainTab,
                                  isTablet: isTablet,
                                  outOfStock: outOfStock,
                                ),
                                _buildQtyButton(
                                  Icons.add,
                                  isTablet,
                                  onTap: _canIncrementProduct(product, cartQty)
                                      ? () => _addToCart(product)
                                      : null,
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

    // Tablet View (Grid Item)
    return Stack(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.isReadOnly || !_canIncrementProduct(product, cartQty)
                ? null
                : () => _addToCart(product),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
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
                padding: const EdgeInsets.fromLTRB(9, 8, 9, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Name + meta + price grouped at top; qty sits at card bottom only.
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
                                color: product.stockColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                product.stockLabel,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: product.stockColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'SAR ${product.price.toStringAsFixed(2)}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            height: 1.1,
                            color: AppColors.secondaryLight,
                          ),
                        ),
                      ],
                    ),
                    if (!widget.isReadOnly)
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            children: [
                              _buildQtyButton(Icons.remove, true, onTap: cartQty > 0
                                  ? () => _updateQty(product, -1)
                                  : null),
                              _InlineGridQtyField(
                                product: product,
                                cartQty: cartQty,
                                isMainTab: widget.isMainTab,
                                isTablet: true,
                                outOfStock: outOfStock,
                              ),
                              _buildQtyButton(
                                Icons.add,
                                true,
                                onTap: _canIncrementProduct(product, cartQty)
                                    ? () => _addToCart(product)
                                    : null,
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
        if (cartQty > 0 && !widget.isReadOnly)
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
                'x${_formatGridQuantityLabel(product, cartQty)}',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.secondaryLight),
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
        width: isTablet ? 28 : 28,
        height: isTablet ? 28 : 28,
        decoration: BoxDecoration(
          color: onTap != null ? AppColors.secondaryLight : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(icon, size: isTablet ? 14 : 14, color: onTap != null ? Colors.white : Colors.grey),
      ),
    );
  }

  // ── Cart Item ──
  /// Right column: net line total (excl. VAT); crosses out gross when line discount applies.
  Widget _buildCartLineExclVatPriceBlock(CartItem item, {required bool isTablet}) {
    final hasLineDisc = item.actualDiscountAmount > 0;
    final net = item.totalPriceExclVat;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasLineDisc) ...[
          Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Text(
              'SAR ${item.lineSubtotalExclVat.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: isTablet ? 14 : 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                decoration: TextDecoration.lineThrough,
                decorationColor: Colors.grey.shade600,
                height: 1.15,
              ),
            ),
          ),
          SizedBox(height: isTablet ? 4 : 2),
        ],
        Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Text(
            'SAR ${net.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTablet ? 18 : 13,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E2124),
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(CartItem item, bool isTablet) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: EdgeInsets.zero,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(item.product.name,
                            style: TextStyle(
                              fontSize: isTablet ? 17 : 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E2124),
                              height: isTablet ? 1.2 : 1.15,
                            ),
                            maxLines: isTablet ? 2 : 1,
                            overflow: TextOverflow.ellipsis),
                        SizedBox(height: isTablet ? 8 : 6),
                        if (item.product.isService && item.product.isPriceEditable)
                          _EditableServiceUnitPriceRow(
                            item: item,
                            isMainTab: widget.isMainTab,
                            isTablet: isTablet,
                          )
                        else
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
                              '${_formatGridQuantityLabel(item.product, item.quantity)} × SAR ${item.effectiveUnitPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: isTablet ? 13 : 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                                height: isTablet ? 1.1 : 1.0,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  if (isTablet) ...[
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildCartLineExclVatPriceBlock(item, isTablet: true),
                        SizedBox(
                          height: item.actualDiscountAmount > 0 ? 8 : 10,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Dis.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 60,
                              height: 28,
                              child: TextFormField(
                                key: ValueKey(
                                  'ind_disc_${item.product.id}_${item.isDiscountPercent}',
                                ),
                                initialValue: item.discount > 0
                                    ? (item.discount % 1 == 0
                                        ? item.discount.toInt().toString()
                                        : item.discount.toString())
                                    : '',
                                keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                onChanged: (val) {
                                  final discount = double.tryParse(val) ?? 0.0;
                                  context.read<PosViewModel>().setIndividualDiscount(
                                        item.product,
                                        discount,
                                        item.isDiscountPercent,
                                        isMainTab: widget.isMainTab,
                                      );
                                },
                                style: const TextStyle(fontSize: 12),
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.zero,
                                  hintText: '0',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                context.read<PosViewModel>().setIndividualDiscount(
                                      item.product,
                                      item.discount,
                                      !item.isDiscountPercent,
                                      isMainTab: widget.isMainTab,
                                    );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFC145)
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Text(
                                  item.isDiscountPercent ? '%' : 'SAR',
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

                  // Price + discount on the right for mobile (compact row)
                  if (!isTablet) ...[
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildCartLineExclVatPriceBlock(item, isTablet: false),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Dis.', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                            const SizedBox(width: 3),
                            SizedBox(
                              width: 38,
                              height: 18,
                              child: TextFormField(
                                key: ValueKey('ind_disc_${item.product.id}_${item.isDiscountPercent}'),
                                initialValue: item.discount > 0
                                    ? (item.discount % 1 == 0 ? item.discount.toInt().toString() : item.discount.toString())
                                    : '',
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (val) {
                                  final discount = double.tryParse(val) ?? 0.0;
                                  context.read<PosViewModel>().setIndividualDiscount(item.product, discount, item.isDiscountPercent, isMainTab: widget.isMainTab);
                                },
                                style: const TextStyle(fontSize: 10),
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.zero,
                                  hintText: '0',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.grey.shade300)),
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 3),
                            GestureDetector(
                              onTap: () => context.read<PosViewModel>().setIndividualDiscount(item.product, item.discount, !item.isDiscountPercent, isMainTab: widget.isMainTab),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFC145).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item.isDiscountPercent ? '%' : 'SAR',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF1E2124)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: isTablet ? 8 : 8,
          right: isTablet ? 8 : 8,
          child: GestureDetector(
            onTap: () {
              context.read<PosViewModel>().removeFromCart(item.product, isMainTab: widget.isMainTab);
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: EdgeInsets.all(isTablet ? 6 : 6),
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
    );
  }

  // ── Helpers ──
  Widget _buildInteractiveTotalDiscountRow(
    BuildContext context,
    PosViewModel vm,
    bool isTablet,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Total discount',
            style: TextStyle(
              fontSize: isTablet ? 18 : 10,
              color: Colors.green.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          width: isTablet ? 80 : 56,
          height: isTablet ? 28 : 26,
          child: TextField(
            controller: vm.globalDiscountTextController(widget.isMainTab),
            keyboardType: TextInputType.text,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,+\s]')),
            ],
            onChanged: (val) {
              final discount = _parseCombinedDiscountInput(val);
              context.read<PosViewModel>().setGlobalDiscount(
                    discount,
                    vm.getActiveIsGlobalDiscountPercent(widget.isMainTab),
                    isMainTab: widget.isMainTab,
                  );
            },
            style: TextStyle(
              fontSize: isTablet ? 14 : 11,
              color: Colors.green.shade800,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              hintText: '0',
              hintStyle: TextStyle(color: Colors.green.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: Colors.green.shade400),
              ),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () {
            context.read<PosViewModel>().setGlobalDiscount(
                  vm.getActiveGlobalDiscount(widget.isMainTab),
                  !vm.getActiveIsGlobalDiscountPercent(widget.isMainTab),
                  isMainTab: widget.isMainTab,
                );
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 8 : 6,
              vertical: isTablet ? 4 : 3,
            ),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Text(
              vm.getActiveIsGlobalDiscountPercent(widget.isMainTab) ? '%' : 'SAR',
              style: TextStyle(
                fontSize: isTablet ? 12 : 9,
                fontWeight: FontWeight.w700,
                color: Colors.green.shade800,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow(String label, String value, bool isTablet, {Color? color}) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontSize: isTablet ? 18 : 10, color: color ?? Colors.grey.shade600)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: isTablet ? 18 : 10, fontWeight: FontWeight.w600, color: color ?? AppColors.secondaryLight)),
      ],
    );
  }

  double _parseCombinedDiscountInput(String input) {
    final normalized = input.trim();
    if (normalized.isEmpty) return 0.0;

    final parts = normalized
        .split(RegExp(r'[+,]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty);

    double total = 0.0;
    for (final part in parts) {
      total += double.tryParse(part) ?? 0.0;
    }
    return total;
  }

}

/// Grid badge + inline qty field (respects [PosProduct.allowDecimalQty]).
String _formatGridQuantityLabel(PosProduct product, double q) {
  if (q <= 0) return '0';
  if (!product.allowDecimalQty) {
    return (q % 1 == 0) ? q.toInt().toString() : q.round().toString();
  }
  final rounded = (q * 100).round() / 100.0;
  if (rounded % 1 == 0) return rounded.toInt().toString();
  var s = rounded.toStringAsFixed(2);
  if (s.contains('.')) {
    s = s.replaceFirst(RegExp(r'0+$'), '');
    if (s.endsWith('.')) s = s.substring(0, s.length - 1);
  }
  return s;
}

/// Clamps typed quantity so services never exceed 1.
class _ServiceQtyCapFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final d = double.tryParse(newValue.text.replaceAll(',', ''));
    if (d == null) return oldValue;
    if (d > 1) {
      const t = '1';
      return const TextEditingValue(
        text: t,
        selection: TextSelection.collapsed(offset: 1),
      );
    }
    return newValue;
  }
}

/// Inline quantity on product grid cards (replaces "Enter Quantity" dialog).
class _InlineGridQtyField extends StatefulWidget {
  final PosProduct product;
  final double cartQty;
  final bool isMainTab;
  final bool isTablet;
  final bool outOfStock;

  const _InlineGridQtyField({
    required this.product,
    required this.cartQty,
    required this.isMainTab,
    required this.isTablet,
    required this.outOfStock,
  });

  @override
  State<_InlineGridQtyField> createState() => _InlineGridQtyFieldState();
}

class _InlineGridQtyFieldState extends State<_InlineGridQtyField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  /// Apply typed quantity while the field still has focus (blur-only commit is easy to miss on tablet).
  Timer? _typingCommitDebounce;

  static String _formatQty(PosProduct product, double q) {
    return _formatGridQuantityLabel(product, q);
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: _formatQty(widget.product, widget.cartQty),
    );
    _focusNode = FocusNode()..canRequestFocus = !widget.product.isService;
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant _InlineGridQtyField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.isService != widget.product.isService) {
      _focusNode.canRequestFocus = !widget.product.isService;
    }
    if (oldWidget.outOfStock != widget.outOfStock ||
        oldWidget.product.id != widget.product.id) {
      _controller.text = _formatQty(widget.product, widget.cartQty);
      return;
    }
    if (!_focusNode.hasFocus) {
      final next = _formatQty(widget.product, widget.cartQty);
      if (_controller.text != next) {
        _controller.text = next;
      }
    }
  }

  @override
  void dispose() {
    _typingCommitDebounce?.cancel();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _scheduleCommitFromTyping() {
    _typingCommitDebounce?.cancel();
    _typingCommitDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      _commit();
    });
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      _typingCommitDebounce?.cancel();
      _commit();
    }
  }

  double _qtyInCart(PosViewModel vm) {
    final activeCart = widget.isMainTab ? vm.mainTabCartItems : vm.cartItems;
    final idx = activeCart.indexWhere(
      (i) =>
          i.product.id == widget.product.id &&
          i.product.isServiceType == widget.product.isServiceType &&
          (i.product.departmentId ?? '') == (widget.product.departmentId ?? ''),
    );
    if (idx < 0) return 0;
    return activeCart[idx].quantity;
  }

  void _commit() {
    if (widget.outOfStock) return;
    final rawFull = EnglishNumberFormatter.convert(_controller.text.trim())
        .replaceAll(',', '.');
    if (rawFull == '.') return;

    var raw = rawFull;
    if (RegExp(r'^\d+\.$').hasMatch(raw)) {
      raw = '${raw}0';
    }
    var qty = double.tryParse(raw) ?? 0;
    if (widget.product.isService && qty > 1) {
      qty = 1;
      _controller.text = _formatQty(widget.product, qty);
    }
    final vm = context.read<PosViewModel>();
    final err = vm.setSpecificQuantity(
      widget.product,
      qty,
      isMainTab: widget.isMainTab,
    );
    if (!mounted) return;
    if (err != null) {
      ToastService.showError(context, err);
      _controller.text = _formatQty(widget.product, widget.cartQty);
      return;
    }
    _controller.text = _formatQty(widget.product, _qtyInCart(vm));
  }

  InputDecoration _decoration({
    required bool disabled,
    bool readOnlyService = false,
  }) {
    final r = BorderRadius.circular(widget.isTablet ? 7 : 6);
    final base = OutlineInputBorder(
      borderRadius: r,
      borderSide: BorderSide(color: Colors.grey.shade200),
    );
    final fill = disabled
        ? Colors.grey.shade200
        : (readOnlyService ? Colors.grey.shade100 : Colors.grey.shade50);
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: fill,
      border: base,
      enabledBorder: base,
      focusedBorder: readOnlyService
          ? base
          : OutlineInputBorder(
              borderRadius: r,
              borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
            ),
      disabledBorder: base,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 4,
        vertical: widget.isTablet ? 8 : 4,
      ),
      hintText: '0',
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: widget.isTablet ? 12 : 11),
    );
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.outOfStock;
    final serviceLockQty = widget.product.isService;
    final field = TextField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: !disabled,
      readOnly: serviceLockQty,
      showCursor: !serviceLockQty,
      enableInteractiveSelection: !serviceLockQty,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.numberWithOptions(decimal: widget.product.allowDecimalQty),
      inputFormatters: [
        EnglishNumberFormatter(),
        if (widget.product.allowDecimalQty)
          const DecimalQtyTextInputFormatter(maxFractionDigits: 2)
        else
          FilteringTextInputFormatter.digitsOnly,
        if (widget.product.isService) _ServiceQtyCapFormatter(),
      ],
      style: TextStyle(
        fontSize: widget.isTablet ? 12 : 11,
        fontWeight: FontWeight.w600,
        color: disabled ? Colors.grey.shade600 : const Color(0xFF1E2124),
      ),
      decoration: _decoration(disabled: disabled, readOnlyService: serviceLockQty && !disabled),
      onChanged: serviceLockQty ? null : (_) => _scheduleCommitFromTyping(),
      onEditingComplete: () {
        _typingCommitDebounce?.cancel();
        if (!serviceLockQty) _commit();
      },
      onSubmitted: (_) {
        _typingCommitDebounce?.cancel();
        if (!serviceLockQty) {
          _commit();
          _focusNode.unfocus();
        }
      },
    );

    if (widget.isTablet) {
      return Expanded(
        child: SizedBox(
          height: 28,
          child: field,
        ),
      );
    }
    return SizedBox(
      height: 24,
      width: 40,
      child: field,
    );
  }
}

/// Unit price editor for price-editable services in the cart (stable [TextEditingController]).
class _EditableServiceUnitPriceRow extends StatefulWidget {
  final CartItem item;
  final bool isMainTab;
  final bool isTablet;

  const _EditableServiceUnitPriceRow({
    required this.item,
    required this.isMainTab,
    required this.isTablet,
  });

  @override
  State<_EditableServiceUnitPriceRow> createState() =>
      _EditableServiceUnitPriceRowState();
}

class _EditableServiceUnitPriceRowState extends State<_EditableServiceUnitPriceRow> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.item.effectiveUnitPrice.toStringAsFixed(2),
    );
  }

  @override
  void didUpdateWidget(covariant _EditableServiceUnitPriceRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.product.id != widget.item.product.id) {
      _controller.text = widget.item.effectiveUnitPrice.toStringAsFixed(2);
      return;
    }
    if (oldWidget.item.serviceUnitPrice != widget.item.serviceUnitPrice ||
        oldWidget.item.product.price != widget.item.product.price) {
      final next = widget.item.effectiveUnitPrice.toStringAsFixed(2);
      if (_controller.text != next) {
        _controller.text = next;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.item.quantity;
    final qtyLabel = _formatGridQuantityLabel(widget.item.product, q);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isTablet ? 9 : 6,
        vertical: widget.isTablet ? 5 : 3,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Text(
            '$qtyLabel × ',
            style: TextStyle(
              fontSize: widget.isTablet ? 13 : 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          Text(
            'SAR ',
            style: TextStyle(
              fontSize: widget.isTablet ? 12 : 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(
            width: widget.isTablet ? 76 : 64,
            child: TextField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(
                fontSize: widget.isTablet ? 13 : 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E2124),
              ),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                border: InputBorder.none,
                hintText: '0.00',
              ),
              onChanged: (v) {
                final p = double.tryParse(v.trim());
                context.read<PosViewModel>().setServiceUnitPrice(
                      widget.item.product,
                      p,
                      isMainTab: widget.isMainTab,
                    );
              },
            ),
          ),
        ],
      ),
    );
  }
}
