import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../models/workshop_owner_models.dart';
import '../widgets/owner_app_bar.dart';
import '../../../utils/toast_service.dart';
import 'branch_management_view_model.dart';
class BranchManagementView extends StatelessWidget {
  const BranchManagementView({super.key});

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
                _buildHeader(context),
                const SizedBox(height: 24),
                Expanded(child: _buildBranchList(vm)),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddBranchSheet(context),
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

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Branches',
          style: AppTextStyles.h2.copyWith(fontSize: 24, color: AppColors.secondaryLight),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage and monitor all your workshop locations.',
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildBranchList(BranchManagementViewModel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.secondaryLight));
    }

    if (vm.branches.isEmpty) {
      return const Center(child: Text('No branches found.'));
    }

    return ListView.builder(
      itemCount: vm.branches.length,
      itemBuilder: (context, index) {
        final branch = vm.branches[index];
        return _buildBranchCard(context, branch);
      },
    );
  }

  Widget _buildBranchCard(BuildContext context, Branch branch) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                child: const Icon(Icons.store_rounded, color: AppColors.secondaryLight, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      branch.name,
                      style: AppTextStyles.h2.copyWith(fontSize: 17, color: AppColors.secondaryLight),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: Colors.grey, size: 12),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            branch.location,
                            style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(branch.status),
            ],
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
        height: MediaQuery.of(context).size.height * 0.45,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            _buildHandle(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text('Register New Branch', style: AppTextStyles.h2.copyWith(fontSize: 22)),
                     const SizedBox(height: 8),
                     const Text(
                       'Enter branch details.',
                       style: TextStyle(color: Colors.grey),
                     ),
                     const SizedBox(height: 30),
                     _buildTextField('Branch Name / Area', Icons.location_on_rounded, controller: vm.branchNameController),
                     _buildTextField('Address', Icons.map_rounded, controller: vm.addressController),
                     const SizedBox(height: 40),
                     ElevatedButton(
                       onPressed: vm.isLoading ? null : () => vm.submitBranchForm(context),
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
                               'Submit for Approval',
                               style: TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 16),
                             ),
                     ),
                     const SizedBox(height: 20),
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

