import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import 'employee_management_view_model.dart';
import '../../../models/workshop_owner_models.dart';
import '../widgets/owner_app_bar.dart';
import '../widgets/custom_search_bar.dart';

class EmployeeManagementView extends StatefulWidget {
  const EmployeeManagementView({super.key});

  @override
  State<EmployeeManagementView> createState() => _EmployeeManagementViewState();
}

class _EmployeeManagementViewState extends State<EmployeeManagementView> {
  String? selectedBranchFilter;

  @override
  Widget build(BuildContext context) {
    return Consumer<EmployeeManagementViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          appBar: OwnerAppBar(
            title: 'Employee Management',
            onMenuPressed: () => Scaffold.of(context).openDrawer(),
          ),
          body: vm.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryLight),
                )
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (vm.employees.isNotEmpty || vm.searchQuery.isNotEmpty) ...[
                        CustomSearchBar(
                          onChanged: (val) => vm.updateSearchQuery(val),
                          hintText: 'Search by Name, Email or Mobile...',
                        ),
                        const SizedBox(height: 16),
                      ],
                      _buildFilters(vm),
                      const SizedBox(height: 16),
                      Expanded(child: _buildEmployeeList(vm)),
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
            label: const Text(
              'Add Employee',
              style: TextStyle(
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

  // AppBar is now replaced by the shared OwnerAppBar widget

  Widget _buildFilters(EmployeeManagementViewModel vm) {
    if (vm.employees.isEmpty && !vm.isLoading) {
      return const SizedBox.shrink();
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('All Branches', selectedBranchFilter == null, () {
            setState(() => selectedBranchFilter = null);
          }),
          ...vm.branches.map(
            (branch) => _buildFilterChip(
              branch.name,
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

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
              color: isSelected ? AppColors.secondaryLight : Colors.grey.shade700,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeList(EmployeeManagementViewModel vm) {
    if (vm.employees.isEmpty && vm.isLoading) {
      return const SizedBox.shrink();
    }

    final filteredEmployees = selectedBranchFilter == null
        ? vm.employees
        : vm.employees
              .where((e) => e.branchId == selectedBranchFilter)
              .toList();

    if (filteredEmployees.isEmpty) {
      return const Center(child: Text('No employees found.'));
    }

    return ListView.builder(
      itemCount: filteredEmployees.length,
      itemBuilder: (context, index) {
        final employee = filteredEmployees[index];
        return _buildEmployeeCard(employee, vm);
      },
    );
  }

  Widget _buildEmployeeCard(
    OwnerEmployee employee,
    EmployeeManagementViewModel vm,
  ) {
    final branchName = vm.branches
        .firstWhere(
          (b) => b.id == employee.branchId,
          orElse: () => Branch(
            id: '',
            name: 'Unknown',
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
                        child: Icon(Icons.person_rounded, color: AppColors.primaryLight, size: 28),
                      ),
                    ),
                    if (employee.isOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 14,
                          height: 14,
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
                        employee.name,
                        style: AppTextStyles.h2.copyWith(
                          fontSize: 15,
                          color: AppColors.secondaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      _buildStatusBadge(employee),
                    ],
                  ),
                ),
                _buildActionMenu(employee, vm),
              ],
            ),
          ),
          Container(height: 1, color: Colors.grey.withOpacity(0.06)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildInfoItem('MOBILE', employee.mobile.isNotEmpty ? employee.mobile : 'N/A', Icons.phone_android_rounded)),
                    Container(width: 1, height: 30, color: Colors.grey.withOpacity(0.1)),
                    if (employee.role.toLowerCase() != 'cashier')
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: _buildInfoItem('DEPARTMENTS', departmentNames.isNotEmpty ? departmentNames : 'None', Icons.category_rounded, isPrimary: true),
                        ),
                      )
                    else
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: _buildInfoItem(
                            'STATUS', 
                            employee.status.toUpperCase(), 
                            employee.status.toLowerCase() == 'active' ? Icons.verified_user_rounded : Icons.do_not_disturb_on_rounded, 
                            isPrimary: employee.status.toLowerCase() == 'active',
                          ),
                        ),
                      ),
                    Container(width: 1, height: 30, color: Colors.grey.withOpacity(0.1)),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: _buildInfoItem('BRANCH', branchName.toUpperCase(), Icons.location_on_rounded),
                      ),
                    ),
                  ],
                ),
                if (employee.role.toLowerCase() == 'technician') ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildInfoItem('TECH TYPE', (employee.technicianType ?? 'Unknown').toUpperCase(), Icons.build_circle_outlined)),
                      Container(width: 1, height: 30, color: Colors.grey.withOpacity(0.1)),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: _buildInfoItem('SALARY / COMM', 'SAR ${(employee.basicSalary ?? 0.0).toStringAsFixed(0)} / ${employee.commissionPercent.toStringAsFixed(2)}%', Icons.payments_outlined),
                        ),
                      ),
                      Container(width: 1, height: 30, color: Colors.grey.withOpacity(0.1)),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: _buildInfoItem(
                            'STATUS', 
                            employee.status.toUpperCase(), 
                            employee.status.toLowerCase() == 'active' ? Icons.verified_user_rounded : Icons.do_not_disturb_on_rounded, 
                            isPrimary: employee.status.toLowerCase() == 'active',
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
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, {bool isPrimary = false}) {
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
              style: TextStyle(color: Colors.grey.shade400, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 13,
            color: isPrimary ? AppColors.primaryLight : AppColors.secondaryLight,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildActionMenu(OwnerEmployee e, EmployeeManagementViewModel vm) {
    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      offset: const Offset(0, 40),
      icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade400, size: 20),
      onSelected: (value) {
        if (value == 'edit') {
          vm.setEditEmployee(e);
          _showAddEmployeeSheet(context, vm);
        } else if (value == 'delete') {
          _showDeleteConfirmation(context, vm, e);
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

  void _showDeleteConfirmation(BuildContext context, EmployeeManagementViewModel vm, OwnerEmployee e) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Are you sure you want to delete "${e.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              vm.deleteEmployee(context, e.id, e.role);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(OwnerEmployee employee) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        employee.role.toUpperCase(),
        style: const TextStyle(
          color: AppColors.secondaryLight,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
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
      final e = widget.vm.employees.firstWhere((emp) => emp.name == widget.vm.nameController.text); // Rough way to find current editing employee if needed, but better to use the fields already pre-filled in VM
      selectedRole = widget.vm.employees.firstWhere((emp) => emp.name == widget.vm.nameController.text, orElse: () => OwnerEmployee(id: '', name: '', mobile: '', branchId: '', role: 'Technician', departmentIds: [], commissionPercent: 0, isAvailable: false)).role;
      // Capitalize first letter of role
      if (selectedRole.isNotEmpty) {
        selectedRole = selectedRole[0].toUpperCase() + selectedRole.substring(1).toLowerCase();
      }
      
      // Attempt to find the full employee object from VM to get branch/dept/techType
      final editingEmp = widget.vm.employees.firstWhere((emp) => emp.name == widget.vm.nameController.text, orElse: () => OwnerEmployee(id: '', name: '', mobile: '', branchId: '', role: '', departmentIds: [], commissionPercent: 0, isAvailable: false));
      selectedBranchId = editingEmp.branchId;
      if (editingEmp.departmentIds.isNotEmpty) {
        selectedDepartmentId = editingEmp.departmentIds.first;
      }
      if (editingEmp.technicianType != null) {
        isWorkshop = editingEmp.technicianType!.toLowerCase().contains('workshop') || editingEmp.technicianType!.toLowerCase() == 'both';
        isOnCall = editingEmp.technicianType!.toLowerCase().contains('oncall') || editingEmp.technicianType!.toLowerCase() == 'both';
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
    return Container(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        vm.isEditing ? 'Update Employee' : 'Add New Employee',
                        style: AppTextStyles.h2.copyWith(fontSize: 18),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    vm.isEditing ? 'Modify existing employee details.' : 'Provide detailed Information to register a new member.',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  _buildDropdown(
                    'Role',
                    [
                      'Manager',
                      'Cashier',
                      'Technician',
                      'Sales Executive',
                      'Supplier',
                    ],
                    value: selectedRole,
                    onChanged: (val) {
                      setState(() => selectedRole = val!);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Full Name',
                    Icons.person_rounded,
                    vm.nameController,
                  ),
                  _buildTextField(
                    'Mobile Number',
                    Icons.phone_android_rounded,
                    vm.mobileController,
                  ),
                  _buildTextField(
                    'Email Address',
                    Icons.email_rounded,
                    vm.emailController,
                  ),
                  _buildPasswordField(vm.passwordController, isOptional: vm.isEditing),

                  const SizedBox(height: 16),
                  if (selectedRole != 'Supplier')
                    if (vm.branches.isNotEmpty)
                      _buildDropdown(
                        'Assign to Branch',
                        vm.branches.map((b) => b.name).toList(),
                        value: selectedBranchId != null
                            ? vm.branches
                                  .firstWhere(
                                    (b) => b.id == selectedBranchId,
                                    orElse: () => vm.branches.first,
                                  )
                                  .name
                            : vm.branches.first.name,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              selectedBranchId = vm.branches
                                  .firstWhere(
                                    (b) => b.name == val,
                                    orElse: () => vm.branches.first,
                                  )
                                  .id;
                            });
                          }
                        },
                      ),
                  if (selectedRole != 'Cashier' && selectedRole != 'Supplier')
                    if (vm.departments.isNotEmpty)
                      _buildDropdown(
                        'Assign Department',
                        vm.departments.map((d) => d.name).toList(),
                        value: vm.departments
                            .firstWhere(
                              (d) => d.id == selectedDepartmentId,
                              orElse: () => vm.departments.first,
                            )
                            .name,
                        onChanged: (val) {
                          setState(
                            () => selectedDepartmentId = vm.departments
                                .firstWhere((d) => d.name == val)
                                .id,
                          );
                        },
                      ),

                  if (selectedRole == 'Supplier') ...[
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Address',
                      Icons.map_rounded,
                      vm.addressController,
                    ),
                    _buildTextField(
                      'Opening Balance',
                      Icons.account_balance_wallet_rounded,
                      vm.openingBalanceController,
                      isNumber: true,
                    ),
                  ],

                  if (selectedRole == 'Technician') ...[
                    const SizedBox(height: 20),
                    _buildSectionTitle('Technician Specifics'),
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
                            'Workshop Technician',
                            isWorkshop,
                            (val) {
                              setState(() => isWorkshop = val);
                            },
                          ),
                          const SizedBox(height: 10),
                          _buildToggleRow(
                            'On-Call Technician',
                            isOnCall,
                            (val) {
                              setState(() => isOnCall = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (selectedRole != 'Cashier' &&
                      selectedRole != 'Supplier') ...[
                    const SizedBox(height: 24),
                    _buildSectionTitle('Salary & Commission'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            'Base Salary',
                            Icons.money_rounded,
                            vm.baseSalaryController,
                            isNumber: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            'Commission %',
                            Icons.percent_rounded,
                            vm.commissionPercentController,
                            isNumber: true,
                          ),
                        ),
                      ],
                    ),
                  ],

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
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: ElevatedButton(
                onPressed: vm.isLoading
                    ? null
                    : () async {
                        final bId =
                            selectedBranchId ??
                            (vm.branches.isNotEmpty
                                ? vm.branches.first.id
                                : null);
                        final dId =
                            selectedDepartmentId ??
                            (vm.departments.isNotEmpty
                                ? vm.departments.first.id
                                : null);

                        if (selectedRole == 'Technician') {
                            await vm.submitTechnicianForm(
                              context,
                              branchId: bId,
                              departmentId: dId,
                              isWorkshop: isWorkshop,
                              isOnCall: isOnCall,
                            );
                        } else if (selectedRole == 'Cashier') {
                          await vm.submitCashierForm(
                            context,
                            branchId: bId,
                          );
                        } else if (selectedRole == 'Supplier') {
                          await vm.submitSupplierForm(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Only Technician, Cashier, and Supplier creation APIs are integrated.',
                              ),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: vm.isActionLoading
                    ? const CircularProgressIndicator(
                        color: AppColors.secondaryLight,
                      )
                    : Text(
                        vm.isEditing ? 'Update Employee' : 'Save Employee',
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
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.secondaryLight, size: 20),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, {bool isOptional = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: !_passwordVisible,
        decoration: InputDecoration(
          labelText: isOptional ? 'Password (Optional)' : 'Password',
          prefixIcon: const Icon(
            Icons.lock_rounded,
            color: AppColors.secondaryLight,
            size: 20,
          ),
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
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items, {
    String? value,
    Function(String?)? onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: label,
            labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          value: value ?? (items.isNotEmpty ? items[0] : null),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildToggleRow(String label, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
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
