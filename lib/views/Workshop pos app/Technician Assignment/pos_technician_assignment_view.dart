import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_colors.dart';
import '../../../widgets/pos_widgets.dart';
import 'package:filter_service_providers/views/Workshop pos app/Navbar/pos_shell.dart';
import '../Home Screen/pos_view_model.dart';
import '../Technician Screen/technician_view_model.dart';
import 'technician_assignment_view_model.dart';
import '../../../utils/toast_service.dart';

class PosTechnicianAssignmentView extends StatefulWidget {
  final String jobId;
  final String? departmentName;
  final String? departmentId; // needed for walk-in order API
  final bool isWalkIn; // true = walk-in flow, call walk-in API on assign

  const PosTechnicianAssignmentView({
    super.key,
    required this.jobId,
    this.departmentName,
    this.departmentId,
    this.isWalkIn = false,
  });

  @override
  State<PosTechnicianAssignmentView> createState() =>
      _PosTechnicianAssignmentViewState();
}

class _PosTechnicianAssignmentViewState
    extends State<PosTechnicianAssignmentView> {
  /// Existing job on server, or walk-in/edit flow (order saved when broadcasting / assigning).
  bool get _canTapBroadcast =>
      widget.jobId.isNotEmpty || widget.isWalkIn;

  /// `workshop` / `on_call` while that broadcast is in progress (null = idle).
  String? _broadcastingDuty;

  /// After first save in walk-in mode, reuse this job for another broadcast tap (avoid duplicate POST).
  String? _cachedJobIdFromSave;

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
    final posVm = context.read<PosViewModel>();
    final navigator = Navigator.of(context);

    String jobIdToUse = widget.jobId;

    // Walk-in / Edit-order flow: call appropriate API first
    if (widget.isWalkIn) {
      final deptId = widget.departmentId ?? '';
      final isEditMode = posVm.editingOrder != null;

      if (isEditMode) {
        // Edit order: call PATCH edit API, reuse existing jobId
        final existingJobId = posVm.editingCompletingOrderId ?? '';
        if (existingJobId.isEmpty) {
          ToastService.showError(context, 'Failed to get job ID for edit');
          return;
        }
        final success = await posVm.submitEditOrder(
          deptId.isNotEmpty ? [deptId] : [],
          context,
        );
        if (!mounted) return;
        if (!success) return;
        jobIdToUse = existingJobId;
      } else {
        // New walk-in order: call walk-in API, get new jobId from response
        final success = await posVm.submitWalkInOrder(
          deptId.isNotEmpty ? [deptId] : [],
          context,
          clearCustomerOnSuccess: false,
        );
        if (!mounted) return;
        if (!success) return;
        jobIdToUse = posVm.currentJobId ?? '';
        if (jobIdToUse.isEmpty) {
          ToastService.showError(context, 'Failed to get order ID');
          return;
        }
      }
    }

    final success = await vm.assignMultipleTechnicians(
      jobIdToUse,
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

  /// Same persistence as multi-assign: walk-in POST or edit PATCH, then returns real `jobId`.
  Future<String?> _resolveJobIdForBroadcast(BuildContext context) async {
    if (widget.jobId.isNotEmpty) return widget.jobId;
    final cached = _cachedJobIdFromSave;
    if (cached != null && cached.isNotEmpty) return cached;
    if (!widget.isWalkIn) return null;

    final posVm = context.read<PosViewModel>();
    final deptId = widget.departmentId ?? '';
    final isEditMode = posVm.editingOrder != null;

    if (isEditMode) {
      final existingJobId = posVm.editingCompletingOrderId ?? '';
      if (existingJobId.isEmpty) {
        ToastService.showError(context, 'Failed to get job ID for edit');
        return null;
      }
      final success = await posVm.submitEditOrder(
        deptId.isNotEmpty ? [deptId] : [],
        context,
      );
      if (!mounted) return null;
      if (!success) return null;
      _cachedJobIdFromSave = existingJobId;
      return existingJobId;
    }

    final success = await posVm.submitWalkInOrder(
      deptId.isNotEmpty ? [deptId] : [],
      context,
      clearCustomerOnSuccess: false,
    );
    if (!mounted) return null;
    if (!success) return null;
    final jobIdToUse = posVm.currentJobId ?? '';
    if (jobIdToUse.isEmpty) {
      ToastService.showError(context, 'Failed to get order ID');
      return null;
    }
    _cachedJobIdFromSave = jobIdToUse;
    return jobIdToUse;
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(1.0)),
      child: ChangeNotifierProvider(
        create: (_) =>
            TechnicianAssignmentViewModel()
              ..setDepartmentName(widget.departmentName),
        child: Builder(
          builder: (context) {
            final assignVm = context.watch<TechnicianAssignmentViewModel>();
            return Scaffold(
              backgroundColor: const Color(0xFFFBF9F6),
              appBar: PosScreenAppBar(
                title: 'Technician Assignment ',
                actions: [
                  // if (widget.departmentName != null &&
                  //     widget.departmentName!.isNotEmpty)
                  //   TextButton.icon(
                  //     onPressed: () => assignVm.setShowAll(!assignVm.showAll),
                  //     icon: Icon(
                  //       assignVm.showAll
                  //           ? Icons.filter_alt
                  //           : Icons.all_inclusive,
                  //       size: 18,
                  //       color: AppColors.secondaryLight,
                  //     ),
                  //     label: Text(
                  //       assignVm.showAll ? 'Show Dept' : 'Show All',
                  //       style: const TextStyle(
                  //         color: AppColors.secondaryLight,
                  //         fontWeight: FontWeight.bold,
                  //         fontSize: 12,
                  //       ),
                  //     ),
                  //   ),
                ],
              ),
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

                  // Filter by search query and department
                  final technicians = vm.technicians.where((tech) {
                    // Search Filter
                    final query = assignVm.searchQuery.toLowerCase();
                    final matchesSearch =
                        tech.name.toLowerCase().contains(query) ||
                        (tech.employeeType).toLowerCase().contains(query);

                    if (!matchesSearch) return false;

                    // Department Filter
                    if (assignVm.showAll ||
                        assignVm.departmentName == null ||
                        assignVm.departmentName!.isEmpty) {
                      return true;
                    }

                    return tech.departments.any(
                      (d) =>
                          d.name.toLowerCase() ==
                          assignVm.departmentName!.toLowerCase(),
                    );
                  }).toList();

                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: Colors.grey.shade200),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.04,
                                      ),
                                      blurRadius: 14,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  onChanged: assignVm.setSearchQuery,
                                  decoration: InputDecoration(
                                    hintText: 'Search technicians...',
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: Colors.grey.shade400,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (widget.departmentName != null &&
                              widget.departmentName!.isNotEmpty)
                            GestureDetector(
                              onTap: () =>
                                  assignVm.setShowAll(!assignVm.showAll),

                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: isTablet ? 24.0 : 16,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight.withValues(
                                      alpha: 0.25,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    assignVm.showAll ? 'Show Dept' : 'Show All',
                                    style: const TextStyle(
                                      color: AppColors.secondaryLight,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
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
                                      crossAxisCount: isLandscape
                                          ? 3
                                          : (isTablet ? 2 : 1),
                                      mainAxisExtent: isTablet ? 142 : 124,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 10,
                                    ),
                                itemBuilder: (context, index) {
                                  final tech = technicians[index];
                                  final isSelected = assignVm
                                      .selectedTechnicianIds
                                      .contains(tech.id);

                                  return InkWell(
                                    onTap:
                                        (vm.isAssigning ||
                                            tech.slotsUsed >= tech.totalSlots ||
                                            !tech.isOnline)
                                        ? null
                                        : () => assignVm.toggleSelection(tech),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Opacity(
                                      opacity: tech.isEligible ? 1.0 : 0.5,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 10,
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
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Stack(
                                              children: [
                                                CircleAvatar(
                                                  radius: isTablet ? 25 : 22,
                                                  backgroundColor: AppColors
                                                      .primaryLight
                                                      .withValues(alpha: 0.1),
                                                  child: Icon(
                                                    Icons.person,
                                                    size: isTablet ? 25 : 21,
                                                    color: AppColors
                                                        .secondaryLight,
                                                  ),
                                                ),
                                                Positioned(
                                                  right: 0,
                                                  bottom: 0,
                                                  child: Container(
                                                    width: isTablet ? 12 : 10,
                                                    height: isTablet ? 12 : 10,
                                                    decoration: BoxDecoration(
                                                      color: tech.isOnline
                                                          ? Colors.green
                                                          : Colors.grey.shade400,
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
                                                    tech.isOnline
                                                        ? 'Online'
                                                        : 'Last seen: ${tech.formattedLastSeen}',
                                                    style: TextStyle(
                                                      fontSize: isTablet
                                                          ? 13
                                                          : 12,
                                                      color: tech.isOnline
                                                          ? Colors.green.shade700
                                                          : Colors.grey,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          tech.name,
                                                          style: TextStyle(
                                                            fontSize: isTablet
                                                                ? 16
                                                                : 15,
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
                                                      ),
                                                    ],
                                                  ),
                                                  if (tech
                                                      .departments
                                                      .isNotEmpty) ...[
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      tech.departments
                                                          .map((d) => d.name)
                                                          .join(' • '),
                                                      style: TextStyle(
                                                        fontSize: isTablet
                                                            ? 13
                                                            : 12,
                                                        color: Colors.blueGrey,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                  const SizedBox(height: 3),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.work_history_outlined,
                                                        size: isTablet ? 14 : 12,
                                                        color:
                                                            tech.slotsUsed >=
                                                                tech.totalSlots
                                                            ? Colors
                                                                  .red
                                                                  .shade400
                                                            : Colors
                                                                  .green
                                                                  .shade400,
                                                      ),
                                                      const SizedBox(width: 3),
                                                      Text(
                                                        'Slots: ${tech.slotsUsed}/${tech.totalSlots}',
                                                        style: TextStyle(
                                                          fontSize: isTablet
                                                              ? 12
                                                              : 11,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              tech.slotsUsed >=
                                                                  tech.totalSlots
                                                              ? Colors
                                                                    .red
                                                                    .shade600
                                                              : Colors
                                                                    .green
                                                                    .shade600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (tech.isOnline &&
                                                tech.slotsUsed <
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
                                                visualDensity:
                                                    const VisualDensity(
                                                      horizontal: 0.2,
                                                      vertical: 0.2,
                                                    ),
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
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        offset: const Offset(0, -4),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                  child: assignVm.selectedTechnicianIds.isEmpty
                      ? Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: (_canTapBroadcast &&
                                        _broadcastingDuty == null)
                                    ? () => _broadcastWorkshop(context)
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondaryLight,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                      Colors.grey.shade300,
                                  disabledForegroundColor:
                                      Colors.grey.shade500,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_broadcastingDuty == 'workshop')
                                      const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    else
                                      const Icon(
                                        Icons.campaign_outlined,
                                        size: 18,
                                      ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        'Broadcast to Workshop',
                                        style: TextStyle(
                                          fontSize: isTablet ? 15 : 13,
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
                                onPressed: (_canTapBroadcast &&
                                        _broadcastingDuty == null)
                                    ? () => _broadcastOnCall(context)
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryLight,
                                  foregroundColor: AppColors.secondaryLight,
                                  disabledBackgroundColor:
                                      AppColors.primaryLight.withOpacity(0.5),
                                  disabledForegroundColor:
                                      AppColors.secondaryLight.withOpacity(0.5),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_broadcastingDuty == 'on_call')
                                      SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.secondaryLight,
                                        ),
                                      )
                                    else
                                      const Icon(
                                        Icons.online_prediction,
                                        size: 18,
                                      ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        'Broadcast to On-Call',
                                        style: TextStyle(
                                          fontSize: isTablet ? 15 : 13,
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
                                      vertical: 16,
                                      horizontal: 10,
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
                                            fontSize: isTablet ? 15 : 13,
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

  Future<void> _broadcastWorkshop(BuildContext context) async {
    if (!_canTapBroadcast || _broadcastingDuty != null) return;
    setState(() => _broadcastingDuty = 'workshop');
    try {
      final jobId = await _resolveJobIdForBroadcast(context);
      if (!mounted) return;
      if (jobId == null || jobId.isEmpty) return;
      await context.read<PosViewModel>().broadcastJob(
            context,
            jobId,
            dutyMode: 'workshop',
          );
    } finally {
      if (mounted) setState(() => _broadcastingDuty = null);
    }
  }

  Future<void> _broadcastOnCall(BuildContext context) async {
    if (!_canTapBroadcast || _broadcastingDuty != null) return;
    setState(() => _broadcastingDuty = 'on_call');
    try {
      final jobId = await _resolveJobIdForBroadcast(context);
      if (!mounted) return;
      if (jobId == null || jobId.isEmpty) return;
      await context.read<PosViewModel>().broadcastJob(
            context,
            jobId,
            dutyMode: 'on_call',
          );
    } finally {
      if (mounted) setState(() => _broadcastingDuty = null);
    }
  }
}
