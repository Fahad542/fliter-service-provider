import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/toast_service.dart';
import '../Home Screen/pos_view_model.dart';
import '../../../models/petty_cash_model.dart';
import '../../../models/expense_category_model.dart'; // Added
import '../../../models/cashier_expense_models.dart';
import '../../../widgets/pos_widgets.dart';
import '../../../widgets/pos_shell_rail_layout.dart';
import '../../../utils/pos_shell_scaffold.dart' show PosShellScaffoldRegistry;

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
  Locale? _lastLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    if (_lastLocale != locale) {
      _lastLocale = locale;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<PettyCashViewModel>().translateApiDataForLocale(locale);
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    if (!mounted) return;
    setState(() {});
    final vm = context.read<PettyCashViewModel>();
    vm.setIsRequestingFunds(_tabController.index == 1);
    if (_tabController.index == 2) {
      vm.fetchExpenseHistory(refresh: true);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ToastService.showError(context, context.read<PettyCashViewModel>().validationMessage(AppLocalizations.of(context)!, message));
  }

  Widget _buildTabContent(PettyCashViewModel vm, bool isTablet) {
    switch (_tabController.index) {
      case 0:
        return _buildExpenseForm(vm, isTablet);
      case 1:
        return vm.showPendingRequestStatus &&
            vm.fundRequests.any((r) => r.status == PettyCashStatus.pending)
            ? _buildPendingStatusCard(
          vm.fundRequests.lastWhere((r) => r.status == PettyCashStatus.pending),
          isTablet,
        )
            : _buildRequestForm(vm, isTablet);
      case 2:
        return _buildExpenseHistoryTab(vm, isTablet);
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final vm = Provider.of<PettyCashViewModel>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      // Parent [PosShell] Scaffold already resizes for the keyboard; inner resize
      // causes double inset, huge gap, and content jumping to the top.
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PosScreenAppBar(
        title: l10n.posPettyCashTitle,
        showBackButton: false,
        showHamburger: true,
        onMenuPressed: () =>
            PosShellScaffoldRegistry.openDrawer(),
      ),
      body: wrapPosShellRailBody(
        context,
        vm.isPettyCashLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            isTablet ? 16 : 8,
            isTablet ? 16 : 8,
            isTablet ? 16 : 8,
            isTablet ? 16 : 8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ... (rest of children)
              // Balance Header
              _buildBalanceCard(vm, isTablet),
              const SizedBox(height: 16), // Reduced from 24

              if (vm.isLowPettyCashBalance) ...[
                _buildLowBalanceWarning(vm, isTablet),
                const SizedBox(height: 24),
              ],

              // Tab bar — same white pill style as owner Approvals / Accounting.
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade200.withValues(alpha: 0.85),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: AppColors.secondaryLight,
                  unselectedLabelColor: const Color(0xFF9CA3AF),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: isTablet ? 13 : 12.5,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 11.5 : 11,
                  ),
                  overlayColor: MaterialStateProperty.resolveWith(
                        (states) {
                      if (states.contains(MaterialState.pressed)) {
                        return AppColors.primaryLight.withValues(alpha: 0.12);
                      }
                      return AppColors.primaryLight.withValues(alpha: 0.06);
                    },
                  ),
                  tabs: [
                    Tab(text: l10n.posPettyCashExpenseTab),
                    Tab(text: l10n.posPettyCashFundTab),
                    Tab(text: l10n.posPettyCashHistoryTab),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildTabContent(vm, isTablet),
              ),
              const SizedBox(height: 24), // Reduced from 40
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(PettyCashViewModel vm, bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 18 : 12),
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
              size: isTablet ? 100 : 80,
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
                      AppLocalizations.of(context)!.posPettyCashSecureWallet,
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
                AppLocalizations.of(context)!.posPettyCashAvailable,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: isTablet ? 13 : 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    AppLocalizations.of(context)!.posCommonSar,
                    style: TextStyle(
                      color: AppColors.primaryLight,
                      fontSize: isTablet ? 18 : 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    vm.pettyCashBalance.toStringAsFixed(2),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 26 : 22,
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

  Widget _buildLowBalanceWarning(PettyCashViewModel vm, bool isTablet) {
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
              AppLocalizations.of(context)!.posPettyCashLowBalanceMessage,
              style: TextStyle(
                color: Colors.red.shade800,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              _tabController.animateTo(1);
              vm.setIsRequestingFunds(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: Text(
              AppLocalizations.of(context)!.posPettyCashRequestFund,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
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
        _buildSectionTitle(AppLocalizations.of(context)!.posPettyCashExpenseDetails, Icons.receipt_long_outlined),
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel(AppLocalizations.of(context)!.posPettyCashAmountSar),
                        _buildTextField(
                          vm.amountController,
                          '0.00',
                          Icons.attach_money,
                          TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: isTablet ? 16 : 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel(AppLocalizations.of(context)!.posPettyCashExpenseCategory),
                        _buildDropdown(vm),
                      ],
                    ),
                  ),
                ],
              ),
              if (vm.selectedCategory?.requiresEmployeeSelection == true) ...[
                SizedBox(height: isTablet ? 16 : 14),
                _buildLabel(AppLocalizations.of(context)!.posPettyCashEmployeeSalaryAdvance),
                if (vm.branchEmployeesLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))),
                  )
                else
                  _buildEmployeeDropdown(vm),
              ],
              const SizedBox(height: 16),

              _buildLabel(AppLocalizations.of(context)!.posPettyCashDescriptionNotes),
              _buildTextField(vm.notesController, AppLocalizations.of(context)!.posPettyCashEnterDetailsHint, Icons.notes, TextInputType.text, maxLines: 2),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _buildSectionTitle(AppLocalizations.of(context)!.posPettyCashProofOfExpense, Icons.camera_alt_outlined),
        const SizedBox(height: 12),
        _buildImagePicker(vm),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: isTablet ? 52 : 42,
          child: ElevatedButton(
            onPressed: vm.isExpenseSubmitting ? null : () {
              vm.submitExpenseAction((error) {
                if (mounted) _showError(error);
              }).then((success) {
                if (success && mounted) {
                  ToastService.showSuccess(context, AppLocalizations.of(context)!.posPettyCashExpenseSubmitted);
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryLight,
              disabledBackgroundColor: AppColors.secondaryLight.withOpacity(0.7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 3,
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
                const Icon(Icons.check_circle_outline, size: 20),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.posPettyCashSubmitExpense,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: isTablet ? 15.5 : 14,
                    letterSpacing: 0.2,
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
        _buildSectionTitle(AppLocalizations.of(context)!.posPettyCashFundRequest, Icons.add_circle_outline_rounded),
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
              _buildLabel(AppLocalizations.of(context)!.posPettyCashRequestedAmountSar),
              _buildTextField(vm.requestAmountController, '0.00', Icons.add_card, TextInputType.number),
              const SizedBox(height: 16),

              _buildLabel(AppLocalizations.of(context)!.posPettyCashReasonForRequest),
              _buildTextField(vm.reasonController, AppLocalizations.of(context)!.posPettyCashReasonHint, Icons.help_outline, TextInputType.text, maxLines: 4),
            ],
          ),
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: isTablet ? 56 : 44,
          child: ElevatedButton(
            onPressed: vm.isRequestSubmitting ? null : () {
              vm.submitRequestAction(
                    (error) { if (mounted) _showError(error); },
                    () { if (mounted) ToastService.showSuccess(context, AppLocalizations.of(context)!.posPettyCashFundRequestSubmitted); },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryLight,
              disabledBackgroundColor: AppColors.secondaryLight.withOpacity(0.7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 3,
              shadowColor: AppColors.secondaryLight.withOpacity(0.4),
            ),
            child: vm.isRequestSubmitting
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
                Icon(Icons.send_rounded, size: isTablet ? 21 : 18),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.posPettyCashSubmitRequest,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: isTablet ? 15.5 : 14,
                    letterSpacing: 0.2,
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
    final kb = MediaQuery.viewInsetsOf(context).bottom;
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
        scrollPadding: EdgeInsets.fromLTRB(12, 12, 12, kb + 100),
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
          hint: Text(AppLocalizations.of(context)!.posPettyCashSelectCategory, style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.secondaryLight.withOpacity(0.5)),
          style: const TextStyle(color: AppColors.secondaryLight, fontSize: 14, fontWeight: FontWeight.w600),
          items: vm.expenseCategories.map((cat) => DropdownMenuItem(value: cat, child: Text(vm.localizedText(cat.name)))).toList(),
          onChanged: (val) => vm.setCategory(val),
        ),
      ),
    );
  }

  Widget _buildEmployeeDropdown(PettyCashViewModel vm) {
    BranchEmployee? value;
    final sel = vm.selectedBranchEmployee;
    if (sel != null && vm.branchEmployees.any((e) => e.id == sel.id)) {
      value = vm.branchEmployees.firstWhere((e) => e.id == sel.id);
    }
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
        child: DropdownButton<BranchEmployee>(
          value: value,
          hint: Text(
            vm.branchEmployees.isEmpty ? AppLocalizations.of(context)!.posPettyCashNoEmployees : AppLocalizations.of(context)!.posPettyCashSelectEmployee,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.secondaryLight.withOpacity(0.5)),
          style: const TextStyle(color: AppColors.secondaryLight, fontSize: 14, fontWeight: FontWeight.w600),
          items: vm.branchEmployees
              .map(
                (e) => DropdownMenuItem<BranchEmployee>(
              value: e,
              child: Text(e.name.isNotEmpty ? vm.localizedText(e.name) : e.id),
            ),
          )
              .toList(),
          onChanged: vm.branchEmployees.isEmpty ? null : (e) => vm.setBranchEmployee(e),
        ),
      ),
    );
  }

  String _historyStatusLabel(String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'all':
        return l10n.posCommonAll;
      case 'pending':
        return l10n.posCommonPending;
      case 'approved':
        return l10n.posCommonApproved;
      case 'rejected':
        return l10n.posCommonRejected;
      default:
        return key;
    }
  }

  Future<void> _pickHistoryFromDate(PettyCashViewModel vm) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: vm.expenseHistoryFromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    vm.setExpenseHistoryDateRange(
      from: picked,
      to: vm.expenseHistoryToDate,
    );
  }

  Future<void> _pickHistoryToDate(PettyCashViewModel vm) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: vm.expenseHistoryToDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    vm.setExpenseHistoryDateRange(
      from: vm.expenseHistoryFromDate,
      to: picked,
    );
  }

  Widget _buildHistoryFilters(PettyCashViewModel vm, bool isTablet) {
    String fmt(DateTime? d) =>
        d == null ? AppLocalizations.of(context)!.posPettyCashSelectDate : DateFormat('yyyy-MM-dd').format(d);

    final dateLabelStyle = TextStyle(
      fontSize: isTablet ? 12 : 10.5,
      color: AppColors.secondaryLight.withValues(alpha: 0.72),
      fontWeight: FontWeight.w600,
    );
    final iconColor = AppColors.secondaryLight.withValues(alpha: 0.55);

    Widget dateField({
      required String prefix,
      required DateTime? value,
      required VoidCallback onTap,
    }) {
      return OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(
            vertical: isTablet ? 12 : 10,
            horizontal: 8,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: isTablet ? 18 : 16,
              color: iconColor,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '$prefix ${fmt(value)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: dateLabelStyle,
              ),
            ),
          ],
        ),
      );
    }

    final hasFilters = vm.expenseHistoryFromDate != null ||
        vm.expenseHistoryToDate != null ||
        vm.expenseHistoryCategoryId != null ||
        vm.expenseHistoryStatusFilter != 'all';

    final filterDropdownTextStyle = TextStyle(
      fontSize: isTablet ? 13 : 11,
      color: AppColors.secondaryLight.withValues(alpha: 0.58),
    );

    Widget filterDropdown({
      required Widget child,
    }) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 10 : 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: DropdownButtonHideUnderline(child: child),
      );
    }

    const statusKeys = ['all', 'pending', 'approved', 'rejected'];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 18,
          child: dateField(
            prefix: AppLocalizations.of(context)!.posPettyCashFrom,
            value: vm.expenseHistoryFromDate,
            onTap: () => _pickHistoryFromDate(vm),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 18,
          child: dateField(
            prefix: AppLocalizations.of(context)!.posPettyCashTo,
            value: vm.expenseHistoryToDate,
            onTap: () => _pickHistoryToDate(vm),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 22,
          child: filterDropdown(
            child: DropdownButton<String?>(
              value: vm.expenseHistoryCategoryId,
              isExpanded: true,
              style: filterDropdownTextStyle,
              hint: Text(
                AppLocalizations.of(context)!.posPettyCashAllCategories,
                style: filterDropdownTextStyle,
              ),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(AppLocalizations.of(context)!.posPettyCashAllCategories, style: filterDropdownTextStyle),
                ),
                ...vm.expenseCategories.map(
                      (c) => DropdownMenuItem<String?>(
                    value: c.id,
                    child: Text(
                      vm.localizedText(c.name),
                      style: filterDropdownTextStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
              onChanged: vm.setExpenseHistoryCategoryId,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 18,
          child: filterDropdown(
            child: DropdownButton<String>(
              value: vm.expenseHistoryStatusFilter,
              isExpanded: true,
              style: filterDropdownTextStyle,
              items: [
                for (final k in statusKeys)
                  DropdownMenuItem<String>(
                    value: k,
                    child: Text(
                      _historyStatusLabel(k),
                      style: filterDropdownTextStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (v) {
                if (v != null) vm.setExpenseHistoryStatusFilter(v);
              },
            ),
          ),
        ),
        if (hasFilters) ...[
          const SizedBox(width: 4),
          TextButton(
            onPressed: vm.clearExpenseHistoryFilters,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              AppLocalizations.of(context)!.posPettyCashReset,
              style: TextStyle(
                fontSize: isTablet ? 13 : 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryLight,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildExpenseHistoryTab(PettyCashViewModel vm, bool isTablet) {
    final df = DateFormat('dd MMM yyyy, HH:mm');
    final listHeight = math.min(520.0, MediaQuery.sizeOf(context).height * 0.52);

    return Column(
      key: const ValueKey('expense_history_tab'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(AppLocalizations.of(context)!.posPettyCashHistoryTitle, Icons.history_rounded),
        const SizedBox(height: 14),
        _buildHistoryFilters(vm, isTablet),
        const SizedBox(height: 16),
        SizedBox(
          height: listHeight,
          child: vm.expenseHistoryLoading && vm.expenseHistory.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : vm.expenseHistory.isEmpty
              ? RefreshIndicator(
            onRefresh: () => vm.fetchExpenseHistory(refresh: true),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: listHeight - 48,
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.posPettyCashNoHistory,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                ),
              ],
            ),
          )
              : RefreshIndicator(
            onRefresh: () => vm.fetchExpenseHistory(refresh: true),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _expenseHistoryListItemCount(vm, isTablet),
              itemBuilder: (ctx, i) {
                if (_expenseHistoryIsLoadMoreRow(vm, i, isTablet)) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: TextButton(
                        onPressed: vm.expenseHistoryLoading
                            ? null
                            : () => vm.fetchExpenseHistory(refresh: false),
                        child: vm.expenseHistoryLoading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : Text(AppLocalizations.of(context)!.posPettyCashLoadMore),
                      ),
                    ),
                  );
                }
                if (isTablet) {
                  final base = i * 3;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildHistorySlot(vm, base, df),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildHistorySlot(vm, base + 1, df),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildHistorySlot(vm, base + 2, df),
                        ),
                      ],
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildHistoryRow(vm, vm.expenseHistory[i], df),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  int _expenseHistoryListItemCount(PettyCashViewModel vm, bool isTablet) {
    final n = vm.expenseHistory.length;
    final more = vm.expenseHistoryHasMore ? 1 : 0;
    if (!isTablet) return n + more;
    final rows = (n + 2) ~/ 3;
    return rows + more;
  }

  bool _expenseHistoryIsLoadMoreRow(
      PettyCashViewModel vm,
      int index,
      bool isTablet,
      ) {
    if (!vm.expenseHistoryHasMore) return false;
    final n = vm.expenseHistory.length;
    if (!isTablet) return index >= n;
    final rows = (n + 2) ~/ 3;
    return index >= rows;
  }

  Widget _buildHistorySlot(
      PettyCashViewModel vm,
      int index,
      DateFormat df,
      ) {
    if (index < 0 || index >= vm.expenseHistory.length) {
      return const SizedBox.shrink();
    }
    return _buildHistoryRow(vm, vm.expenseHistory[index], df);
  }

  Widget _buildHistoryRow(PettyCashViewModel vm, CashierExpenseHistoryEntry e, DateFormat df) {
    final st = e.status.toLowerCase();
    Color c = Colors.orange;
    if (st == 'approved') c = Colors.green;
    if (st == 'rejected') c = Colors.red;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: c.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  st.toUpperCase(),
                  style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  vm.localizedText(e.kind.replaceAll('_', ' ')).toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${AppLocalizations.of(context)!.posCommonSar} ${e.amount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          if ((e.category ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              vm.localizedText(e.category!),
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade800),
            ),
          ],
          if ((e.employeeName ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context)!.posPettyCashEmployeePrefix(vm.localizedText(e.employeeName!)),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ],
          if ((e.description ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              vm.localizedText(e.description!),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
          if (e.createdAt != null) ...[
            const SizedBox(height: 6),
            Text(
              df.format(e.createdAt!.toLocal()),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
          if ((e.rejectionReason ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              AppLocalizations.of(context)!.posPettyCashRejectionPrefix(vm.localizedText(e.rejectionReason!)),
              style: TextStyle(fontSize: 12, color: Colors.red.shade800),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImagePicker(PettyCashViewModel vm) {
    return GestureDetector(
      onTap: vm.pickImage,
      child: Container(
        height: 80,
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
                  AppLocalizations.of(context)!.posPettyCashTapUploadReceipt,
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
              _buildSectionTitle(AppLocalizations.of(context)!.posPettyCashRequestStatus, Icons.info_outline),
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
                      AppLocalizations.of(context)!.posPettyCashPendingUpper,
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
          _buildInfoRow(Icons.account_balance_wallet_outlined, AppLocalizations.of(context)!.posPettyCashRequestedAmount, '${AppLocalizations.of(context)!.posCommonSar} ${request.amount.toStringAsFixed(2)}'),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.help_outline, AppLocalizations.of(context)!.posPettyCashReason, request.reason),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.calendar_today_outlined, AppLocalizations.of(context)!.posPettyCashRequestDate, '${request.date.day}/${request.date.month}/${request.date.year}'),
          const SizedBox(height: 32),
          Text(
            AppLocalizations.of(context)!.posPettyCashPendingReviewMessage,
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
              child: Text(
                AppLocalizations.of(context)!.posPettyCashSubmitNewRequest,
                style: const TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.bold),
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