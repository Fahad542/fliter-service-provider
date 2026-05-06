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

class PosHomeView extends StatelessWidget {
  const PosHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final langCode = Localizations.localeOf(context).languageCode;
    final isTablet = MediaQuery.of(context).size.width > 600;
    final vm = context.watch<PosViewModel>();

    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: PosTabletLayout.textScaler(context)),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        resizeToAvoidBottomInset: false,
        appBar: PosAppBar(
          userName: vm.cashierName,
          infoTitle: vm.workshopName,
          infoBranch: l10n.posHomeBranchPrefix(vm.branchName),
          infoTime: AppTranslationService.localizeDigitsForLanguage(DateFormat('dd MMM yyyy · hh:mm a', langCode).format(DateTime.now()), langCode),
          onMenuPressed: () => PosShellScaffoldRegistry.openDrawer(),
        ),
        body: wrapPosShellRailBody(
          context,
          GestureDetector(
            onTap: () {
              if (vm.homeSearchController.text.isEmpty) {
                vm.homeSearchFocusNode.unfocus();
              }
            },
            child: Column(
              children: [
                // 2. Custom Info Bar (Merged into AppBar)

                // 3. Main Content
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 24),
                  child: Column(
                    children: [
                      SizedBox(height: isTablet ? 18 : 24),
                      // Title
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: l10n.posHomeTitleFilter,
                              style: AppTextStyles.h1.copyWith(
                                color: AppColors.primaryLight,
                                fontSize: isTablet ? 36 : 34,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: l10n.posHomeTitlePos,
                              style: AppTextStyles.h1.copyWith(
                                color: AppColors.secondaryLight,
                                fontSize: isTablet ? 36 : 34,
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
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Search bar
                      PosSearchBar(
                        controller: vm.homeSearchController,
                        focusNode: vm.homeSearchFocusNode,
                        hintText:
                        l10n.posHomeSearchHint,
                        onChanged: (val) => vm.handleSearchDebounce(val),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildActionChip(
                            context: context,
                            icon: Icons.add,
                            label: l10n.posHomeNewWalkIn,
                            onTap: () {
                              context.read<PosViewModel>().clearCustomerData();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const PosAddCustomerView(initialTab: 0),
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
                      const SizedBox(height: 12),
                    ],
                  ),
                ),

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
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (vm.searchedCustomers.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 10, 6, 14),
                child: Text(
                  l10n.posHomeRecentSearches,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(2, 0, 2, 12),
                  itemCount: isTablet
                      ? (vm.searchedCustomers.length / 3).ceil()
                      : vm.searchedCustomers.length,
                  itemBuilder: (context, rowIndex) {
                    Widget buildCustomerCard(int index) {
                      final customer = vm.searchedCustomers[index];
                      final latestOrder = customer.orders.isNotEmpty
                          ? customer.orders.first
                          : null;
                      final vehicle = latestOrder?.vehicle;
                      final langCode = Localizations.localeOf(context).languageCode;

                      // Raw API strings that need Arabic translation
                      final rawVehicle = vehicle != null
                          ? '${vehicle.make} ${vehicle.model}'
                          '${(vehicle.year != null && vehicle.year!.isNotEmpty) ? ' · ${vehicle.year}' : ''}'
                          : l10n.posHomeNoVehicle;
                      final rawStatus = latestOrder?.status.toUpperCase() ?? l10n.posCommonNotAvailable;

                      return _TranslatedSearchHistoryItem(
                        langCode: langCode,
                        rawVehicle: rawVehicle,
                        plate: vehicle?.plateNo ?? l10n.posCommonNotAvailable,
                        rawCustomer: customer.name,
                        phone: customer.mobile,
                        lastVisit: latestOrder != null
                            ? AppTranslationService.localizeDigitsForLanguage(vm.formatDate(latestOrder.createdAt), langCode)
                            : l10n.posCommonNotAvailable,
                        rawLastService: rawStatus,
                        orderNumber: latestOrder?.id,
                        isCorporate:
                        customer.customerType.toLowerCase() == 'corporate',
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
                          final returnVm = context.read<SalesReturnViewModel>();
                          returnVm.searchController.text = customer.id.toString();
                          returnVm.searchInvoice();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PosSalesReturnView(showBackButton: true),
                            ),
                          );
                        },
                      );
                    }

                    if (!isTablet) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: buildCustomerCard(rowIndex),
                      );
                    }

                    final i0 = rowIndex * 3;
                    final i1 = i0 + 1;
                    final i2 = i0 + 2;
                    final n = vm.searchedCustomers.length;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: i0 < n
                                ? buildCustomerCard(i0)
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: i1 < n
                                ? buildCustomerCard(i1)
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: i2 < n
                                ? buildCustomerCard(i2)
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }

        // Show "No Results" only if we've actually searched for something and got nothing back
        if (vm.homeSearchController.text.isNotEmpty &&
            !vm.isSearchingCustomer) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
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
          horizontal: 16,
          vertical: 10,
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