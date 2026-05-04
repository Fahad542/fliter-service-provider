import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../Home Screen/pos_view_model.dart';
import 'promo_view_model.dart';

class PromoCodeDialog extends StatefulWidget {
  final bool isMainTab;
  const PromoCodeDialog({super.key, this.isMainTab = false});

  @override
  State<PromoCodeDialog> createState() => _PromoCodeDialogState();
}

class _PromoCodeDialogState extends State<PromoCodeDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final promoVm = context.read<PromoViewModel>();
        promoVm.clearPromoError();
        promoVm.fetchAvailablePromos();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _applyPromo() async {
    final posVm = context.read<PosViewModel>();
    final promoVm = context.read<PromoViewModel>();
    final code = _controller.text.trim();
    if (code.isEmpty) return;

    await promoVm.validatePromo(code, posVm, context, isMainTab: widget.isMainTab);

    if (!mounted) return;

    if (posVm.getActivePromoCode(widget.isMainTab).isNotEmpty) {
       Navigator.of(context).pop(); // Close dialog on success
    }
  }

  Future<void> _previewFromList(String code) async {
    final posVm = context.read<PosViewModel>();
    final promoVm = context.read<PromoViewModel>();
    _controller.text = code;

    await promoVm.validatePromo(code, posVm, context, isMainTab: widget.isMainTab);
  }

  void _removeAppliedPromo() {
    final posVm = context.read<PosViewModel>();
    final promoVm = context.read<PromoViewModel>();
    posVm.clearPromoCode(isMainTab: widget.isMainTab);
    promoVm.clearPromoError();
    _controller.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final promoVm = context.watch<PromoViewModel>();
    final posVm = context.watch<PosViewModel>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isPromoApplied =
        posVm.getActivePromoCode(widget.isMainTab).isNotEmpty;
    final hasPromoSelection = isPromoApplied || promoVm.validResult != null;
    final shouldLockInput = hasPromoSelection;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: SizedBox(
        width: isTablet
            ? (screenWidth * 0.70).clamp(400.0, 720.0)
            : (screenWidth - 28),
        height: isTablet ? 540 : 520,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.local_offer_outlined, color: AppColors.primaryLight),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Apply Promo Code',
                    style: AppTextStyles.h3.copyWith(fontSize: isTablet ? 22 : 20),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Select any promo code below to apply discount instantly.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.grey,
                  fontSize: isTablet ? 15 : 13,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Builder(
                  builder: (_) {
                    if (promoVm.isLoadingPromos) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (promoVm.availablePromotions.isEmpty) {
                      return Center(
                        child: Text(
                          'No promo codes available.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      );
                    }
                    return GridView.builder(
                      itemCount: promoVm.availablePromotions.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: isTablet ? 96 : 90,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemBuilder: (context, index) {
                        final promo = promoVm.availablePromotions[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: promoVm.isLoading
                              ? null
                              : () => _previewFromList(promo.code),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 1),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight.withOpacity(0.16),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      promo.code,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.secondaryLight,
                                        fontSize: isTablet ? 14 : 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        promo.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w700,
                                          fontSize: isTablet ? 15 : 13,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        promo.description,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: Colors.grey.shade600,
                                          fontSize: isTablet ? 12.5 : 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Or enter code manually',
                style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.characters,
                enabled: !shouldLockInput,
                readOnly: shouldLockInput,
                style: TextStyle(fontSize: isTablet ? 17 : 15),
                decoration: InputDecoration(
                  hintText: 'e.g. SAVE10',
                  hintStyle: TextStyle(fontSize: isTablet ? 16 : 14),
                  filled: true,
                  fillColor:
                      isPromoApplied ? Colors.grey.shade200 : Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              if (hasPromoSelection) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _removeAppliedPromo,
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.red,
                    ),
                    label: const Text(
                      'Remove Promo',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
              if (promoVm.promoErrorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  promoVm.promoErrorMessage!,
                  style: TextStyle(color: Colors.red, fontSize: isTablet ? 14 : 13, fontWeight: FontWeight.w600),
                ),
              ],
              const SizedBox(height: 14),
              // Show result ticket if valid
              if (promoVm.validResult != null && promoVm.promoErrorMessage == null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.05),
                    border: Border.all(color: Colors.green.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Text('Valid Promo Code', style: AppTextStyles.bodyMedium.copyWith(color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildResultRow('Discount:', promoVm.validResult!['message']),
                      const SizedBox(height: 6),
                      _buildResultRow('Store:', promoVm.validResult!['store']),
                      const SizedBox(height: 6),
                      _buildResultRow('Products:', promoVm.validResult!['products']),
                      const SizedBox(height: 6),
                      if (promoVm.validResult!['period'] != null)
                        _buildResultRow('Validity:', promoVm.validResult!['period']),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<PromoViewModel>().clearPromoError();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryLight,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text('Cancel', style: TextStyle(fontSize: isTablet ? 16 : 14)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (promoVm.isLoading || isPromoApplied)
                          ? null
                          : (promoVm.validResult == null
                              ? _applyPromo
                              : () {
                                  final posVm = context.read<PosViewModel>();
                                    posVm.applyPromoCode(
                                      _controller.text.trim().toUpperCase(),
                                      promoVm.validResult!['discount'],
                                      promoVm.validResult!['isPercent'],
                                      isMainTab: widget.isMainTab,
                                      promoCodeId: promoVm.validResult!['id']?.toString(),
                                    );
                                  Navigator.pop(context);
                                }),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: promoVm.isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                              promoVm.validResult == null ? 'Check Code' : 'Apply Discount',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: isTablet ? 16 : 14,
                                color: Colors.black,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 70, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13))),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
      ],
    );
  }
}
