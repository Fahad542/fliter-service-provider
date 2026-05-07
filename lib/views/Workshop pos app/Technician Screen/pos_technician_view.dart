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
import '../../../utils/pos_shell_scaffold.dart' show PosShellScaffoldRegistry;

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
  /// All | Offline | Online (workshop duty, card "Online now") | On call | Not available
  String _presenceTab = 'All';

  static String _dutyModeResolved(PosTechnician t) {
    final dm = t.dutyMode?.toLowerCase().trim() ?? '';
    if (dm.isNotEmpty) return dm;
    if (t.workshopDuty) return 'workshop';
    if (t.onCallDuty) return 'on_call';
    return 'inactive';
  }

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
          color: isSelected ? AppColors.secondaryLight : Colors.transparent,
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
            color: isSelected
                ? AppColors.onSecondaryLight
                : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  /// Tab filters (search pehle [TechnicianViewModel.technicians] se lag chuka hota hai).
  /// Online / On call / Not available teeno sirf **presence online** technicians ko duty ke hisaab se baantti hain.
  List<PosTechnician> _filterByPresence(
    List<PosTechnician> searched,
  ) {
    bool presenceOnline(PosTechnician t) => t.isOnline;

    switch (_presenceTab) {
      case 'All':
        return searched;
      case 'Offline':
        return searched.where((t) => !presenceOnline(t)).toList();
      case 'Online':
        return searched
            .where(
              (t) =>
                  presenceOnline(t) && _dutyModeResolved(t) == 'workshop',
            )
            .toList();
      case 'On call':
        return searched
            .where(
              (t) =>
                  presenceOnline(t) && _dutyModeResolved(t) == 'on_call',
            )
            .toList();
      case 'Not available':
        return searched
            .where(
              (t) =>
                  presenceOnline(t) && _dutyModeResolved(t) == 'inactive',
            )
            .toList();
      default:
        return searched;
    }
  }

  String _emptyFilterMessage() {
    switch (_presenceTab) {
      case 'Online':
        return 'No technicians on workshop duty';
      case 'Offline':
        return 'No offline technicians';
      case 'On call':
        return 'No technicians on on-call duty';
      case 'Not available':
        return 'No technicians with duties off';
      default:
        return 'No technicians found';
    }
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
            ? PosShellScaffoldRegistry.openDrawer
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildPresenceTab('All'),
                        const SizedBox(width: 12),
                        _buildPresenceTab('Offline'),
                        const SizedBox(width: 12),
                        _buildPresenceTab('Online'),
                        const SizedBox(width: 12),
                        _buildPresenceTab('On call'),
                        const SizedBox(width: 12),
                        _buildPresenceTab('Not available'),
                      ],
                    ),
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
                                    _emptyFilterMessage(),
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
                                context,
                                vm,
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
    BuildContext context,
    TechnicianViewModel vm,
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
        // Lower ratio = taller cells — workshop/on-call toggles need extra height vs old cards.
        childAspectRatio: isTablet
            ? (orientation == Orientation.landscape ? 1.30 : 1.35)
            : (orientation == Orientation.landscape ? 1.32 : 1.35),
        crossAxisSpacing: isTablet ? 18 : 12,
        mainAxisSpacing: isTablet ? 18 : 12,
      ),
      itemBuilder: (context, index) {
        final tech = technicians[index];
        return TechnicianCard(
          tech: tech,
          compact: !isTablet && orientation == Orientation.portrait,
          showPresenceToggle: true,
          presenceBusy: vm.isPresenceToggleBusy(tech.id),
          onPresenceChanged: (online) =>
              vm.setTechnicianPresence(context, tech.id, online),
          showDutyToggles: true,
          dutyBusy: vm.isDutyToggleBusy(tech.id),
          onWorkshopDutyChanged: (v) =>
              vm.setTechnicianWorkshopDuty(context, tech, v),
          onOnCallDutyChanged: (v) =>
              vm.setTechnicianOnCallDuty(context, tech, v),
        );
      },
    );
  }
}
