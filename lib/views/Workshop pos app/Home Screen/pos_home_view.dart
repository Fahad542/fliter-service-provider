import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/LocalizedApiText.dart';
import '../../../services/locker_translation_mixin.dart';
import '../../../utils/app_text_styles.dart';
import '../More Tab/settings_view_model.dart';
import '../../../widgets/pos_widgets.dart';
import '../../../widgets/pos_shell_rail_layout.dart';
import '../../../widgets/pos_shimmer.dart';
import '../Add Customer Screen/pos_add_customer_view.dart';
import '../Search History/pos_search_history_view.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:flutter/services.dart';
import '../../../utils/app_formatters.dart';
import '../../../utils/pos_tablet_layout.dart';
import '../../../utils/pos_shell_scaffold.dart' show PosShellScaffoldRegistry;
import '../Product Grid/pos_product_grid_view.dart';
import '../Sales Return/sales_return_view_model.dart';
import '../Sales Return/pos_sales_return_view.dart';
import 'pos_view_model.dart';
import 'pos_customer_history_view.dart';
import '../Corporate Bookings/pos_corporate_bookings_view.dart';

class PosHomeView extends StatefulWidget {
  const PosHomeView({super.key});

  @override
  State<PosHomeView> createState() => _PosHomeViewState();
}

class _PosHomeViewState extends State<PosHomeView>
    with SingleTickerProviderStateMixin {
  // ── Animation ─────────────────────────────────────────────────────────────
  // One AnimationController drives both FadeTransition and SizeTransition.
  // FadeTransition is GPU-composited (no layout pass per frame).
  // SizeTransition reclaims the space so search results expand naturally.
  // 220 ms matches the typical Android soft-keyboard slide duration.
  late final AnimationController _headerAnim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    value: 1.0, // start fully visible
  );
  late final Animation<double> _headerFade =
  CurvedAnimation(parent: _headerAnim, curve: Curves.easeInOut);

  bool _keyboardWasOpen = false;

  @override
  void dispose() {
    _headerAnim.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Drive animation from MediaQuery — no setState, only AnimationController.
    // This means zero extra widget-tree rebuilds from keyboard changes.
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    if (keyboardOpen == _keyboardWasOpen) return;
    _keyboardWasOpen = keyboardOpen;
    if (keyboardOpen) {
      _headerAnim.reverse(); // hide header
    } else {
      _headerAnim.forward(); // restore header
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final langCode = Localizations.localeOf(context).languageCode;
    final isTablet = MediaQuery.of(context).size.width > 600;
    final vm = context.watch<PosViewModel>();
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: PosTabletLayout.textScaler(context)),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        resizeToAvoidBottomInset: false,
        appBar: PosAppBar(
          userName: vm.cashierName,
          infoTitle: vm.workshopName,
          infoBranch: l10n.posHomeBranchPrefix(vm.branchName),
          infoTime: AppTranslationService.localizeDigitsForLanguage(
              DateFormat('dd MMM yyyy · hh:mm a', langCode)
                  .format(DateTime.now()),
              langCode),
          onMenuPressed: () => PosShellScaffoldRegistry.openDrawer(),
        ),
        body: wrapPosShellRailBody(
          context,
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {},
            child: Column(
              children: [
                // ── Animated header: title + subtitle ─────────────────────
                FadeTransition(
                  opacity: _headerFade,
                  child: SizeTransition(
                    sizeFactor: _headerFade,
                    axisAlignment: -1,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          isTablet ? 20 : 24, isTablet ? 14 : 18,
                          isTablet ? 20 : 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(width: double.infinity),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: l10n.posHomeTitleFilter,
                                  style: AppTextStyles.h1.copyWith(
                                    color: AppColors.primaryLight,
                                    fontSize: isTablet ? 34 : 32,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(
                                  text: l10n.posHomeTitlePos,
                                  style: AppTextStyles.h1.copyWith(
                                    color: AppColors.secondaryLight,
                                    fontSize: isTablet ? 34 : 32,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.posHomeSubtitle,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.grey,
                              fontSize: 15,
                              height: 1.1,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Search bar — always visible ────────────────────────────
                // Small top gap so search bar doesn't butt up against the appbar
                // when the header is hidden (keyboard open state).
                AnimatedPadding(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.only(top: keyboardOpen ? 12 : 0),
                  child: const SizedBox.shrink(),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 24),
                  child: Column(
                    children: [
                      PosSearchBar(
                        controller: vm.homeSearchController,
                        focusNode: vm.homeSearchFocusNode,
                        hintText: l10n.posHomeSearchHint,
                        onChanged: (val) => vm.handleSearchDebounce(val),
                      ),

                      // ── Animated buttons ───────────────────────────────
                      FadeTransition(
                        opacity: _headerFade,
                        child: SizeTransition(
                          sizeFactor: _headerFade,
                          axisAlignment: -1,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildActionChip(
                                  context: context,
                                  icon: Icons.add,
                                  label: l10n.posHomeNewWalkIn,
                                  onTap: () {
                                    context
                                        .read<PosViewModel>()
                                        .clearCustomerData();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const PosAddCustomerView(
                                            initialTab: 0),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 12),
                                _buildActionChip(
                                  context: context,
                                  icon: Icons.business,
                                  label: l10n.posHomeCorporateBooking,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                        const PosCorporateBookingsView(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Search results ─────────────────────────────────────────
                if (vm.homeSearchController.text.isNotEmpty ||
                    vm.homeSearchFocusNode.hasFocus)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildSearchResults(context, isTablet),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, bool isTablet) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<PosViewModel>(
      builder: (context, vm, child) {
        if (vm.isSearchingCustomer) {
          return _CustomerSearchShimmerList(isTablet: isTablet);
        }

        if (vm.searchedCustomers.isNotEmpty) {
          final langCode = Localizations.localeOf(context).languageCode;
          final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
          Widget buildCustomerCard(int index) {
            final customer = vm.searchedCustomers[index];
            final latestOrder = customer.orders.isNotEmpty
                ? customer.orders.first
                : null;
            final vehicle = latestOrder?.vehicle;

            // Raw API strings that need Arabic translation
            final rawVehicle = vehicle != null
                ? '${vehicle.make} ${vehicle.model}'
                '${(vehicle.year != null && vehicle.year!.isNotEmpty) ? ' · ${vehicle.year}' : ''}'
                : l10n.posHomeNoVehicle;
            final rawStatus = latestOrder?.status.toUpperCase() ?? l10n.posCommonNotAvailable;

            final plateRaw = vehicle?.plateNo;
            final plateDisplay = (plateRaw == null ||
                plateRaw.trim().isEmpty)
                ? l10n.posCommonNotAvailable
                : formatVehiclePlateLettersFirst(plateRaw);

            return _TranslatedSearchHistoryItem(
              langCode: langCode,
              rawVehicle: rawVehicle,
              plate: plateDisplay,
              rawCustomer: customer.name,
              phone: customer.mobile,
              lastVisit: latestOrder != null
                  ? AppTranslationService.localizeDigitsForLanguage(
                vm.formatDate(latestOrder.createdAt),
                langCode,
              )
                  : l10n.posCommonNotAvailable,
              rawLastService: rawStatus,
              orderNumber: latestOrder?.id,
              isCorporate: customer.customerType.toLowerCase() == 'corporate',
              onContinue: () {
                final posVm = context.read<PosViewModel>();
                final isCorporateCustomer =
                    customer.customerType.toLowerCase() == 'corporate';
                posVm.clearCart();
                posVm.setCustomerData(
                  name: customer.name,
                  vat: customer.taxId ?? '',
                  mobile: customer.mobile,
                  vehicleNumber: vehicle?.plateNo ?? '',
                  vinNumber: vehicle?.vin ?? '',
                  make: vehicle?.make ?? '',
                  model: vehicle?.model ?? '',
                  odometer: latestOrder?.odometerReading ?? 0,
                  previousOrderId: latestOrder?.id,
                  vehicleYear: vehicle?.year ?? '',
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PosAddCustomerView(
                      initialTab: isCorporateCustomer ? 1 : 0,
                    ),
                  ),
                );
              },
              onViewHistory: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PosCustomerHistoryView(
                      customer: customer,
                      focusOrderId: latestOrder?.id,
                    ),
                  ),
                );
              },
              onSalesReturn: () {
                // Pre-fill the customer id, then push the screen. The search itself is
                // triggered from PosSalesReturnView.initState after the route is on screen
                // so any cross-branch error toast/banner renders in this view's scope
                // (otherwise the toast fires under the home screen and the navigation
                // transition swallows it).
                final returnVm = context.read<SalesReturnViewModel>();
                returnVm.clearSearchResults();
                returnVm.searchController.text = customer.id.toString();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PosSalesReturnView(showBackButton: true),
                  ),
                );
              },
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final availableW = constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : MediaQuery.sizeOf(context).width;
              final crossAxisCount = !isTablet
                  ? 1
                  : availableW >= 980
                  ? 3
                  : availableW >= 640
                  ? 2
                  : 1;
              final gap = keyboardOpen ? 8.0 : 10.0;

              final heading = Padding(
                padding: EdgeInsets.fromLTRB(
                  isTablet ? 0 : 6,
                  keyboardOpen ? 2 : 8,
                  isTablet ? 0 : 6,
                  keyboardOpen ? 8 : 12,
                ),
                child: Text(
                  l10n.posHomeRecentSearches,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: keyboardOpen
                        ? (isTablet ? 14 : 12.5)
                        : (isTablet ? 16 : 14),
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              );

              // Mobile (crossAxisCount==1): SliverList — each card takes its
              // natural height, overflow impossible.
              // Tablet multi-col: SliverList of IntrinsicHeight rows so row
              // height is driven by the tallest card, not a fixed extent.
              Widget buildGrid() {
                if (crossAxisCount == 1) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                        padding: EdgeInsets.only(bottom: gap),
                        child: buildCustomerCard(index),
                      ),
                      childCount: vm.searchedCustomers.length,
                    ),
                  );
                }
                final customers = vm.searchedCustomers;
                final rowCount = (customers.length / crossAxisCount).ceil();
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, rowIndex) {
                      final start = rowIndex * crossAxisCount;
                      final end = (start + crossAxisCount)
                          .clamp(0, customers.length);
                      final indices =
                      List.generate(end - start, (i) => start + i);
                      return Padding(
                        padding: EdgeInsets.only(bottom: gap),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (int i = 0; i < indices.length; i++) ...[
                                if (i > 0) SizedBox(width: gap),
                                Expanded(
                                    child: buildCustomerCard(indices[i])),
                              ],
                              for (int i = indices.length;
                              i < crossAxisCount;
                              i++) ...[
                                SizedBox(width: gap),
                                const Expanded(child: SizedBox.shrink()),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: rowCount,
                  ),
                );
              }

              return CustomScrollView(
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverToBoxAdapter(child: heading),
                  SliverPadding(
                    padding:
                    EdgeInsets.only(bottom: keyboardOpen ? 10 : 14),
                    sliver: buildGrid(),
                  ),
                ],
              );
            },
          );
        }

        // Show "No Results" only if we've actually searched for something and got nothing back
        if (vm.homeSearchController.text.isNotEmpty &&
            !vm.isSearchingCustomer) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Icon(
                  Icons.search_off_outlined,
                  size: 48,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.posHomeNoResults,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.posHomeNoResultsHint,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    // Reverting to previous compact style as requested
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.secondaryLight),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: AppColors.secondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Async-translating wrapper for SearchHistoryItem.
//
// WHY: SearchHistoryItem accepts plain String fields. API data arrives in
// English and must be translated to Arabic on the fly when the locale is Arabic.
// Using FutureBuilder here keeps the translation logic out of pos_widgets.dart
// and out of the ViewModel — each card translates independently, shows the
// raw (English) string instantly via initialData, then updates once the
// translation resolves. Re-renders automatically on locale switch because the
// ValueKey changes (langCode is part of the key).
// ─────────────────────────────────────────────────────────────────────────────

class _CustomerSearchShimmerList extends StatelessWidget {
  final bool isTablet;

  const _CustomerSearchShimmerList({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final count = isTablet ? 6 : 3;
    final gap = keyboardOpen ? 8.0 : 10.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableW = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final crossAxisCount = !isTablet
            ? 1
            : availableW >= 980
                ? 3
                : availableW >= 640
                    ? 2
                    : 1;

        Widget card() => _ShimmerCard(isTablet: isTablet);

        return PosShimmer(
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.only(top: keyboardOpen ? 8 : 14),
                sliver: crossAxisCount == 1
                    ? SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                            padding: EdgeInsets.only(bottom: gap),
                            child: card(),
                          ),
                          childCount: count,
                        ),
                      )
                    : SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: gap,
                          crossAxisSpacing: gap,
                          childAspectRatio: 2.35,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => card(),
                          childCount: count,
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  final bool isTablet;

  const _ShimmerCard({required this.isTablet});

  @override
  Widget build(BuildContext context) {

    final titleW = isTablet ? 150.0 : 135.0;
    final lineW = isTablet ? 210.0 : 190.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFE9EDF3),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: PosShimmerBox(width: titleW, height: 13)),
                        const SizedBox(width: 8),
                        PosShimmerBox(width: 42, height: 18, radius: 9),
                      ],
                    ),
                    const SizedBox(height: 9),
                    PosShimmerBox(width: lineW, height: 10),
                    const SizedBox(height: 8),
                    PosShimmerBox(width: lineW * 0.78, height: 10),
                    const SizedBox(height: 10),
                    PosShimmerBox(width: lineW * 0.65, height: 24, radius: 10),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: PosShimmerBox(width: double.infinity, height: 34, radius: 12)),
              const SizedBox(width: 8),
              Expanded(child: PosShimmerBox(width: double.infinity, height: 34, radius: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TranslatedSearchHistoryItem extends StatelessWidget {
  const _TranslatedSearchHistoryItem({
    required this.langCode,
    required this.rawVehicle,
    required this.plate,
    required this.rawCustomer,
    required this.phone,
    required this.lastVisit,
    required this.rawLastService,
    required this.isCorporate,
    this.orderNumber,
    this.onContinue,
    this.onViewHistory,
    this.onSalesReturn,
  });

  final String langCode;
  final String rawVehicle;
  final String plate;
  final String rawCustomer;
  final String phone;
  final String lastVisit;
  final String rawLastService;
  final bool isCorporate;
  final String? orderNumber;
  final VoidCallback? onContinue;
  final VoidCallback? onViewHistory;
  final VoidCallback? onSalesReturn;

  String _instantStatus(String status) {
    if (langCode != 'ar') return status;
    switch (status.trim().toLowerCase().replaceAll('_', ' ')) {
      case 'invoiced':
        return 'مفوتر';
      case 'completed':
      case 'complete':
        return 'مكتمل';
      case 'pending':
        return 'قيد الانتظار';
      case 'draft':
        return 'مسودة';
      case 'in progress':
      case 'inprogress':
        return 'قيد التنفيذ';
      case 'cancelled':
      case 'canceled':
        return 'ملغي';
      default:
        return AppTranslationService.localizeDigitsForLanguage(status, langCode);
    }
  }

  Future<_TranslatedStrings> _translate() async {
    final results = await Future.wait([
      AppTranslationService.localizedDynamicValueForLanguage(rawVehicle, langCode),
      AppTranslationService.localizedDynamicValueForLanguage(rawCustomer, langCode),
      AppTranslationService.localizedStatusForLanguage(rawLastService, langCode),
    ]);
    return _TranslatedStrings(
      vehicle: results[0],
      customer: results[1],
      lastService: results[2],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_TranslatedStrings>(
      // Key ensures translation re-runs when the locale changes.
      key: ValueKey<String>('$langCode::$rawVehicle::$rawCustomer::$rawLastService'),
      future: _translate(),
      initialData: _TranslatedStrings(
        vehicle: AppTranslationService.localizeDigitsForLanguage(rawVehicle, langCode),
        customer: rawCustomer,
        lastService: _instantStatus(rawLastService),
      ),
      builder: (context, snapshot) {
        final t = snapshot.data!;
        return SearchHistoryItem(
          vehicle: t.vehicle,
          plate: plate,
          customer: t.customer,
          phone: phone,
          lastVisit: lastVisit,
          lastService: t.lastService,
          orderNumber: orderNumber,
          isCorporate: isCorporate,
          onContinue: onContinue,
          onViewHistory: onViewHistory,
          onSalesReturn: onSalesReturn,
        );
      },
    );
  }
}

class _TranslatedStrings {
  const _TranslatedStrings({
    required this.vehicle,
    required this.customer,
    required this.lastService,
  });
  final String vehicle;
  final String customer;
  final String lastService;
}
