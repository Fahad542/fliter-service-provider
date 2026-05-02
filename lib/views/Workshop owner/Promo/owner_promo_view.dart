import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/owner_app_bar.dart';
import 'owner_promo_view_model.dart';
import '../../../../models/workshop_owner_models.dart';
import 'package:intl/intl.dart';

class OwnerPromoView extends StatefulWidget {
  const OwnerPromoView({super.key});

  @override
  State<OwnerPromoView> createState() => _OwnerPromoViewState();
}

class _OwnerPromoViewState extends State<OwnerPromoView> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<OwnerPromoViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          appBar: OwnerAppBar(
            title: l10n.promoTitle,
            onMenuPressed: () => Scaffold.of(context).openDrawer(),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              vm.setEditPromoCode(null);
              _showAddPromoSheet(context);
            },
            backgroundColor: AppColors.secondaryLight,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: Text(
              l10n.promoNewButton,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          body: vm.isLoading && vm.promoCodes.isEmpty
              ? const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryLight,
            ),
          )
              : _buildPromoList(context, l10n, vm),
        );
      },
    );
  }

  // ── Promo list ───────────────────────────────────────────────────────────────

  Widget _buildPromoList(
      BuildContext context,
      AppLocalizations l10n,
      OwnerPromoViewModel vm,
      ) {
    if (vm.promoCodes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_offer_rounded,
              size: 80,
              color: Colors.grey.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.promoNoCodesFound,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: vm.promoCodes.length,
      itemBuilder: (context, index) {
        final p = vm.promoCodes[index];

        bool isExpired = false;
        try {
          if (DateTime.parse(p.validTo).isBefore(DateTime.now())) {
            isExpired = true;
          }
        } catch (_) {}

        final activeColor =
        (p.isActive && !isExpired) ? Colors.green : Colors.grey;

        // Discount unit — translated at render time so locale switch re-runs.
        final unit = p.discountType == 'percent'
            ? l10n.promoUnitPercent
            : l10n.promoUnitSar;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: activeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.local_offer_rounded,
                          color: activeColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // p.code is a user-defined code from the DB — not translated.
                          Text(
                            p.code,
                            style: AppTextStyles.h2.copyWith(
                              fontSize: 16,
                              color: AppColors.secondaryLight,
                            ),
                          ),
                          const SizedBox(height: 2),
                          // Discount label assembled from l10n values at render time.
                          Text(
                            l10n.promoDiscountOff(
                              p.discountValue.toString(),
                              unit,
                            ),
                            style: TextStyle(
                              color: activeColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  PopupMenuButton<String>(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 8,
                    offset: const Offset(0, 40),
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        vm.setEditPromoCode(p);
                        _showAddPromoSheet(context);
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(context, vm, p);
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
                                color:
                                AppColors.primaryLight.withOpacity(0.1),
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
                              l10n.promoMenuEdit,
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
                                color:
                                AppColors.primaryLight.withOpacity(0.1),
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
                              l10n.promoMenuDelete,
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
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStat(
                    l10n.promoStatUsage,
                    '${p.usageCount} / ${p.usageLimit}',
                  ),
                  _buildStat(
                    l10n.promoStatMinOrder,
                    l10n.promoMinOrderAmount(
                        p.minOrderAmount.toInt().toString()),
                  ),
                  _buildStat(
                    l10n.promoStatValidTill,
                    _formatDate(p.validTo),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  /// Formats an ISO date string.
  /// Uses the current locale so dates render correctly for AR/EN.
  String _formatDate(String isoString) {
    try {
      final d = DateTime.parse(isoString);
      // intl respects the locale set via Localizations.localeOf — no extra work needed.
      return DateFormat('MMM d, yyyy').format(d);
    } catch (_) {
      return isoString.split('T').first;
    }
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 12,
            color: AppColors.secondaryLight,
          ),
        ),
      ],
    );
  }

  // ── Delete confirmation dialog ────────────────────────────────────────────────

  void _showDeleteConfirmation(
      BuildContext context,
      OwnerPromoViewModel vm,
      PromoCode p,
      ) {
    // Capture l10n and parentContext before the async gap.
    final l10n = AppLocalizations.of(context)!;
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
              l10n.promoDeleteConfirmTitle,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          // p.code is a proper name from the DB — used as-is inside the
          // translated sentence body.
          l10n.promoDeleteConfirmBody(p.code),
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    l10n.promoDeleteCancel,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    vm.deletePromoCode(parentContext, p.id);
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
                    l10n.promoDeleteConfirm,
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

  // ── Bottom sheet launcher ────────────────────────────────────────────────────

  void _showAddPromoSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => ChangeNotifierProvider.value(
        value: context.read<OwnerPromoViewModel>(),
        child: const _AddPromoSheet(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _AddPromoSheet extends StatefulWidget {
  const _AddPromoSheet();

  @override
  State<_AddPromoSheet> createState() => _AddPromoSheetState();
}

class _AddPromoSheetState extends State<_AddPromoSheet> {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OwnerPromoViewModel>();
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
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
          Flexible(
            child: SingleChildScrollView(
              padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sheet title — translated at build time.
                  Text(
                    vm.isEditing
                        ? l10n.promoSheetUpdateTitle
                        : l10n.promoSheetCreateTitle,
                    style: AppTextStyles.h2.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    vm.isEditing
                        ? l10n.promoSheetUpdateSubtitle
                        : l10n.promoSheetCreateSubtitle,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  _buildTextField(
                    l10n.promoFieldCode,
                    Icons.title_rounded,
                    vm.codeController,
                  ),

                  // Discount type selector — labels translated at build time.
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => vm.setDiscountType('fixed'),
                            child: Container(
                              padding:
                              const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: vm.discountType == 'fixed'
                                    ? AppColors.primaryLight
                                    : Colors.grey.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  l10n.promoTypeFixed,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => vm.setDiscountType('percent'),
                            child: Container(
                              padding:
                              const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: vm.discountType == 'percent'
                                    ? AppColors.primaryLight
                                    : Colors.grey.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  l10n.promoTypePercent,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  _buildTextField(
                    l10n.promoFieldDiscountValue,
                    Icons.money_off_rounded,
                    vm.discountValueController,
                    isNumber: true,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          l10n.promoFieldUsageLimit,
                          Icons.repeat_rounded,
                          vm.usageLimitController,
                          isNumber: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          l10n.promoFieldMinOrder,
                          Icons.shopping_basket_rounded,
                          vm.minOrderAmountController,
                          isNumber: true,
                        ),
                      ),
                    ],
                  ),

                  _buildTextField(
                    l10n.promoFieldDescription,
                    Icons.description_rounded,
                    vm.descriptionController,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: _buildDatePicker(
                          l10n.promoFieldValidFrom,
                          Icons.calendar_today_rounded,
                          vm.validFromController,
                          context,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDatePicker(
                          l10n.promoFieldValidTo,
                          Icons.event_rounded,
                          vm.validToController,
                          context,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Submit button
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
                  : () => vm.submitPromoCode(context),
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
                // Button label translated at build time.
                vm.isEditing
                    ? l10n.promoSubmitUpdate
                    : l10n.promoSubmitCreate,
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

  // ── Field builders ───────────────────────────────────────────────────────────

  Widget _buildTextField(
      String label,
      IconData icon,
      TextEditingController controller, {
        bool isNumber = false,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType:
        isNumber ? TextInputType.number : TextInputType.text,
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
          labelStyle: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildDatePicker(
      String label,
      IconData icon,
      TextEditingController controller,
      BuildContext context,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (date != null) {
            controller.text = date.toIso8601String().split('T').first;
          }
        },
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
          labelStyle: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}