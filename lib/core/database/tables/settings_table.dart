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

  @override
  Set<Column> get primaryKey => {ownerId};
}
