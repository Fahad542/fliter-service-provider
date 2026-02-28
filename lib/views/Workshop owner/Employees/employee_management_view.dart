import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import 'employee_management_view_model.dart';
import '../../../models/workshop_owner_models.dart';
import '../widgets/owner_app_bar.dart';

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
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildFilters(vm),
                const SizedBox(height: 24),
                Expanded(child: _buildEmployeeList(vm)),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddEmployeeSheet(context, vm),
            backgroundColor: AppColors.secondaryLight,
            icon: const Icon(Icons.person_add_rounded, color: Colors.white),
            label: const Text('Add Employee', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      },
    );
  }

  // AppBar is now replaced by the shared OwnerAppBar widget

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Our Team',
          style: AppTextStyles.h2.copyWith(fontSize: 24, color: AppColors.secondaryLight),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage staff across all your branch locations.',
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildFilters(EmployeeManagementViewModel vm) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('All Branches', selectedBranchFilter == null, () {
            setState(() => selectedBranchFilter = null);
          }),
          ...vm.branches.map((branch) => _buildFilterChip(branch.name, selectedBranchFilter == branch.id, () {
            setState(() => selectedBranchFilter = branch.id);
          })),
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
            color: isSelected ? AppColors.secondaryLight : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? AppColors.secondaryLight : Colors.grey.withOpacity(0.2)),
            boxShadow: isSelected ? [BoxShadow(color: AppColors.secondaryLight.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeList(EmployeeManagementViewModel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.secondaryLight));
    }

    final filteredEmployees = selectedBranchFilter == null 
      ? vm.employees 
      : vm.employees.where((e) => e.branchId == selectedBranchFilter).toList();

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

  Widget _buildEmployeeCard(OwnerEmployee employee, EmployeeManagementViewModel vm) {
    final branchName = vm.branches.firstWhere((b) => b.id == employee.branchId, orElse: () => Branch(id: '', name: 'Unknown', location: '', vat: '', cr: '', salesMTD: 0, status: '')).name;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryLight.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
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
            child: Center(
              child: Text(
                employee.name[0],
                style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.secondaryLight, fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.name,
                  style: AppTextStyles.h2.copyWith(fontSize: 16, color: AppColors.secondaryLight),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryLight.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        employee.role.toUpperCase(),
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.secondaryLight, letterSpacing: 0.5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      branchName,
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (employee.role == 'Technician') 
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  height: 30,
                  width: 45,
                  child: Switch.adaptive(
                    value: employee.isAvailable ?? true, 
                    onChanged: (val) {},
                    activeColor: Colors.green,
                  ),
                ),
                Text(
                  employee.isAvailable ?? true ? 'AVAILABLE' : 'BUSY',
                  style: TextStyle(
                    fontSize: 8,
                    color: (employee.isAvailable ?? true) ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            )
          else 
            const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  void _showAddEmployeeSheet(BuildContext context, EmployeeManagementViewModel vm) {
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
  bool isWorkshopTechnician = true;
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    if (widget.vm.branches.isNotEmpty) {
      selectedBranchId = widget.vm.branches.first.id;
    }
    if (widget.vm.departments.isNotEmpty) {
      selectedDepartmentId = widget.vm.departments.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EmployeeManagementViewModel>();
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
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
                   Text('Add New Employee', style: AppTextStyles.h2.copyWith(fontSize: 22)),
                   const SizedBox(height: 8),
                   const Text(
                     'Provide detailed Information to register a new member.',
                     style: TextStyle(color: Colors.grey),
                   ),
                   const SizedBox(height: 30),
                   _buildDropdown(
                     'Role',
                     ['Manager', 'Cashier', 'Technician', 'Sales Executive', 'Supplier'],
                     value: selectedRole,
                     onChanged: (val) {
                       setState(() => selectedRole = val!);
                     }
                   ),
                   const SizedBox(height: 16),
                   _buildTextField('Full Name', Icons.person_rounded, vm.nameController),
                   _buildTextField('Mobile Number', Icons.phone_android_rounded, vm.mobileController),
                   _buildTextField('Email Address', Icons.email_rounded, vm.emailController),
                   _buildPasswordField(vm.passwordController),
                   
                   const SizedBox(height: 16),
                   if (selectedRole != 'Supplier')
                     if (vm.branches.isNotEmpty)
                       _buildDropdown(
                         'Assign to Branch',
                         vm.branches.map((b) => b.name).toList(),
                         value: vm.branches.firstWhere((b) => b.id == selectedBranchId, orElse: () => vm.branches.first).name,
                         onChanged: (val) {
                           setState(() => selectedBranchId = vm.branches.firstWhere((b) => b.name == val).id);
                         }
                       ),
                   if (selectedRole != 'Cashier' && selectedRole != 'Supplier')
                     if (vm.departments.isNotEmpty)
                       _buildDropdown(
                         'Assign Department',
                         vm.departments.map((d) => d.name).toList(),
                         value: vm.departments.firstWhere((d) => d.id == selectedDepartmentId, orElse: () => vm.departments.first).name,
                         onChanged: (val) {
                           setState(() => selectedDepartmentId = vm.departments.firstWhere((d) => d.name == val).id);
                         }
                       ),

                   if (selectedRole == 'Supplier') ...[
                     const SizedBox(height: 16),
                     _buildTextField('Address', Icons.map_rounded, vm.addressController),
                     _buildTextField('Opening Balance', Icons.account_balance_wallet_rounded, vm.openingBalanceController, isNumber: true),
                   ],
                   
                   if (selectedRole == 'Technician') ...[
                     const SizedBox(height: 20),
                     _buildSectionTitle('Technician Specifics'),
                     const SizedBox(height: 12),
                     Container(
                       padding: const EdgeInsets.all(12),
                       decoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
                       child: Column(
                         children: [
                           _buildToggleRow('Workshop Technician', isWorkshopTechnician, (val) {
                             setState(() => isWorkshopTechnician = val);
                           }),
                           const SizedBox(height: 10),
                           _buildToggleRow('On-Call Technician', !isWorkshopTechnician, (val) {
                             setState(() => isWorkshopTechnician = !val);
                           }),
                         ],
                       ),
                     ),
                   ],

                   if (selectedRole != 'Cashier' && selectedRole != 'Supplier') ...[
                     const SizedBox(height: 24),
                     _buildSectionTitle('Salary & Commission'),
                     const SizedBox(height: 16),
                     Row(
                       children: [
                         Expanded(child: _buildTextField('Base Salary', Icons.money_rounded, vm.baseSalaryController, isNumber: true)),
                         const SizedBox(width: 16),
                         Expanded(child: _buildTextField('Commission %', Icons.percent_rounded, vm.commissionPercentController, isNumber: true)),
                       ],
                     ),
                   ],
                    
                   const SizedBox(height: 40),
                   ElevatedButton(
                     onPressed: vm.isLoading ? null : () async {
                       if (selectedRole == 'Technician') {
                         await vm.submitTechnicianForm(
                           context, 
                           branchId: selectedBranchId, 
                           departmentId: selectedDepartmentId,
                           isWorkshopTechnician: isWorkshopTechnician,
                         );
                       } else if (selectedRole == 'Cashier') {
                         await vm.submitCashierForm(
                           context,
                           branchId: selectedBranchId,
                         );
                       } else if (selectedRole == 'Supplier') {
                         await vm.submitSupplierForm(context);
                       } else {
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Only Technician, Cashier, and Supplier creation APIs are integrated.')),
                         );
                       }
                     },
                     style: ElevatedButton.styleFrom(
                       backgroundColor: AppColors.primaryLight,
                       minimumSize: const Size.fromHeight(56),
                       elevation: 0,
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                     ),
                     child: vm.isLoading 
                         ? const CircularProgressIndicator(color: AppColors.secondaryLight)
                         : const Text(
                             'Save Employee',
                             style: TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 16),
                           ),
                   ),
                   const SizedBox(height: 40),
                ],
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

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {bool isNumber = false, bool obscureText = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
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
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: !_passwordVisible,
        decoration: InputDecoration(
          labelText: 'Password',
          prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.secondaryLight, size: 20),
          suffixIcon: IconButton(
            icon: Icon(
              _passwordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
              color: Colors.grey,
              size: 20,
            ),
            onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
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

  Widget _buildDropdown(String label, List<String> items, {String? value, Function(String?)? onChanged}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: label,
            labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          value: value ?? (items.isNotEmpty ? items[0] : null),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildToggleRow(String label, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        Switch.adaptive(value: value, onChanged: onChanged, activeColor: AppColors.secondaryLight),
      ],
    );
  }
}
