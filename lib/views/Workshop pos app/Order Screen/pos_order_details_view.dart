import 'package:flutter/material.dart';
import '../../../models/pos_order_model.dart';
import '../../../utils/app_colors.dart';

class PosOrderDetailsView extends StatelessWidget {
  final PosOrder order;

  const PosOrderDetailsView({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.secondaryLight,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          'Order Details',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          isTablet ? 28 : 16,
          isTablet ? 20 : 14,
          isTablet ? 28 : 16,
          isTablet ? 32 : 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(isTablet),
            const SizedBox(height: 12),
            _buildSectionCard(
              isTablet: isTablet,
              title: 'Customer',
              icon: Icons.person_outline_rounded,
              children: [
                _infoRow(
                  'Vehicle no.',
                  order.plateNumber.isNotEmpty ? order.plateNumber : '-',
                  isTablet,
                ),
                _infoRow('Customer', order.customerName, isTablet),
                _infoRow(
                  'Mobile',
                  order.customer?.mobile.isNotEmpty == true
                      ? order.customer!.mobile
                      : '-',
                  isTablet,
                ),
                _infoRow(
                  'VAT',
                  order.customer?.vatNumber.isNotEmpty == true
                      ? order.customer!.vatNumber
                      : '-',
                  isTablet,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildSectionCard(
              isTablet: isTablet,
              title: 'Vehicle',
              icon: Icons.directions_car_outlined,
              children: [
                _infoRow(
                  'Make/Model',
                  order.carModel.isNotEmpty ? order.carModel : '-',
                  isTablet,
                ),
                _infoRow(
                  'Plate',
                  order.plateNumber.isNotEmpty ? order.plateNumber : '-',
                  isTablet,
                ),
                _infoRow('Odometer', '${order.odometerReading} km', isTablet),
              ],
            ),
            const SizedBox(height: 12),
            _buildJobsSection(isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Center(
            child: Container(
              width: isTablet ? 54 : 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 16 : 12,
              vertical: isTablet ? 14 : 10,
            ),
            decoration: BoxDecoration(
              color: AppColors.secondaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.plateNumber.isNotEmpty
                            ? order.plateNumber.toUpperCase()
                            : '—',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: isTablet ? 19 : 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        () {
                          final m = order.carModel.isNotEmpty
                              ? order.carModel
                              : '-';
                          final c = order.customerName;
                          if (c != 'Unknown' && c.isNotEmpty) {
                            return '$c  •  $m';
                          }
                          return m;
                        }(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.82),
                          fontWeight: FontWeight.w500,
                          fontSize: isTablet ? 13 : 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Created: ${order.date.isNotEmpty ? order.date : '-'}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.72),
                                fontSize: isTablet ? 12 : 10,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: order.statusColor.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              order.statusText,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isTablet ? 11 : 9.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 12 : 10,
                    vertical: isTablet ? 8 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Order #${order.id.split('-').last.toUpperCase()}',
                    style: TextStyle(
                      color: AppColors.secondaryLight,
                      fontWeight: FontWeight.w700,
                      fontSize: isTablet ? 13 : 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSectionCard({
    required bool isTablet,
    required String title,
    required List<Widget> children,
    IconData? icon,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 18 : 14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: isTablet ? 18 : 16,
                    color: AppColors.secondaryLight,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E2124),
                  ),
                ),
              ),
            ]),

          SizedBox(height: isTablet ? 10 : 8),
          Divider(height: 1, color: Colors.grey.shade200),
          SizedBox(height: isTablet ? 12 : 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildJobsSection(bool isTablet) {
    final jobs = order.jobs;
    if (jobs.isEmpty) {
      return _buildSectionCard(
        isTablet: isTablet,
        title: 'Jobs',
        children: [_infoRow('Details', 'No jobs found', isTablet)],
      );
    }

    return Column(
      children: jobs.asMap().entries.map((entry) {
        final i = entry.key;
        final job = entry.value;
        final techNames = job.technicians
            .map((t) => t.name)
            .where((n) => n.trim().isNotEmpty)
            .join(', ');
        return Padding(
          padding: EdgeInsets.only(bottom: i == jobs.length - 1 ? 0 : 12),
          child: _buildSectionCard(
            isTablet: isTablet,
            title: 'Job ${i + 1} • ${job.status.replaceAll('_', ' ').toUpperCase()}',
            icon: Icons.work_outline_rounded,
            children: [
              _infoRow(
                'Department',
                job.department.isNotEmpty ? job.department : '-',
                isTablet,
              ),
              _infoRow(
                'Technician',
                techNames.isNotEmpty ? techNames : '-',
                isTablet,
              ),
              _infoRow(
                'Subtotal',
                'SAR ${(job.totalAmount - job.vatAmount).toStringAsFixed(2)}',
                isTablet,
              ),
              _infoRow('VAT', 'SAR ${job.vatAmount.toStringAsFixed(2)}', isTablet),
              _infoRow('Total', 'SAR ${job.totalAmount.toStringAsFixed(2)}', isTablet),
              const SizedBox(height: 6),
              Text(
                'Items (${job.items.length})',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: isTablet ? 16 : 14,
                  color: const Color(0xFF1E2124),
                ),
              ),
              const SizedBox(height: 6),
              ...job.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 10 : 8,
                        vertical: isTablet ? 8 : 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE9EDF3)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.productName.isNotEmpty
                                  ? item.productName
                                  : item.productId,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: isTablet ? 14 : 12.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'x${item.qty.toStringAsFixed(item.qty % 1 == 0 ? 0 : 1)}',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: isTablet ? 13 : 12,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'SAR ${item.lineTotal.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: isTablet ? 13 : 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _infoRow(String key, String value, bool isTablet) {
    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 8 : 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isTablet ? 130 : 96,
            child: Text(
              key,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: isTablet ? 14 : 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: const Color(0xFF1E2124),
                fontSize: isTablet ? 15 : 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE8ECF3)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x12000000),
          blurRadius: 10,
          offset: Offset(0, 3),
        ),
      ],
    );
  }
}
