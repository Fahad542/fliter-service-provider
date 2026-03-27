import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text_styles.dart';
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
    return Consumer<OwnerPromoViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          appBar: OwnerAppBar(
            title: 'Promo Codes',
            onMenuPressed: () => Scaffold.of(context).openDrawer(),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              vm.setEditPromoCode(null);
              _showAddPromoSheet(context);
            },
            backgroundColor: AppColors.secondaryLight,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text('New Promo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          body: vm.isLoading && vm.promoCodes.isEmpty
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryLight))
              : _buildPromoList(vm),
        );
      },
    );
  }

  Widget _buildPromoList(OwnerPromoViewModel vm) {
    if (vm.promoCodes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_offer_rounded, size: 80, color: Colors.grey.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text('No promo codes found', style: TextStyle(color: Colors.grey, fontSize: 16)),
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
          final validToDateTime = DateTime.parse(p.validTo);
          if (validToDateTime.isBefore(DateTime.now())) {
            isExpired = true;
          }
        } catch (_) {}

        final activeColor = (p.isActive && !isExpired) ? Colors.green : Colors.grey;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.withOpacity(0.08)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
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
                        decoration: BoxDecoration(color: activeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: Icon(Icons.local_offer_rounded, color: activeColor, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.code, style: AppTextStyles.h2.copyWith(fontSize: 16, color: AppColors.secondaryLight)),
                          const SizedBox(height: 2),
                          Text('${p.discountValue} ${p.discountType == 'percent' ? '%' : 'SAR'} OFF', style: TextStyle(color: activeColor, fontSize: 13, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ],
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        vm.setEditPromoCode(p);
                        _showAddPromoSheet(context);
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(context, vm, p);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_rounded, size: 20, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_rounded, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                    icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade400),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStat('Usage', '${p.usageCount} / ${p.usageLimit}'),
                  _buildStat('Min Order', 'SAR ${p.minOrderAmount.toInt()}'),
                  _buildStat('Valid Till', _formatDate(p.validTo)),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  String _formatDate(String isoString) {
    try {
      final d = DateTime.parse(isoString);
      return DateFormat('MMM d, yyyy').format(d);
    } catch (_) {
      return isoString.split('T').first;
    }
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.secondaryLight)),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, OwnerPromoViewModel vm, PromoCode p) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Promo Code'),
        content: Text('Are you sure you want to delete "${p.code}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              vm.deletePromoCode(context, p.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

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

class _AddPromoSheet extends StatefulWidget {
  const _AddPromoSheet();

  @override
  State<_AddPromoSheet> createState() => _AddPromoSheetState();
}

class _AddPromoSheetState extends State<_AddPromoSheet> {

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OwnerPromoViewModel>();

    return Container(
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
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(vm.isEditing ? 'Update Promo Code' : 'Create Promo Code', style: AppTextStyles.h2.copyWith(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(
                    vm.isEditing ? 'Modify existing promo code details.' : 'Configure a new discount code for customers.',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  
                  _buildTextField('Promo Code (e.g., SUMMER20)', Icons.title_rounded, vm.codeController),
                  
                  // Discount Type Selector
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => vm.setDiscountType('fixed'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: vm.discountType == 'fixed' ? AppColors.primaryLight : Colors.grey.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(child: Text('Fixed Amount', style: TextStyle(fontWeight: FontWeight.w800))),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => vm.setDiscountType('percent'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: vm.discountType == 'percent' ? AppColors.primaryLight : Colors.grey.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(child: Text('Percentage (%)', style: TextStyle(fontWeight: FontWeight.w800))),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  _buildTextField('Discount Value', Icons.money_off_rounded, vm.discountValueController, isNumber: true),
                  
                  Row(
                    children: [
                      Expanded(child: _buildTextField('Usage Limit', Icons.repeat_rounded, vm.usageLimitController, isNumber: true)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField('Min Order (SAR)', Icons.shopping_basket_rounded, vm.minOrderAmountController, isNumber: true)),
                    ],
                  ),
                  
                  _buildTextField('Description', Icons.description_rounded, vm.descriptionController),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildDatePicker('Valid From', Icons.calendar_today_rounded, vm.validFromController, context),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDatePicker('Valid To', Icons.event_rounded, vm.validToController, context),
                      ),
                    ],
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
              onPressed: vm.isLoading ? null : () => vm.submitPromoCode(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  disabledBackgroundColor: AppColors.primaryLight,
                  foregroundColor: AppColors.secondaryLight,
                  disabledForegroundColor: AppColors.secondaryLight,
                  minimumSize: const Size.fromHeight(56),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: vm.isLoading
                  ? const CircularProgressIndicator(color: AppColors.primaryLight)
                  : Text(
                      vm.isEditing ? 'Update Promo' : 'Create Promo',
                      style: const TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {bool isNumber = false}) {
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

  Widget _buildDatePicker(String label, IconData icon, TextEditingController controller, BuildContext context) {
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
