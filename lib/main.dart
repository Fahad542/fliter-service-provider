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
import 'views/Login/login_view_model.dart';
import 'views/Navbar/pos_shell.dart';
// import 'data/repositories/department_repository.dart';
import 'data/repositories/pos_repository.dart';
// import 'views/Department/department_view_model.dart';
import 'views/Workshop pos app/Technician Screen/technician_view_model.dart';
import 'views/Workshop pos app/Corporate Bookings/corporate_booking_view_model.dart';
import 'views/Workshop pos app/Notifications/notifications_view_model.dart';
import 'views/Workshop pos app/Petty Cash/petty_cash_view_model.dart';
import 'views/Workshop pos app/Store Closing/store_closing_view_model.dart';
import 'views/Workshop pos app/Promo/promo_view_model.dart';
import 'views/Workshop pos app/Product Grid/product_grid_view_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
       // Provider<FilterRepository>(create: (_) => FilterRepository()),
        Provider<AuthRepository>(create: (_) => AuthRepository()),
        Provider<SessionService>(create: (_) => SessionService()),
        ChangeNotifierProvider<SettingsViewModel>(create: (_) => SettingsViewModel()),
        Provider<PosRepository>(create: (_) => PosRepository()),
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
      ],
      child: Consumer<SettingsViewModel>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Workshop Portal',
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
            
            home: FutureBuilder<bool>(
              future: context.read<SessionService>().isLoggedIn(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.data == true) {
                  return const PosShell();
                }
                return const MenuView();
              },
            ),
          );
        },
      ),
    );
  }
}
