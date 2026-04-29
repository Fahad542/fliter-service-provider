import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import 'branch_management_view_model.dart';
import '../../../models/workshop_owner_models.dart';
import '../widgets/owner_app_bar.dart';
import '../owner_shell.dart';

class BranchManagementView extends StatefulWidget {
  const BranchManagementView({super.key});

  @override
  State<BranchManagementView> createState() => _BranchManagementViewState();
}

class _BranchManagementViewState extends State<BranchManagementView> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<BranchManagementViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          appBar: OwnerAppBar(
            title: l10n.branchManagementTitle,
            showGlobalLeft:   true,
            showNotification: true,
            showDrawer:       false,
            onNotificationPressed: () => OwnerShell.goToNotifications(context),
            onMenuPressed: () => Scaffold.of(context).openDrawer(),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              vm.clearForm();
              _showBranchSheet(context, l10n, vm);
            },
            backgroundColor: AppColors.primaryLight,
            foregroundColor: AppColors.secondaryLight,
            icon: const Icon(Icons.add_rounded),
            label: Text(
              l10n.branchAddButton,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          body: _buildBody(context, l10n, vm),
        );
      },
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────────

  Widget _buildBody(
      BuildContext context,
      AppLocalizations l10n,
      BranchManagementViewModel vm,
      ) {
    return Column(
      children: [
        _buildSearchBar(l10n, vm),
        Expanded(
          child: vm.isLoading
              ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryLight))
              : vm.branches.isEmpty
              ? _buildEmpty(l10n)
              : _buildList(context, l10n, vm),
        ),
      ],
    );
  }

  // ── Search ────────────────────────────────────────────────────────────────

  Widget _buildSearchBar(AppLocalizations l10n, BranchManagementViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: TextField(
        onChanged: vm.updateSearchQuery,
        decoration: InputDecoration(
          hintText: l10n.branchSearchHint,
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────

  Widget _buildEmpty(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.account_tree_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            l10n.branchNoBranches,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Branch list ───────────────────────────────────────────────────────────

  Widget _buildList(
      BuildContext context,
      AppLocalizations l10n,
      BranchManagementViewModel vm,
      ) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: vm.branches.length,
      itemBuilder: (context, index) {
        final branch = vm.branches[index];
        return _buildBranchCard(context, l10n, vm, branch);
      },
    );
  }

  Widget _buildBranchCard(
      BuildContext context,
      AppLocalizations l10n,
      BranchManagementViewModel vm,
      Branch branch,
      ) {
    // Display name / location come from translated cache when Arabic is active.
    final displayName     = branch.translatedName     ?? branch.name;
    final displayLocation = branch.translatedLocation ?? branch.location;

    // Status chip uses the raw API status for colour logic; display text from l10n.
    final rawStatus    = branch.status;
    final isActive     = rawStatus.toLowerCase() == 'active';
    final statusLabel  = isActive ? l10n.branchStatusActive : l10n.branchStatusInactive;
    final statusColor  = isActive ? Colors.green : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.account_tree_rounded,
              color: AppColors.primaryLight,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),

          // Text info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.secondaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 13, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        displayLocation,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusLabel.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Actions
          Column(
            children: [
              IconButton(
                onPressed: () {
                  vm.setEditBranch(branch);
                  _showBranchSheet(context, l10n, vm);
                },
                icon: const Icon(Icons.edit_rounded,
                    color: AppColors.primaryLight, size: 20),
                tooltip: l10n.branchEditButton,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
              ),
              IconButton(
                onPressed: () =>
                    _confirmDelete(context, l10n, vm, branch.id),
                icon: const Icon(Icons.delete_rounded,
                    color: Colors.redAccent, size: 20),
                tooltip: l10n.branchDeleteButton,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Delete confirmation ───────────────────────────────────────────────────

  void _confirmDelete(
      BuildContext context,
      AppLocalizations l10n,
      BranchManagementViewModel vm,
      String branchId,
      ) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.branchDeleteConfirmTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.secondaryLight,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.branchDeleteConfirmBody,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.grey, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        l10n.branchDeleteConfirmCancel,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondaryLight),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await vm.deleteBranch(context, branchId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        l10n.branchDeleteConfirmDelete,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Add / Edit bottom sheet ───────────────────────────────────────────────

  void _showBranchSheet(
      BuildContext context,
      AppLocalizations l10n,
      BranchManagementViewModel vm,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BranchFormSheet(vm: vm, l10n: l10n),
    );
  }
}

// ── Branch form sheet ─────────────────────────────────────────────────────────

class _BranchFormSheet extends StatelessWidget {
  final BranchManagementViewModel vm;
  final AppLocalizations l10n;

  const _BranchFormSheet({required this.vm, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Text(
                  vm.isEditing ? l10n.branchFormTitleEdit : l10n.branchFormTitleAdd,
                  style: AppTextStyles.h2.copyWith(fontSize: 20),
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  children: [
                    // Branch name
                    _label(l10n.branchFormNameLabel),
                    const SizedBox(height: 8),
                    _textField(
                      controller: vm.branchNameController,
                      hint: l10n.branchFormNameHint,
                    ),
                    const SizedBox(height: 20),

                    // Address with autocomplete
                    _label(l10n.branchFormAddressLabel),
                    const SizedBox(height: 8),
                    _AddressField(vm: vm, l10n: l10n),
                    const SizedBox(height: 20),

                    // GPS
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label(l10n.branchFormLatLabel),
                              const SizedBox(height: 8),
                              _textField(
                                controller: vm.gpsLatController,
                                hint: '24.7136',
                                keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label(l10n.branchFormLngLabel),
                              const SizedBox(height: 8),
                              _textField(
                                controller: vm.gpsLngController,
                                hint: '46.6753',
                                keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Active toggle
                    Consumer<BranchManagementViewModel>(
                      builder: (_, vm2, __) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.branchFormStatusLabel,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppColors.secondaryLight,
                            ),
                          ),
                          Switch(
                            value: vm2.isActive,
                            onChanged: vm2.toggleStatus,
                            activeColor: AppColors.primaryLight,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit button
                    Consumer<BranchManagementViewModel>(
                      builder: (_, vm2, __) => ElevatedButton(
                        onPressed: vm2.isActionLoading
                            ? null
                            : () => vm2.submitBranchForm(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          foregroundColor: AppColors.secondaryLight,
                          disabledBackgroundColor:
                          AppColors.primaryLight.withOpacity(0.5),
                          minimumSize: const Size.fromHeight(56),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: vm2.isActionLoading
                            ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.secondaryLight,
                          ),
                        )
                            : Text(
                          vm2.isEditing
                              ? l10n.branchFormUpdateButton
                              : l10n.branchFormSaveButton,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 13,
      color: AppColors.secondaryLight,
    ),
  );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) =>
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFFF8F9FD),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );
}

// ── Address autocomplete field ────────────────────────────────────────────────

class _AddressField extends StatefulWidget {
  final BranchManagementViewModel vm;
  final AppLocalizations l10n;
  const _AddressField({required this.vm, required this.l10n});

  @override
  State<_AddressField> createState() => _AddressFieldState();
}

class _AddressFieldState extends State<_AddressField> {
  List<Map<String, dynamic>> _suggestions = [];
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: widget.vm.addressController,
          decoration: InputDecoration(
            hintText: widget.l10n.branchFormAddressHint,
            filled: true,
            fillColor: const Color(0xFFF8F9FD),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            suffixIcon: _loading
                ? const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            )
                : null,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          onChanged: (val) async {
            if (val.length < 3) {
              setState(() => _suggestions = []);
              return;
            }
            setState(() => _loading = true);
            final s = await widget.vm.getAddressSuggestions(val);
            setState(() {
              _suggestions = s;
              _loading     = false;
            });
          },
        ),
        if (_suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _suggestions.length,
              separatorBuilder: (_, __) =>
                  Divider(color: Colors.grey.shade100, height: 1),
              itemBuilder: (_, i) {
                final s = _suggestions[i];
                return ListTile(
                  leading: const Icon(Icons.location_on_outlined,
                      color: Colors.grey, size: 18),
                  title: Text(s['description'] as String,
                      style: const TextStyle(fontSize: 13)),
                  onTap: () {
                    widget.vm.setSelectedAddress(
                      s['description'] as String,
                      s['placeId']     as String,
                    );
                    setState(() => _suggestions = []);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}