import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../models/department_model.dart';
import '../widgets/owner_app_bar.dart';
import 'department_management_view_model.dart';

class DepartmentManagementView extends StatelessWidget {
  const DepartmentManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DepartmentManagementViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          appBar: OwnerAppBar(
            title: 'Department Management',
            onMenuPressed: () => Scaffold.of(context).openDrawer(),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                Expanded(child: _buildDepartmentList(vm)),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddDepartmentSheet(context),
            backgroundColor: AppColors.secondaryLight,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text('Add New Department', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Departments',
          style: AppTextStyles.h2.copyWith(fontSize: 24, color: AppColors.secondaryLight),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage all service departments for your workshop.',
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildDepartmentList(DepartmentManagementViewModel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.secondaryLight));
    }

    if (vm.departments.isEmpty) {
      return const Center(child: Text('No departments found.'));
    }

    return ListView.builder(
      itemCount: vm.departments.length,
      itemBuilder: (context, index) {
        final department = vm.departments[index];
        return _buildDepartmentCard(context, department);
      },
    );
  }

  Widget _buildDepartmentCard(BuildContext context, Department department) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryLight.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryLight.withOpacity(0.2), AppColors.primaryLight.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.category_rounded, color: AppColors.secondaryLight, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  department.name,
                  style: AppTextStyles.h2.copyWith(fontSize: 17, color: AppColors.secondaryLight),
                ),
                const SizedBox(height: 4),
                Text(
                  department.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: department.isActive ? Colors.green.shade700 : Colors.red.shade700, 
                    fontSize: 12, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDepartmentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChangeNotifierProvider.value(
        value: context.read<DepartmentManagementViewModel>(),
        child: const _AddDepartmentSheet(),
      ),
    );
  }
}

class _AddDepartmentSheet extends StatelessWidget {
  const _AddDepartmentSheet();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DepartmentManagementViewModel>();

    return FocusScope(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add Department', style: AppTextStyles.h2.copyWith(fontSize: 22)),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter the name of the new department.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  _buildTextField('Department Name', Icons.category_rounded, controller: vm.departmentNameController),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: vm.isLoading ? null : () => vm.submitDepartmentForm(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLight,
                      disabledBackgroundColor: Colors.grey.shade300,
                      minimumSize: const Size.fromHeight(56),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: vm.isLoading
                        ? const CircularProgressIndicator(color: AppColors.secondaryLight)
                        : const Text(
                            'Add Department',
                            style: TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 16),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        width: 40,
        height: 5,
        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, {TextEditingController? controller}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.secondaryLight, size: 20),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        labelStyle: const TextStyle(color: Colors.grey),
      ),
    );
  }
}
