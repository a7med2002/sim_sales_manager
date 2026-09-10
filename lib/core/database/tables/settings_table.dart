import 'package:drift/drift.dart';

import 'tenant_columns.dart';

/// One row per seller — `ownerId` (from [TenantColumns]) is the primary
/// key itself rather than a separate `id`, since there's exactly one
/// settings row per account.
class SettingsTable extends Table with TenantColumns {
  @override
  String get tableName => 'settings';

  TextColumn get currencySymbol => text().withDefault(const Constant('₪'))();
  TextColumn get themePreference => text().withDefault(const Constant('system'))();
  // A device-local cache of `profiles.display_name`, refreshed whenever
  // `ProfileCubit` fetches it successfully — purely local, never pushed
  // to or pulled from Supabase (see sync_engine.dart's settings mapping,
  // which deliberately excludes it), so it can't conflict with the real
  // source of truth. Read only as a cold-start-while-offline fallback,
  // so "Welcome back" shows the seller's actual last-known name instead
  // of their email when there's no time to fetch it fresh.
  TextColumn get cachedDisplayName => text().nullable()();

  // A device-local cache of `profiles.role` ('seller'/'admin'), same
  // reasoning and lifecycle as `cachedDisplayName` above — refreshed
  // whenever `AuthService.fetchCurrentRole()` succeeds, read only as a
  // cold-start-while-offline fallback so a returning admin still lands
  // on the Admin Hub instead of silently falling back to the seller
  // shell just because there was no connectivity to re-confirm the role.
  TextColumn get cachedRole => text().nullable()();

  @override
  Set<Column> get primaryKey => {ownerId};
}
