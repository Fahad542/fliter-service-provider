import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/app_formatters.dart';
import '../Home Screen/pos_view_model.dart';
import '../../../widgets/pos_widgets.dart';
import '../More Tab/pos_more_view.dart'; // Added
import 'promo_code_dialog.dart'; // Added (same folder)
import 'promo_view_model.dart';

class PosPromoView extends StatefulWidget {
  const PosPromoView({super.key});

  @override
  State<PosPromoView> createState() => _PosPromoViewState();
}

class _PosPromoViewState extends State<PosPromoView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PromoViewModel>().clearPromoError();
    });
  }

  @override
  Widget build(BuildContext context) {
    final promoVm = Provider.of<PromoViewModel>(context);
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PosScreenAppBar(
        title: 'Promo Code',
        showBackButton: false,
        showHamburger: true,
        onMenuPressed: () => Scaffold.of(context).openDrawer(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEntrySection(isTablet),
            const SizedBox(height: 24),
            _buildSectionTitle('Available Promotions', Icons.stars_outlined),
            const SizedBox(height: 16),
            _buildPromotionCatalog(promoVm.availablePromotions, isTablet),
          ],
        ),
      ),
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

  Widget _buildEntrySection(bool isTablet) {
    final promoVm = Provider.of<PromoViewModel>(context);
    final posVm = Provider.of<PosViewModel>(context, listen: false);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Apply Promo Code', Icons.local_offer_outlined),
          const SizedBox(height: 16),
          Text(
            'Check the validity of a customer provided code.',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: promoVm.promoController,
                    textCapitalization: TextCapitalization.characters,
                    textAlign: TextAlign.left,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1),
                    inputFormatters: [EnglishNumberFormatter()],
                    decoration: InputDecoration(
                      hintText: 'e.g. SAVE10',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                      prefixIcon: const Icon(Icons.qr_code_scanner_rounded, size: 20, color: AppColors.secondaryLight),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: promoVm.isLoading ? null : () => promoVm.checkMockValidity(null, posVm, context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryLight,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    shadowColor: AppColors.secondaryLight.withOpacity(0.4),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  child: promoVm.isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Check Validity', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
          if (promoVm.promoErrorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 12),
                  Text(promoVm.promoErrorMessage!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
            ),
          ],
          if (promoVm.validResult != null) ...[
            const SizedBox(height: 24),
            _buildResultCard(promoVm.validResult!),
          ],
        ],
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> validResult) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 24),
              const SizedBox(width: 12),
              Text(
                validResult['message'],
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w800, fontSize: 17),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildResultDetail(Icons.store, 'Store: ${validResult['store']}'),
          const SizedBox(height: 8),
          _buildResultDetail(Icons.inventory_2, 'Products: ${validResult['products']}'),
          const SizedBox(height: 8),
          _buildResultDetail(Icons.calendar_today, 'Period: ${validResult['period']}'),
        ],
      ),
    );
  }

  Widget _buildResultDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.green.withOpacity(0.7)),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(color: Colors.grey.shade800, fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildPromotionCatalog(List<AvailablePromotion> promos, bool isTablet) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: promos.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 2 : 1,
        mainAxisExtent: 210, // Increased from 175 to fix overflow
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        final promo = promos[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      promo.code,
                      style: const TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      promo.isPercent ? '${promo.discount.toStringAsFixed(0)}% OFF' : 'SAR ${promo.discount.toStringAsFixed(0)} OFF',
                      style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.green, fontSize: 11),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                promo.title,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1E2124)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                promo.description,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12, height: 1.3),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    final posVm = Provider.of<PosViewModel>(context, listen: false);
                    final promoVm = Provider.of<PromoViewModel>(context, listen: false);
                    promoVm.checkMockValidity(promo.code, posVm, context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.secondaryLight.withOpacity(0.1)),
                    backgroundColor: AppColors.secondaryLight.withOpacity(0.03),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Check Conditions', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.secondaryLight, fontSize: 12)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
