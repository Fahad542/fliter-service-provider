import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../../widgets/pos_widgets.dart';
// import '../../Department/pos_department_view.dart';
// import '../../Product Grid/pos_product_grid_view.dart';
import '../Department/department_view_model.dart';
import '../Home Screen/pos_view_model.dart';
import '../Product Grid/pos_product_grid_view.dart';
import 'corporate_booking_view_model.dart';
// package:filter_service_providers/views/Workshop%20pos%20app/Department/department_view_model.dart
// import '../../Department/department_view_model.dart';

class PosCorporateBookingsView extends StatefulWidget {
  const PosCorporateBookingsView({super.key});

  @override
  State<PosCorporateBookingsView> createState() => _PosCorporateBookingsViewState();
}

class _PosCorporateBookingsViewState extends State<PosCorporateBookingsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DepartmentViewModel>(context, listen: false).fetchDepartments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(isTablet ? 1.4 : 1.0),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFBF9F6),
        appBar: const PosScreenAppBar(
          title: 'Corporate Bookings',
        ),
        body: Consumer<CorporateBookingViewModel>(
          builder: (context, vm, child) {
            final bookings = vm.filteredBookings;

            return Column(
              children: [
                // ─── Header & Filters ───
                Padding(
                  padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                  child: Row(
                    children: [
                      _buildFilterChip('All', vm.currentFilter == 'All', vm, isTablet),
                      SizedBox(width: isTablet ? 12 : 8),
                      _buildFilterChip('Today', vm.currentFilter == 'Today', vm, isTablet),
                      SizedBox(width: isTablet ? 12 : 8),
                      _buildFilterChip('Pending', vm.currentFilter == 'Pending', vm, isTablet),
                    ],
                  ),
                ),

                // ─── List of Bookings ───
                Expanded(
                  child: bookings.isEmpty
                      ? const Center(child: Text('No bookings found for the selected filter.'))
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16, vertical: 8),
                          itemCount: bookings.length,
                          itemBuilder: (context, index) {
                            final booking = bookings[index];
                            return _buildBookingCard(booking, isTablet);
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, CorporateBookingViewModel vm, bool isTablet) {
    return GestureDetector(
      onTap: () => vm.setFilter(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 12, vertical: isTablet ? 10 : 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primaryLight : Colors.grey.shade300),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.primaryLight.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2))]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.secondaryLight : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: isTablet ? 13 : 11,
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: ID & Status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    booking.id,
                    style: TextStyle(
                      color: AppColors.secondaryLight,
                      fontWeight: FontWeight.w700,
                      fontSize: isTablet ? 12 : 10,
                    ),
                  ),
                ),
                const Spacer(),
                _buildStatusBadge(booking.status, isTablet),
              ],
            ),
            SizedBox(height: isTablet ? 16 : 12),

            // Row 2: Customer Name
            Row(
              children: [
                Icon(Icons.business, size: isTablet ? 24 : 18, color: Colors.grey.shade500),
                SizedBox(width: isTablet ? 12 : 8),
                Text(
                  booking.companyName,
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E2124),
                  ),
                ),
              ],
            ),
            SizedBox(height: isTablet ? 16 : 12),

            // Grid Info Details
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isTablet ? 3 : 2,
              childAspectRatio: isTablet ? 4.5 : 3.5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                _buildInfoColumn('Vehicle', booking.vehicleName, Icons.directions_car_outlined, isTablet),
                _buildInfoColumn('Plate', booking.vehiclePlate, Icons.credit_card_outlined, isTablet),
                _buildInfoColumn('Department', booking.department, Icons.category_outlined, isTablet),
                _buildInfoColumn('Booked For', DateFormat('MMM dd, hh:mm a').format(booking.bookedDateTime), Icons.event_outlined, isTablet),
              ],
            ),

            SizedBox(height: isTablet ? 20 : 16),
            const Divider(height: 1),
            SizedBox(height: isTablet ? 16 : 12),

            // Actions Row
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: OutlinedButton.icon(
                    onPressed: () => _viewDetails(context, booking, isTablet),
                    icon: Icon(Icons.visibility_outlined, size: isTablet ? 18 : 14),
                    label: Text('View Details', style: TextStyle(fontSize: isTablet ? 13 : 11, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryLight,
                      side: BorderSide(color: AppColors.primaryLight),
                      padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: () => _showReasonDialog(context, booking, 'Reject', isTablet),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Reject', style: TextStyle(fontSize: isTablet ? 13 : 11, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final deptVm = Provider.of<DepartmentViewModel>(context, listen: false);
                      final departments = deptVm.departments;
                      String resolvedDeptId = '';
                      if (departments.isNotEmpty) {
                        try {
                           resolvedDeptId = departments.firstWhere((d) => d?.name.toLowerCase() == booking.department.toLowerCase()).id;
                        } catch (_) {
                           resolvedDeptId = departments.first.id;
                        }
                      }

                      Provider.of<PosViewModel>(context, listen: false).setCustomerData(
                        name: booking.companyName,
                        vat: '', // Corporate VAT if available
                        mobile: '', // Corporate mobile if available
                        vehicleNumber: booking.vehiclePlate,
                        make: booking.vehicleName,
                        model: '',
                        odometer: 0,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PosProductGridView(
                            departmentName: booking.department,
                            departmentId: resolvedDeptId.isNotEmpty ? resolvedDeptId : 'dept-mock-id',
                            preSelectedProducts: booking.preSelectedProducts,
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.edit_document, size: isTablet ? 18 : 14),
                    label: Text('Approve', style: TextStyle(fontSize: isTablet ? 13 : 11, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryLight,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, IconData icon, bool isTablet) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: isTablet ? 20 : 16, color: Colors.grey.shade400),
        SizedBox(width: isTablet ? 10 : 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isTablet ? 11 : 9,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: isTablet ? 13 : 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E2124),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          width: isTablet ? 600 : 400,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.corporate_fare, color: AppColors.primaryLight, size: isTablet ? 28 : 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Corporate Booking',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: isTablet ? 14 : 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            booking.companyName,
                            style: TextStyle(
                              color: AppColors.secondaryLight,
                              fontSize: isTablet ? 22 : 18,
                              fontWeight: FontWeight.bold,
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
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailSectionHeading('Booking Details', Icons.description_outlined, isTablet),
                      const SizedBox(height: 16),
                      _buildDetailRow('Booking ID', booking.id, isTablet),
                      _buildDetailRow('Scheduled Time', DateFormat('MMM dd, yyyy - hh:mm a').format(booking.bookedDateTime), isTablet),
                      _buildDetailRow('Department', booking.department, isTablet),
                      
                      const SizedBox(height: 24),
                      _buildDetailSectionHeading('Vehicle Information', Icons.directions_car_outlined, isTablet),
                      const SizedBox(height: 16),
                      _buildDetailRow('Vehicle Name', booking.vehicleName, isTablet),
                      _buildDetailRow('License Plate', booking.vehiclePlate, isTablet),
                      
                      const SizedBox(height: 24),
                      _buildDetailSectionHeading('Requested Products', Icons.inventory_2_outlined, isTablet),
                      const SizedBox(height: 16),
                      if (booking.preSelectedProducts == null || booking.preSelectedProducts.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.grey.shade500, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                'No specific products requested.',
                                style: TextStyle(fontSize: isTablet ? 14 : 12, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: booking.preSelectedProducts.length,
                            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200),
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle, size: isTablet ? 18 : 16, color: Colors.green),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Product ID: ${booking.preSelectedProducts[index]}',
                                      style: TextStyle(
                                        fontSize: isTablet ? 15 : 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.secondaryLight,
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        foregroundColor: Colors.grey.shade700,
                      ),
                      child: Text('Close', style: TextStyle(fontSize: isTablet ? 15 : 14, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        final deptVm = Provider.of<DepartmentViewModel>(context, listen: false);
                        final departments = deptVm.departments;
                        String resolvedDeptId = '';
                        if (departments.isNotEmpty) {
                          try {
                             resolvedDeptId = departments.firstWhere((d) => d.name.toLowerCase() == booking.department.toLowerCase()).id;
                          } catch (_) {
                             resolvedDeptId = departments.first.id;
                          }
                        }

                        Provider.of<PosViewModel>(context, listen: false).setCustomerData(
                          name: booking.companyName,
                          vat: '', // Corporate VAT if available
                          mobile: '', // Corporate mobile if available
                          vehicleNumber: booking.vehiclePlate,
                          make: booking.vehicleName,
                          model: '',
                          odometer: 0,
                        );
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PosProductGridView(
                              departmentName: booking.department,
                              departmentId: resolvedDeptId.isNotEmpty ? resolvedDeptId : 'dept-mock-id',
                              preSelectedProducts: booking.preSelectedProducts,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryLight,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Approve Booking', style: TextStyle(fontSize: isTablet ? 15 : 14, fontWeight: FontWeight.w600)),
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

  Widget _buildDetailSectionHeading(String title, IconData icon, bool isTablet) {
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

  void _showReasonDialog(BuildContext context, booking, String action, bool isTablet) {
    final TextEditingController reasonController = TextEditingController();
    final bool isReject = action == 'Reject';
    final Color themeColor = isReject ? Colors.red.shade600 : Colors.orange.shade600;
    final Color bgThemeColor = isReject ? Colors.red.shade50 : Colors.orange.shade50;
    final IconData iconData = isReject ? Icons.cancel_outlined : Icons.warning_amber_rounded;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          width: isTablet ? 500 : 350,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: bgThemeColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(iconData, color: themeColor, size: isTablet ? 24 : 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        '$action Booking',
                        style: TextStyle(
                          color: AppColors.secondaryLight,
                          fontSize: isTablet ? 20 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Please provide a reason to $action this booking for ${booking.companyName}. This information will be sent back to the corporate portal.',
                      style: TextStyle(fontSize: isTablet ? 15 : 14, color: Colors.grey.shade600, height: 1.4),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Reason',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: isTablet ? 14 : 12, color: AppColors.secondaryLight),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: reasonController,
                      maxLines: 4,
                      style: TextStyle(fontSize: isTablet ? 15 : 14),
                      decoration: InputDecoration(
                        hintText: 'Enter your reason here...',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: themeColor, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Actions
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        foregroundColor: Colors.grey.shade600,
                      ),
                      child: Text('Cancel', style: TextStyle(fontSize: isTablet ? 15 : 14, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (reasonController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.error_outline, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text('Please provide a reason to $action.'),
                                ],
                              ),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.red.shade800,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                          return;
                        }
                        final status = action == 'Reject' ? 'Rejected' : 'Cancelled';
                        Provider.of<CorporateBookingViewModel>(context, listen: false)
                            .updateBookingStatus(booking.id, status, reason: reasonController.text);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_outline, color: Colors.white),
                                const SizedBox(width: 8),
                                Text('Booking $status. Portal updated.'),
                              ],
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.green.shade700,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Confirm $action', style: TextStyle(fontSize: isTablet ? 15 : 14, fontWeight: FontWeight.bold)),
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
}
