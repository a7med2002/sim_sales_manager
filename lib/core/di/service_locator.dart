import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/companies/presentation/cubit/companies_cubit.dart';
import '../../features/customers/presentation/cubit/customers_cubit.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../catalog/company_catalog.dart';
import '../catalog/customer_catalog.dart';
import '../config/env.dart';
import '../database/app_database.dart';
import '../settings/settings_cubit.dart';
import '../sync/bloc/sync_bloc.dart';
import '../sync/connectivity_service.dart';
import '../sync/sync_engine.dart';

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
  }
  getIt.registerLazySingleton<SyncBloc>(
    () => SyncBloc(
      connectivity: getIt<ConnectivityService>(),
      engine: Env.isConfigured ? getIt<SyncEngine>() : null,
    ),
  );

  getIt.registerLazySingleton<HomeCubit>(() => HomeCubit());
  getIt.registerLazySingleton<CompaniesCubit>(() => CompaniesCubit());
  getIt.registerLazySingleton<CustomersCubit>(() => CustomersCubit());
  getIt.registerLazySingleton<ProfileCubit>(() => ProfileCubit());
  getIt.registerLazySingleton<SettingsCubit>(() => SettingsCubit());

  getIt.registerLazySingleton<CompanyCatalog>(() => getIt<CompaniesCubit>());
  getIt.registerLazySingleton<CustomerCatalog>(() => getIt<CustomersCubit>());
}
