import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../locker_view_model.dart';
import '../../../models/locker_models.dart';
import '../../../utils/app_colors.dart';
import '../Collection/record_collection_view.dart';

class LockerRequestDetailsView extends StatelessWidget {
  final LockerRequest request;
  const LockerRequestDetailsView({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Consumer<LockerViewModel>(
      builder: (context, vm, child) {
        final isManager = vm.currentUser?.role == 'Manager';
        
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          appBar: AppBar(
            backgroundColor: AppColors.primaryLight,
            elevation: 0,
            toolbarHeight: 72,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            title: const Text('REQUEST DETAILS', style: TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 2)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.secondaryLight, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusHeader(request.status),
                const SizedBox(height: 24),
                _buildLockedCashSection(request),
                const SizedBox(height: 32),
                _buildTransactionDetails(request),
                const SizedBox(height: 48),
                _buildActionButtons(context, vm, isManager),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusHeader(LockerStatus status) {
    Color color = Colors.orange;
    switch (status) {
      case LockerStatus.collected: color = Colors.teal; break;
      case LockerStatus.awaitingApproval: color = Colors.blue; break;
      case LockerStatus.approved: color = Colors.green; break;
      case LockerStatus.rejected: color = Colors.red; break;
      default: color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: const Icon(Icons.shield_outlined, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SYSTEM STATUS',
                style: TextStyle(color: color.withOpacity(0.5), fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 1),
              ),
              Text(
                status.name.toUpperCase(),
                style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.info_outline_rounded, color: Colors.black12, size: 20),
        ],
      ),
    );
  }

  Widget _buildLockedCashSection(LockerRequest request) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppColors.secondaryLight.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 10)),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E323A), AppColors.secondaryLight],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.security_rounded, color: AppColors.primaryLight, size: 32),
          ),
          const SizedBox(height: 24),
          Text(
            'SAR ${request.lockedCashAmount.toInt()}',
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1),
          ),
          const SizedBox(height: 6),
          Text(
            'TOTAL SECURED ASSET',
            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetails(LockerRequest request) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'INTERNAL DATA',
          style: TextStyle(color: AppColors.secondaryLight, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              _buildDetailItem('Source Branch', request.branchName, Icons.location_on_outlined),
              _buildDetailItem('CASHIER Identity', request.cashierName, Icons.person_outline),
              _buildDetailItem('Shift Close Time', DateFormat('dd MMM, hh:mm A').format(request.closingDate), Icons.access_time),
              if (request.assignedOfficerId != null) ...[
                _buildDetailItem('Assigned Officer', 'Officer ID: ${request.assignedOfficerId}', Icons.assignment_ind_outlined),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondaryLight.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.secondaryLight.withOpacity(0.4), size: 16),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: const TextStyle(color: AppColors.secondaryLight, fontSize: 13, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, LockerViewModel vm, bool isManager) {
    if (request.status == LockerStatus.pending && isManager) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () => _showOfficerSelection(context, vm),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryLight,
            foregroundColor: AppColors.secondaryLight,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_add_alt_1_rounded, size: 20),
              SizedBox(width: 12),
              Text('ASSIGN COLLECTION OFFICER', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
            ],
          ),
        ),
      );
    }
    
    if (request.status == LockerStatus.assigned) {
       return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => RecordCollectionView(request: request)));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: AppColors.secondaryLight,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('PROCEED TO COLLECTION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2)),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.secondaryLight,
              side: BorderSide(color: AppColors.secondaryLight.withOpacity(0.1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('GENERATE AUDIT PDF', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2)),
          ),
        ),
      ],
    );
    }

    return const SizedBox.shrink();
  }

  void _showOfficerSelection(BuildContext context, LockerViewModel vm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2)),
            ),
            const Text('SELECT FIELD OFFICER', style: TextStyle(color: AppColors.secondaryLight, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 24),
            ...vm.officers.where((o) => o.role == 'Officer').map((officer) => _buildOfficerTile(context, vm, officer.name, officer.id)),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficerTile(BuildContext context, LockerViewModel vm, String name, String id) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppColors.secondaryLight.withOpacity(0.05),
        child: const Icon(Icons.person_3_outlined, color: AppColors.secondaryLight, size: 20),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.secondaryLight)),
      subtitle: Text('ID: $id', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.black12),
      onTap: () {
        vm.assignOfficer(request.id, id);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ASSIGNED TO ${name.toUpperCase()}'),
            backgroundColor: AppColors.secondaryLight,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }
}
