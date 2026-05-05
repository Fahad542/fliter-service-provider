import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/LocalizedApiText.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../utils/app_colors.dart';
import '../../../widgets/pos_widgets.dart';
import '../../../widgets/pos_shell_rail_layout.dart';
import '../../../utils/pos_shell_scaffold.dart' show PosShellScaffoldRegistry;
import 'sales_return_list_view_model.dart';
import '../../../models/sales_return_list_model.dart';

class PosSalesReturnListView extends StatefulWidget {
  const PosSalesReturnListView({super.key});

  @override
  State<PosSalesReturnListView> createState() => _PosSalesReturnListViewState();
}

class _PosSalesReturnListViewState extends State<PosSalesReturnListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalesReturnListViewModel>().fetchReturns(refresh: true);
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final vm = context.read<SalesReturnListViewModel>();
      if (!vm.isLoading && vm.hasMore) {
        vm.fetchReturns();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final vm = context.watch<SalesReturnListViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PosScreenAppBar(
        title: AppLocalizations.of(context)!.posSalesReturnListTitle,
        showBackButton: false,
        showHamburger: true,
        onMenuPressed: () =>
            PosShellScaffoldRegistry.openDrawer(),
      ),
      body: wrapPosShellRailBody(
        context,
        RefreshIndicator(
          onRefresh: () => vm.fetchReturns(refresh: true),
          color: AppColors.primaryLight,
          child: _buildBody(vm, isTablet),
        ),
      ),
    );
  }

  Widget _buildBody(SalesReturnListViewModel vm, bool isTablet) {
    if (vm.isLoading && vm.returns.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.error != null && vm.returns.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.posSalesReturnListFailedLoad,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => vm.fetchReturns(refresh: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: Colors.black,
              ),
              child: Text(AppLocalizations.of(context)!.posCommonRetry),
            ),
          ],
        ),
      );
    }

    if (vm.returns.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_return_rounded,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.posSalesReturnListNoReturns,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    return GridView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? (isLandscape ? 3 : 2) : 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: isTablet ? (isLandscape ? 225 : 240) : 210,
      ),
      itemCount: vm.returns.length + (vm.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == vm.returns.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final item = vm.returns[index];
        return _buildReturnCard(item, isTablet);
      },
    );
  }

  Widget _buildReturnCard(SalesReturnInfo returnInfo, bool isTablet) {
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    final date = DateTime.tryParse(returnInfo.returnDate) ?? DateTime.now();
    final localeCode = Localizations.localeOf(context).languageCode;
    final formattedDate = DateFormat('MMM dd, yyyy • hh:mm a', localeCode == 'ar' ? 'ar' : 'en').format(date);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onDoubleTap: () {}, // Prevent accidental taps
            onTap: () => _showReturnDetails(returnInfo, isTablet),
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 24 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          returnInfo.returnNo,
                          style: const TextStyle(
                            color: AppColors.secondaryLight,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Spacer(),
                      _buildStatusBadge(returnInfo.status),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Icon(
                          Icons.receipt_long_rounded,
                          color: AppColors.secondaryLight,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.posSalesReturnListInvoiceLabel(returnInfo.invoiceNo),
                              style: TextStyle(
                                fontSize: isLandscape ? 15 : 17,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF2D3139),
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: isLandscape ? 11.5 : 13,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (returnInfo.reason != null &&
                          returnInfo.reason!.isNotEmpty)
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.info_outline_rounded,
                                  size: 16, color: Colors.grey.shade600),
                              const SizedBox(width: 8),
                              Expanded(
                                child: LocalizedApiText(
                                  returnInfo.reason!,
                                  style: TextStyle(
                                    fontSize: isLandscape ? 11.5 : 13,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.posSalesReturnRefundAmount,
                            style: TextStyle(
                              fontSize: isLandscape ? 10 : 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade400,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppLocalizations.of(context)!.posSalesReturnSarAmount(returnInfo.totalAmount.toStringAsFixed(2)),
                            style: TextStyle(
                              fontSize: isLandscape ? 18 : 20,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF109D59), // Material Green 700
                              letterSpacing: -0.8,
                            ),
                          ),
                        ],
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
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green.shade600;
      case 'pending':
        return Colors.orange.shade600;
      case 'cancelled':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  Widget _buildStatusBadge(String status) {
    Color color = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: LocalizedApiText(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  void _showReturnDetails(SalesReturnInfo returnInfo, bool isTablet) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? 120 : 20,
          vertical: 40,
        ),
        child: _ReturnDetailsDialog(returnInfo: returnInfo, isTablet: isTablet),
      ),
    );
  }
}

class _ReturnDetailsDialog extends StatelessWidget {
  final SalesReturnInfo returnInfo;
  final bool isTablet;

  const _ReturnDetailsDialog({required this.returnInfo, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(30, 24, 20, 20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.posSalesReturnDetailsTitle,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E2124),
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.posSalesReturnDetailsSubtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 26),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.all(10),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Grid
                  _buildDetailedGrid(context, isTablet),
                  
                  const SizedBox(height: 32),
                  
                  // Section Title
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        AppLocalizations.of(context)!.posSalesReturnItemsReturned,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E2124),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Product List
                  ...returnInfo.items.map((item) => _buildItemRow(context, item)),
                ],
              ),
            ),
          ),

          // Footer Action
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade100)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryLight,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.posSalesReturnCloseDetails,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedGrid(BuildContext context, bool isTablet) {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: [
        _buildDetailItem(AppLocalizations.of(context)!.posSalesReturnNoLabel, returnInfo.returnNo, Icons.tag_rounded),
        _buildDetailItem(AppLocalizations.of(context)!.posSalesReturnInvoiceNoLabel, returnInfo.invoiceNo, Icons.receipt_rounded),
        _buildDetailItem(AppLocalizations.of(context)!.posSalesReturnOrderIdLabel, returnInfo.orderId, Icons.shopping_bag_rounded),
        _buildDetailItem(
          AppLocalizations.of(context)!.posSalesReturnCustomerLabel,
          returnInfo.customerName.isNotEmpty ? returnInfo.customerName : returnInfo.customerId,
          Icons.person_rounded,
        ),
        _buildDetailItem(AppLocalizations.of(context)!.posSalesReturnTotalRefund, AppLocalizations.of(context)!.posSalesReturnSarAmount(returnInfo.totalAmount.toStringAsFixed(2)), Icons.payments_rounded, isAmount: true),
        if (returnInfo.reason != null)
          _buildDetailItem(AppLocalizations.of(context)!.posSalesReturnReasonLabel, returnInfo.reason!, Icons.comment_rounded, isFullWidth: true),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon, {bool isAmount = false, bool isFullWidth = false}) {
    return SizedBox(
      width: isFullWidth ? double.infinity : (isTablet ? 240 : 130),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 4),
                LocalizedApiText(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isAmount ? FontWeight.w900 : FontWeight.w700,
                    color: isAmount ? const Color(0xFF109D59) : const Color(0xFF2D3139),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(BuildContext context, SalesReturnItemInfo item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(Icons.inventory_2_rounded,
                size: 22, color: AppColors.secondaryLight),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.posSalesReturnItemId(item.salesOrderItemId),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: Color(0xFF2D3139),
                  ),
                ),
                if (item.reason != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: LocalizedApiText(
                      item.reason!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppLocalizations.of(context)!.posSalesReturnItemQty(item.qty.toString()),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                AppLocalizations.of(context)!.posSalesReturnSarAmount(item.lineTotal.toStringAsFixed(2)),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: AppColors.secondaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
