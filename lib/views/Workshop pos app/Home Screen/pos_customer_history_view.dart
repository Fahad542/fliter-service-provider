import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/customer_search_model.dart';
import '../../../models/pos_order_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../widgets/pos_widgets.dart';

class PosCustomerHistoryView extends StatelessWidget {
  final SearchedCustomer customer;

  const PosCustomerHistoryView({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      appBar: PosScreenAppBar(title: 'Customer History'),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 32 : 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCustomerProfile(isTablet),
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

  Widget _buildCustomerProfile(bool isTablet) {
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
                    _buildTypeBadge(),
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

  Widget _buildTypeBadge() {
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
}

