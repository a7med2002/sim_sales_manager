import 'package:drift/drift.dart';

/// Shared columns every tenant-scoped table carries: who owns the row
/// (mirrors Supabase's `owner_id`, scoped by RLS server-side) and the
/// offline-first sync bookkeeping from CLAUDE.md — `synced = false`
/// means this row has local changes not yet pushed, `updatedAt` drives
/// last-write-wins conflict resolution on pull.
mixin TenantColumns on Table {
  TextColumn get ownerId => text()();
  BoolColumn get synced => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime()();
}
