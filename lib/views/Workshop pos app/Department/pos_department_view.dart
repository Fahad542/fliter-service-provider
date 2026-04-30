import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/department_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/toast_service.dart';
import '../../../widgets/pos_widgets.dart';
import '../Home Screen/pos_view_model.dart';
import '../Navbar/pos_shell.dart';
import 'department_view_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/localized_api_text.dart';

String _normalizeDeptKeyForExclude(String value) =>
    value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

class PosDepartmentView extends StatefulWidget {
  final List<String>? preSelectedProducts;
  final String? initialDepartmentId;

  /// When set, the primary action adds jobs to this existing walk-in draft (POST …/jobs) and pops.
  final String? addJobsToOrderId;

  /// Departments already represented on that order (by id or normalized name) — not selectable.
  final List<String> excludedDepartmentIds;
  final List<String> excludedNormalizedNameKeys;

  const PosDepartmentView({
    super.key,
    this.preSelectedProducts,
    this.initialDepartmentId,
    this.addJobsToOrderId,
    this.excludedDepartmentIds = const [],
    this.excludedNormalizedNameKeys = const [],
  });

  @override
  State<PosDepartmentView> createState() => _PosDepartmentViewState();
}

class _PosDepartmentViewState extends State<PosDepartmentView> {
  bool _autoSelectionDone = false;
  bool _placingOrder = false;

  bool _departmentExcluded(Department d) {
    if (widget.excludedDepartmentIds.contains(d.id)) return true;
    final k = _normalizeDeptKeyForExclude(d.name);
    return widget.excludedNormalizedNameKeys.contains(k);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DepartmentViewModel>().fetchDepartments();
    });
  }

  IconData _getIconForDepartment(String name) {
    // Icon mapping is keyed on English name fragments from the API — locale-independent.
    final lowerName = name.toLowerCase();
    if (lowerName.contains('oil')) return Icons.oil_barrel_outlined;
    if (lowerName.contains('wash')) return Icons.local_car_wash_outlined;
    if (lowerName.contains('repair')) return Icons.build_outlined;
    if (lowerName.contains('tyre') || lowerName.contains('tire')) {
      return Icons.tire_repair_outlined;
    }
    if (lowerName.contains('ac')) return Icons.ac_unit_outlined;
    if (lowerName.contains('inspect')) return Icons.search_outlined;
    if (lowerName.contains('detail')) return Icons.auto_awesome_outlined;
    if (lowerName.contains('battery')) {
      return Icons.battery_charging_full_outlined;
    }
    return Icons.category_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final l = AppLocalizations.of(context)!;

    final isAddToExisting =
        (widget.addJobsToOrderId ?? '').trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      appBar: PosScreenAppBar(
        title: isAddToExisting ? l.posDeptAddTitle : l.posDeptSelectTitle,
      ),
      body: Consumer<DepartmentViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${viewModel.errorMessage}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.fetchDepartments(),
                    child: Text(l.posDeptRetry),
                  ),
                ],
              ),
            );
          }

          final departments = viewModel.departments;
          final preferredDepartmentId = isAddToExisting
              ? widget.initialDepartmentId
              : (widget.initialDepartmentId ??
              context.read<PosViewModel>().editDepartmentId);

          if (departments.isEmpty) {
            return Center(child: Text(l.posDeptNoneFound));
          }

          if (!_autoSelectionDone &&
              preferredDepartmentId != null &&
              viewModel.selectedIndex == null) {
            final idx =
            departments.indexWhere((d) => d.id == preferredDepartmentId);
            if (idx != -1) {
              _autoSelectionDone = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  context
                      .read<DepartmentViewModel>()
                      .setSelectedIndex(idx);
                }
              });
            }
          }

          return Column(
            children: [
              SizedBox(height: isTablet ? 12 : 10),

              // Department grid (shrink-wrap + scroll — avoids large empty gap under few cards)
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 14 : 10),
                  child: GridView.builder(
                    itemCount: departments.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isTablet ? 6 : 4,
                      childAspectRatio: isTablet ? 1.1 : 1.1,
                      crossAxisSpacing: isTablet ? 8 : 6,
                      mainAxisSpacing: isTablet ? 8 : 6,
                    ),
                    itemBuilder: (context, index) {
                      final dept = departments[index];
                      final isSelected =
                      viewModel.selectedIndices.contains(index);
                      final excluded = _departmentExcluded(dept);

                      return GestureDetector(
                        onTap: excluded
                            ? () {
                          ToastService.showError(
                            context,
                            l.posDeptAlreadyOnOrder,
                          );
                        }
                            : () {
                          viewModel.toggleSelectedIndex(index);
                        },
                        child: AnimatedOpacity(
                          opacity: excluded ? 0.42 : 1,
                          duration: const Duration(milliseconds: 200),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              gradient: isSelected && !excluded
                                  ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primaryLight
                                      .withOpacity(0.15),
                                  AppColors.primaryLight
                                      .withOpacity(0.05),
                                ],
                              )
                                  : null,
                              borderRadius: BorderRadius.circular(
                                  isTablet ? 18 : 14),
                              border: Border.all(
                                color: excluded
                                    ? Colors.grey.shade300
                                    : isSelected
                                    ? AppColors.primaryLight
                                    .withOpacity(0.6)
                                    : Colors.grey.shade200
                                    .withOpacity(0.8),
                                width: isSelected && !excluded ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected && !excluded
                                      ? AppColors.primaryLight
                                      .withOpacity(0.08)
                                      : Colors.black.withOpacity(0.03),
                                  blurRadius:
                                  isSelected && !excluded ? 10 : 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.zero,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding:
                                    EdgeInsets.all(isTablet ? 9 : 7),
                                    decoration: const BoxDecoration(
                                      color: AppColors.secondaryLight,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _getIconForDepartment(dept.name),
                                      size: isTablet ? 28 : 22,
                                      color: AppColors.primaryLight,
                                    ),
                                  ),
                                  SizedBox(height: isTablet ? 12 : 10),
                                  // dept.name comes from API/database; translate for Arabic display only.
                                  LocalizedApiText(
                                    dept.name,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                      fontSize: isTablet ? 13 : 11,
                                      height: 1.15,
                                      color: isSelected
                                          ? AppColors.secondaryLight
                                          : Colors.grey.shade700,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
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
              ),

              // Bottom Action
              if (viewModel.selectedIndices.isNotEmpty)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    isTablet ? 32 : 20,
                    12,
                    isTablet ? 32 : 20,
                    isTablet ? 32 : 24,
                  ),
                  child: Column(
                    children: [
                      // Selected department info
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 20 : 16,
                          vertical: isTablet ? 10 : 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding:
                              EdgeInsets.all(isTablet ? 5 : 4),
                              decoration: const BoxDecoration(
                                color: AppColors.secondaryLight,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getIconForDepartment(
                                  viewModel
                                      .selectedDepartments.first.name,
                                ),
                                size: isTablet ? 16 : 14,
                                color: AppColors.primaryLight,
                              ),
                            ),
                            SizedBox(width: isTablet ? 12 : 8),
                            Expanded(
                              child: viewModel.selectedIndices.length == 1
                                  ? LocalizedApiText(
                                      viewModel.selectedDepartments.first.name,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: isTablet ? 15 : 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : Text(
                                      l.posDeptSelectedCount(viewModel.selectedIndices.length),
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: isTablet ? 15 : 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isTablet ? 16 : 12),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: _buildOrderPlacedButton(
                          context,
                          viewModel.selectedDepartments,
                          isTablet,
                          _placingOrder,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderPlacedButton(
      BuildContext context,
      List<Department> selectedDepartments,
      bool isTablet,
      bool isPlacing,
      ) {
    return Consumer<PosViewModel>(
      builder: (context, posViewModel, child) {
        final l = AppLocalizations.of(context)!;
        final selectedDeptIds =
        selectedDepartments.map((d) => d.id).toList();
        final busy = isPlacing || posViewModel.isLoading;
        final addToExistingOrderId =
            widget.addJobsToOrderId?.trim() ?? '';
        final isAddToExistingFlow = addToExistingOrderId.isNotEmpty;

        return ElevatedButton(
          onPressed: busy
              ? null
              : () async {
            if (isAddToExistingFlow) {
              final validIds = selectedDepartments
                  .where((d) => !_departmentExcluded(d))
                  .map((d) => d.id.trim())
                  .where((id) => id.isNotEmpty)
                  .toList();
              if (validIds.isEmpty) {
                ToastService.showError(
                  context,
                  l.posDeptSelectAtLeastOne,
                );
                return;
              }
              setState(() => _placingOrder = true);
              try {
                final ok =
                await posViewModel.addDepartmentsToWalkInOrder(
                  context,
                  addToExistingOrderId,
                  validIds,
                );
                if (!context.mounted || !ok) return;
                Navigator.of(context).pop();
              } finally {
                if (mounted) setState(() => _placingOrder = false);
              }
              return;
            }

            if (posViewModel.vehicleNumber.trim().isEmpty) {
              ToastService.showError(
                context,
                l.posDeptVehicleRequired,
              );
              return;
            }

            setState(() => _placingOrder = true);
            try {
              if (posViewModel.editingOrder == null) {
                final placed =
                await posViewModel.placeWalkInShellOrder(
                  selectedDeptIds,
                  context,
                );
                if (!context.mounted || !placed) return;
              }
              final createdOrderId =
                  posViewModel.lastCreatedWalkInOrderId;

              final previousDeptId =
                  posViewModel.editDepartmentId;
              final isDeptChanged =
                  posViewModel.editingOrder != null &&
                      previousDeptId != null &&
                      previousDeptId.isNotEmpty &&
                      !selectedDeptIds.contains(previousDeptId);

              if (isDeptChanged) {
                final shouldContinue = await showDialog<bool>(
                  context: context,
                  builder: (dialogCtx) {
                    final w =
                        MediaQuery.of(dialogCtx).size.width;
                    final isDialogTablet = w > 600;
                    // Re-resolve l10n inside dialog context
                    final dl =
                    AppLocalizations.of(dialogCtx)!;
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      insetPadding: EdgeInsets.symmetric(
                        horizontal:
                        isDialogTablet ? w * 0.28 : 24,
                        vertical: 24,
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          isDialogTablet ? 28 : 22,
                          isDialogTablet ? 24 : 20,
                          isDialogTablet ? 28 : 22,
                          isDialogTablet ? 22 : 18,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              dl.posDeptChangeDeptTitle,
                              style: AppTextStyles.h3.copyWith(
                                fontSize:
                                isDialogTablet ? 26 : 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              dl.posDeptChangeDeptBody,
                              style:
                              AppTextStyles.bodyMedium.copyWith(
                                color: Colors.grey.shade800,
                                fontSize:
                                isDialogTablet ? 17 : 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              dl.posDeptChangeDeptRefresh,
                              style:
                              AppTextStyles.bodyMedium.copyWith(
                                color: Colors.grey.shade600,
                                fontSize:
                                isDialogTablet ? 16 : 14,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        Navigator.pop(
                                            dialogCtx, false),
                                    style:
                                    OutlinedButton.styleFrom(
                                      padding:
                                      EdgeInsets.symmetric(
                                        vertical:
                                        isDialogTablet
                                            ? 16
                                            : 13,
                                      ),
                                      side: BorderSide(
                                        color:
                                        Colors.grey.shade300,
                                      ),
                                      shape:
                                      RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(
                                            12),
                                      ),
                                    ),
                                    child: Text(
                                      dl.posDeptChangeDeptCancel,
                                      style: TextStyle(
                                        color:
                                        Colors.grey.shade700,
                                        fontWeight: FontWeight.w700,
                                        fontSize:
                                        isDialogTablet ? 16 : 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(
                                            dialogCtx, true),
                                    style:
                                    ElevatedButton.styleFrom(
                                      backgroundColor:
                                      AppColors.primaryLight,
                                      foregroundColor:
                                      AppColors.secondaryLight,
                                      elevation: 0,
                                      padding:
                                      EdgeInsets.symmetric(
                                        vertical:
                                        isDialogTablet
                                            ? 16
                                            : 13,
                                      ),
                                      shape:
                                      RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(
                                            12),
                                      ),
                                    ),
                                    child: Text(
                                      dl.posDeptChangeDeptContinue,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize:
                                        isDialogTablet ? 16 : 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );

                if (shouldContinue != true) return;

                // Reset current invoice/cart state so user can rebuild
                // order against the newly selected department.
                posViewModel.clearCart(isMainTab: false);
              }

              if (!context.mounted) return;
              await posViewModel.fetchOrders(
                silent: false,
                preferredOrderId: createdOrderId,
              );
              if (!context.mounted) return;
              navigateToPosShellOrdersTab(context);
            } finally {
              if (mounted) setState(() => _placingOrder = false);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryLight,
            foregroundColor: AppColors.secondaryLight,
            disabledBackgroundColor:
            AppColors.primaryLight.withValues(alpha: 0.85),
            disabledForegroundColor: AppColors.secondaryLight,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
            ),
          ),
          child: busy
              ? const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.secondaryLight,
            ),
          )
              : Text(
            isAddToExistingFlow
                ? l.posDeptAddToOrder
                : l.posDeptOrderPlaced,
            style: AppTextStyles.button.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: isTablet ? 16 : 14,
            ),
          ),
        );
      },
    );
  }
}