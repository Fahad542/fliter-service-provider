import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/pos_payment_method.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/toast_service.dart';

/// Optional handler to persist PAY draft to `PATCH …/payment-method` before closing.
typedef InvoicePaymentDraftPersistFn = Future<String?> Function(
  InvoicePaymentChoiceResult proposal,
);

/// Result of [showInvoicePaymentChoiceDialog].
class InvoicePaymentChoiceResult {
  final bool isCorporate;
  final Set<PaymentMethod> payments;
  /// Per-method amounts when multiple methods are selected (individual or corporate).
  final Map<PaymentMethod, double> paymentAmounts;
  /// Legacy field — always empty (Employees payment removed from cashier UI).
  final Set<String> employeeIds;

  const InvoicePaymentChoiceResult({
    required this.isCorporate,
    required this.payments,
    this.paymentAmounts = const {},
    this.employeeIds = const <String>{},
  });
}

Future<InvoicePaymentChoiceResult?> showInvoicePaymentChoiceDialog(
  BuildContext context, {
  bool? initialIsCorporate,
  Set<PaymentMethod>? initialPayments,
  Map<PaymentMethod, double>? initialPaymentAmounts,
  Set<String>? initialEmployeeIds,
  /// Order grand total for split validation; defaults to 0 if omitted (e.g. hot-reload edge cases).
  double totalAmount = 0,

  /// When set (cashier Orders flow): Save calls PATCH draft first; on failure dialog stays open.
  InvoicePaymentDraftPersistFn? persistDraftFn,

  /// When set with [persistDraftFn]: clears server draft and closes modal (caller gets `null`).
  Future<String?> Function()? clearPersistedDraftFn,
}) {
  return showDialog<InvoicePaymentChoiceResult>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (ctx) => _InvoicePaymentChoiceDialog(
      initialIsCorporate: initialIsCorporate,
      initialPayments: initialPayments,
      initialPaymentAmounts: initialPaymentAmounts,
      initialEmployeeIds: initialEmployeeIds,
      totalAmount: totalAmount,
      persistDraftFn: persistDraftFn,
      clearPersistedDraftFn: clearPersistedDraftFn,
    ),
  );
}

class _InvoicePaymentChoiceDialog extends StatefulWidget {
  final bool? initialIsCorporate;
  final Set<PaymentMethod>? initialPayments;
  final Map<PaymentMethod, double>? initialPaymentAmounts;
  /// Prefill from cashier order-summary flow when reopening dialog.
  final Set<String>? initialEmployeeIds;
  final double totalAmount;
  final InvoicePaymentDraftPersistFn? persistDraftFn;
  final Future<String?> Function()? clearPersistedDraftFn;

  const _InvoicePaymentChoiceDialog({
    this.initialIsCorporate,
    this.initialPayments,
    this.initialPaymentAmounts,
    this.initialEmployeeIds,
    this.totalAmount = 0,
    this.persistDraftFn,
    this.clearPersistedDraftFn,
  });

  @override
  State<_InvoicePaymentChoiceDialog> createState() =>
      _InvoicePaymentChoiceDialogState();
}

class _InvoicePaymentChoiceDialogState extends State<_InvoicePaymentChoiceDialog> {
  bool? _isCorporate;
  late Set<PaymentMethod> _selected;
  final Map<PaymentMethod, TextEditingController> _amountControllers = {};

  bool _draftSaving = false;
  bool _draftClearing = false;

  static const _corporateMethods = <PaymentMethod>[
    PaymentMethod.monthlyBilling,
    PaymentMethod.bankTransfer,
    PaymentMethod.cash,
    PaymentMethod.card,
    PaymentMethod.wallet,
  ];

  static const _retailDisplayOrder = <PaymentMethod>[
    PaymentMethod.cash,
    PaymentMethod.card,
    PaymentMethod.bankTransfer,
    PaymentMethod.tabby,
    PaymentMethod.tamara,
  ];

  bool get _isSplitMode => _selected.length > 1;
  double get _safeTotal => widget.totalAmount > 0 ? widget.totalAmount : 0.0;

  @override
  void initState() {
    super.initState();
    _isCorporate = widget.initialIsCorporate;
    final initial = widget.initialPayments;
    if (initial != null && initial.isNotEmpty) {
      _selected = Set<PaymentMethod>.from(initial)
        ..remove(PaymentMethod.employees);
    } else {
      _selected = {};
    }
    _syncAmountControllers(seedFromInitial: true);
  }

  @override
  void dispose() {
    for (final c in _amountControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _clearAllControllers() {
    for (final c in _amountControllers.values) {
      c.dispose();
    }
    _amountControllers.clear();
  }

  /// Changing Individual ↔ Corporate resets payment selections; confirm when there is something to lose.
  bool _shouldConfirmCustomerTypeSwitch() {
    if (_selected.isEmpty) return false;
    if (_isCorporate == true) {
      if (_selected.length > 1) return true;
      if (_selected.length == 1) {
        return _selected.single != PaymentMethod.monthlyBilling;
      }
    }
    return true;
  }

  Future<void> _onCustomerTypeTapped(bool wantCorporate) async {
    if (_isCorporate == wantCorporate) return;

    final firstPick = _isCorporate == null;
    if (!firstPick &&
        _shouldConfirmCustomerTypeSwitch() &&
        wantCorporate != _isCorporate) {
      final go = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          final maxW = min(340.0, MediaQuery.sizeOf(ctx).width - 56);
          return AlertDialog(
            constraints: BoxConstraints(maxWidth: maxW),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              'Change customer',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.secondaryLight,
                fontSize: 17,
              ),
            ),
            content: const Text(
              'Do you really want to change the customer? Your payment choices for '
              'this customer type will be cleared.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondaryLight.withValues(alpha: 0.85),
                  ),
                ),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  foregroundColor: AppColors.onPrimaryLight,
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text(
                  'Change customer',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          );
        },
      );
      if (go != true) return;
    }
    if (!mounted) return;

    setState(() {
      _clearAllControllers();
      _isCorporate = wantCorporate;
      _selected = {};
      _syncAmountControllers();
    });
  }

  void _toggleRetailMethod(PaymentMethod pm, bool isSelected) {
    final wasRetail = _isCorporate == false;
    final oldLen = wasRetail ? _selected.length : 0;
    setState(() {
      if (isSelected) {
        _selected.remove(pm);
      } else {
        _selected.add(pm);
      }
      final newLen = _isCorporate == false ? _selected.length : 0;
      final oneToMany =
          wasRetail && oldLen == 1 && newLen >= 2;
      _syncAmountControllers(fromOneToManySplit: oneToMany);
    });
  }

  void _toggleCorporateMethod(PaymentMethod pm, bool isSelected) {
    if (!_corporateMethods.contains(pm)) return;
    final wasCorp = _isCorporate == true;
    final oldLen = wasCorp ? _selected.length : 0;
    setState(() {
      if (isSelected) {
        _selected.remove(pm);
      } else {
        _selected.add(pm);
      }
      final newLen = _isCorporate == true ? _selected.length : 0;
      final oneToMany = wasCorp && oldLen == 1 && newLen >= 2;
      _syncAmountControllers(fromOneToManySplit: oneToMany);
    });
  }

  String _amountToText(double v) {
    if ((v - v.roundToDouble()).abs() < 0.0001) return v.round().toString();
    return v.toStringAsFixed(2);
  }

  void _syncAmountControllers({
    bool seedFromInitial = false,
    /// True when user goes from 1 method (total auto-filled) to 2+ — clear split fields.
    bool fromOneToManySplit = false,
  }) {
    final current = Set<PaymentMethod>.from(_amountControllers.keys);
    final desired = _isCorporate != null
        ? Set<PaymentMethod>.from(_selected)
        : <PaymentMethod>{};

    for (final removed in current.difference(desired)) {
      _amountControllers[removed]?.dispose();
      _amountControllers.remove(removed);
    }

    for (final pm in desired) {
      final existing = _amountControllers[pm];
      if (existing != null) continue;
      final initialAmount = seedFromInitial
          ? (widget.initialPaymentAmounts != null
              ? widget.initialPaymentAmounts![pm]
              : null)
          : null;
      _amountControllers[pm] = TextEditingController(
        text: initialAmount != null && initialAmount > 0
            ? _amountToText(initialAmount)
            : '',
      );
    }

    if (!_isSplitMode && _isCorporate != null && _selected.length == 1) {
      final only = _selected.first;
      _amountControllers[only]?.text = _amountToText(_safeTotal);
    }

    if (_isSplitMode && fromOneToManySplit) {
      for (final pm in _selected) {
        _amountControllers[pm]?.text = '';
      }
    }
  }

  double _parseAmount(TextEditingController c) {
    final raw = c.text.trim().replaceAll(',', '');
    if (raw.isEmpty) return 0;
    return double.tryParse(raw) ?? 0;
  }

  double get _splitSum {
    double sum = 0;
    for (final pm in _selected) {
      final c = _amountControllers[pm];
      if (c != null) sum += _parseAmount(c);
    }
    return sum;
  }

  double get _remainingAmount => _safeTotal - _splitSum;

  bool get _canSave {
    if (_isCorporate == null || _selected.isEmpty) return false;
    if (!_isSplitMode) return true;
    for (final pm in _selected) {
      final c = _amountControllers[pm];
      if (c == null || _parseAmount(c) <= 0) return false;
    }
    return _remainingAmount.abs() <= 0.05;
  }

  Widget _paymentTile(PaymentMethod pm, {required bool isCorporateMode}) {
    final isSelected = _selected.contains(pm);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isCorporateMode) {
            _toggleCorporateMethod(pm, isSelected);
          } else {
            _toggleRetailMethod(pm, isSelected);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : const Color(0xFFF8F9FC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primaryLight : const Color(0xFFE2E8F0),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.secondaryLight.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  pm.label,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color:
                        isSelected ? AppColors.secondaryLight : Colors.grey.shade600,
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: AppColors.onPrimaryLight,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paymentGrid({
    required List<PaymentMethod> methods,
    required bool isCorporateMode,
  }) {
    const spacing = 8.0;
    const cols = 3;
    final rows = <Widget>[];
    for (var i = 0; i < methods.length; i += cols) {
      final rowTiles = <Widget>[];
      for (var k = 0; k < cols; k++) {
        if (k > 0) rowTiles.add(const SizedBox(width: spacing));
        final idx = i + k;
        if (idx < methods.length) {
          rowTiles.add(
            Expanded(
              child: _paymentTile(
                methods[idx],
                isCorporateMode: isCorporateMode,
              ),
            ),
          );
        } else {
          rowTiles.add(const Expanded(child: SizedBox()));
        }
      }
      rows.add(Row(crossAxisAlignment: CrossAxisAlignment.start, children: rowTiles));
      if (i + cols < methods.length) {
        rows.add(const SizedBox(height: spacing));
      }
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
  }

  Widget _splitAmountsEditor() {
    final methods = _selected.toList();
    const spacing = 8.0;
    const cols = 3;
    final rows = <Widget>[];
    for (var i = 0; i < methods.length; i += cols) {
      final rowChildren = <Widget>[];
      for (var k = 0; k < cols; k++) {
        if (k > 0) rowChildren.add(const SizedBox(width: spacing));
        final idx = i + k;
        rowChildren.add(
          Expanded(
            child: idx < methods.length
                ? _amountField(methods[idx])
                : const SizedBox(),
          ),
        );
      }
      rows.add(Row(children: rowChildren));
      if (i + cols < methods.length) {
        rows.add(const SizedBox(height: spacing));
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Amount by payment method',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.secondaryLight,
          ),
        ),
        const SizedBox(height: 8),
        ...rows,
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: _remainingAmount.abs() <= 0.05
                ? const Color(0xFFEAF8EE)
                : const Color(0xFFFFF4E5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _remainingAmount.abs() <= 0.05
                  ? const Color(0xFFA7D7B2)
                  : const Color(0xFFF4C27A),
            ),
          ),
          child: Row(
            children: [
              Icon(
                _remainingAmount.abs() <= 0.05 ? Icons.check_circle : Icons.info_outline,
                size: 16,
                color: _remainingAmount.abs() <= 0.05
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFB26A00),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Remaining: ${_remainingAmount.toStringAsFixed(2)} SAR',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: _remainingAmount.abs() <= 0.05
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFF8B5E00),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _amountField(PaymentMethod pm) {
    final c = _amountControllers[pm]!;
    return TextFormField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
      ],
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: '${pm.label} amount',
        labelStyle: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
        ),
        floatingLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.secondaryLight,
        ),
        suffixText: 'SAR',
        suffixStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
        ),
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
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

  Map<PaymentMethod, double> _buildPaymentAmounts() {
    if (_selected.isEmpty) return const {};
    if (_selected.length == 1) {
      return {_selected.first: _safeTotal};
    }
    final out = <PaymentMethod, double>{};
    for (final pm in _selected) {
      final c = _amountControllers[pm];
      if (c != null) out[pm] = _parseAmount(c);
    }
    return out;
  }

  Future<void> _submitSaveDraft() async {
    if (!_canSave || _draftSaving || _draftClearing) return;
    final proposal = InvoicePaymentChoiceResult(
      isCorporate: _isCorporate!,
      payments: Set<PaymentMethod>.from(_selected),
      paymentAmounts: _buildPaymentAmounts(),
      employeeIds: const <String>{},
    );
    if (widget.persistDraftFn != null) {
      setState(() => _draftSaving = true);
      try {
        final err = await widget.persistDraftFn!(proposal);
        if (!mounted) return;
        setState(() => _draftSaving = false);
        if (err != null) {
          ToastService.showError(context, err);
          return;
        }
      } catch (e, st) {
        if (mounted) {
          setState(() => _draftSaving = false);
          ToastService.showError(context, e.toString());
          debugPrint('persistDraftFn: $e\n$st');
        }
        return;
      }
    }
    if (!mounted) return;
    Navigator.of(context).pop(proposal);
  }

  Future<void> _submitClearPersistedDraft() async {
    if (widget.clearPersistedDraftFn == null || _draftSaving || _draftClearing) {
      return;
    }
    setState(() => _draftClearing = true);
    try {
      final err = await widget.clearPersistedDraftFn!();
      if (!mounted) return;
      setState(() => _draftClearing = false);
      if (err != null) {
        ToastService.showError(context, err);
        return;
      }
      Navigator.of(context).pop();
    } catch (e, st) {
      if (!mounted) return;
      setState(() => _draftClearing = false);
      ToastService.showError(context, e.toString());
      debugPrint('clearPersistedDraft: $e\n$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.sizeOf(context);
    final maxW = min(560.0, mq.width - 40);
    final maxH = min(600.0, mq.height * 0.85);
    final retailMethods = _retailDisplayOrder
        .where((pm) => pm.isRetailSelectable)
        .toList();

    return Dialog(
      elevation: 10,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      backgroundColor: AppColors.surfaceLight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW, maxHeight: maxH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment method',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      color: AppColors.secondaryLight,
                    ),
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
                            onTap: () => _onCustomerTypeTapped(false),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _CustomerTypeCard(
                            label: 'Corporate',
                            icon: Icons.business_rounded,
                            selected: _isCorporate == true,
                            onTap: () => _onCustomerTypeTapped(true),
                          ),
                        ),
                      ],
                    ),
                    if (_isCorporate == null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Tap Individual or Corporate first. Then choose Cash, Card, Tabby, etc.',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                          height: 1.35,
                        ),
                      ),
                    ],
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
                                        ? 'Corporate payment (multi-select to split)'
                                        : 'Payment (multi-select to split)',
                                    style: const TextStyle(
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
                              methods: _isCorporate! ? _corporateMethods : retailMethods,
                              isCorporateMode: _isCorporate!,
                            ),
                            if (_isSplitMode) ...[
                              const SizedBox(height: 12),
                              _splitAmountsEditor(),
                            ],
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
                children: [
                  if (widget.clearPersistedDraftFn != null)
                    TextButton(
                      style: TextButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      onPressed:
                          _draftSaving || _draftClearing ? null : _submitClearPersistedDraft,
                      child: _draftClearing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              'Clear saved payment',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color:
                                    Colors.orange.shade800.withValues(alpha: 0.9),
                              ),
                            ),
                    ),
                  const Spacer(),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    onPressed:
                        (_draftSaving || _draftClearing) ? null : () => Navigator.of(context).pop(),
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
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed:
                        (_draftSaving ||
                                _draftClearing ||
                                !_canSave)
                            ? null
                            : _submitSaveDraft,
                    child: _draftSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Save',
                            style:
                                TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
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
            color: selected ? AppColors.secondaryLight : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.secondaryLight : const Color(0xFFE2E8F0),
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.secondaryLight.withValues(alpha: 0.25),
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
                color: selected ? AppColors.onSecondaryLight : Colors.grey.shade500,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color:
                      selected ? AppColors.onSecondaryLight : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
