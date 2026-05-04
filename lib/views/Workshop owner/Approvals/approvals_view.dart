import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../Workshop Owner/Approvals/approvals_view_model.dart';
import '../widgets/owner_app_bar.dart';
import '../widgets/owner_petty_cash_approval_card.dart';

// ---------------------------------------------------------------------------
// ApprovalsView
//
// ── Filter keys vs display labels ───────────────────────────────────────────
// [_statusKeys] and [_queueKeys] hold RAW API values ('all', 'pending', …).
// These are passed to vm.setStatusFilter / vm.setQueueFilter and compared
// against vm.statusFilter / vm.queueFilter.  They are NEVER translated.
//
// Display labels come exclusively from AppLocalizations (l10n.*) — static
// strings that are already correct for the active locale.
//
// This design guarantees no switch/if ever breaks in Arabic mode.
// ---------------------------------------------------------------------------

class ApprovalsView extends StatefulWidget {
  const ApprovalsView({super.key});

  @override
  State<ApprovalsView> createState() => _ApprovalsViewState();
}

class _ApprovalsViewState extends State<ApprovalsView> {
  /// Raw API keys — never translated, always safe for comparison.
  static const List<String> _statusKeys = [
    'all',
    'pending',
    'approved',
    'rejected',
  ];

  static const List<String> _queueKeys = ['all', 'fund', 'expense'];

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
    final l10n = AppLocalizations.of(context)!;
    final vm   = context.watch<ApprovalsViewModel>();
    final requests = vm.requests;

    /// Queue options: key = raw API value, value = localized label.
    final queueOptions = [
      MapEntry(_queueKeys[0], l10n.approvalsQueueAll),
      MapEntry(_queueKeys[1], l10n.approvalsQueueTopUps),
      MapEntry(_queueKeys[2], l10n.approvalsQueueExpenses),
    ];

    /// Status options: key = raw API value, value = localized label.
    final statusOptions = List.generate(
      _statusKeys.length,
          (i) => MapEntry(_statusKeys[i], [
        l10n.approvalsStatusAll,
        l10n.approvalsStatusPending,
        l10n.approvalsStatusApproved,
        l10n.approvalsStatusRejected,
      ][i]),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: OwnerAppBar(
        title: l10n.approvalsTitle,
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
                _buildSegmentLabel(l10n.approvalsQueueLabel),
                const SizedBox(height: 8),
                _buildApprovalSegmentedRow(
                  options: queueOptions,
                  // Compare with raw API key — always safe.
                  selectedKey: vm.queueFilter,
                  onSelect: vm.setQueueFilter,
                ),
                const SizedBox(height: 12),
                _buildSegmentLabel(l10n.approvalsStatusLabel),
                const SizedBox(height: 8),
                _buildApprovalSegmentedRow(
                  options: statusOptions,
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
                    children: const [SizedBox(height: 600)],
                  )
                      : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding:
                    const EdgeInsets.fromLTRB(20, 4, 20, 32),
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
                        onApprove: () async {
                          await vm.approveRequest(req.id);
                          return true;
                        },
                        onReject: (reason) async {
                          await vm.rejectRequest(req.id, reason);
                          return true;
                        },
                      );
                    },
                  ),
                ),
                if (requests.isEmpty) _buildEmptyState(vm, l10n),
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
          // Compare key (raw API value) — never the translated label.
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
                  padding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 2),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primaryLight
                        : Colors.transparent,
                    borderRadius: pillRadius,
                  ),
                  child: Text(
                    // Display the localized label (e.value) —
                    // selection logic always uses the raw key (e.key).
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

  Widget _buildEmptyState(ApprovalsViewModel vm, AppLocalizations l10n) {
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
              // Compare against RAW queueFilter key — safe in any locale.
              vm.queueFilter == 'expense'
                  ? l10n.approvalsEmptyExpenses
                  : l10n.approvalsEmptyPettyCash,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.approvalsEmptySubtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}