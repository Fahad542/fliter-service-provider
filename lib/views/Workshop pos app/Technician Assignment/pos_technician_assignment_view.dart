import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_colors.dart';
import '../../../widgets/pos_widgets.dart';
import 'package:filter_service_providers/views/Workshop pos app/Navbar/pos_shell.dart';
import '../Home Screen/pos_view_model.dart';
import '../Technician Screen/technician_view_model.dart';
import 'technician_assignment_view_model.dart';
import '../../../utils/toast_service.dart';
import '../../../models/pos_order_model.dart';
import '../../../models/pos_technician_model.dart';

List<JobTechnician> _jobTechniciansFromSelection(
  Set<String> selectedIds,
  List<PosTechnician> catalog,
) {
  final out = <JobTechnician>[];
  for (final t in catalog) {
    if (!selectedIds.contains(t.id)) continue;
    final pct = double.tryParse(t.commissionPercent) ?? 0;
    out.add(
      JobTechnician(
        id: t.id,
        employeeId: t.id,
        name: t.name,
        commissionPercent: pct,
        commissionAmount: 0,
      ),
    );
  }
  return out;
}

/// Runs under [ChangeNotifierProvider]<[TechnicianAssignmentViewModel]> so
/// [context.read] for the assignment VM is valid (parent [State] context is above the provider).
class _AssignmentCatalogBootstrap extends StatefulWidget {
  final String? departmentId;
  final List<JobTechnician> initialAssignedTechnicians;
  final Widget child;

  const _AssignmentCatalogBootstrap({
    required this.departmentId,
    required this.initialAssignedTechnicians,
    required this.child,
  });

  @override
  State<_AssignmentCatalogBootstrap> createState() =>
      _AssignmentCatalogBootstrapState();
}

class _AssignmentCatalogBootstrapState extends State<_AssignmentCatalogBootstrap> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCatalogAndSeed());
  }

  Future<void> _loadCatalogAndSeed() async {
    if (!mounted) return;
    final dept = widget.departmentId?.trim() ?? '';
    final techVm = context.read<TechnicianViewModel>();
    final assignVm = context.read<TechnicianAssignmentViewModel>();
    if (dept.isNotEmpty) {
      await techVm.fetchCashierTechnicians(departmentId: dept);
    } else {
      await techVm.fetchCashierTechnicians();
    }
    if (!mounted) return;
    assignVm.applyInitialSelectionFromJob(
      widget.initialAssignedTechnicians,
      techVm.rawTechnicians,
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class PosTechnicianAssignmentView extends StatefulWidget {
  final String jobId;
  final String? departmentName;
  final String? departmentId; // needed for walk-in order API
  final bool isWalkIn; // true = walk-in flow, call walk-in API on assign
  /// Technicians already on this job (pre-checks rows after catalog loads).
  final List<JobTechnician> initialAssignedTechnicians;

  const PosTechnicianAssignmentView({
    super.key,
    required this.jobId,
    this.departmentName,
    this.departmentId,
    this.isWalkIn = false,
    this.initialAssignedTechnicians = const [],
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

  /// True from tap through walk-in/edit save, assign API, refresh, orders fetch, until orders shell is pushed (or flow fails).
  bool _saveFlowInProgress = false;

  bool _saveFlowBusy(TechnicianViewModel vm) =>
      vm.isAssigning || _saveFlowInProgress;

  void _handleMultiAssign(
    BuildContext context,
    TechnicianAssignmentViewModel assignVm,
  ) async {
    final vm = context.read<TechnicianViewModel>();
    final posVm = context.read<PosViewModel>();
    final navigator = Navigator.of(context);

    setState(() => _saveFlowInProgress = true);
    var didNavigateToOrders = false;

    String jobIdToUse = widget.jobId;

    try {
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

    if (jobIdToUse.trim().isEmpty) {
      ToastService.showError(context, 'Job not found for this assignment.');
      return;
    }

    final success = await vm.assignMultipleTechnicians(
      jobIdToUse,
      assignVm.selectedTechnicianIds.toList(),
    );

    if (!mounted) return;

    if (success) {
      final oid = (posVm.selectedOrder?.id ?? posVm.editingOrder?.id)?.trim();
      final List<JobTechnician> techs;
      if (assignVm.selectedTechnicianIds.isEmpty) {
        techs = [];
      } else {
        var merged = List<JobTechnician>.from(vm.lastCashierAssignTechnicians);
        if (merged.isEmpty) {
          merged = _jobTechniciansFromSelection(
            assignVm.selectedTechnicianIds,
            vm.rawTechnicians,
          );
        }
        techs = merged;
      }
      if (oid != null && oid.isNotEmpty) {
        posVm.applyJobTechniciansFromAssign(
          orderId: oid,
          jobId: jobIdToUse,
          technicians: techs,
        );
      }
      final initialIds = widget.initialAssignedTechnicians
          .map((jt) => jt.pickerEmployeeId.trim())
          .where((id) => id.isNotEmpty)
          .toSet();
      final selectedIds = Set<String>.from(assignVm.selectedTechnicianIds);
      final addedIds = selectedIds.difference(initialIds);
      final removedIds = initialIds.difference(selectedIds);
      final slotsBeforeRefresh = <String, int>{
        for (final t in vm.rawTechnicians) t.id: t.slotsUsed,
      };
      await vm.refreshTechniciansCatalogQuiet(
        departmentId: widget.departmentId,
      );
      if (!mounted) return;
      vm.reconcileSlotsAfterAssign(
        addedEmployeeIds: addedIds,
        removedEmployeeIds: removedIds,
        slotsBeforeRefresh: slotsBeforeRefresh,
      );
      if (!mounted) return;
      ToastService.showSuccess(
        context,
        assignVm.selectedTechnicianIds.isEmpty
            ? 'All technicians removed from this job'
            : 'Technicians assigned successfully',
      );
      if (oid != null && oid.isNotEmpty) {
        await posVm.fetchOrders(silent: true, preferredOrderId: oid);
      } else {
        await posVm.fetchOrders(silent: true);
      }
      if (!mounted) return;
      didNavigateToOrders = true;
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
    } finally {
      if (mounted && !didNavigateToOrders) {
        setState(() => _saveFlowInProgress = false);
      }
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
        child: _AssignmentCatalogBootstrap(
          departmentId: widget.departmentId,
          initialAssignedTechnicians: widget.initialAssignedTechnicians,
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
              body: Stack(
                children: [
                  Consumer<TechnicianViewModel>(

                builder: (context, vm, child) {
                  final listLoading =
                      vm.isLoading && !vm.hasTechnicianList;

                  if (vm.errorMessage != null &&
                      !vm.isLoading &&
                      !vm.hasTechnicianList) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: ${vm.errorMessage}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              final d = widget.departmentId?.trim() ?? '';
                              if (d.isNotEmpty) {
                                vm.fetchCashierTechnicians(departmentId: d);
                              } else {
                                vm.fetchCashierTechnicians();
                              }
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Filter by search + department + online toggle. Selected techs
                  // must stay visible so the user can always uncheck them (otherwise
                  // they vanish under "Online only" or dept mismatch).
                  final query = assignVm.searchQuery.toLowerCase();
                  bool matchesSearch(PosTechnician tech) {
                    if (query.isEmpty) return true;
                    return tech.name.toLowerCase().contains(query) ||
                        tech.employeeType.toLowerCase().contains(query);
                  }

                  bool passesDeptAndOnline(PosTechnician tech) {
                    final deptName = assignVm.departmentName?.trim() ?? '';
                    if (deptName.isNotEmpty) {
                      final inDept = tech.departments.any(
                        (d) => d.name.toLowerCase() == deptName.toLowerCase(),
                      );
                      if (!inDept) return false;
                    }
                    if (assignVm.onlineOnly && !tech.isOnline) return false;
                    return true;
                  }

                  final selectedIds = assignVm.selectedTechnicianIds;
                  final seen = <String>{};
                  final technicians = <PosTechnician>[];
                  for (final tech in vm.rawTechnicians) {
                    if (!selectedIds.contains(tech.id)) continue;
                    if (!matchesSearch(tech)) continue;
                    if (seen.add(tech.id)) technicians.add(tech);
                  }
                  for (final tech in vm.rawTechnicians) {
                    if (selectedIds.contains(tech.id)) continue;
                    if (!matchesSearch(tech)) continue;
                    if (!passesDeptAndOnline(tech)) continue;
                    if (seen.add(tech.id)) technicians.add(tech);
                  }

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
                          GestureDetector(
                            onTap: () =>
                                assignVm.setOnlineOnly(!assignVm.onlineOnly),
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
                                  assignVm.onlineOnly
                                      ? 'Show all'
                                      : 'Online only',
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
                        child: listLoading
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(
                                      width: 36,
                                      height: 36,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Loading technicians…',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : technicians.isEmpty
                                ? const Center(
                                    child: Text('No technicians found'),
                                  )
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
                                  // Full slots / not assignable still allow deselecting a checked tech.
                                  final canPickNew = tech.assignable &&
                                      tech.slotsUsed < tech.totalSlots;
                                  final canInteract = !_saveFlowBusy(vm) &&
                                      (canPickNew || isSelected);

                                  return InkWell(
                                    onTap: canInteract
                                        ? () =>
                                            assignVm.toggleSelection(tech)
                                        : null,
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
                                            if (canPickNew || isSelected)
                                              Checkbox(
                                                value: isSelected,
                                                onChanged: _saveFlowBusy(vm)
                                                    ? null
                                                    : (_) => assignVm
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
              if (context.watch<TechnicianViewModel>().isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.white,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
                ),
            ],
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Consumer<TechnicianViewModel>(
                        builder: (context, vm, _) {
                          final busy = _saveFlowBusy(vm);
                          return Row(
                            children: [
                              if (_canTapBroadcast) ...[
                                Expanded(
                                  child: SizedBox(
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: (_broadcastingDuty == null && !busy)
                                          ? () => _broadcastOnCall(context)
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryLight,
                                        foregroundColor: AppColors.secondaryLight,
                                        disabledBackgroundColor: AppColors.primaryLight.withOpacity(0.5),
                                        disabledForegroundColor: AppColors.secondaryLight.withOpacity(0.5),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: (_broadcastingDuty == 'on_call') ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: AppColors.secondaryLight,
                                          strokeWidth: 2.5,
                                        ),
                                      ) : const Text(
                                        'Broadcast',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: busy
                                        ? null
                                        : () => _handleMultiAssign(context, assignVm),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.secondaryLight,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: Colors.grey.shade300,
                                      disabledForegroundColor: Colors.grey.shade500,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: busy ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    ) : const Text(
                                      'Save Technicians',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        ),
      ),
    );
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
