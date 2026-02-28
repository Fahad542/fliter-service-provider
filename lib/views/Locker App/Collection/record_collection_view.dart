import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../locker_view_model.dart';
import '../../../models/locker_models.dart';

class RecordCollectionView extends StatefulWidget {
  final LockerRequest request;
  const RecordCollectionView({super.key, required this.request});

  @override
  State<RecordCollectionView> createState() => _RecordCollectionViewState();
}

class _RecordCollectionViewState extends State<RecordCollectionView> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: AppColors.primaryLight,
        elevation: 0,
        toolbarHeight: 72,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        title: const Text('RECORD COLLECTION', style: TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 2)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.secondaryLight, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAssetSummaryCard(),
            const SizedBox(height: 32),
            _buildAmountEntrySection(),
            const SizedBox(height: 32),
            _buildEvidenceSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetSummaryCard() {
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
            decoration: BoxDecoration(color: AppColors.secondaryLight.withOpacity(0.05), shape: BoxShape.circle),
            child: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.secondaryLight, size: 24),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'EXPECTED AMOUNT',
                style: TextStyle(color: Colors.black.withOpacity(0.3), fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 1),
              ),
              Text(
                'SAR ${widget.request.lockedCashAmount.toInt()}',
                style: const TextStyle(color: AppColors.secondaryLight, fontWeight: FontWeight.w900, fontSize: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountEntrySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'VERIFIED RECEIVED AMOUNT',
          style: TextStyle(color: AppColors.secondaryLight, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.secondaryLight.withOpacity(0.1), width: 1.5),
            boxShadow: [
              BoxShadow(color: AppColors.secondaryLight.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8)),
            ],
          ),
          child: TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppColors.secondaryLight, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1),
            decoration: InputDecoration(
              prefixText: 'SAR ',
              prefixStyle: TextStyle(color: AppColors.secondaryLight.withOpacity(0.2), fontSize: 20, fontWeight: FontWeight.w900),
              border: InputBorder.none,
              hintText: '0.00',
              hintStyle: TextStyle(color: Colors.black.withOpacity(0.05)),
            ),
            onChanged: (val) => setState(() {}),
          ),
        ),
        const SizedBox(height: 16),
        _buildDifferenceSummary(),
        const SizedBox(height: 24),
        const Text(
          'COLLECTION NOTES',
          style: TextStyle(color: AppColors.secondaryLight, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.secondaryLight.withOpacity(0.05)),
          ),
          child: TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter any remarks or reason for difference...',
              hintStyle: TextStyle(color: Colors.black.withOpacity(0.15), fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDifferenceSummary() {
    final received = double.tryParse(_amountController.text) ?? 0;
    final locked = widget.request.lockedCashAmount;
    final difference = locked - received;

    Color diffColor = Colors.green;
    String status = 'MATCHED';

    if (difference > 0) {
      diffColor = Colors.red;
      status = 'SHORT';
    } else if (difference < 0) {
      diffColor = Colors.teal;
      status = 'OVER';
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
          _buildDiffRow('LOCKED AMOUNT', 'SAR ${locked.toInt()}', Colors.black38),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: Colors.black12),
          ),
          _buildDiffRow('RECEIVED AMOUNT', 'SAR ${received.toInt()}', Colors.black38),
          const SizedBox(height: 12),
          _buildDiffRow('DIFFERENCE', 'SAR ${difference.abs().toInt()}', diffColor, isMain: true, suffix: status),
        ],
      ),
    );
  }

  Widget _buildDiffRow(String label, String value, Color color, {bool isMain = false, String? suffix}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.black.withOpacity(0.3), fontWeight: FontWeight.w900, fontSize: 8, letterSpacing: 1),
        ),
        Row(
          children: [
            if (suffix != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                child: Text(suffix, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
              ),
            ],
            Text(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: isMain ? 18 : 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEvidenceSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'COLLECTION EVIDENCE',
          style: TextStyle(color: AppColors.secondaryLight, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildEvidenceCard('CAPTURE PHOTO', Icons.camera_alt_rounded),
            const SizedBox(width: 12),
            _buildEvidenceCard('ATTACH LOGS', Icons.assessment_rounded),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => _showSuccess(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: AppColors.secondaryLight,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('CONFIRM & FINALISE ASSET', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2)),
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
            Text(label, style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 7, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  void _showSuccess(BuildContext context) {
    final amount = double.tryParse(_amountController.text) ?? 0;
    context.read<LockerViewModel>().recordCollection(
      requestId: widget.request.id,
      receivedAmount: amount,
      notes: _notesController.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ASSET LOGGED SUCCESSFULLY'),
        backgroundColor: AppColors.secondaryLight,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
    Navigator.pop(context);
  }
}
