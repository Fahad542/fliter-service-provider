import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/pos_tablet_layout.dart';
import '../../../../widgets/pos_widgets.dart';
import '../Department/department_view_model.dart';
import '../Home Screen/pos_view_model.dart';
import '../Product Grid/pos_product_grid_view.dart';
import 'corporate_booking_view_model.dart';

class PosCorporateBookingsView extends StatefulWidget {
  const PosCorporateBookingsView({super.key});

  @override
  State<PosCorporateBookingsView> createState() =>
      _PosCorporateBookingsViewState();
}

class _PosCorporateBookingsViewState extends State<PosCorporateBookingsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DepartmentViewModel>(
        context,
        listen: false,
      ).fetchDepartments();
      Provider.of<CorporateBookingViewModel>(
        context,
        listen: false,
      ).fetchCorporateBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: PosTabletLayout.textScaler(context)),
      child: Scaffold(
        backgroundColor: const Color(0xFFFBF9F6),
        appBar: PosScreenAppBar(title: 'Corporate Bookings'),
        body: Consumer<CorporateBookingViewModel>(
          builder: (context, vm, child) {
            final bookings = vm.filteredBookings;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Filters Row ───
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    isTablet ? 32.0 : 20.0,
                    24.0,
                    isTablet ? 32.0 : 20.0,
                    16.0,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildFilterChip(
                          'All',
                          vm.currentFilter == 'All',
                          vm,
                          isTablet,
                        ),
                        const SizedBox(width: 12),
                        _buildFilterChip(
                          'Today',
                          vm.currentFilter == 'Today',
                          vm,
                          isTablet,
                        ),
                        const SizedBox(width: 12),
                        _buildFilterChip(
                          'Pending',
                          vm.currentFilter == 'Pending',
                          vm,
                          isTablet,
                        ),
                      ],
                    ),
                  ),
                ),

                // ─── List of Bookings ───
                Expanded(
                  child: vm.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryLight,
                          ),
                        )
                      : (bookings.isEmpty
                            ? _buildEmptyState(isTablet)
                            : ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 32 : 20,
                                  vertical: 8,
                                ),
                                itemCount: bookings.length,
                                itemBuilder: (context, index) {
                                  final booking = bookings[index];
                                  return _buildBookingCard(booking, isTablet);
                                },
                              )),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isTablet) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_rounded,
              size: isTablet ? 64 : 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Bookings Found',
            style: TextStyle(
              fontSize: isTablet ? 22 : 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E2124),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no corporate bookings for the selected filter.',
            style: TextStyle(
              fontSize: isTablet ? 15 : 14,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    CorporateBookingViewModel vm,
    bool isTablet,
  ) {
    return GestureDetector(
      onTap: () => vm.setFilter(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutBack,
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 20 : 16,
          vertical: isTablet ? 10 : 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primaryLight : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryLight.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            fontSize: isTablet ? 13 : 12,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(booking, bool isTablet) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header Section ───
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 24 : 16,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade50)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Icon(
                      Icons.corporate_fare_rounded,
                      size: isTablet ? 24 : 20,
                      color: AppColors.secondaryLight,
                    ),
                  ),
                  SizedBox(width: isTablet ? 16 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.companyName,
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 16,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E2124),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.tag,
                              size: 12,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              booking.id,
                              style: TextStyle(
                                fontSize: isTablet ? 12 : 11,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(booking.status, isTablet),
                ],
              ),
            ),

            // ─── Detail Grid Section ───
            Padding(
              padding: EdgeInsets.all(isTablet ? 24 : 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoTag(
                          'Vehicle',
                          booking.vehicleName,
                          Icons.directions_car_rounded,
                          isTablet,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoTag(
                          'Plate',
                          booking.vehiclePlate,
                          Icons.pin_outlined,
                          isTablet,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoTag(
                          'Department',
                          booking.department,
                          Icons.category_rounded,
                          isTablet,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoTag(
                          'Date',
                          DateFormat(
                            'MMM dd, hh:mm a',
                          ).format(booking.bookedDateTime),
                          Icons.event_available_rounded,
                          isTablet,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ─── Actions Divider ───
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey.shade100,
                      Colors.grey.shade200,
                      Colors.grey.shade100,
                    ],
                  ),
                ),
              ),
            ),

            // ─── Actions Bottom Row ───
            Padding(
              padding: EdgeInsets.all(isTablet ? 24 : 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: () => _viewDetails(context, booking, isTablet),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: EdgeInsets.symmetric(
                          vertical: isTablet ? 14 : 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Details',
                        style: TextStyle(
                          fontSize: isTablet ? 13 : 12,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (booking.statusDisplay.toLowerCase() != 'approved' &&
                      booking.status.toLowerCase() != 'approved') ...[
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: () => _showReasonDialog(
                          context,
                          booking,
                          'Reject',
                          isTablet,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryLight,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            vertical: isTablet ? 14 : 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Reject',
                          style: TextStyle(
                            fontSize: isTablet ? 13 : 12,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {
                          final vm = Provider.of<CorporateBookingViewModel>(
                            context,
                            listen: false,
                          );
                          final success = await vm.approveBooking(booking.id);
                          if (!success) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    vm.errorMessage ??
                                        'Failed to approve booking',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          foregroundColor: AppColors.secondaryLight,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            vertical: isTablet ? 14 : 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Approve',
                          style: TextStyle(
                            color: AppColors.secondaryLight,
                            fontSize: isTablet ? 14 : 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      flex: 3,
                      child: ElevatedButton(
                        onPressed: () =>
                            _navigateToProductGrid(context, booking),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryLight,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            vertical: isTablet ? 14 : 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: isTablet ? 18 : 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTag(
    String label,
    String value,
    IconData icon,
    bool isTablet,
  ) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 12 : 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: isTablet ? 16 : 14,
              color: AppColors.secondaryLight,
            ),
          ),
          SizedBox(width: isTablet ? 10 : 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isTablet ? 10 : 9,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E2124),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, bool isTablet) {
    Color bgColor;
    Color textColor;

    if (status.contains('Waiting') || status.contains('Pending')) {
      bgColor = Colors.orange.shade50;
      textColor = Colors.orange.shade700;
    } else if (status.contains('In Progress')) {
      bgColor = Colors.blue.shade50;
      textColor = Colors.blue.shade700;
    } else if (status.contains('Completed')) {
      bgColor = Colors.green.shade50;
      textColor = Colors.green.shade700;
    } else {
      bgColor = Colors.grey.shade100;
      textColor = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: isTablet ? 11 : 9,
        ),
      ),
    );
  }

  void _viewDetails(BuildContext context, booking, bool isTablet) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          width: isTablet ? 600 : MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 30,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Simple Header
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 16,
                  vertical: isTablet ? 20 : 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade100),
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Corporate Booking Details',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: isTablet ? 14 : 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            booking.companyName,
                            style: TextStyle(
                              color: const Color(0xFF1E2124),
                              fontSize: isTablet ? 24 : 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(booking.status, isTablet),
                  ],
                ),
              ),

              // Content Details
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isTablet ? 28 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailSectionHeading(
                        'Booking Details',
                        Icons.receipt_long_rounded,
                        isTablet,
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow('Booking ID', booking.id, isTablet),
                      _buildDetailRow(
                        'Scheduled Time',
                        DateFormat(
                          'MMM dd, yyyy - hh:mm a',
                        ).format(booking.bookedDateTime),
                        isTablet,
                      ),
                      _buildDetailRow(
                        'Department',
                        booking.department,
                        isTablet,
                      ),

                      const SizedBox(height: 24),
                      Divider(height: 1, color: Colors.grey.shade100),
                      const SizedBox(height: 24),

                      _buildDetailSectionHeading(
                        'Vehicle Information',
                        Icons.directions_car_rounded,
                        isTablet,
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        'Vehicle Name',
                        booking.vehicleName,
                        isTablet,
                      ),
                      _buildDetailRow(
                        'License Plate',
                        booking.vehiclePlate,
                        isTablet,
                      ),

                      const SizedBox(height: 24),
                      Divider(height: 1, color: Colors.grey.shade100),
                      const SizedBox(height: 24),

                      _buildDetailSectionHeading(
                        'Requested Products',
                        Icons.inventory_2_rounded,
                        isTablet,
                      ),
                      const SizedBox(height: 16),
                      if ((booking.items == null || booking.items!.isEmpty) &&
                          (booking.preSelectedProducts == null ||
                              booking.preSelectedProducts.isEmpty))
                        Container(
                          padding: EdgeInsets.all(isTablet ? 20 : 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: Colors.grey.shade500,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'No specific products requested. Open matching department.',
                                  style: TextStyle(
                                    fontSize: isTablet ? 15 : 13,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (booking.items != null &&
                          booking.items!.isNotEmpty)
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.grey.shade50,
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: booking.items!.length,
                            separatorBuilder: (context, index) =>
                                Divider(height: 1, color: Colors.grey.shade200),
                            itemBuilder: (context, index) {
                              final item = booking.items![index];
                              final itemName =
                                  item['serviceName'] ??
                                  item['productName'] ??
                                  'Service package';
                              final qty = item['qty'] ?? 1;

                              return Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 20 : 16,
                                  vertical: 16,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: isTablet ? 20 : 18,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            itemName.toString(),
                                            style: TextStyle(
                                              fontSize: isTablet ? 15 : 14,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.secondaryLight,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Qty: $qty',
                                            style: TextStyle(
                                              fontSize: isTablet ? 13 : 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.grey.shade50,
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: booking.preSelectedProducts.length,
                            separatorBuilder: (context, index) =>
                                Divider(height: 1, color: Colors.grey.shade200),
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 20 : 16,
                                  vertical: 16,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: isTablet ? 20 : 18,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        'Product ID: ${booking.preSelectedProducts[index]}',
                                        style: TextStyle(
                                          fontSize: isTablet ? 15 : 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.secondaryLight,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Action Buttons Bottom
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 16,
                  vertical: isTablet ? 20 : 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                  border: Border(top: BorderSide(color: Colors.grey.shade100)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor: Colors.grey.shade600,
                        ),
                        child: Text(
                          'Close',
                          style: TextStyle(
                            fontSize: isTablet ? 15 : 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (booking.statusDisplay.toLowerCase() != 'approved' &&
                        booking.status.toLowerCase() != 'approved')
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () async {
                            final vm = Provider.of<CorporateBookingViewModel>(
                              context,
                              listen: false,
                            );
                            final success = await vm.approveBooking(booking.id);
                            if (!success) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      vm.errorMessage ??
                                          'Failed to approve booking',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } else {
                              if (context.mounted) Navigator.pop(ctx);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryLight,
                            foregroundColor: AppColors.secondaryLight,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'Approve Booking',
                            style: TextStyle(
                              color: AppColors.secondaryLight,
                              fontSize: isTablet ? 15 : 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _navigateToProductGrid(context, booking);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondaryLight,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: isTablet ? 15 : 14,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: isTablet ? 18 : 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSectionHeading(
    String title,
    IconData icon,
    bool isTablet,
  ) {
    return Row(
      children: [
        Icon(icon, size: isTablet ? 20 : 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: AppColors.secondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, bool isTablet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: isTablet ? 14 : 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.secondaryLight,
                fontSize: isTablet ? 14 : 13,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _showReasonDialog(
    BuildContext context,
    booking,
    String action,
    bool isTablet,
  ) {
    final TextEditingController reasonController = TextEditingController();
    final bool isReject = action == 'Reject';
    final Color themeColor = isReject
        ? Colors.red.shade600
        : Colors.orange.shade600;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          width: isTablet ? 500 : MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: themeColor.withValues(alpha: 0.15),
                blurRadius: 30,
                spreadRadius: 5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Simple Header Section
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 16,
                  vertical: isTablet ? 20 : 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade100),
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Booking Details',
                        style: TextStyle(
                          color: const Color(0xFF1E2124),
                          fontSize: isTablet ? 22 : 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(isTablet ? 24 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Please provide a reason to $action this booking for ${booking.companyName}. This information will be sent back to the corporate portal.',
                      style: TextStyle(
                        fontSize: isTablet ? 15 : 14,
                        color: Colors.grey.shade600,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Reason',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: isTablet ? 14 : 13,
                        color: AppColors.secondaryLight,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: reasonController,
                      maxLines: 4,
                      style: TextStyle(
                        fontSize: isTablet ? 15 : 14,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter your reason here...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w400,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: themeColor, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Actions
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 16,
                  vertical: isTablet ? 20 : 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                  border: Border(top: BorderSide(color: Colors.grey.shade100)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor: Colors.grey.shade600,
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: isTablet ? 15 : 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (reasonController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Text('Please provide a reason to $action.'),
                                  ],
                                ),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.red.shade800,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                            return;
                          }

                          final vm = Provider.of<CorporateBookingViewModel>(
                            context,
                            listen: false,
                          );
                          final success = await vm.rejectBooking(
                            booking.id,
                            reasonController.text,
                          );

                          if (!context.mounted) return;
                          Navigator.pop(ctx);

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Text('Booking Rejected. Portal updated.'),
                                  ],
                                ),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.green.shade700,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  vm.errorMessage ?? 'Failed to reject booking',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Submit Reason',
                          style: TextStyle(
                            fontSize: isTablet ? 15 : 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToProductGrid(BuildContext context, dynamic booking) {
    if (booking.items != null && booking.items!.isNotEmpty) {
      // Find unique departments from items
      final Map<String, String> uniqueDepts = {};
      for (var item in booking.items!) {
        final deptId = item['departmentId']?.toString();
        final deptName = item['departmentName']?.toString();
        if (deptId != null &&
            deptId.isNotEmpty &&
            deptName != null &&
            deptName.isNotEmpty) {
          uniqueDepts[deptId] = deptName;
        }
      }

      if (uniqueDepts.isNotEmpty) {
        if (uniqueDepts.length == 1) {
          final deptId = uniqueDepts.keys.first;
          final deptName = uniqueDepts.values.first;
          _proceedToGrid(context, booking, deptId, deptName);
        } else {
          _showDepartmentSelectionBottomSheet(context, booking, uniqueDepts);
        }
        return;
      }
    }

    // Fallback if no items or no departments found in items
    final deptVm = Provider.of<DepartmentViewModel>(context, listen: false);
    final departments = deptVm.departments;
    String resolvedDeptId = '';
    if (departments.isNotEmpty) {
      try {
        resolvedDeptId = departments
            .firstWhere(
              (d) => d.name.toLowerCase() == booking.department.toLowerCase(),
            )
            .id;
      } catch (_) {
        resolvedDeptId = departments.first.id;
      }
    }
    _proceedToGrid(
      context,
      booking,
      resolvedDeptId.isNotEmpty ? resolvedDeptId : 'dept-mock-id',
      booking.department,
    );
  }

  void _proceedToGrid(
    BuildContext context,
    dynamic booking,
    String departmentId,
    String departmentName,
  ) {
    Provider.of<PosViewModel>(context, listen: false).setCustomerData(
      name: booking.companyName,
      vat: '',
      mobile: '',
      vehicleNumber: booking.vehiclePlate,
      make: booking.vehicleName,
      model: '',
      odometer: 0,
    );

    // Filter items to only include those for this department
    List<dynamic>? filteredItems;
    if (booking.items != null && booking.items!.isNotEmpty) {
      filteredItems = booking.items!
          .where((item) => item['departmentId']?.toString() == departmentId)
          .toList();
    } else {
      filteredItems = booking.preSelectedProducts
          ?.map((id) => {'productId': id})
          .toList();
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PosProductGridView(
          departmentName: departmentName,
          departmentId: departmentId,
          preSelectedItems: filteredItems,
        ),
      ),
    );
  }

  void _showDepartmentSelectionBottomSheet(
    BuildContext context,
    dynamic booking,
    Map<String, String> departments,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFBF9F6),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 10, bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Select Department',
                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E2124),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Choose a department to process from the requested booking.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isTablet ? 15 : 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  isTablet ? 32 : 16,
                  0,
                  isTablet ? 32 : 16,
                  MediaQuery.of(context).padding.bottom + 24,
                ),
                itemCount: departments.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final deptId = departments.keys.elementAt(index);
                  final deptName = departments.values.elementAt(index);

                  // Count items for this dept
                  int itemCount = 0;
                  if (booking.items != null) {
                    itemCount = booking.items!
                        .where((i) => i['departmentId']?.toString() == deptId)
                        .length;
                  }

                  return InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                      _proceedToGrid(context, booking, deptId, deptName);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: EdgeInsets.all(isTablet ? 20 : 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryLight.withOpacity(0.05),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.build_circle_outlined,
                              color: AppColors.secondaryLight,
                              size: isTablet ? 28 : 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  deptName,
                                  style: TextStyle(
                                    fontSize: isTablet ? 17 : 15,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1E2124),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$itemCount items',
                                  style: TextStyle(
                                    fontSize: isTablet ? 14 : 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.grey.shade400,
                            size: isTablet ? 24 : 20,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
