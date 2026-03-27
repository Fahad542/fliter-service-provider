import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_colors.dart';
import '../../../widgets/pos_widgets.dart';
import 'package:filter_service_providers/views/Workshop pos app/Navbar/pos_shell.dart';
import '../Technician Screen/technician_view_model.dart';
import 'technician_assignment_view_model.dart';
import '../../../utils/toast_service.dart';

class PosTechnicianAssignmentView extends StatefulWidget {
  final String jobId;

  const PosTechnicianAssignmentView({super.key, required this.jobId});

  @override
  State<PosTechnicianAssignmentView> createState() =>
      _PosTechnicianAssignmentViewState();
}

class _PosTechnicianAssignmentViewState
    extends State<PosTechnicianAssignmentView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TechnicianViewModel>().fetchTechnicians();
    });
  }

  void _handleMultiAssign(
    BuildContext context,
    TechnicianAssignmentViewModel assignVm,
  ) async {
    if (assignVm.selectedTechnicianIds.isEmpty) return;

    final vm = context.read<TechnicianViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final success = await vm.assignMultipleTechnicians(
      widget.jobId,
      assignVm.selectedTechnicianIds.toList(),
    );

    if (!mounted) return;

    if (success) {
      ToastService.showSuccess(context, 'Technicians assigned successfully');
      // Navigate back to orders view
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => PosShell(initialIndex: 2)),
        (route) => false,
      );
    } else {
      ToastService.showError(
        context,
        vm.assignmentMessage ?? 'Failed to assign technicians',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(isTablet ? 1.4 : 1.0)),
      child: ChangeNotifierProvider(
        create: (_) => TechnicianAssignmentViewModel(),
        child: Builder(
          builder: (context) {
            final assignVm = context.watch<TechnicianAssignmentViewModel>();
            return Scaffold(
              backgroundColor: const Color(0xFFFBF9F6),
              appBar: PosScreenAppBar(title: 'Technician Assignment '),
              body: Consumer<TechnicianViewModel>(
                builder: (context, vm, child) {
                  if (vm.isLoading && vm.technicians.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (vm.errorMessage != null && vm.technicians.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: ${vm.errorMessage}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => vm.fetchTechnicians(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Filter by search query
                  final technicians = vm.technicians.where((tech) {
                    final query = assignVm.searchQuery.toLowerCase();
                    return tech.name.toLowerCase().contains(query) ||
                        (tech.employeeType).toLowerCase().contains(query);
                  }).toList();

                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            onChanged: assignVm.setSearchQuery,
                            decoration: InputDecoration(
                              hintText: 'Search technicians...',
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey.shade400,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: technicians.isEmpty
                            ? const Center(child: Text('No technicians found'))
                            : GridView.builder(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 24 : 16,
                                  vertical: 8,
                                ),
                                itemCount: technicians.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: isTablet ? 3 : 1,
                                      childAspectRatio: isTablet ? 2.8 : 3.8,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 6,
                                    ),
                                itemBuilder: (context, index) {
                                  final tech = technicians[index];
                                  final isSelected = assignVm
                                      .selectedTechnicianIds
                                      .contains(tech.id);

                                  return InkWell(
                                    onTap:
                                        (vm.isAssigning ||
                                            tech.slotsUsed >= tech.totalSlots)
                                        ? null
                                        : () => assignVm.toggleSelection(tech),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Opacity(
                                      opacity: tech.isEligible ? 1.0 : 0.5,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primaryLight
                                                    .withValues(alpha: 0.1)
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.primaryLight
                                                : Colors.grey.shade200,
                                            width: isSelected ? 2 : 1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.02,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Stack(
                                              children: [
                                                CircleAvatar(
                                                  radius: isTablet ? 24 : 20,
                                                  backgroundColor: AppColors
                                                      .primaryLight
                                                      .withValues(alpha: 0.1),
                                                  child: Icon(
                                                    Icons.person,
                                                    size: isTablet ? 24 : 20,
                                                    color: AppColors
                                                        .secondaryLight,
                                                  ),
                                                ),
                                                if (tech.isOnline)
                                                  Positioned(
                                                    right: 0,
                                                    bottom: 0,
                                                    child: Container(
                                                      width: isTablet ? 12 : 10,
                                                      height: isTablet
                                                          ? 12
                                                          : 10,
                                                      decoration: BoxDecoration(
                                                        color: Colors.green,
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: Colors.white,
                                                          width: 2,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    tech.name,
                                                    style: TextStyle(
                                                      fontSize: isTablet
                                                          ? 15
                                                          : 14,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: const Color(
                                                        0xFF1E2124,
                                                      ),
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  if (tech.departments.isNotEmpty) ...[
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      tech.departments.map((d) => d.name).join(' • '),
                                                      style: TextStyle(
                                                        fontSize: isTablet ? 12 : 11,
                                                        color: Colors.blueGrey,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    tech.isOnline
                                                        ? 'Online'
                                                        : 'Last seen: ${tech.formattedLastSeen}',
                                                    style: TextStyle(
                                                      fontSize: isTablet
                                                          ? 12
                                                          : 11,
                                                      color: tech.isOnline
                                                          ? Colors.green
                                                          : Colors.grey,
                                                      fontWeight: tech.isOnline
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .work_history_outlined,
                                                        size: isTablet
                                                            ? 14
                                                            : 12,
                                                        color:
                                                            tech.slotsUsed >=
                                                                tech.totalSlots
                                                            ? Colors
                                                                  .red
                                                                  .shade400
                                                            : Colors
                                                                  .blue
                                                                  .shade400,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(
                                                          'Slots: ${tech.slotsUsed}/${tech.totalSlots} used',
                                                          style: TextStyle(
                                                            fontSize: isTablet
                                                                ? 12
                                                                : 10,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color:
                                                                tech.slotsUsed >=
                                                                    tech.totalSlots
                                                                ? Colors
                                                                      .red
                                                                      .shade600
                                                                : Colors
                                                                      .blue
                                                                      .shade600,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (tech.slotsUsed <
                                                tech.totalSlots)
                                              Checkbox(
                                                value: isSelected,
                                                onChanged: vm.isAssigning
                                                    ? null
                                                    : (val) => assignVm
                                                          .toggleSelection(
                                                            tech,
                                                          ),
                                                activeColor:
                                                    AppColors.secondaryLight,
                                                checkColor:
                                                    AppColors.primaryLight,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
              bottomNavigationBar: SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        offset: const Offset(0, -4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: assignVm.selectedTechnicianIds.isEmpty
                      ? Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  _showBroadcastWorkshopDialog(context);
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.secondaryLight,
                                  side: const BorderSide(
                                    color: AppColors.secondaryLight,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.campaign_outlined,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        'Broadcast to Workshop',
                                        style: TextStyle(
                                          fontSize: isTablet ? 14 : 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  _showBroadcastOnCallDialog(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryLight,
                                  foregroundColor: AppColors.secondaryLight,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.online_prediction,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        'Broadcast to On-Call',
                                        style: TextStyle(
                                          fontSize: isTablet ? 14 : 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : Consumer<TechnicianViewModel>(
                          builder: (context, vm, child) => Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: vm.isAssigning
                                      ? null
                                      : () => _handleMultiAssign(
                                          context,
                                          assignVm,
                                        ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.secondaryLight,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                      horizontal: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (vm.isAssigning)
                                        const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      else
                                        const Icon(
                                          Icons.assignment_ind,
                                          size: 18,
                                        ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          vm.isAssigning
                                              ? 'Assigning...'
                                              : 'Assign to ${assignVm.selectedTechnicianIds.length} Technician${assignVm.selectedTechnicianIds.length > 1 ? 's' : ''}',
                                          style: TextStyle(
                                            fontSize: isTablet ? 14 : 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showBroadcastWorkshopDialog(BuildContext context) {
    ToastService.showInfo(context, 'Broadcasted to Workshop technicians');
  }

  void _showBroadcastOnCallDialog(BuildContext context) {
    ToastService.showInfo(context, 'Broadcasted to On-Call technicians');
  }
}
