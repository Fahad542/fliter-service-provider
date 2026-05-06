import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/LocalizedApiText.dart';
import 'package:provider/provider.dart';

import '../../../services/invoice_network_print.dart';
import '../../../services/locker_translation_mixin.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/toast_service.dart';
import '../../../utils/pos_tablet_layout.dart';
import '../../../utils/app_text_styles.dart';
import '../Home Screen/pos_view_model.dart';
import '../../Menu/menu_view.dart';
import '../../../widgets/pos_widgets.dart';
import '../../../widgets/thermal_printer_wifi_dialog.dart';
import '../../../widgets/pos_shell_rail_layout.dart';
import '../Login/login_view_model.dart';
import 'package:filter_service_providers/utils/restart_widget.dart';
import '../../../models/store_closing_model.dart';
import 'store_closing_view_model.dart';

class PosStoreClosingView extends StatefulWidget {
  const PosStoreClosingView({super.key});

  @override
  State<PosStoreClosingView> createState() => _PosStoreClosingViewState();
}

class _PosStoreClosingViewState extends State<PosStoreClosingView> {
  bool _closingThermalPrintBusy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<StoreClosingViewModel>();
      // After a successful close, [PosShell] swaps the body subtree (rail + inner
      // IndexedStack vs plain IndexedStack). That can remount this widget; do not
      // reset here or the reconciliation / difference UI vanishes immediately.
      if (!vm.isReconciled) {
        vm.reset();
      }
      // Store-closing GET summary is not called on enter — only [reconcile] hits
      // the API when the user taps Close Shift (submit counter closing).
    });
  }


  String _storeDigits(Object? value) {
    return AppTranslationService.localizeDigitsForLanguage(
      value?.toString() ?? '',
      Localizations.localeOf(context).languageCode,
    );
  }

  String _storeMoney(num amount) {
    return AppLocalizations.of(context)!
        .posSalesReturnSarAmount(_storeDigits(amount.toStringAsFixed(2)));
  }

  String _storeSignedAmount(num amount) {
    final sign = amount >= 0 ? '+' : '';
    return _storeDigits('$sign${amount.toStringAsFixed(2)}');
  }

  String _storeExpected(num amount) {
    return AppLocalizations.of(context)!
        .posStoreClosingExpectedAmount(_storeDigits(amount.toStringAsFixed(2)));
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final isReconciled = context.watch<StoreClosingViewModel>().isReconciled;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: isReconciled
          ? AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: AppColors.primaryLight,
              elevation: 0,
              centerTitle: true,
              toolbarHeight: PosTabletLayout.appBarHeight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(PosTabletLayout.appBarBottomRadius),
                ),
              ),
              title: Text(
                AppLocalizations.of(context)!.posStoreClosingTitle,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? PosTabletLayout.appBarTitleSize : 19,
                ),
              ),
            )
          : PosScreenAppBar(
              title: AppLocalizations.of(context)!.posStoreClosingTitle,
              showBackButton: false,
            ),
      body: wrapPosShellRailBody(
        context,
        Consumer2<StoreClosingViewModel, PosViewModel>(
        builder: (context, closingVm, posVm, _) {
          final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + keyboardHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReconciliationSummary(isTablet, posVm),
                const SizedBox(height: 24),
                _buildSectionTitle(AppLocalizations.of(context)!.posStoreClosingCounterReconciliation, Icons.account_balance_rounded),
                const SizedBox(height: 16),
                if (!closingVm.isReconciled)
                  _buildPhysicalCountForm(isTablet, closingVm)
                else ...[
                  _buildReconciliationResult(isTablet, closingVm),
                  const SizedBox(height: 24),
                  _buildBottomActions(isTablet, posVm, closingVm),
                ],
              ],
            ),
          );
        },
      ),
      ),
      bottomNavigationBar: isReconciled
          ? const SizedBox.shrink()
          : Consumer2<PosViewModel, StoreClosingViewModel>(
              builder: (context, posVm, closingVm, _) =>
                  _buildBottomActions(isTablet, posVm, closingVm),
            ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, size: 18, color: AppColors.secondaryLight.withOpacity(0.7)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E2124),
          ),
        ),
      ],
    );
  }

  Widget _buildReconciliationSummary(bool isTablet, PosViewModel posVm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.secondaryLight, Color(0xFF2C3136)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryLight.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.posStoreClosingSummaryTitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.posStoreClosingShiftStatus,
                    style: TextStyle(
                        color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.history_toggle_off_rounded,
                    color: AppColors.primaryLight, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildSummaryItem(AppLocalizations.of(context)!.posStoreClosingCashier, posVm.cashierName, Icons.person_outline),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.1),
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),
              _buildSummaryItem(
                AppLocalizations.of(context)!.posStoreClosingBranch,
                posVm.branchName.isNotEmpty ? posVm.branchName : AppLocalizations.of(context)!.posStoreClosingMainBranch,
                Icons.storefront_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.primaryLight),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LocalizedApiText(
            value,
            style: const TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _buildPhysicalCountForm(bool isTablet, StoreClosingViewModel closingVm) {
    final summary = closingVm.summary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
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
          Text(
            AppLocalizations.of(context)!.posStoreClosingPhysicalDrawerCount,
            style: AppTextStyles.h3.copyWith(fontSize: 15, color: const Color(0xFF1E2124)),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context)!.posStoreClosingPhysicalDrawerHint,
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey, fontSize: 12),
          ),

          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildInputField(
                  label: AppLocalizations.of(context)!.posStoreClosingPhysicalCashAmount,
                  controller: closingVm.cashController,
                  icon: Icons.payments_outlined,
                  hint: summary != null
                      ? _storeExpected(summary.systemCashGross)
                      : null,
                  onChanged: (_) => closingVm.updatePhysicalCount(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInputField(
                  label: AppLocalizations.of(context)!.posStoreClosingBankCardSlips,
                  controller: closingVm.bankController,
                  icon: Icons.credit_card_outlined,
                  hint: summary != null
                      ? _storeExpected(summary.systemBankGross)
                      : null,
                  onChanged: (_) => closingVm.updatePhysicalCount(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInputField(
                  label: AppLocalizations.of(context)!.posStoreClosingCorporateInvoices,
                  controller: closingVm.corporateController,
                  icon: Icons.business_outlined,
                  hint: summary != null
                      ? _storeExpected(summary.systemCorporateGross)
                      : null,
                  onChanged: (_) => closingVm.updatePhysicalCount(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildInputField(
                  label: AppLocalizations.of(context)!.posStoreClosingTamaraCredits,
                  controller: closingVm.tamaraController,
                  icon: Icons.receipt_long_outlined,
                  hint: summary != null
                      ? _storeExpected(summary.systemTamaraGross)
                      : null,
                  onChanged: (_) => closingVm.updatePhysicalCount(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInputField(
                  label: AppLocalizations.of(context)!.posStoreClosingTabbyCredits,
                  controller: closingVm.tabbyController,
                  icon: Icons.receipt_long_outlined,
                  hint: summary != null
                      ? _storeExpected(summary.systemTabbyGross)
                      : null,
                  onChanged: (_) => closingVm.updatePhysicalCount(),
                ),
              ),
              Expanded(
                child: _buildInputField(
                  label: AppLocalizations.of(context)!.posStoreClosingOthersEmployeeSales,
                  controller: closingVm.othersController,
                  icon: Icons.groups_outlined,
                  hint: summary != null
                      ? _storeExpected(summary.systemOthersGross)
                      : null,
                  onChanged: (_) => closingVm.updatePhysicalCount(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInputField(
            label: AppLocalizations.of(context)!.posStoreClosingNotesOptional,
            controller: closingVm.notesController,
            icon: Icons.notes_rounded,
            isNumeric: false,
            maxLines: 3,
            onChanged: (_) {},
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryLight.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.posStoreClosingTotalPhysicalSum,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.secondaryLight),
                ),
                Text(
                  _storeMoney(closingVm.physicalTotal),
                  style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: AppColors.secondaryLight),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHintRow(String label, double amount, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
          Text(
            _storeMoney(amount),
            style: TextStyle(
              fontSize: 12,
              color: bold ? AppColors.secondaryLight : Colors.grey.shade700,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    bool isNumeric = true,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 13, color: Colors.grey.shade700)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            keyboardType: isNumeric ? TextInputType.number : TextInputType.multiline,
            maxLines: maxLines,
            onChanged: onChanged,
            style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: AppColors.secondaryLight),
            decoration: InputDecoration(
              prefixIcon: Icon(icon,
                  color: AppColors.secondaryLight.withOpacity(0.5), size: 20),
              hintText: hint ?? (isNumeric ? _storeDigits('0.00') : AppLocalizations.of(context)!.posStoreClosingAddNotesHint),
              hintStyle: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w400),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primaryLight, width: 2)),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReconciliationResult(bool isTablet, StoreClosingViewModel closingVm) {
    final report = closingVm.report;
    if (report == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Status banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: report.netDifference == 0
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  report.netDifference == 0
                      ? Icons.check_circle_rounded
                      : Icons.warning_amber_rounded,
                  color: report.netDifference == 0 ? Colors.green : Colors.orange,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.netDifference == 0
                            ? AppLocalizations.of(context)!.posStoreClosingShiftBalanced
                            : AppLocalizations.of(context)!.posStoreClosingDiscrepancyDetected,
                        style: TextStyle(
                          color: report.netDifference == 0
                              ? Colors.green.shade800
                              : Colors.orange.shade900,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        report.netDifference == 0
                            ? AppLocalizations.of(context)!.posStoreClosingShiftClosedSuccessfully
                            : report.salesReturnsTotal > 0.001
                                ? AppLocalizations.of(context)!.posStoreClosingGrossNetExplanation
                                : AppLocalizations.of(context)!.posStoreClosingPositiveDiff,
                        style: TextStyle(
                          color: report.netDifference == 0
                              ? Colors.green.shade700
                              : Colors.orange.shade800,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Closing ID
          if (closingVm.closingId != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context)!.posStoreClosingClosingId,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600)),
                  Text(
                    _storeDigits(closingVm.closingId!),
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryLight,
                        fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
          _buildResultHeader(
              showGrossNetLegend: report.salesReturnsTotal > 0.001),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _buildResultRow(AppLocalizations.of(context)!.posStoreClosingCashAccount, report.systemCashGross, report.physicalCash, report.cashDiff),
          const SizedBox(height: 12),
          _buildResultRow(AppLocalizations.of(context)!.posStoreClosingBankCards, report.systemBankGross, report.physicalBank, report.bankDiff),
          const SizedBox(height: 12),
          _buildResultRow(AppLocalizations.of(context)!.posStoreClosingCorporate, report.systemCorporateGross, report.physicalCorporate, report.corporateDiff),
          const SizedBox(height: 12),
          _buildResultRow(AppLocalizations.of(context)!.posStoreClosingTamara, report.systemTamaraGross, report.physicalTamara, report.tamaraDiff),
          const SizedBox(height: 12),
          _buildResultRow(AppLocalizations.of(context)!.posStoreClosingTabby, report.systemTabbyGross, report.physicalTabby, report.tabbyDiff),
          const SizedBox(height: 12),
          _buildResultRow(AppLocalizations.of(context)!.posStoreClosingOthers, report.systemOthersGross, report.physicalOthers, report.othersDiff),
          const Divider(height: 20),
          _buildResultTableFooter(report),
        ],
      ),
    );
  }

  Widget _buildResultHeader({bool showGrossNetLegend = false}) {
    final hdrStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.grey.shade500,
      fontSize: 12,
    );
    final subStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: Colors.grey.shade400,
      fontSize: 9,
    );
    Widget hdrCol(String top, String? bottom, double w) {
      return SizedBox(
        width: w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(top, textAlign: TextAlign.right, style: hdrStyle),
            if (bottom != null) Text(bottom, textAlign: TextAlign.right, style: subStyle),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            AppLocalizations.of(context)!.posStoreClosingCategory,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12),
          ),
        ),
        showGrossNetLegend
            ? hdrCol(AppLocalizations.of(context)!.posStoreClosingSystem, AppLocalizations.of(context)!.posStoreClosingGross, 64)
            : SizedBox(
                width: 64,
                child: Text(AppLocalizations.of(context)!.posStoreClosingSystem, textAlign: TextAlign.right, style: hdrStyle),
              ),
        SizedBox(
          width: 72,
          child: Text(
            AppLocalizations.of(context)!.posStoreClosingPhysical,
            textAlign: TextAlign.right,
            maxLines: 1,
            style: hdrStyle,
          ),
        ),
        showGrossNetLegend
            ? hdrCol(AppLocalizations.of(context)!.posStoreClosingDiff, AppLocalizations.of(context)!.posStoreClosingNet, 56)
            : SizedBox(
                width: 56,
                child: Text(AppLocalizations.of(context)!.posStoreClosingDiff, textAlign: TextAlign.right, style: hdrStyle),
              ),
      ],
    );
  }

  Widget _buildResultRow(
      String label, double system, double physical, double diff) {
    // diff = system - physical: positive = cashier short (red), negative = cashier excess (green)
    final diffColor =
        diff == 0 ? Colors.green : (diff > 0 ? Colors.red : Colors.green);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 13, color: Colors.grey.shade800),
          ),
        ),
        SizedBox(
          width: 64,
          child: Text(
            _storeDigits(system.toStringAsFixed(2)),
            textAlign: TextAlign.right,
            style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500),
          ),
        ),
        SizedBox(
          width: 72,
          child: Text(
            _storeDigits(physical.toStringAsFixed(2)),
            textAlign: TextAlign.right,
            style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondaryLight,
                fontWeight: FontWeight.w800),
          ),
        ),
        SizedBox(
          width: 56,
          child: Text(
            _storeSignedAmount(diff),
            textAlign: TextAlign.right,
            style: TextStyle(
                fontWeight: FontWeight.w900, fontSize: 13, color: diffColor),
          ),
        ),
      ],
    );
  }

  /// Column totals, optional sales-return deduction, then net grand total (aligned with table).
  Widget _buildResultTableFooter(StoreClosingReport report) {
    final sys = report.systemBucketsSumGross;
    final phy = report.physicalTotal;
    final dsum = report.diffBucketsSum;
    final diffColor =
        dsum == 0 ? Colors.green : (dsum > 0 ? Colors.red : Colors.green);

    Widget sumCell(String text, {Color? color, FontWeight w = FontWeight.w800}) {
      return Text(
        text,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: 13,
          fontWeight: w,
          color: color ?? Colors.grey.shade800,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.posSalesReturnTotal,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: AppColors.secondaryLight,
                ),
              ),
            ),
            SizedBox(width: 64, child: sumCell(_storeDigits(sys.toStringAsFixed(2)))),
            SizedBox(width: 72, child: sumCell(_storeDigits(phy.toStringAsFixed(2)))),
            SizedBox(
              width: 56,
              child: sumCell(
                _storeSignedAmount(dsum),
                color: diffColor,
              ),
            ),
          ],
        ),
        if (report.salesReturnsTotal > 0.001) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.posStoreClosingLessSalesReturn,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: AppColors.secondaryLight,
                    ),
                  ),
                ),
                Text(
                  '− ${_storeMoney(report.salesReturnsTotal)}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: AppColors.secondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.posStoreClosingGrandTotal,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: AppColors.secondaryLight,
                  ),
                ),
              ),
              Text(
                _storeMoney(report.systemSales),
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: AppColors.secondaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(
      bool isTablet, PosViewModel posVm, StoreClosingViewModel closingVm) {
    return Container(
      padding: closingVm.isReconciled
          ? const EdgeInsets.symmetric(vertical: 8)
          : const EdgeInsets.fromLTRB(24, 16, 24, 16),
      decoration: BoxDecoration(
        color: closingVm.isReconciled ? Colors.transparent : Colors.white,
        border: closingVm.isReconciled
            ? null
            : Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          if (!closingVm.isReconciled)
            Expanded(
              child: ElevatedButton(
                onPressed: (!closingVm.isReconciling)
                    ? () => closingVm.reconcile(
                          posVm.branchName,
                          posVm.cashierName,
                          context,
                        )
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  foregroundColor: AppColors.secondaryLight,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 6,
                  shadowColor: AppColors.primaryLight.withOpacity(0.3),
                ),
                child: closingVm.isReconciling
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.secondaryLight))
                    : Text(AppLocalizations.of(context)!.posStoreClosingCloseShift,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5)),
              ),
            )
          else ...[
            Expanded(
              child: Tooltip(
                message:
                    AppLocalizations.of(context)!.posStoreClosingPrinterHint,
                child: GestureDetector(
                  onLongPress: _closingThermalPrintBusy
                      ? null
                      : () async {
                          final ok =
                              await showThermalPrinterWifiDialog(context);
                          if (!mounted) return;
                          if (ok) {
                            ToastService.showSuccess(
                              context,
                              AppLocalizations.of(context)!.posStoreClosingSaveSuccess,
                            );
                          }
                        },
                  child: ElevatedButton(
                    onPressed: (_closingThermalPrintBusy ||
                            closingVm.report == null)
                        ? null
                        : () async {
                            final rpt = closingVm.report;
                            if (rpt == null) return;
                            setState(() => _closingThermalPrintBusy = true);
                            try {
                              await executeStoreClosingThermalPrint(
                                report: rpt,
                                closingId: closingVm.closingId,
                              );
                              if (!mounted) return;
                              ToastService.showSuccess(
                                context,
                                AppLocalizations.of(context)!.posStoreClosingReceiptSent,
                              );
                            } catch (e) {
                              if (!mounted) return;
                              ToastService.showError(
                                  context, e.toString());
                            } finally {
                              if (mounted) {
                                setState(
                                    () => _closingThermalPrintBusy = false);
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryLight,
                      foregroundColor: AppColors.onSecondaryLight,
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    child: _closingThermalPrintBusy
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.onSecondaryLight,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.posStoreClosingPrint,
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _showLogoutDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  foregroundColor: AppColors.secondaryLight,
                  minimumSize: const Size(0, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 6,
                  shadowColor:
                      AppColors.primaryLight.withValues(alpha: 0.35),
                ),
                child: Text(
                  AppLocalizations.of(context)!.posStoreClosingFinalLogout,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.white,
        child: Container(
          width: 400,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.posStoreClosingLogout,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.secondaryLight),
              ),
              const SizedBox(height: 10),
              Text(
                AppLocalizations.of(context)!.posStoreClosingLogoutConfirm,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Text(AppLocalizations.of(context)!.posStoreClosingCancel,
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondaryLight)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await context.read<LoginViewModel>().logout();
                        if (context.mounted) {
                          RestartWidget.restartApp(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(AppLocalizations.of(context)!.posStoreClosingLogout,
                          style: TextStyle(
                              color: AppColors.secondaryLight,
                              fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
