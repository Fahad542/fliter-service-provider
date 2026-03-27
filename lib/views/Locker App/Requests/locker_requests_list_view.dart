import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../locker_view_model.dart';
import '../../../models/locker_models.dart';
import '../../../utils/app_colors.dart';
import 'locker_request_details_view.dart';

class LockerRequestsListView extends StatelessWidget {
  const LockerRequestsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LockerViewModel>(
      builder: (context, vm, child) {
        final requests = vm.filteredRequests;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          appBar: AppBar(
            backgroundColor: AppColors.primaryLight,
            toolbarHeight: 72,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            automaticallyImplyLeading: false,
            title: const Text('ASSET COLLECTION', style: TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 2)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.secondaryLight, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: requests.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    return _buildPremiumRequestCard(context, vm, request);
                  },
                ),
        );
      },
    );
  }

  Widget _buildPremiumRequestCard(BuildContext context, LockerViewModel vm, LockerRequest request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 6)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => LockerRequestDetailsView(request: request)));
          },
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                request.branchName.toUpperCase(),
                                style: TextStyle(color: Colors.black.withOpacity(0.2), fontWeight: FontWeight.w900, fontSize: 8, letterSpacing: 1),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'REF: LCK-00${request.id}',
                                style: const TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        if (vm.currentUser?.role == 'Manager' && request.status == LockerStatus.pending)
                          InkWell(
                            onTap: () => _showAssignmentSheet(context, vm, request),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.person_add_alt_1_rounded, color: AppColors.secondaryLight, size: 12),
                                  SizedBox(width: 4),
                                  Text(
                                    'ASSIGN',
                                    style: TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 8, letterSpacing: 1),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          _buildStatusBadge(request.status),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SAR ${request.lockedCashAmount.toInt()}',
                              style: const TextStyle(color: AppColors.secondaryLight, fontSize: 20, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'LOCKED CASH ASSET',
                              style: TextStyle(color: Colors.black.withOpacity(0.2), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              DateFormat('dd MMM, yy').format(request.closingDate),
                              style: const TextStyle(color: AppColors.secondaryLight, fontSize: 12, fontWeight: FontWeight.w900),
                            ),
                            Text(
                              DateFormat('hh:mm A').format(request.closingDate),
                              style: TextStyle(color: Colors.black.withOpacity(0.2), fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildStatusBadge(LockerStatus status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 8, letterSpacing: 0.5),
      ),
    );
  }

  Color _getStatusColor(LockerStatus status) {
    switch (status) {
      case LockerStatus.pending: return Colors.orange;
      case LockerStatus.awaitingApproval: return Colors.blue;
      case LockerStatus.collected: return Colors.teal;
      case LockerStatus.approved: return Colors.green;
      case LockerStatus.rejected: return Colors.red;
      default: return Colors.grey;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.black.withOpacity(0.05)),
          const SizedBox(height: 20),
          const Text('No Active Requests', style: TextStyle(color: Colors.black38, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showAssignmentSheet(BuildContext context, LockerViewModel vm, LockerRequest request) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ASSIGN COLLECTION OFFICER',
              style: TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2),
            ),
            const SizedBox(height: 8),
            Text(
              'SELECT AN OFFICER TO HANDLE ${request.branchName.toUpperCase()}',
              style: TextStyle(color: Colors.black.withOpacity(0.3), fontWeight: FontWeight.bold, fontSize: 9, letterSpacing: 1),
            ),
            const SizedBox(height: 24),
            ...vm.officers.where((o) => o.role == 'Officer').map((officer) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                onTap: () {
                  vm.assignOfficer(request.id, officer.id);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('ASSIGNED TO ${officer.name.toUpperCase()}'),
                      backgroundColor: AppColors.secondaryLight,
                    ),
                  );
                },
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryLight.withOpacity(0.1),
                  child: Text(officer.name[0], style: const TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.bold)),
                ),
                title: Text(officer.name, style: const TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 14)),
                subtitle: Text('ID: ${officer.id}', style: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.black12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.black.withOpacity(0.04)),
                ),
              ),
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
