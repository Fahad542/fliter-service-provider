import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../widgets/owner_app_bar.dart';
import '../widgets/owner_petty_cash_approval_card.dart';
import 'approvals_view_model.dart';

class ApprovalsView extends StatefulWidget {
  const ApprovalsView({super.key});

  @override
  State<ApprovalsView> createState() => _ApprovalsViewState();
}

class _ApprovalsViewState extends State<ApprovalsView> {
  final List<String> _filters = ['all', 'pending', 'approved', 'rejected'];
  final List<MapEntry<String, String>> _queueOptions = const [
    MapEntry('all', 'All'),
    MapEntry('fund', 'Top-ups'),
    MapEntry('expense', 'Expenses'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final vm = context.read<ApprovalsViewModel>();
        vm.bindRealtime();
        vm.fetchRequests();
      }
    });
  }

  @override
  void dispose() {
    context.read<ApprovalsViewModel>().unbindRealtime();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ApprovalsViewModel>();
    final requests = vm.requests;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: OwnerAppBar(
        title: 'Approvals',
        showGlobalLeft: false,
        showNotification: false,
        showBackButton: false,
        showDrawer: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSegmentLabel('Queue'),
                const SizedBox(height: 8),
                _buildApprovalSegmentedRow(
                  options: _queueOptions,
                  selectedKey: vm.queueFilter,
                  onSelect: vm.setQueueFilter,
                ),
                const SizedBox(height: 12),
                _buildSegmentLabel('Status'),
                const SizedBox(height: 8),
                _buildApprovalSegmentedRow(
                  options: [
                    for (final f in _filters)
                      MapEntry(f, f[0].toUpperCase() + f.substring(1)),
                  ],
                  selectedKey: vm.statusFilter,
                  onSelect: vm.setStatusFilter,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (vm.error != null && vm.error!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: Text(
                  vm.error!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    children: [
                      RefreshIndicator(
                        onRefresh: () => vm.fetchRequests(),
                        child: requests.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: const [
                                  SizedBox(height: 600),
                                ],
                              )
                            : ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  4,
                                  20,
                                  32,
                                ),
                                itemCount: requests.length,
                                itemBuilder: (context, index) {
                                  final req = requests[index];
                                  return OwnerPettyCashApprovalCard(
                                    request: req,
                                    currency: vm.currency,
                                    hasApprovalActionInFlight:
                                        vm.hasApprovalActionInFlight,
                                    isApprovingThis:
                                        vm.isApprovingRequest(req.id),
                                    isRejectingThis:
                                        vm.isRejectingRequest(req.id),
                                    onApprove: () => vm.approveRequest(req.id),
                                    onReject: (reason) =>
                                        vm.rejectRequest(req.id, reason),
                                  );
                                },
                              ),
                      ),
                      if (requests.isEmpty) _buildEmptyState(vm),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: Color(0xFF9CA3AF),
        letterSpacing: 0.35,
      ),
    );
  }

  /// Same pattern as [AccountingView] / owner admin tab pills: white bar + primary selected segment.
  Widget _buildApprovalSegmentedRow({
    required List<MapEntry<String, String>> options,
    required String selectedKey,
    required void Function(String key) onSelect,
  }) {
    final pillRadius = BorderRadius.circular(12);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200.withValues(alpha: 0.85),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: options.map((e) {
          final selected = selectedKey == e.key;
          return Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSelect(e.key),
                borderRadius: pillRadius,
                splashColor: AppColors.primaryLight.withValues(alpha: 0.2),
                highlightColor: AppColors.primaryLight.withValues(alpha: 0.06),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primaryLight : Colors.transparent,
                    borderRadius: pillRadius,
                  ),
                  child: Text(
                    e.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: selected ? 12.5 : 11,
                      fontWeight:
                          selected ? FontWeight.w800 : FontWeight.w600,
                      color: selected
                          ? AppColors.secondaryLight
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(ApprovalsViewModel vm) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 120),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 72,
              color: Colors.green.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            Text(
              vm.queueFilter == 'expense'
                  ? 'No expense approvals'
                  : 'No petty cash requests',
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No records for this queue and status.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
