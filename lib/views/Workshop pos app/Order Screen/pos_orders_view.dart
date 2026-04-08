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
import '../../../widgets/pos_shell_rail_layout.dart';

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
      appBar: const PosScreenAppBar(
        title: 'Orders',
        showBackButton: false,
        showGlobalLeft: true,
        showHamburger: false,
      ),
      body: wrapPosShellRailBody(
        context,
        Consumer<PosViewModel>(
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
              // Fixed Header Section
              Padding(
                padding: EdgeInsets.fromLTRB(
                    isTablet ? 20 : 12, 8, isTablet ? 20 : 12, 0),
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    _buildStatCards(vm.orderStats, isTablet),
                    const SizedBox(height: 14),
                    _buildSearchAndFilter(context, isTablet),
                    const SizedBox(height: 6),
                    _buildTabs(context, isTablet, vm.orderStatusFilter),
                  ],
                ),
              ),

              // Scrollable Orders List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => vm.fetchOrders(silent: true),
                  color: AppColors.secondaryLight,
                  backgroundColor: Colors.white,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 20 : 12, vertical: 12),
                        sliver: SliverToBoxAdapter(
                          child: _buildOrdersList(context, vm.orders, isTablet),
                        ),
                      ),
                      // Extra bottom padding for cart bar clearance on grid
                      const SliverToBoxAdapter(child: SizedBox(height: 88)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
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
            height: 92,
            backgroundColor: Colors.white,
            textColor: AppColors.secondaryLight,
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
            width: 90,
            backgroundColor: Colors.white,
            textColor: AppColors.secondaryLight,
          )).toList(),
        ),
      );
    }
  }

  Widget _buildSearchAndFilter(BuildContext context, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0),
      child: PosSearchBar(
        hintText: 'Search by Customer or Plate Number...',
        onChanged: (val) => context.read<PosViewModel>().setOrderSearchQuery(val),
      ),
    );
  }

  Widget _buildTabs(BuildContext context, bool isTablet, String currentStatus) {
    final statuses = [
      'All',
      'Draft',
      'Waiting',
      'Corp. pending approval',
      'Corporate approved',
      'Rejected by corporate',
      'Accepted by Tech',
      'In Progress',
      'Tech Completed',
      'Completed',
      'Cancelled',
    ];

    return SizedBox(
      height: isTablet ? 58 : 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
        itemCount: statuses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final status = statuses[index];
          final isSelected = currentStatus == status;
          return Center(
            child: GestureDetector(
              onTap: () => context.read<PosViewModel>().setOrderStatusFilter(status),
              child: Container(
                height: isTablet ? 40 : 34,
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryLight : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryLight : Colors.grey.shade300,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: AppColors.primaryLight.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ] : null,
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 10,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.secondaryLight : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context, List<PosOrder> orders, bool isTablet) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
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
    
    if (isTablet || isLandscape) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: orders.length,
        // Tight height: grid cells are fixed-size; extra [mainAxisExtent] = empty space under buttons.
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisExtent: isTablet ? 172 : 160,
          crossAxisSpacing: 12,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          return OrderItemCard(order: orders[index], isTablet: isTablet);
        },
      );
    }
    
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return OrderItemCard(order: orders[index], isTablet: isTablet);
      },
    );
  }
}

