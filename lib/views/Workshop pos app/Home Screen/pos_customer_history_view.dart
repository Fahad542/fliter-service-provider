import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/customer_search_model.dart';
import '../../../models/invoiced_orders_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../widgets/pos_widgets.dart';
import '../Home Screen/pos_view_model.dart';
import 'package:provider/provider.dart';

class PosCustomerHistoryView extends StatefulWidget {
  final SearchedCustomer customer;
  final String? focusOrderId;

  const PosCustomerHistoryView({
    super.key, 
    required this.customer,
    this.focusOrderId,
  });

  @override
  State<PosCustomerHistoryView> createState() => _PosCustomerHistoryViewState();
}

class _PosCustomerHistoryViewState extends State<PosCustomerHistoryView> {
  Future<InvoicedOrderResponse?>? _historyFuture;

  @override
  void initState() {
    super.initState();
    final vm = context.read<PosViewModel>();
    _historyFuture = vm.fetchCustomerInvoicedHistory(widget.customer.id);
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final customer = widget.customer;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      appBar: PosScreenAppBar(title: 'Customer History'),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 32 : 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCustomerProfile(isTablet, customer),

            const SizedBox(height: 32),
            Text(
              'Past Orders',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: isTablet ? 26 : 22,
                color: const Color(0xFF1E2124),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<InvoicedOrderResponse?>(
              future: _historyFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryLight,
                        strokeWidth: 3,
                      ),
                    ),
                  );
                }
                final orders = snapshot.data?.orders ?? [];
                if (orders.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No order history found for this customer.'),
                    ),
                  );
                }
                if (!isTablet) {
                  return Column(
                    children: [
                      for (int i = 0; i < orders.length; i++) ...[
                        _buildInvoicedOrderCard(orders[i], isTablet),
                        if (i < orders.length - 1) const SizedBox(height: 12),
                      ],
                    ],
                  );
                }
                final rows = (orders.length / 3).ceil();
                return Column(
                  children: [
                    for (int r = 0; r < rows; r++) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildInvoicedOrderSlot(
                              orders,
                              r * 3,
                              isTablet,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInvoicedOrderSlot(
                              orders,
                              r * 3 + 1,
                              isTablet,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInvoicedOrderSlot(
                              orders,
                              r * 3 + 2,
                              isTablet,
                            ),
                          ),
                        ],
                      ),
                      if (r < rows - 1) const SizedBox(height: 12),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryOrderCard(SearchedCustomerOrder order, bool isTablet) {
    final status = order.status.toLowerCase();
    Color statusColor;
    if (status == 'invoiced' || status == 'completed') {
      statusColor = const Color(0xFF27AE60);
    } else if (status.contains('pending') || status.contains('waiting') || status.contains('draft')) {
      statusColor = const Color(0xFFF2994A);
    } else if (status.contains('progress') || status.contains('accepted')) {
      statusColor = const Color(0xFF2D9CDB);
    } else {
      statusColor = Colors.grey;
    }

    String formattedDate = order.createdAt;
    try {
      final parsed = DateTime.parse(order.createdAt);
      formattedDate = DateFormat('dd MMM yyyy').format(parsed);
    } catch (_) {}

    return Container(
      padding: EdgeInsets.all(isTablet ? 18 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Order #${order.id}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: isTablet ? 15 : 13,
                    color: const Color(0xFF1E2124),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: isTablet ? 11 : 10,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (order.vehicle != null) ...[
            Row(
              children: [
                Icon(Icons.directions_car_rounded,
                    size: isTablet ? 15 : 13, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${order.vehicle!.make} ${order.vehicle!.model}  •  ${order.vehicle!.plateNo}'
                    '${(order.vehicle!.year != null && order.vehicle!.year!.isNotEmpty) ? '  ·  ${order.vehicle!.year}' : ''}'
                    '${(order.vehicle!.vin != null && order.vehicle!.vin!.isNotEmpty) ? '  ·  VIN ${order.vehicle!.vin}' : ''}',
                    style: TextStyle(
                      fontSize: isTablet ? 13 : 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
          Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  size: isTablet ? 13 : 11, color: Colors.grey.shade400),
              const SizedBox(width: 6),
              Text(
                formattedDate,
                style: TextStyle(
                  fontSize: isTablet ? 12 : 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (order.invoiceNo != null && order.invoiceNo!.isNotEmpty) ...[
                const SizedBox(width: 12),
                Icon(Icons.receipt_long_rounded,
                    size: isTablet ? 13 : 11, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(
                  'Invoice: ${order.invoiceNo}',
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvoicedOrderSlot(
    List<InvoicedOrder> orders,
    int index,
    bool isTablet,
  ) {
    if (index >= orders.length) return const SizedBox.shrink();
    return _buildInvoicedOrderCard(orders[index], isTablet, compact: true);
  }

  Widget _buildInvoicedOrderCard(
    InvoicedOrder order,
    bool isTablet, {
    bool compact = false,
  }) {
    String formattedDate = order.createdAt;
    try {
      final parsed = DateTime.parse(order.createdAt);
      formattedDate = DateFormat('dd MMM yyyy').format(parsed);
    } catch (_) {}

    final pad = compact
        ? 12.0
        : (isTablet ? 18.0 : 14.0);
    final invFs = compact
        ? 13.0
        : (isTablet ? 17.0 : 15.0);
    final invIcon = compact ? 14.0 : (isTablet ? 17.0 : 15.0);
    final totalFs = compact
        ? 15.0
        : (isTablet ? 19.0 : 17.0);
    final dateFs = compact
        ? 12.0
        : (isTablet ? 15.0 : 14.0);
    final dateIcon = compact ? 13.0 : (isTablet ? 15.0 : 14.0);
    final promoFs = compact ? 11.0 : (isTablet ? 14.0 : 13.0);
    final promoIcon = compact ? 13.0 : (isTablet ? 15.0 : 14.0);
    final lineNameFs = compact ? 12.0 : (isTablet ? 15.0 : 14.0);
    final lineQtyFs = compact ? 11.0 : (isTablet ? 14.0 : 13.0);
    final lineTotalFs = compact ? 12.0 : (isTablet ? 15.0 : 14.0);
    final moreFs = compact ? 12.0 : (isTablet ? 14.0 : 13.0);

    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: compact ? 8 : (isTablet ? 10 : 8),
                      vertical: compact ? 4 : (isTablet ? 5 : 4)),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.receipt_long_rounded,
                          size: invIcon, color: AppColors.primaryLight),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          order.invoiceNo.isNotEmpty ? order.invoiceNo : 'Order #${order.id}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: invFs,
                            color: AppColors.primaryLight,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'SAR ${order.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: totalFs,
                  color: const Color(0xFF1E2124),
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 8 : 10),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  size: dateIcon, color: Colors.grey.shade400),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: dateFs,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (order.promoCodeName != null && order.promoCodeName!.isNotEmpty) ...[
                const SizedBox(width: 10),
                Icon(Icons.local_offer_rounded,
                    size: promoIcon, color: Colors.orange.shade400),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    order.promoCodeName!,
                    style: TextStyle(
                      fontSize: promoFs,
                      color: Colors.orange.shade500,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          if (order.items.isNotEmpty) ...[
            SizedBox(height: compact ? 8 : 10),
            Divider(color: Colors.grey.shade100, height: 1),
            SizedBox(height: compact ? 8 : 10),
            ...order.items.take(3).map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: compact ? 4 : 6),
                child: Row(
                  children: [
                    Container(
                      width: compact ? 5 : 6,
                      height: compact ? 5 : 6,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: compact ? 6 : 8),
                    Expanded(
                      child: Text(
                        item.productName,
                        style: TextStyle(
                          fontSize: lineNameFs,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: compact ? 4 : 8),
                    Text(
                      'x${item.qty.toStringAsFixed(item.qty == item.qty.roundToDouble() ? 0 : 1)}',
                      style: TextStyle(
                        fontSize: lineQtyFs,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: compact ? 4 : 8),
                    Text(
                      'SAR ${item.lineTotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: lineTotalFs,
                        color: const Color(0xFF1E2124),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (order.items.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '+${order.items.length - 3} more items',
                  style: TextStyle(
                    fontSize: moreFs,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomerProfile(bool isTablet, SearchedCustomer customer) {
    final outerPad = isTablet ? 18.0 : 24.0;
    final avatarPad = isTablet ? 12.0 : 16.0;
    final avatarIcon = isTablet ? 28.0 : 36.0;
    final nameFs = isTablet ? 19.0 : 24.0;
    final metaFs = isTablet ? 14.0 : 16.0;

    return Container(
      padding: EdgeInsets.all(outerPad),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(avatarPad),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryLight.withValues(alpha: 0.2), AppColors.primaryLight.withValues(alpha: 0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.2), width: 1.5),
            ),
            child: Icon(Icons.person_rounded, color: AppColors.primaryLight, size: avatarIcon),
          ),
          SizedBox(width: isTablet ? 16 : 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        customer.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: nameFs,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildTypeBadge(customer, isTablet),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  customer.mobile,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: metaFs,
                  ),
                ),
                if (customer.taxId != null && customer.taxId!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'VAT: ${customer.taxId}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.grey.shade600,
                      fontSize: metaFs,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(SearchedCustomer customer, bool isTablet) {
    final isCorporate = customer.customerType.toLowerCase() == 'corporate';
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 8 : 10,
        vertical: isTablet ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: isCorporate ? Colors.blue.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isCorporate ? Colors.blue.shade100 : Colors.grey.shade200,
        ),
      ),
      child: Text(
        customer.customerType.toUpperCase(),
        style: TextStyle(
          color: isCorporate ? Colors.blue.shade700 : Colors.grey.shade700,
          fontSize: isTablet ? 11 : 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

}


