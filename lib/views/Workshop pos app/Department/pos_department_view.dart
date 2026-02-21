import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/department_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../widgets/pos_widgets.dart';
// import '../../Product Grid/pos_product_grid_view.dart';
// import '../../utils/app_colors.dart';
// import '../../utils/app_text_styles.dart';
// import '../../utils/toast_service.dart';
// import '../../widgets/pos_widgets.dart';
import '../Home Screen/pos_view_model.dart';
import '../Product Grid/pos_product_grid_view.dart';
import '../Technician Assignment/pos_technician_assignment_view.dart';
// import '../Workshop pos app/Home Screen/pos_view_model.dart';
// import '../Workshop pos app/Technician Assignment/pos_technician_assignment_view.dart';
// import '../Product Grid/pos_product_grid_view.dart';
// import '../../models/department_model.dart';
import 'department_view_model.dart';

class PosDepartmentView extends StatefulWidget {
  final List<String>? preSelectedProducts;

  const PosDepartmentView({
    super.key,
    this.preSelectedProducts,
  });

  @override
  State<PosDepartmentView> createState() => _PosDepartmentViewState();
}

class _PosDepartmentViewState extends State<PosDepartmentView> {

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

          if (departments.isEmpty) {
            return const Center(child: Text('No departs found'));
          }

          return Column(
            children: [
              SizedBox(height: isTablet ? 24 : 20),

              // Department Grid
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 20),
                  child: GridView.builder(
                    itemCount: departments.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isTablet ? 4 : 3,
                      childAspectRatio: isTablet ? 0.85 : 0.9,
                      crossAxisSpacing: isTablet ? 18 : 12,
                      mainAxisSpacing: isTablet ? 18 : 12,
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
                            color: isSelected
                                ? AppColors.primaryLight.withOpacity(0.15)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryLight
                                  : Colors.grey.shade200,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(isTablet ? 16 : 10),
                                decoration: const BoxDecoration(
                                  color: AppColors.secondaryLight,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getIconForDepartment(dept.name),
                                  size: isTablet ? 32 : 24,
                                  color: AppColors.primaryLight,
                                ),
                              ),
                              SizedBox(height: isTablet ? 14 : 8),
                              Text(
                                dept.name,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                  fontSize: isTablet ? 15 : 12,
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
                          vertical: isTablet ? 14 : 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getIconForDepartment(departments[viewModel.selectedIndex!].name),
                              size: isTablet ? 22 : 18,
                              color: AppColors.primaryLight,
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
                                height: 58,
                                child: _buildProductsButton(context, departments[viewModel.selectedIndex!], isTablet),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SizedBox(
                                height: 58,
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
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PosProductGridView(
              departmentName: dept.name,
              departmentId: dept.id,
              preSelectedProducts: widget.preSelectedProducts,
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
  }

  Widget _buildTechnicianButton(BuildContext context, Department dept, bool isTablet) {
    return Consumer<PosViewModel>(
      builder: (context, posViewModel, child) {
        return ElevatedButton(
          onPressed: posViewModel.isLoading
              ? null
              : () async {
                  final success = await posViewModel.submitWalkInOrder([dept.id], context);
                  final orderId = posViewModel.currentJobId ?? '';
                  if (success) {
                    if (context.mounted) {
                      if (orderId.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => PosTechnicianAssignmentView(jobId: orderId)),
                        );
                      } else {
                        posViewModel?.setShellSelectedIndex(2); // Orders Tab
                        posViewModel.fetchOrders();
                        Navigator.popUntil(context, (route) => route.isFirst);
                      }
                    }
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondaryLight,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
            ),
          ),
          child: posViewModel.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
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
