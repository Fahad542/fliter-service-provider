import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/department_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/toast_service.dart';
import '../../../widgets/pos_widgets.dart';
import '../Home Screen/pos_view_model.dart';
import '../Product Grid/pos_product_grid_view.dart';
import '../Technician Assignment/pos_technician_assignment_view.dart';
import 'department_view_model.dart';

class PosDepartmentView extends StatefulWidget {
  final List<String>? preSelectedProducts;
  final String? initialDepartmentId;

  const PosDepartmentView({
    super.key,
    this.preSelectedProducts,
    this.initialDepartmentId,
  });

  @override
  State<PosDepartmentView> createState() => _PosDepartmentViewState();
}

class _PosDepartmentViewState extends State<PosDepartmentView> {
  bool _autoSelectionDone = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DepartmentViewModel>().fetchDepartments();
    });
  }

  IconData _getIconForDepartment(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('oil')) return Icons.oil_barrel_outlined;
    if (lowerName.contains('wash')) return Icons.local_car_wash_outlined;
    if (lowerName.contains('repair')) return Icons.build_outlined;
    if (lowerName.contains('tyre')) return Icons.tire_repair_outlined;
    if (lowerName.contains('ac')) return Icons.ac_unit_outlined;
    if (lowerName.contains('inspect')) return Icons.search_outlined;
    if (lowerName.contains('detail')) return Icons.auto_awesome_outlined;
    if (lowerName.contains('battery')) return Icons.battery_charging_full_outlined;
    return Icons.category_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      appBar: PosScreenAppBar(title: 'Select Depart'),
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
                  Text('Error: ${viewModel.errorMessage}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.fetchDepartments(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final departments = viewModel.departments;
          final preferredDepartmentId =
              widget.initialDepartmentId ??
              context.read<PosViewModel>().editDepartmentId;

          if (departments.isEmpty) {
            return const Center(child: Text('No departs found'));
          }

          if (!_autoSelectionDone &&
              preferredDepartmentId != null &&
              viewModel.selectedIndex == null) {
            final idx = departments.indexWhere((d) => d.id == preferredDepartmentId);
            if (idx != -1) {
              _autoSelectionDone = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  context.read<DepartmentViewModel>().setSelectedIndex(idx);
                }
              });
            }
          }

          return Column(
            children: [
              SizedBox(height: isTablet ? 24 : 20),

              // Department Grid
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 14 : 10),
                  child: GridView.builder(
                    itemCount: departments.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isTablet ? 6 : 4,
                      childAspectRatio: isTablet ? 1.1 : 1.1,
                      crossAxisSpacing: isTablet ? 8 : 6,
                      mainAxisSpacing: isTablet ? 8 : 6,
                    ),
                    itemBuilder: (context, index) {
                      final dept = departments[index];
                      final isSelected = viewModel.selectedIndex == index;

                      return GestureDetector(
                        onTap: () {
                          viewModel.setSelectedIndex(index);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            gradient: isSelected
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.primaryLight.withOpacity(0.15),
                                      AppColors.primaryLight.withOpacity(0.05),
                                    ],
                                  )
                                : null,
                            borderRadius:
                                BorderRadius.circular(isTablet ? 18 : 14),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryLight.withOpacity(0.6)
                                  : Colors.grey.shade200.withOpacity(0.8),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? AppColors.primaryLight.withOpacity(0.08)
                                    : Colors.black.withOpacity(0.03),
                                blurRadius: isSelected ? 10 : 6,
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
                                  padding: EdgeInsets.all(isTablet ? 9 : 7),
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
                                SizedBox(height: isTablet ? 2 : 2),
                                Text(
                                  dept.name,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight:
                                        isSelected ? FontWeight.w700 : FontWeight.w600,
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
                      );
                    },
                  ),
                ),
              ),

              // Bottom Action
              if (viewModel.selectedIndex != null)
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
                              padding: EdgeInsets.all(isTablet ? 5 : 4),
                              decoration: const BoxDecoration(
                                color: AppColors.secondaryLight,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getIconForDepartment(
                                  departments[viewModel.selectedIndex!].name,
                                ),
                                size: isTablet ? 16 : 14,
                                color: AppColors.primaryLight,
                              ),
                            ),
                            SizedBox(width: isTablet ? 12 : 8),
                            Text(
                              departments[viewModel.selectedIndex!].name,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: isTablet ? 15 : 13,
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                      SizedBox(height: isTablet ? 16 : 12),

                      // Action Buttons
                      if (isTablet)
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 52,
                                child: _buildProductsButton(context, departments[viewModel.selectedIndex!], isTablet),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SizedBox(
                                height: 52,
                                child: _buildTechnicianButton(context, departments[viewModel.selectedIndex!], isTablet),
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: _buildProductsButton(context, departments[viewModel.selectedIndex!], isTablet),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: _buildTechnicianButton(context, departments[viewModel.selectedIndex!], isTablet),
                            ),
                          ],
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

  Widget _buildProductsButton(BuildContext context, Department dept, bool isTablet) {
    return Consumer<PosViewModel>(
      builder: (context, posViewModel, child) {
        final editPreSelectedItems = posViewModel.editPreSelectedItems;
        return ElevatedButton(
          onPressed: posViewModel.isLoading
              ? null
              : () async {
                  if (posViewModel.vehicleNumber.trim().isEmpty) {
                    ToastService.showError(
                      context,
                      'Please add vehicle number first (Add Customer)',
                    );
                    return;
                  }

                  final previousDeptId = posViewModel.editDepartmentId;
                  final isDeptChanged =
                      posViewModel.editingOrder != null &&
                      previousDeptId != null &&
                      previousDeptId.isNotEmpty &&
                      previousDeptId != dept.id;

                  if (isDeptChanged) {
                    final shouldContinue = await showDialog<bool>(
                      context: context,
                      builder: (dialogCtx) {
                        final w = MediaQuery.of(dialogCtx).size.width;
                        final isDialogTablet = w > 600;
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          insetPadding: EdgeInsets.symmetric(
                            horizontal: isDialogTablet ? w * 0.28 : 24,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Change Department?',
                                  style: AppTextStyles.h3.copyWith(
                                    fontSize: isDialogTablet ? 26 : 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'Do you really want to change your department?',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Colors.grey.shade800,
                                    fontSize: isDialogTablet ? 17 : 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Your invoice data will be refreshed.',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Colors.grey.shade600,
                                    fontSize: isDialogTablet ? 16 : 14,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed:
                                            () => Navigator.pop(dialogCtx, false),
                                        style: OutlinedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                            vertical: isDialogTablet ? 16 : 13,
                                          ),
                                          side: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.w700,
                                            fontSize: isDialogTablet ? 16 : 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed:
                                            () => Navigator.pop(dialogCtx, true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primaryLight,
                                          foregroundColor: AppColors.secondaryLight,
                                          elevation: 0,
                                          padding: EdgeInsets.symmetric(
                                            vertical: isDialogTablet ? 16 : 13,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: Text(
                                          'Continue',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: isDialogTablet ? 16 : 14,
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

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PosProductGridView(
                        departmentName: dept.name,
                        departmentId: dept.id,
                        preSelectedItems: isDeptChanged
                            ? null
                            : (editPreSelectedItems ??
                                widget.preSelectedProducts
                                    ?.map((id) => {'productId': id})
                                    .toList()),
                        completingOrder: posViewModel.editingOrder,
                        completingOrderId: posViewModel.editingCompletingOrderId,
                      ),
                    ),
                  );
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryLight,
            foregroundColor: AppColors.secondaryLight,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
            ),
          ),
          child: Text(
            'Continue to Products',
            style: AppTextStyles.button.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: isTablet ? 15 : 13,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTechnicianButton(BuildContext context, Department dept, bool isTablet) {
    return Consumer<PosViewModel>(
      builder: (context, posViewModel, child) {
        return ElevatedButton(
          onPressed: () {
            if (posViewModel.vehicleNumber.trim().isEmpty) {
              ToastService.showError(
                context,
                'Please add vehicle number first (Add Customer)',
              );
              return;
            }
            // Navigate directly — walk-in API will be called on "Assign to Technician"
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PosTechnicianAssignmentView(
                  jobId: '', // empty = walk-in mode (API not called yet)
                  departmentName: dept.name,
                  departmentId: dept.id,
                  isWalkIn: true,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondaryLight,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
            ),
          ),
          child: Text(
            'Continue to Technician',
            style: AppTextStyles.button.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: isTablet ? 15 : 13,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}

