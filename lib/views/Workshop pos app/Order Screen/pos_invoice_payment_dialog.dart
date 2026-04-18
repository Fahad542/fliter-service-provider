import 'dart:math' show min;

import 'package:flutter/material.dart';
import '../../../models/pos_payment_method.dart';
import '../../../utils/app_colors.dart';

/// Result of [showInvoicePaymentChoiceDialog].
class InvoicePaymentChoiceResult {
  final bool isCorporate;
  final Set<PaymentMethod> payments;

  const InvoicePaymentChoiceResult({
    required this.isCorporate,
    required this.payments,
  });
}

/// Dialog: corporate vs individual, then payment method(s) matching POS rules.
/// Size and typography track [WalkInInvoiceDetailsDialog] (compact).
Future<InvoicePaymentChoiceResult?> showInvoicePaymentChoiceDialog(
  BuildContext context, {
  bool? initialIsCorporate,
  Set<PaymentMethod>? initialPayments,
}) {
  return showDialog<InvoicePaymentChoiceResult>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (ctx) => _InvoicePaymentChoiceDialog(
      initialIsCorporate: initialIsCorporate,
      initialPayments: initialPayments,
    ),
  );
}

class _InvoicePaymentChoiceDialog extends StatefulWidget {
  final bool? initialIsCorporate;
  final Set<PaymentMethod>? initialPayments;

  const _InvoicePaymentChoiceDialog({
    this.initialIsCorporate,
    this.initialPayments,
  });

  @override
  State<_InvoicePaymentChoiceDialog> createState() =>
      _InvoicePaymentChoiceDialogState();
}

class _InvoicePaymentChoiceDialogState extends State<_InvoicePaymentChoiceDialog> {
  bool? _isCorporate;
  late Set<PaymentMethod> _selected;

  static const _corporateMethods = <PaymentMethod>[
    PaymentMethod.monthlyBilling,
    PaymentMethod.bankTransfer,
    PaymentMethod.cash,
    PaymentMethod.card,
    PaymentMethod.wallet,
  ];

  @override
  void initState() {
    super.initState();
    _isCorporate = widget.initialIsCorporate;
    final initial = widget.initialPayments;
    if (initial != null && initial.isNotEmpty) {
      _selected = Set<PaymentMethod>.from(initial);
    } else if (_isCorporate == true) {
      _selected = {PaymentMethod.monthlyBilling};
    } else if (_isCorporate == false) {
      _selected = {};
    } else {
      _selected = {};
    }
  }

  void _setCorporate(bool value) {
    setState(() {
      _isCorporate = value;
      if (value) {
        _selected = _selected
            .where((p) => _corporateMethods.contains(p))
            .toSet();
        if (_selected.isEmpty) {
          _selected = {PaymentMethod.monthlyBilling};
        }
      } else {
        _selected.removeWhere(
          (p) => p == PaymentMethod.monthlyBilling || p == PaymentMethod.wallet,
        );
      }
    });
  }

  bool get _canSave =>
      _isCorporate != null && _selected.isNotEmpty;

  Widget _paymentTile(PaymentMethod pm, {required bool isCorporateMode}) {
    final isSelected = _selected.contains(pm);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            if (isCorporateMode) {
              _selected = {pm};
            } else {
              if (isSelected) {
                _selected.remove(pm);
              } else {
                _selected.add(pm);
              }
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryLight.withValues(alpha: 0.55)
                : const Color(0xFFF8F9FC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryLight
                  : const Color(0xFFE2E8F0),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryLight.withValues(alpha: 0.22),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.7)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  pm.icon,
                  size: 17,
                  color: isSelected
                      ? AppColors.secondaryLight
                      : Colors.grey.shade500,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  pm.label,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color: isSelected
                        ? AppColors.secondaryLight
                        : Colors.grey.shade600,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: AppColors.secondaryLight,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Two payment options per row (matches invoice details field layout).
  Widget _paymentGrid({
    required List<PaymentMethod> methods,
    required bool isCorporateMode,
  }) {
    final rows = <Widget>[];
    for (var i = 0; i < methods.length; i += 2) {
      final a = methods[i];
      final b = i + 1 < methods.length ? methods[i + 1] : null;
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _paymentTile(a, isCorporateMode: isCorporateMode),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: b != null
                  ? _paymentTile(b, isCorporateMode: isCorporateMode)
                  : const SizedBox(),
            ),
          ],
        ),
      );
      if (i + 2 < methods.length) {
        rows.add(const SizedBox(height: 8));
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.55,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.sizeOf(context);
    final maxW = min(520.0, mq.width - 40);
    final maxH = min(520.0, mq.height * 0.78);

    final retailMethods =
        PaymentMethod.values.where((pm) => pm.isRetailSelectable).toList();

    return Dialog(
      elevation: 10,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      backgroundColor: AppColors.surfaceLight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW, maxHeight: maxH),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.payments_rounded,
                          size: 20,
                          color: AppColors.secondaryLight,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Payment method',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                            color: AppColors.secondaryLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select customer type, then choose how this invoice will be paid.',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionLabel('Customer type'),
                    Row(
                      children: [
                        Expanded(
                          child: _CustomerTypeCard(
                            label: 'Individual',
                            icon: Icons.person_outline_rounded,
                            selected: _isCorporate == false,
                            onTap: () => _setCorporate(false),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _CustomerTypeCard(
                            label: 'Corporate',
                            icon: Icons.business_rounded,
                            selected: _isCorporate == true,
                            onTap: () => _setCorporate(true),
                          ),
                        ),
                      ],
                    ),
                    if (_isCorporate != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE8ECF3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _isCorporate!
                                      ? Icons.corporate_fare_rounded
                                      : Icons.shopping_bag_outlined,
                                  size: 16,
                                  color: AppColors.secondaryLight,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _isCorporate!
                                        ? 'Corporate payment'
                                        : 'Payment (multi-select to split)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.secondaryLight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _paymentGrid(
                              methods: _isCorporate!
                                  ? _corporateMethods
                                  : retailMethods,
                              isCorporateMode: _isCorporate!,
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE8ECF3)),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondaryLight.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryLight,
                      foregroundColor: AppColors.onPrimaryLight,
                      disabledBackgroundColor: const Color(0xFFE2E8F0),
                      disabledForegroundColor: const Color(0xFF94A3B8),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 11,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _canSave
                        ? () {
                            Navigator.of(context).pop(
                              InvoicePaymentChoiceResult(
                                isCorporate: _isCorporate!,
                                payments:
                                    Set<PaymentMethod>.from(_selected),
                              ),
                            );
                          }
                        : null,
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
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

class _CustomerTypeCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CustomerTypeCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryLight.withValues(alpha: 0.45)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppColors.primaryLight
                  : const Color(0xFFE2E8F0),
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primaryLight.withValues(alpha: 0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 22,
                color: selected
                    ? AppColors.secondaryLight
                    : Colors.grey.shade500,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: selected
                      ? AppColors.secondaryLight
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
