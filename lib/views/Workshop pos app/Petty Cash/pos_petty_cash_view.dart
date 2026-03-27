import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/toast_service.dart';
import '../Home Screen/pos_view_model.dart';
import '../../../models/petty_cash_model.dart';
import '../../../models/expense_category_model.dart'; // Added
import '../../../widgets/pos_widgets.dart';

import '../More Tab/pos_more_view.dart'; // Added
import '../Promo/promo_code_dialog.dart'; // Added
import 'petty_cash_view_model.dart';




class PosPettyCashView extends StatefulWidget {
  const PosPettyCashView({super.key});

  @override
  State<PosPettyCashView> createState() => _PosPettyCashViewState();
}

class _PosPettyCashViewState extends State<PosPettyCashView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        context.read<PettyCashViewModel>().setIsRequestingFunds(_tabController.index == 1);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ToastService.showError(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final vm = Provider.of<PettyCashViewModel>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PosScreenAppBar(
        title: 'Petty Cash',
        showBackButton: false,
        showHamburger: true,
        onMenuPressed: () => Scaffold.of(context).openDrawer(),
      ),
      body: vm.isPettyCashLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 20 : 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ... (rest of children)
              // Balance Header
              _buildBalanceCard(vm, isTablet),
              const SizedBox(height: 16), // Reduced from 24

              if (vm.isLowPettyCashBalance) ...[
                _buildLowBalanceWarning(isTablet),
                const SizedBox(height: 24),
              ],

              // Modern Segmented Control for Tabs (Matching Add Customer Page)
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: AppColors.secondaryLight,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  tabs: const [
                    Tab(text: 'Submit Expense'),
                    Tab(text: 'Request Fund'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: vm.isRequestingFunds 
                  ? (vm.showPendingRequestStatus && vm.fundRequests.any((r) => r.status == PettyCashStatus.pending)
                      ? _buildPendingStatusCard(vm.fundRequests.lastWhere((r) => r.status == PettyCashStatus.pending), isTablet)
                      : _buildRequestForm(vm, isTablet))
                  : _buildExpenseForm(vm, isTablet),
              ),
              const SizedBox(height: 40), // Bottom padding for content
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(PettyCashViewModel vm, bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondaryLight,
            AppColors.secondaryLight.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryLight.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.account_balance_wallet_rounded,
              size: isTablet ? 120 : 100,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: AppColors.primaryLight,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'SECURE WALLET',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Available Petty Cash',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: isTablet ? 15 : 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    'SAR',
                    style: TextStyle(
                      color: AppColors.primaryLight,
                      fontSize: isTablet ? 20 : 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    vm.pettyCashBalance.toStringAsFixed(2),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 36 : 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLowBalanceWarning(bool isTablet) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Petty cash balance is low. Please request fund.',
              style: TextStyle(
                color: Colors.red.shade800, 
                fontWeight: FontWeight.w700, 
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildExpenseForm(PettyCashViewModel vm, bool isTablet) {
    return Column(
      key: const ValueKey('expense_form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Expense Details', Icons.receipt_long_outlined),
        const SizedBox(height: 12),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Amount (SAR)'),
              _buildTextField(vm.amountController, '0.00', Icons.attach_money, TextInputType.number),
              const SizedBox(height: 16),

              _buildLabel('Expense Category'),
              _buildDropdown(vm),
              const SizedBox(height: 16),

              _buildLabel('Description / Notes'),
              _buildTextField(vm.notesController, 'Enter details...', Icons.notes, TextInputType.text, maxLines: 2),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _buildSectionTitle('Proof of Expense', Icons.camera_alt_outlined),
        const SizedBox(height: 12),
        _buildImagePicker(vm),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: vm.isExpenseSubmitting ? null : () {
              vm.submitExpenseAction((error) {
                if (mounted) _showError(error);
              }).then((success) {
                if (success && mounted) {
                  ToastService.showSuccess(context, 'Expense submitted – pending approval');
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryLight,
              disabledBackgroundColor: AppColors.secondaryLight.withOpacity(0.7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              shadowColor: AppColors.secondaryLight.withOpacity(0.4),
            ),
            child: vm.isExpenseSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'Submit Expense',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequestForm(PettyCashViewModel vm, bool isTablet) {
    return Column(
      key: const ValueKey('request_form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Fund Request', Icons.add_circle_outline_rounded),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Requested Amount (SAR)'),
              _buildTextField(vm.requestAmountController, '0.00', Icons.add_card, TextInputType.number),
              const SizedBox(height: 16),

              _buildLabel('Reason for Request'),
              _buildTextField(vm.reasonController, 'Explain why you need more funds...', Icons.help_outline, TextInputType.text, maxLines: 4),
            ],
          ),
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              vm.submitRequestAction(
                (error) { if (mounted) _showError(error); },
                () { if (mounted) ToastService.showSuccess(context, 'Fund request submitted – pending approval'); },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryLight,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              shadowColor: AppColors.secondaryLight.withOpacity(0.4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.send_rounded, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Submit Request',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, size: 18, color: AppColors.secondaryLight.withOpacity(0.7)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E2124),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade700)), // Reduced from 14
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, TextInputType type, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: type,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w400),
          prefixIcon: Icon(icon, color: AppColors.secondaryLight.withOpacity(0.4), size: 18),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), 
            borderSide: BorderSide(color: Colors.grey.shade100),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), 
            borderSide: BorderSide(color: Colors.grey.shade100),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), 
            borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDropdown(PettyCashViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ExpenseCategory>(
          value: vm.selectedCategory,
          hint: Text('Select category', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.secondaryLight.withOpacity(0.5)),
          style: const TextStyle(color: AppColors.secondaryLight, fontSize: 14, fontWeight: FontWeight.w600),
          items: vm.expenseCategories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat.name))).toList(),
          onChanged: (val) => vm.setCategory(val),
        ),
      ),
    );
  }

  Widget _buildImagePicker(PettyCashViewModel vm) {
    return GestureDetector(
      onTap: vm.pickImage,
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade300, 
            style: BorderStyle.solid,
            width: 1,
          ),
        ),
        child: vm.selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(vm.selectedImage!, fit: BoxFit.cover),
              )
            : DottedContainer(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.cloud_upload_outlined, color: AppColors.secondaryLight, size: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to upload receipt', 
                      style: TextStyle(
                        color: AppColors.secondaryLight.withOpacity(0.6), 
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      )
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPendingStatusCard(FundRequest request, bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryLight.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle('Request Status', Icons.info_outline),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time_rounded, size: 14, color: Colors.orange.shade700),
                    const SizedBox(width: 6),
                    Text(
                      'PENDING',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoRow(Icons.account_balance_wallet_outlined, 'Requested Amount', 'SAR ${request.amount.toStringAsFixed(2)}'),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.help_outline, 'Reason', request.reason),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.calendar_today_outlined, 'Request Date', '${request.date.day}/${request.date.month}/${request.date.year}'),
          const SizedBox(height: 32),
          Text(
            'Your request is currently being reviewed by administration. You will be notified once it is approved.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => context.read<PettyCashViewModel>().setShowPendingRequestStatus(false),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryLight),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Submit New Request',
                style: TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.secondaryLight.withOpacity(0.5)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label, 
                style: TextStyle(
                  color: AppColors.secondaryLight.withOpacity(0.5), 
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                )
              ),
              const SizedBox(height: 1),
              Text(
                value, 
                style: const TextStyle(
                  color: AppColors.secondaryLight,
                  fontWeight: FontWeight.w700, 
                  fontSize: 14,
                )
              ),
            ],
          ),
        ),
      ],
    );
  }
}
