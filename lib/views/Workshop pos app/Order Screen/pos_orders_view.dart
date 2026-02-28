import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/app_formatters.dart';
import '../Home Screen/pos_view_model.dart';
import '../../../models/pos_order_model.dart';
import '../../../widgets/pos_widgets.dart';

class PosOrdersView extends StatefulWidget {
  const PosOrdersView({super.key});

  @override
  State<PosOrdersView> createState() => _PosOrdersViewState();
}

class _PosOrdersViewState extends State<PosOrdersView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final vm = context.watch<PosViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD),
      appBar: PosAppBar(
        userName: vm.cashierName,
        infoTitle: vm.workshopName,
        infoBranch: 'Branch: ${vm.branchName}',
        infoTime: DateFormat('dd MMM yyyy · hh:mm a').format(DateTime.now()),
        showDrawer: false,
        showGlobalLeft: true,
      ),
      body: Consumer<PosViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.errorMessage != null && vm.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, size: 48, color: Colors.red.shade200),
                  const SizedBox(height: 16),
                  Text('Error: ${vm.errorMessage}', style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => vm.fetchOrders(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryLight,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => vm.fetchOrders(silent: true),
                  color: AppColors.secondaryLight,
                  backgroundColor: Colors.white,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 32 : 16, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatCards(vm.orderStats, isTablet),
                        const SizedBox(height: 32),
                        _buildSearchAndFilter(context, isTablet),
                        const SizedBox(height: 24),
                        _buildOrdersList(context, vm.orders, isTablet),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCards(OrderStats stats, bool isTablet) {
    final statList = [
      {
        'title': 'Total Orders',
        'value': stats.total.toString(),
        'icon': Icons.assignment_rounded,
        'color': AppColors.secondaryLight,
      },
      {
        'title': 'Waiting',
        'value': stats.draft.toString(),
        'icon': Icons.hourglass_top_rounded,
        'color': AppColors.primaryLight,
      },
      {
        'title': 'In Progress',
        'value': stats.inProgress.toString(),
        'icon': Icons.auto_mode_rounded,
        'color': const Color(0xFF2D9CDB), // Professional Blue
      },
      {
        'title': 'Ready for Invoice',
        'value': stats.readyForInvoice.toString(),
        'icon': Icons.receipt_long_rounded,
        'color': const Color(0xFFF2994A), // Professional Amber/Orange
      },
      {
        'title': 'Completed',
        'value': stats.invoiced.toString(),
        'icon': Icons.check_circle_rounded,
        'color': const Color(0xFF27AE60), // Professional Green
      },
    ];

    if (isTablet) {
      return Row(
        children: statList.map((stat) => Expanded(
          child: StatCard(
            title: stat['title'] as String,
            value: stat['value'] as String,
            icon: stat['icon'] as IconData,
            accentColor: stat['color'] as Color,
            width: double.infinity,
          ),
        )).toList(),
      );
    } else {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none, // Allow shadows to be visible
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), // Padding for shadows
        child: Row(
          children: statList.map((stat) => StatCard(
            title: stat['title'] as String,
            value: stat['value'] as String,
            icon: stat['icon'] as IconData,
            accentColor: stat['color'] as Color,
            width: 115,
          )).toList(),
        ),
      );
    }
  }

  Widget _buildSearchAndFilter(BuildContext context, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 0 : 4),
      child: PosSearchBar(
        hintText: 'Search by Customer or Plate Number...',
        onChanged: (val) => context.read<PosViewModel>().setOrderSearchQuery(val),
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context, List<PosOrder> orders, bool isTablet) {
    if (orders.isEmpty) {
      return Center(child: Padding(
        padding: const EdgeInsets.all(64.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
            ),
            const SizedBox(height: 24),
            Text(
              'No matching orders found', 
              style: TextStyle(
                color: Colors.grey.shade600, 
                fontSize: 16,
                fontWeight: FontWeight.w600,
              )
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search query', 
              style: TextStyle(
                color: Colors.grey.shade400, 
                fontSize: 14,
              )
            ),
          ],
        ),
      ));
    }
    
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return OrderItemCard(order: orders[index], isTablet: isTablet);
      },
    );
  }
}

