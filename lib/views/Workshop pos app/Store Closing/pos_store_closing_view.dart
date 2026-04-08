import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/pos_tablet_layout.dart';
import '../../../utils/app_text_styles.dart';
import '../Home Screen/pos_view_model.dart';
import '../../Menu/menu_view.dart';
import '../../../widgets/pos_widgets.dart';
import '../../../widgets/pos_shell_rail_layout.dart';
import '../Login/login_view_model.dart';
import 'package:filter_service_providers/utils/restart_widget.dart';
import 'store_closing_view_model.dart';

class PosStoreClosingView extends StatefulWidget {
  const PosStoreClosingView({super.key});

  @override
  State<PosStoreClosingView> createState() => _PosStoreClosingViewState();
}

class _PosStoreClosingViewState extends State<PosStoreClosingView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<StoreClosingViewModel>();
      vm.reset();
      vm.loadSummary();
    });
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
                'Store Closing',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? PosTabletLayout.appBarTitleSize : 19,
                ),
              ),
            )
          : const PosScreenAppBar(
              title: 'Store Closing',
              showBackButton: false,
              showGlobalLeft: true,
              showHamburger: false,
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
                _buildSectionTitle('Counter Reconciliation', Icons.account_balance_rounded),
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
                    'RECONCILIATION SUMMARY',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Shift Closing Status',
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
              _buildSummaryItem('Cashier', posVm.cashierName, Icons.person_outline),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.1),
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),
              _buildSummaryItem(
                'Branch',
                posVm.branchName.isNotEmpty ? posVm.branchName : 'Main Branch',
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
          Text(
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
            'Physical Drawer Count',
            style: AppTextStyles.h3.copyWith(fontSize: 15, color: const Color(0xFF1E2124)),
          ),
          const SizedBox(height: 6),
          Text(
            'Enter the physical amounts you have counted for each payment category.',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey, fontSize: 12),
          ),

          const SizedBox(height: 20),
          _buildInputField(
            label: 'Physical Cash Amount',
            controller: closingVm.cashController,
            icon: Icons.payments_outlined,
            hint: summary != null ? 'Expected: SAR ${summary.systemCash.toStringAsFixed(2)}' : null,
            onChanged: (_) => closingVm.updatePhysicalCount(),
          ),
          const SizedBox(height: 16),
          _buildInputField(
            label: 'Bank / Card Slips',
            controller: closingVm.bankController,
            icon: Icons.credit_card_outlined,
            hint: summary != null ? 'Expected: SAR ${summary.systemBank.toStringAsFixed(2)}' : null,
            onChanged: (_) => closingVm.updatePhysicalCount(),
          ),
          const SizedBox(height: 16),
          _buildInputField(
            label: 'Corporate Invoices',
            controller: closingVm.corporateController,
            icon: Icons.business_outlined,
            hint: summary != null ? 'Expected: SAR ${summary.systemCorporate.toStringAsFixed(2)}' : null,
            onChanged: (_) => closingVm.updatePhysicalCount(),
          ),
          const SizedBox(height: 16),
          _buildInputField(
            label: 'Tamara Credits',
            controller: closingVm.tamaraController,
            icon: Icons.receipt_long_outlined,
            hint: summary != null ? 'Expected: SAR ${summary.systemTamara.toStringAsFixed(2)}' : null,
            onChanged: (_) => closingVm.updatePhysicalCount(),
          ),
          const SizedBox(height: 16),
          _buildInputField(
            label: 'Tabby Credits',
            controller: closingVm.tabbyController,
            icon: Icons.receipt_long_outlined,
            hint: summary != null ? 'Expected: SAR ${summary.systemTabby.toStringAsFixed(2)}' : null,
            onChanged: (_) => closingVm.updatePhysicalCount(),
          ),
          const SizedBox(height: 16),
          _buildInputField(
            label: 'Notes (Optional)',
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
                const Text(
                  'Total Physical Sum',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.secondaryLight),
                ),
                Text(
                  'SAR ${closingVm.physicalTotal.toStringAsFixed(2)}',
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
            'SAR ${amount.toStringAsFixed(2)}',
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
              hintText: hint ?? (isNumeric ? '0.00' : 'Add notes here...'),
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
                            ? 'Shift Balanced'
                            : 'Discrepancy Detected',
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
                            ? 'Shift closed successfully.'
                            : 'Positive diff = system > physical.',
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
                  Text('Closing ID',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600)),
                  Text(
                    closingVm.closingId!,
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
          _buildResultHeader(),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _buildResultRow('Cash Account', report.systemCash, report.physicalCash, report.cashDiff),
          const SizedBox(height: 12),
          _buildResultRow('Bank / Cards', report.systemBank, report.physicalBank, report.bankDiff),
          const SizedBox(height: 12),
          _buildResultRow('Corporate', report.systemCorporate, report.physicalCorporate, report.corporateDiff),
          const SizedBox(height: 12),
          _buildResultRow('Tamara', report.systemTamara, report.physicalTamara, report.tamaraDiff),
          const SizedBox(height: 12),
          _buildResultRow('Tabby', report.systemTabby, report.physicalTabby, report.tabbyDiff),
          const Divider(height: 32),
          _buildTotalDifferenceRow(closingVm),
          const SizedBox(height: 12),
          _buildSystemSalesRow(report.systemSales),
        ],
      ),
    );
  }

  Widget _buildResultHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text('Category',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
        ),
        SizedBox(
          width: 64,
          child: Text('System',
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade500, fontSize: 12)),
        ),
        SizedBox(
          width: 72,
          child: Text('Physical',
              textAlign: TextAlign.right,
              maxLines: 1,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade500, fontSize: 12)),
        ),
        SizedBox(
          width: 56,
          child: Text('Diff',
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade500, fontSize: 12)),
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
            system.toStringAsFixed(0),
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
            physical.toStringAsFixed(0),
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
            (diff >= 0 ? '+' : '') + diff.toStringAsFixed(0),
            textAlign: TextAlign.right,
            style: TextStyle(
                fontWeight: FontWeight.w900, fontSize: 13, color: diffColor),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalDifferenceRow(StoreClosingViewModel closingVm) {
    if (closingVm.report == null) return const SizedBox();
    final netDiff = closingVm.report!.netDifference;

    // netDiff = system - physical
    // positive → system > physical → cashier is SHORT (owes money) → red, show as −
    // negative → physical > system → cashier has EXCESS → green, show as +
    // zero → balanced → green
    final isShort = netDiff > 0;
    final isExcess = netDiff < 0;
    final diffColor =
        netDiff == 0 ? Colors.green : (isShort ? Colors.red : Colors.green);
    final statusLabel =
        netDiff == 0 ? 'BALANCED' : (isShort ? 'SHORT' : 'EXCESS');
    final displayAmount = netDiff.abs();
    final displaySign = isShort ? '−' : (isExcess ? '+' : '');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: diffColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: diffColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total Difference',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: diffColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: diffColor,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          Text(
            '$displaySign SAR ${displayAmount.toStringAsFixed(2)}',
            style: TextStyle(
                fontWeight: FontWeight.w800, fontSize: 18, color: diffColor),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemSalesRow(double systemSales) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondaryLight.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('System Total Sales',
              style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.secondaryLight)),
          Text(
            'SAR ${systemSales.toStringAsFixed(2)}',
            style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: AppColors.secondaryLight),
          ),
        ],
      ),
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
                onPressed: (closingVm.physicalTotal > 0 && !closingVm.isReconciling)
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
                    : const Text('Close Shift',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5)),
              ),
            )
          else ...[
            Expanded(
              child: ElevatedButton(
                onPressed:
                    closingVm.isGeneratingReport ? null : () => closingVm.buildReport(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  foregroundColor: AppColors.secondaryLight,
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: closingVm.isGeneratingReport
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.secondaryLight))
                    : const Text('Generate Report',
                        style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _showLogoutDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF44336),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 6,
                  shadowColor: Colors.red.withOpacity(0.3),
                ),
                child: const Text('Final Logout',
                    style: TextStyle(fontWeight: FontWeight.w700)),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Log out',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.secondaryLight),
              ),
              const SizedBox(height: 10),
              const Text(
                'Are you sure you want to log out from your account?',
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
                      child: const Text('Cancel',
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
                      child: const Text('Log out',
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
