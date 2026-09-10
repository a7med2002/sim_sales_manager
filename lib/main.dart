import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/auth/auth_service.dart';
import 'core/config/env.dart';
import 'core/database/app_database.dart';
import 'core/di/service_locator.dart';
import 'core/navigation/new_sale_launcher.dart';
import 'core/navigation/route_names.dart';
import 'core/sync/bloc/sync_bloc.dart';
import 'core/sync/bloc/sync_event.dart';
import 'core/sync/connectivity_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/cubit/theme_cubit.dart';
import 'features/activity_log/presentation/pages/activity_log_page.dart';
import 'features/admin/presentation/pages/admin_company_catalog_page.dart';
import 'features/admin/presentation/pages/admin_hub_page.dart';
import 'features/admin/presentation/pages/admin_support_feedback_page.dart';
import 'features/admin/presentation/pages/admin_users_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/companies/presentation/pages/companies_page.dart';
import 'features/customers/presentation/pages/customers_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/more/presentation/pages/more_page.dart';
import 'features/new_sale/presentation/pages/new_sale_sheet.dart';
import 'features/number_update/presentation/pages/number_update_page.dart';
import 'features/numbers/presentation/pages/numbers_page.dart';
import 'features/auth/presentation/pages/reset_password_page.dart';
import 'features/profits/presentation/pages/profits_page.dart';
import 'features/reports/presentation/pages/reports_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'features/shipments_operations/presentation/pages/shipments_operations_page.dart';
import 'features/support_feedback/presentation/pages/support_feedback_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Only connects when real project credentials are supplied via
  // `--dart-define` (see core/config/env.dart) — otherwise the app runs
  // fully offline against the local Drift database, per CLAUDE.md's
  // offline-first rule.
  var startRoute = RouteNames.login;
  if (Env.isConfigured) {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabaseAnonKey,
    );

    // Needed below to read/write the cached role and check real
    // connectivity — safe to set up this early, before the rest of DI,
    // since neither depends on anything else in the container.
    setupServiceLocator();

    // `Supabase.initialize` already restores any previously-persisted
    // session (supabase_flutter stores it locally by default) before
    // this line runs — so a non-null `currentSession` here means the
    // user is genuinely still signed in, not just that a stale session
    // object happens to exist in memory. Skip Login straight to Home in
    // that case, instead of always forcing a fresh sign-in on every app
    // launch regardless of session state.
    final ownerId = Supabase.instance.client.auth.currentSession?.user.id;
    if (ownerId != null) {
      startRoute = RouteNames.home;
      // An admin account never sees the seller shell — same routing
      // decision `LoginCubit.submit()` makes right after a fresh
      // sign-in. Read whatever role was cached from the last successful
      // fetch first (instant, no network) so a returning admin lands on
      // the right shell even fully offline, then only attempt a fresh
      // fetch when there's real connectivity to back it — otherwise
      // this used to block the very first frame on the platform's long
      // default connect timeout for nothing (see ConnectivityService's
      // doc comment on why a plain `connectivity_plus` check isn't
      // enough on its own).
      final db = getIt<AppDatabase>();
      var role = await _readCachedRole(db, ownerId);
      if (await getIt<ConnectivityService>().isOnline) {
        try {
          role = await AuthService(Supabase.instance.client).fetchCurrentRole();
          unawaited(_cacheRole(db, ownerId, role));
        } catch (_) {
          // Falls back to the cached role read above.
        }
      }
      if (role == 'admin') startRoute = RouteNames.adminHub;
    }
  } else {
    setupServiceLocator();
  }

  getIt<SyncBloc>().add(const SyncStarted());
  NewSaleLauncher.register((context) => NewSaleSheet.show(context));
  runApp(SimSalesManagerApp(initialRoute: startRoute));
}

Future<String?> _readCachedRole(AppDatabase db, String ownerId) async {
  try {
    final row = await (db.select(db.settingsTable)..where((t) => t.ownerId.equals(ownerId))).getSingleOrNull();
    return row?.cachedRole;
  } catch (_) {
    return null;
  }
}

Future<void> _cacheRole(AppDatabase db, String ownerId, String role) async {
  try {
    await db.into(db.settingsTable).insertOnConflictUpdate(
          SettingsTableCompanion.insert(ownerId: ownerId, updatedAt: DateTime.now(), cachedRole: Value(role)),
        );
  } catch (_) {
    // Best-effort cache write — a miss here just means the next offline
    // cold start falls back to Login-decided-nothing (stays on the
    // seller shell), same as before this existed.
  }
}

class SimSalesManagerApp extends StatefulWidget {
  final String initialRoute;

  const SimSalesManagerApp({super.key, this.initialRoute = RouteNames.login});

  @override
  State<SimSalesManagerApp> createState() => _SimSalesManagerAppState();
}

class _SimSalesManagerAppState extends State<SimSalesManagerApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    // Supabase's own deep link handling (bundled `app_links`, see
    // `core/config/deep_links.dart`) exchanges the "reset password" email
    // link for a temporary session and fires this event — push the "set
    // new password" screen when it does. Only relevant once a real
    // Supabase project is configured (`main()` only calls
    // `Supabase.initialize` in that case).
    if (Env.isConfigured) {
      _authSubscription = Supabase.instance.client.auth.onAuthStateChange
          .listen((data) {
            if (data.event == AuthChangeEvent.passwordRecovery) {
              _navigatorKey.currentState?.pushNamed(RouteNames.resetPassword);
            }
          });
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

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
              navigatorKey: _navigatorKey,
              title: 'eSIM Dafter',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeMode,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              initialRoute: widget.initialRoute,
              routes: {
                RouteNames.login: (_) => const LoginPage(),
                RouteNames.resetPassword: (_) => const ResetPasswordPage(),
                RouteNames.home: (_) => const HomePage(),
                RouteNames.companies: (_) => const CompaniesPage(),
                RouteNames.customers: (_) => const CustomersPage(),
                RouteNames.more: (_) => const MorePage(),
                RouteNames.settings: (_) => const SettingsPage(),
                RouteNames.numbers: (_) => const NumbersPage(),
                RouteNames.activityLog: (_) => const ActivityLogPage(),
                RouteNames.supportFeedback: (_) => const SupportFeedbackPage(),
                RouteNames.profits: (_) => const ProfitsPage(),
                RouteNames.reports: (_) => const ReportsPage(),
                RouteNames.shipmentsOperations: (_) =>
                    const ShipmentsOperationsPage(),
                RouteNames.numberUpdate: (_) => const NumberUpdatePage(),
                RouteNames.adminHub: (_) => const AdminHubPage(),
                RouteNames.adminCompanyCatalog: (_) =>
                    const AdminCompanyCatalogPage(),
                RouteNames.adminUsers: (_) => const AdminUsersPage(),
                RouteNames.adminSupportFeedback: (_) =>
                    const AdminSupportFeedbackPage(),
              },
            );
          },
        ),
      ),
    );
  }
}
