import 'package:drift/drift.dart';

import 'tenant_columns.dart';

/// Remembers which supplier a phone number matched last time Number
/// Update tried it, so the next update for that same number tries that
/// supplier first instead of re-running the full trial-and-error order
/// (Liyan -> QuickLine -> Areen -> Sky) every time. One row per
/// (owner, phone number) — overwritten whenever a fresh trial finds a
/// (possibly different) match.
class NumberUpdateProviderCacheTable extends Table with TenantColumns {
  @override
  String get tableName => 'number_update_provider_cache';

  TextColumn get phoneNumber => text()();
  TextColumn get provider => text()();

  @override
  Set<Column> get primaryKey => {ownerId, phoneNumber};
}
