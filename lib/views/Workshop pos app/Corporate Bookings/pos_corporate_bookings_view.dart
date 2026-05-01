import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../services/localized_api_text.dart';
import '../../../../utils/pos_tablet_layout.dart';
import '../../../../widgets/pos_widgets.dart';
import '../../../models/pos_order_model.dart';
import '../Home Screen/pos_view_model.dart';
import '../Navbar/pos_shell.dart';
import 'corporate_booking_view_model.dart';

class PosCorporateBookingsView extends StatefulWidget {
  const PosCorporateBookingsView({super.key});

  @override
  State<PosCorporateBookingsView> createState() =>
      _PosCorporateBookingsViewState();
}

class _PosCorporateBookingsViewState extends State<PosCorporateBookingsView> {
  CorporateBookingViewModel? _vmRef;
  String? _redirectingBookingId;

  // ── Status helpers ─────────────────────────────────────────────────────
  // NOTE: These return raw/English status strings so that boolean helpers
  // (_isApproved, _isRejected) keep working via .contains() on a stable
  // ASCII string.  Translation happens only at render time via
  // [_localizedStatus] and [_buildStatusBadge].

  String _rawStatus(dynamic booking) {
    final orderRaw = booking.orderStatus?.toString().trim() ?? '';
    final statusRaw = booking.status?.toString().trim() ?? '';
    final displayRaw = booking.statusDisplay?.toString().trim() ?? '';
    final combined = '$displayRaw $statusRaw $orderRaw'.toLowerCase();
    if (combined.contains('cancelled') || combined.contains('canceled')) {
      return 'Cancelled';
    }
    if (combined.contains('rejected')) {
      return 'Rejected';
    }
    if (displayRaw.isNotEmpty) return displayRaw;
    if (statusRaw.isNotEmpty) return statusRaw;
    return 'Pending';
  }

  /// Translates a raw status string to the active locale.
  String _localizedStatus(String raw, AppLocalizations l10n) {
    final lower = raw.toLowerCase();
    if (lower.contains('cancelled') || lower.contains('canceled')) {
      return l10n.posCorporateStatusCancelled;
    }
    if (lower.contains('rejected')) return l10n.posCorporateStatusRejected;
    if (lower.contains('approved')) return l10n.posCorporateStatusApproved;
    if (lower.contains('in progress')) return l10n.posCorporateStatusInProgress;
    if (lower.contains('completed')) return l10n.posCorporateStatusCompleted;
    if (lower.contains('waiting')) return l10n.posCorporateStatusWaitingApproval;
    if (lower.contains('pending') || lower.contains('submitted')) {
      return l10n.posCorporateStatusPending;
    }
    return raw; // Unknown – pass through
  }

  bool _isApproved(dynamic booking) {
    final raw = '${_rawStatus(booking)} ${booking.orderStatus?.toString() ?? ''}'
        .toLowerCase();
    if (raw.contains('cancelled') || raw.contains('canceled') || raw.contains('rejected')) {
      return false;
    }
    return raw.contains('approved');
  }

  bool _isRejected(dynamic booking) {
    final raw = '${_rawStatus(booking)} ${booking.orderStatus?.toString() ?? ''}'
        .toLowerCase();
    return raw.contains('rejected') || raw.contains('cancelled');
  }

  bool _canReviewBooking(dynamic booking) {
    return !_isApproved(booking) && !_isRejected(booking);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<CorporateBookingViewModel>(context, listen: false);
      _vmRef = vm;
      vm.fetchCorporateBookings();
      vm.bindRealtime();
    });
  }

  @override
  void dispose() {
    _vmRef?.unbindRealtime();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isTablet = MediaQuery.of(context).size.width > 600;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: PosTabletLayout.textScaler(context)),
      child: Scaffold(
        backgroundColor: const Color(0xFFFBF9F6),
        appBar: PosScreenAppBar(title: l10n.posCorporateBookingsTitle),
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
                      children: [
                        _buildFilterChip(
                          label: l10n.posCorporateFilterAll,
                          filterKey: 'All',
                          isSelected: vm.currentFilter == 'All',
                          vm: vm,
                          isTablet: isTablet,
                        ),
                        const SizedBox(width: 12),
                        _buildFilterChip(
                          label: l10n.posCorporateFilterToday,
                          filterKey: 'Today',
                          isSelected: vm.currentFilter == 'Today',
                          vm: vm,
                          isTablet: isTablet,
                        ),
                        const SizedBox(width: 12),
                        _buildFilterChip(
                          label: l10n.posCorporateFilterPending,
                          filterKey: 'Pending',
                          isSelected: vm.currentFilter == 'Pending',
                          vm: vm,
                          isTablet: isTablet,
                        ),
                      ],
                    ),
                  ),
                ),

                // ─── List ───
                Expanded(
                  child: vm.isLoading
                      ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryLight),
                  )
                      : bookings.isEmpty
                      ? _buildEmptyState(isTablet, l10n)
                      : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 32 : 20,
                      vertical: 8,
                    ),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) =>
                        _buildBookingCard(bookings[index], isTablet, l10n),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Empty state ──────────────────────────────────────────────────────────

  Widget _buildEmptyState(bool isTablet, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
            child: Icon(Icons.inbox_rounded, size: isTablet ? 64 : 48, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.posCorporateNoBookingsTitle,
            style: TextStyle(
              fontSize: isTablet ? 22 : 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E2124),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              l10n.posCorporateNoBookingsSubtitle,
              style: TextStyle(
                fontSize: isTablet ? 15 : 14,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter chip ──────────────────────────────────────────────────────────

  Widget _buildFilterChip({
    required String label,
    required String filterKey,
    required bool isSelected,
    required CorporateBookingViewModel vm,
    required bool isTablet,
  }) {
    return GestureDetector(
      onTap: () => vm.setFilter(filterKey),
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

  // ── Booking card ─────────────────────────────────────────────────────────

  Widget _buildBookingCard(dynamic booking, bool isTablet, AppLocalizations l10n) {
    final isRedirecting = _redirectingBookingId == booking.id.toString();
    final rawStatus = _rawStatus(booking);
    final localStatus = _localizedStatus(rawStatus, l10n);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 8))],
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16, vertical: 16),
              decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade50))),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.grey.shade50, shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200)),
                    child: Icon(Icons.corporate_fare_rounded, size: isTablet ? 24 : 20, color: AppColors.secondaryLight),
                  ),
                  SizedBox(width: isTablet ? 16 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LocalizedApiText(
                          booking.companyName,
                          style: TextStyle(fontSize: isTablet ? 18 : 16, fontWeight: FontWeight.w800, color: const Color(0xFF1E2124), letterSpacing: -0.2),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.tag, size: 12, color: Colors.grey.shade400),
                            const SizedBox(width: 4),
                            Text(
                              booking.id,
                              style: TextStyle(fontSize: isTablet ? 12 : 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(rawStatus, localStatus, isTablet),
                ],
              ),
            ),

            // Details grid
            Padding(
              padding: EdgeInsets.all(isTablet ? 24 : 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildInfoTag(l10n.posCorporateCardLabelVehicle, booking.vehicleName, Icons.directions_car_rounded, isTablet)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildInfoTag(l10n.posCorporateCardLabelPlate, booking.vehiclePlate, Icons.pin_outlined, isTablet)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildInfoTag(l10n.posCorporateCardLabelDepartment, booking.department, Icons.category_rounded, isTablet)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoTag(
                          l10n.posCorporateCardLabelDate,
                          DateFormat('MMM dd, hh:mm a').format(booking.bookedDateTime),
                          Icons.event_available_rounded,
                          isTablet,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Divider
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.grey.shade100, Colors.grey.shade200, Colors.grey.shade100]),
                ),
              ),
            ),

            // Actions
            Padding(
              padding: EdgeInsets.all(isTablet ? 24 : 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: () => _viewDetails(context, booking, isTablet, l10n),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: EdgeInsets.symmetric(vertical: isTablet ? 14 : 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(l10n.posCorporateActionDetails, style: TextStyle(fontSize: isTablet ? 13 : 12, fontWeight: FontWeight.w700), maxLines: 1),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (_canReviewBooking(booking)) ...[
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: () => _showReasonDialog(context, booking, l10n.posCorporateActionReject, isTablet, l10n),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryLight,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: isTablet ? 14 : 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(l10n.posCorporateActionReject, style: TextStyle(fontSize: isTablet ? 13 : 12, fontWeight: FontWeight.w700), maxLines: 1),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {
                          final vm = Provider.of<CorporateBookingViewModel>(context, listen: false);
                          final success = await vm.approveBooking(booking.id);
                          if (!success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(vm.errorMessage ?? l10n.posCorporateApproveError),
                              backgroundColor: Colors.red,
                            ));
                          } else {
                            vm.setFilter('All');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          foregroundColor: AppColors.secondaryLight,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: isTablet ? 14 : 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          l10n.posCorporateActionApprove,
                          style: TextStyle(color: AppColors.secondaryLight, fontSize: isTablet ? 14 : 13, fontWeight: FontWeight.w800, letterSpacing: 0.2),
                        ),
                      ),
                    ),
                  ] else if (_isApproved(booking)) ...[
                    Expanded(
                      flex: 3,
                      child: ElevatedButton(
                        onPressed: isRedirecting ? null : () => _navigateToProductGrid(context, booking, l10n),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryLight,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: isTablet ? 14 : 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isRedirecting
                            ? SizedBox(width: isTablet ? 18 : 16, height: isTablet ? 18 : 16, child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(l10n.posCorporateActionContinue, style: TextStyle(fontSize: isTablet ? 14 : 13, fontWeight: FontWeight.w800, letterSpacing: 0.2)),
                            const SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: isTablet ? 18 : 16),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    const Expanded(flex: 3, child: SizedBox.shrink()),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Info tag ─────────────────────────────────────────────────────────────

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
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: Icon(icon, size: isTablet ? 16 : 14, color: AppColors.secondaryLight),
          ),
          SizedBox(width: isTablet ? 10 : 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: TextStyle(fontSize: isTablet ? 10 : 9, color: Colors.grey.shade500, fontWeight: FontWeight.w700, letterSpacing: 0.2)),
                const SizedBox(height: 1),
                LocalizedApiText(value, style: TextStyle(fontSize: isTablet ? 12 : 11, fontWeight: FontWeight.w800, color: const Color(0xFF1E2124)), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Status badge ─────────────────────────────────────────────────────────

  Widget _buildStatusBadge(String rawStatus, String localizedStatus, bool isTablet) {
    Color bgColor;
    Color textColor;
    final lower = rawStatus.toLowerCase();

    if (lower.contains('waiting') || lower.contains('pending') || lower.contains('submitted')) {
      bgColor = Colors.orange.shade50;
      textColor = Colors.orange.shade700;
    } else if (lower.contains('in progress')) {
      bgColor = Colors.blue.shade50;
      textColor = Colors.blue.shade700;
    } else if (lower.contains('approved')) {
      bgColor = Colors.green.shade50;
      textColor = Colors.green.shade700;
    } else if (lower.contains('complete')) {
      bgColor = Colors.green.shade50;
      textColor = Colors.green.shade700;
    } else if (lower.contains('rejected') || lower.contains('cancelled')) {
      bgColor = Colors.red.shade50;
      textColor = Colors.red.shade700;
    } else {
      bgColor = Colors.grey.shade100;
      textColor = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Text(
        localizedStatus,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: isTablet ? 11 : 9),
      ),
    );
  }

  // ── Details dialog ───────────────────────────────────────────────────────

  void _viewDetails(BuildContext context, dynamic booking, bool isTablet, AppLocalizations l10n) {
    final rawStatus = _rawStatus(booking);
    final localStatus = _localizedStatus(rawStatus, l10n);

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
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 30, spreadRadius: 2, offset: const Offset(0, 10))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
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
                            l10n.posCorporateDialogDetailsTitle,
                            style: TextStyle(color: Colors.grey.shade600, fontSize: isTablet ? 14 : 12, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            booking.companyName,
                            style: TextStyle(color: const Color(0xFF1E2124), fontSize: isTablet ? 24 : 20, fontWeight: FontWeight.w900, letterSpacing: -0.3),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(rawStatus, localStatus, isTablet),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isTablet ? 28 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailSectionHeading(l10n.posCorporateDetailsSectionBooking, Icons.receipt_long_rounded, isTablet),
                      const SizedBox(height: 16),
                      _buildDetailRow(l10n.posCorporateDetailsBookingId, booking.id, isTablet),
                      _buildDetailRow(
                        l10n.posCorporateDetailsScheduledTime,
                        DateFormat('MMM dd, yyyy - hh:mm a').format(booking.bookedDateTime),
                        isTablet,
                      ),
                      _buildDetailRow(l10n.posCorporateDetailsDepartment, booking.department, isTablet),
                      if (_isRejected(booking) && (booking.rejectionReason?.trim().isNotEmpty ?? false))
                        _buildDetailRow(l10n.posCorporateDetailsRejectionReason, booking.rejectionReason!.trim(), isTablet),

                      const SizedBox(height: 24),
                      Divider(height: 1, color: Colors.grey.shade100),
                      const SizedBox(height: 24),

                      _buildDetailSectionHeading(l10n.posCorporateDetailsSectionVehicle, Icons.directions_car_rounded, isTablet),
                      const SizedBox(height: 16),
                      _buildDetailRow(l10n.posCorporateDetailsVehicleName, booking.vehicleName, isTablet),
                      _buildDetailRow(l10n.posCorporateDetailsLicensePlate, booking.vehiclePlate, isTablet),

                      const SizedBox(height: 24),
                      Divider(height: 1, color: Colors.grey.shade100),
                      const SizedBox(height: 24),

                      _buildDetailSectionHeading(l10n.posCorporateDetailsSectionProducts, Icons.inventory_2_rounded, isTablet),
                      const SizedBox(height: 16),
                      if ((booking.items == null || booking.items!.isEmpty) &&
                          (booking.preSelectedProducts == null || booking.preSelectedProducts.isEmpty))
                        Container(
                          padding: EdgeInsets.all(isTablet ? 20 : 16),
                          decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline_rounded, color: Colors.grey.shade500, size: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  l10n.posCorporateDetailsNoProducts,
                                  style: TextStyle(fontSize: isTablet ? 15 : 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (booking.items != null && booking.items!.isNotEmpty)
                        Container(
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(16), color: Colors.grey.shade50),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: booking.items!.length,
                            separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
                            itemBuilder: (_, index) {
                              final item = booking.items![index];
                              final itemName = item['serviceName'] ?? item['productName'] ?? 'Service package';
                              final qty = item['qty'] ?? 1;
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16, vertical: 16),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle_rounded, size: isTablet ? 20 : 18, color: Colors.green),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          LocalizedApiText(itemName.toString(), style: TextStyle(fontSize: isTablet ? 15 : 14, fontWeight: FontWeight.w700, color: AppColors.secondaryLight, letterSpacing: 0.2)),
                                          const SizedBox(height: 4),
                                          Text(l10n.posCorporateDetailsQty(qty.toString()), style: TextStyle(fontSize: isTablet ? 13 : 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
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
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(16), color: Colors.grey.shade50),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: booking.preSelectedProducts.length,
                            separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
                            itemBuilder: (_, index) => Padding(
                              padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16, vertical: 16),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle_rounded, size: isTablet ? 20 : 18, color: Colors.green),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      l10n.posCorporateDetailsProductId(booking.preSelectedProducts[index].toString()),
                                      style: TextStyle(fontSize: isTablet ? 15 : 14, fontWeight: FontWeight.w700, color: AppColors.secondaryLight, letterSpacing: 0.2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Bottom actions
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
                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), foregroundColor: Colors.grey.shade600),
                        child: Text(l10n.posCorporateActionClose, style: TextStyle(fontSize: isTablet ? 15 : 14, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (_canReviewBooking(booking))
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () async {
                            final vm = Provider.of<CorporateBookingViewModel>(context, listen: false);
                            final success = await vm.approveBooking(booking.id);
                            if (!success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(vm.errorMessage ?? l10n.posCorporateApproveError),
                                backgroundColor: Colors.red,
                              ));
                            } else {
                              vm.setFilter('All');
                              if (context.mounted) Navigator.pop(ctx);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryLight,
                            foregroundColor: AppColors.secondaryLight,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(
                            l10n.posCorporateActionApproveBooking,
                            style: TextStyle(color: AppColors.secondaryLight, fontSize: isTablet ? 15 : 14, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else if (_isApproved(booking))
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _redirectingBookingId == booking.id.toString()
                              ? null
                              : () {
                            Navigator.pop(ctx);
                            _navigateToProductGrid(context, booking, l10n);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondaryLight,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: _redirectingBookingId == booking.id.toString()
                              ? SizedBox(width: isTablet ? 18 : 16, height: isTablet ? 18 : 16, child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(l10n.posCorporateActionContinue, style: TextStyle(fontSize: isTablet ? 15 : 14, fontWeight: FontWeight.w800, letterSpacing: 0.5), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                              const SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: isTablet ? 18 : 16),
                            ],
                          ),
                        ),
                      )
                    else
                      const Expanded(flex: 2, child: SizedBox.shrink()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section heading ──────────────────────────────────────────────────────

  Widget _buildDetailSectionHeading(String title, IconData icon, bool isTablet) {
    return Row(
      children: [
        Icon(icon, size: isTablet ? 20 : 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            title,
            style: TextStyle(fontSize: isTablet ? 16 : 14, fontWeight: FontWeight.bold, color: AppColors.secondaryLight),
            overflow: TextOverflow.ellipsis,
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
            child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: isTablet ? 14 : 13, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 3,
            child: LocalizedApiText(value, style: TextStyle(color: AppColors.secondaryLight, fontSize: isTablet ? 14 : 13, fontWeight: FontWeight.w600), textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }

  // ── Reject dialog ────────────────────────────────────────────────────────

  void _showReasonDialog(BuildContext context, dynamic booking, String actionLabel, bool isTablet, AppLocalizations l10n) {
    final TextEditingController reasonController = TextEditingController();
    final Color themeColor = Colors.red.shade600;

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
            boxShadow: [BoxShadow(color: themeColor.withValues(alpha: 0.15), blurRadius: 30, spreadRadius: 5, offset: const Offset(0, 10))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
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
                        l10n.posCorporateDialogRejectTitle,
                        style: TextStyle(color: const Color(0xFF1E2124), fontSize: isTablet ? 22 : 18, fontWeight: FontWeight.w800, letterSpacing: -0.2),
                        overflow: TextOverflow.ellipsis,
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
                      l10n.posCorporateDialogRejectBody(actionLabel, booking.companyName),
                      style: TextStyle(fontSize: isTablet ? 15 : 14, color: Colors.grey.shade600, height: 1.4, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 24),
                    Text(l10n.posCorporateDialogReasonLabel, style: TextStyle(fontWeight: FontWeight.w800, fontSize: isTablet ? 14 : 13, color: AppColors.secondaryLight, letterSpacing: 0.2)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: reasonController,
                      maxLines: 4,
                      style: TextStyle(fontSize: isTablet ? 15 : 14, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: l10n.posCorporateDialogReasonHint,
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w400),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: themeColor, width: 2)),
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
                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), foregroundColor: Colors.grey.shade600),
                        child: Text(l10n.posCorporateActionCancel, style: TextStyle(fontSize: isTablet ? 15 : 14, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (reasonController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Row(children: [
                                const Icon(Icons.error_outline, color: Colors.white),
                                const SizedBox(width: 8),
                                Flexible(child: Text(l10n.posCorporateDialogReasonRequired(actionLabel))),
                              ]),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.red.shade800,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ));
                            return;
                          }

                          final vm = Provider.of<CorporateBookingViewModel>(context, listen: false);
                          final success = await vm.rejectBooking(booking.id, reasonController.text);
                          if (!context.mounted) return;
                          Navigator.pop(ctx);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Row(children: [
                                const Icon(Icons.check_circle_outline, color: Colors.white),
                                const SizedBox(width: 8),
                                Flexible(child: Text(l10n.posCorporateRejectSuccess)),
                              ]),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.green.shade700,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(vm.errorMessage ?? l10n.posCorporateRejectError),
                              backgroundColor: Colors.red,
                            ));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(l10n.posCorporateActionSubmitReason, style: TextStyle(fontSize: isTablet ? 15 : 14, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
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

  // ── Navigation ───────────────────────────────────────────────────────────

  Future<void> _navigateToProductGrid(BuildContext context, dynamic booking, AppLocalizations l10n) async {
    final bid = booking.id?.toString() ?? '';
    if (mounted) setState(() => _redirectingBookingId = bid);

    final posVm = Provider.of<PosViewModel>(context, listen: false);
    final bookingOrderId = booking.id?.toString().trim() ?? '';
    final bookingJobBadge = _bookingLooksCompleted(booking) ? 'Completed' : 'Pending';

    posVm.setCustomerData(
      name: booking.companyName?.toString() ?? '',
      vat: '',
      mobile: '',
      vehicleNumber: booking.vehiclePlate?.toString() ?? '',
      make: booking.vehicleName?.toString() ?? '',
      model: '',
      odometer: 0,
    );

    posVm.setOrderSearchQuery('');
    posVm.setOrderStatusFilter('All');
    posVm.setOrdersListTab('All');

    await posVm.fetchOrders(
      silent: true,
      preferredOrderId: bookingOrderId.isNotEmpty ? bookingOrderId : null,
    );

    final matchedOrder = _resolveCorporateOrderMatch(posVm, booking, bookingOrderId);
    if (matchedOrder == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.posCorporateNoMatchingOrder),
        backgroundColor: Colors.orange,
      ));
      if (mounted) setState(() => _redirectingBookingId = null);
      return;
    }

    posVm.selectOrder(matchedOrder);
    posVm.setOrdersListTab(bookingJobBadge);

    if (!context.mounted) return;
    navigateToPosShellOrdersTab(context);
    if (mounted) setState(() => _redirectingBookingId = null);
  }

  PosOrder? _resolveCorporateOrderMatch(PosViewModel posVm, dynamic booking, String bookingOrderId) {
    final allOrders = List<PosOrder>.from(posVm.orders)
      ..sort((a, b) => (int.tryParse(b.id) ?? 0).compareTo(int.tryParse(a.id) ?? 0));

    if (bookingOrderId.isNotEmpty) {
      try {
        return allOrders.firstWhere((o) => o.id.trim() == bookingOrderId);
      } catch (_) {}
    }

    final plate = booking.vehiclePlate?.toString().trim().toLowerCase() ?? '';
    final company = booking.companyName?.toString().trim().toLowerCase() ?? '';
    final hasBookingPlate = plate.isNotEmpty;

    if (hasBookingPlate) {
      final plateMatches = allOrders.where((o) {
        final isCorporate = o.source.toLowerCase().contains('corporate') || (o.corporateAccountId?.isNotEmpty ?? false);
        if (!isCorporate) return false;
        final orderPlate = o.plateNumber.trim().toLowerCase();
        return orderPlate.isNotEmpty && orderPlate == plate;
      }).toList();
      if (plateMatches.isNotEmpty) return plateMatches.first;
    }

    final candidates = allOrders.where((o) {
      final isCorporate = o.source.toLowerCase().contains('corporate') || (o.corporateAccountId?.isNotEmpty ?? false);
      if (!isCorporate) return false;
      final orderPlate = o.plateNumber.trim().toLowerCase();
      final orderCompany = (o.corporateCompanyName ?? o.customerName).trim().toLowerCase();
      if (hasBookingPlate) return false;
      return orderPlate.isNotEmpty && orderPlate == plate || (company.isNotEmpty && orderCompany == company);
    }).toList();

    if (candidates.isEmpty) return null;
    candidates.sort((a, b) => (int.tryParse(b.id) ?? 0).compareTo(int.tryParse(a.id) ?? 0));
    return candidates.first;
  }

  bool _bookingLooksCompleted(dynamic booking) {
    final statusRaw = '${booking.statusDisplay?.toString() ?? ''} ${booking.status?.toString() ?? ''}'.toLowerCase();
    return statusRaw.contains('complete') || statusRaw.contains('invoiced');
  }
}