import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../widgets/pos_widgets.dart';
import '../../../widgets/pos_shell_rail_layout.dart';
import '../../../utils/pos_shell_scaffold.dart' show PosShellScaffoldRegistry;
import '../../../models/create_invoice_model.dart';
import '../../../l10n/app_localizations.dart';
import 'sales_return_view_model.dart';

class PosSalesReturnView extends StatefulWidget {
  /// Set to true when pushed via Navigator.push (e.g. from Home Screen).
  /// Set to false (default) when shown as a shell tab from the drawer.
  final bool showBackButton;
  const PosSalesReturnView({super.key, this.showBackButton = false});

  @override
  State<PosSalesReturnView> createState() => _PosSalesReturnViewState();
}

class _PosSalesReturnViewState extends State<PosSalesReturnView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<SalesReturnViewModel>();
      // Only clear state when shown as a shell/drawer tab (not when pushed with pre-filled state)
      if (!widget.showBackButton) {
        vm.clearSelection();
        vm.searchController.clear();
        vm.searchInvoice(); // clears results
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final vm = context.watch<SalesReturnViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: PosScreenAppBar(
        title: (!isTablet && vm.selectedInvoice != null)
            ? 'Return - ${vm.selectedInvoice!.invoiceNo.isNotEmpty ? vm.selectedInvoice!.invoiceNo : vm.selectedInvoice!.id}'
            : 'Sales Return',
        showBackButton: widget.showBackButton || (!isTablet && vm.selectedInvoice != null),
        showHamburger: !widget.showBackButton && !(!isTablet && vm.selectedInvoice != null),
        onMenuPressed: () =>
            PosShellScaffoldRegistry.openDrawer(),
        onBack: () {
          if (!isTablet && vm.selectedInvoice != null) {
            vm.clearSelection();
          } else if (widget.showBackButton) {
            vm.clearSelection();
            Navigator.pop(context);
          }
        },
      ),
      body: wrapPosShellRailBody(
        context,
        Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left side: Search and Results
          if (isTablet || vm.selectedInvoice == null)
            Expanded(
              flex: isTablet ? 4 : 10,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Column(
                  children: [
                    _buildSearchHeader(vm, isTablet),
                    SizedBox(height: isTablet ? 4 : 8),
                    if (vm.searchResults.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 14 : 20,
                          vertical: isTablet ? 4 : 8,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 3,
                              height: isTablet ? 13 : 16,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Results',
                              style: TextStyle(
                                fontSize: isTablet ? 12 : 14,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1E2124),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(child: _buildSearchResults(vm, isTablet)),
                  ],
                ),
              ),
            ),

          if (isTablet)
            VerticalDivider(
                width: 1,
                color: Colors.grey.shade300.withValues(alpha: 0.5)),
          // Right side: Return Form (visible if invoice selected)
          if (isTablet || vm.selectedInvoice != null)
            Expanded(
              flex: isTablet ? 6 : (vm.selectedInvoice != null ? 10 : 0),
              child: vm.selectedInvoice == null
                  ? _buildEmptyState(isTablet)
                  : _buildReturnDetails(vm, isTablet),
            ),
        ],
      ),
      ),
    );
  }

  Widget _buildSearchHeader(SalesReturnViewModel vm, bool isTablet) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isTablet ? 14 : 16,
        isTablet ? 12 : 22,
        isTablet ? 14 : 16,
        isTablet ? 4 : 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: vm.searchController,
                    textCapitalization: TextCapitalization.characters,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 15 : 17,
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g. INV-123 or Name/Phone',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w500,
                        fontSize: isTablet ? 14 : 16,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Colors.grey.shade400,
                        size: isTablet ? 22 : 26,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 12 : 14,
                        vertical: isTablet ? 13 : 18,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      isDense: true,
                    ),
                    onChanged: (value) {
                      if (value.trim().isEmpty) {
                        vm.clearSearchResults();
                      }
                    },
                    onSubmitted: (_) => vm.searchInvoice(),
                  ),
                ),
              ),
              SizedBox(width: isTablet ? 8 : 12),
              SizedBox(
                  height: isTablet ? 46 : 50,
                  width: isTablet ? 46 : 50,
                  child: ElevatedButton(
                    onPressed: vm.isSearching ? null : vm.searchInvoice,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLight,
                      foregroundColor: AppColors.secondaryLight,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: vm.isSearching
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.secondaryLight,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(Icons.send_rounded,
                            size: isTablet ? 20 : 22,
                            color: AppColors.secondaryLight),
                  ),
                ),
              
            ],
          ),
          if (vm.searchError != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: Colors.red.shade600,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      vm.searchError!,
                      style: TextStyle(
                        color: Colors.red.shade800,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ]
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchResults(SalesReturnViewModel vm, bool isTablet) {
    if (vm.searchController.text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    if (vm.isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.searchController.text.isNotEmpty &&
        vm.searchResults.isEmpty &&
        vm.searchError == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              'No invoices found for "${vm.searchController.text}"',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 12 : 16,
        vertical: isTablet ? 4 : 8,
      ),
      itemCount: vm.searchResults.length,
      itemBuilder: (context, index) {
        final inv = vm.searchResults[index];
        final isSelected = vm.selectedInvoice?.id == inv.id;
        final isTablet = MediaQuery.of(context).size.width > 600;
        final cardR = isTablet ? 14.0 : 20.0;

        return Padding(
          padding: EdgeInsets.only(bottom: isTablet ? 8 : 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(cardR),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryLight.withValues(alpha: 0.8)
                    : Colors.grey.shade200,
                width: isSelected ? 2.0 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? AppColors.primaryLight.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.03),
                  blurRadius: isSelected ? 16 : (isTablet ? 8 : 12),
                  offset: isSelected ? const Offset(0, 5) : const Offset(0, 3),
                  spreadRadius: isSelected ? -1 : 0,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => vm.selectInvoice(inv),
                borderRadius: BorderRadius.circular(cardR),
                  child: Padding(
                  padding: EdgeInsets.all(isTablet ? 12 : 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (inv.invoiceDate.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(bottom: isTablet ? 5 : 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: isTablet ? 12 : 12,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                inv.invoiceDate.split('T')[0],
                                style: TextStyle(
                                  fontSize: isTablet ? 11 : 12,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(isTablet ? 8 : 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryLight.withValues(alpha: 0.15)
                                  : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryLight.withValues(alpha: 0.3)
                                    : Colors.grey.shade200,
                              ),
                            ),
                            child: Icon(
                              Icons.receipt_long_rounded,
                              size: isTablet ? 18 : 18,
                              color: isSelected
                                  ? AppColors.primaryLight
                                  : AppColors.secondaryLight,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              inv.invoiceNo.isNotEmpty ? inv.invoiceNo : inv.id,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: isTablet ? 14 : 15,
                                color: const Color(0xFF1E2124),
                                letterSpacing: -0.3,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 9 : 10,
                              vertical: isTablet ? 5 : 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.green.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              'SAR ${inv.totalAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Colors.green.shade700,
                                fontSize: isTablet ? 12 : 13,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isTablet ? 6 : 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person_outline_rounded,
                              size: isTablet ? 15 : 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              inv.customerName.isNotEmpty
                                  ? inv.customerName
                                  : 'Walk-in Customer',
                              style: TextStyle(
                                fontSize: isTablet ? 13 : 14,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isTablet) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 28 : 32),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              Icons.assignment_return_rounded,
              size: isTablet ? 64 : 64,
              color: AppColors.secondaryLight.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: isTablet ? 18 : 32),
          Text(
            'Select an Invoice',
            style: TextStyle(
              fontSize: isTablet ? 19 : 24,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1E2124),
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: isTablet ? 8 : 12),
          Text(
            'Search and select an invoice from the left\nto initiate its sales return process.',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: isTablet ? 13 : 15,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReturnDetails(SalesReturnViewModel vm, bool isTablet) {
    final inv = vm.selectedInvoice!;
    final selectedCount = vm.selectedItems.values.where((v) => v).length;

    return Container(
      color: AppColors.primaryLight.withValues(alpha: 0.07),
      child: Column(
        children: [
          // ── Invoice Summary Header ──
          Container(
            margin: EdgeInsets.fromLTRB(
              isTablet ? 14 : 16, isTablet ? 12 : 16,
              isTablet ? 14 : 16, 0,
            ),
            padding: EdgeInsets.all(isTablet ? 14 : 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1E2124),
                  const Color(0xFF2C3036),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E2124).withValues(alpha: 0.2),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isTablet ? 10 : 14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryLight.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    color: AppColors.primaryLight,
                    size: isTablet ? 22 : 26,
                  ),
                ),
                SizedBox(width: isTablet ? 12 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inv.invoiceNo.isNotEmpty ? inv.invoiceNo : inv.id,
                        style: TextStyle(
                          fontSize: isTablet ? 17 : 19,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: isTablet ? 3 : 5),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: isTablet ? 12 : 12,
                            color: Colors.white54,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              inv.customerName.isNotEmpty
                                  ? inv.customerName
                                  : 'Walk-in Customer',
                              style: TextStyle(
                                fontSize: isTablet ? 12 : 14,
                                color: Colors.white60,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (inv.invoiceDate.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.calendar_today_rounded,
                              size: isTablet ? 11 : 11,
                              color: Colors.white38,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              inv.invoiceDate.split('T')[0],
                              style: TextStyle(
                                fontSize: isTablet ? 10 : 11,
                                color: Colors.white38,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: isTablet ? 10 : 11,
                        color: Colors.white38,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'SAR ${inv.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 17,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryLight,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Scrollable Body ──
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                isTablet ? 14 : 16, isTablet ? 12 : 22,
                isTablet ? 14 : 16, isTablet ? 14 : 22,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Items section header
                  Row(
                    children: [
                      Container(
                        width: 3,
                        height: isTablet ? 14 : 18,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.inventory_2_rounded,
                          size: isTablet ? 14 : 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        'Select Items to Return',
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E2124),
                        ),
                      ),
                      const Spacer(),
                      if (selectedCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$selectedCount selected',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: isTablet ? 10 : 14),

                  // Item List
                  ...inv.items
                      .map((item) => _buildReturnItemRow(item, vm, isTablet)),

                  SizedBox(height: isTablet ? 16 : 28),

                  // Proof section header
                  Row(
                    children: [
                      Container(
                        width: 3,
                        height: isTablet ? 14 : 18,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryLight,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.add_photo_alternate_rounded,
                          size: isTablet ? 14 : 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        'Return Proof',
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E2124),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Optional',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isTablet ? 10 : 14),
                  _buildImagePicker(vm, isTablet),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // ── Bottom Action Bar ──
          Container(
            padding: EdgeInsets.fromLTRB(
              isTablet ? 14 : 16, isTablet ? 10 : 14,
              isTablet ? 14 : 16,
              MediaQuery.of(context).padding.bottom + (isTablet ? 10 : 14),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade100)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: Row(
              children: [
                SizedBox(
                  height: isTablet ? 48 : 58,
                  child: ElevatedButton(
                    onPressed: vm.isSubmitting ? null : vm.clearSelection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryLight,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: isTablet ? 18 : 26),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: isTablet ? 14 : 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isTablet ? 8 : 12),
                Expanded(
                  child: SizedBox(
                    height: isTablet ? 48 : 58,
                    child: ElevatedButton(
                      onPressed: vm.isSubmitting
                          ? null
                          : () => vm.submitReturnRequest(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: vm.isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              'Submit Return',
                              style: TextStyle(
                                color: AppColors.secondaryLight,
                                fontWeight: FontWeight.w800,
                                fontSize: isTablet ? 14 : 16,
                                letterSpacing: 0.3,
                              ),
                            ),
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

  Widget _buildReturnItemRow(
      InvoiceItem item, SalesReturnViewModel vm, bool isTablet) {
    final isSelected = vm.selectedItems[item.id] ?? false;
    final double qty = vm.returnQuantities[item.id] ?? 0.0;
    final reason = vm.returnReasons[item.id];

    final cardR = isTablet ? 14.0 : 20.0;
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 8 : 12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.white,
        borderRadius: BorderRadius.circular(cardR),
        border: Border.all(
          color: isSelected ? AppColors.primaryLight : Colors.grey.shade200,
          width: isSelected ? 2.0 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppColors.primaryLight.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: isSelected ? 14 : (isTablet ? 6 : 10),
            offset: isSelected ? const Offset(0, 4) : const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            InkWell(
              onTap: () =>
                  vm.toggleItemSelection(item.id, !isSelected, item.qty),
              borderRadius: isSelected
                  ? BorderRadius.vertical(top: Radius.circular(cardR))
                  : BorderRadius.circular(cardR),
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 14 : 24),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryLight
                            : Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryLight
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryLight.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      width: isTablet ? 26 : 26,
                      height: isTablet ? 26 : 26,
                      child: isSelected
                          ? Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: isTablet ? 18 : 18,
                            )
                          : null,
                    ),
                    SizedBox(width: isTablet ? 10 : 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: isTablet ? 14 : 17,
                              color: isSelected
                                  ? AppColors.primaryLight
                                  : const Color(0xFF1E2124),
                            ),
                          ),
                          SizedBox(height: isTablet ? 3 : 5),
                          Text(
                            '${item.qty.toStringAsFixed(0)}x @ SAR ${item.unitPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: isTablet ? 12 : 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 10 : 14,
                        vertical: isTablet ? 5 : 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryLight.withValues(alpha: 0.1)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryLight.withValues(alpha: 0.2)
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Text(
                        'SAR ${(item.qty * item.unitPrice).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: isTablet ? 13 : 15,
                          color: isSelected
                              ? AppColors.primaryLight
                              : const Color(0xFF1E2124),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Expanded Return Config
            if (isSelected)
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade100, width: 1.5),
                  ),
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(cardR),
                  ),
                ),
                padding: EdgeInsets.all(isTablet ? 14 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Qty Stepper
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 12 : 16,
                        vertical: isTablet ? 8 : 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(isTablet ? 5 : 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight.withValues(
                                    alpha: 0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.numbers_rounded,
                                  size: isTablet ? 14 : 16,
                                  color: AppColors.primaryLight,
                                ),
                              ),
                              SizedBox(width: isTablet ? 8 : 12),
                              Text(
                                'Return Qty',
                                style: TextStyle(
                                  fontSize: isTablet ? 12 : 14,
                                  color: const Color(0xFF1E2124),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          _buildStepper(item.id, qty, item.qty, vm, isTablet),
                        ],
                      ),
                    ),
                    SizedBox(height: isTablet ? 10 : 16),
                    // Reason Dropdown
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 12 : 20,
                        vertical: isTablet ? 2 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: reason,
                          isExpanded: true,
                          hint: Text(
                            'Select Return Reason',
                            style: TextStyle(
                              fontSize: isTablet ? 13 : 15,
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.grey.shade600,
                              size: isTablet ? 16 : 18,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: isTablet ? 13 : 15,
                            color: const Color(0xFF1E2124),
                            fontWeight: FontWeight.w700,
                          ),
                          items: vm.returnReasonOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            if (newValue != null) {
                              vm.updateReturnReason(item.id, newValue);
                            }
                          },
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

  Widget _buildStepper(
    String itemId,
    double currentQty,
    double maxQty,
    SalesReturnViewModel vm,
    bool isTablet,
  ) {
    final btnSize = isTablet ? 34.0 : 44.0;
    final iconSz = isTablet ? 18.0 : 22.0;
    final fieldW = isTablet ? 40.0 : 50.0;
    final fieldFs = isTablet ? 14.0 : 16.0;
    // Generate controller with the current value.
    final int currentInt = currentQty.toInt();
    final int maxInt = maxQty.toInt();
    final String displayVal = currentInt.toString();

    final controller = TextEditingController(text: displayVal);
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStepButton(
          icon: Icons.remove_rounded,
          isEnabled: currentInt > 0,
          size: btnSize,
          iconSize: iconSz,
          onPressed: () {
            final newQty = (currentInt - 1).clamp(0, maxInt).toDouble();
            vm.updateReturnQuantity(itemId, newQty);
          },
        ),
        Container(
          width: fieldW,
          alignment: Alignment.center,
          margin: EdgeInsets.symmetric(horizontal: isTablet ? 6 : 8),
          child: Focus(
            onFocusChange: (hasFocus) {
              if (!hasFocus) {
                final parsed = int.tryParse(controller.text);
                if (parsed != null && parsed >= 0 && parsed <= maxInt) {
                  vm.updateReturnQuantity(itemId, parsed.toDouble());
                } else {
                  vm.updateReturnQuantity(itemId, currentQty);
                  controller.text = displayVal;
                }
              }
            },
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: fieldFs,
                color: const Color(0xFF1E2124),
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onFieldSubmitted: (val) {
                final parsed = int.tryParse(val);
                if (parsed != null && parsed >= 0 && parsed <= maxInt) {
                  vm.updateReturnQuantity(itemId, parsed.toDouble());
                } else {
                  vm.updateReturnQuantity(itemId, currentQty);
                  controller.text = displayVal;
                }
              },
            ),
          ),
        ),
        _buildStepButton(
          icon: Icons.add_rounded,
          isEnabled: currentInt < maxInt,
          size: btnSize,
          iconSize: iconSz,
          onPressed: () {
            final newQty = (currentInt + 1).clamp(0, maxInt).toDouble();
            vm.updateReturnQuantity(itemId, newQty);
          },
        ),
      ],
    );
  }

  Widget _buildStepButton({
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onPressed,
    double size = 44,
    double iconSize = 22,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isEnabled ? AppColors.primaryLight : Colors.grey.shade100,
        shape: BoxShape.circle,
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: AppColors.primaryLight.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
        child: IconButton(
          icon: Icon(
            icon,
            size: iconSize,
          color: isEnabled ? Colors.white : Colors.grey.shade400,
        ),
        padding: EdgeInsets.zero,
        onPressed: isEnabled ? onPressed : null,
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E2124),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker(SalesReturnViewModel vm, bool isTablet) {
    return GestureDetector(
      onTap: vm.pickProofImage,
      child: Container(
        height: isTablet ? 120 : 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isTablet ? 14 : 20),
          border: Border.all(
            color: vm.proofImage != null
                ? AppColors.primaryLight.withValues(alpha: 0.5)
                : Colors.grey.shade200,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: vm.proofImage != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.file(vm.proofImage!, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: vm.pickProofImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_a_photo_rounded,
                      color: Colors.grey.shade500,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tap to upload proof image',
                    style: TextStyle(
                      color: const Color(0xFF1E2124),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'JPG, PNG up to 5MB',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
