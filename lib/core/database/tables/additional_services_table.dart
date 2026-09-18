import 'package:drift/drift.dart';

import 'tenant_columns.dart';

/// One row per "Additional Service" top-up applied to a Line — a seller
/// activating extra data (fixed 30GB by default, editable) from the
/// supplying company when a customer's line runs out before month's end.
/// Deliberately its own table rather than new columns on `LinesTable`:
/// [amountDeducted] (what it costs against the *company's* balance) and
/// [amountCharged] (what, if anything, the seller passes on to the
/// *customer* as debt) are both independent of the Line's own
/// `retailPrice`/`wholesaleCost`/`amountRemaining` — folding them in
/// there would corrupt `Line.applyPayment`'s `retailPrice - amountPaid`
/// invariant the moment any future payment recomputed it. Keeping this
/// separate also gives a real per-line history (one row per top-up)
/// instead of a single mutated running total.
///
/// [companyId] is a snapshot of whichever company the deduction actually
/// came from at creation time — deliberately never touched again even if
/// the Line itself is later reassigned to a different company (see
/// `CustomersCubit.updateLine`'s doc comment on why that reassignment
/// must not retroactively move a historical deduction).
///
/// [customerId] is denormalized (same reasoning as `LinesTable.customerId`
/// itself) so `CustomersState.totalOwedFor` can sum unpaid
/// [amountCharged] without joining through `lines`.
class AdditionalServicesTable extends Table with TenantColumns {
  @override
  String get tableName => 'additional_services';

  TextColumn get id => text()();
  TextColumn get lineId => text()();
  TextColumn get customerId => text()();
  TextColumn get companyId => text().nullable()();

  RealColumn get amountDeducted => real()();
  RealColumn get amountCharged => real().withDefault(const Constant(0))();
  RealColumn get gbAdded => real().withDefault(const Constant(30))();

  /// Whether the seller has collected [amountCharged] from the customer
  /// yet — flipped by its own dedicated "Mark collected" action, never by
  /// the Line's own "Add payment" flow (see class doc comment on why
  /// these stay independent).
  BoolColumn get collected => boolean().withDefault(const Constant(false))();

  /// The actual moment this top-up was activated — kept separate from
  /// [TenantColumns.updatedAt] (which changes again when [collected]
  /// flips) so the per-line history list has a stable, real creation
  /// date to sort/display by.
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
