import 'package:filter_service_providers/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/locker_models.dart';
import '../../../utils/app_colors.dart';
import 'locker_request_details_view.dart';
import 'locker_requests_view_model.dart';

// ── Filter mode enum ──────────────────────────────────────────────────────────

enum LockerListFilterMode { normal, assignPending }

// ── Entry point ───────────────────────────────────────────────────────────────

class LockerRequestsListView extends StatelessWidget {
  final LockerListFilterMode filterMode;

  const LockerRequestsListView({
    super.key,
    this.filterMode = LockerListFilterMode.normal,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LockerRequestsViewModel(filterMode: filterMode),
      child: const _LockerRequestsBody(),
    );
  }
}

// ── Inner StatefulWidget ──────────────────────────────────────────────────────

class _LockerRequestsBody extends StatefulWidget {
  const _LockerRequestsBody();

  @override
  State<_LockerRequestsBody> createState() => _LockerRequestsBodyState();
}

class _LockerRequestsBodyState extends State<_LockerRequestsBody> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<LockerRequestsViewModel>().init();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<LockerRequestsViewModel>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LockerRequestsViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF0F2F5),
          appBar: CustomAppBar(),
          body: Column(
            children: [
              _buildSearchAndFilters(context, vm),
              Expanded(child: _buildBody(context, vm)),
            ],
          ),
        );
      },
    );
  }

  // ── Search + status dropdown ──────────────────────────────────────────────

  Widget _buildSearchAndFilters(
      BuildContext context, LockerRequestsViewModel vm) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F5F7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black.withOpacity(0.06)),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: l10n.lockerSearchHint,
                  hintStyle: TextStyle(
                      color: Colors.black.withOpacity(0.3),
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: Colors.black.withOpacity(0.3),
                      size: 18),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.close_rounded,
                        color: Colors.black.withOpacity(0.3),
                        size: 16),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                      vm.onSearchChanged('');
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (val) {
                  setState(() {});
                  vm.onSearchChanged(val);
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: DropdownButtonFormField<String?>(
              value: vm.selectedStatus,
              dropdownColor: Colors.white,
              iconEnabledColor: Colors.black.withOpacity(0.4),
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 1.2,
              ),
              decoration: InputDecoration(
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                filled: true,
                fillColor: const Color(0xFFF4F5F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                  BorderSide(color: Colors.black.withOpacity(0.06)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                  BorderSide(color: Colors.black.withOpacity(0.06)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: AppColors.secondaryLight.withOpacity(0.4)),
                ),
              ),
              items: vm.activeFilters
                  .map((f) => DropdownMenuItem<String?>(
                value: f.value,
                child: Text(f.label),
              ))
                  .toList(),
              onChanged: (val) => vm.setStatus(val),
            ),
          ),
        ],
      ),
    );
  }

  // ── Body dispatcher ───────────────────────────────────────────────────────

  Widget _buildBody(BuildContext context, LockerRequestsViewModel vm) {
    final l10n = AppLocalizations.of(context)!;

    if (vm.isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primaryLight),
            const SizedBox(height: 16),
            Text(l10n.lockerLoadingRequests,
                style: const TextStyle(color: Colors.black45, fontSize: 13)),
          ],
        ),
      );
    }

    if (vm.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration:
                BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                child:
                Icon(Icons.wifi_off_rounded, size: 40, color: Colors.red.shade400),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.lockerFailedLoadRequests,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.secondaryLight),
              ),
              const SizedBox(height: 8),
              Text(
                vm.errorMessage ?? l10n.lockerUnexpectedError,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black45, fontSize: 13),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: vm.refresh,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.lockerRetry),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryLight,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (vm.requests.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox_rounded,
                  size: 56, color: Colors.black.withOpacity(0.12)),
              const SizedBox(height: 16),
              Text(
                l10n.lockerNoRequestsFound,
                style: TextStyle(
                    color: Colors.black.withOpacity(0.35),
                    fontWeight: FontWeight.w900,
                    fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.lockerAdjustFilters,
                style: TextStyle(
                    color: Colors.black.withOpacity(0.25), fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primaryLight,
      onRefresh: vm.refresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: vm.requests.length + (vm.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == vm.requests.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                  child: CircularProgressIndicator(color: AppColors.primaryLight)),
            );
          }
          return _RequestCard(
            request: vm.requests[index],
            isSupervisor: vm.isSupervisor,
            isCollector: vm.isCollector,
            currentUserId: vm.userId,
          );
        },
      ),
    );
  }
}

// ── Request card ──────────────────────────────────────────────────────────────

class _RequestCard extends StatelessWidget {
  final LockerRequest request;
  final bool isSupervisor;
  final bool isCollector;
  final String? currentUserId;

  const _RequestCard({
    required this.request,
    required this.isSupervisor,
    required this.isCollector,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                LockerRequestDetailsView(requestId: request.id),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1 — branch + badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.branchName,
                            style: const TextStyle(
                              color: AppColors.secondaryLight,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            request.referenceCode,
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.3),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _StatusBadge(status: request.status),
                  ],
                ),
                const SizedBox(height: 12),
                Container(height: 1, color: Colors.black.withOpacity(0.04)),
                const SizedBox(height: 12),
                // Row 2 — amount + date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${l10n.lockerSarCurrency} ${request.lockedCashAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: AppColors.secondaryLight,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.lockerLockedCashAsset,
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.2),
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          DateFormat('dd MMM, yy').format(request.closingDate),
                          style: const TextStyle(
                            color: AppColors.secondaryLight,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          DateFormat('hh:mm a').format(request.closingDate),
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.25),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Officer chip
                if (request.assignedOfficerName != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryLight.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.secondaryLight.withOpacity(0.07)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_outline_rounded,
                            size: 11,
                            color: AppColors.secondaryLight.withOpacity(0.4)),
                        const SizedBox(width: 5),
                        Text(
                          request.assignedOfficerName!,
                          style: TextStyle(
                            color: AppColors.secondaryLight.withOpacity(0.6),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // TAP TO COLLECT chip
                if (request.status == LockerStatus.assigned &&
                    (isCollector ||
                        (currentUserId != null &&
                            request.assignedOfficerId == currentUserId))) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_forward_rounded,
                            size: 11,
                            color: AppColors.secondaryLight.withOpacity(0.7)),
                        const SizedBox(width: 5),
                        Text(
                          l10n.lockerTapToCollect,
                          style: TextStyle(
                            color: AppColors.secondaryLight.withOpacity(0.7),
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Status badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final LockerStatus status;
  const _StatusBadge({required this.status});

  Color get _color {
    switch (status) {
      case LockerStatus.pending:
        return Colors.orange;
      case LockerStatus.assigned:
        return Colors.blue;
      case LockerStatus.awaitingApproval:
        return Colors.purple;
      case LockerStatus.collected:
        return Colors.teal;
      case LockerStatus.approved:
        return Colors.green;
      case LockerStatus.rejected:
        return Colors.red;
    }
  }

  String _label(AppLocalizations l10n) {
    switch (status) {
      case LockerStatus.pending:
        return l10n.lockerStatusPending;
      case LockerStatus.assigned:
        return l10n.lockerStatusAssigned;
      case LockerStatus.awaitingApproval:
        return l10n.lockerStatusAwaiting;
      case LockerStatus.collected:
        return l10n.lockerStatusCollected;
      case LockerStatus.approved:
        return l10n.lockerStatusApproved;
      case LockerStatus.rejected:
        return l10n.lockerStatusRejected;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _color.withOpacity(0.2)),
      ),
      child: Text(
        _label(l10n),
        style: TextStyle(
          color: _color,
          fontWeight: FontWeight.w900,
          fontSize: 8,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}