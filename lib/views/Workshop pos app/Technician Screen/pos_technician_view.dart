import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import 'technician_view_model.dart';
import '../Home Screen/pos_view_model.dart';
import '../../../models/pos_technician_model.dart';
import '../../../widgets/pos_widgets.dart';

class PosTechnicianView extends StatefulWidget {
  const PosTechnicianView({super.key});

  @override
  State<PosTechnicianView> createState() => _PosTechnicianViewState();
}

class _PosTechnicianViewState extends State<PosTechnicianView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final posVm = context.watch<PosViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      appBar: PosAppBar(
        userName: posVm.cashierName,
        infoTitle: posVm.workshopName,
        infoBranch: 'Branch: ${posVm.branchName}',
        infoTime: DateFormat('dd MMM yyyy · hh:mm a').format(DateTime.now()),
        customHeight: isTablet ? 156 : 99,
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<TechnicianViewModel>().fetchTechnicians(),
        color: AppColors.secondaryLight,
        backgroundColor: Colors.white,
        child: Consumer<TechnicianViewModel>(
          builder: (context, vm, child) {
            if (vm.isLoading && vm.technicians.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (vm.errorMessage != null && vm.technicians.isEmpty) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${vm.errorMessage}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => vm.fetchTechnicians(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final technicians = vm.technicians;

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 32 : 16, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search & View All Bar
                        _buildSearchSection(context, isTablet),
                        const SizedBox(height: 32),

                        // Technician Sections
                        if (technicians.isEmpty)
                          const Center(child: Text('No technicians found'))
                        else
                          _buildTechnicianSections(vm.groupedTechnicians, isTablet),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context, bool isTablet) {
    return Row(
      children: [
        Expanded(
          child: PosSearchBar(
            hintText: 'Search technicians...',
            onChanged: (val) => context.read<TechnicianViewModel>().setSearchQuery(val),
          ),
        ),
      ],
    );
  }

  Widget _buildTechnicianSections(Map<String, List<PosTechnician>> grouped, bool isTablet) {
    return Column(
      children: grouped.entries.map((entry) {
        return _buildCategoryBlock(entry.key, entry.value, isTablet);
      }).toList(),
    );
  }

  Widget _buildCategoryBlock(String category, List<PosTechnician> technicians, bool isTablet) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(category, style: AppTextStyles.h2.copyWith(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Workshop Technicians', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: technicians.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isTablet ? 4 : 1,
              childAspectRatio: isTablet ? 2.1 : 4, // Adjusted ratio to prevent overflow with scaling
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemBuilder: (context, index) {
              return TechnicianCard(tech: technicians[index]);
            },
          ),
        ],
      ),
    );
  }
}

