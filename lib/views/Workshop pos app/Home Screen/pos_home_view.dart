import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../More Tab/settings_view_model.dart';
import '../../../widgets/pos_widgets.dart';
import '../Add Customer Screen/pos_add_customer_view.dart';
import '../Search History/pos_search_history_view.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:flutter/services.dart';
import '../../../utils/app_formatters.dart';
import '../Product Grid/pos_product_grid_view.dart';
import '../Sales Return/sales_return_view_model.dart';
import '../Sales Return/pos_sales_return_view.dart';
import '../Department/pos_department_view.dart';
import 'pos_view_model.dart';
import 'pos_customer_history_view.dart';
import '../Corporate Bookings/pos_corporate_bookings_view.dart';

class PosHomeView extends StatelessWidget {
  const PosHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final vm = context.watch<PosViewModel>();

    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(isTablet ? 1.4 : 1.0)),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        resizeToAvoidBottomInset: false,
        appBar: PosAppBar(
          userName: vm.cashierName,
          infoTitle: vm.workshopName,
          infoBranch: 'Branch: ${vm.branchName}',
          infoTime: DateFormat('dd MMM yyyy · hh:mm a').format(DateTime.now()),
          onMenuPressed: () => Scaffold.of(context).openDrawer(),
        ),
        body: GestureDetector(
          onTap: () {
            if (vm.homeSearchController.text.isEmpty) {
              vm.homeSearchFocusNode.unfocus();
            }
          },
          child: Column(
            children: [
              // 2. Custom Info Bar (Merged into AppBar)

              // 3. Main Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    // Title
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Workshop ',
                            style: AppTextStyles.h1.copyWith(
                              color: AppColors.primaryLight,
                              fontSize: isTablet ? 46 : 34,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: 'POS',
                            style: AppTextStyles.h1.copyWith(
                              color: AppColors.secondaryLight,
                              fontSize: isTablet ? 46 : 34,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Search by vehicle number, phone number,\nor customer name',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.grey,
                        fontSize: isTablet ? 18 : 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Search bar
                    PosSearchBar(
                      controller: vm.homeSearchController,
                      focusNode: vm.homeSearchFocusNode,
                      hintText:
                          'Search customer / vehicle / mobile / plate...',
                      onChanged: (val) => vm.handleSearchDebounce(val),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildActionChip(
                          context: context,
                          icon: Icons.add,
                          label: 'New walk-in',
                          onTap: () {
                            context.read<PosViewModel>().clearCustomerData();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const PosAddCustomerView(initialTab: 0),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        _buildActionChip(
                          context: context,
                          icon: Icons.business,
                          label: 'Corporate booking',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const PosCorporateBookingsView(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              if (vm.homeSearchController.text.isNotEmpty ||
                  vm.homeSearchFocusNode.hasFocus)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildSearchResults(context, isTablet),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, bool isTablet) {
    return Consumer<PosViewModel>(
      builder: (context, vm, child) {
        if (vm.isSearchingCustomer) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (vm.searchedCustomers.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
                child: Text(
                  'Recent Searches',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 40),
                  itemCount: vm.searchedCustomers.length,
                  itemBuilder: (context, index) {
                    final customer = vm.searchedCustomers[index];
                    final latestOrder = customer.orders.isNotEmpty
                        ? customer.orders.first
                        : null;
                    final vehicle = latestOrder?.vehicle;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SearchHistoryItem(
                        vehicle: vehicle != null
                            ? '${vehicle.make} ${vehicle.model}'
                            : 'No Vehicle',
                        plate: vehicle?.plateNo ?? 'N/A',
                        customer: customer.name,
                        lastVisit: latestOrder != null
                            ? vm.formatDate(latestOrder.createdAt)
                            : 'N/A',
                        lastService: latestOrder?.status.toUpperCase() ?? 'N/A',
                        orderNumber: latestOrder?.id,
                        isCorporate:
                            customer.customerType.toLowerCase() == 'corporate',
                        onContinue: () {
                          context.read<PosViewModel>().setCustomerData(
                            name: customer.name,
                            vat: customer.taxId ?? '',
                            mobile: customer.mobile,
                            vehicleNumber: vehicle?.plateNo ?? '',
                            make: vehicle?.make ?? '',
                            model: vehicle?.model ?? '',
                            odometer: latestOrder?.odometerReading ?? 0,
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PosDepartmentView(),
                            ),
                          );
                        },
                        onViewHistory: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PosCustomerHistoryView(
                                customer: customer,
                                focusOrderId: latestOrder?.id,
                              ),
                            ),
                          );
                        },
                        onSalesReturn: () {
                          final returnVm = context.read<SalesReturnViewModel>();
                          returnVm.searchController.text = customer.id.toString();
                          returnVm.searchInvoice();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PosSalesReturnView(),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }

        // Show "No Results" only if we've actually searched for something and got nothing back
        if (vm.homeSearchController.text.isNotEmpty &&
            !vm.isSearchingCustomer) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                Icon(
                  Icons.search_off_outlined,
                  size: 48,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 12),
                Text(
                  'No results found',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Try searching with a different name or number',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    // Reverting to previous compact style as requested
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.secondaryLight),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: AppColors.secondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
