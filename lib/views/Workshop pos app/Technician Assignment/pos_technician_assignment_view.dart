import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_colors.dart';
import '../../../widgets/pos_widgets.dart';
import '../Technician Screen/technician_view_model.dart';
import 'technician_assignment_view_model.dart';

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

  void _handleMultiAssign(BuildContext context, TechnicianAssignmentViewModel assignVm) async {
    if (assignVm.selectedTechnicianIds.isEmpty) return;

    final vm = context.read<TechnicianViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context, rootNavigator: true);
    final success = await vm.assignMultipleTechnicians(
        widget.jobId, assignVm.selectedTechnicianIds.toList());
    
    if (!mounted) return;

    if (success) {
      showDialog(
        context: navigator.context,
        barrierDismissible: false,
        builder: (ctx) => _BroadcastTimerDialog(
          isWorkshop: false,
          specificTechNames: List.from(assignVm.selectedTechnicianNames),
        ),
      );
    } else {
       messenger.showSnackBar(
        SnackBar(
          content: Text(vm.assignmentMessage ?? 'Failed to assign technicians'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(isTablet ? 1.4 : 1.0),
      ),
      child: ChangeNotifierProvider(
        create: (_) => TechnicianAssignmentViewModel(),
        child: Builder(
          builder: (context) {
            final assignVm = context.watch<TechnicianAssignmentViewModel>();
            return Scaffold(
              backgroundColor: const Color(0xFFFBF9F6),
              appBar: const PosScreenAppBar(title: 'Technician Assignment '),
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
                        prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: technicians.isEmpty
                      ? const Center(child: Text('No technicians found'))
                      : GridView.builder(
                          padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 24 : 16, vertical: 8),
                          itemCount: technicians.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isTablet ? 3 : 1,
                            childAspectRatio: isTablet ? 2.5 : 4.5,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemBuilder: (context, index) {
                            final tech = technicians[index];
                            final isSelected = assignVm.selectedTechnicianIds.contains(tech.id);

                            return InkWell(
                              onTap: vm.isAssigning
                                  ? null
                                  : () => assignVm.toggleSelection(tech),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primaryLight.withValues(alpha: 0.1) : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: isSelected ? AppColors.primaryLight : Colors.grey.shade200,
                                      width: isSelected ? 2 : 1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: isTablet ? 24 : 20,
                                      backgroundColor: AppColors.primaryLight
                                          .withValues(alpha: 0.1),
                                      child: Icon(Icons.person,
                                          size: isTablet ? 24 : 20,
                                          color: AppColors.secondaryLight),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            tech.name,
                                            style: TextStyle(
                                              fontSize: isTablet ? 15 : 14,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF1E2124),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            tech.statusInfo,
                                            style: TextStyle(
                                              fontSize: isTablet ? 12 : 11,
                                              color: tech.statusInfo.contains('Castrol')
                                                ? Colors.black54
                                                : Colors.grey,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.work_history_outlined,
                                                size: isTablet ? 14 : 12,
                                                color: tech.slotsUsed >= tech.totalSlots 
                                                    ? Colors.red.shade400 
                                                    : Colors.blue.shade400,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Slots: ${tech.slotsUsed}/${tech.totalSlots} used',
                                                style: TextStyle(
                                                  fontSize: isTablet ? 12 : 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: tech.slotsUsed >= tech.totalSlots 
                                                      ? Colors.red.shade600 
                                                      : Colors.blue.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Checkbox(
                                      value: isSelected,
                                      onChanged: vm.isAssigning 
                                          ? null 
                                          : (val) => assignVm.toggleSelection(tech),
                                      activeColor: AppColors.secondaryLight,
                                      checkColor: AppColors.primaryLight,
                                    ),
                                  ],
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
                )
              ],
            ),
            child: assignVm.selectedTechnicianIds.isEmpty
                ? Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _showBroadcastWorkshopDialog();
                          },
                          icon: const Icon(Icons.campaign_outlined, size: 18),
                          label: Text(
                            'Broadcast to Workshop',
                            style: TextStyle(fontSize: isTablet ? 14 : 12, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.secondaryLight,
                            side: const BorderSide(color: AppColors.secondaryLight),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showBroadcastOnCallDialog();
                          },
                          icon: const Icon(Icons.online_prediction, size: 18),
                          label: Text(
                            'Broadcast to On-Call',
                            style: TextStyle(fontSize: isTablet ? 14 : 12, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryLight,
                            foregroundColor: AppColors.secondaryLight,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  )
                : Consumer<TechnicianViewModel>(
                    builder: (context, vm, child) => Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: vm.isAssigning ? null : () => _handleMultiAssign(context, assignVm),
                            icon: vm.isAssigning 
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.assignment_ind, size: 18),
                            label: Text(
                              vm.isAssigning 
                                  ? 'Assigning...' 
                                  : 'Assign to ${assignVm.selectedTechnicianIds.length} Technician${assignVm.selectedTechnicianIds.length > 1 ? 's' : ''}',
                              style: TextStyle(fontSize: isTablet ? 14 : 12, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondaryLight,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  void _showBroadcastWorkshopDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _BroadcastTimerDialog(isWorkshop: true),
    );
  }

  void _showBroadcastOnCallDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _BroadcastTimerDialog(isWorkshop: false),
    );
  }
}

class _BroadcastTimerDialog extends StatefulWidget {
  final bool isWorkshop;
  final List<String>? specificTechNames;
  const _BroadcastTimerDialog({required this.isWorkshop, this.specificTechNames});

  @override
  State<_BroadcastTimerDialog> createState() => _BroadcastTimerDialogState();
}

class _BroadcastTimerDialogState extends State<_BroadcastTimerDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TechnicianAssignmentViewModel>().startBroadcastTimer(
        context, widget.isWorkshop, widget.specificTechNames,
      );
    });
  }

  @override
  void dispose() {
    // ViewModel handles its own timer cancellation if needed
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TechnicianAssignmentViewModel>();
    final specificNamesText = widget.specificTechNames?.join(', ');

    final titleText = widget.specificTechNames != null
        ? 'Assign to $specificNamesText'
        : widget.isWorkshop ? 'Broadcast to Workshop' : 'Broadcast to On-Call';
        
    final waitingText = widget.specificTechNames != null
        ? 'Waiting for $specificNamesText to accept...'
        : widget.isWorkshop 
            ? 'Waiting for Workshop technicians to accept...'
            : 'Waiting for On-Call technicians to accept...';
    
    final availableCountText = widget.specificTechNames != null
        ? 'Direct Assignment'
        : widget.isWorkshop ? 'Workshop Broadcast Active' : '3 Available On-Call';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Center(
        child: Text(titleText, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!vm.isAccepted) ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLight.withValues(alpha: 0.1),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                   SizedBox(
                     width: 100,
                     height: 100,
                     child: CircularProgressIndicator(
                       value: vm.secondsRemaining / 300,
                       strokeWidth: 8,
                       backgroundColor: Colors.grey.shade200,
                       valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
                     ),
                   ),
                   Text(
                    _formatTime(vm.secondsRemaining),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.secondaryLight),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              waitingText,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.isWorkshop ? Colors.blue.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                availableCountText,
                style: TextStyle(
                  color: widget.isWorkshop ? Colors.blue.shade700 : Colors.green.shade700, 
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Developer Testing actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => context.read<TechnicianAssignmentViewModel>().handleBroadcastTimeout(context, widget.isWorkshop, widget.specificTechNames),
                  child: const Text('Simulate Timeout', style: TextStyle(color: Colors.red)),
                ),
                TextButton(
                  onPressed: () => context.read<TechnicianAssignmentViewModel>().simulateAccept(context, widget.specificTechNames),
                  child: const Text('Simulate Accept', style: TextStyle(color: Colors.green)),
                ),
              ],
            ),
          ] else ...[
            const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            Text(
              'Accepted by ${vm.acceptedBy}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (!widget.isWorkshop && widget.specificTechNames == null) ...[
              Text(
                'Estimated Arrival in ${vm.arrivalMinutes} min',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              const Text(
                'Technicians are present at the workshop',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ],
      ),
      actions: [
        if (!vm.isAccepted)
          TextButton(
            onPressed: () {
              context.read<TechnicianAssignmentViewModel>().cancelTimer();
              Navigator.pop(context);
            },
            child: const Text('Cancel Request', style: TextStyle(color: Colors.grey)),
          ),
      ],
    );
  }
}
