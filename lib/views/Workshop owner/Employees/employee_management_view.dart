import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import 'employee_management_view_model.dart';
import '../../../models/workshop_owner_models.dart';
import '../widgets/owner_app_bar.dart';
import '../widgets/custom_search_bar.dart';

class EmployeeManagementView extends StatefulWidget {
  const EmployeeManagementView({super.key});

  @override
  State<EmployeeManagementView> createState() =>
      _EmployeeManagementViewState();
}

class _EmployeeManagementViewState extends State<EmployeeManagementView> {
  String? selectedBranchFilter;
  Locale? _lastLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    if (_lastLocale != null && _lastLocale != locale) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<EmployeeManagementViewModel>().onLocaleChanged();
      });
    }
    _lastLocale = locale;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<EmployeeManagementViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          appBar: OwnerAppBar(
            title: l10n.empMgmtTitle,
            onMenuPressed: () => Scaffold.of(context).openDrawer(),
          ),
          body: vm.isLoading
              ? const Center(
            child: CircularProgressIndicator(
                color: AppColors.primaryLight),
          )
              : Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (vm.employees.isNotEmpty ||
                    vm.searchQuery.isNotEmpty) ...[
                  CustomSearchBar(
                    onChanged: (val) => vm.updateSearchQuery(val),
                    hintText: l10n.empMgmtSearchHint,
                  ),
                  const SizedBox(height: 16),
                ],
                _buildFilters(vm, l10n),
                const SizedBox(height: 16),
                Expanded(child: _buildEmployeeList(vm, l10n)),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              vm.setEditEmployee(null);
              _showAddEmployeeSheet(context, vm);
            },
            backgroundColor: AppColors.secondaryLight,
            icon: const Icon(Icons.person_add_rounded, color: Colors.white),
            label: Text(
              l10n.empMgmtAddButton,
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

  Widget _buildFilters(
      EmployeeManagementViewModel vm, AppLocalizations l10n) {
    if (vm.employees.isEmpty && !vm.isLoading) {
      return const SizedBox.shrink();
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(l10n.empMgmtFilterAllBranches,
              selectedBranchFilter == null, () {
                setState(() => selectedBranchFilter = null);
              }),
          ...vm.branches.map(
                (branch) => _buildFilterChip(
              vm.branchDisplayName(branch),
              selectedBranchFilter == branch.id,
                  () {
                setState(() => selectedBranchFilter = branch.id);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
      String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryLight
                  : Colors.grey.withOpacity(0.2),
            ),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: AppColors.primaryLight.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ]
                : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? AppColors.secondaryLight
                  : Colors.grey.shade700,
              fontWeight:
              isSelected ? FontWeight.w900 : FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeList(
      EmployeeManagementViewModel vm, AppLocalizations l10n) {
    if (vm.employees.isEmpty && vm.isLoading) {
      return const SizedBox.shrink();
    }

    final filteredEmployees = selectedBranchFilter == null
        ? vm.employees
        : vm.employees
        .where((e) => e.branchId == selectedBranchFilter)
        .toList();

    if (filteredEmployees.isEmpty) {
      return Center(child: Text(l10n.empMgmtNoEmployees));
    }

    return ListView.builder(
      itemCount: filteredEmployees.length,
      itemBuilder: (context, index) {
        final employee = filteredEmployees[index];
        return _buildEmployeeCard(employee, vm, l10n);
      },
    );
  }

  Widget _buildEmployeeCard(
      OwnerEmployee employee,
      EmployeeManagementViewModel vm,
      AppLocalizations l10n,
      ) {
    final branchName =
    (employee.branchName != null && employee.branchName!.isNotEmpty)
        ? employee.branchName!
        : vm.branches
        .firstWhere(
          (b) => b.id == employee.branchId,
      orElse: () => Branch(
        id: '',
        name: l10n.empMgmtInfoUnknown,
        location: '',
        vat: '',
        cr: '',
        salesMTD: 0,
        status: '',
      ),
    )
        .name;

    final departmentNames = employee.departmentIds.map((id) {
      final matches = vm.departments.where((d) => d.id == id);
      return matches.isNotEmpty ? matches.first.name : null;
    }).where((name) => name != null).join(', ');

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color:
                            AppColors.primaryLight.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppColors.primaryLight
                                    .withOpacity(0.2)),
                          ),
                          child: const Center(
                            child: Icon(Icons.person_rounded,
                                color: AppColors.primaryLight, size: 28),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: employee.isActive
                                  ? Colors.green
                                  : Colors.grey.shade400,
                              shape: BoxShape.circle,
                              border:
                              Border.all(color: Colors.white, width: 2),
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
                          // Last seen
                          if (employee.role.toLowerCase() ==
                              'technician' &&
                              employee
                                  .localizedFormattedLastSeen(l10n)
                                  .isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                l10n.empMgmtLastSeen(
                                    employee.localizedFormattedLastSeen(
                                        l10n)),
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  employee.name,
                                  style: AppTextStyles.h2.copyWith(
                                    fontSize: 15,
                                    color: AppColors.secondaryLight,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (employee.role.toLowerCase() ==
                                  'technician' &&
                                  employee.slots != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight
                                        .withOpacity(0.08),
                                    borderRadius:
                                    BorderRadius.circular(6),
                                    border: Border.all(
                                        color: AppColors.primaryLight
                                            .withOpacity(0.1)),
                                  ),
                                  child: Text(
                                    '${employee.slots!.active}/${employee.slots!.total}',
                                    style: const TextStyle(
                                      color: AppColors.primaryLight,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _buildStatusBadge(employee, l10n),
                              if (employee.role.toLowerCase() ==
                                  'technician') ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (employee.isTechnicianAvailable
                                        ? Colors.green
                                        : Colors.grey)
                                        .withOpacity(0.1),
                                    borderRadius:
                                    BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: employee
                                              .isTechnicianAvailable
                                              ? Colors.green
                                              : Colors.grey,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        employee
                                            .localizedTechnicianStatusLabel(
                                            l10n),
                                        style: TextStyle(
                                          color: employee
                                              .isTechnicianAvailable
                                              ? Colors.green
                                              : Colors.grey.shade600,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              if (employee.role.toLowerCase() !=
                                  'technician') ...[
                                const SizedBox(width: 8),
                                Text(
                                  employee.mobile.isNotEmpty
                                      ? employee.mobile
                                      : 'N/A',
                                  style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildActionMenu(employee, vm, l10n),
                  ],
                ),
              ),
              Container(
                  height: 1, color: Colors.grey.withOpacity(0.06)),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4),
                            child: _buildInfoItem(
                              l10n.empMgmtInfoBranch,
                              branchName.toUpperCase(),
                              Icons.location_on_rounded,
                            ),
                          ),
                        ),
                        Container(
                            width: 1,
                            height: 30,
                            color: Colors.grey.withOpacity(0.1)),
                        if (employee.role.toLowerCase() != 'cashier')
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4),
                              child: _buildInfoItem(
                                l10n.empMgmtInfoDept,
                                departmentNames.isNotEmpty
                                    ? departmentNames
                                    : l10n.empMgmtInfoNone,
                                Icons.category_rounded,
                                isPrimary: true,
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4),
                              child: _buildInfoItem(
                                l10n.empMgmtInfoRoleType,
                                employee.localizedRole(l10n).toUpperCase(),
                                Icons.verified_user_rounded,
                                isPrimary: true,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (employee.role.toLowerCase() == 'technician') ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoItem(
                              l10n.empMgmtInfoTechType,
                              employee.localizedTechType(l10n),
                              Icons.build_circle_outlined,
                            ),
                          ),
                          Container(
                              width: 1,
                              height: 30,
                              color: Colors.grey.withOpacity(0.1)),
                          Expanded(
                            child: Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 4),
                              child: _buildInfoItem(
                                l10n.empMgmtInfoSalary,
                                l10n.ownerCurrencyAmount(l10n.ownerCurrencySar, ((employee.basicSalary ?? 0.0).toStringAsFixed(0)).toString()),
                                Icons.payments_outlined,
                              ),
                            ),
                          ),
                          Container(
                              width: 1,
                              height: 30,
                              color: Colors.grey.withOpacity(0.1)),
                          Expanded(
                            child: Padding(
                              padding:
                              const EdgeInsets.only(left: 4),
                              child: _buildInfoItem(
                                l10n.empMgmtInfoCommission,
                                '${employee.commissionPercent.toStringAsFixed(1)}%',
                                Icons.percent_rounded,
                                isPrimary: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionMenu(
      OwnerEmployee e,
      EmployeeManagementViewModel vm,
      AppLocalizations l10n,
      ) {
    return PopupMenuButton<String>(
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      offset: const Offset(0, 40),
      icon: Icon(Icons.more_vert_rounded,
          color: Colors.grey.shade400, size: 20),
      onSelected: (value) {
        if (value == 'edit') {
          vm.setEditEmployee(e);
          _showAddEmployeeSheet(context, vm);
        } else if (value == 'delete') {
          _showDeleteConfirmation(context, vm, e, l10n);
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
                child: const Icon(Icons.edit_rounded,
                    size: 16, color: AppColors.secondaryLight),
              ),
              const SizedBox(width: 12),
              Text(l10n.empMgmtMenuEdit,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.secondaryLight)),
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
                child: const Icon(Icons.delete_rounded,
                    size: 16, color: AppColors.secondaryLight),
              ),
              const SizedBox(width: 12),
              Text(l10n.empMgmtMenuDelete,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.secondaryLight)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon,
      {bool isPrimary = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12, color: Colors.grey.shade400),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 13,
            color: isPrimary
                ? AppColors.primaryLight
                : AppColors.secondaryLight,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildSlotItem(String label, String value, IconData icon,
      {Color? color}) {
    return Column(
      children: [
        Icon(icon, size: 14, color: color ?? Colors.grey.shade400),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13,
              color: color ?? AppColors.secondaryLight),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(
      OwnerEmployee employee, AppLocalizations l10n) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        employee.localizedRole(l10n).toUpperCase(),
        style: const TextStyle(
          color: AppColors.secondaryLight,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context,
      EmployeeManagementViewModel vm,
      OwnerEmployee e,
      AppLocalizations l10n,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.empMgmtDeleteTitle),
        content: Text(l10n.empMgmtDeleteBody(e.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.empMgmtDeleteCancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              vm.deleteEmployee(context, e.id, e.role);
            },
            child: Text(l10n.empMgmtDeleteConfirm,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddEmployeeSheet(
      BuildContext context,
      EmployeeManagementViewModel vm,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddEmployeeSheet(vm: vm),
    );
  }
}

// ─── Add / Edit Employee Sheet ────────────────────────────────────────────────

class _AddEmployeeSheet extends StatefulWidget {
  final EmployeeManagementViewModel vm;
  const _AddEmployeeSheet({required this.vm});

  @override
  State<_AddEmployeeSheet> createState() => _AddEmployeeSheetState();
}

class _AddEmployeeSheetState extends State<_AddEmployeeSheet> {
  String selectedRole = 'Technician';
  String? selectedBranchId;
  String? selectedDepartmentId;
  bool isWorkshop = true;
  bool isOnCall = false;
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    if (widget.vm.isEditing) {
      final editingEmp = widget.vm.employees.firstWhere(
            (emp) => emp.name == widget.vm.nameController.text,
        orElse: () => OwnerEmployee(
            id: '',
            name: '',
            mobile: '',
            branchId: '',
            role: '',
            departmentIds: [],
            commissionPercent: 0,
            isAvailable: false),
      );
      selectedRole = editingEmp.role.isEmpty
          ? 'Technician'
          : editingEmp.role[0].toUpperCase() +
          editingEmp.role.substring(1).toLowerCase();
      selectedBranchId = editingEmp.branchId;
      if (editingEmp.departmentIds.isNotEmpty) {
        selectedDepartmentId = editingEmp.departmentIds.first;
      }
      if (editingEmp.technicianType != null) {
        isWorkshop = editingEmp.technicianType!.toLowerCase().contains(
            'workshop') ||
            editingEmp.technicianType!.toLowerCase() == 'both';
        isOnCall =
            editingEmp.technicianType!.toLowerCase().contains('oncall') ||
                editingEmp.technicianType!.toLowerCase() == 'both';
      }
    } else {
      if (widget.vm.branches.isNotEmpty) {
        selectedBranchId = widget.vm.branches.first.id;
      }
      if (widget.vm.departments.isNotEmpty) {
        selectedDepartmentId = widget.vm.departments.first.id;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EmployeeManagementViewModel>();
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.72,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        vm.isEditing
                            ? l10n.empMgmtSheetUpdateTitle
                            : l10n.empMgmtSheetAddTitle,
                        style:
                        AppTextStyles.h2.copyWith(fontSize: 18),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded,
                            color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    vm.isEditing
                        ? l10n.empMgmtSheetUpdateSubtitle
                        : l10n.empMgmtSheetAddSubtitle,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  // Role dropdown (display translated names but keep internal
                  // English values for the submit logic)
                  _buildDropdown(
                    l10n.empMgmtFieldRole,
                    [
                      l10n.empMgmtRoleCashier,
                      l10n.empMgmtRoleTechnician,
                      l10n.empMgmtRoleSupplier,
                    ],
                    value: _localizedRole(selectedRole, l10n),
                    onChanged: (val) {
                      setState(() =>
                      selectedRole = _englishRole(val!, l10n));
                    },
                    enabled: !vm.isEditing,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    l10n.empMgmtFieldFullName,
                    Icons.person_rounded,
                    vm.nameController,
                  ),
                  _buildTextField(
                    l10n.empMgmtFieldMobile,
                    Icons.phone_android_rounded,
                    vm.mobileController,
                  ),
                  _buildTextField(
                    l10n.empMgmtFieldEmail,
                    Icons.email_rounded,
                    vm.emailController,
                  ),
                  _buildPasswordField(
                    vm.passwordController,
                    l10n,
                    isOptional: vm.isEditing,
                  ),

                  const SizedBox(height: 16),
                  if (selectedRole != l10n.empMgmtRoleSupplier)
                    if (vm.branches.isNotEmpty)
                      _buildDropdown(
                        l10n.empMgmtFieldBranch,
                        vm.branchDisplayNames,
                        value: selectedBranchId != null
                            ? vm.branchDisplayName(
                                vm.branches.firstWhere(
                                  (b) => b.id == selectedBranchId,
                                  orElse: () => vm.branches.first,
                                ),
                              )
                            : vm.branchDisplayName(vm.branches.first),
                        onChanged: (val) {
                          if (val != null) {
                            final index = vm.branchDisplayNames.indexOf(val);
                            setState(() {
                              selectedBranchId = vm.branches[
                                      index >= 0 ? index : 0]
                                  .id;
                            });
                          }
                        },
                      ),

                  if (selectedRole != l10n.empMgmtRoleCashier &&
                      selectedRole != l10n.empMgmtRoleSupplier)
                    if (vm.departments.isNotEmpty)
                      _buildDropdown(
                        l10n.empMgmtFieldDepartment,
                        vm.departmentDisplayNames,
                        value: vm.departmentDisplayName(
                          vm.departments.firstWhere(
                            (d) => d.id == selectedDepartmentId,
                            orElse: () => vm.departments.first,
                          ),
                        ),
                        onChanged: (val) {
                          final index = vm.departmentDisplayNames.indexOf(val ?? '');
                          setState(
                            () => selectedDepartmentId = vm.departments[
                                    index >= 0 ? index : 0]
                                .id,
                          );
                        },
                      ),

                  if (selectedRole == l10n.empMgmtRoleSupplier) ...[
                    const SizedBox(height: 16),
                    TypeAheadField<Map<String, dynamic>>(
                      controller: vm.addressController,
                      builder: (context, controller, focusNode) =>
                          _buildTextField(
                            l10n.empMgmtFieldAddress,
                            Icons.map_rounded,
                            controller,
                            focusNode: focusNode,
                          ),
                      suggestionsCallback: (pattern) async {
                        if (pattern.length < 3) return [];
                        return await vm.getAddressSuggestions(pattern);
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          leading: const Icon(Icons.location_on_rounded,
                              color: AppColors.primaryLight),
                          title:
                          Text(suggestion['description'] ?? ''),
                        );
                      },
                      onSelected: (suggestion) {
                        vm.onAddressSelected(suggestion);
                      },
                      emptyBuilder: (context) => Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(l10n.empMgmtNoAddressFound),
                      ),
                    ),
                    _buildTextField(
                      l10n.empMgmtFieldOpeningBalance,
                      Icons.account_balance_wallet_rounded,
                      vm.openingBalanceController,
                      isNumber: true,
                    ),
                  ],

                  if (selectedRole == l10n.empMgmtRoleTechnician) ...[
                    const SizedBox(height: 20),
                    _buildSectionTitle(l10n.empMgmtSectionTechSpecifics),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _buildToggleRow(
                            l10n.empMgmtToggleWorkshop,
                            isWorkshop,
                                (val) => setState(() => isWorkshop = val),
                          ),
                          const SizedBox(height: 10),
                          _buildToggleRow(
                            l10n.empMgmtToggleOnCall,
                            isOnCall,
                                (val) => setState(() => isOnCall = val),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (selectedRole != l10n.empMgmtRoleCashier &&
                      selectedRole != l10n.empMgmtRoleSupplier) ...[
                    const SizedBox(height: 24),
                    _buildSectionTitle(l10n.empMgmtSectionSalary),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            l10n.empMgmtFieldBaseSalary,
                            Icons.money_rounded,
                            vm.baseSalaryController,
                            isNumber: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            l10n.empMgmtFieldCommission,
                            Icons.percent_rounded,
                            vm.commissionPercentController,
                            isNumber: true,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),
                  _buildSectionTitle(l10n.empMgmtSectionAvailability),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _buildToggleRow(
                      l10n.empMgmtFieldActiveStatus,
                      vm.isActive,
                          (val) => vm.toggleStatus(val),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 18,
            ),
            child: ElevatedButton(
              onPressed: vm.isLoading
                  ? null
                  : () async {
                final bId = selectedBranchId ??
                    (vm.branches.isNotEmpty
                        ? vm.branches.first.id
                        : null);
                final dId = selectedDepartmentId ??
                    (vm.departments.isNotEmpty
                        ? vm.departments.first.id
                        : null);

                if (selectedRole == l10n.empMgmtRoleTechnician) {
                  await vm.submitTechnicianForm(
                    context,
                    branchId: bId,
                    departmentId: dId,
                    isWorkshop: isWorkshop,
                    isOnCall: isOnCall,
                  );
                } else if (selectedRole ==
                    l10n.empMgmtRoleCashier) {
                  await vm.submitCashierForm(context,
                      branchId: bId);
                } else if (selectedRole ==
                    l10n.empMgmtRoleSupplier) {
                  await vm.submitSupplierForm(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                      Text(l10n.empMgmtApiNotIntegrated),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                disabledBackgroundColor: AppColors.primaryLight,
                foregroundColor: AppColors.secondaryLight,
                disabledForegroundColor: AppColors.secondaryLight,
                minimumSize: const Size.fromHeight(56),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
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
                    ? l10n.empMgmtUpdateButton
                    : l10n.empMgmtSaveButton,
                style: const TextStyle(
                  color: AppColors.secondaryLight,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Role helpers: keep internal values as English keys ───────────────────

  String _localizedRole(String englishRole, AppLocalizations l10n) {
    switch (englishRole.toLowerCase()) {
      case 'technician':
        return l10n.empMgmtRoleTechnician;
      case 'cashier':
        return l10n.empMgmtRoleCashier;
      case 'supplier':
        return l10n.empMgmtRoleSupplier;
      default:
        return englishRole;
    }
  }

  String _englishRole(String localizedRole, AppLocalizations l10n) {
    if (localizedRole == l10n.empMgmtRoleTechnician) return 'Technician';
    if (localizedRole == l10n.empMgmtRoleCashier) return 'Cashier';
    if (localizedRole == l10n.empMgmtRoleSupplier) return 'Supplier';
    return localizedRole;
  }

  // ── Shared widget builders ────────────────────────────────────────────────

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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w900,
        fontSize: 16,
        color: AppColors.secondaryLight,
      ),
    );
  }

  Widget _buildTextField(
      String label,
      IconData icon,
      TextEditingController controller, {
        bool isNumber = false,
        bool obscureText = false,
        FocusNode? focusNode,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: isNumber
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon:
          Icon(icon, color: AppColors.secondaryLight, size: 20),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          labelStyle:
          const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
      TextEditingController controller,
      AppLocalizations l10n, {
        bool isOptional = false,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: !_passwordVisible,
        decoration: InputDecoration(
          labelText: isOptional
              ? l10n.empMgmtFieldPasswordOptional
              : l10n.empMgmtFieldPassword,
          prefixIcon: const Icon(Icons.lock_rounded,
              color: AppColors.secondaryLight, size: 20),
          suffixIcon: IconButton(
            icon: Icon(
              _passwordVisible
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              color: Colors.grey,
              size: 20,
            ),
            onPressed: () =>
                setState(() => _passwordVisible = !_passwordVisible),
          ),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          labelStyle:
          const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildDropdown(
      String label,
      List<String> items, {
        String? value,
        Function(String?)? onChanged,
        bool enabled = true,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: enabled
            ? Colors.grey.withOpacity(0.05)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enabled
              ? Colors.transparent
              : Colors.grey.withOpacity(0.1),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: label,
            labelStyle:
            const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          value:
          value ?? (items.isNotEmpty ? items[0] : null),
          items: items
              .map((e) =>
              DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: enabled ? onChanged : null,
        ),
      ),
    );
  }

  Widget _buildToggleRow(
      String label, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.secondaryLight,
        ),
      ],
    );
  }
}