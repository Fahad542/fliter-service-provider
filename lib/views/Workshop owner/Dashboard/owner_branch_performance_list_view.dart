import 'package:flutter/material.dart';
import '../../../models/workshop_owner_models.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/owner_app_bar.dart';
import '../widgets/owner_branch_performance_tile.dart';

class OwnerBranchPerformanceListView extends StatelessWidget {
  final List<Branch> branches;

  const OwnerBranchPerformanceListView({
    super.key,
    required this.branches,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: OwnerAppBar(
        title: l10n.branchPerformanceListTitle,
        showBackButton: true,
        showDrawer: false,
        showNotification: false,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: branches.isEmpty
          ? Center(
        child: Text(
          l10n.branchPerformanceNoBranches,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        itemCount: branches.length,
        itemBuilder: (context, index) {
          return OwnerBranchPerformanceTile(branch: branches[index]);
        },
      ),
    );
  }
}