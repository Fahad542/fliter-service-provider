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
import '../../../utils/pos_shell_scaffold.dart';

class PosTechnicianView extends StatefulWidget {
  /// When embedded in [PosShell], keep drawer + no back. When pushed from another
  /// flow (e.g. department product grid), show back and hide the drawer control.
  final bool showBackButton;
  final bool showHamburger;

  const PosTechnicianView({
    super.key,
    this.showBackButton = false,
    this.showHamburger = true,
  });

  @override
  State<PosTechnicianView> createState() => _PosTechnicianViewState();
}

class _PosTechnicianViewState extends State<PosTechnicianView> {
  /// All | Offline | Online — filters by [PosTechnician.isOnline].
  String _presenceTab = 'All';

  Widget _buildPresenceTab(String title) {
    final isSelected = _presenceTab == title;
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          setState(() => _presenceTab = title);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFCC247) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(color: const Color(0xFFE8ECF3), width: 1.5),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? const Color(0xFF23262D) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  List<PosTechnician> _filterByPresence(
    List<PosTechnician> searched,
  ) {
    if (_presenceTab == 'All') return searched;
    if (_presenceTab == 'Online') {
      return searched.where((t) => t.isOnline).toList();
    }
    return searched.where((t) => !t.isOnline).toList();
  }

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
        showBackButton: widget.showBackButton,
        showHamburger: widget.showHamburger,
        onMenuPressed: widget.showHamburger
            ? () => kPosShellScaffoldKey.currentState?.openDrawer()
            : null,
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

            final searched = vm.technicians;
            final technicians = _filterByPresence(searched);
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
                const SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Row(
                    children: [
                      _buildPresenceTab('All'),
                      const SizedBox(width: 12),
                      _buildPresenceTab('Offline'),
                      const SizedBox(width: 12),
                      _buildPresenceTab('Online'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: searched.isEmpty
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
                      : technicians.isEmpty
                          ? SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                                vertical: 16,
                              ),
                              child: SizedBox(
                                height: 280,
                                child: Center(
                                  child: Text(
                                    _presenceTab == 'Online'
                                        ? 'No online technicians'
                                        : _presenceTab == 'Offline'
                                            ? 'No offline technicians'
                                            : 'No technicians found',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
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
                              child: _buildTechnicianGrid(
                                technicians,
                                isTablet,
                              ),
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
