import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/locker_models.dart';
import '../../../utils/app_colors.dart';
import 'record_collection_view_model.dart';

// ── Entry point ────────────────────────────────────────────────────────────────

class RecordCollectionView extends StatelessWidget {
  final LockerRequest request;

  const RecordCollectionView({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecordCollectionViewModel(request: request),
      child: const _RecordCollectionBody(),
    );
  }
}

// ── Inner StatefulWidget ───────────────────────────────────────────────────────

class _RecordCollectionBody extends StatefulWidget {
  const _RecordCollectionBody();

  @override
  State<_RecordCollectionBody> createState() => _RecordCollectionBodyState();
}

class _RecordCollectionBodyState extends State<_RecordCollectionBody> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController   = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<RecordCollectionViewModel>().loadSession();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<RecordCollectionViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          appBar: AppBar(
            backgroundColor: AppColors.primaryLight,
            elevation: 0,
            toolbarHeight: 72,
            title: Text(
              l10n.lockerRecordCollectionTitle,
              style: const TextStyle(
                color: AppColors.secondaryLight,
                fontWeight: FontWeight.w900,
                fontSize: 15,
                letterSpacing: 2,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.secondaryLight, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAssetSummaryCard(context, vm),
                const SizedBox(height: 32),
                _buildAmountEntrySection(context, vm),
                const SizedBox(height: 32),
                _buildEvidenceSection(context, vm),
                if (vm.hasError) ...[
                  const SizedBox(height: 16),
                  _ErrorBanner(
                    message: vm.errorMessage!,
                    onDismiss: vm.resetError,
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Asset summary card ─────────────────────────────────────────────────────

  Widget _buildAssetSummaryCard(
      BuildContext context, RecordCollectionViewModel vm) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondaryLight.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: AppColors.secondaryLight,
              size: 24,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.lockerExpectedAmount,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.3),
                    fontWeight: FontWeight.w900,
                    fontSize: 9,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  '${l10n.lockerSarCurrency} ${vm.request.lockedCashAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppColors.secondaryLight,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  vm.request.referenceCode,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.25),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Amount entry + notes ────────────────────────────────────────────────────

  Widget _buildAmountEntrySection(
      BuildContext context, RecordCollectionViewModel vm) {
    final l10n = AppLocalizations.of(context)!;
    final isSubmitting = vm.isSubmitting;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.lockerVerifiedReceivedAmount,
          style: const TextStyle(
            color: AppColors.secondaryLight,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.secondaryLight.withOpacity(0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondaryLight.withOpacity(0.03),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            enabled: !isSubmitting,
            style: const TextStyle(
              color: AppColors.secondaryLight,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
            decoration: InputDecoration(
              prefixText: '${l10n.lockerSarCurrency} ',
              prefixStyle: TextStyle(
                color: AppColors.secondaryLight.withOpacity(0.2),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
              border: InputBorder.none,
              hintText: '0.00',
              hintStyle: TextStyle(color: Colors.black.withOpacity(0.05)),
            ),
            onChanged: (val) => setState(() {}),
          ),
        ),
        const SizedBox(height: 16),
        _buildDifferenceSummary(context, vm),
        const SizedBox(height: 24),
        Text(
          l10n.lockerCollectionNotes,
          style: const TextStyle(
            color: AppColors.secondaryLight,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: AppColors.secondaryLight.withOpacity(0.05)),
          ),
          child: TextField(
            controller: _notesController,
            maxLines: 3,
            enabled: !isSubmitting,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: l10n.lockerCollectionNotesHint,
              hintStyle:
              TextStyle(color: Colors.black.withOpacity(0.15), fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  // ── Difference summary ─────────────────────────────────────────────────────

  Widget _buildDifferenceSummary(
      BuildContext context, RecordCollectionViewModel vm) {
    final l10n = AppLocalizations.of(context)!;
    final received   = double.tryParse(_amountController.text) ?? 0;
    final locked     = vm.request.lockedCashAmount;
    final difference = locked - received;

    Color  diffColor    = Colors.green;
    String statusLabel  = l10n.lockerStatusMatched;

    if (difference > 0) {
      diffColor   = Colors.red;
      statusLabel = l10n.lockerShortLabel;
    } else if (difference < 0) {
      diffColor   = Colors.teal;
      statusLabel = l10n.lockerOverLabel;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: diffColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: diffColor.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _buildDiffRow(
            l10n.lockerLockedAmount,
            '${l10n.lockerSarCurrency} ${locked.toStringAsFixed(0)}',
            Colors.black38,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: Colors.black12),
          ),
          _buildDiffRow(
            l10n.lockerReceivedAmountLabel,
            '${l10n.lockerSarCurrency} ${received.toStringAsFixed(0)}',
            Colors.black38,
          ),
          const SizedBox(height: 12),
          _buildDiffRow(
            l10n.lockerDifference,
            '${l10n.lockerSarCurrency} ${difference.abs().toStringAsFixed(0)}',
            diffColor,
            isMain: true,
            suffix: statusLabel,
          ),
        ],
      ),
    );
  }

  Widget _buildDiffRow(
      String label,
      String value,
      Color color, {
        bool isMain = false,
        String? suffix,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.black.withOpacity(0.3),
            fontWeight: FontWeight.w900,
            fontSize: 8,
            letterSpacing: 1,
          ),
        ),
        Row(
          children: [
            if (suffix != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  suffix,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: isMain ? 18 : 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Evidence + submit ──────────────────────────────────────────────────────

  Widget _buildEvidenceSection(
      BuildContext context, RecordCollectionViewModel vm) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.lockerCollectionEvidence,
          style: const TextStyle(
            color: AppColors.secondaryLight,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildEvidenceCard(l10n.lockerCapturePhoto, Icons.camera_alt_rounded),
            const SizedBox(width: 12),
            _buildEvidenceCard(l10n.lockerAttachLogs, Icons.assessment_rounded),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed:
            vm.isSubmitting ? null : () => _handleSubmit(context, vm),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: AppColors.secondaryLight,
              disabledBackgroundColor: AppColors.primaryLight.withOpacity(0.5),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: vm.isSubmitting
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.secondaryLight,
              ),
            )
                : Text(
              l10n.lockerConfirmFinalise,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEvidenceCard(String label, IconData icon) {
    return Expanded(
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryLight, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.black.withOpacity(0.4),
                fontSize: 7,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Submit handler ─────────────────────────────────────────────────────────

  Future<void> _handleSubmit(
      BuildContext context, RecordCollectionViewModel vm) async {
    final l10n     = AppLocalizations.of(context)!;
    final received = double.tryParse(_amountController.text);

    if (received == null || received <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.lockerEnterValidAmount),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final success = await vm.submit(
      receivedAmount: received,
      notes: _notesController.text.trim(),
    );

    if (!mounted) return;
    if (success) {
      final result = vm.result!;
      _showSuccessSheet(context, result);
    }
  }

  // ── Success bottom sheet ───────────────────────────────────────────────────

  void _showSuccessSheet(BuildContext context, CollectionResult result) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => _SuccessSheet(
        result: result,
        onDone: () {
          Navigator.pop(context); // close sheet
          Navigator.pop(context); // close RecordCollectionView → details
          Navigator.pop(context); // close details → list
        },
      ),
    );
  }
}

// ── Success sheet ──────────────────────────────────────────────────────────────

class _SuccessSheet extends StatelessWidget {
  final CollectionResult result;
  final VoidCallback onDone;

  const _SuccessSheet({required this.result, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final l10n       = AppLocalizations.of(context)!;
    final hasDiff    = result.hasDifference;
    final isPending  = result.isPendingApproval;
    final accentColor = hasDiff ? Colors.orange : Colors.green;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        left: 32,
        right: 32,
        top: 32,
        bottom: 32 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPending
                  ? Icons.hourglass_top_rounded
                  : Icons.check_circle_outline_rounded,
              color: accentColor,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isPending
                ? l10n.lockerSuccessPendingApproval
                : l10n.lockerSuccessCollectionRecorded,
            style: const TextStyle(
              color: AppColors.secondaryLight,
              fontWeight: FontWeight.w900,
              fontSize: 18,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            result.message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black45, fontSize: 13),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FD),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatCell(
                  label: l10n.lockerReceivedLabel,
                  value: '${l10n.lockerSarCurrency} ${result.receivedAmount.toStringAsFixed(0)}',
                  color: Colors.teal,
                ),
                Container(width: 1, height: 40, color: Colors.black.withOpacity(0.06)),
                _StatCell(
                  label: l10n.lockerDiffLabel,
                  value: '${l10n.lockerSarCurrency} ${result.difference.abs().toStringAsFixed(0)}',
                  color: hasDiff ? Colors.red : Colors.green,
                ),
                Container(width: 1, height: 40, color: Colors.black.withOpacity(0.06)),
                _StatCell(
                  label: l10n.lockerStatusLabel,
                  value: isPending ? l10n.lockerStatusReview : l10n.lockerStatusOk,
                  color: accentColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: AppColors.secondaryLight,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                l10n.lockerDone,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCell({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.black.withOpacity(0.3),
            fontSize: 8,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

// ── Error banner ───────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              color: Colors.red.shade400, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded,
                color: Colors.red.shade300, size: 18),
            onPressed: onDismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}