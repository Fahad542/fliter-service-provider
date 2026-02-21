import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_colors.dart';
import '../../widgets/widgets.dart';
import '../Workshop pos app/More Tab/settings_view_model.dart';
import '../Login/login_view.dart';

class MenuView extends StatelessWidget {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final crossAxisCount = 2; // Fixed 2 columns for both (clean 2x2 grid on tablet)
    final childAspectRatio = isTablet ? 1.15 : 0.85;
    final horizontalPadding = isTablet ? screenWidth * 0.15 : 24.0; // Reduced padding to make cards larger (70% width)

    final double iconContainerSize = isTablet ? 50 : 40;
    final double iconSize = isTablet ? 30 : 22;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(isTablet ? 1.4 : 1.0),
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // ── Layer 1: Custom Header ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: const CustomAuthHeader(
              title: 'ALL Apps',
              subtitle: 'Please choose one of these apps',
            ),
          ),

          Positioned(
            top: screenHeight * (isTablet ? 0.25 : 0.22), // Pushed down for mobile to clear text
            left: horizontalPadding,
            right: horizontalPadding,
            bottom: 60,
            child: GridView.count(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: childAspectRatio,
              physics: const BouncingScrollPhysics(),
              children: [
                MenuCard(
                  title: 'Workshop\nPortal',
                  icon: Icons.store_rounded,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming Soon'), duration: Duration(seconds: 1)),
                    );
                  },
                ),
                MenuCard(
                  title: 'Multi Branch\nView',
                  icon: Icons.domain_rounded,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming Soon'), duration: Duration(seconds: 1)),
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
                        builder: (_) => const LoginView(appName: 'Workshop POS App'),
                      ),
                    );
                  },
                ),
                MenuCard(
                  title: 'Supplier\nPortal',
                  icon: Icons.inventory_2_rounded,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming Soon'), duration: Duration(seconds: 1)),
                    );
                  },
                ),
              ],
            ),
          ),

          // ── Layer 3: Version footer ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Center(
              child: Text(
                'Version: 1.0.0',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
