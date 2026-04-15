import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/pos_order_model.dart';
import '../../../models/create_invoice_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/toast_service.dart';
import '../../../utils/pos_tablet_layout.dart';
import '../../../widgets/pos_widgets.dart';
import '../Home Screen/pos_view_model.dart' as pvm;
import 'package:provider/provider.dart';

// ── Mock data models used exclusively for this review screen ─────────────────

class ReviewLineItem {
  final String name;
  final String technicianName;
  /// VAT-inclusive catalog unit price (stored as-is for reference).
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

  static double _r2(double v) => (v * 100).roundToDouble() / 100;

  /// Unit price excluding VAT.
  double get unitPriceExclVat => _r2(unitPrice / 1.15);

  /// Gross amount before VAT (unitPriceExclVat × qty).
  double get grossBeforeVat => unitPriceExclVat * qty;

  /// Discount amount (computed on VAT-exclusive gross).
  double get discountAmount {
    if (discountType == 'amount' || discountType == 'fixed') {
      return discountValue;
    } else if (discountType == 'percentage' || discountType == 'percent') {
      return grossBeforeVat * (discountValue / 100);
    }
    return 0.0;
  }

  /// Total before VAT (after line discount).
  double get totalBeforeVat => grossBeforeVat - discountAmount;

  /// VAT on this line item.
  double get vatOnLine => totalBeforeVat * 0.15;

  /// Total with VAT.
  double get totalWithVat => totalBeforeVat + vatOnLine;

  // Backward compat aliases
  double get baseTotal => grossBeforeVat;
  double get lineTotal => totalBeforeVat;
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

// ── Walk-in invoice dialog (StatefulWidget: controllers disposed with route) ─

InputDecoration _walkInInvoiceFieldDecoration(String label, {bool optional = false}) {
  final borderRadius = BorderRadius.circular(12);
  return InputDecoration(
    labelText: optional ? '$label (optional)' : label,
    filled: true,
    fillColor: Colors.grey.shade50,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(borderRadius: borderRadius),
    enabledBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
    ),
  );
}

Widget _walkInInvoiceSectionHeader(String title, IconData icon) {
  return Row(
    children: [
      Icon(icon, size: 20, color: AppColors.secondaryLight),
      const SizedBox(width: 8),
      Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.secondaryLight,
        ),
      ),
    ],
  );
}

class _WalkInInvoiceFormResult {
  final String name;
  final String mobile;
  final String vat;
  final String vehicleNumber;
  final String vin;
  final String make;
  final String model;
  final String year;
  final String color;
  final int odometer;

  const _WalkInInvoiceFormResult({
    required this.name,
    required this.mobile,
    required this.vat,
    required this.vehicleNumber,
    required this.vin,
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.odometer,
  });
}

class _WalkInInvoiceDetailsDialog extends StatefulWidget {
  final PosOrder order;
  final pvm.PosViewModel posVm;

  const _WalkInInvoiceDetailsDialog({
    required this.order,
    required this.posVm,
  });

  @override
  State<_WalkInInvoiceDetailsDialog> createState() => _WalkInInvoiceDetailsDialogState();
}

class _WalkInInvoiceDetailsDialogState extends State<_WalkInInvoiceDetailsDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _mobileCtrl;
  late final TextEditingController _vatCtrl;
  late final TextEditingController _plateCtrl;
  late final TextEditingController _makeCtrl;
  late final TextEditingController _modelCtrl;
  late final TextEditingController _yearCtrl;
  late final TextEditingController _vinCtrl;
  late final TextEditingController _odoCtrl;
  final _formKey = GlobalKey<FormState>();

  static String _pick(String vm, String fallback) {
    final a = vm.trim();
    return a.isNotEmpty ? a : fallback.trim();
  }

  static int _parseOdometer(String s) {
    final t = s.trim().replaceAll(RegExp(r'[\s,]'), '');
    if (t.isEmpty) return 0;
    return int.tryParse(t) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    final o = widget.order;
    final c = o.customer;
    final v = o.vehicle;
    final posVm = widget.posVm;
    _nameCtrl = TextEditingController(text: _pick(posVm.customerName, c?.name ?? ''));
    _mobileCtrl = TextEditingController(text: _pick(posVm.mobile, c?.mobile ?? ''));
    _vatCtrl = TextEditingController(text: _pick(posVm.vatNumber, c?.vatNumber ?? ''));
    _plateCtrl = TextEditingController(text: _pick(posVm.vehicleNumber, v?.plateNo ?? ''));
    _makeCtrl = TextEditingController(text: _pick(posVm.make, v?.make ?? ''));
    _modelCtrl = TextEditingController(text: _pick(posVm.model, v?.model ?? ''));
    _yearCtrl = TextEditingController(text: _pick(posVm.vehicleYear, v?.year ?? ''));
    _vinCtrl = TextEditingController(text: _pick(posVm.vinNumber, v?.vin ?? ''));
    _odoCtrl = TextEditingController(
      text: posVm.odometerReading != 0
          ? '${posVm.odometerReading}'
          : (o.odometerReading != 0 ? '${o.odometerReading}' : ''),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _vatCtrl.dispose();
    _plateCtrl.dispose();
    _makeCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _vinCtrl.dispose();
    _odoCtrl.dispose();
    super.dispose();
  }

  void _close([_WalkInInvoiceFormResult? result]) {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.sizeOf(context);
    final maxW = min(440.0, mq.width - 40);
    final maxH = min(560.0, mq.height * 0.88);
    final v = widget.order.vehicle;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: AppColors.surfaceLight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW, maxHeight: maxH),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Invoice details',
                    style: AppTextStyles.h3.copyWith(color: AppColors.secondaryLight),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Confirm billing contact and vehicle before creating the invoice.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey.shade700,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _walkInInvoiceSectionHeader('Billing', Icons.person_outline_rounded),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: _walkInInvoiceFieldDecoration('Customer name'),
                        textCapitalization: TextCapitalization.words,
                        validator: (s) =>
                            (s == null || s.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _mobileCtrl,
                        decoration: _walkInInvoiceFieldDecoration('Mobile'),
                        keyboardType: TextInputType.phone,
                        validator: (s) =>
                            (s == null || s.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _vatCtrl,
                        decoration: _walkInInvoiceFieldDecoration('VAT', optional: true),
                      ),
                      const SizedBox(height: 22),
                      _walkInInvoiceSectionHeader('Vehicle', Icons.directions_car_outlined),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _plateCtrl,
                        decoration: _walkInInvoiceFieldDecoration('Plate number'),
                        textCapitalization: TextCapitalization.characters,
                        validator: (s) =>
                            (s == null || s.trim().isEmpty) ? 'Plate is required' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _makeCtrl,
                              decoration: _walkInInvoiceFieldDecoration('Make', optional: true),
                              textCapitalization: TextCapitalization.words,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _modelCtrl,
                              decoration: _walkInInvoiceFieldDecoration('Model', optional: true),
                              textCapitalization: TextCapitalization.words,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _yearCtrl,
                              decoration: _walkInInvoiceFieldDecoration('Year', optional: true),
                              keyboardType: TextInputType.number,
                              validator: (s) {
                                if (s == null || s.trim().isEmpty) return null;
                                final yi = int.tryParse(s.trim());
                                if (yi == null || yi < 1900 || yi > 2100) {
                                  return 'Invalid year';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _vinCtrl,
                              decoration: _walkInInvoiceFieldDecoration('VIN', optional: true),
                              textCapitalization: TextCapitalization.characters,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _odoCtrl,
                        decoration: _walkInInvoiceFieldDecoration('Odometer', optional: true),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _close(null),
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.secondaryLight.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryLight,
                      foregroundColor: AppColors.onPrimaryLight,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState?.validate() != true) return;
                      _close(
                        _WalkInInvoiceFormResult(
                          name: _nameCtrl.text,
                          mobile: _mobileCtrl.text,
                          vat: _vatCtrl.text,
                          vehicleNumber: _plateCtrl.text,
                          vin: _vinCtrl.text,
                          make: _makeCtrl.text,
                          model: _modelCtrl.text,
                          year: _yearCtrl.text,
                          color: _pick(widget.posVm.vehicleColor, v?.color ?? ''),
                          odometer: _parseOdometer(_odoCtrl.text),
                        ),
                      );
                    },
                    child: Text('Continue', style: AppTextStyles.button),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
  Set<PaymentMethod> _selectedPayments = {};
  bool _isGenerated = false;
  bool _isLoading = false;
  Invoice? _currentInvoice;
  bool _canExit = false;

  // Inline split payment controllers (created/disposed as _selectedPayments changes)
  final Map<PaymentMethod, TextEditingController> _splitControllers = {};

  // Inline billing + vehicle form (walk-in orders)
  final _billingFormKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _mobileCtrl;
  late final TextEditingController _vatCtrl;
  late final TextEditingController _plateCtrl;
  late final TextEditingController _makeCtrl;
  late final TextEditingController _modelCtrl;
  late final TextEditingController _yearCtrl;
  late final TextEditingController _vinCtrl;
  late final TextEditingController _odoCtrl;

  @override
  void initState() {
    super.initState();
    _currentInvoice = widget.invoice;
    if (_currentInvoice != null) {
      _isGenerated = true;
    }
    _buildItems();
    _initBillingControllers();
  }

  void _initBillingControllers() {
    final o = widget.order;
    final c = o.customer;
    final v = o.vehicle;
    final posVm = Provider.of<pvm.PosViewModel>(context, listen: false);
    _nameCtrl = TextEditingController(text: _pickField(posVm.customerName, c?.name ?? ''));
    _mobileCtrl = TextEditingController(text: _pickField(posVm.mobile, c?.mobile ?? ''));
    _vatCtrl = TextEditingController(text: _pickField(posVm.vatNumber, c?.vatNumber ?? ''));
    _plateCtrl = TextEditingController(text: _pickField(posVm.vehicleNumber, v?.plateNo ?? ''));
    _makeCtrl = TextEditingController(text: _pickField(posVm.make, v?.make ?? ''));
    _modelCtrl = TextEditingController(text: _pickField(posVm.model, v?.model ?? ''));
    _yearCtrl = TextEditingController(text: _pickField(posVm.vehicleYear, v?.year ?? ''));
    _vinCtrl = TextEditingController(text: _pickField(posVm.vinNumber, v?.vin ?? ''));
    _odoCtrl = TextEditingController(
      text: posVm.odometerReading != 0
          ? '${posVm.odometerReading}'
          : (o.odometerReading != 0 ? '${o.odometerReading}' : ''),
    );
  }

  static String _pickField(String vm, String fallback) {
    final a = vm.trim();
    return a.isNotEmpty ? a : fallback.trim();
  }

  static int _parseOdometer(String s) {
    final t = s.trim().replaceAll(RegExp(r'[\s,]'), '');
    if (t.isEmpty) return 0;
    return int.tryParse(t) ?? 0;
  }

  void _syncSplitControllers() {
    final current = Set.of(_splitControllers.keys);
    final desired = Set.of(_selectedPayments);
    for (final removed in current.difference(desired)) {
      _splitControllers[removed]!.dispose();
      _splitControllers.remove(removed);
    }
    for (final added in desired.difference(current)) {
      _splitControllers[added] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _splitControllers.values) {
      c.dispose();
    }
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _vatCtrl.dispose();
    _plateCtrl.dispose();
    _makeCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _vinCtrl.dispose();
    _odoCtrl.dispose();
    super.dispose();
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
    } else if (widget.order.jobs.any((j) => !j.isCancelledJob)) {
      _items = widget.order.jobs
          .where((j) => !j.isCancelledJob)
          .expand((job) {
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
          technicianName: widget.order.jobs.any((j) => !j.isCancelledJob)
              ? widget.order.jobs.firstWhere((j) => !j.isCancelledJob).department
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

  List<PosOrderJob> get _activeJobs =>
      widget.order.jobs.where((j) => !j.isCancelledJob).toList();

  // ── Gross Amount (Excl. VAT) ──
  // Sum of amountBeforeDiscount across active jobs — backend now stores VAT-exclusive.
  double get _grossSubtotal {
    if (_currentInvoice != null) return _currentInvoice!.subtotal;
    final fromJobs = _activeJobs.fold<double>(
      0.0,
      (s, j) => s + j.amountBeforeDiscount,
    );
    if (fromJobs > 0) return fromJobs;
    return _items.fold(0.0, (s, i) => s + i.grossBeforeVat);
  }

  // ── Item discounts (sum of per-line discounts) ──
  double get _itemDiscountsTotal =>
      _items.fold(0.0, (s, i) => s + i.discountAmount);

  // ── Invoice discount (job-level) ──
  double get _invoiceDiscountTotal {
    final active = _activeJobs;
    double total = 0;
    for (final job in active) {
      if (job.totalDiscountType == 'percent' || job.totalDiscountType == 'percentage') {
        total += job.amountAfterDiscount > 0
            ? job.amountAfterDiscount * (job.totalDiscountValue / 100)
            : 0;
      } else {
        total += job.totalDiscountValue;
      }
    }
    if (total > 0) return total;
    // Fallback to order-level
    if (widget.order.totalDiscountType == 'percent' ||
        widget.order.totalDiscountType == 'percentage') {
      final base = _grossSubtotal - _itemDiscountsTotal;
      return base * ((widget.order.totalDiscountValue ?? 0) / 100);
    }
    return widget.order.totalDiscountValue ?? 0;
  }

  // ── Promo discount ──
  double get _promoDiscountTotal {
    final fromJobs = _activeJobs.fold<double>(
      0.0,
      (s, j) => s + j.promoDiscountAmount,
    );
    if (fromJobs > 0) return fromJobs;
    return widget.order.promoDiscountAmount ?? 0;
  }

  // ── Total of all discounts (for display) ──
  double get _totalDiscountAmount {
    if (_currentInvoice != null) return _currentInvoice!.discountAmount;
    return _itemDiscountsTotal + _invoiceDiscountTotal + _promoDiscountTotal;
  }

  // ── Total Taxable Amount (after ALL discounts, before VAT) ──
  double get _netSubtotal {
    if (_currentInvoice != null) {
      return max(0, _currentInvoice!.totalAmount - _currentInvoice!.vatAmount);
    }
    final fromJobs = _activeJobs.fold<double>(
      0.0,
      (s, j) => s + j.amountAfterPromo,
    );
    if (fromJobs > 0) return fromJobs;
    return max(0, _grossSubtotal - _totalDiscountAmount);
  }

  // ── VAT 15% ──
  double get _vatAmount {
    if (_currentInvoice != null) return _currentInvoice!.vatAmount;
    final jobsVat = _activeJobs.fold<double>(0.0, (s, j) => s + j.vatAmount);
    if (jobsVat > 0) return jobsVat;
    return _netSubtotal * 0.15;
  }

  // ── Final Total (Taxable + VAT) ──
  double get _totalAmount {
    if (_currentInvoice != null) return _currentInvoice!.totalAmount;
    final fromJobs = _activeJobs.fold<double>(0.0, (s, j) => s + j.totalAmount);
    if (fromJobs > 0) return fromJobs;
    return _netSubtotal + _vatAmount;
  }

  String? get _promoCode =>
      _currentInvoice?.promoCodeName ?? widget.order.promoCodeName;

  // Build commission display entries from real invoice data
  List<_CommissionDisplayEntry> get _commissions {
    if (_currentInvoice != null && _currentInvoice!.departments.isNotEmpty) {
      final entries = <_CommissionDisplayEntry>[];
      for (final dept in _currentInvoice!.departments) {
        for (final c in dept.commissions) {
          if (c.technicianName.isNotEmpty) {
            entries.add(_CommissionDisplayEntry(
              technicianName: c.technicianName,
              departmentName: dept.departmentName,
              commissionAmount: c.commissionAmount,
              commissionPercent: c.commissionPercent,
            ));
          }
        }
      }
      if (entries.isNotEmpty) return entries;
    }

    // Fallback 1: use technician data already present in the order's jobs
    final jobEntries = <_CommissionDisplayEntry>[];
    for (final job in widget.order.jobs.where((j) => !j.isCancelledJob)) {
      for (final tech in job.technicians) {
        if (tech.name.isEmpty) continue;
        double amount = tech.commissionAmount;
        double percent = tech.commissionPercent;
        // If backend didn't return a monetary amount, compute from percent or default 10%
        if (amount <= 0) {
          final rate = percent > 0 ? percent / 100.0 : 0.10;
          amount = job.totalAmount * rate;
          if (percent <= 0) percent = 10.0;
        }
        jobEntries.add(_CommissionDisplayEntry(
          technicianName: tech.name,
          departmentName: job.department,
          commissionAmount: amount,
          commissionPercent: percent,
        ));
      }
    }
    if (jobEntries.isNotEmpty) return jobEntries;

    // Fallback 2: pure 10% estimate — no technician data at all
    if (_totalAmount <= 0) return [];
    return [
      _CommissionDisplayEntry(
        technicianName: 'Technician',
        departmentName: widget.order.jobs.any((j) => !j.isCancelledJob)
            ? widget.order.jobs.firstWhere((j) => !j.isCancelledJob).department
            : '',
        commissionAmount: _totalAmount * 0.10,
        commissionPercent: 10.0,
      )
    ];
  }

  bool _isStandardWalkInOrder(PosOrder o) {
    if ((o.corporateAccountId ?? '').trim().isNotEmpty) return false;
    final s = o.source.toLowerCase().replaceAll('-', '_');
    return s == 'walk_in';
  }

  /// Standard walk-in: confirm billing + vehicle (merged into billing PATCH before invoice).
  Future<bool> _ensureWalkInBillingContact(pvm.PosViewModel posVm) async {
    if (!_isStandardWalkInOrder(widget.order)) return true;

    final result = await showDialog<_WalkInInvoiceFormResult?>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _WalkInInvoiceDetailsDialog(
        order: widget.order,
        posVm: posVm,
      ),
    );

    if (result != null) {
      posVm.updateWalkInBillingContact(
        name: result.name,
        mobile: result.mobile,
        vat: result.vat,
        vehicleNumber: result.vehicleNumber,
        vin: result.vin,
        make: result.make,
        model: result.model,
        odometer: result.odometer,
        year: result.year,
        color: result.color,
      );
    }

    return result != null;
  }

  Future<List<Map<String, dynamic>>?> _promptForSplitAmounts() async {
    if (_selectedPayments.length == 1) {
      return [{'method': _selectedPayments.first.label, 'amount': _totalAmount}];
    }

    final controllers = <PaymentMethod, TextEditingController>{};
    for (final pm in _selectedPayments) {
      controllers[pm] = TextEditingController();
    }

    return await showDialog<List<Map<String, dynamic>>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            double currentSum = 0;
            for (final c in controllers.values) {
              currentSum += double.tryParse(c.text.trim()) ?? 0.0;
            }
            final remaining = _totalAmount - currentSum;

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: AppColors.surfaceLight,
              title: Text(
                'Split Payment',
                style: AppTextStyles.h3.copyWith(color: AppColors.secondaryLight),
              ),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Invoice Total', style: AppTextStyles.bodyMedium),
                          Text('${_totalAmount.toStringAsFixed(2)} SAR',
                              style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._selectedPayments.map((pm) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 120,
                              child: Row(
                                children: [
                                  Icon(pm.icon, size: 20, color: Colors.grey.shade600),
                                  const SizedBox(width: 8),
                                  Text(pm.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: controllers[pm],
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: _walkInInvoiceFieldDecoration('Amount (SAR)'),
                                onChanged: (_) => setDialogState(() {}),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    if (remaining.abs() > 0.05)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          remaining > 0
                              ? 'Remaining: ${remaining.toStringAsFixed(2)} SAR'
                              : 'Exceeds total by ${(remaining.abs()).toStringAsFixed(2)} SAR',
                          style: TextStyle(
                            color: remaining > 0 ? Colors.orange.shade700 : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, null),
                  child: Text('Cancel', style: AppTextStyles.button.copyWith(color: AppColors.secondaryLight)),
                ),
                FilledButton(
                  onPressed: remaining.abs() > 0.05
                      ? null
                      : () {
                          final result = <Map<String, dynamic>>[];
                          for (final pm in _selectedPayments) {
                            result.add({
                              'method': pm.label,
                              'amount': double.tryParse(controllers[pm]!.text.trim()) ?? 0.0,
                            });
                          }
                          Navigator.pop(ctx, result);
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Confirm amounts'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ── Inline Split Payment card ────────────────────────────────────────────
  Widget _buildInlineSplitPaymentCard() {
    double currentSum = 0;
    for (final c in _splitControllers.values) {
      currentSum += double.tryParse(c.text.trim()) ?? 0.0;
    }
    final remaining = _totalAmount - currentSum;

    return _SectionCard(
      title: 'Split Payment',
      icon: Icons.call_split_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Invoice Total', style: AppTextStyles.bodyMedium),
                Text(
                  '${_totalAmount.toStringAsFixed(2)} SAR',
                  style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...() {
            final methods = _selectedPayments.toList();
            final rows = <Widget>[];
            for (int i = 0; i < methods.length; i += 2) {
              final first = methods[i];
              final hasSecond = i + 1 < methods.length;
              rows.add(Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(first.icon, size: 18, color: Colors.grey.shade600),
                              const SizedBox(width: 6),
                              Text(first.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _splitControllers[first],
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: _walkInInvoiceFieldDecoration('Amount (SAR)'),
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                      ),
                    ),
                    if (hasSecond) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(methods[i + 1].icon, size: 18, color: Colors.grey.shade600),
                                const SizedBox(width: 6),
                                Text(methods[i + 1].label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _splitControllers[methods[i + 1]],
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: _walkInInvoiceFieldDecoration('Amount (SAR)'),
                              onChanged: (_) => setState(() {}),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ));
            }
            return rows;
          }(),
          if (remaining.abs() > 0.05)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                remaining > 0
                    ? 'Remaining: ${remaining.toStringAsFixed(2)} SAR'
                    : 'Exceeds total by ${remaining.abs().toStringAsFixed(2)} SAR',
                style: TextStyle(
                  color: remaining > 0 ? Colors.orange.shade700 : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Inline Billing + Vehicle form ───────────────────────────────────────
  Widget _buildInlineBillingForm() {
    return _SectionCard(
      title: 'Invoice Details',
      icon: Icons.receipt_outlined,
      child: Form(
        key: _billingFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _walkInInvoiceSectionHeader('Billing', Icons.person_outline_rounded),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameCtrl,
                    decoration: _walkInInvoiceFieldDecoration('Customer name'),
                    textCapitalization: TextCapitalization.words,
                    validator: (s) =>
                        (s == null || s.trim().isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _mobileCtrl,
                    decoration: _walkInInvoiceFieldDecoration('Mobile'),
                    keyboardType: TextInputType.phone,
                    validator: (s) =>
                        (s == null || s.trim().isEmpty) ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _vatCtrl,
              decoration: _walkInInvoiceFieldDecoration('VAT', optional: true),
            ),
            const SizedBox(height: 22),
            _walkInInvoiceSectionHeader('Vehicle', Icons.directions_car_outlined),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _plateCtrl,
                    decoration: _walkInInvoiceFieldDecoration('Plate number'),
                    textCapitalization: TextCapitalization.characters,
                    validator: (s) =>
                        (s == null || s.trim().isEmpty) ? 'Plate is required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _odoCtrl,
                    decoration: _walkInInvoiceFieldDecoration('Odometer', optional: true),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _makeCtrl,
                    decoration: _walkInInvoiceFieldDecoration('Make', optional: true),
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _modelCtrl,
                    decoration: _walkInInvoiceFieldDecoration('Model', optional: true),
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _yearCtrl,
                    decoration: _walkInInvoiceFieldDecoration('Year', optional: true),
                    keyboardType: TextInputType.number,
                    validator: (s) {
                      if (s == null || s.trim().isEmpty) return null;
                      final yi = int.tryParse(s.trim());
                      if (yi == null || yi < 1900 || yi > 2100) {
                        return 'Invalid year';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _vinCtrl,
                    decoration: _walkInInvoiceFieldDecoration('VIN', optional: true),
                    textCapitalization: TextCapitalization.characters,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _generateInvoice() async {
    // 1. Corporate decision must be made
    if (_isCorporate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please indicate if this is a corporate customer.'),
        ),
      );
      return;
    }

    // 2. Payment methods required for non-corporate
    if (_isCorporate == false && _selectedPayments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one payment method.')),
      );
      return;
    }

    // 3. Validate split amounts sum when 2+ methods selected
    List<Map<String, dynamic>>? paymentSplits;
    if (_isCorporate != true) {
      if (_selectedPayments.length == 1) {
        paymentSplits = [{'method': _selectedPayments.first.label, 'amount': _totalAmount}];
      } else {
        double splitSum = 0;
        for (final c in _splitControllers.values) {
          splitSum += double.tryParse(c.text.trim()) ?? 0.0;
        }
        if ((splitSum - _totalAmount).abs() > 0.05) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Split amounts must equal the total (${_totalAmount.toStringAsFixed(2)} SAR). Currently: ${splitSum.toStringAsFixed(2)} SAR.',
              ),
            ),
          );
          return;
        }
        paymentSplits = _selectedPayments.map((pm) {
          return {
            'method': pm.label,
            'amount': double.tryParse(_splitControllers[pm]?.text.trim() ?? '') ?? 0.0,
          };
        }).toList();
      }
    }

    // 4. Validate inline billing form for walk-in orders
    final posVm = Provider.of<pvm.PosViewModel>(context, listen: false);
    if (_isStandardWalkInOrder(widget.order)) {
      if (_billingFormKey.currentState?.validate() != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in the required invoice details.')),
        );
        return;
      }
      final v = widget.order.vehicle;
      posVm.updateWalkInBillingContact(
        name: _nameCtrl.text,
        mobile: _mobileCtrl.text,
        vat: _vatCtrl.text,
        vehicleNumber: _plateCtrl.text,
        vin: _vinCtrl.text,
        make: _makeCtrl.text,
        model: _modelCtrl.text,
        year: _yearCtrl.text,
        color: _pickField(posVm.vehicleColor, v?.color ?? ''),
        odometer: _parseOdometer(_odoCtrl.text),
      );
    }

    // 5. Submit
    try {
      setState(() => _isLoading = true);

      final response = await posVm.generateInvoice(
        widget.order.id,
        orderForBilling: widget.order,
        isCorporate: _isCorporate,
        paymentMethod: _isCorporate == true
            ? 'Corporate'
            : (paymentSplits?.length == 1 ? paymentSplits!.first['method'] : null),
        payments: _isCorporate != true && paymentSplits != null && paymentSplits.length > 1
            ? paymentSplits
            : null,
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
        if (mounted) {
          ToastService.showError(
            context,
            response?.message ?? 'Failed to generate invoice',
          );
        }
      }
    } catch (e) {
      if (mounted) ToastService.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildDepartmentJobs(bool isTablet) {
    final visibleJobs =
        widget.order.jobs.where((j) => !j.isCancelledJob).toList();
    if (visibleJobs.isEmpty) {
      return Center(
        child: Text(
          'No departmental data found.',
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey.shade500),
        ),
      );
    }
    final sortedJobs = List<PosOrderJob>.from(visibleJobs)
      ..sort((a, b) {
        final aId = int.tryParse(a.id) ?? -1;
        final bId = int.tryParse(b.id) ?? -1;
        final byNumericId = bId.compareTo(aId);
        if (byNumericId != 0) return byNumericId;
        return b.id.compareTo(a.id);
      });

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedJobs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final job = sortedJobs[index];
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.department,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Job ID: ${job.id}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w800,
                              fontSize: isTablet ? 14 : 13,
                            ),
                          ),
                        ],
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
                                          'SAR ${((item.unitPrice / 1.15 * 100).roundToDouble() / 100).toStringAsFixed(2)} / ea (Excl. VAT)',
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
                                  if (item.discountValue != null &&
                                      item.discountValue! > 0)
                                    Text(
                                      'SAR ${(item.qty * ((item.unitPrice / 1.15 * 100).roundToDouble() / 100)).toStringAsFixed(2)}',
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
                                  if (item.discountValue != null &&
                                      item.discountValue! > 0)
                                    Text(
                                      item.discountType == 'percentage' ||
                                              item.discountType == 'percent'
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
                                      tech.commissionAmount > 0 ||
                                              tech.commissionPercent == 0
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
                                  Color bgColor = Colors.orange.withOpacity(
                                    0.1,
                                  );
                                  Color textColor = Colors.orange.shade700;
                                  String displayText = s.isEmpty
                                      ? 'PENDING'
                                      : tech.status!.toUpperCase();

                                  if (displayText == 'ACCEPTED_BY_TECHNICIAN') {
                                    displayText = 'ACCEPTED';
                                  } else if (displayText == 'IN_PROGRESS' ||
                                      displayText == 'IN PROGRESS') {
                                    displayText = 'IN PROGRESS';
                                  }

                                  if (s.contains('completed') ||
                                      s.contains('accepted')) {
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
                          // Backend now provides VAT-exclusive amounts on the job.
                          final double jobSubtotalExclusive =
                              job.amountBeforeDiscount > 0
                                  ? job.amountBeforeDiscount
                                  : job.items.fold(0.0, (sum, i) {
                                      final exclVat = (i.unitPrice / 1.15 * 100).roundToDouble() / 100;
                                      return sum + exclVat * i.qty;
                                    });

                          final double postItemDiscountJobTotal =
                              job.amountAfterDiscount > 0
                                  ? job.amountAfterDiscount
                                  : job.items.fold(0.0, (sum, i) => sum + i.lineTotal);

                          final double calculatedItemDiscountAmount =
                              jobSubtotalExclusive - postItemDiscountJobTotal;

                          final double jobTotal = job.totalAmount > 0
                              ? job.totalAmount
                              : postItemDiscountJobTotal;

                          final double jobVatAmount = job.vatAmount > 0
                              ? job.vatAmount
                              : job.amountAfterPromo > 0
                                  ? job.amountAfterPromo * 0.15
                                  : jobTotal - (jobTotal / (1 + _vatRate));

                          String? jobPromoLabel =
                              (job.promoCodeName != null &&
                                  job.promoCodeName!.isNotEmpty)
                              ? job.promoCodeName
                              : null;

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
                    ],
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
          fontSize: 11,
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
          showBackButton: false,
          showHamburger: false,
        ),
        body: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: PosTabletLayout.textScaler(context),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 32 : 16,
              vertical: isTablet ? 20 : 14,
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      children: [
                        _buildTotalRow(
                          'Gross Amount (Excl. VAT)',
                          _grossSubtotal.toStringAsFixed(2),
                        ),
                        _buildTotalRow(
                          'Item Discounts',
                          '- ${_itemDiscountsTotal.toStringAsFixed(2)}',
                          isNegative: true,
                        ),
                        _buildTotalRow(
                          'Invoice Discount',
                          '- ${_invoiceDiscountTotal.toStringAsFixed(2)}',
                          isNegative: true,
                        ),
                        _buildTotalRow(
                          'Promo Discount',
                          '- ${_promoDiscountTotal.toStringAsFixed(2)}',
                          isNegative: true,
                        ),
                        _buildTotalRow(
                          'Total Taxable Amount',
                          _netSubtotal.toStringAsFixed(2),
                        ),
                        _buildTotalRow(
                          'VAT (15%)',
                          _vatAmount.toStringAsFixed(2),
                        ),
                        const Divider(height: 24, thickness: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Amount',
                              style: TextStyle(
                                fontSize: isTablet ? 18 : 16,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF1E2124),
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'SAR ${currencyFormat.format(_totalAmount)}',
                              style: TextStyle(
                                fontSize: isTablet ? 21 : 19,
                                fontWeight: FontWeight.w900,
                                color: AppColors.secondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
                    title: 'Payment Method (Select multiple if splitting)',
                    icon: Icons.payment_rounded,
                    child: _PaymentMethodSelector(
                      selected: _selectedPayments,
                      onChanged: (pms) => setState(() {
                        _selectedPayments = pms;
                        _syncSplitControllers();
                      }),
                      isTablet: isTablet,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Inline Split Payment ────────────────────────────────────
                  if (_selectedPayments.length >= 2) ...[
                    _buildInlineSplitPaymentCard(),
                    const SizedBox(height: 16),
                  ],
                ],

                if (_isCorporate == true) ...[
                  _InfoBanner(
                    icon: Icons.info_outline_rounded,
                    message:
                        'Monthly billing — no payment collected at this time.',
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Inline Billing + Vehicle Form (walk-in) ──────────────────
                if (_isStandardWalkInOrder(widget.order)) ...[
                  _buildInlineBillingForm(),
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
            : (_selectedPayments.length > 1 ? 'Split (${_selectedPayments.map((p) => p.label).join(' + ')})' : _selectedPayments.firstOrNull?.label),
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

  Widget _buildTotalRow(
    String label,
    String value, {
    bool isNegative = false,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w500,
              color: isBold ? const Color(0xFF1E2124) : Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 17 : 15,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
              color: isNegative
                  ? Colors.red.shade700
                  : (isBold
                        ? AppColors.secondaryLight
                        : const Color(0xFF1E2124)),
            ),
          ),
        ],
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
                  order.plateNumber.isNotEmpty
                      ? order.plateNumber.toUpperCase()
                      : '—',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 21 : 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  () {
                    final m = order.carModel.trim();
                    final c = order.customerName;
                    if (c != 'Unknown' && c.isNotEmpty) {
                      return m.isEmpty ? c : '$c  •  $m';
                    }
                    return m.isEmpty ? 'Walk-in' : m;
                  }(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: isTablet ? 14 : 13,
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
                fontSize: 13,
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
                    fontSize: 15,
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
    final fs = isTablet ? 12.0 : 11.0;
    final labelStyle = TextStyle(fontSize: fs, color: Colors.grey.shade500);
    final valStyle = TextStyle(fontSize: fs, fontWeight: FontWeight.w600, color: const Color(0xFF1E2124));

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8, height: 8,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
              ),
              Expanded(
                child: Text(
                  item.name,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: isTablet ? 15 : 14, color: const Color(0xFF1E2124)),
                ),
              ),
              Text(
                'SAR ${currencyFormat.format(item.totalWithVat)}',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: isTablet ? 15 : 14, color: AppColors.secondaryLight),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 18, top: 4),
            child: Column(
              children: [
                Row(children: [
                  Expanded(child: Text('Unit (Excl. VAT)', style: labelStyle)),
                  Text('SAR ${item.unitPriceExclVat.toStringAsFixed(2)}', style: valStyle),
                ]),
                const SizedBox(height: 2),
                Row(children: [
                  Expanded(child: Text('Qty', style: labelStyle)),
                  Text('${item.qty}', style: valStyle),
                ]),
                const SizedBox(height: 2),
                Row(children: [
                  Expanded(child: Text('Gross Before VAT', style: labelStyle)),
                  Text('SAR ${item.grossBeforeVat.toStringAsFixed(2)}', style: valStyle),
                ]),
                if (item.discountAmount > 0) ...[
                  const SizedBox(height: 2),
                  Row(children: [
                    Expanded(child: Text('Discount', style: labelStyle)),
                    Text('- SAR ${item.discountAmount.toStringAsFixed(2)}', style: valStyle.copyWith(color: Colors.green)),
                  ]),
                  const SizedBox(height: 2),
                  Row(children: [
                    Expanded(child: Text('Total Before VAT', style: labelStyle)),
                    Text('SAR ${item.totalBeforeVat.toStringAsFixed(2)}', style: valStyle),
                  ]),
                ],
                const SizedBox(height: 2),
                Row(children: [
                  Expanded(child: Text('VAT (15%)', style: labelStyle)),
                  Text('SAR ${item.vatOnLine.toStringAsFixed(2)}', style: valStyle),
                ]),
                if (item.technicianName.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(children: [
                    Expanded(child: Text('Tech', style: labelStyle)),
                    Text(item.technicianName, style: valStyle),
                  ]),
                ],
              ],
            ),
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

    final double computedGlobalDiscountAmount =
        (globalDiscountType == 'percent')
        ? (netSubtotal * globalDiscountValue / 100)
        : globalDiscountValue;

    final double priceAfterGlobal = netSubtotal - computedGlobalDiscountAmount;

    final bool isPromoPercent =
        promoDiscountType?.toLowerCase() == 'percent' ||
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
            label: 'Gross Amount (Excl. VAT)',
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
                Text(
                  'Discount',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.green.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF1E2124)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        globalDiscountValue % 1 == 0
                            ? globalDiscountValue.toInt().toString()
                            : globalDiscountValue.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.green.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        border: Border.all(color: Colors.green.shade200),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        globalDiscountType == 'percent' ? '%' : 'SAR',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
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
              label: promoCode != null && promoCode!.isNotEmpty
                  ? 'Promo Discount ($promoCode)'
                  : 'Promo Discount',
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
                  fontSize: isTablet ? 17 : 15,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1E2124),
                ),
              ),
              Text(
                'SAR ${currencyFormat.format(computedTotalAmount)}',
                style: TextStyle(
                  fontSize: isTablet ? 19 : 17,
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
            fontSize: 14,
            color: labelColor ?? Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: valueColor ?? const Color(0xFF1E2124),
          ),
        ),
      ],
    );
  }
}

class _CommissionDisplayEntry {
  final String technicianName;
  final String departmentName;
  final double commissionAmount;
  final double commissionPercent;

  const _CommissionDisplayEntry({
    required this.technicianName,
    required this.departmentName,
    required this.commissionAmount,
    required this.commissionPercent,
  });
}

class _CommissionsWidget extends StatelessWidget {
  final List<_CommissionDisplayEntry> commissions;
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
      children: commissions.map((e) {
        final initial = e.technicianName.isNotEmpty
            ? e.technicianName[0].toUpperCase()
            : '?';
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.secondaryLight,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.technicianName,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: isTablet ? 14 : 13,
                      ),
                    ),
                    if (e.departmentName.isNotEmpty)
                      Text(
                        e.departmentName,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: isTablet ? 12 : 11,
                        ),
                      ),
                  ],
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
                  'SAR ${currencyFormat.format(e.commissionAmount)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
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
  final Set<PaymentMethod> selected;
  final ValueChanged<Set<PaymentMethod>> onChanged;
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
        final isSelected = selected.contains(pm);
        return GestureDetector(
          onTap: () {
            final newSelection = Set.of(selected);
            if (isSelected) {
              newSelection.remove(pm);
            } else {
              newSelection.add(pm);
            }
            onChanged(newSelection);
          },
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
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: isTablet ? 56 : 44,
            height: isTablet ? 56 : 44,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              color: Colors.black,
              size: isTablet ? 30 : 22,
            ),
          ),
          SizedBox(height: isTablet ? 16 : 10),
          Text(
            'Invoice Generated & Locked',
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 18 : 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: isTablet ? 6 : 4),
          Text(
            invoiceNo,
            style: TextStyle(
              color: AppColors.primaryLight,
              fontSize: isTablet ? 14 : 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: isTablet ? 14 : 10),
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
  final List<_CommissionDisplayEntry> commissions;
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
  final List<_CommissionDisplayEntry> commissions;
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

              // Customer / vehicle (plate prominent)
              _DialogRow(
                label: 'Vehicle no.',
                value: order.plateNumber.isNotEmpty
                    ? order.plateNumber.toUpperCase()
                    : '—',
              ),
              _DialogRow(label: 'Customer', value: order.customerName),
              _DialogRow(label: 'Vehicle', value: order.carModel),
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
