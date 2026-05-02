import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_colors.dart';
import '../../widgets/widgets.dart';
import '../../services/session_service.dart';
import '../Workshop pos app/Login/login_view.dart';
import '../Workshop pos app/More Tab/settings_view_model.dart';
import '../Locker App/Auth/locker_login_view.dart';
import '../Locker App/Dashboard/locker_dashboard_view.dart';
import '../Workshop Owner/Auth/owner_login_view.dart';
import '../Workshop Owner/owner_shell.dart';
import '../Technician App/Auth/tech_login_view.dart';
import '../Super Admin/Auth/super_admin_login_view.dart';
import '../supplier/supplier_shell.dart';
import '../supplier/Login/supplier_login_view.dart';

class MenuView extends StatelessWidget {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isLandscape = screenWidth > screenHeight;

    final crossAxisCount = isTablet ? (isLandscape ? 3 : 2) : 2;
    final childAspectRatio = isTablet ? (isLandscape ? 1.15 : 1.15) : 0.85;
    final horizontalPadding = isTablet
        ? screenWidth * (isLandscape ? 0.1 : 0.15)
        : 24.0;

    final double iconContainerSize = isTablet ? 50 : 40;
    final double iconSize = isTablet ? 30 : 22;

    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(isTablet ? 1.4 : 1.0)),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              // ── Layer 1 & 2: Custom Header & Grid ──
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CustomAuthHeader(
                    title: 'ALL Apps',
                    subtitle: 'Please choose one of these apps',
                    height: isTablet ? (isLandscape ? screenHeight * 0.50 : null) : null,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: isTablet ? (isLandscape ? screenHeight * 0.32 : screenHeight * 0.25) : screenHeight * 0.22,
                      left: horizontalPadding,
                      right: horizontalPadding,
                    ),
                    child: GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: childAspectRatio,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        MenuCard(
                          title: 'Super Admin\nPortal',
                          icon: Icons.admin_panel_settings_rounded,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SuperAdminLoginView(),
                              ),
                            );
                          },
                        ),
                        MenuCard(
                          title: 'Workshop\nOwner',
                          icon: Icons.store_rounded,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const OwnerLoginView(),
                              ),
                            );
                          },
                        ),
                        MenuCard(
                          title: 'Technician\nApp',
                          icon: Icons.engineering_rounded,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TechLoginView(),
                              ),
                            );
                          },
                        ),
                        MenuCard(
                          title: 'Workshop\nPOS App',
                          icon: Icons.point_of_sale_rounded,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginView(
                                    appName: 'Workshop POS App'),
                              ),
                            );
                          },
                        ),
                        MenuCard(
                          title: 'Locker\nPortal',
                          icon: Icons.lock_rounded,
                          onTap: () async {
                            final isLoggedIn =
                            await SessionService().isLoggedIn(role: 'locker');
                            if (!context.mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => isLoggedIn
                                    ? const LockerDashboardView()
                                    : const LockerLoginView(),
                              ),
                            );
                          },
                        ),
                        MenuCard(
                          title: 'Supplier',
                          icon: Icons.local_shipping_rounded,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SupplierLoginView(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // ── Layer 3: Version footer ──
              Center(
                child: Text(
                  'Version: 1.0.0',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
                ),
              ),

              SizedBox(
                height: 24 + MediaQuery.of(context).padding.bottom,
              ),
            ],
          ),
        ),
      ),
    );
  }
}