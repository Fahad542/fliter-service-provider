import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/workshop_owner_models.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/toast_service.dart';
import 'owner_petty_cash_reject_dialog.dart';

/// Same layout as Approvals list cards (pending + Approve/Reject).
class OwnerPettyCashApprovalCard extends StatelessWidget {
  final PettyCashRequestItem request;
  final String currency;
  final bool hasApprovalActionInFlight;
  final bool isApprovingThis;
  final bool isRejectingThis;
  final Future<bool> Function() onApprove;
  final Future<bool> Function(String reason) onReject;

  const OwnerPettyCashApprovalCard({
    super.key,
    required this.request,
    required this.currency,
    required this.hasApprovalActionInFlight,
    required this.isApprovingThis,
    required this.isRejectingThis,
    required this.onApprove,
    required this.onReject,
  });

  static String formatDateTimeCompact(DateTime? dt, {String localeName = 'en'}) {
    if (dt == null) return '—';
    return DateFormat('dd MMM yyyy, HH:mm', localeName).format(dt.toLocal());
  }

  String _localizedStatus(AppLocalizations l10n, String status) {
    final s = status.trim().toLowerCase();
    if (s == 'approved') return l10n.pettyCashStatusApproved;
    if (s == 'rejected') return l10n.pettyCashStatusRejected;
    if (s == 'pending') return l10n.pettyCashStatusPending;
    return l10n.pettyCashStatusFallback(status.toUpperCase());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final status = request.status.toLowerCase();
    final statusColor = status == 'approved'
        ? Colors.green
        : status == 'rejected'
            ? Colors.red
            : Colors.orange;

    final isExpense = request.isExpenseKind;
    final queueTag = isExpense
        ? l10n.pettyCashQueueCashierExpense
        : l10n.pettyCashQueueFundRequest;
    final noteText = (request.translatedReason ?? request.reason).trim();
    final cashierName = request.translatedCashierName?.trim().isNotEmpty == true
        ? request.translatedCashierName!
        : request.cashierName;
    final branchName = request.translatedBranchName?.trim().isNotEmpty == true
        ? request.translatedBranchName!
        : request.branchName;
    final categoryLabel = request.translatedCategoryLabel?.trim().isNotEmpty == true
        ? request.translatedCategoryLabel!
        : request.categoryLabel;
    final employeeName = request.translatedEmployeeName?.trim().isNotEmpty == true
        ? request.translatedEmployeeName!
        : request.employeeName;
    final localizedCurrency = currency.toUpperCase() == 'SAR'
        ? l10n.ownerCurrencySar
        : currency;
    final localizedAmount = l10n.ownerCurrencyAmount(
      localizedCurrency,
      request.amount.toStringAsFixed(2),
    );

    final tertiary = AppColors.secondaryLight.withValues(alpha: 0.55);
    final caption = AppColors.secondaryLight.withValues(alpha: 0.38);

    Widget statusBadge() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Text(
          _localizedStatus(l10n, request.translatedStatus ?? request.status),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.w800,
            fontSize: 9.5,
            letterSpacing: 0.3,
            height: 1.1,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.secondaryLight.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(child: statusBadge()),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        queueTag,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondaryLight.withValues(alpha: 0.72),
                          fontSize: 10,
                          letterSpacing: 0.75,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  localizedAmount,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color: AppColors.secondaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            cashierName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyLarge.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.25,
              color: AppColors.secondaryLight,
            ),
          ),
          if (!isExpense) ...[
            const SizedBox(height: 4),
            Text(
              l10n.pettyCashRequestLabel,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.3,
                color: tertiary,
              ),
            ),
          ],
          if (isExpense && (categoryLabel ?? '').isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              categoryLabel!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.35,
                color: tertiary,
              ),
            ),
          ],
          if (isExpense && (employeeName ?? '').isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              employeeName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 1.35,
                color: tertiary,
              ),
            ),
          ],
          if (noteText.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              noteText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.4,
                color: AppColors.secondaryLight.withValues(alpha: 0.72),
              ),
            ),
          ],
          SizedBox(height: noteText.isNotEmpty ? 10 : 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.place_outlined,
                  size: 14,
                  color: caption,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      branchName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                        color: tertiary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatDateTimeCompact(
                        request.requestedAt,
                        localeName: l10n.localeName,
                      ),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                        color: caption,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (status == 'pending') ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: hasApprovalActionInFlight
                        ? null
                        : () async {
                            final ok = await onApprove();
                            if (!context.mounted) return;
                            if (ok) {
                              ToastService.showSuccess(
                                context,
                                l10n.pettyCashRequestApprovedSuccess,
                              );
                            } else {
                              ToastService.showError(
                                context,
                                l10n.pettyCashRequestApproveFailed,
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLight,
                      foregroundColor: AppColors.secondaryLight,
                      disabledBackgroundColor:
                          AppColors.primaryLight.withValues(alpha: 0.55),
                      disabledForegroundColor:
                          AppColors.secondaryLight.withValues(alpha: 0.55),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 9,
                        horizontal: 8,
                      ),
                    ),
                    child: isApprovingThis
                        ? SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.secondaryLight,
                            ),
                          )
                        : Text(
                            l10n.pettyCashApprove,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.secondaryLight,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: hasApprovalActionInFlight
                        ? null
                        : () {
                            showPettyCashRejectRequestDialog(
                              context,
                              onConfirm: (reason) => onReject(reason),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryLight,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppColors.secondaryLight.withValues(alpha: 0.45),
                      disabledForegroundColor:
                          Colors.white.withValues(alpha: 0.75),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 9,
                        horizontal: 8,
                      ),
                    ),
                    child: isRejectingThis
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            l10n.pettyCashReject,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
