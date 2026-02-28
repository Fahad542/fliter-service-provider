import 'package:filter_service_providers/views/Workshop%20pos%20app/Department/department_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
// import 'data/repositories/filter_repository.dart';
import 'views/Workshop pos app/More Tab/settings_view_model.dart';
import 'views/Workshop pos app/Home Screen/pos_view_model.dart';
import 'views/Menu/menu_view.dart';
import 'utils/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'services/session_service.dart';
import 'views/Workshop pos app/Login/login_view_model.dart';
import 'views/Workshop pos app/Navbar/pos_shell.dart';
import 'views/Workshop Owner/owner_shell.dart';
// import 'data/repositories/department_repository.dart';
import 'data/repositories/pos_repository.dart';
import 'data/repositories/owner_repository.dart';
// import 'views/Department/department_view_model.dart';
import 'views/Workshop pos app/Technician Screen/technician_view_model.dart';
import 'views/Workshop pos app/Corporate Bookings/corporate_booking_view_model.dart';
import 'views/Workshop pos app/Notifications/notifications_view_model.dart';
import 'views/Workshop pos app/Petty Cash/petty_cash_view_model.dart';
import 'views/Workshop pos app/Store Closing/store_closing_view_model.dart';
import 'views/Workshop pos app/Promo/promo_view_model.dart';
import 'views/Workshop pos app/Product Grid/product_grid_view_model.dart';
import 'views/Workshop pos app/Sales Return/sales_return_view_model.dart';
import 'views/Workshop Owner/Dashboard/owner_dashboard_view_model.dart';
import 'views/Workshop Owner/Branches/branch_management_view_model.dart';
import 'views/Workshop Owner/Employees/employee_management_view_model.dart';
import 'views/Workshop Owner/Corporate/corporate_management_view_model.dart';
import 'views/Workshop Owner/Inventory/inventory_management_view_model.dart';
import 'views/Workshop Owner/Billing/billing_management_view_model.dart';
import 'views/Workshop Owner/Departments/department_management_view_model.dart';
import 'views/Workshop owner/Suppliers/suppliers_view_model.dart';
import 'views/Workshop Owner/Auth/owner_login_view_model.dart';
import 'views/Technician App/technician_view_model.dart';
import 'views/Locker App/locker_view_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

/// Checks which portal was last used and whether its session is still valid.
/// Returns the portal name string ('owner', 'cashier') or null if no session.
Future<String?> _resolveStartScreen(SessionService session) async {
  final lastPortal = await session.getLastPortal();
  if (lastPortal == null) return null;
  final isLoggedIn = await session.isLoggedIn(role: lastPortal);
  return isLoggedIn ? lastPortal : null;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>(create: (_) => AuthRepository()),
        Provider<SessionService>(create: (_) => SessionService()),
        Provider<OwnerRepository>(create: (_) => OwnerRepository()),
        ChangeNotifierProvider<SettingsViewModel>(create: (_) => SettingsViewModel()),
        Provider<PosRepository>(create: (_) => PosRepository()),
        ChangeNotifierProvider<LoginViewModel>(
          create: (context) => LoginViewModel(
            authRepository: context.read<AuthRepository>(),
            sessionService: context.read<SessionService>(),
          ),
        ),

        ChangeNotifierProxyProvider2<PosRepository, SessionService, DepartmentViewModel>(
          create: (context) => DepartmentViewModel(
            departmentRepository: context.read<PosRepository>(),
            sessionService: context.read<SessionService>(),
          ),
          update: (context, deptRepo, sessionService, previous) =>
              previous ?? DepartmentViewModel(departmentRepository: deptRepo, sessionService: sessionService),
        ),
        ChangeNotifierProxyProvider2<PosRepository, SessionService, PosViewModel>(
          create: (context) => PosViewModel(
            posRepository: context.read<PosRepository>(),
            sessionService: context.read<SessionService>(),
          ),
          update: (context, posRepo, sessionService, previous) =>
              previous ??
              PosViewModel(
                  posRepository: posRepo, sessionService: sessionService),
        ),
        ChangeNotifierProxyProvider2<PosRepository, SessionService,
            TechnicianViewModel>(
          create: (context) => TechnicianViewModel(
            posRepository: context.read<PosRepository>(),
            sessionService: context.read<SessionService>(),
          ),
          update: (context, posRepo, sessionService, previous) =>
              previous ??
              TechnicianViewModel(
                  posRepository: posRepo, sessionService: sessionService),
        ),
        ChangeNotifierProvider<CorporateBookingViewModel>(
          create: (_) => CorporateBookingViewModel(),
        ),
        ChangeNotifierProvider<NotificationsViewModel>(
          create: (_) => NotificationsViewModel(),
        ),
        ChangeNotifierProxyProvider2<PosRepository, SessionService, PettyCashViewModel>(
          create: (context) => PettyCashViewModel(
            posRepository: context.read<PosRepository>(),
            sessionService: context.read<SessionService>(),
          ),
          update: (context, posRepo, sessionService, previous) =>
              previous ?? PettyCashViewModel(posRepository: posRepo, sessionService: sessionService),
        ),
        ChangeNotifierProvider<StoreClosingViewModel>(
          create: (_) => StoreClosingViewModel(),
        ),
        ChangeNotifierProxyProvider2<PosRepository, SessionService, PromoViewModel>(
          create: (context) => PromoViewModel(
            posRepository: context.read<PosRepository>(),
            sessionService: context.read<SessionService>(),
          ),
          update: (context, posRepo, sessionService, previous) =>
              previous ?? PromoViewModel(posRepository: posRepo, sessionService: sessionService),
        ),
        ChangeNotifierProvider<ProductGridViewModel>(
          create: (_) => ProductGridViewModel(),
        ),
        ChangeNotifierProxyProvider2<PosRepository, SessionService, SalesReturnViewModel>(
          create: (context) => SalesReturnViewModel(
            posRepository: context.read<PosRepository>(),
            sessionService: context.read<SessionService>(),
          ),
          update: (context, posRepo, sessionService, previous) =>
              previous ?? SalesReturnViewModel(posRepository: posRepo, sessionService: sessionService),
        ),
        ChangeNotifierProvider<OwnerDashboardViewModel>(create: (_) => OwnerDashboardViewModel()),
        ChangeNotifierProxyProvider2<OwnerRepository, SessionService, BranchManagementViewModel>(
          create: (context) => BranchManagementViewModel(
            ownerRepository: context.read<OwnerRepository>(),
            sessionService: context.read<SessionService>(),
          ),
          update: (context, ownerRepo, sessionService, previous) =>
              previous ?? BranchManagementViewModel(ownerRepository: ownerRepo, sessionService: sessionService),
        ),
        ChangeNotifierProxyProvider2<OwnerRepository, SessionService, EmployeeManagementViewModel>(
          create: (context) => EmployeeManagementViewModel(
            ownerRepository: context.read<OwnerRepository>(),
            sessionService: context.read<SessionService>(),
          ),
          update: (context, ownerRepo, sessionService, previous) =>
              previous ?? EmployeeManagementViewModel(ownerRepository: ownerRepo, sessionService: sessionService),
        ),
        ChangeNotifierProxyProvider2<OwnerRepository, SessionService, CorporateManagementViewModel>(
          create: (context) => CorporateManagementViewModel(
            ownerRepository: context.read<OwnerRepository>(),
            sessionService: context.read<SessionService>(),
          ),
          update: (context, ownerRepo, sessionService, previous) =>
              previous ?? CorporateManagementViewModel(ownerRepository: ownerRepo, sessionService: sessionService),
        ),
        ChangeNotifierProxyProvider2<OwnerRepository, SessionService, InventoryManagementViewModel>(
          create: (context) => InventoryManagementViewModel(
            ownerRepository: context.read<OwnerRepository>(),
            sessionService: context.read<SessionService>(),
          ),
          update: (context, ownerRepo, sessionService, previous) =>
              previous ?? InventoryManagementViewModel(ownerRepository: ownerRepo, sessionService: sessionService),
        ),
        ChangeNotifierProvider<BillingManagementViewModel>(create: (_) => BillingManagementViewModel()),
        ChangeNotifierProxyProvider2<OwnerRepository, SessionService, DepartmentManagementViewModel>(
          create: (context) => DepartmentManagementViewModel(
            ownerRepository: context.read<OwnerRepository>(),
            sessionService: context.read<SessionService>(),
          ),
          update: (context, ownerRepo, sessionService, previous) =>
              previous ?? DepartmentManagementViewModel(ownerRepository: ownerRepo, sessionService: sessionService),
        ),
        ChangeNotifierProxyProvider2<OwnerRepository, SessionService, SuppliersViewModel>(
          create: (context) => SuppliersViewModel(
            ownerRepository: context.read<OwnerRepository>(),
            sessionService: context.read<SessionService>(),
          ),
          update: (context, ownerRepo, sessionService, previous) =>
              previous ?? SuppliersViewModel(ownerRepository: ownerRepo, sessionService: sessionService),
        ),
        ChangeNotifierProvider<TechAppViewModel>(
          create: (_) => TechAppViewModel()..init(),
        ),
        ChangeNotifierProvider<LockerViewModel>(
          create: (_) => LockerViewModel()..init(),
        ),
        ChangeNotifierProvider<OwnerLoginViewModel>(
          create: (context) => OwnerLoginViewModel(
            authRepository: context.read<AuthRepository>(),
            sessionService: context.read<SessionService>(),
          ),
        ),
      ],
      child: Consumer<SettingsViewModel>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Workshop Owner',
            debugShowCheckedModeBanner: false,
            // Theme Configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            
            // Localization Configuration
            locale: settings.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('ar'), // Arabic
            ],
            
            home: FutureBuilder<String?>(
              future: _resolveStartScreen(context.read<SessionService>()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                switch (snapshot.data) {
                  case 'owner':
                    return const OwnerShell();
                  case 'cashier':
                    return const PosShell();
                  default:
                    return const MenuView();
                }
              },
            ),
          );
        },
      ),
    );
  }
}
