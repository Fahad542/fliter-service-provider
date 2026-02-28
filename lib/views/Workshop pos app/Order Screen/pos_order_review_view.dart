import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/pos_order_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../widgets/pos_widgets.dart';

// ── Mock data models used exclusively for this review screen ─────────────────

class ReviewLineItem {
  final String name;
  final String technicianName;
  final double unitPrice;
  final int qty;
  final double commissionRate; // e.g. 0.10 = 10%

  ReviewLineItem({
    required this.name,
    required this.technicianName,
    required this.unitPrice,
    required this.qty,
    this.commissionRate = 0.10,
  });

  double get lineTotal => unitPrice * qty;
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

  const PosOrderReviewView({super.key, required this.order});

  @override
  State<PosOrderReviewView> createState() => _PosOrderReviewViewState();
}

class _PosOrderReviewViewState extends State<PosOrderReviewView> {
  // Mock items derived from job count
  late final List<ReviewLineItem> _items;

  // Financial variables
  static const double _vatRate = 0.15;

  // UX state
  bool? _isCorporate; // null = not answered yet
  PaymentMethod? _selectedPayment;
  bool _isGenerated = false;
  String? _mockInvoiceNo;

  @override
  void initState() {
    super.initState();
    _items = _generateMockItems(widget.order.jobsCount);
  }

  List<ReviewLineItem> _generateMockItems(int count) {
    final names = [
      'Oil Change Service',
      'Brake Pad Replacement',
      'Air Filter Replacement',
      'Wheel Alignment',
      'Tire Rotation',
      'Battery Check & Replacement',
      'Transmission Service',
    ];
    final technicians = ['Ahmed Al-Malik', 'Khalid Hassan', 'Tariq Suleiman'];
    final prices = [120.0, 350.0, 80.0, 200.0, 150.0, 280.0, 400.0];
    final rng = Random(widget.order.id.hashCode);

    return List.generate(max(1, count), (i) {
      final idx = rng.nextInt(names.length);
      return ReviewLineItem(
        name: names[idx],
        technicianName: technicians[rng.nextInt(technicians.length)],
        unitPrice: prices[idx],
        qty: 1,
        commissionRate: 0.08 + rng.nextDouble() * 0.07,
      );
    });
  }

  double get _subtotal => _items.fold(0.0, (s, i) => s + i.lineTotal);
  double get _vatExclusive => _subtotal;
  double get _vatAmount => _subtotal * _vatRate;
  double get _total => _subtotal + _vatAmount;

  // Mock promo / discount
  double get _discountAmount => 0.0; // Hook into real promo later
  String? get _promoCode => null;

  // Commission per technician
  Map<String, double> get _commissions {
    final map = <String, double>{};
    for (final item in _items) {
      map[item.technicianName] = (map[item.technicianName] ?? 0) + item.commission;
    }
    return map;
  }

  void _generateInvoice() {
    if (_isCorporate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please indicate if this is a corporate customer.')),
      );
      return;
    }
    if (_isCorporate == false && _selectedPayment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method.')),
      );
      return;
    }

    final rng = Random();
    final invoiceNo = 'INV-${DateFormat('yyyyMMdd').format(DateTime.now())}-${1000 + rng.nextInt(9000)}';

    setState(() {
      _isGenerated = true;
      _mockInvoiceNo = invoiceNo;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final currencyFormat = NumberFormat('#,##0.00');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: PosScreenAppBar(
        title: _isGenerated ? 'Invoice Ready' : 'Final Review',
        showBackButton: !_isGenerated,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header Card ──────────────────────────────────────────────────
            _OrderHeaderCard(order: widget.order, isTablet: isTablet),
            const SizedBox(height: 16),

            if (_isGenerated) ...[
              // ── Success State ─────────────────────────────────────────────
              _GeneratedSuccessCard(invoiceNo: _mockInvoiceNo!, isTablet: isTablet),
              const SizedBox(height: 16),
              _CommissionsCard(commissions: _commissions, currencyFormat: currencyFormat, isTablet: isTablet),
              const SizedBox(height: 24),
              _PrintButton(onTap: () => _showPrintDialog()),
              const SizedBox(height: 20),
            ] else ...[
              // ── Items List ────────────────────────────────────────────────
              _SectionCard(
                title: 'Order Items',
                icon: Icons.inventory_2_rounded,
                child: Column(
                  children: _items
                      .map((item) => _ItemRow(item: item, currencyFormat: currencyFormat, isTablet: isTablet))
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),

              // ── VAT Breakdown ─────────────────────────────────────────────
              _SectionCard(
                title: 'Pricing Breakdown',
                icon: Icons.calculate_rounded,
                child: _VatBreakdownWidget(
                  subtotalExclusive: _vatExclusive,
                  vatAmount: _vatAmount,
                  vatRate: _vatRate,
                  discountAmount: _discountAmount,
                  promoCode: _promoCode,
                  total: _total - _discountAmount,
                  currencyFormat: currencyFormat,
                  isTablet: isTablet,
                ),
              ),
              const SizedBox(height: 16),

              // ── Commissions Preview ────────────────────────────────────────
              _SectionCard(
                title: 'Technician Commissions',
                icon: Icons.people_rounded,
                child: _CommissionsWidget(
                  commissions: _commissions,
                  currencyFormat: currencyFormat,
                  isTablet: isTablet,
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
                  message: 'Monthly billing — no payment collected at this time.',
                ),
                const SizedBox(height: 16),
              ],

              // ── Generate Invoice Button ───────────────────────────────────
              _GenerateInvoiceButton(onTap: _generateInvoice),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  void _showPrintDialog() {
    showDialog(
      context: context,
      builder: (context) => _MockInvoicePrintDialog(
        order: widget.order,
        items: _items,
        invoiceNo: _mockInvoiceNo!,
        total: _total - _discountAmount,
        vatAmount: _vatAmount,
        discountAmount: _discountAmount,
        isCorporate: _isCorporate ?? false,
        paymentMethod: _selectedPayment,
        commissions: _commissions,
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
  const _SectionCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 6))],
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
  const _ItemRow({required this.item, required this.currencyFormat, required this.isTablet});

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
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: isTablet ? 14 : 13, color: const Color(0xFF1E2124)),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tech: ${item.technicianName}',
                  style: TextStyle(fontSize: isTablet ? 12 : 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'SAR ${currencyFormat.format(item.lineTotal)}',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: isTablet ? 14 : 13, color: AppColors.secondaryLight),
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
  final double discountAmount;
  final String? promoCode;
  final double total;
  final NumberFormat currencyFormat;
  final bool isTablet;

  const _VatBreakdownWidget({
    required this.subtotalExclusive,
    required this.vatAmount,
    required this.vatRate,
    required this.discountAmount,
    required this.promoCode,
    required this.total,
    required this.currencyFormat,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PriceRow(label: 'Subtotal (excl. VAT)', value: 'SAR ${currencyFormat.format(subtotalExclusive)}'),
        const SizedBox(height: 8),
        _PriceRow(label: 'VAT (${(vatRate * 100).toStringAsFixed(0)}%)', value: '+ SAR ${currencyFormat.format(vatAmount)}', valueColor: Colors.orange.shade700),
        const SizedBox(height: 8),
        if (discountAmount > 0) ...[
          _PriceRow(
            label: promoCode != null ? 'Discount ($promoCode)' : 'Discount',
            value: '- SAR ${currencyFormat.format(discountAmount)}',
            valueColor: Colors.green.shade700,
          ),
          const SizedBox(height: 8),
        ],
        const Divider(height: 1, color: Color(0xFFF0F0F5)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total (incl. VAT)', style: TextStyle(fontSize: isTablet ? 16 : 14, fontWeight: FontWeight.w900, color: const Color(0xFF1E2124))),
            Text(
              'SAR ${currencyFormat.format(total)}',
              style: TextStyle(fontSize: isTablet ? 18 : 16, fontWeight: FontWeight.w900, color: AppColors.secondaryLight),
            ),
          ],
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _PriceRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: valueColor ?? const Color(0xFF1E2124))),
      ],
    );
  }
}

class _CommissionsWidget extends StatelessWidget {
  final Map<String, double> commissions;
  final NumberFormat currencyFormat;
  final bool isTablet;
  const _CommissionsWidget({required this.commissions, required this.currencyFormat, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    if (commissions.isEmpty) {
      return const Text('No technician commissions.', style: TextStyle(color: Colors.grey));
    }
    return Column(
      children: commissions.entries.map((e) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryLight.withOpacity(0.2),
              child: Text(
                e.key.substring(0, 1),
                style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.secondaryLight, fontSize: 13),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(e.key, style: TextStyle(fontWeight: FontWeight.w700, fontSize: isTablet ? 14 : 13)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'SAR ${currencyFormat.format(e.value)}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF2E7D32)),
              ),
            ),
          ],
        ),
      )).toList(),
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
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E2124)),
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
  const _ChoiceChip({required this.label, required this.icon, required this.selected, required this.onTap, required this.accentColor});

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
              Icon(icon, color: selected ? Colors.white : Colors.grey.shade400, size: 22),
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
  const _PaymentMethodSelector({required this.selected, required this.onChanged, required this.isTablet});

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
              color: isSelected ? AppColors.primaryLight : const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primaryLight : Colors.grey.shade200,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(pm.icon, size: 16, color: isSelected ? Colors.black : Colors.grey.shade400),
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
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1565C0)),
            ),
          ),
        ],
      ),
    );
  }
}

class _GenerateInvoiceButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GenerateInvoiceButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.auto_awesome_rounded, size: 18, color: Colors.black),
      label: const Text('Generate Invoice', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.black)),
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
  const _GeneratedSuccessCard({required this.invoiceNo, required this.isTablet});

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
            child: const Icon(Icons.check_rounded, color: Colors.black, size: 30),
          ),
          const SizedBox(height: 16),
          const Text('Invoice Generated & Locked', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(invoiceNo, style: TextStyle(color: AppColors.primaryLight, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
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
                Text('No further edits allowed', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
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
  const _CommissionsCard({required this.commissions, required this.currencyFormat, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Commissions Credited',
      icon: Icons.verified_rounded,
      child: _CommissionsWidget(commissions: commissions, currencyFormat: currencyFormat, isTablet: isTablet),
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
      label: const Text('Print Invoice & Receipt', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
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
                      decoration: BoxDecoration(color: AppColors.secondaryLight, shape: BoxShape.circle),
                      child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(height: 12),
                    const Text('TAX INVOICE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text(invoiceNo, style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(dateStr, style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),

              // Customer info
              _DialogRow(label: 'Customer', value: order.customerName),
              _DialogRow(label: 'Vehicle', value: order.carModel),
              _DialogRow(label: 'Plate No.', value: order.plateNumber.toUpperCase()),
              _DialogRow(label: 'Billing', value: isCorporate ? 'Corporate (Monthly)' : paymentMethod?.label ?? '—'),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              // Items
              const Text('SERVICES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: Colors.grey)),
              const SizedBox(height: 10),
              ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(item.name, style: const TextStyle(fontSize: 13))),
                    Text('SAR ${currencyFormat.format(item.lineTotal)}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  ],
                ),
              )),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              _DialogRow(label: 'Subtotal', value: 'SAR ${currencyFormat.format(total - vatAmount + discountAmount)}'),
              _DialogRow(label: 'VAT (15%)', value: 'SAR ${currencyFormat.format(vatAmount)}'),
              if (discountAmount > 0)
                _DialogRow(label: 'Discount', value: '- SAR ${currencyFormat.format(discountAmount)}'),

              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.secondaryLight, borderRadius: BorderRadius.circular(14)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('TOTAL', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
                    Text('SAR ${currencyFormat.format(total)}',
                        style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // Dismiss the dialog
                    Navigator.pop(context); // Return to the Order screen
                  },
                  icon: const Icon(Icons.check_rounded, size: 18, color: Colors.black),
                  label: const Text('Done', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
