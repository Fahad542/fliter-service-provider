import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/pos_order_model.dart';
import '../../../models/pos_payment_method.dart';
import '../../../models/create_invoice_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/toast_service.dart';
import '../../../utils/pos_tablet_layout.dart';
import '../../../widgets/pos_widgets.dart';
import '../Home Screen/pos_view_model.dart' as pvm;
import 'package:provider/provider.dart';
import '../../../data/repositories/pos_repository.dart';
import '../../../models/cashier_expense_models.dart';
import '../../../services/session_service.dart';
import '../../../services/localized_api_text.dart';

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

// ── Walk-in invoice dialog (StatefulWidget: controllers disposed with route) ─

const TextStyle _kWalkInInvoiceDialogFieldStyle =
TextStyle(fontSize: 13, fontWeight: FontWeight.w500);

InputDecoration _walkInInvoiceFieldDecoration(
    String label, {
      bool optional = false,
      bool compact = false,
    }) {
  final borderRadius = BorderRadius.circular(compact ? 10 : 12);
  final baseLabel = TextStyle(
    fontSize: compact ? 11.5 : null,
    fontWeight: FontWeight.w600,
    color: Colors.grey.shade700,
  );
  return InputDecoration(
    labelText: optional ? '$label (optional)' : label,
    labelStyle: compact ? baseLabel : null,
    floatingLabelStyle: compact
        ? baseLabel.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: AppColors.secondaryLight,
    )
        : null,
    filled: true,
    fillColor: Colors.grey.shade50,
    isDense: true,
    contentPadding: EdgeInsets.symmetric(
      horizontal: compact ? 12 : 16,
      vertical: compact ? 10 : 14,
    ),
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

Widget _walkInInvoiceSectionHeader(
    String title,
    IconData icon, {
      bool compact = false,
    }) {
  return Row(
    children: [
      Icon(
        icon,
        size: compact ? 17 : 20,
        color: AppColors.secondaryLight,
      ),
      const SizedBox(width: 6),
      Text(
        title,
        style: compact
            ? TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w800,
          color: AppColors.secondaryLight,
        )
            : AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.secondaryLight,
        ),
      ),
    ],
  );
}

class WalkInInvoiceFormResult {
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

  const WalkInInvoiceFormResult({
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

class WalkInInvoiceDetailsDialog extends StatefulWidget {
  /// When null (e.g. Takeaway checkout), use [standaloneInitial] to seed fields.
  final PosOrder? order;
  final pvm.PosViewModel posVm;
  final WalkInInvoiceFormResult? standaloneInitial;
  /// Takeaway only asks for customer + VAT; walk-in orders still show vehicle fields.
  final bool showVehicleSection;

  const WalkInInvoiceDetailsDialog({
    super.key,
    this.order,
    required this.posVm,
    this.standaloneInitial,
    this.showVehicleSection = true,
  }) : assert(
  order != null || standaloneInitial != null,
  'Provide order or standaloneInitial',
  );

  @override
  State<WalkInInvoiceDetailsDialog> createState() => WalkInInvoiceDetailsDialogState();
}

class WalkInInvoiceDetailsDialogState extends State<WalkInInvoiceDetailsDialog> {
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

  static int _parseOdometer(String s) {
    final t = s.trim().replaceAll(RegExp(r'[\s,]'), '');
    if (t.isEmpty) return 0;
    return int.tryParse(t) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    if (widget.order != null) {
      final o = widget.order!;
      final c = o.customer;
      final v = o.vehicle;
      final posVm = widget.posVm;
      final snap = posVm.walkInBillingSnapshotForOrder(o.id);
      // Billing contact + plate: snapshot wins when set (user draft for this order).
      // Optional vehicle fields (make, model, year, VIN, odometer): always from [o] only —
      // snapshot previously mirrored stale PosViewModel data and showed wrong prefills.
      if (snap != null) {
        _nameCtrl = TextEditingController(
          text: snap.name.trim().isNotEmpty ? snap.name : (c?.name ?? '').trim(),
        );
        _mobileCtrl = TextEditingController(
          text: snap.mobile.trim().isNotEmpty ? snap.mobile : (c?.mobile ?? '').trim(),
        );
        _vatCtrl = TextEditingController(
          text: snap.vat.trim().isNotEmpty ? snap.vat : (c?.vatNumber ?? '').trim(),
        );
        _plateCtrl = TextEditingController(
          text: snap.vehicleNumber.trim().isNotEmpty
              ? snap.vehicleNumber
              : (v?.plateNo ?? '').trim(),
        );
      } else {
        _nameCtrl = TextEditingController(text: (c?.name ?? '').trim());
        _mobileCtrl = TextEditingController(text: (c?.mobile ?? '').trim());
        _vatCtrl = TextEditingController(text: (c?.vatNumber ?? '').trim());
        _plateCtrl = TextEditingController(text: (v?.plateNo ?? '').trim());
      }
      _makeCtrl = TextEditingController(text: (v?.make ?? '').trim());
      _modelCtrl = TextEditingController(text: (v?.model ?? '').trim());
      _yearCtrl = TextEditingController(text: (v?.year ?? '').trim());
      _vinCtrl = TextEditingController(text: (v?.vin ?? '').trim());
      final suggestedOdo = posVm.suggestedOdometerForOrder(o);
      _odoCtrl = TextEditingController(
        text: suggestedOdo != 0 ? '$suggestedOdo' : '',
      );
    } else {
      final d = widget.standaloneInitial!;
      _nameCtrl = TextEditingController(text: d.name);
      _mobileCtrl = TextEditingController(text: d.mobile);
      _vatCtrl = TextEditingController(text: d.vat);
      _plateCtrl = TextEditingController(text: d.vehicleNumber);
      _makeCtrl = TextEditingController(text: d.make);
      _modelCtrl = TextEditingController(text: d.model);
      _yearCtrl = TextEditingController(text: d.year);
      _vinCtrl = TextEditingController(text: d.vin);
      _odoCtrl = TextEditingController(
        text: d.odometer != 0 ? '${d.odometer}' : '',
      );
    }
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

  void _close([WalkInInvoiceFormResult? result]) {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    // Lock billing only for corporate **walk-in** approval flow, not corporate bookings.
    final isCorporateLocked = widget.order != null &&
        widget.order!.isCorporateWalkIn &&
        !widget.order!.isCorporateBookingOrder;
    final vehicleFieldsLocked = false;
    final mq = MediaQuery.sizeOf(context);
    // Compact card; same max-width formula as payment dialog.
    final maxW = min(520.0, mq.width - 40);
    final maxH = min(520.0, mq.height * 0.78);
    final formScroll = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      //shrinkWrap: !widget.showVehicleSection,
      physics: widget.showVehicleSection
          ? null
          : const ClampingScrollPhysics(),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _walkInInvoiceSectionHeader(
              AppLocalizations.of(context)!.posReviewBilling,
              Icons.person_outline_rounded,
              compact: true,
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameCtrl,
                    readOnly: isCorporateLocked,
                    style: _kWalkInInvoiceDialogFieldStyle,
                    decoration: _walkInInvoiceFieldDecoration(
                      AppLocalizations.of(context)!.posReviewCustomerNameLabel,
                      compact: true,
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (s) =>
                    isCorporateLocked
                        ? null
                        : (s == null || s.trim().isEmpty)
                        ? AppLocalizations.of(context)!.posReviewRequiredError
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _mobileCtrl,
                    readOnly: isCorporateLocked,
                    style: _kWalkInInvoiceDialogFieldStyle,
                    decoration: _walkInInvoiceFieldDecoration(
                      AppLocalizations.of(context)!.posReviewMobileLabel,
                      compact: true,
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (s) =>
                    isCorporateLocked
                        ? null
                        : (s == null || s.trim().isEmpty)
                        ? AppLocalizations.of(context)!.posReviewRequiredError
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _vatCtrl,
              readOnly: isCorporateLocked,
              style: _kWalkInInvoiceDialogFieldStyle,
              decoration: _walkInInvoiceFieldDecoration(
                AppLocalizations.of(context)!.posReviewVatLabel,
                optional: true,
                compact: true,
              ),
            ),
            if (widget.showVehicleSection) ...[
              const SizedBox(height: 14),
              _walkInInvoiceSectionHeader(
                AppLocalizations.of(context)!.posReviewVehicle,
                Icons.directions_car_outlined,
                compact: true,
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _plateCtrl,
                      readOnly: vehicleFieldsLocked,
                      style: _kWalkInInvoiceDialogFieldStyle,
                      decoration: _walkInInvoiceFieldDecoration(
                        AppLocalizations.of(context)!.posReviewPlateNumberLabel,
                        compact: true,
                      ),
                      textCapitalization: TextCapitalization.characters,
                      validator: (s) =>
                      (s == null || s.trim().isEmpty)
                          ? AppLocalizations.of(context)!.posReviewPlateRequiredError
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _odoCtrl,
                      readOnly: vehicleFieldsLocked,
                      style: _kWalkInInvoiceDialogFieldStyle,
                      decoration: _walkInInvoiceFieldDecoration(
                        AppLocalizations.of(context)!.posReviewOdometerLabel,
                        optional: true,
                        compact: true,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _makeCtrl,
                      readOnly: vehicleFieldsLocked,
                      style: _kWalkInInvoiceDialogFieldStyle,
                      decoration: _walkInInvoiceFieldDecoration(
                        AppLocalizations.of(context)!.posReviewMakeLabel,
                        optional: true,
                        compact: true,
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _modelCtrl,
                      readOnly: vehicleFieldsLocked,
                      style: _kWalkInInvoiceDialogFieldStyle,
                      decoration: _walkInInvoiceFieldDecoration(
                        AppLocalizations.of(context)!.posReviewModelLabel,
                        optional: true,
                        compact: true,
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _yearCtrl,
                      readOnly: vehicleFieldsLocked,
                      style: _kWalkInInvoiceDialogFieldStyle,
                      decoration: _walkInInvoiceFieldDecoration(
                        AppLocalizations.of(context)!.posReviewYearLabel,
                        optional: true,
                        compact: true,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (s) {
                        if (s == null || s.trim().isEmpty) return null;
                        final yi = int.tryParse(s.trim());
                        if (yi == null || yi < 1900 || yi > 2100) {
                          return AppLocalizations.of(context)!.posReviewInvalidYearError;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _vinCtrl,
                      readOnly: vehicleFieldsLocked,
                      style: _kWalkInInvoiceDialogFieldStyle,
                      decoration: _walkInInvoiceFieldDecoration(
                        AppLocalizations.of(context)!.posReviewVinLabel,
                        optional: true,
                        compact: true,
                      ),
                      textCapitalization: TextCapitalization.characters,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
          ],
        ),
      ),
    );
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      backgroundColor: AppColors.surfaceLight,
      child: ConstrainedBox(
        constraints: widget.showVehicleSection
            ? BoxConstraints(maxWidth: maxW, maxHeight: maxH)
            : BoxConstraints(maxWidth: maxW),
        child: Column(
          mainAxisSize: widget.showVehicleSection
              ? MainAxisSize.max
              : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.showVehicleSection
                        ? AppLocalizations.of(context)!.posReviewInvoiceDetails
                        : AppLocalizations.of(context)!.posReviewCustomerDetails,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      color: AppColors.secondaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.showVehicleSection
                        ? AppLocalizations.of(context)!.posReviewConfirmBillingAndVehicle
                        : AppLocalizations.of(context)!.posReviewConfirmBillingOnly,
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
            if (widget.showVehicleSection)
              Expanded(child: formScroll)
            else
              formScroll,
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _close(null),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    child: Builder(builder: (ctx) => Text(
                      AppLocalizations.of(ctx)!.posReviewCancelBtn,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondaryLight.withValues(alpha: 0.85),
                      ),
                    )),
                  ),
                  const SizedBox(width: 4),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryLight,
                      foregroundColor: AppColors.onPrimaryLight,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState?.validate() != true) {
                        return;
                      }
                      if (!widget.showVehicleSection) {
                        _close(
                          WalkInInvoiceFormResult(
                            name: _nameCtrl.text,
                            mobile: _mobileCtrl.text,
                            vat: _vatCtrl.text,
                            vehicleNumber: '',
                            vin: '',
                            make: '',
                            model: '',
                            year: '',
                            color: '',
                            odometer: 0,
                          ),
                        );
                        return;
                      }
                      final colorResult = widget.order != null
                          ? () {
                        final o = widget.order!;
                        final v = o.vehicle;
                        final prev = widget.posVm
                            .walkInBillingSnapshotForOrder(o.id);
                        final pc = (prev?.color ?? '').trim();
                        if (pc.isNotEmpty) return pc;
                        return (v?.color ?? '').trim();
                      }()
                          : '';
                      _close(
                        WalkInInvoiceFormResult(
                          name: _nameCtrl.text,
                          mobile: _mobileCtrl.text,
                          vat: _vatCtrl.text,
                          vehicleNumber: _plateCtrl.text,
                          vin: _vinCtrl.text,
                          make: _makeCtrl.text,
                          model: _modelCtrl.text,
                          year: _yearCtrl.text,
                          color: colorResult,
                          odometer: _parseOdometer(_odoCtrl.text),
                        ),
                      );
                    },
                    child: Builder(builder: (ctx) => Text(
                      AppLocalizations.of(ctx)!.posReviewContinueBtn,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    )),
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

  /// Branch employees for "Employees" payment (GET /cashier/employees).
  List<BranchEmployee> _branchEmployees = [];
  bool _branchEmployeesLoading = false;
  bool _branchEmployeesLoadFailed = false;
  /// Single employee for Employees payment line (`employeeIds` payload uses one id).
  String? _employeesPaymentEmployeeId;

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

  /// Tablet split-row scroll areas (Final Review) — scrollbars on tech + summary only.
  late final ScrollController _reviewTechScrollController;
  late final ScrollController _reviewSummaryScrollController;

  @override
  void initState() {
    super.initState();
    _reviewTechScrollController = ScrollController();
    _reviewSummaryScrollController = ScrollController();
    _currentInvoice = widget.invoice;
    if (_currentInvoice != null) {
      _isGenerated = true;
    }
    _buildItems();
    _initBillingControllers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final posVm = Provider.of<pvm.PosViewModel>(context, listen: false);
      if (posVm.invoicePaymentIsCorporate == null) return;
      setState(() {
        _isCorporate = posVm.invoicePaymentIsCorporate;
        _selectedPayments = Set<PaymentMethod>.from(posVm.invoicePaymentMethods);
        if (_isCorporate == true && _selectedPayments.isEmpty) {
          _selectedPayments = {PaymentMethod.monthlyBilling};
        }
        final ids = posVm.invoicePaymentEmployeeIds;
        _employeesPaymentEmployeeId =
        ids.isEmpty ? null : ids.first;
        _syncSplitControllers();
        for (final entry in posVm.invoicePaymentAmounts.entries) {
          final c = _splitControllers[entry.key];
          if (c != null && entry.value > 0) {
            c.text = entry.value.toStringAsFixed(2);
          }
        }
        if (_selectedPayments.contains(PaymentMethod.employees)) {
          _ensureBranchEmployeesLoaded();
        }
      });
    });
  }

  void _initBillingControllers() {
    final o = widget.order;
    final c = o.customer;
    final v = o.vehicle;
    final posVm = Provider.of<pvm.PosViewModel>(context, listen: false);
    final snap = posVm.walkInBillingSnapshotForOrder(o.id);
    if (snap != null) {
      _nameCtrl = TextEditingController(text: snap.name);
      _mobileCtrl = TextEditingController(text: snap.mobile);
      _vatCtrl = TextEditingController(text: snap.vat);
      _plateCtrl = TextEditingController(text: snap.vehicleNumber);
      _makeCtrl = TextEditingController(text: snap.make);
      _modelCtrl = TextEditingController(text: snap.model);
      _yearCtrl = TextEditingController(text: snap.year);
      _vinCtrl = TextEditingController(text: snap.vin);
      _odoCtrl = TextEditingController(
        text: snap.odometer != 0
            ? '${snap.odometer}'
            : (o.odometerReading != 0 ? '${o.odometerReading}' : ''),
      );
    } else {
      _nameCtrl = TextEditingController(text: (c?.name ?? '').trim());
      _mobileCtrl = TextEditingController(text: (c?.mobile ?? '').trim());
      _vatCtrl = TextEditingController(text: (c?.vatNumber ?? '').trim());
      _plateCtrl = TextEditingController(text: (v?.plateNo ?? '').trim());
      _makeCtrl = TextEditingController(text: (v?.make ?? '').trim());
      _modelCtrl = TextEditingController(text: (v?.model ?? '').trim());
      _yearCtrl = TextEditingController(text: (v?.year ?? '').trim());
      _vinCtrl = TextEditingController(text: (v?.vin ?? '').trim());
      _odoCtrl = TextEditingController(
        text: o.odometerReading != 0 ? '${o.odometerReading}' : '',
      );
    }
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

  Map<String, dynamic> _paymentSplitLine(PaymentMethod pm, double amount) {
    final m = <String, dynamic>{
      'method': pm.apiKey,
      'amount': amount,
    };
    if (pm == PaymentMethod.employees &&
        (_employeesPaymentEmployeeId ?? '').isNotEmpty) {
      m['employeeIds'] = [_employeesPaymentEmployeeId!];
    }
    return m;
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

  void _onRetailPaymentMethodsChanged(Set<PaymentMethod> pms) {
    final wantsEmployees = pms.contains(PaymentMethod.employees);
    setState(() {
      _selectedPayments = pms;
      if (!wantsEmployees) {
        _employeesPaymentEmployeeId = null;
      }
      _syncSplitControllers();
    });
    if (wantsEmployees) {
      _ensureBranchEmployeesLoaded();
    }
  }

  void _onCorporateCustomerChanged(bool? v) {
    setState(() {
      _isCorporate = v;
      _employeesPaymentEmployeeId = null;
      _branchEmployees.clear();
      _branchEmployeesLoadFailed = false;
      _branchEmployeesLoading = false;
      if (v == true) {
        _selectedPayments = {PaymentMethod.monthlyBilling};
      } else if (v == false) {
        _selectedPayments = {};
      }
    });
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
    _reviewTechScrollController.dispose();
    _reviewSummaryScrollController.dispose();
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
      final active =
      job.distinctActiveTechnicians.where((t) => t.name.isNotEmpty).toList();
      final n = active.length;
      for (final tech in active) {
        double amount = tech.commissionAmount;
        double percent = tech.commissionPercent;
        // If backend didn't return a monetary amount, estimate one pool from job total
        // and split equally across assigned technicians (2 techs → each gets pool/2).
        if (amount <= 0) {
          final rate = percent > 0 ? percent / 100.0 : 0.10;
          final pool = job.totalAmount * rate;
          amount = n > 0 ? pool / n : pool;
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
    return Provider.of<pvm.PosViewModel>(context, listen: false)
        .isStandardWalkInOrderForBilling(o);
  }

  /// Standard walk-in: confirm billing + vehicle (merged into billing PATCH before invoice).
  Future<bool> _ensureWalkInBillingContact(pvm.PosViewModel posVm) async {
    if (!_isStandardWalkInOrder(widget.order)) return true;

    final result = await showDialog<WalkInInvoiceFormResult?>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => WalkInInvoiceDetailsDialog(
        order: widget.order,
        posVm: posVm,
      ),
    );

    if (result != null) {
      posVm.updateWalkInBillingContact(
        forOrderId: widget.order.id,
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
      final patchErr = await posVm.submitWalkInOrderBillingPatch(widget.order);
      if (!mounted) return false;
      if (patchErr != null) {
        ToastService.showError(context, patchErr);
        return false;
      }
    }

    return result != null;
  }

  Future<List<Map<String, dynamic>>?> _promptForSplitAmounts() async {
    if (_selectedPayments.length == 1) {
      return [
        _paymentSplitLine(_selectedPayments.first, _totalAmount),
      ];
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
              title: Builder(builder: (bctx) => Text(
                AppLocalizations.of(bctx)!.posReviewSplitPayment,
                style: AppTextStyles.h3.copyWith(color: AppColors.secondaryLight),
              )),
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
                          Builder(builder: (ctx) => Text(AppLocalizations.of(ctx)!.posReviewInvoiceTotal, style: AppTextStyles.bodyMedium)),
                          Text('\${_totalAmount.toStringAsFixed(2)} SAR',
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
                                  Builder(builder: (ctx) => Text(pm.localizedLabel(ctx), style: const TextStyle(fontWeight: FontWeight.w600))),
                                ],
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: controllers[pm],
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: _walkInInvoiceFieldDecoration(AppLocalizations.of(context)!.posReviewAmountSar),
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
                              : 'Exceeds total by ${remaining.abs().toStringAsFixed(2)} SAR',
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
                  child: Builder(builder: (bctx) => Text(AppLocalizations.of(bctx)!.posReviewCancelDialogBtn, style: AppTextStyles.button.copyWith(color: AppColors.secondaryLight))),
                ),
                FilledButton(
                  onPressed: remaining.abs() > 0.05
                      ? null
                      : () {
                    final result = <Map<String, dynamic>>[];
                    for (final pm in _selectedPayments) {
                      final amt =
                          double.tryParse(controllers[pm]!.text.trim()) ??
                              0.0;
                      result.add(_paymentSplitLine(pm, amt));
                    }
                    Navigator.pop(ctx, result);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Builder(builder: (ctx) => Text(AppLocalizations.of(ctx)!.posReviewConfirmAmounts)),
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
      title: AppLocalizations.of(context)!.posReviewSplitPayment,
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
                Builder(builder: (ctx) => Text(AppLocalizations.of(ctx)!.posReviewInvoiceTotal, style: AppTextStyles.bodyMedium)),
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
                              Builder(builder: (ctx) => Text(first.localizedLabel(ctx), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                            ],
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _splitControllers[first],
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: _walkInInvoiceFieldDecoration(AppLocalizations.of(context)!.posReviewAmountSar),
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
                                Builder(builder: (ctx) => Text(methods[i + 1].localizedLabel(ctx), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                              ],
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _splitControllers[methods[i + 1]],
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: _walkInInvoiceFieldDecoration(AppLocalizations.of(context)!.posReviewAmountSar),
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
                    ? 'Remaining: \${remaining.toStringAsFixed(2)} SAR'
                    : 'Exceeds total by \${remaining.abs().toStringAsFixed(2)} SAR',
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

  Widget _buildEmployeesInvoiceSection() {
    if (_branchEmployeesLoading && _branchEmployees.isEmpty) {
      return _SectionCard(
        title: AppLocalizations.of(context)!.posReviewEmployeesPayment,
        icon: Icons.groups_outlined,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    if (_branchEmployeesLoadFailed && _branchEmployees.isEmpty) {
      return _SectionCard(
        title: AppLocalizations.of(context)!.posReviewEmployeesPayment,
        icon: Icons.groups_outlined,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppLocalizations.of(context)!.posReviewCouldNotLoadEmployees,
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.red.shade700),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                setState(() {
                  _branchEmployeesLoadFailed = false;
                  _branchEmployees.clear();
                });
                _ensureBranchEmployeesLoaded();
              },
              style: FilledButton.styleFrom(backgroundColor: AppColors.primaryLight),
              child: Builder(builder: (ctx) => Text(AppLocalizations.of(ctx)!.posReviewRetry)),
            ),
          ],
        ),
      );
    }
    final list = _branchEmployees;
    if (list.isEmpty) {
      return _SectionCard(
        title: AppLocalizations.of(context)!.posReviewEmployeesPayment,
        icon: Icons.groups_outlined,
        child: Text(
          AppLocalizations.of(context)!.posReviewNoBranchEmployees,
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey.shade600),
        ),
      );
    }

    return _SectionCard(
      title: AppLocalizations.of(context)!.posReviewSelectEmployee,
      icon: Icons.groups_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.posReviewEmployeeInstructions,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey.shade700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 108,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final e = list[i];
                final name =
                e.name.trim().isNotEmpty ? e.name.trim() : e.id;
                final typeLabel = e.employeeTypeDisplay;
                final selected = _employeesPaymentEmployeeId == e.id;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _employeesPaymentEmployeeId =
                        selected ? null : e.id;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 146,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primaryLight.withValues(alpha: 0.42)
                            : const Color(0xFFF8F9FC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? AppColors.primaryLight
                              : const Color(0xFFE2E8F0),
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
                                selected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                size: 16,
                                color: selected
                                    ? AppColors.secondaryLight
                                    : Colors.grey.shade400,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.8,
                                    fontWeight: FontWeight.w800,
                                    color: selected
                                        ? AppColors.secondaryLight
                                        : Colors.grey.shade700,
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
                              fontSize: 11,
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
          ),
        ],
      ),
    );
  }

  // ── Inline Billing + Vehicle form ───────────────────────────────────────
  Widget _buildInlineBillingForm() {
    return _SectionCard(
      title: AppLocalizations.of(context)!.posReviewInvoiceDetails,
      icon: Icons.receipt_outlined,
      child: Form(
        key: _billingFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _walkInInvoiceSectionHeader(AppLocalizations.of(context)!.posReviewBilling, Icons.person_outline_rounded),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameCtrl,
                    decoration: _walkInInvoiceFieldDecoration(AppLocalizations.of(context)!.posReviewCustomerNameLabel),
                    textCapitalization: TextCapitalization.words,
                    validator: (s) =>
                    (s == null || s.trim().isEmpty) ? AppLocalizations.of(context)!.posReviewRequiredError : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _mobileCtrl,
                    decoration: _walkInInvoiceFieldDecoration(AppLocalizations.of(context)!.posReviewMobileLabel),
                    keyboardType: TextInputType.phone,
                    validator: (s) =>
                    (s == null || s.trim().isEmpty) ? AppLocalizations.of(context)!.posReviewRequiredError : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _vatCtrl,
                    decoration: _walkInInvoiceFieldDecoration(AppLocalizations.of(context)!.posReviewVatLabel, optional: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _walkInInvoiceSectionHeader(AppLocalizations.of(context)!.posReviewVehicle, Icons.directions_car_outlined),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _plateCtrl,
                    decoration: _walkInInvoiceFieldDecoration(AppLocalizations.of(context)!.posReviewPlateNumberLabel),
                    textCapitalization: TextCapitalization.characters,
                    validator: (s) =>
                    (s == null || s.trim().isEmpty) ? AppLocalizations.of(context)!.posReviewPlateRequiredError : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _odoCtrl,
                    decoration: _walkInInvoiceFieldDecoration(AppLocalizations.of(context)!.posReviewOdometerLabel, optional: true),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _makeCtrl,
                    decoration: _walkInInvoiceFieldDecoration(AppLocalizations.of(context)!.posReviewMakeLabel, optional: true),
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
                    controller: _modelCtrl,
                    decoration: _walkInInvoiceFieldDecoration(AppLocalizations.of(context)!.posReviewModelLabel, optional: true),
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _yearCtrl,
                    decoration: _walkInInvoiceFieldDecoration(AppLocalizations.of(context)!.posReviewYearLabel, optional: true),
                    keyboardType: TextInputType.number,
                    validator: (s) {
                      if (s == null || s.trim().isEmpty) return null;
                      final yi = int.tryParse(s.trim());
                      if (yi == null || yi < 1900 || yi > 2100) {
                        return AppLocalizations.of(context)!.posReviewInvalidYearError;
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _vinCtrl,
                    decoration: _walkInInvoiceFieldDecoration(AppLocalizations.of(context)!.posReviewVinLabel, optional: true),
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
    if (widget.order.isCorporateWalkIn &&
        !widget.order.isCorporateBookingOrder &&
        (widget.order.isCorporateUnapproved ||
            widget.order.isWaitingCorporateApproval ||
            widget.order.isRejectedByCorporate)) {
      ToastService.showError(
        context,
        AppLocalizations.of(context)!.posReviewCorporateMustBeApproved,
      );
      return;
    }
    if (!widget.order.meetsCashierInvoicePrerequisites) {
      ToastService.showError(context, AppLocalizations.of(context)!.posReviewOrderNotReadyForInvoicing);
      return;
    }

    // 1. Corporate decision must be made
    if (_isCorporate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Builder(builder: (ctx) => Text(AppLocalizations.of(ctx)!.posReviewIndicateCorporate)),
        ),
      );
      return;
    }

    // 2. Payment methods required
    if (_isCorporate == true && _selectedPayments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Builder(builder: (ctx) => Text(AppLocalizations.of(ctx)!.posReviewSelectPaymentMethod))),
      );
      return;
    }
    if (_isCorporate == false && _selectedPayments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Builder(builder: (ctx) => Text(AppLocalizations.of(ctx)!.posReviewSelectAtLeastOnePayment))),
      );
      return;
    }

    if (_isCorporate == false &&
        _selectedPayments.contains(PaymentMethod.employees) &&
        (_employeesPaymentEmployeeId == null ||
            _employeesPaymentEmployeeId!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Builder(builder: (ctx) => Text(AppLocalizations.of(ctx)!.posReviewSelectOneEmployee)),
        ),
      );
      return;
    }

    // 3. Validate split amounts sum when 2+ methods selected
    List<Map<String, dynamic>>? paymentSplits;
    if (_isCorporate != true) {
      if (_selectedPayments.length == 1) {
        paymentSplits = [
          _paymentSplitLine(_selectedPayments.first, _totalAmount),
        ];
      } else {
        double splitSum = 0;
        for (final c in _splitControllers.values) {
          splitSum += double.tryParse(c.text.trim()) ?? 0.0;
        }
        if ((splitSum - _totalAmount).abs() > 0.05) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Builder(builder: (ctx) => Text(AppLocalizations.of(ctx)!.posReviewSplitAmountsMustEqual(_totalAmount.toStringAsFixed(2), splitSum.toStringAsFixed(2)))),
            ),
          );
          return;
        }
        paymentSplits = _selectedPayments.map((pm) {
          final amt =
              double.tryParse(_splitControllers[pm]?.text.trim() ?? '') ?? 0.0;
          return _paymentSplitLine(pm, amt);
        }).toList();
      }
    }

    // 4. Validate inline billing form for walk-in orders
    final posVm = Provider.of<pvm.PosViewModel>(context, listen: false);
    if (_isStandardWalkInOrder(widget.order)) {
      if (_billingFormKey.currentState?.validate() != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Builder(builder: (ctx) => Text(AppLocalizations.of(ctx)!.posReviewFillRequiredInvoiceDetails))),
        );
        return;
      }
      final v = widget.order.vehicle;
      posVm.updateWalkInBillingContact(
        forOrderId: widget.order.id,
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
            ? (_selectedPayments.isNotEmpty
            ? _selectedPayments.first.apiKey
            : 'Corporate')
            : (paymentSplits != null && paymentSplits.length == 1
            ? paymentSplits.first['method'] as String?
            : null),
        payments:
        _isCorporate != true && paymentSplits != null ? paymentSplits : null,
      );

      if (response != null && response.success) {
        posVm.fetchOrders();

        final inv = response.invoice;
        if (inv != null) {
          setState(() {
            _currentInvoice = inv;
            _buildItems();
          });
          if (!mounted) return;
          await showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => InvoiceDialog(
              invoice: inv,
              requestedPaymentMethod: _requestedPaymentLabelForInvoice(),
              onDone: () {
                Future.delayed(Duration.zero, () {
                  if (context.mounted) Navigator.pop(context);
                });
              },
            ),
          );
        } else if (mounted) {
          ToastService.showSuccess(
            context,
            response.message.isNotEmpty ? response.message : AppLocalizations.of(context)!.posReviewInvoiceReady,
          );
        }
      } else {
        if (mounted) {
          ToastService.showError(
            context,
            response?.message ?? AppLocalizations.of(context)!.posReviewOrderNotReadyForInvoicing,
          );
        }
      }
    } catch (e) {
      if (mounted) ToastService.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildDepartmentJobs(bool isTablet, NumberFormat currencyFormat) {
    final visibleJobs =
    widget.order.jobs.where((j) => !j.isCancelledJob).toList();
    if (visibleJobs.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.posReviewNoDeptData,
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

    final summaryCard = _ReviewDraftOrderSummaryCard(
      isTablet: isTablet,
      currencyFormat: currencyFormat,
      grossSubtotal: _grossSubtotal,
      itemDiscountsTotal: _itemDiscountsTotal,
      invoiceDiscountTotal: _invoiceDiscountTotal,
      promoDiscountTotal: _promoDiscountTotal,
      netSubtotal: _netSubtotal,
      vatAmount: _vatAmount,
      totalAmount: _totalAmount,
      showFinalReviewHints: isTablet,
    );

    if (isTablet) {
      final mq = MediaQuery.of(context);
      final panelH = (mq.size.height * 0.62).clamp(440.0, 780.0);

      return SizedBox(
        height: panelH,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final minCardH = constraints.maxHeight;
                  final table = _buildDepartmentsDataTable(
                    sortedJobs,
                    isTablet,
                    currencyFormat,
                    minTableHeight: minCardH,
                  );
                  // No Scrollbar here: always-visible thumb/track looked like an "extra" bar when
                  // filler rows match panel height; table still scrolls when content overflows.
                  return SingleChildScrollView(
                    primary: false,
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: minCardH),
                      child: table,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 336,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 2,
                    child: _ReviewAssignTechniciansCard(
                      isTablet: isTablet,
                      jobs: sortedJobs,
                      bodyScrollable: true,
                      bodyScrollController: _reviewTechScrollController,
                    ),
                  ),
                  SizedBox(height: isTablet ? 12 : 14),
                  Expanded(
                    flex: 3,
                    child: Scrollbar(
                      controller: _reviewSummaryScrollController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      thickness: 6,
                      radius: const Radius.circular(8),
                      child: SingleChildScrollView(
                        controller: _reviewSummaryScrollController,
                        primary: false,
                        physics: const ClampingScrollPhysics(),
                        child: summaryCard,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final table = _buildDepartmentsDataTable(sortedJobs, isTablet, currencyFormat);

    final sidePanels = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ReviewAssignTechniciansCard(
          isTablet: isTablet,
          jobs: sortedJobs,
        ),
        SizedBox(height: isTablet ? 12 : 14),
        summaryCard,
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 640),
            child: table,
          ),
        ),
        const SizedBox(height: 16),
        sidePanels,
      ],
    );
  }

  static const Color _kReviewTableBorder = Color(0xFFE4E6EB);

  TableBorder _reviewTableBorder() => TableBorder.all(
    color: _kReviewTableBorder,
    width: 1,
  );

  /// Review table cell padding (departments grid).
  EdgeInsets _reviewTablePaddingHeader(bool isTablet) => EdgeInsets.symmetric(
    horizontal: isTablet ? 12 : 8,
    vertical: isTablet ? 11 : 9,
  );

  EdgeInsets _reviewTablePaddingBody(bool isTablet) => EdgeInsets.symmetric(
    horizontal: isTablet ? 12 : 8,
    vertical: isTablet ? 9 : 7,
  );

  /// Department line items only (no technician column).
  Map<int, TableColumnWidth> _reviewDeptColumnWidths() => {
    0: const IntrinsicColumnWidth(flex: 1.1),
    1: const IntrinsicColumnWidth(),
    2: const IntrinsicColumnWidth(flex: 0.55),
    3: const FlexColumnWidth(2.4),
    4: const IntrinsicColumnWidth(),
    5: const IntrinsicColumnWidth(),
  };

  TableCell _reviewHeaderCell(String text, bool isTablet, {TextAlign align = TextAlign.start}) {
    final pad = _reviewTablePaddingHeader(isTablet);
    return TableCell(
      child: Container(
        color: const Color(0xFFF5F6FA),
        padding: pad,
        alignment: _alignmentFor(align),
        child: Text(
          text,
          textAlign: align,
          style: TextStyle(
            fontSize: isTablet ? 12.5 : 10.5,
            fontWeight: FontWeight.w800,
            color: AppColors.secondaryLight,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Alignment _alignmentFor(TextAlign a) {
    switch (a) {
      case TextAlign.end:
      case TextAlign.right:
        return Alignment.centerRight;
      case TextAlign.center:
        return Alignment.center;
      default:
        return Alignment.centerLeft;
    }
  }

  TableCell _reviewBodyCell(
      String text,
      bool isTablet, {
        TextAlign align = TextAlign.start,
        FontWeight weight = FontWeight.w500,
        Color? color,
        int maxLines = 4,
      }) {
    final pad = _reviewTablePaddingBody(isTablet);
    return TableCell(
      child: Padding(
        padding: pad,
        child: Align(
          alignment: _alignmentFor(align),
          child: Text(
            text,
            textAlign: align,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isTablet ? 13 : 11,
              fontWeight: weight,
              color: color ?? const Color(0xFF1E2124),
            ),
          ),
        ),
      ),
    );
  }

  /// Empty rows so [Table] grid lines extend to [minTableHeight] (tablet Final Review).
  static const int _kMaxReviewFillerRows = 120;

  int _reviewFillerRowCount({
    required int tableRowCount,
    required double minViewportHeight,
    required bool isTablet,
  }) {
    final perRow = isTablet ? 39.0 : 33.0;
    final estimated = tableRowCount * perRow;
    if (estimated >= minViewportHeight) return 0;
    final gap = minViewportHeight - estimated;
    final n = (gap / perRow).ceil();
    return n.clamp(0, _kMaxReviewFillerRows);
  }

  Widget _buildDepartmentsDataTable(
      List<PosOrderJob> jobs,
      bool isTablet,
      NumberFormat currencyFormat, {
        double? minTableHeight,
      }) {
    final rows = <TableRow>[
      TableRow(
        children: [
          _reviewHeaderCell(AppLocalizations.of(context)!.posReviewDepartmentCol, isTablet),
          _reviewHeaderCell(AppLocalizations.of(context)!.posReviewJobIdCol, isTablet),
          _reviewHeaderCell(AppLocalizations.of(context)!.posReviewStatusCol, isTablet),
          _reviewHeaderCell(AppLocalizations.of(context)!.posReviewProductServiceCol, isTablet),
          _reviewHeaderCell(AppLocalizations.of(context)!.posReviewQtyCol, isTablet, align: TextAlign.end),
          _reviewHeaderCell(AppLocalizations.of(context)!.posReviewAmountSarCol, isTablet, align: TextAlign.end),
        ],
      ),
    ];

    for (final job in jobs) {
      final items = job.items;
      if (items.isEmpty) {
        rows.add(TableRow(
          children: [
            _reviewBodyCell(job.department, isTablet, weight: FontWeight.w700),
            _reviewBodyCell(job.id, isTablet),
            _reviewBodyCell(job.status.toUpperCase(), isTablet, maxLines: 2),
            _reviewBodyCell(AppLocalizations.of(context)!.posReviewNoLineItems, isTablet, color: Colors.grey.shade500),
            _reviewBodyCell('—', isTablet, align: TextAlign.end),
            _reviewBodyCell('—', isTablet, align: TextAlign.end),
          ],
        ));
      } else {
        for (var i = 0; i < items.length; i++) {
          final item = items[i];
          final qtyStr = item.qty % 1 == 0
              ? item.qty.toInt().toString()
              : item.qty.toStringAsFixed(1);
          rows.add(TableRow(
            children: [
              _reviewBodyCell(i == 0 ? job.department : '', isTablet,
                  weight: i == 0 ? FontWeight.w800 : FontWeight.w500),
              _reviewBodyCell(i == 0 ? job.id : '', isTablet),
              _reviewBodyCell(i == 0 ? job.status.toUpperCase() : '', isTablet, maxLines: 2),
              _reviewBodyCell(item.productName, isTablet, weight: FontWeight.w600),
              _reviewBodyCell(qtyStr, isTablet, align: TextAlign.end),
              _reviewBodyCell(item.lineTotal.toStringAsFixed(2), isTablet,
                  align: TextAlign.end, weight: FontWeight.w800),
            ],
          ));
        }
      }

      if (job.items.isNotEmpty) {
        final jobSubtotalExclusive = job.amountBeforeDiscount > 0
            ? job.amountBeforeDiscount
            : job.items.fold(0.0, (sum, i) {
          final exclVat = (i.unitPrice / 1.15 * 100).roundToDouble() / 100;
          return sum + exclVat * i.qty;
        });
        final postItemDiscountJobTotal = job.amountAfterDiscount > 0
            ? job.amountAfterDiscount
            : job.items.fold(0.0, (sum, i) => sum + i.lineTotal);
        final itemDisc = jobSubtotalExclusive - postItemDiscountJobTotal;
        final jobTotal = job.totalAmount > 0 ? job.totalAmount : postItemDiscountJobTotal;
        final jobVatAmount = job.vatAmount > 0
            ? job.vatAmount
            : job.amountAfterPromo > 0
            ? job.amountAfterPromo * 0.15
            : jobTotal - (jobTotal / (1 + _vatRate));

        rows.add(TableRow(
          decoration: const BoxDecoration(color: Color(0xFFFAFAFC)),
          children: [
            _reviewBodyCell('', isTablet),
            _reviewBodyCell('', isTablet),
            _reviewBodyCell('', isTablet),
            _reviewBodyCell(AppLocalizations.of(context)!.posReviewGrossExclVat, isTablet, weight: FontWeight.w700),
            _reviewBodyCell('', isTablet),
            _reviewBodyCell(jobSubtotalExclusive.toStringAsFixed(2), isTablet,
                align: TextAlign.end, weight: FontWeight.w700),
          ],
        ));
        if (itemDisc > 0.009) {
          rows.add(TableRow(
            decoration: const BoxDecoration(color: Color(0xFFFAFAFC)),
            children: [
              _reviewBodyCell('', isTablet),
              _reviewBodyCell('', isTablet),
              _reviewBodyCell('', isTablet),
              _reviewBodyCell(AppLocalizations.of(context)!.posReviewItemLineDiscounts, isTablet, weight: FontWeight.w600),
              _reviewBodyCell('', isTablet),
              _reviewBodyCell('- ${itemDisc.toStringAsFixed(2)}', isTablet,
                  align: TextAlign.end,
                  weight: FontWeight.w700,
                  color: Colors.green.shade700),
            ],
          ));
        }
        rows.add(TableRow(
          decoration: const BoxDecoration(color: Color(0xFFFAFAFC)),
          children: [
            _reviewBodyCell('', isTablet),
            _reviewBodyCell('', isTablet),
            _reviewBodyCell('', isTablet),
            _reviewBodyCell(AppLocalizations.of(context)!.posReviewVatPct((_vatRate * 100).toStringAsFixed(0)), isTablet, weight: FontWeight.w700),
            _reviewBodyCell('', isTablet),
            _reviewBodyCell(jobVatAmount.toStringAsFixed(2), isTablet,
                align: TextAlign.end, weight: FontWeight.w700),
          ],
        ));
        rows.add(TableRow(
          decoration: BoxDecoration(color: AppColors.primaryLight.withOpacity(0.12)),
          children: [
            _reviewBodyCell('', isTablet),
            _reviewBodyCell('', isTablet),
            _reviewBodyCell('', isTablet),
            _reviewBodyCell(AppLocalizations.of(context)!.posReviewDepartmentTotal, isTablet, weight: FontWeight.w900),
            _reviewBodyCell('', isTablet),
            _reviewBodyCell(currencyFormat.format(jobTotal), isTablet,
                align: TextAlign.end,
                weight: FontWeight.w900,
                color: AppColors.secondaryLight),
          ],
        ));
      }
    }

    final minH = minTableHeight;
    if (minH != null && minH > 0) {
      final extra = _reviewFillerRowCount(
        tableRowCount: rows.length,
        minViewportHeight: minH,
        isTablet: isTablet,
      );
      // One fewer filler row so the table does not show an extra blank line at the bottom.
      final fillCount = extra > 0 ? extra - 1 : 0;
      for (var i = 0; i < fillCount; i++) {
        rows.add(
          TableRow(
            children: [
              _reviewBodyCell('', isTablet),
              _reviewBodyCell('', isTablet),
              _reviewBodyCell('', isTablet),
              _reviewBodyCell('', isTablet),
              _reviewBodyCell('', isTablet, align: TextAlign.end),
              _reviewBodyCell('', isTablet, align: TextAlign.end),
            ],
          ),
        );
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Table(
          columnWidths: _reviewDeptColumnWidths(),
          defaultColumnWidth: const FlexColumnWidth(1),
          border: _reviewTableBorder(),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: rows,
        ),
      ),
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
          title: _isGenerated ? AppLocalizations.of(context)!.posReviewInvoiceReady : AppLocalizations.of(context)!.posReviewFinalReview,
          showBackButton: true,
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
                  _buildDepartmentJobs(isTablet, currencyFormat),
                  const SizedBox(height: 16),

                  // ── Corporate + Payment (tablet: same row when individual) ───
                  if (isTablet) ...[
                    if (_isCorporate == false)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _SectionCard(
                              title: AppLocalizations.of(context)!.posReviewCorporateCustomerQuestion,
                              icon: Icons.business_rounded,
                              child: _CorporatePrompt(
                                isCorporate: _isCorporate,
                                onChanged: _onCorporateCustomerChanged,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _SectionCard(
                              title: AppLocalizations.of(context)!.posReviewPaymentMethod,
                              icon: Icons.payment_rounded,
                              child: _PaymentMethodSelector(
                                selected: _selectedPayments,
                                onChanged: _onRetailPaymentMethodsChanged,
                                isTablet: isTablet,
                              ),
                            ),
                          ),
                        ],
                      )
                    else if (_isCorporate == true)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _SectionCard(
                              title: AppLocalizations.of(context)!.posReviewCorporateCustomerQuestion,
                              icon: Icons.business_rounded,
                              child: _CorporatePrompt(
                                isCorporate: _isCorporate,
                                onChanged: _onCorporateCustomerChanged,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _SectionCard(
                              title: AppLocalizations.of(context)!.posReviewPaymentMethodCorporate,
                              icon: Icons.payment_rounded,
                              child: _PaymentMethodSelector(
                                selected: _selectedPayments,
                                onChanged: (pms) => setState(() => _selectedPayments = pms),
                                isTablet: isTablet,
                                corporateMonthlyOnly: true,
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      _SectionCard(
                        title: AppLocalizations.of(context)!.posReviewCorporateCustomerQuestion,
                        icon: Icons.business_rounded,
                        child: _CorporatePrompt(
                          isCorporate: _isCorporate,
                          onChanged: _onCorporateCustomerChanged,
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (_isCorporate == false && _selectedPayments.length >= 2) ...[
                      _buildInlineSplitPaymentCard(),
                      const SizedBox(height: 16),
                    ],
                    if (_isCorporate == false &&
                        _selectedPayments.contains(PaymentMethod.employees)) ...[
                      _buildEmployeesInvoiceSection(),
                      const SizedBox(height: 16),
                    ],
                  ] else ...[
                    _SectionCard(
                      title: AppLocalizations.of(context)!.posReviewCorporateCustomerQuestion,
                      icon: Icons.business_rounded,
                      child: _CorporatePrompt(
                        isCorporate: _isCorporate,
                        onChanged: _onCorporateCustomerChanged,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isCorporate == false) ...[
                      _SectionCard(
                        title: AppLocalizations.of(context)!.posReviewPaymentMethod,
                        icon: Icons.payment_rounded,
                        child: _PaymentMethodSelector(
                          selected: _selectedPayments,
                          onChanged: _onRetailPaymentMethodsChanged,
                          isTablet: isTablet,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_selectedPayments.length >= 2) ...[
                        _buildInlineSplitPaymentCard(),
                        const SizedBox(height: 16),
                      ],
                      if (_selectedPayments.contains(PaymentMethod.employees)) ...[
                        _buildEmployeesInvoiceSection(),
                        const SizedBox(height: 16),
                      ],
                    ],
                    if (_isCorporate == true) ...[
                      _SectionCard(
                        title: AppLocalizations.of(context)!.posReviewPaymentMethodCorporate,
                        icon: Icons.payment_rounded,
                        child: _PaymentMethodSelector(
                          selected: _selectedPayments,
                          onChanged: (pms) => setState(() => _selectedPayments = pms),
                          isTablet: isTablet,
                          corporateMonthlyOnly: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
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
                    enabled: widget.order.meetsCashierInvoicePrerequisites &&
                        (!widget.order.isCorporateWalkIn ||
                            widget.order.isCorporateApproved ||
                            widget.order.isCorporateBookingOrder),
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

  /// Matches [InvoiceDialog] payment hint (corporate / split / single method).
  String? _requestedPaymentLabelForInvoice() {
    if (_isCorporate == true) {
      if (_selectedPayments.isEmpty) return 'Corporate';
      return 'Corporate — ${_selectedPayments.first.apiKey}';
    }
    if (_selectedPayments.length > 1) {
      return 'Split (${_selectedPayments.map((p) => p.apiKey).join(' + ')})';
    }
    if (_selectedPayments.length == 1) return _selectedPayments.first.label;
    return null;
  }

  void _showPrintDialog() {
    if (_currentInvoice == null) {
      ToastService.showError(context, AppLocalizations.of(context)!.posReviewInvoiceNotLoaded);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => InvoiceDialog(
        invoice: _currentInvoice!,
        requestedPaymentMethod: _requestedPaymentLabelForInvoice(),
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
                child: LocalizedApiText(
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
                  Expanded(child: Builder(builder: (ctx) => Text(AppLocalizations.of(ctx)!.posReviewGrossExclVat, style: labelStyle))),
                  Text('SAR ${item.unitPriceExclVat.toStringAsFixed(2)}', style: valStyle),
                ]),
                const SizedBox(height: 2),
                Row(children: [
                  Expanded(child: Builder(builder: (ctx) => Text(AppLocalizations.of(ctx)!.posReviewQtyCol, style: labelStyle))),
                  Text('${item.qty}', style: valStyle),
                ]),
                const SizedBox(height: 2),
                Row(children: [
                  Expanded(child: Builder(builder: (ctx) => Text(AppLocalizations.of(ctx)!.posReviewGrossAmountExclVat, style: labelStyle))),
                  Text('SAR ${item.grossBeforeVat.toStringAsFixed(2)}', style: valStyle),
                ]),
                if (item.discountAmount > 0) ...[
                  const SizedBox(height: 2),
                  Row(children: [
                    Expanded(child: Builder(builder: (ctx) => Text(AppLocalizations.of(ctx)!.posReviewDiscount, style: labelStyle))),
                    Text('- SAR ${item.discountAmount.toStringAsFixed(2)}', style: valStyle.copyWith(color: Colors.green)),
                  ]),
                  const SizedBox(height: 2),
                  Row(children: [
                    Expanded(child: Builder(builder: (ctx) => Text(AppLocalizations.of(ctx)!.posReviewTotalTaxable, style: labelStyle))),
                    Text('SAR ${item.totalBeforeVat.toStringAsFixed(2)}', style: valStyle),
                  ]),
                ],
                const SizedBox(height: 2),
                Row(children: [
                  Expanded(child: Builder(builder: (ctx) => Text(AppLocalizations.of(ctx)!.posReviewVat15, style: labelStyle))),
                  Text('SAR ${item.vatOnLine.toStringAsFixed(2)}', style: valStyle),
                ]),
                if (item.technicianName.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(children: [
                    Expanded(child: Builder(builder: (ctx) => Text(AppLocalizations.of(ctx)!.posDetailsTechnician, style: labelStyle))),
                    LocalizedApiText(item.technicianName, style: valStyle),
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
    label: AppLocalizations.of(context)!.posReviewGrossAmountExclVat,
    value: 'SAR ${currencyFormat.format(subtotalExclusive)}',
    valueColor: const Color(0xFF1E2124),
    ),
    const SizedBox(height: 8),

    if (itemDiscountAmount > 0) ...[
    _PriceRow(
    label: AppLocalizations.of(context)!.posReviewItemDiscounts,
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
    Builder(builder: (ctx) => Text(
    AppLocalizations.of(ctx)!.posReviewDiscount,
    style: TextStyle(
    fontSize: 13,
    color: Colors.green.shade600,
    fontWeight: FontWeight.w500,
    ),
    )),
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
    label: AppLocalizations.of(context)!.posReviewPriceAfterDiscount,
    value: 'SAR ${currencyFormat.format(priceAfterGlobal)}',
    ),
    const SizedBox(height: 8),
    ],

    if (computedPromoAmount > 0) ...[
    _PriceRow(
    label: promoCode != null && promoCode!.isNotEmpty
    ? AppLocalizations.of(context)!.posReviewPromoDiscount(promoCode!)
        : AppLocalizations.of(context)!.posReviewPromoDiscountNoCode,
    value: '-SAR ${currencyFormat.format(computedPromoAmount)}',
    valueColor: Colors.green.shade600,
    labelColor: Colors.green.shade600,
    ),
    const SizedBox(height: 8),
    _PriceRow(
    label: AppLocalizations.of(context)!.posReviewPriceAfterPromo,
    value: 'SAR ${currencyFormat.format(priceAfterPromo)}',
    ),
    const SizedBox(height: 8),
    ],

    const Divider(height: 1, color: Color(0xFFF0F0F5)),
    const SizedBox(height: 10),
    _PriceRow(
    label: AppLocalizations.of(context)!.posReviewTaxPct((vatRate * 100).toStringAsFixed(0)),
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
    Builder(builder: (ctx) => Text(
    AppLocalizations.of(ctx)!.posReviewTotalAmount,
    style: TextStyle(
    fontSize: isTablet ? 17 : 15,
    fontWeight: FontWeight.w900,
    color: const Color(0xFF1E2124),
    ),
    )),
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
        Text(
          AppLocalizations.of(context)!.posReviewIsCorporateCustomer,
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
              label: AppLocalizations.of(context)!.posReviewYesCorporate,
              icon: Icons.business_rounded,
              selected: isCorporate == true,
              onTap: () => onChanged(true),
              accentColor: AppColors.secondaryLight,
            ),
            const SizedBox(width: 12),
            _ChoiceChip(
              label: AppLocalizations.of(context)!.posReviewNoIndividual,
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
  /// Corporate invoice: five tappable methods (monthly billing, cash, card, bank, wallet).
  final bool corporateMonthlyOnly;
  const _PaymentMethodSelector({
    required this.selected,
    required this.onChanged,
    required this.isTablet,
    this.corporateMonthlyOnly = false,
  });

  Widget _methodChip(PaymentMethod pm, {required bool isSelected}) {
    return AnimatedContainer(
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
          Icon(
            pm.icon,
            size: 16,
            color: isSelected ? Colors.black : Colors.grey.shade400,
          ),
          const SizedBox(width: 8),
          Builder(builder: (ctx) => Text(
            pm.localizedLabel(ctx),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.black : Colors.grey.shade500,
            ),
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (corporateMonthlyOnly) {
      const corporateMethods = <PaymentMethod>[
        PaymentMethod.monthlyBilling,
        PaymentMethod.bankTransfer,
        PaymentMethod.cash,
        PaymentMethod.card,
        PaymentMethod.wallet,
      ];
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: corporateMethods.map((pm) {
          final isSelected = selected.contains(pm);
          return GestureDetector(
            onTap: () => onChanged({pm}),
            child: _methodChip(pm, isSelected: isSelected),
          );
        }).toList(),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: PaymentMethod.values.where((pm) => pm.isRetailSelectable).map((pm) {
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
          child: _methodChip(pm, isSelected: isSelected),
        );
      }).toList(),
    );
  }
}

class _GenerateInvoiceButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;
  final bool enabled;
  const _GenerateInvoiceButton({
    required this.onTap,
    this.isLoading = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final canTap = enabled && !isLoading;
    return ElevatedButton.icon(
      onPressed: canTap ? onTap : null,
      icon: isLoading
          ? const SizedBox.shrink()
          : Icon(
        Icons.auto_awesome_rounded,
        size: 18,
        color: canTap ? Colors.black : const Color(0xFF64748B),
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
          : Text(
        AppLocalizations.of(context)!.posReviewCompleteAndGenerateInvoice,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 14,
          color: canTap ? Colors.black : const Color(0xFF64748B),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor:
        canTap ? AppColors.primaryLight : const Color(0xFFCBD5E1),
        foregroundColor: Colors.black,
        disabledBackgroundColor: const Color(0xFFCBD5E1),
        disabledForegroundColor: const Color(0xFF64748B),
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
            AppLocalizations.of(context)!.posReviewInvoiceGeneratedLocked,
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
              children: [
                const Icon(Icons.lock_rounded, size: 14, color: Colors.white70),
                const SizedBox(width: 6),
                Text(
                  AppLocalizations.of(context)!.posReviewNoFurtherEdits,
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
          Text(
            AppLocalizations.of(context)!.posReviewCommissionsNote,
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
      title: AppLocalizations.of(context)!.posReviewCommissionsCredited,
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
      label: Text(
        AppLocalizations.of(context)!.posReviewPrintInvoice,
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

// ── Mock Print Dialog ───────────────────────────────────────────────────

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
                    : paymentMethod != null ? paymentMethod!.label : '—',
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
                label: AppLocalizations.of(context)!.posReviewVat15,
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

/// Draft-style order totals beside the final-review table (`pos_orders_view` DRAFT TOTALS).
class _ReviewDraftOrderSummaryCard extends StatelessWidget {
  final bool isTablet;
  final NumberFormat currencyFormat;
  final double grossSubtotal;
  final double itemDiscountsTotal;
  final double invoiceDiscountTotal;
  final double promoDiscountTotal;
  final double netSubtotal;
  final double vatAmount;
  final double totalAmount;
  /// Extra hint lines + spacing (tablet Final Review right column).
  final bool showFinalReviewHints;

  const _ReviewDraftOrderSummaryCard({
    required this.isTablet,
    required this.currencyFormat,
    required this.grossSubtotal,
    required this.itemDiscountsTotal,
    required this.invoiceDiscountTotal,
    required this.promoDiscountTotal,
    required this.netSubtotal,
    required this.vatAmount,
    required this.totalAmount,
    this.showFinalReviewHints = false,
  });

  static const _border = Color(0xFFE8ECF3);

  @override
  Widget build(BuildContext context) {
    final pad = EdgeInsets.all(isTablet ? 18.0 : 16.0);
    final labelStyle = TextStyle(
      fontSize: isTablet ? 13.0 : 12.0,
      fontWeight: FontWeight.w600,
      color: Colors.grey.shade600,
    );
    final valueStyle = TextStyle(
      fontSize: isTablet ? 13.0 : 12.0,
      fontWeight: FontWeight.w800,
      color: const Color(0xFF1E2124),
    );

    Widget line(String label, String value, {bool negative = false}) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(label, style: labelStyle)),
            Text(
              value,
              style: valueStyle.copyWith(
                color: negative ? Colors.red.shade700 : const Color(0xFF1E2124),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: pad,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppLocalizations.of(context)!.posReviewOrderSummary,
            style: TextStyle(
              fontSize: isTablet ? 13 : 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 14),
          line(AppLocalizations.of(context)!.posReviewGrossAmountExclVat, grossSubtotal.toStringAsFixed(2)),
          line(AppLocalizations.of(context)!.posReviewItemDiscounts, '- ${itemDiscountsTotal.toStringAsFixed(2)}', negative: true),
          line(AppLocalizations.of(context)!.posReviewInvoiceDiscount, '- ${invoiceDiscountTotal.toStringAsFixed(2)}', negative: true),
          line(AppLocalizations.of(context)!.posReviewPromoDiscountNoCode, '- ${promoDiscountTotal.toStringAsFixed(2)}', negative: true),
          line(AppLocalizations.of(context)!.posReviewTotalTaxable, netSubtotal.toStringAsFixed(2)),
          line(AppLocalizations.of(context)!.posReviewVat15, vatAmount.toStringAsFixed(2)),
          if (showFinalReviewHints) ...[
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.posReviewLineNetNote,
              style: TextStyle(
                fontSize: isTablet ? 11.5 : 11,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.posReviewInvoicePromoNote,
              style: TextStyle(
                fontSize: isTablet ? 11.5 : 11,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.posReviewConfirmAmountsNote,
              style: TextStyle(
                fontSize: isTablet ? 11.5 : 11,
                color: Colors.grey.shade500,
                height: 1.4,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 14),
          ],
          const Divider(height: 20, thickness: 1, color: _border),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.secondaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOTAL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 14 : 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'SAR ${currencyFormat.format(totalAmount)}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Department-wise assigned technicians (active assignments only).
class _ReviewAssignTechniciansCard extends StatelessWidget {
  final bool isTablet;
  final List<PosOrderJob> jobs;
  /// When true, the list scrolls inside a fixed-height parent (tablet split row).
  final bool bodyScrollable;
  final ScrollController? bodyScrollController;

  const _ReviewAssignTechniciansCard({
    required this.isTablet,
    required this.jobs,
    this.bodyScrollable = false,
    this.bodyScrollController,
  });

  static const _border = Color(0xFFE8ECF3);

  /// Preview commission for review. API often returns `0` until completion/invoice; mirror
  /// [_commissions] fallback so reassigned techs don’t show SAR 0.00 before invoice.
  String _commissionLabel(JobTechnician tech, PosOrderJob job) {
    double amount = tech.commissionAmount;
    double percent = tech.commissionPercent;
    if (amount <= 0) {
      final rate = percent > 0 ? percent / 100.0 : 0.10;
      amount = job.totalAmount * rate;
      if (percent <= 0) percent = 10.0;
    }
    return 'SAR ${amount.toStringAsFixed(2)}'
        '${percent > 0 ? ' (${percent.toStringAsFixed(0)}%)' : ''}';
  }

  List<Widget> _jobBlocks({
    required BuildContext context,
    required TextStyle deptStyle,
    required TextStyle jobIdStyle,
    required TextStyle nameStyle,
    required TextStyle commStyle,
  }) {
    final list = <Widget>[];
    for (var i = 0; i < jobs.length; i++) {
      final job = jobs[i];
      final techs = job.distinctActiveTechnicians;
      list.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LocalizedApiText(job.department, style: deptStyle, uppercase: true),
              Builder(builder: (ctx) => Text(AppLocalizations.of(ctx)!.posReviewJobHash(job.id), style: jobIdStyle)),
              const SizedBox(height: 8),
              if (techs.isEmpty)
                Text(
                  AppLocalizations.of(context)!.posReviewNoTechAssigned,
                  style: TextStyle(
                    fontSize: isTablet ? 12.5 : 11.5,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade500,
                  ),
                )
              else
                ...techs.map(
                      (t) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.engineering_outlined,
                          size: isTablet ? 20 : 18,
                          color: AppColors.secondaryLight,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LocalizedApiText(t.name, style: nameStyle),
                              Text(
                                AppLocalizations.of(context)!.posReviewCommissionLabel(_commissionLabel(t, job)),
                                style: commStyle,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
      if (i < jobs.length - 1) {
        list.add(Divider(height: 1, thickness: 1, color: Colors.grey.shade200));
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final pad = EdgeInsets.all(isTablet ? 18.0 : 16.0);
    final deptStyle = TextStyle(
      fontSize: isTablet ? 14 : 13,
      fontWeight: FontWeight.w800,
      color: const Color(0xFF1E2124),
    );
    final jobIdStyle = TextStyle(
      fontSize: isTablet ? 11.5 : 10.5,
      fontWeight: FontWeight.w600,
      color: Colors.grey.shade600,
    );
    final nameStyle = TextStyle(
      fontSize: isTablet ? 13 : 12,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF1E2124),
    );
    final commStyle = TextStyle(
      fontSize: isTablet ? 11.5 : 10.5,
      fontWeight: FontWeight.w600,
      color: Colors.grey.shade700,
    );

    final header = Text(
      AppLocalizations.of(context)!.posReviewAssignedTechnicians,
      style: TextStyle(
        fontSize: isTablet ? 13 : 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.5,
        color: const Color(0xFF64748B),
      ),
    );

    final blocks = _jobBlocks(
      context: context,
      deptStyle: deptStyle,
      jobIdStyle: jobIdStyle,
      nameStyle: nameStyle,
      commStyle: commStyle,
    );

    return Container(
      padding: pad,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          const SizedBox(height: 14),
          if (bodyScrollable)
            Expanded(
              child: bodyScrollController != null
                  ? Scrollbar(
                controller: bodyScrollController,
                thumbVisibility: true,
                trackVisibility: true,
                thickness: 6,
                radius: const Radius.circular(8),
                child: SingleChildScrollView(
                  controller: bodyScrollController,
                  primary: false,
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ...blocks,
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              )
                  : SingleChildScrollView(
                primary: false,
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: blocks,
                ),
              ),
            )
          else
            ...blocks,
        ],
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