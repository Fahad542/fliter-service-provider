import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import 'corporate_management_view_model.dart';
import '../../../models/workshop_owner_models.dart';
import '../widgets/owner_app_bar.dart';

class CorporateManagementView extends StatefulWidget {
  const CorporateManagementView({super.key});

  @override
  State<CorporateManagementView> createState() => _CorporateManagementViewState();
}

class _CorporateManagementViewState extends State<CorporateManagementView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<CorporateManagementViewModel>(
      builder: (context, vm, child) {
        final filteredCustomers = vm.corporateCustomers.where((c) => 
          c.companyName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.vatNumber.contains(_searchQuery)
        ).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          appBar: OwnerAppBar(
            title: 'Corporate Management',
            onMenuPressed: () => Scaffold.of(context).openDrawer(),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildSearchBar(),
                const SizedBox(height: 24),
                Expanded(child: _buildCustomerList(filteredCustomers)),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddCorporateSheet(context, vm),
            backgroundColor: AppColors.secondaryLight,
            icon: const Icon(Icons.add_business_rounded, color: Colors.white),
            label: const Text('Add Corporate', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Corporate Partners',
          style: AppTextStyles.h2.copyWith(fontSize: 24, color: AppColors.secondaryLight),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage billing and branch access for corporate clients.',
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (val) => setState(() => _searchQuery = val),
      decoration: InputDecoration(
        hintText: 'Search by Company or VAT...',
        prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
      ),
    );
  }

  Widget _buildCustomerList(List<CorporateCustomer> customers) {
    if (customers.isEmpty) {
      return const Center(child: Text('No corporate customers found.'));
    }

    return ListView.builder(
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        return _buildCustomerCard(customer);
      },
    );
  }

  Widget _buildCustomerCard(CorporateCustomer customer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Column(
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
                child: const Icon(Icons.business_rounded, color: AppColors.secondaryLight, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customer.companyName, style: AppTextStyles.h2.copyWith(fontSize: 17, color: AppColors.secondaryLight)),
                    const SizedBox(height: 2),
                    Text('VAT: ${customer.vatNumber}', style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              _buildCategoryBadge(customer.category),
            ],
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: Colors.grey.withOpacity(0.08)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem('CONTACT', customer.contactName),
              _buildInfoItem('VEHICLES', customer.vehicleCount.toString()),
              _buildInfoItem('TOTAL REVENUE', 'SAR ${customer.totalSales.toStringAsFixed(0)}', isPrimary: true),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _showAddUserSheet(context, context.read<CorporateManagementViewModel>(), customer.id),
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: const Text('Add User', style: TextStyle(fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(String category) {
    Color color;
    switch (category.toLowerCase()) {
      case 'gold': color = const Color(0xFFD4AF37); break;
      case 'silver': color = const Color(0xFFC0C0C0); break;
      default: color = const Color(0xFFCD7F32);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        category.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, {bool isPrimary = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13,
            color: isPrimary ? AppColors.secondaryLight : Colors.black87,
          ),
        ),
      ],
    );
  }

  void _showAddCorporateSheet(BuildContext context, CorporateManagementViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddCorporateSheet(vm: vm),
    );
  }

  void _showAddUserSheet(BuildContext context, CorporateManagementViewModel vm, String customerId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddCorporateUserSheet(vm: vm, corporateAccountId: customerId),
    );
  }
}

class _AddCorporateSheet extends StatefulWidget {
  final CorporateManagementViewModel vm;
  const _AddCorporateSheet({required this.vm});

  @override
  State<_AddCorporateSheet> createState() => _AddCorporateSheetState();
}

class _AddCorporateSheetState extends State<_AddCorporateSheet> {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CorporateManagementViewModel>();
    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
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
                  Text('Register Corporate Partner', style: AppTextStyles.h2.copyWith(fontSize: 22)),
                  const SizedBox(height: 8),
                  const Text('Fill in the details to create a new corporate account.', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 30),
                  _buildTextField('Company Name', Icons.business_rounded, vm.companyNameController),
                  _buildTextField('Customer Name', Icons.person_rounded, vm.contactNameController),
                  _buildTextField('Mobile Number', Icons.phone_android_rounded, vm.mobileController, keyboardType: TextInputType.phone),
                  _buildTextField('Tax ID', Icons.receipt_long_rounded, vm.vatNumberController),
                  _buildTextField('Credit Limit', Icons.monetization_on_rounded, vm.creditLimitController, keyboardType: TextInputType.number),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: vm.isLoading ? null : () => vm.submitCorporateForm(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryLight,
                      minimumSize: const Size.fromHeight(56),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: vm.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Create Partner', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                  ),
                  const SizedBox(height: 20),
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
        width: 40, height: 5,
        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {TextInputType keyboardType = TextInputType.text, bool obscureText = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.secondaryLight, size: 20),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}

class _AddCorporateUserSheet extends StatefulWidget {
  final CorporateManagementViewModel vm;
  final String corporateAccountId;
  const _AddCorporateUserSheet({required this.vm, required this.corporateAccountId});

  @override
  State<_AddCorporateUserSheet> createState() => _AddCorporateUserSheetState();
}

class _AddCorporateUserSheetState extends State<_AddCorporateUserSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
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
                  Text('Add Corporate User', style: AppTextStyles.h2.copyWith(fontSize: 22)),
                  const SizedBox(height: 8),
                  const Text('Create credentials for a user associated with this corporate account.', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 30),
                  _buildTextField('Full Name', Icons.person_rounded, widget.vm.userNameController),
                  _buildTextField('Email Address', Icons.email_rounded, widget.vm.userEmailController, keyboardType: TextInputType.emailAddress),
                  _buildTextField('Password', Icons.lock_rounded, widget.vm.userPasswordController, obscureText: true),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: widget.vm.isLoading ? null : () => widget.vm.submitCorporateUserForm(context, widget.corporateAccountId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryLight,
                      minimumSize: const Size.fromHeight(56),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: widget.vm.isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Create User', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                  ),
                  const SizedBox(height: 20),
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
        width: 40, height: 5,
        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {TextInputType keyboardType = TextInputType.text, bool obscureText = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.secondaryLight, size: 20),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
