import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../models/department_model.dart';
import '../widgets/owner_app_bar.dart';
import 'department_management_view_model.dart';
import '../widgets/custom_search_bar.dart';

class DepartmentManagementView extends StatefulWidget {
  const DepartmentManagementView({super.key});

  @override
  State<DepartmentManagementView> createState() =>
      _DepartmentManagementViewState();
}

class _DepartmentManagementViewState extends State<DepartmentManagementView> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<DepartmentManagementViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          appBar: OwnerAppBar(
            title: l10n.deptMgmtTitle,
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
                    hintText: l10n.deptMgmtSearchHint,
                  ),
                  const SizedBox(height: 24),
                ],
                Expanded(child: _buildDepartmentList(context, vm, l10n)),
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
            label: Text(
              l10n.deptMgmtAddButton,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDepartmentList(
      BuildContext context,
      DepartmentManagementViewModel vm,
      AppLocalizations l10n,
      ) {
    if (vm.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryLight),
      );
    }

    if (vm.departments.isEmpty) {
      return Center(child: Text(l10n.deptMgmtNoDepartments));
    }

    return ListView.builder(
      itemCount: vm.departments.length,
      itemBuilder: (context, index) {
        final department = vm.departments[index];
        return _buildDepartmentCard(context, department, vm, l10n);
      },
    );
  }

  Widget _buildDepartmentCard(
      BuildContext context,
      Department department,
      DepartmentManagementViewModel vm,
      AppLocalizations l10n,
      ) {
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
                  border: Border.all(
                    color: AppColors.primaryLight.withOpacity(0.2),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.account_tree_rounded,
                    color: AppColors.primaryLight,
                    size: 26,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: department.isActive
                        ? Colors.green
                        : Colors.grey.shade400,
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
                  style: AppTextStyles.h2.copyWith(
                    fontSize: 16,
                    color: AppColors.secondaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.business_rounded,
                      color: Colors.grey.shade400,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.deptMgmtLabelDepartment,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _buildActionMenu(context, department, vm, l10n),
        ],
      ),
    );
  }

  Widget _buildActionMenu(
      BuildContext context,
      Department d,
      DepartmentManagementViewModel vm,
      AppLocalizations l10n,
      ) {
    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      offset: const Offset(0, 40),
      icon: Icon(
        Icons.more_vert_rounded,
        color: Colors.grey.shade400,
        size: 20,
      ),
      onSelected: (value) {
        if (value == 'edit') {
          vm.setEditDepartment(d);
          _showAddDepartmentSheet(context);
        } else if (value == 'delete') {
          _showDeleteConfirmation(context, vm, d, l10n);
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
                child: const Icon(
                  Icons.edit_rounded,
                  size: 16,
                  color: AppColors.secondaryLight,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.deptMgmtMenuEdit,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.secondaryLight,
                ),
              ),
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
                child: const Icon(
                  Icons.delete_rounded,
                  size: 16,
                  color: AppColors.secondaryLight,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.deptMgmtMenuDelete,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.secondaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(
      BuildContext context,
      DepartmentManagementViewModel vm,
      Department d,
      AppLocalizations l10n,
      ) {
    final parentContext = context;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              l10n.deptMgmtConfirmDeleteTitle,
              style: const TextStyle(
                  fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          l10n.deptMgmtConfirmDeleteBody(d.name),
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    l10n.deptMgmtCancel,
                    style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    vm.deleteDepartment(parentContext, d.id);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: AppColors.secondaryLight,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    l10n.deptMgmtDelete,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.12)
            : Colors.orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? l10n.deptMgmtStatusActive : l10n.deptMgmtStatusInactive,
        style: TextStyle(
          color:
          isActive ? Colors.green.shade700 : Colors.orange.shade700,
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
    final l10n = AppLocalizations.of(context)!;

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
                    Text(
                      vm.isEditing
                          ? l10n.deptMgmtSheetUpdateTitle
                          : l10n.deptMgmtSheetAddTitle,
                      style: AppTextStyles.h2.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      vm.isEditing
                          ? l10n.deptMgmtSheetUpdateSubtitle
                          : l10n.deptMgmtSheetAddSubtitle,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 30),
                    _buildTextField(
                      l10n.deptMgmtFieldName,
                      Icons.category_rounded,
                      controller: vm.departmentNameController,
                    ),
                    const SizedBox(height: 16),
                    _buildSwitchTile(
                      l10n.deptMgmtFieldActiveStatus,
                      vm.isActive,
                          (val) => vm.toggleStatus(val),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: vm.isActionLoading
                          ? null
                          : () => vm.submitDepartmentForm(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        disabledBackgroundColor: AppColors.primaryLight,
                        foregroundColor: AppColors.secondaryLight,
                        disabledForegroundColor: AppColors.secondaryLight,
                        minimumSize: const Size.fromHeight(56),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: vm.isActionLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.secondaryLight,
                          strokeWidth: 2,
                        ),
                      )
                          : Text(
                        vm.isEditing
                            ? l10n.deptMgmtSheetUpdateButton
                            : l10n.deptMgmtSheetAddButton,
                        style: const TextStyle(
                          color: AppColors.secondaryLight,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
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
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
      String title, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.grey, fontWeight: FontWeight.w600)),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryLight,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label,
      IconData icon, {
        TextEditingController? controller,
      }) {
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