import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/workshop_owner_models.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';

/// Branch row used on dashboard Branch Performance and full list screen.
class OwnerBranchPerformanceTile extends StatelessWidget {
  final Branch branch;
  final VoidCallback? onTap;

  const OwnerBranchPerformanceTile({
    super.key,
    required this.branch,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localizedBranchName = branch.translatedName?.trim().isNotEmpty == true
        ? branch.translatedName!
        : branch.name;
    final localizedLocation = branch.translatedLocation?.trim().isNotEmpty == true
        ? branch.translatedLocation!
        : branch.location;
    final localizedSalesAmount = l10n.ownerCurrencyAmount(
      l10n.ownerCurrencySar,
      branch.salesMTD.toStringAsFixed(0),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondaryLight.withValues(alpha: 0.03),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: Colors.grey.withValues(alpha: 0.06)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.secondaryLight.withValues(alpha: 0.9),
                      AppColors.secondaryLight,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.store_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizedBranchName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.h2.copyWith(
                        fontSize: 15,
                        color: AppColors.secondaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      localizedLocation,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    localizedSalesAmount,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.secondaryLight,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    l10n.ownerMonthlySales,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                color: Colors.grey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
