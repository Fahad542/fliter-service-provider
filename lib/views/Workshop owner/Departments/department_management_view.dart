import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../models/department_model.dart';
import '../widgets/owner_app_bar.dart';
import 'department_management_view_model.dart';
import '../widgets/custom_search_bar.dart';

class DepartmentManagementView extends StatefulWidget {
  const DepartmentManagementView({super.key});

  @override
  State<DepartmentManagementView> createState() => _DepartmentManagementViewState();
}

class _DepartmentManagementViewState extends State<DepartmentManagementView> {
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
                if (vm.departments.isNotEmpty || vm.searchQuery.isNotEmpty) ...[
                  CustomSearchBar(
                    onChanged: (val) => vm.updateSearchQuery(val),
                    hintText: 'Search by Department Name...',
                  ),
                  const SizedBox(height: 24),
                ],
                Expanded(child: _buildDepartmentList(context, vm)),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              vm.setEditDepartment(null);
              _showAddDepartmentSheet(context);
            },
            backgroundColor: AppColors.secondaryLight,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text('Add New Department', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      },
    );
  }



  Widget _buildDepartmentList(BuildContext context, DepartmentManagementViewModel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryLight));
    }

    if (vm.departments.isEmpty) {
      return const Center(child: Text('No departments found.'));
    }

    return ListView.builder(
      itemCount: vm.departments.length,
      itemBuilder: (context, index) {
        final department = vm.departments[index];
        return _buildDepartmentCard(context, department, vm);
      },
    );
  }

  Widget _buildDepartmentCard(BuildContext context, Department department, DepartmentManagementViewModel vm) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryLight.withOpacity(0.2)),
                ),
                child: const Center(
                  child: Icon(Icons.account_tree_rounded, color: AppColors.primaryLight, size: 26),
                ),
              ),
              if (department.isActive)
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  department.name,
                  style: AppTextStyles.h2.copyWith(fontSize: 16, color: AppColors.secondaryLight),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.business_rounded, color: Colors.grey.shade400, size: 14),
                    const SizedBox(width: 4),
                    const Text('Department', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const SizedBox(width: 8),
          _buildActionMenu(context, department, vm),
        ],
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context, Department d, DepartmentManagementViewModel vm) {
    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      offset: const Offset(0, 40),
      icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade400, size: 20),
      onSelected: (value) {
        if (value == 'edit') {
          vm.setEditDepartment(d);
          _showAddDepartmentSheet(context);
        } else if (value == 'delete') {
          _showDeleteConfirmation(context, vm, d);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit_rounded, size: 16, color: AppColors.secondaryLight),
              ),
              const SizedBox(width: 12),
              const Text('Edit', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.secondaryLight)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_rounded, size: 16, color: AppColors.secondaryLight),
              ),
              const SizedBox(width: 12),
              const Text('Delete', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.secondaryLight)),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, DepartmentManagementViewModel vm, Department d) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Department'),
        content: Text('Are you sure you want to delete "${d.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              vm.deleteDepartment(context, d.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withOpacity(0.12) : Colors.orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'ACTIVE' : 'INACTIVE',
        style: TextStyle(
          color: isActive ? Colors.green.shade700 : Colors.orange.shade700,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
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
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vm.isEditing ? 'Update Department' : 'Add Department', style: AppTextStyles.h2.copyWith(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text(
                      vm.isEditing ? 'Modify existing department details.' : 'Enter the name of the new department.',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 30),
                    _buildTextField('Department Name', Icons.category_rounded, controller: vm.departmentNameController),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: vm.isActionLoading ? null : () => vm.submitDepartmentForm(context),
                      style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  disabledBackgroundColor: AppColors.primaryLight,
                  foregroundColor: AppColors.secondaryLight,
                  disabledForegroundColor: AppColors.secondaryLight,
                  minimumSize: const Size.fromHeight(56),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: vm.isActionLoading
                          ? const CircularProgressIndicator(color: AppColors.secondaryLight)
                          : Text(
                              vm.isEditing ? 'Update Department' : 'Add Department',
                              style: const TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 16),
                            ),
                    ),
                  ],
                ),
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
