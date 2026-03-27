import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/pos_order_model.dart';
import '../../../models/create_invoice_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/toast_service.dart';
import '../../../widgets/pos_widgets.dart';
import '../Home Screen/pos_view_model.dart' as pvm;
import 'package:provider/provider.dart';

// ── Mock data models used exclusively for this review screen ─────────────────

class ReviewLineItem {
  final String name;
  final String technicianName;
  final double unitPrice;
  final int qty;
  final double commissionRate; // e.g. 0.10 = 10%
  final String? discountType;
  final double discountValue;

  ReviewLineItem({
    required this.name,
    required this.technicianName,
    required this.unitPrice,
    required this.qty,
    this.commissionRate = 0.10,
    this.discountType,
    this.discountValue = 0.0,
  });

  double get baseTotal => unitPrice * qty;
  double get discountAmount {
    if (discountType == 'amount' || discountType == 'fixed') {
      return discountValue;
    } else if (discountType == 'percentage' || discountType == 'percent') {
      return baseTotal * (discountValue / 100);
    }
    return 0.0;
  }
  double get lineTotal => baseTotal - discountAmount;
  double get commission => lineTotal * commissionRate;
}

enum PaymentMethod { cash, card, bankTransfer, tabby, tamara }

extension PaymentMethodLabel on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.tabby:
        return 'Tabby';
      case PaymentMethod.tamara:
        return 'Tamara';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.cash:
        return Icons.money_rounded;
      case PaymentMethod.card:
        return Icons.credit_card_rounded;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance_rounded;
      case PaymentMethod.tabby:
        return Icons.splitscreen_rounded;
      case PaymentMethod.tamara:
        return Icons.shopping_bag_rounded;
    }
  }
}

// ── View ──────────────────────────────────────────────────────────────────────

class PosOrderReviewView extends StatefulWidget {
  final PosOrder order;
  final Invoice? invoice;

  const PosOrderReviewView({super.key, required this.order, this.invoice});

  @override
  State<PosOrderReviewView> createState() => _PosOrderReviewViewState();
}

class _PosOrderReviewViewState extends State<PosOrderReviewView> {
  List<ReviewLineItem> _items = [];

  // Financial variables
  static const double _vatRate = 0.15;

  // UX state
  bool? _isCorporate; // null = not answered yet
  PaymentMethod? _selectedPayment;
  bool _isGenerated = false;
  bool _isLoading = false;
  Invoice? _currentInvoice;
  bool _canExit = false;

  @override
  void initState() {
    super.initState();
    _currentInvoice = widget.invoice;
    if (_currentInvoice != null) {
      _isGenerated = true;
    }
    _buildItems();
  }

  void _buildItems() {
    if (_currentInvoice != null) {
      _items = [];
      for (var dept in _currentInvoice!.departments) {
        for (var item in dept.items) {
          _items.add(
            ReviewLineItem(
              name: item.productName,
              technicianName: dept.departmentName,
              unitPrice: item.unitPrice,
              qty: item.qty.toInt(),
              commissionRate: 0.10, // Mock commission fallback
              discountType: item.discountType,
              discountValue: item.discountValue ?? 0.0,
            ),
          );
        }
      }
      if (_items.isEmpty && _currentInvoice!.items.isNotEmpty) {
        _items = _currentInvoice!.items
            .map(
              (item) => ReviewLineItem(
                name: item.productName,
                technicianName: 'Technician',
                unitPrice: item.unitPrice,
                qty: item.qty.toInt(),
              ),
            )
            .toList();
      }
    } else if (widget.order.jobs.isNotEmpty) {
      _items = widget.order.jobs.expand((job) {
        return job.items.map((item) {
          return ReviewLineItem(
            name: item.productName,
            technicianName: job.department,
            unitPrice: item.unitPrice,
            qty: item.qty.toInt(),
            commissionRate: 0.10,
            discountType: item.discountType,
            discountValue: item.discountValue ?? 0.0,
          );
        });
      }).toList();
    } else if (widget.order.items.isNotEmpty) {
      _items = widget.order.items.map((item) {
        final priceDynamic = item['price'] ?? item['unitPrice'] ?? 0.0;
        final double price = priceDynamic is int
            ? priceDynamic.toDouble()
            : (priceDynamic as double? ?? 0.0);
        return ReviewLineItem(
          name: item['productName'] ?? item['name'] ?? 'Item',
          technicianName: widget.order.jobs.isNotEmpty
              ? widget.order.latestJob!.department
              : 'Technician',
          unitPrice: price,
          qty: item['quantity'] ?? item['qty'] ?? 1,
          commissionRate: 0.10, // Mock commission fallback
        );
      }).toList();
    } else {
      _items = [];
    }
  }

  double get _grossSubtotal =>
      _currentInvoice?.subtotal ?? _items.fold(0.0, (s, i) => s + i.baseTotal);
      
  double get _discountAmount {
    if (_currentInvoice != null && _currentInvoice!.discountAmount > 0) return _currentInvoice!.discountAmount;
    double itemDiscounts = _items.fold(0.0, (s, i) => s + i.discountAmount);
    double globalDiscount = 0.0;
    if (widget.order.totalDiscountType == 'percent') {
      double baseForGlobal = _grossSubtotal - itemDiscounts;
      globalDiscount = baseForGlobal * ((widget.order.totalDiscountValue ?? 0.0) / 100.0);
    } else {
      globalDiscount = widget.order.totalDiscountValue ?? 0.0;
    }
    
    double promoDiscount = 0.0;
    final isPromoPercent = widget.order.promoDiscountType?.toLowerCase() == 'percent' || 
                           widget.order.promoDiscountType?.toLowerCase() == 'percentage';
    
    if (isPromoPercent) {
      double baseForPromo = _grossSubtotal - itemDiscounts - globalDiscount;
      promoDiscount = baseForPromo * ((widget.order.promoDiscountValue ?? 0.0) / 100.0);
    } else {
      promoDiscount = widget.order.promoDiscountAmount != null && widget.order.promoDiscountAmount! > 0 
          ? widget.order.promoDiscountAmount! 
          : widget.order.promoDiscountValue ?? 0.0;
    }
    
    return itemDiscounts + globalDiscount + promoDiscount;
  }

  double get _netSubtotal => _grossSubtotal - _discountAmount;
  double get _vatExclusive => _grossSubtotal;
  double get _vatAmount => _currentInvoice?.vatAmount ?? _netSubtotal * _vatRate;
  double get _total => _currentInvoice?.totalAmount ?? (_netSubtotal + _vatAmount);

  String? get _promoCode => _currentInvoice?.promoCodeName ?? widget.order.promoCodeName;

  // Commission per technician
  Map<String, double> get _commissions {
    if (_currentInvoice != null) {
      final map = <String, double>{};
      for (var dept in _currentInvoice!.departments) {
        for (var comm in dept.commissions) {
          map[comm.technicianName] =
              (map[comm.technicianName] ?? 0) + comm.commissionAmount;
        }
      }
      return map;
    }

    final map = <String, double>{};
    for (final item in _items) {
      map[item.technicianName] =
          (map[item.technicianName] ?? 0) + item.commission;
    }
    return map;
  }

  void _generateInvoice() async {
    if (_isCorporate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please indicate if this is a corporate customer.'),
        ),
      );
      return;
    }
    if (_isCorporate == false && _selectedPayment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final posVm = Provider.of<pvm.PosViewModel>(context, listen: false);

      final response = await posVm.generateInvoice(
        widget.order.id,
        isCorporate: _isCorporate,
        paymentMethod: _isCorporate == true
            ? 'Corporate'
            : _selectedPayment?.label,
      );

      if (response != null && response.success) {
        setState(() {
          _isGenerated = true;
          if (response.invoice != null) {
            _currentInvoice = response.invoice;
            _buildItems();
          }
        });

        posVm.fetchOrders();
      } else {
        if (mounted)
          ToastService.showError(
            context,
            response?.message ?? 'Failed to generate invoice',
          );
      }
    } catch (e) {
      if (mounted) ToastService.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildDepartmentJobs(bool isTablet) {
    if (widget.order.jobs.isEmpty) {
      return Center(
        child: Text(
          'No departmental data found.',
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey.shade500),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.order.jobs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final job = widget.order.jobs[index];
        final hasItems = job.items.isNotEmpty;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Department Header Background Fill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.05),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade100),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.business_center_rounded,
                        size: 16,
                        color: AppColors.secondaryLight,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        job.department,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildStatusBadge(job.status),
                  ],
                ),
              ),
              // Items Body
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!hasItems)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'No items bound to this department.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                      )
                    else
                      ...job.items.map((item) {
                        final isLast = job.items.last == item;
                        return Padding(
                          padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.secondaryLight,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            "Qty: ${item.qty.toInt()}",
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.grey.shade600,
                                                  fontSize: 10,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'SAR ${item.unitPrice.toStringAsFixed(2)} / ea',
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade500,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (item.discountValue != null && item.discountValue! > 0)
                                    Text(
                                      'SAR ${(item.qty * item.unitPrice).toStringAsFixed(2)}',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: Colors.grey.shade400,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  Text(
                                    'SAR ${item.lineTotal.toStringAsFixed(2)}',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.secondaryLight,
                                    ),
                                  ),
                                  if (item.discountValue != null && item.discountValue! > 0)
                                    Text(
                                      item.discountType == 'percentage' || item.discountType == 'percent'
                                          ? '(-${item.discountValue}%)'
                                          : '(-SAR ${item.discountValue})',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: Colors.green.shade600,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 10,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),

                      // Render Technicians if any
                      if (job.technicians.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, color: Color(0xFFEEEBE6)),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.handyman_rounded,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Assigned Technicians',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...job.technicians.map(
                          (tech) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight.withOpacity(
                                      0.15,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    size: 14,
                                    color: AppColors.primaryLight,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tech.name,
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.secondaryLight,
                                        ),
                                      ),
                                      Text(
                                        tech.commissionAmount > 0 || tech.commissionPercent == 0
                                          ? 'Commission: SAR ${tech.commissionAmount.toStringAsFixed(2)}'
                                          : 'Commission: ${tech.commissionPercent.toStringAsFixed(0)}%',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: Colors.green.shade600,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Builder(
                                  builder: (context) {
                                    final s = tech.status?.toLowerCase() ?? '';
                                    Color bgColor = Colors.orange.withOpacity(0.1);
                                    Color textColor = Colors.orange.shade700;
                                    String displayText = s.isEmpty ? 'PENDING' : tech.status!.toUpperCase();

                                    if (displayText == 'ACCEPTED_BY_TECHNICIAN') {
                                      displayText = 'ACCEPTED';
                                    } else if (displayText == 'IN_PROGRESS' || displayText == 'IN PROGRESS') {
                                      displayText = 'IN PROGRESS';
                                    }

                                    if (s.contains('completed') || s.contains('accepted')) {
                                      bgColor = Colors.green.withOpacity(0.1);
                                      textColor = Colors.green.shade700;
                                    } else if (s.contains('progress')) {
                                      bgColor = Colors.purple.withOpacity(0.1);
                                      textColor = Colors.purple.shade700;
                                    }

                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: bgColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        displayText,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: textColor,
                                          fontSize: 10,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      // Render Job Breakdown
                      if (job.items.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, color: Color(0xFFEEEBE6)),
                        ),
                        Builder(
                          builder: (context) {
                            final double preItemDiscountJobTotal = job.items.fold(0.0, (sum, i) => sum + (i.qty * i.unitPrice));
                            final double postItemDiscountJobTotal = job.items.fold(0.0, (sum, i) => sum + i.lineTotal);
                            final double calculatedItemDiscountAmount = preItemDiscountJobTotal - postItemDiscountJobTotal;

                            final double jobTotal = job.totalAmount > 0 ? job.totalAmount : postItemDiscountJobTotal;
                            
                            final double jobVatAmount = job.vatAmount > 0 
                                ? job.vatAmount 
                                : jobTotal - (jobTotal / (1 + _vatRate));
                                
                            // The true Total Amount Gross (pre-global-discount AND pre-item-discount)
                            final double jobSubtotalExclusive = preItemDiscountJobTotal;

                            String? jobPromoLabel;
                            if (job.promoCodeName != null && job.promoCodeName!.isNotEmpty) {
                              jobPromoLabel = job.promoCodeName;
                            } else {
                              jobPromoLabel = widget.order.promoCodeName;
                            }

                            return _VatBreakdownWidget(
                              subtotalExclusive: jobSubtotalExclusive,
                              itemDiscountAmount: calculatedItemDiscountAmount,
                              vatAmount: jobVatAmount,
                              vatRate: _vatRate,
                              globalDiscountValue: job.totalDiscountValue,
                              globalDiscountType: job.totalDiscountType,
                              promoDiscountAmount: job.promoDiscountAmount,
                              promoDiscountValue: job.promoDiscountValue,
                              promoDiscountType: job.promoDiscountType,
                              promoCode: jobPromoLabel,
                              total: jobTotal,
                              currencyFormat: NumberFormat('#,##0.00'),
                              isTablet: isTablet,
                            );
                          },
                        ),
                      ]
                    ], // Children of the Items Body Column
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor = Colors.grey.shade200;
    Color textColor = Colors.grey.shade800;

    String lowerStatus = status.toLowerCase();
    if (lowerStatus == 'completed' || lowerStatus.contains('invoiced')) {
      bgColor = Colors.green.withOpacity(0.15);
      textColor = Colors.green.shade700;
    } else if (lowerStatus.contains('pending')) {
      bgColor = Colors.orange.withOpacity(0.15);
      textColor = Colors.orange.shade800;
    } else if (lowerStatus.contains('progress')) {
      bgColor = Colors.blue.withOpacity(0.15);
      textColor = Colors.blue.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final currencyFormat = NumberFormat('#,##0.00');

    return PopScope(
      canPop: !_isGenerated || _canExit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: PosScreenAppBar(
          title: _isGenerated ? 'Invoice Ready' : 'Final Review',
          showBackButton: !_isGenerated,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 32 : 16,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header Card ──────────────────────────────────────────────────
              _OrderHeaderCard(order: widget.order, isTablet: isTablet),
              const SizedBox(height: 16),

              if (_isGenerated) ...[
                // ── Success State ─────────────────────────────────────────────
                _GeneratedSuccessCard(
                  invoiceNo: _currentInvoice?.invoiceNo ?? 'INV-READY',
                  isTablet: isTablet,
                ),
                const SizedBox(height: 16),
                _CommissionsCard(
                  commissions: _commissions,
                  currencyFormat: currencyFormat,
                  isTablet: isTablet,
                ),
                const SizedBox(height: 24),
                _PrintButton(onTap: () => _showPrintDialog()),
                const SizedBox(height: 20),
              ] else ...[
                // ── Department Jobs List ──────────────────────────────────────
                _buildDepartmentJobs(isTablet),
                const SizedBox(height: 16),

                // ── VAT Breakdown ─────────────────────────────────────────────
                _SectionCard(
                  title: 'Order Grand Total',
                  icon: Icons.receipt_long_rounded,
                  child: Builder(
                    builder: (context) {
                      double absoluteGrandTotal = 0.0;
                      
                      if (widget.order.jobs.isEmpty) {
                        absoluteGrandTotal = _total - _discountAmount;
                      } else {
                        for (final job in widget.order.jobs) {
                          final double preItemDiscountJobTotal = job.items.fold(0.0, (sum, i) => sum + (i.qty * i.unitPrice));
                          final double postItemDiscountJobTotal = job.items.fold(0.0, (sum, i) => sum + i.lineTotal);
                          final double itemDiscountAmount = preItemDiscountJobTotal - postItemDiscountJobTotal;
                          
                          final double netSubtotal = preItemDiscountJobTotal - itemDiscountAmount;
                          
                          final double computedGlobalAmount = (job.totalDiscountType == 'percent') 
                              ? (netSubtotal * job.totalDiscountValue / 100) 
                              : job.totalDiscountValue;
                              
                          final double priceAfterGlobal = netSubtotal - computedGlobalAmount;
                          
                          final bool isJobPromoPercent = job.promoDiscountType?.toLowerCase() == 'percent' || 
                                                         job.promoDiscountType?.toLowerCase() == 'percentage';
                          final double computedPromoAmount = isJobPromoPercent
                              ? (priceAfterGlobal * job.promoDiscountValue / 100)
                              : (job.promoDiscountAmount > 0 ? job.promoDiscountAmount : job.promoDiscountValue);
                                  
                          final double priceAfterPromo = priceAfterGlobal - computedPromoAmount;
                          final double tax = priceAfterPromo * _vatRate;
                          
                          absoluteGrandTotal += (priceAfterPromo + tax);
                        }
                      }
                      
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total amount',
                              style: TextStyle(
                                fontSize: isTablet ? 16 : 14,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1E2124),
                              ),
                            ),
                            Text(
                              'SAR ${currencyFormat.format(absoluteGrandTotal)}',
                              style: TextStyle(
                                fontSize: isTablet ? 18 : 16,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF1E2124),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  ),
                ),
                const SizedBox(height: 16),

                // ── Corporate Prompt ──────────────────────────────────────────
                _SectionCard(
                  title: 'Corporate Customer?',
                  icon: Icons.business_rounded,
                  child: _CorporatePrompt(
                    isCorporate: _isCorporate,
                    onChanged: (val) => setState(() => _isCorporate = val),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Payment Method (when not corporate) ────────────────────────
                if (_isCorporate == false) ...[
                  _SectionCard(
                    title: 'Payment Method',
                    icon: Icons.payment_rounded,
                    child: _PaymentMethodSelector(
                      selected: _selectedPayment,
                      onChanged: (pm) => setState(() => _selectedPayment = pm),
                      isTablet: isTablet,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (_isCorporate == true) ...[
                  _InfoBanner(
                    icon: Icons.info_outline_rounded,
                    message:
                        'Monthly billing — no payment collected at this time.',
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Generate Invoice Button ───────────────────────────────────
                _GenerateInvoiceButton(
                  onTap: _generateInvoice,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showPrintDialog() {
    if (_currentInvoice == null) {
      ToastService.showError(context, 'Invoice could not be loaded.');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => InvoiceDialog(
        invoice: _currentInvoice!,
        requestedPaymentMethod: _isCorporate == true
            ? 'Corporate (Monthly)'
            : _selectedPayment?.label,
        onDone: () {
          setState(() {
            _canExit = true;
          });
          // Note: InvoiceDialog already calls Navigator.pop(ctx) internally before trigger onDone!
          Future.delayed(Duration.zero, () {
            if (context.mounted) Navigator.pop(context); // Exit the view
          });
        },
      ),
    );
  }
}

// ── Sub Widgets ───────────────────────────────────────────────────────────────

class _OrderHeaderCard extends StatelessWidget {
  final PosOrder order;
  final bool isTablet;
  const _OrderHeaderCard({required this.order, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.customerName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 20 : 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${order.carModel}  •  ${order.plateNumber.toUpperCase()}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: isTablet ? 13 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Order #${order.id}',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: AppColors.secondaryLight),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.secondaryLight,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F5)),
          Padding(padding: const EdgeInsets.all(20), child: child),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final ReviewLineItem item;
  final NumberFormat currencyFormat;
  final bool isTablet;
  const _ItemRow({
    required this.item,
    required this.currencyFormat,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 5, right: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: isTablet ? 14 : 13,
                    color: const Color(0xFF1E2124),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tech: ${item.technicianName}',
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'SAR ${currencyFormat.format(item.lineTotal)}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: isTablet ? 14 : 13,
                  color: AppColors.secondaryLight,
                ),
              ),
              if (item.qty > 1)
                Text(
                  'x${item.qty}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VatBreakdownWidget extends StatelessWidget {
  final double subtotalExclusive;
  final double vatAmount;
  final double vatRate;
  final double itemDiscountAmount;
  final double globalDiscountValue;
  final String? globalDiscountType;
  final double promoDiscountAmount;
  final double promoDiscountValue;
  final String? promoDiscountType;
  final String? promoCode;
  final double total;
  final NumberFormat currencyFormat;
  final bool isTablet;
  final bool showDetailedBreakdown;

  const _VatBreakdownWidget({
    required this.subtotalExclusive,
    required this.vatAmount,
    required this.vatRate,
    this.itemDiscountAmount = 0.0,
    this.globalDiscountValue = 0.0,
    this.globalDiscountType,
    this.promoDiscountAmount = 0.0,
    this.promoDiscountValue = 0.0,
    this.promoDiscountType,
    this.promoCode,
    required this.total,
    required this.currencyFormat,
    required this.isTablet,
    this.showDetailedBreakdown = true,
  });

  @override
  Widget build(BuildContext context) {
    // Math checks
    final double netSubtotal = subtotalExclusive - itemDiscountAmount;
    
    final double computedGlobalDiscountAmount = (globalDiscountType == 'percent') 
        ? (netSubtotal * globalDiscountValue / 100) 
        : globalDiscountValue;
        
    final double priceAfterGlobal = netSubtotal - computedGlobalDiscountAmount;
    
    final bool isPromoPercent = promoDiscountType?.toLowerCase() == 'percent' || 
                                promoDiscountType?.toLowerCase() == 'percentage';
    final double computedPromoAmount = isPromoPercent
        ? (priceAfterGlobal * promoDiscountValue / 100)
        : (promoDiscountAmount > 0 ? promoDiscountAmount : promoDiscountValue);
            
    final double priceAfterPromo = priceAfterGlobal - computedPromoAmount;
    
    // Calculate Native Tax and Total
    final double computedTaxAmount = priceAfterPromo * vatRate;
    final double computedTotalAmount = priceAfterPromo + computedTaxAmount;

    return Column(
      children: [
        if (showDetailedBreakdown) ...[
          _PriceRow(
            label: 'Total Amount Gross',
            value: 'SAR ${currencyFormat.format(subtotalExclusive)}',
            valueColor: const Color(0xFF1E2124),
          ),
          const SizedBox(height: 8),
          
          if (itemDiscountAmount > 0) ...[
            _PriceRow(
              label: 'Item Discounts',
              value: '-SAR ${currencyFormat.format(itemDiscountAmount)}',
              valueColor: Colors.green.shade600,
              labelColor: Colors.green.shade600,
            ),
            const SizedBox(height: 8),
          ],
          
          if (computedGlobalDiscountAmount > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Discount', style: TextStyle(fontSize: 13, color: Colors.green.shade600, fontWeight: FontWeight.w500)),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF1E2124)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        globalDiscountValue % 1 == 0 ? globalDiscountValue.toInt().toString() : globalDiscountValue.toStringAsFixed(2),
                        style: TextStyle(fontSize: 13, color: Colors.green.shade600, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        border: Border.all(color: Colors.green.shade200),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        globalDiscountType == 'percent' ? '%' : 'SAR',
                        style: TextStyle(fontSize: 13, color: Colors.green.shade700, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            _PriceRow(
              label: 'Price after discount',
              value: 'SAR ${currencyFormat.format(priceAfterGlobal)}',
            ),
            const SizedBox(height: 8),
          ],

          if (computedPromoAmount > 0) ...[
            _PriceRow(
              label: promoCode != null && promoCode!.isNotEmpty ? 'Promo Discount ($promoCode)' : 'Promo Discount',
              value: '-SAR ${currencyFormat.format(computedPromoAmount)}',
              valueColor: Colors.green.shade600,
              labelColor: Colors.green.shade600,
            ),
            const SizedBox(height: 8),
            _PriceRow(
              label: 'Price after promo',
              value: 'SAR ${currencyFormat.format(priceAfterPromo)}',
            ),
            const SizedBox(height: 8),
          ],
          
          const Divider(height: 1, color: Color(0xFFF0F0F5)),
          const SizedBox(height: 10),
          _PriceRow(
            label: 'Tax (${(vatRate * 100).toStringAsFixed(0)}%)',
            value: 'SAR ${currencyFormat.format(computedTaxAmount)}',
            valueColor: Colors.grey.shade400,
            labelColor: Colors.grey.shade400,
          ),
          const SizedBox(height: 10),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total amount',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1E2124),
                ),
              ),
              Text(
                'SAR ${currencyFormat.format(computedTotalAmount)}',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1E2124),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final Color? labelColor;
  const _PriceRow({
    required this.label, 
    required this.value, 
    this.valueColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: labelColor ?? Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: valueColor ?? const Color(0xFF1E2124),
          ),
        ),
      ],
    );
  }
}

class _CommissionsWidget extends StatelessWidget {
  final Map<String, double> commissions;
  final NumberFormat currencyFormat;
  final bool isTablet;
  const _CommissionsWidget({
    required this.commissions,
    required this.currencyFormat,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    if (commissions.isEmpty) {
      return const Text(
        'No technician commissions.',
        style: TextStyle(color: Colors.grey),
      );
    }
    return Column(
      children: commissions.entries
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                    child: Text(
                      e.key.substring(0, 1),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.secondaryLight,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      e.key,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: isTablet ? 14 : 13,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'SAR ${currencyFormat.format(e.value)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _CorporatePrompt extends StatelessWidget {
  final bool? isCorporate;
  final ValueChanged<bool?> onChanged;
  const _CorporatePrompt({required this.isCorporate, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Is this a corporate customer?',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E2124),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _ChoiceChip(
              label: 'Yes — Corporate',
              icon: Icons.business_rounded,
              selected: isCorporate == true,
              onTap: () => onChanged(true),
              accentColor: AppColors.secondaryLight,
            ),
            const SizedBox(width: 12),
            _ChoiceChip(
              label: 'No — Individual',
              icon: Icons.person_rounded,
              selected: isCorporate == false,
              onTap: () => onChanged(false),
              accentColor: AppColors.secondaryLight,
            ),
          ],
        ),
      ],
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color accentColor;
  const _ChoiceChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? accentColor : const Color(0xFFF5F6FA),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? accentColor : Colors.grey.shade200,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: selected ? Colors.white : Colors.grey.shade400,
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodSelector extends StatelessWidget {
  final PaymentMethod? selected;
  final ValueChanged<PaymentMethod?> onChanged;
  final bool isTablet;
  const _PaymentMethodSelector({
    required this.selected,
    required this.onChanged,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: PaymentMethod.values.map((pm) {
        final isSelected = selected == pm;
        return GestureDetector(
          onTap: () => onChanged(pm),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryLight
                  : const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryLight
                    : Colors.grey.shade200,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  pm.icon,
                  size: 16,
                  color: isSelected ? Colors.black : Colors.grey.shade400,
                ),
                const SizedBox(width: 8),
                Text(
                  pm.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.black : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final String message;
  const _InfoBanner({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF90CAF9)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1565C0), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1565C0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GenerateInvoiceButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;
  const _GenerateInvoiceButton({required this.onTap, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onTap,
      icon: isLoading
          ? const SizedBox.shrink()
          : const Icon(
              Icons.auto_awesome_rounded,
              size: 18,
              color: Colors.black,
            ),
      label: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.black,
              ),
            )
          : const Text(
              'Complete Order & Generate Invoice',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.black,
        elevation: 0,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class _GeneratedSuccessCard extends StatelessWidget {
  final String invoiceNo;
  final bool isTablet;
  const _GeneratedSuccessCard({
    required this.invoiceNo,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.black,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Invoice Generated & Locked',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            invoiceNo,
            style: TextStyle(
              color: AppColors.primaryLight,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.lock_rounded, size: 14, color: Colors.white70),
                SizedBox(width: 6),
                Text(
                  'No further edits allowed',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Commissions have been credited to technician accounts.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _CommissionsCard extends StatelessWidget {
  final Map<String, double> commissions;
  final NumberFormat currencyFormat;
  final bool isTablet;
  const _CommissionsCard({
    required this.commissions,
    required this.currencyFormat,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Commissions Credited',
      icon: Icons.verified_rounded,
      child: _CommissionsWidget(
        commissions: commissions,
        currencyFormat: currencyFormat,
        isTablet: isTablet,
      ),
    );
  }
}

class _PrintButton extends StatelessWidget {
  final VoidCallback onTap;
  const _PrintButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.print_rounded, size: 18),
      label: const Text(
        'Print Invoice & Receipt',
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.secondaryLight,
        side: BorderSide(color: AppColors.secondaryLight, width: 1.5),
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

// ── Mock Print Dialog ─────────────────────────────────────────────────────────

class _MockInvoicePrintDialog extends StatelessWidget {
  final PosOrder order;
  final List<ReviewLineItem> items;
  final String invoiceNo;
  final double total;
  final double vatAmount;
  final double discountAmount;
  final bool isCorporate;
  final PaymentMethod? paymentMethod;
  final Map<String, double> commissions;
  final VoidCallback onDone;

  const _MockInvoicePrintDialog({
    required this.order,
    required this.items,
    required this.invoiceNo,
    required this.total,
    required this.vatAmount,
    required this.discountAmount,
    required this.isCorporate,
    required this.paymentMethod,
    required this.commissions,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,##0.00');
    final dateStr = DateFormat('dd MMM yyyy').format(DateTime.now());

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'TAX INVOICE',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      invoiceNo,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),

              // Customer info
              _DialogRow(label: 'Customer', value: order.customerName),
              _DialogRow(label: 'Vehicle', value: order.carModel),
              _DialogRow(
                label: 'Plate No.',
                value: order.plateNumber.toUpperCase(),
              ),
              _DialogRow(
                label: 'Billing',
                value: isCorporate
                    ? 'Corporate (Monthly)'
                    : paymentMethod?.label ?? '—',
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              // Items
              const Text(
                'SERVICES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              ...(() {
                final Map<String, List<ReviewLineItem>> groupedItems = {};
                for (var item in items) {
                  final deptName =
                      item.technicianName.isEmpty ||
                          item.technicianName == 'Technician'
                      ? 'General Services'
                      : item.technicianName;
                  groupedItems.putIfAbsent(deptName, () => []).add(item);
                }

                final List<Widget> serviceWidgets = [];
                groupedItems.forEach((dept, deptItems) {
                  // Department Header
                  serviceWidgets.add(
                    Container(
                      margin: const EdgeInsets.only(bottom: 8, top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.label_important_rounded,
                            size: 14,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              dept.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.grey.shade800,
                                letterSpacing: 0.8,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                  // Department Items
                  for (var item in deptItems) {
                    serviceWidgets.add(
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 10,
                          left: 4,
                          right: 4,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${item.qty}x  ${item.name}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              'SAR ${currencyFormat.format(item.lineTotal)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  serviceWidgets.add(const SizedBox(height: 4));
                });
                return serviceWidgets;
              })(),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              _DialogRow(
                label: 'Subtotal',
                value:
                    'SAR ${currencyFormat.format(total - vatAmount + discountAmount)}',
              ),
              _DialogRow(
                label: 'VAT (15%)',
                value: 'SAR ${currencyFormat.format(vatAmount)}',
              ),
              if (discountAmount > 0)
                _DialogRow(
                  label: 'Discount',
                  value: '- SAR ${currencyFormat.format(discountAmount)}',
                ),

              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'SAR ${currencyFormat.format(total)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onDone,
                  icon: const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: Colors.black,
                  ),
                  label: const Text(
                    'Done',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogRow extends StatelessWidget {
  final String label;
  final String value;
  const _DialogRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
