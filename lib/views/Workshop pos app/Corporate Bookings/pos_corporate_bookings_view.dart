import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../utils/app_colors.dart';
import '../../../../widgets/pos_widgets.dart';
import '../Department/department_view_model.dart';
import '../Home Screen/pos_view_model.dart';
import '../Product Grid/pos_product_grid_view.dart';
import 'corporate_booking_view_model.dart';

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ─── Filters Row ───
                Padding(
                  padding: EdgeInsets.fromLTRB(isTablet ? 32.0 : 20.0, 24.0, isTablet ? 32.0 : 20.0, 16.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildFilterChip('All', vm.currentFilter == 'All', vm, isTablet),
                        const SizedBox(width: 12),
                        _buildFilterChip('Today', vm.currentFilter == 'Today', vm, isTablet),
                        const SizedBox(width: 12),
                        _buildFilterChip('Pending', vm.currentFilter == 'Pending', vm, isTablet),
                      ],
                    ),
                  ),
                ),

                // ─── List of Bookings ───
                Expanded(
                  child: bookings.isEmpty
                      ? _buildEmptyState(isTablet)
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 20, vertical: 8),
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
            child: Icon(Icons.inbox_rounded, size: isTablet ? 64 : 48, color: Colors.grey.shade400),
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

  Widget _buildFilterChip(String label, bool isSelected, CorporateBookingViewModel vm, bool isTablet) {
    return GestureDetector(
      onTap: () => vm.setFilter(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutBack,
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16, vertical: isTablet ? 10 : 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? AppColors.primaryLight : Colors.grey.shade300, width: 1.5),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.primaryLight.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 3))]
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))],
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
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16, vertical: 16),
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
                      child: Icon(Icons.corporate_fare_rounded, size: isTablet ? 24 : 20, color: AppColors.secondaryLight),
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
                              Icon(Icons.tag, size: 12, color: Colors.grey.shade400),
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
                        Expanded(child: _buildInfoTag('Vehicle', booking.vehicleName, Icons.directions_car_rounded, isTablet)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildInfoTag('Plate', booking.vehiclePlate, Icons.pin_outlined, isTablet)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildInfoTag('Department', booking.department, Icons.category_rounded, isTablet)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildInfoTag('Date', DateFormat('MMM dd, hh:mm a').format(booking.bookedDateTime), Icons.event_available_rounded, isTablet)),
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
                      colors: [Colors.grey.shade100, Colors.grey.shade200, Colors.grey.shade100],
                    )
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
                          padding: EdgeInsets.symmetric(vertical: isTablet ? 14 : 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Details', style: TextStyle(fontSize: isTablet ? 13 : 12, fontWeight: FontWeight.w700), maxLines: 1),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: () => _showReasonDialog(context, booking, 'Reject', isTablet),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryLight,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: isTablet ? 14 : 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Reject', style: TextStyle(fontSize: isTablet ? 13 : 12, fontWeight: FontWeight.w700), maxLines: 1),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
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
                            vat: '',
                            mobile: '',
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          foregroundColor: AppColors.secondaryLight,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: isTablet ? 14 : 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Approve', style: TextStyle(color: AppColors.secondaryLight, fontSize: isTablet ? 14 : 13, fontWeight: FontWeight.w800, letterSpacing: 0.2)),
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

  Widget _buildInfoTag(String label, String value, IconData icon, bool isTablet) {
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
                BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2))
              ]
            ),
            child: Icon(icon, size: isTablet ? 16 : 14, color: AppColors.secondaryLight),
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
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Simple Header
              Container(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16, vertical: isTablet ? 20 : 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                      _buildDetailSectionHeading('Booking Details', Icons.receipt_long_rounded, isTablet),
                      const SizedBox(height: 16),
                      _buildDetailRow('Booking ID', booking.id, isTablet),
                      _buildDetailRow('Scheduled Time', DateFormat('MMM dd, yyyy - hh:mm a').format(booking.bookedDateTime), isTablet),
                      _buildDetailRow('Department', booking.department, isTablet),
                      
                      const SizedBox(height: 24),
                      Divider(height: 1, color: Colors.grey.shade100),
                      const SizedBox(height: 24),
                      
                      _buildDetailSectionHeading('Vehicle Information', Icons.directions_car_rounded, isTablet),
                      const SizedBox(height: 16),
                      _buildDetailRow('Vehicle Name', booking.vehicleName, isTablet),
                      _buildDetailRow('License Plate', booking.vehiclePlate, isTablet),
                      
                      const SizedBox(height: 24),
                      Divider(height: 1, color: Colors.grey.shade100),
                      const SizedBox(height: 24),
                      
                      _buildDetailSectionHeading('Requested Products', Icons.inventory_2_rounded, isTablet),
                      const SizedBox(height: 16),
                      if (booking.preSelectedProducts == null || booking.preSelectedProducts.isEmpty)
                        Container(
                          padding: EdgeInsets.all(isTablet ? 20 : 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline_rounded, color: Colors.grey.shade500, size: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'No specific products requested. Open matching department.',
                                  style: TextStyle(fontSize: isTablet ? 15 : 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
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
                            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200),
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16, vertical: 16),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle_rounded, size: isTablet ? 20 : 18, color: Colors.green),
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
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16, vertical: isTablet ? 20 : 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
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
                        child: Text('Close', style: TextStyle(fontSize: isTablet ? 15 : 14, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
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
                          backgroundColor: AppColors.primaryLight,
                          foregroundColor: AppColors.secondaryLight,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text('Approve Booking', style: TextStyle(color: AppColors.secondaryLight, fontSize: isTablet ? 15 : 14, fontWeight: FontWeight.w800, letterSpacing: 0.5), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
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
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Simple Header Section
              Container(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16, vertical: isTablet ? 20 : 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                      style: TextStyle(fontSize: isTablet ? 15 : 14, color: Colors.grey.shade600, height: 1.4, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Reason',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: isTablet ? 14 : 13, color: AppColors.secondaryLight, letterSpacing: 0.2),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: reasonController,
                      maxLines: 4,
                      style: TextStyle(fontSize: isTablet ? 15 : 14, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: 'Enter your reason here...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w400),
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
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16, vertical: isTablet ? 20 : 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
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
                        child: Text('Cancel', style: TextStyle(fontSize: isTablet ? 15 : 14, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
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
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text('Submit Reason', style: TextStyle(fontSize: isTablet ? 15 : 14, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
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
}
