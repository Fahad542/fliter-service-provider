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
          assignVm: assignVm,
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
                            childAspectRatio: isTablet ? 2.8 : 3.2,
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
                                        mainAxisSize: MainAxisSize.min,
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
                                              Expanded(
                                                child: Text(
                                                  'Slots: ${tech.slotsUsed}/${tech.totalSlots} used',
                                                  style: TextStyle(
                                                    fontSize: isTablet ? 12 : 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: tech.slotsUsed >= tech.totalSlots 
                                                        ? Colors.red.shade600 
                                                        : Colors.blue.shade600,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
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
                        child: OutlinedButton(
                          onPressed: () {
                            _showBroadcastWorkshopDialog(context);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.secondaryLight,
                            side: const BorderSide(color: AppColors.secondaryLight),
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.campaign_outlined, size: 18),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Broadcast to Workshop',
                                  style: TextStyle(fontSize: isTablet ? 14 : 12, fontWeight: FontWeight.bold),
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
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.online_prediction, size: 18),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Broadcast to On-Call',
                                  style: TextStyle(fontSize: isTablet ? 14 : 12, fontWeight: FontWeight.bold),
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
                            onPressed: vm.isAssigning ? null : () => _handleMultiAssign(context, assignVm),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondaryLight,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (vm.isAssigning) 
                                  const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                else 
                                  const Icon(Icons.assignment_ind, size: 18),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    vm.isAssigning 
                                        ? 'Assigning...' 
                                        : 'Assign to ${assignVm.selectedTechnicianIds.length} Technician${assignVm.selectedTechnicianIds.length > 1 ? 's' : ''}',
                                    style: TextStyle(fontSize: isTablet ? 14 : 12, fontWeight: FontWeight.bold),
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
    final assignVm = context.read<TechnicianAssignmentViewModel>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _BroadcastTimerDialog(
        isWorkshop: true,
        assignVm: assignVm,
      ),
    );
  }

  void _showBroadcastOnCallDialog(BuildContext context) {
    final assignVm = context.read<TechnicianAssignmentViewModel>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _BroadcastTimerDialog(
        isWorkshop: false,
        assignVm: assignVm,
      ),
    );
  }
}

class _BroadcastTimerDialog extends StatefulWidget {
  final bool isWorkshop;
  final List<String>? specificTechNames;
  final TechnicianAssignmentViewModel assignVm;
  
  const _BroadcastTimerDialog({
    required this.isWorkshop, 
    this.specificTechNames,
    required this.assignVm,
  });

  @override
  State<_BroadcastTimerDialog> createState() => _BroadcastTimerDialogState();
}

class _BroadcastTimerDialogState extends State<_BroadcastTimerDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.assignVm.startBroadcastTimer(
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
    return ListenableBuilder(
      listenable: widget.assignVm,
      builder: (context, _) {
        final vm = widget.assignVm;
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

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      elevation: 0,
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxWidth: 380),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 30,
              spreadRadius: 2,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Simple Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Icon(
                        widget.specificTechNames != null ? Icons.person_search_rounded : Icons.radar_rounded,
                        size: 28,
                        color: AppColors.secondaryLight,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        titleText, 
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF1E2124), letterSpacing: -0.2),
                      ),
                    ),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                child: Column(
                  children: [
                    if (!vm.isAccepted) ...[
                      // Upgraded Timer Element
                      Stack(
                        alignment: Alignment.center,
                        children: [
                           Container(
                             width: 140,
                             height: 140,
                             decoration: BoxDecoration(
                               shape: BoxShape.circle,
                               color: Colors.white,
                               boxShadow: [
                                 BoxShadow(
                                   color: AppColors.primaryLight.withValues(alpha: 0.1),
                                   blurRadius: 30,
                                   spreadRadius: 5,
                                 )
                               ],
                             ),
                           ),
                           SizedBox(
                             width: 150,
                             height: 150,
                             child: CircularProgressIndicator(
                               value: vm.secondsRemaining / 300,
                               strokeWidth: 10,
                               backgroundColor: Colors.grey.shade100,
                               valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
                               strokeCap: StrokeCap.round,
                             ),
                           ),
                           Column(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                               Text(
                                _formatTime(vm.secondsRemaining),
                                style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: AppColors.secondaryLight, letterSpacing: -1.0),
                               ),
                               if (vm.secondsRemaining < 60)
                                 const Text('Left', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                             ],
                           ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      // Status Chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: widget.isWorkshop ? Colors.blue.shade50 : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.isWorkshop ? Icons.info_outline_rounded : Icons.local_taxi_rounded,
                              size: 18,
                              color: widget.isWorkshop ? Colors.blue.shade700 : Colors.green.shade700,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                availableCountText,
                                style: TextStyle(
                                  color: widget.isWorkshop ? Colors.blue.shade700 : Colors.green.shade700, 
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  letterSpacing: 0.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        waitingText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15, color: Colors.black54, height: 1.4, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 36),
                      
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                vm.cancelTimer();
                                Navigator.pop(context);
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                foregroundColor: Colors.red.shade400,
                                backgroundColor: Colors.red.shade50,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: const Text('Cancel Request', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      // Dev Testing Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => vm.handleBroadcastTimeout(context, widget.isWorkshop, widget.specificTechNames),
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                              child: const Text('Timeout', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => vm.simulateAccept(context, widget.specificTechNames),
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.green, side: const BorderSide(color: Colors.green)),
                              child: const Text('Accept', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Premium Success State
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green.shade400, Colors.green.shade600],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: const Icon(Icons.check_rounded, color: Colors.white, size: 50),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Ready to Roll!',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5, color: Color(0xFF1E2124)),
                      ),
                      const SizedBox(height: 12),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5, fontWeight: FontWeight.w500),
                          children: [
                            const TextSpan(text: 'Accepted by\n'),
                            TextSpan(text: vm.acceptedBy, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.secondaryLight)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      if (!widget.isWorkshop && widget.specificTechNames == null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(16)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.timer_outlined, size: 20, color: Colors.orange.shade700),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  'Arrival in ~${vm.arrivalMinutes} min',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.orange.shade900),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(16)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.storefront_outlined, size: 20, color: Colors.blue.shade700),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  'Present at Workshop',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.blue.shade900),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 40),
                      const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(Colors.green)),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
      },
    );
  }
}
