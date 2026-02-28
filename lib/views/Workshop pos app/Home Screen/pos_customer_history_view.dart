import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/customer_search_model.dart';
import '../../../models/pos_order_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../widgets/pos_widgets.dart';

import '../../../models/create_invoice_model.dart';
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
  Future<CreateInvoiceResponse?>? _invoiceFuture;

  @override
  void initState() {
    super.initState();
    if (widget.focusOrderId != null && widget.focusOrderId!.isNotEmpty) {
      _invoiceFuture = context.read<PosViewModel>().fetchInvoiceByOrder(widget.focusOrderId!);
    }
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
            _buildFocusedOrderCard(),
            const SizedBox(height: 32),
            Text(
              'Past Orders',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: const Color(0xFF1E2124),
              ),
            ),
            const SizedBox(height: 16),
            if (customer.orders.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('No order history found for this customer.'),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: customer.orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final searchedOrder = customer.orders[index];
                  
                  // Convert SearchedCustomerOrder to PosOrder for UI compatibility
                  final posOrder = PosOrder(
                    id: searchedOrder.id,
                    status: searchedOrder.status,
                    source: searchedOrder.source,
                    odometerReading: searchedOrder.odometerReading,
                    createdAt: searchedOrder.createdAt,
                    customer: OrderCustomer(
                      id: customer.id,
                      name: customer.name,
                      mobile: customer.mobile,
                    ),
                    vehicle: searchedOrder.vehicle != null 
                        ? OrderVehicle(
                            id: searchedOrder.vehicle!.id,
                            plateNo: searchedOrder.vehicle!.plateNo,
                            make: searchedOrder.vehicle!.make,
                            model: searchedOrder.vehicle!.model,
                          )
                        : null,
                    jobsCount: 0, // Not provided in search details
                  );

                  // Using the shared OrderItemCard for consistency
                  return OrderItemCard(order: posOrder, isTablet: isTablet);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerProfile(bool isTablet, SearchedCustomer customer) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, color: AppColors.primaryLight, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      customer.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildTypeBadge(customer),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  customer.mobile,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                if (customer.taxId != null && customer.taxId!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'VAT: ${customer.taxId}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.grey.shade600,
                      fontSize: 14,
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

  Widget _buildTypeBadge(SearchedCustomer customer) {
    final isCorporate = customer.customerType.toLowerCase() == 'corporate';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildFocusedOrderCard() {
    if (_invoiceFuture == null || widget.focusOrderId == null) return const SizedBox.shrink();

    return FutureBuilder<CreateInvoiceResponse?>(
      future: _invoiceFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        
        final invoice = snapshot.data?.invoice;
        if (invoice == null || invoice.items.isEmpty) {
          return const SizedBox.shrink(); 
        }

        // Find the matching searched order for extra details like visit date, status
        final searchedOrder = widget.customer.orders.firstWhere(
          (o) => o.id == widget.focusOrderId,
          orElse: () => widget.customer.orders.first,
        );

        final DateFormat displayFormat = DateFormat('dd MMM yyyy, hh:mm a');
        final DateFormat parseFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
        String formattedDate = searchedOrder.createdAt;
        try {
          final parsed = parseFormat.parse(searchedOrder.createdAt);
          formattedDate = displayFormat.format(parsed);
        } catch (_) {}

        return Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.only(top: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryLight.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryLight.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order Details',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: AppColors.primaryLight,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '#${widget.focusOrderId}',
                      style: const TextStyle(
                        color: AppColors.primaryLight,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              
              // Key/Value Details
              _buildDetailRow('Customer Name', invoice.customerName),
              const SizedBox(height: 8),
              _buildDetailRow('Vehicle', '${invoice.vehicleInfo} - ${invoice.plateNo}'),
              const SizedBox(height: 8),
              _buildDetailRow('Visit Date', formattedDate),
              const SizedBox(height: 8),
              _buildDetailRow('Status', searchedOrder.status.toUpperCase()),
              
              if (invoice.invoiceNo.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildDetailRow('Invoice No', invoice.invoiceNo),
              ],
              
              const SizedBox(height: 16),
              const Text('Services / Products', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: invoice.items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.qty.toInt()}x ${item.productName}',
                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                            ),
                          ),
                          Text(
                            'SR ${item.lineTotal.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              
              // Totals
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                  Text(
                    'SR ${invoice.subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ],
              ),
              if (invoice.discountAmount > 0) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Discount', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: Colors.green)),
                    Text(
                      '- SR ${invoice.discountAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.green),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('VAT Amount', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                  Text(
                    'SR ${invoice.vatAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  Text(
                    'SR ${invoice.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.secondaryLight),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}


