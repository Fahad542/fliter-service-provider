import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../widgets/pos_widgets.dart';

class PosSearchHistoryView extends StatelessWidget {
  final List<SearchHistoryData> historyItems;

  const PosSearchHistoryView({super.key, required this.historyItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const PosScreenAppBar(title: 'Search History'),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: historyItems.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = historyItems[index];
          return SearchHistoryItem(
            vehicle: item.vehicle,
            plate: item.plate,
            customer: item.customer,
            lastVisit: item.lastVisit,
            lastService: item.lastService,
            isCorporate: item.isCorporate,
          );
        },
      ),
    );
  }
}
