import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/pos_repository.dart';
import '../../../models/cashier_expense_models.dart';
import '../../../models/pos_payment_method.dart';
import '../../../services/session_service.dart';
import '../../../utils/app_colors.dart';
import '../../../l10n/app_localizations.dart';

/// Result of [showInvoicePaymentChoiceDialog].
class InvoicePaymentChoiceResult {
  final bool isCorporate;
  final Set<PaymentMethod> payments;
  /// Per-method amounts when multiple methods are selected (individual or corporate).
  final Map<PaymentMethod, double> paymentAmounts;
  /// Branch employee IDs when [PaymentMethod.employees] is selected.
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

  const _InvoicePaymentChoiceDialog({
    this.initialIsCorporate,
    this.initialPayments,
    this.initialPaymentAmounts,
    this.initialEmployeeIds,
    this.totalAmount = 0,
  });

  @override
  State<_InvoicePaymentChoiceDialog> createState() =>
      _InvoicePaymentChoiceDialogState();
}

class _InvoicePaymentChoiceDialogState extends State<_InvoicePaymentChoiceDialog> {
  bool? _isCorporate;
  late Set<PaymentMethod> _selected;
  final Map<PaymentMethod, TextEditingController> _amountControllers = {};

  static const _corporateMethods = <PaymentMethod>[
    PaymentMethod.monthlyBilling,
    PaymentMethod.bankTransfer,
    PaymentMethod.cash,
    PaymentMethod.card,
    PaymentMethod.wallet,
  ];

  /// Retail methods shown left-to-right, top-to-bottom — [employees] sits early so it is visible without scrolling.
  static const _retailDisplayOrder = <PaymentMethod>[
    PaymentMethod.cash,
    PaymentMethod.card,
    PaymentMethod.bankTransfer,
    PaymentMethod.employees,
    PaymentMethod.tabby,
    PaymentMethod.tamara,
  ];

  List<BranchEmployee> _branchEmployees = [];
  bool _branchEmployeesLoading = false;
  bool _branchEmployeesLoadFailed = false;
  String? _selectedEmployeeId;

  bool get _isSplitMode => _selected.length > 1;
  double get _safeTotal => widget.totalAmount > 0 ? widget.totalAmount : 0.0;

  bool get _employeesPaymentNeedsStaff =>
      _isCorporate == false &&
      _selected.contains(PaymentMethod.employees);

  @override
  void initState() {
    super.initState();
    _isCorporate = widget.initialIsCorporate;
    final initial = widget.initialPayments;
    if (initial != null && initial.isNotEmpty) {
      _selected = Set<PaymentMethod>.from(initial);
    } else if (_isCorporate == true) {
      _selected = {PaymentMethod.monthlyBilling};
    } else {
      _selected = {};
    }
    if (widget.initialEmployeeIds != null &&
        widget.initialEmployeeIds!.isNotEmpty) {
      _selectedEmployeeId = widget.initialEmployeeIds!.first;
    }
    _syncAmountControllers(seedFromInitial: true);
    if (_employeesPaymentNeedsStaff) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _ensureBranchEmployeesLoaded());
    }
  }

  Future<void> _ensureBranchEmployeesLoaded() async {
    if (_branchEmployees.isNotEmpty || _branchEmployeesLoading) return;
    setState(() {
      _branchEmployeesLoading = true;
      _branchEmployeesLoadFailed = false;
    });
    try {
      final session = Provider.of<SessionService>(context, listen: false);
      final repo = Provider.of<PosRepository>(context, listen: false);
      final token = await session.getToken(role: 'cashier');
      if (!mounted) return;
      if (token == null) throw Exception('Session');
      final res = await repo.getCashierEmployees(token);
      if (!mounted) return;
      setState(() {
        _branchEmployees = res.employees;
        _branchEmployeesLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _branchEmployeesLoading = false;
        _branchEmployeesLoadFailed = true;
      });
    }
  }

  @override
  void dispose() {
    for (final c in _amountControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _setCorporate(bool value) {
    setState(() {
      _isCorporate = value;
      if (value) {
        _selectedEmployeeId = null;
        _selected = _selected.where((p) => _corporateMethods.contains(p)).toSet();
        if (_selected.isEmpty) {
          _selected = {PaymentMethod.monthlyBilling};
        }
      } else {
        _selected.removeWhere(
          (p) => p == PaymentMethod.monthlyBilling || p == PaymentMethod.wallet,
        );
      }
      _syncAmountControllers();
    });
  }

  void _toggleRetailMethod(PaymentMethod pm, bool isSelected) {
    final wasRetail = _isCorporate == false;
    final oldLen = wasRetail ? _selected.length : 0;
    setState(() {
      if (isSelected) {
        _selected.remove(pm);
        if (pm == PaymentMethod.employees) {
          _selectedEmployeeId = null;
        }
      } else {
        _selected.add(pm);
        if (pm == PaymentMethod.employees) {
          _ensureBranchEmployeesLoaded();
        }
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
    if (_employeesPaymentNeedsStaff &&
        (_selectedEmployeeId == null || _selectedEmployeeId!.isEmpty)) {
      return false;
    }
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
            color: isSelected
                ? AppColors.primaryLight.withValues(alpha: 0.55)
                : const Color(0xFFF8F9FC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primaryLight : const Color(0xFFE2E8F0),
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
                  color: isSelected ? Colors.white.withValues(alpha: 0.7) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  pm.icon,
                  size: 17,
                  color: isSelected ? AppColors.secondaryLight : Colors.grey.shade500,
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
                    color: isSelected ? AppColors.secondaryLight : Colors.grey.shade600,
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
            Expanded(child: _paymentTile(a, isCorporateMode: isCorporateMode)),
            const SizedBox(width: 8),
            Expanded(
              child: b != null
                  ? _paymentTile(b, isCorporateMode: isCorporateMode)
                  : const SizedBox(),
            ),
          ],
        ),
      );
      if (i + 2 < methods.length) rows.add(const SizedBox(height: 8));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
  }

  Widget _splitAmountsEditor() {
    final methods = _selected.toList();
    final rows = <Widget>[];
    for (var i = 0; i < methods.length; i += 2) {
      final a = methods[i];
      final b = i + 1 < methods.length ? methods[i + 1] : null;
      rows.add(
        Row(
          children: [
            Expanded(child: _amountField(a)),
            const SizedBox(width: 8),
            Expanded(child: b != null ? _amountField(b) : const SizedBox()),
          ],
        ),
      );
      if (i + 2 < methods.length) rows.add(const SizedBox(height: 8));
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
                  'Remaining: \${_remainingAmount.toStringAsFixed(2)} \${AppLocalizations.of(context)!.currencySymbol}',
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
        suffixText: AppLocalizations.of(context)!.currencySymbol,
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

  Widget _buildEmployeesPicker() {
    if (_branchEmployeesLoading && _branchEmployees.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_branchEmployeesLoadFailed && _branchEmployees.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Could not load employees.',
              style: TextStyle(fontSize: 11.5, color: Colors.red.shade700, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _branchEmployees.clear();
                  _branchEmployeesLoadFailed = false;
                });
                _ensureBranchEmployeesLoaded();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (_branchEmployees.isEmpty) {
      return Text(
        'No branch employees listed.',
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      );
    }

    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: _branchEmployees.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final e = _branchEmployees[i];
          final name = e.name.trim().isNotEmpty ? e.name.trim() : e.id;
          final typeLabel = e.employeeTypeDisplay;
          final selected = _selectedEmployeeId == e.id;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedEmployeeId = selected ? null : e.id;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 138,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primaryLight.withValues(alpha: 0.5)
                      : const Color(0xFFF8F9FC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? AppColors.primaryLight : const Color(0xFFE2E8F0),
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          selected ? Icons.radio_button_checked : Icons.radio_button_off,
                          size: 16,
                          color: selected ? AppColors.secondaryLight : Colors.grey.shade400,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: selected ? AppColors.secondaryLight : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      typeLabel.isNotEmpty ? typeLabel : '—',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: typeLabel.isNotEmpty
                            ? Colors.grey.shade600
                            : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.sizeOf(context);
    final maxW = _isSplitMode ? min(760.0, mq.width - 32) : min(520.0, mq.width - 40);
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
                          style: const TextStyle(
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
                    if (_isCorporate == null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Tap Individual or Corporate first. Then choose Cash, Card, Employees, etc.',
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
                            if (_employeesPaymentNeedsStaff) ...[
                              const SizedBox(height: 14),
                              _sectionLabel('Employees'),
                              Text(
                                'Select one employee for Employees payment (name & type). Tap again to clear.',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 6),
                              _buildEmployeesPicker(),
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
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _canSave
                        ? () {
                            Navigator.of(context).pop(
                              InvoicePaymentChoiceResult(
                                isCorporate: _isCorporate!,
                                payments: Set<PaymentMethod>.from(_selected),
                                paymentAmounts: _buildPaymentAmounts(),
                                employeeIds:
                                    _selectedEmployeeId != null &&
                                            _selectedEmployeeId!.isNotEmpty
                                        ? {_selectedEmployeeId!}
                                        : <String>{},
                              ),
                            );
                          }
                        : null,
                    child: const Text(
                      'Save',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
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
            color: selected ? AppColors.primaryLight.withValues(alpha: 0.45) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primaryLight : const Color(0xFFE2E8F0),
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
                color: selected ? AppColors.secondaryLight : Colors.grey.shade500,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: selected ? AppColors.secondaryLight : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
