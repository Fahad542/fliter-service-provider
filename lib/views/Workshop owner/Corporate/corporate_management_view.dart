import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import 'corporate_management_view_model.dart';
import '../../../models/workshop_owner_models.dart';
import '../widgets/owner_app_bar.dart';
import '../widgets/custom_search_bar.dart';

class CorporateManagementView extends StatefulWidget {
  const CorporateManagementView({super.key});

  @override
  State<CorporateManagementView> createState() => _CorporateManagementViewState();
}

class _CorporateManagementViewState extends State<CorporateManagementView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<CorporateManagementViewModel>(
      builder: (context, vm, child) {
        final filteredCustomers = vm.corporateCustomers.where((c) =>
        c.companyName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.vatNumber.contains(_searchQuery),
        ).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          appBar: OwnerAppBar(
            title: l10n.corporateManagementTitle,
            onMenuPressed: () => Scaffold.of(context).openDrawer(),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (vm.corporateCustomers.isNotEmpty) ...[
                  CustomSearchBar(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    hintText: l10n.corporateSearchHint,
                  ),
                  const SizedBox(height: 24),
                ],
                Expanded(
                  child: vm.isListLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primaryLight))
                      : _buildCustomerList(filteredCustomers),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddCorporateSheet(context, vm),
            backgroundColor: AppColors.secondaryLight,
            icon: const Icon(Icons.add_business_rounded, color: Colors.white),
            label: Text(
              l10n.corporateAddButton,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      },
    );
  }

  Widget _buildCustomerList(List<CorporateCustomer> customers) {
    final l10n = AppLocalizations.of(context)!;
    if (customers.isEmpty) {
      return Center(child: Text(l10n.corporateNoneFound));
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
    final l10n = AppLocalizations.of(context)!;
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
        children: [
          // Top Section: Header & Badge
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Avatar
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primaryLight.withOpacity(0.2)),
                  ),
                  child: const Center(
                    child: Icon(Icons.maps_home_work_rounded, color: AppColors.primaryLight, size: 28),
                  ),
                ),
                const SizedBox(width: 16),
                // Title and Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.companyName,
                        style: AppTextStyles.h2.copyWith(fontSize: 16, color: AppColors.secondaryLight),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.person_pin_rounded, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            customer.contactName,
                            style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.corporateVatLabel(customer.vatNumber),
                        style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                // Category Badge
                _buildCategoryBadge(customer.category),
              ],
            ),
          ),

          Container(height: 1, color: Colors.grey.withOpacity(0.06)),

          // Middle Section: Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    l10n.corporateVehiclesLabel,
                    customer.vehicleCount.toString(),
                    Icons.directions_car_rounded,
                  ),
                ),
                Container(width: 1, height: 30, color: Colors.grey.withOpacity(0.1)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: _buildInfoItem(
                      l10n.corporateRevenueLabel,
                      'SAR ${customer.totalSales.toStringAsFixed(0)}',
                      Icons.payments_rounded,
                      isPrimary: true,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(height: 1, color: Colors.grey.withOpacity(0.06)),

          // Bottom Section: Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _showAddUserSheet(
                      context,
                      context.read<CorporateManagementViewModel>(),
                      customer.id,
                    ),
                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                    label: Text(
                      l10n.corporateAddUser,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.secondaryLight,
                      backgroundColor: AppColors.primaryLight,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                TextButton.icon(
                  onPressed: () => _showEditCorporateSheet(
                    context,
                    context.read<CorporateManagementViewModel>(),
                    customer,
                  ),
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: Text(
                    l10n.corporateEdit,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.secondaryLight,
                    backgroundColor: AppColors.secondaryLight.withOpacity(0.08),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(String category) {
    Color color;
    switch (category.toLowerCase()) {
      case 'gold':   color = const Color(0xFFD4AF37); break;
      case 'silver': color = const Color(0xFFC0C0C0); break;
      default:       color = const Color(0xFFCD7F32);
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

  Widget _buildInfoItem(String label, String value, IconData icon, {bool isPrimary = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: Colors.grey),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: isPrimary ? AppColors.primaryLight : AppColors.secondaryLight,
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

  void _showEditCorporateSheet(BuildContext context, CorporateManagementViewModel vm, CorporateCustomer customer) {
    vm.setEditCorporate(customer);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditCorporateSheet(vm: vm),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Corporate Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _AddCorporateSheet extends StatefulWidget {
  final CorporateManagementViewModel vm;
  const _AddCorporateSheet({required this.vm});

  @override
  State<_AddCorporateSheet> createState() => _AddCorporateSheetState();
}

class _AddCorporateSheetState extends State<_AddCorporateSheet> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vm = context.watch<CorporateManagementViewModel>();

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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.corporateRegisterTitle, style: AppTextStyles.h2.copyWith(fontSize: 18)),
                  const SizedBox(height: 6),
                  Text(l10n.corporateRegisterSubtitle, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),
                  _buildTextField(l10n.corporateFieldCompanyName, Icons.business_rounded, vm.companyNameController),
                  _buildTextField(l10n.corporateFieldCustomerName, Icons.person_rounded, vm.contactNameController),
                  _buildTextField(
                    l10n.corporateFieldMobile,
                    Icons.phone_android_rounded,
                    vm.mobileController,
                    inputType: TextInputType.phone,
                  ),
                  _buildTextField(l10n.corporateFieldVat, Icons.receipt_long_rounded, vm.vatNumberController),
                  const SizedBox(height: 10),
                  _buildTextField(
                    l10n.corporateFieldEmail,
                    Icons.email_rounded,
                    vm.emailController,
                    inputType: TextInputType.emailAddress,
                    contentPadding: const EdgeInsets.fromLTRB(0, 12, 0, 10),
                  ),
                  _buildTextField(
                    l10n.corporateFieldPassword,
                    Icons.lock_rounded,
                    vm.passwordController,
                    obscureText: !_isPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                  _buildReferralDropdown(vm, l10n),
                  const SizedBox(height: 6),
                  _buildBranchesHeader(vm, l10n),
                  const SizedBox(height: 8),
                  _buildBranchesSelector(vm, l10n),
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
              onPressed: vm.isActionLoading ? null : () => vm.submitCorporateForm(context),
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
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: AppColors.secondaryLight, strokeWidth: 2),
              )
                  : Text(
                l10n.corporateCreateButton,
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
        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildBranchesSelector(CorporateManagementViewModel vm, AppLocalizations l10n) {
    if (vm.branches.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(l10n.corporateNoBranches, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 180),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: vm.branches.length,
        itemBuilder: (context, index) {
          final branch = vm.branches[index];
          final isSelected = vm.selectedBranchIds.contains(branch.id);
          return CheckboxListTile(
            value: isSelected,
            activeColor: AppColors.primaryLight,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            title: Text(branch.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            subtitle: branch.location.isEmpty
                ? null
                : Text(branch.location, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            onChanged: (_) => vm.toggleBranchSelection(branch.id),
          );
        },
      ),
    );
  }

  Widget _buildBranchesHeader(CorporateManagementViewModel vm, AppLocalizations l10n) {
    final selectedCount = vm.selectedBranchIds.length;
    return Row(
      children: [
        const Icon(Icons.store_mall_directory_rounded, size: 18, color: AppColors.secondaryLight),
        const SizedBox(width: 8),
        Text(
          l10n.corporateSelectBranches,
          style: const TextStyle(
            color: AppColors.secondaryLight,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.18),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            l10n.corporateSelectedCount(selectedCount),
            style: const TextStyle(
              color: AppColors.secondaryLight,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReferralDropdown(CorporateManagementViewModel vm, AppLocalizations l10n) {
    final items = vm.referrals;
    final selected = vm.selectedReferralId;
    final selectedValue = (selected != null && items.any((r) => r.id == selected))
        ? selected
        : (items.isNotEmpty ? items.first.id : null);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: l10n.corporateFieldReferral,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          prefixIcon: const Icon(Icons.card_giftcard_rounded, color: AppColors.secondaryLight, size: 20),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
        items: items
            .map((r) => DropdownMenuItem<String>(
          value: r.id,
          child: Text(
            r.category.isEmpty ? r.name : '${r.name} (${r.category})',
            overflow: TextOverflow.ellipsis,
          ),
        ))
            .toList(),
        onChanged: items.isEmpty ? null : (value) => vm.setSelectedReferralId(value),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.secondaryLight),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      IconData icon,
      TextEditingController controller, {
        TextInputType inputType = TextInputType.text,
        bool obscureText = false,
        Widget? suffixIcon,
        EdgeInsetsGeometry? contentPadding,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.secondaryLight, size: 20),
          suffixIcon: suffixIcon,
          contentPadding: contentPadding,
          filled: true,
          fillColor: Colors.grey.withOpacity(0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Corporate User Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _AddCorporateUserSheet extends StatefulWidget {
  final CorporateManagementViewModel vm;
  final String corporateAccountId;
  const _AddCorporateUserSheet({required this.vm, required this.corporateAccountId});

  @override
  State<_AddCorporateUserSheet> createState() => _AddCorporateUserSheetState();
}

class _AddCorporateUserSheetState extends State<_AddCorporateUserSheet> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vm = context.watch<CorporateManagementViewModel>();

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
                  Text(l10n.corporateAddUserTitle, style: AppTextStyles.h2.copyWith(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(l10n.corporateAddUserSubtitle, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 30),
                  _buildTextField(l10n.corporateUserFieldName, Icons.person_rounded, vm.userNameController),
                  _buildTextField(l10n.corporateUserFieldEmail, Icons.email_rounded, vm.userEmailController),
                  _buildTextField(
                    l10n.corporateUserFieldPassword,
                    Icons.lock_rounded,
                    vm.userPasswordController,
                    obscureText: !_isPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
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
              onPressed: vm.isActionLoading
                  ? null
                  : () => vm.submitCorporateUserForm(context, widget.corporateAccountId),
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
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: AppColors.secondaryLight, strokeWidth: 2),
              )
                  : Text(
                l10n.corporateCreateUserButton,
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
        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      IconData icon,
      TextEditingController controller, {
        bool isNumber = false,
        bool obscureText = false,
        Widget? suffixIcon,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.secondaryLight, size: 20),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.grey.withOpacity(0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Edit Corporate Account Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _EditCorporateSheet extends StatelessWidget {
  final CorporateManagementViewModel vm;
  const _EditCorporateSheet({required this.vm});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ChangeNotifierProvider.value(
      value: vm,
      child: Consumer<CorporateManagementViewModel>(
        builder: (context, vm, _) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.78),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.corporateEditTitle, style: AppTextStyles.h2.copyWith(fontSize: 18)),
                      const SizedBox(height: 6),
                      Text(l10n.corporateEditSubtitle, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 20),
                      _editField(l10n.corporateFieldCompanyName, Icons.business_rounded, vm.editCompanyNameController),
                      _editField(l10n.corporateFieldCustomerName, Icons.person_rounded, vm.editCustomerNameController),
                      _editField(
                        l10n.corporateFieldMobileMobile,
                        Icons.phone_android_rounded,
                        vm.editMobileController,
                        inputType: TextInputType.phone,
                      ),
                      _editField(l10n.corporateFieldTaxId, Icons.receipt_long_rounded, vm.editTaxIdController),
                      const SizedBox(height: 4),
                      // Status dropdown with translated labels
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: DropdownButtonFormField<String>(
                          value: ['pending', 'active', 'rejected'].contains(vm.editStatus)
                              ? vm.editStatus
                              : 'active',
                          decoration: InputDecoration(
                            labelText: l10n.corporateFieldStatus,
                            prefixIcon: const Icon(Icons.toggle_on_rounded, color: AppColors.secondaryLight, size: 20),
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          items: [
                            DropdownMenuItem(value: 'pending', child: Text(l10n.corporateStatusPending)),
                            DropdownMenuItem(value: 'active',  child: Text(l10n.corporateStatusActive)),
                            DropdownMenuItem(value: 'rejected', child: Text(l10n.corporateStatusRejected)),
                          ],
                          onChanged: (v) { if (v != null) vm.setEditStatus(v); },
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.secondaryLight),
                        ),
                      ),
                      // Branch selector header
                      Row(
                        children: [
                          const Icon(Icons.store_mall_directory_rounded, size: 18, color: AppColors.secondaryLight),
                          const SizedBox(width: 8),
                          Text(
                            l10n.corporateSelectBranches,
                            style: const TextStyle(
                              color: AppColors.secondaryLight,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              l10n.corporateSelectedCount(vm.editSelectedBranchIds.length),
                              style: const TextStyle(
                                color: AppColors.secondaryLight,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (vm.branches.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            l10n.corporateNoBranches,
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        )
                      else
                        Container(
                          constraints: const BoxConstraints(maxHeight: 180),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FD),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.withOpacity(0.15)),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: vm.branches.length,
                            itemBuilder: (ctx, i) {
                              final branch = vm.branches[i];
                              final isSelected = vm.editSelectedBranchIds.contains(branch.id);
                              return CheckboxListTile(
                                value: isSelected,
                                activeColor: AppColors.primaryLight,
                                controlAffinity: ListTileControlAffinity.leading,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                title: Text(
                                  branch.name,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                                subtitle: branch.location.isEmpty
                                    ? null
                                    : Text(branch.location, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                onChanged: (_) => vm.toggleEditBranchSelection(branch.id),
                              );
                            },
                          ),
                        ),
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
                  onPressed: vm.isActionLoading ? null : () => vm.submitEditCorporateForm(context),
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
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: AppColors.secondaryLight, strokeWidth: 2),
                  )
                      : Text(
                    l10n.corporateSaveChanges,
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
        ),
      ),
    );
  }

  Widget _editField(
      String label,
      IconData icon,
      TextEditingController controller, {
        TextInputType inputType = TextInputType.text,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
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
}