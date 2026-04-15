import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import 'technician_view_model.dart';
import '../Home Screen/pos_view_model.dart';
import '../../../models/pos_technician_model.dart';
import '../../../widgets/pos_widgets.dart';
import '../../../widgets/pos_shell_rail_layout.dart';

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
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFFBF9F6),
      appBar: PosScreenAppBar(
        title: 'Technicians',
        showBackButton: false,
        showHamburger: true,
        onMenuPressed: () => Scaffold.of(context).openDrawer(),
      ),
      body: wrapPosShellRailBody(
        context,
        RefreshIndicator(
        onRefresh: () => context.read<TechnicianViewModel>().fetchTechnicians(),
        color: AppColors.secondaryLight,
        backgroundColor: Colors.white,
        child: Consumer<TechnicianViewModel>(
          builder: (context, vm, child) {
            if (vm.isLoading && vm.technicians.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primaryLight));
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
            final horizontalPadding = isTablet ? 32.0 : 16.0;

            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    24,
                    horizontalPadding,
                    0,
                  ),
                  child: _buildSearchSection(context, isTablet),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: technicians.isEmpty
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: 16,
                          ),
                          child: const SizedBox(
                            height: 280,
                            child: Center(child: Text('No technicians found')),
                          ),
                        )
                      : SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            0,
                            horizontalPadding,
                            24,
                          ),
                          child: _buildTechnicianGrid(technicians, isTablet),
                        ),
                  ),
              ],
            );
          },
        ),
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
            onChanged: (val) =>
                context.read<TechnicianViewModel>().setSearchQuery(val),
          ),
        ),
      ],
    );
  }

  Widget _buildTechnicianGrid(
    List<PosTechnician> technicians,
    bool isTablet,
  ) {
    final orientation = MediaQuery.of(context).orientation;
    final crossAxisCount = orientation == Orientation.landscape ? 4 : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: technicians.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: isTablet
            ? (orientation == Orientation.landscape ? 2.15 : 2.6)
            : (orientation == Orientation.landscape ? 2.3 : 2.3),
        crossAxisSpacing: isTablet ? 18 : 12,
        mainAxisSpacing: isTablet ? 18 : 12,
      ),
      itemBuilder: (context, index) {
        return TechnicianCard(
          tech: technicians[index],
          // On mobile portrait always use compact to avoid overflow
          compact: !isTablet && orientation == Orientation.portrait,
        );
      },
    );
  }
}
