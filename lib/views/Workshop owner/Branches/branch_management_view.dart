import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../models/workshop_owner_models.dart';
import '../widgets/owner_app_bar.dart';
import '../../../utils/toast_service.dart';
import 'branch_management_view_model.dart';
import '../widgets/custom_search_bar.dart';
class BranchManagementView extends StatefulWidget {
  const BranchManagementView({super.key});

  @override
  State<BranchManagementView> createState() => _BranchManagementViewState();
}

class _BranchManagementViewState extends State<BranchManagementView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<BranchManagementViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          appBar: OwnerAppBar(
            title: 'Branch Management',
            onMenuPressed: () => Scaffold.of(context).openDrawer(),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (vm.branches.isNotEmpty || vm.searchQuery.isNotEmpty) ...[
                  CustomSearchBar(
                    onChanged: (val) => vm.updateSearchQuery(val),
                    hintText: 'Search by Name or Location...',
                  ),
                  const SizedBox(height: 24),
                ],
                Expanded(child: _buildBranchList(context, vm)),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              vm.setEditBranch(null);
              _showAddBranchSheet(context);
            },
            backgroundColor: AppColors.secondaryLight,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text('Add New Branch', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      },
    );
  }

  // AppBar is now replaced by the shared OwnerAppBar widget



  Widget _buildBranchList(BuildContext context, BranchManagementViewModel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryLight));
    }

    if (vm.branches.isEmpty) {
      return const Center(child: Text('No branches found.'));
    }

    return ListView.builder(
      itemCount: vm.branches.length,
      itemBuilder: (context, index) {
        final branch = vm.branches[index];
        return _buildBranchCard(context, branch, vm);
      },
    );
  }

  Widget _buildBranchCard(BuildContext context, Branch branch, BranchManagementViewModel vm) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
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
                        child: Icon(Icons.store_mall_directory_rounded, color: AppColors.primaryLight, size: 26),
                      ),
                    ),
                    if (branch.status.toLowerCase() == 'active')
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
                        branch.name,
                        style: AppTextStyles.h2.copyWith(fontSize: 16, color: AppColors.secondaryLight),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on_rounded, color: Colors.grey, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              branch.location,
                              style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const SizedBox(width: 8),
                _buildActionMenu(context, branch, vm),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context, Branch b, BranchManagementViewModel vm) {
    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      offset: const Offset(0, 40),
      icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade400, size: 20),
      onSelected: (value) {
        if (value == 'edit') {
          vm.setEditBranch(b);
          _showAddBranchSheet(context);
        } else if (value == 'delete') {
          _showDeleteConfirmation(context, vm, b);
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

  void _showDeleteConfirmation(BuildContext context, BranchManagementViewModel vm, Branch b) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Branch'),
        content: Text('Are you sure you want to delete "${b.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              vm.deleteBranch(context, b.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isActive = status.toLowerCase() == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withOpacity(0.12) : Colors.orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: isActive ? Colors.green.shade700 : Colors.orange.shade700,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _showAddBranchSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChangeNotifierProvider.value(
        value: context.read<BranchManagementViewModel>(),
        child: const _AddBranchSheet(),
      ),
    );
  }
}

class _AddBranchSheet extends StatelessWidget {
  const _AddBranchSheet();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BranchManagementViewModel>();

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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vm.isEditing ? 'Update Branch' : 'Register New Branch', style: AppTextStyles.h2.copyWith(fontSize: 18)),
                      const SizedBox(height: 8),
                      Text(
                        vm.isEditing ? 'Modify existing branch details.' : 'Enter branch details.',
                        style: const TextStyle(color: Colors.grey),
                      ),
                     const SizedBox(height: 30),
                     _buildTextField('Branch Name / Area', Icons.location_on_rounded, controller: vm.branchNameController),
                      _buildTextField('Address', Icons.map_rounded, controller: vm.addressController),
                   ],
                 ),
               ),
             ),
             Padding(
               padding: EdgeInsets.only(
                 left: 24,
                 right: 24,
                 top: 16,
                 bottom: MediaQuery.of(context).viewInsets.bottom + 24,
               ),
               child: ElevatedButton(
                 onPressed: vm.isActionLoading ? null : () => vm.submitBranchForm(context),
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
                         vm.isEditing ? 'Update Branch' : 'Submit for Approval',
                         style: const TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 16),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.secondaryLight),
    );
  }

  Widget _buildTextField(String label, IconData icon, {bool isNumber = false, TextEditingController? controller}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
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
      ),
    );
  }
}

