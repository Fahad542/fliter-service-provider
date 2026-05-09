import 'package:flutter/material.dart';
import '../../../services/currency_helper.dart';
import '../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/app_formatters.dart';
import '../Home Screen/pos_view_model.dart';
import '../../../widgets/pos_widgets.dart';
import '../../../widgets/pos_shimmer.dart';
import '../../../widgets/pos_shell_rail_layout.dart';
import '../../../utils/pos_shell_scaffold.dart' show PosShellScaffoldRegistry;
import '../More Tab/pos_more_view.dart'; // Added
import 'promo_code_dialog.dart'; // Added (same folder)
import 'promo_view_model.dart';
import '../../../services/LocalizedApiText.dart';
import '../../../services/locker_translation_mixin.dart';

class PosPromoView extends StatefulWidget {
  const PosPromoView({super.key});

  @override
  State<PosPromoView> createState() => _PosPromoViewState();
}

class _PosPromoViewState extends State<PosPromoView> {
  String _lang(BuildContext context) => Localizations.localeOf(context).languageCode;
  bool _isAr(BuildContext context) => _lang(context) == 'ar';

  String _digits(BuildContext context, Object? value) {
    return AppTranslationService.localizeDigitsForLanguage(
      value?.toString() ?? '',
      _lang(context),
    );
  }

  String _money(BuildContext context, num amount) {
    final lang = _lang(context);
    final v = _digits(context, amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2));
    return lang == 'ar' ? '$v ر.س' : 'SAR $v';
  }

  String _discountText(BuildContext context, double discount, bool isPercent) {
    final amount = discount % 1 == 0 ? discount.toStringAsFixed(0) : discount.toStringAsFixed(2);
    final d = _digits(context, amount);
    if (_isAr(context)) {
      return isPercent ? 'خصم $d٪' : 'خصم ${_money(context, discount)}';
    }
    return isPercent ? '$d% OFF' : '${_money(context, discount)} OFF';
  }

  String _validDiscountText(BuildContext context, Map<String, dynamic> result) {
    final rawDiscount = result['discount'];
    final discount = rawDiscount is num
        ? rawDiscount.toDouble()
        : double.tryParse(rawDiscount?.toString() ?? '') ?? 0;
    final isPercent = result['isPercent'] == true;
    return _discountText(context, discount, isPercent);
  }

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
      resizeToAvoidBottomInset: false,
      appBar: PosScreenAppBar(
        title: AppLocalizations.of(context)!.posPromoTitle,
        showBackButton: false,
        showHamburger: true,
        onMenuPressed: () =>
            PosShellScaffoldRegistry.openDrawer(),
      ),
      body: wrapPosShellRailBody(
        context,
        SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isTablet ? 8 : 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEntrySection(isTablet),
            SizedBox(height: isTablet ? 10 : 20),
            _buildSectionTitle(AppLocalizations.of(context)!.posPromoAvailablePromotions, Icons.stars_outlined),
            SizedBox(height: isTablet ? 8 : 14),
            if (promoVm.isLoadingPromos)
              _PromoPromotionsShimmer(isTablet: isTablet)
            else if (promoVm.availablePromotions.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    AppLocalizations.of(context)!.posPromoNoPromotionsAvailable,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  ),
                ),
              )
            else
              _buildPromotionCatalog(
                promoVm.availablePromotions,
                isTablet,
                MediaQuery.of(context).orientation,
              ),
          ],
        ),
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
      padding: EdgeInsets.fromLTRB(
        isTablet ? 16 : 20,
        isTablet ? 14 : 20,
        isTablet ? 16 : 20,
        isTablet ? 12 : 20,
      ),
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
          _buildSectionTitle(
            AppLocalizations.of(context)!.posPromoApplyPromoCode,
            Icons.local_offer_outlined,
          ),
          SizedBox(height: isTablet ? 8 : 16),
          Text(
            AppLocalizations.of(context)!.posPromoCheckDescription,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
          SizedBox(height: isTablet ? 10 : 16),
          if (isTablet)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                      inputFormatters: [EnglishNumberFormatter()],
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.posPromoExampleSave10,
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.qr_code_scanner_rounded,
                          size: 20,
                          color: AppColors.secondaryLight,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primaryLight,
                            width: 2,
                          ),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: promoVm.isLoading
                        ? null
                        : () => promoVm.validatePromo(
                              promoVm.promoController.text,
                              posVm,
                              context,
                            ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryLight,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      shadowColor:
                          AppColors.secondaryLight.withOpacity(0.4),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    child: promoVm.isLoading
                        ? const PosShimmer(
                            child: PosShimmerBox(
                              width: 20,
                              height: 20,
                              radius: 10,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.posPromoCheckValidity,
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                          inputFormatters: [EnglishNumberFormatter()],
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.posPromoExampleSave10,
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13,
                            ),
                            prefixIcon: const Icon(
                              Icons.qr_code_scanner_rounded,
                              size: 20,
                              color: AppColors.secondaryLight,
                            ),
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
                              borderSide: const BorderSide(
                                color: AppColors.primaryLight,
                                width: 2,
                              ),
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: promoVm.isLoading
                            ? null
                            : () => promoVm.validatePromo(
                                  promoVm.promoController.text,
                                  posVm,
                                  context,
                                ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryLight,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          shadowColor:
                              AppColors.secondaryLight.withOpacity(0.4),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                        ),
                        child: promoVm.isLoading
                            ? const PosShimmer(
                                child: PosShimmerBox(
                                  width: 20,
                                  height: 20,
                                  radius: 10,
                                ),
                              )
                            : Text(
                                AppLocalizations.of(context)!.posPromoCheckValidity,
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          if (promoVm.validResult != null) ...[
            SizedBox(height: isTablet ? 12 : 12),
            SizedBox(
              width: double.infinity,
              child: _buildResultCard(
                promoVm.validResult!,
                compact: isTablet,
                onRemove: () => promoVm.removeAppliedPromo(posVm),
              ),
            ),
          ],
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
                  LocalizedApiText(
                    promoVm.promoErrorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultCard(
    Map<String, dynamic> validResult, {
    bool compact = false,
    VoidCallback? onRemove,
  }) {
    final pad = compact ? 12.0 : 20.0;
    final titleFs = compact ? 14.0 : 17.0;
    final iconMain = compact ? 20.0 : 24.0;
    final gapAfterTitle = compact ? 10.0 : 20.0;
    final gapDetail = compact ? 6.0 : 8.0;
    final EdgeInsetsGeometry cardPadding = compact
        ? const EdgeInsets.fromLTRB(10, 8, 10, 10)
        : EdgeInsets.all(pad);

    return Container(
      padding: cardPadding,
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(compact ? 12 : 16),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: iconMain),
              SizedBox(width: compact ? 8 : 12),
              Expanded(
                child: Text(
                  _validDiscountText(context, validResult),
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w800,
                    fontSize: titleFs,
                  ),
                ),
              ),
              if (onRemove != null)
                Tooltip(
                  message: AppLocalizations.of(context)!.posPromoRemovePromoLower,
                  child: IconButton(
                    onPressed: onRemove,
                    icon: Icon(
                      Icons.close_rounded,
                      size: compact ? 18 : 22,
                      color: Colors.green.shade800,
                    ),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: gapAfterTitle),
          _buildResultDetail(
            Icons.store,
            AppLocalizations.of(context)!.posPromoStoreLabel,
            validResult['store']?.toString() ?? '',
            compact: compact,
          ),
          SizedBox(height: gapDetail),
          _buildResultDetail(
            Icons.inventory_2,
            AppLocalizations.of(context)!.posPromoProductsLabel,
            validResult['products']?.toString() ?? '',
            compact: compact,
          ),
          SizedBox(height: gapDetail),
          _buildResultDetail(
            Icons.calendar_today,
            AppLocalizations.of(context)!.posPromoValidityLabel,
            validResult['period']?.toString() ?? '',
            compact: compact,
          ),
        ],
      ),
    );
  }

  Widget _buildResultDetail(
    IconData icon,
    String label,
    String value, {
    bool compact = false,
  }) {
    final style = TextStyle(
      color: Colors.grey.shade800,
      fontSize: compact ? 12 : 14,
      fontWeight: FontWeight.w500,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: compact ? 14 : 16,
          color: Colors.green.withOpacity(0.7),
        ),
        SizedBox(width: compact ? 8 : 12),
        Expanded(
          child: Wrap(
            spacing: 4,
            runSpacing: 2,
            children: [
              Text(label, style: style.copyWith(fontWeight: FontWeight.w700)),
              LocalizedApiText(
                _digits(context, value),
                style: style,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPromotionCatalog(
    List<AvailablePromotion> promos,
    bool isTablet,
    Orientation orientation,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: promos.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet
            ? (orientation == Orientation.landscape ? 3 : 2)
            : 1,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      promo.code,
                      style: const TextStyle(
                        color: AppColors.secondaryLight,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _discountText(context, promo.discount, promo.isPercent),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.green,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LocalizedApiText(
                promo.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF1E2124),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              LocalizedApiText(
                promo.description,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    final posVm = Provider.of<PosViewModel>(
                      context,
                      listen: false,
                    );
                    final promoVm = Provider.of<PromoViewModel>(
                      context,
                      listen: false,
                    );
                    promoVm.promoController.text = promo.code;
                    promoVm.validatePromo(promo.code, posVm, context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.secondaryLight.withOpacity(0.1),
                    ),
                    backgroundColor: AppColors.secondaryLight.withOpacity(0.03),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.posPromoCheckConditions,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondaryLight,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


class _PromoPromotionsShimmer extends StatelessWidget {
  const _PromoPromotionsShimmer({required this.isTablet});

  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final count = isTablet ? 3 : 2;
    return PosShimmer(
      child: Column(
        children: List.generate(count, (index) {
          return Container(
            margin: EdgeInsets.only(bottom: isTablet ? 10 : 12),
            padding: EdgeInsets.all(isTablet ? 14 : 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              children: const [
                PosShimmerCircle(size: 38),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PosShimmerLine(width: 150, height: 14),
                      SizedBox(height: 8),
                      PosShimmerLine(width: double.infinity, height: 11),
                      SizedBox(height: 6),
                      PosShimmerLine(width: 120, height: 11),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                PosShimmerBox(width: 64, height: 28, radius: 12),
              ],
            ),
          );
        }),
      ),
    );
  }
}
