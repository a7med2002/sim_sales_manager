import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/companies/presentation/cubit/companies_cubit.dart';
import '../../features/customers/presentation/cubit/customers_cubit.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../activity_log/activity_logger.dart';
import '../auth/auth_service.dart';
import '../catalog/company_catalog.dart';
import '../catalog/customer_catalog.dart';
import '../config/env.dart';
import '../database/app_database.dart';
import '../notifications/notifications_cubit.dart';
import '../settings/settings_cubit.dart';
import '../sync/bloc/sync_bloc.dart';
import '../sync/connectivity_service.dart';
import '../sync/sync_engine.dart';
import '../update/update_cubit.dart';

/// Composition root: this is the one place in `core/` allowed to know
/// about concrete feature Cubits — it wires them up as app-lifetime
/// singletons so state survives navigating between tabs, and exposes the
/// narrow `CompanyCatalog`/`CustomerCatalog` interfaces (same instances)
/// for features that only need read/write access, not the full Cubit API.
final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());
  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());

  // `SyncEngine` needs a live Supabase session, so it's only registered
  // once `Env.isConfigured` — until real project credentials are supplied
  // (see core/config/env.dart), the app runs fully offline against Drift
  // and `SyncBloc` just reports `offline` forever, never null-checking.
  if (Env.isConfigured) {
    getIt.registerLazySingleton<SyncEngine>(() => SyncEngine(Supabase.instance.client, getIt<AppDatabase>()));
    getIt.registerLazySingleton<AuthService>(() => AuthService(Supabase.instance.client));
  }
  getIt.registerLazySingleton<SyncBloc>(
    () => SyncBloc(
      connectivity: getIt<ConnectivityService>(),
      engine: Env.isConfigured ? getIt<SyncEngine>() : null,
      auth: Env.isConfigured ? getIt<AuthService>() : null,
    ),
  );

  getIt.registerLazySingleton<ActivityLogger>(() => ActivityLogger());
  getIt.registerLazySingleton<UpdateCubit>(() => UpdateCubit());
  getIt.registerLazySingleton<NotificationsCubit>(() => NotificationsCubit());

  getIt.registerLazySingleton<CompaniesCubit>(() => CompaniesCubit());
  getIt.registerLazySingleton<CustomersCubit>(() => CustomersCubit());
  getIt.registerLazySingleton<ProfileCubit>(() => ProfileCubit());
  getIt.registerLazySingleton<SettingsCubit>(() => SettingsCubit());

  getIt.registerLazySingleton<CompanyCatalog>(() => getIt<CompaniesCubit>());
  getIt.registerLazySingleton<CustomerCatalog>(() => getIt<CustomersCubit>());

  // Reads through the catalog interfaces above, same as Profits/Reports —
  // registered after them so `getIt<CompanyCatalog>()`/`getIt<CustomerCatalog>()`
  // resolve to the same instances those pages already share.
  getIt.registerLazySingleton<HomeCubit>(
    () => HomeCubit(
      customerCatalog: getIt<CustomerCatalog>(),
      companyCatalog: getIt<CompanyCatalog>(),
      profileCubit: getIt<ProfileCubit>(),
    ),
  );
}
