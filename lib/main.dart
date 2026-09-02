import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/env.dart';
import 'core/di/service_locator.dart';
import 'core/navigation/new_sale_launcher.dart';
import 'core/navigation/route_names.dart';
import 'core/sync/bloc/sync_bloc.dart';
import 'core/sync/bloc/sync_event.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/cubit/theme_cubit.dart';
import 'features/activity_log/presentation/pages/activity_log_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/companies/presentation/pages/companies_page.dart';
import 'features/customers/presentation/pages/customers_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/more/presentation/pages/more_page.dart';
import 'features/new_sale/presentation/pages/new_sale_sheet.dart';
import 'features/number_update/presentation/pages/number_update_page.dart';
import 'features/numbers/presentation/pages/numbers_page.dart';
import 'features/profits/presentation/pages/profits_page.dart';
import 'features/reports/presentation/pages/reports_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'features/shipments_operations/presentation/pages/shipments_operations_page.dart';
import 'features/support_feedback/presentation/pages/support_feedback_page.dart';
import 'features/trusted_devices/presentation/pages/trusted_devices_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Only connects when real project credentials are supplied via
  // `--dart-define` (see core/config/env.dart) — otherwise the app runs
  // fully offline against the local Drift database, per CLAUDE.md's
  // offline-first rule.
  if (Env.isConfigured) {
    await Supabase.initialize(url: Env.supabaseUrl, publishableKey: Env.supabaseAnonKey);
  }

  setupServiceLocator();
  getIt<SyncBloc>().add(const SyncStarted());
  NewSaleLauncher.register((context) => NewSaleSheet.show(context));
  runApp(const SimSalesManagerApp());
}

class SimSalesManagerApp extends StatelessWidget {
  const SimSalesManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      child: BlocProvider(
        create: (_) => ThemeCubit(),
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp(
              title: 'SIM Sales Manager',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeMode,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              initialRoute: RouteNames.login,
              routes: {
                RouteNames.login: (_) => const LoginPage(),
                RouteNames.home: (_) => const HomePage(),
                RouteNames.companies: (_) => const CompaniesPage(),
                RouteNames.customers: (_) => const CustomersPage(),
                RouteNames.more: (_) => const MorePage(),
                RouteNames.settings: (_) => const SettingsPage(),
                RouteNames.numbers: (_) => const NumbersPage(),
                RouteNames.activityLog: (_) => const ActivityLogPage(),
                RouteNames.trustedDevices: (_) => const TrustedDevicesPage(),
                RouteNames.supportFeedback: (_) => const SupportFeedbackPage(),
                RouteNames.profits: (_) => const ProfitsPage(),
                RouteNames.reports: (_) => const ReportsPage(),
                RouteNames.shipmentsOperations: (_) => const ShipmentsOperationsPage(),
                RouteNames.numberUpdate: (_) => const NumberUpdatePage(),
              },
            );
          },
        ),
      ),
    );
  }
}
