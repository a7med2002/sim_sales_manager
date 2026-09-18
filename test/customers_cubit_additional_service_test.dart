import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sim_sales_manager/core/activity_log/activity_logger.dart';
import 'package:sim_sales_manager/core/auth/auth_service.dart';
import 'package:sim_sales_manager/core/catalog/company_catalog.dart';
import 'package:sim_sales_manager/core/catalog/company_summary.dart';
import 'package:sim_sales_manager/core/database/app_database.dart';
import 'package:sim_sales_manager/core/di/service_locator.dart';
import 'package:sim_sales_manager/core/notifications/notifications_cubit.dart';
import 'package:sim_sales_manager/core/sync/connectivity_service.dart';
import 'package:sim_sales_manager/features/customers/presentation/cubit/customers_cubit.dart';

/// Field report: "only one Additional Service allowed per line — after
/// adding one, I can't add a second to the same line." Exercises
/// `CustomersCubit.addAdditionalService` directly (not just the pure
/// `CustomersState` math already covered elsewhere) to prove/disprove a
/// real bug in the add path itself, independent of the UI sheet's own
/// balance-exceeded validation (a different, legitimate gate that lives
/// in `AdditionalServiceSheet`, not in the cubit).
class _FakeAuthService extends AuthService {
  _FakeAuthService(this._ownerId) : super(SupabaseClient('https://example.supabase.co', 'anon-key'));
  final String? _ownerId;
  @override
  String? get currentOwnerId => _ownerId;
}

class _FakeCompanyCatalog implements CompanyCatalog {
  final recordedCharges = <({String companyId, double amount})>[];
  final reversedCharges = <({String companyId, double amount})>[];

  @override
  List<CompanySummary> get activeCompanies => const [];

  @override
  Stream<void> get changes => const Stream.empty();

  @override
  void recordSale({required String companyId, required double wholesaleCost, required double profit}) {}

  @override
  void reverseSale({required String companyId, required double wholesaleCost, required double profit}) {}

  @override
  void addShipment({required String companyId, required double totalAmount, required double amountPaid}) {}

  @override
  void recordAdditionalServiceCharge({required String companyId, required double amount}) {
    recordedCharges.add((companyId: companyId, amount: amount));
  }

  @override
  void reverseAdditionalServiceCharge({required String companyId, required double amount}) {
    reversedCharges.add((companyId: companyId, amount: amount));
  }
}

void main() {
  const ownerId = 'seller-1';
  late AppDatabase db;
  late _FakeCompanyCatalog companyCatalog;
  late CustomersCubit cubit;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    companyCatalog = _FakeCompanyCatalog();

    await GetIt.instance.reset();
    getIt.registerSingleton<CompanyCatalog>(companyCatalog);
    getIt.registerSingleton<ActivityLogger>(ActivityLogger(db: db, auth: _FakeAuthService(ownerId), syncEngine: null));
    // Inert — Env.isConfigured is false under flutter test, so this never
    // resolves a real db/auth and every method on it is a safe no-op.
    // Only registered so markAdditionalServiceCollected's
    // cancelDebtRemindersIfSettled call has something to find.
    getIt.registerSingleton<NotificationsCubit>(NotificationsCubit());

    final now = DateTime.now();
    await db.into(db.customersTable).insert(
          CustomersTableCompanion.insert(id: 'cust-1', ownerId: ownerId, name: 'Mahmoud', contactNumber: '0599999999', updatedAt: now),
        );
    await db.into(db.linesTable).insert(LinesTableCompanion.insert(
          id: 'line-1',
          ownerId: ownerId,
          customerId: 'cust-1',
          companyId: const Value('company-1'),
          simNumber: '0599999999',
          purchaseDate: now,
          expiryDate: now.add(const Duration(days: 30)),
          updatedAt: now,
        ));

    cubit = CustomersCubit(db: db, auth: _FakeAuthService(ownerId), syncEngine: null, connectivity: ConnectivityService());
    // _syncThenLoad runs unawaited in the constructor.
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
  });

  tearDown(() async {
    await cubit.close();
    await db.close();
    await GetIt.instance.reset();
  });

  test('exactly one Additional Service is allowed per line — a second add is a no-op, not a second row', () async {
    cubit.addAdditionalService(lineId: 'line-1', amountDeducted: 5, amountCharged: 0, gbAdded: 30);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.additionalServicesFor('line-1'), hasLength(1));

    cubit.addAdditionalService(lineId: 'line-1', amountDeducted: 7, amountCharged: 2, gbAdded: 20);
    await Future<void>.delayed(Duration.zero);

    final services = cubit.state.additionalServicesFor('line-1');
    expect(services, hasLength(1), reason: 'by design, a line only ever gets one — corrections go through updateAdditionalService');
    expect(services.single.amountDeducted, 5, reason: 'the second call must be fully ignored, not partially applied');
    expect(companyCatalog.recordedCharges, hasLength(1), reason: 'the blocked second attempt must never touch the company balance');

    final rows = await (db.select(db.additionalServicesTable)..where((t) => t.lineId.equals('line-1'))).get();
    expect(rows, hasLength(1), reason: 'must stay at one row in Drift too, not just in memory');
  });

  test('repeated attempts on an already-serviced line never create more rows, however many times it\'s tried', () async {
    cubit.addAdditionalService(lineId: 'line-1', amountDeducted: 5, amountCharged: 0, gbAdded: 30);
    await Future<void>.delayed(Duration.zero);

    for (var i = 0; i < 5; i++) {
      cubit.addAdditionalService(lineId: 'line-1', amountDeducted: 1, amountCharged: 0, gbAdded: 10);
      await Future<void>.delayed(Duration.zero);
    }
    expect(cubit.state.additionalServicesFor('line-1'), hasLength(1));
  });

  test('a different line can still get its own Additional Service — the cap is per line, not global', () async {
    final now = DateTime.now();
    await db.into(db.linesTable).insert(LinesTableCompanion.insert(
          id: 'line-2',
          ownerId: ownerId,
          customerId: 'cust-1',
          companyId: const Value('company-1'),
          simNumber: '0588888888',
          purchaseDate: now,
          expiryDate: now.add(const Duration(days: 30)),
          updatedAt: now,
        ));
    await cubit.close();
    cubit = CustomersCubit(db: db, auth: _FakeAuthService(ownerId), syncEngine: null, connectivity: ConnectivityService());
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    cubit.addAdditionalService(lineId: 'line-1', amountDeducted: 5, amountCharged: 0, gbAdded: 30);
    await Future<void>.delayed(Duration.zero);
    cubit.addAdditionalService(lineId: 'line-2', amountDeducted: 6, amountCharged: 0, gbAdded: 30);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.additionalServicesFor('line-1'), hasLength(1));
    expect(cubit.state.additionalServicesFor('line-2'), hasLength(1));
  });

  group('updateAdditionalService (fixing a mistyped entry)', () {
    test('reverses the old company deduction and records the new one', () async {
      cubit.addAdditionalService(lineId: 'line-1', amountDeducted: 5, amountCharged: 0, gbAdded: 30);
      await Future<void>.delayed(Duration.zero);
      final serviceId = cubit.state.additionalServicesFor('line-1').single.id;

      cubit.updateAdditionalService(serviceId: serviceId, amountDeducted: 12, amountCharged: 3, gbAdded: 40);
      await Future<void>.delayed(Duration.zero);

      expect(companyCatalog.reversedCharges, [(companyId: 'company-1', amount: 5)]);
      expect(companyCatalog.recordedCharges.last, (companyId: 'company-1', amount: 12));

      final updated = cubit.state.additionalServicesFor('line-1').single;
      expect(updated.amountDeducted, 12);
      expect(updated.amountCharged, 3);
      expect(updated.gbAdded, 40);
      expect(updated.id, serviceId, reason: 'editing must not change identity — same row, corrected values');
    });

    test('the corrected row persists to Drift', () async {
      cubit.addAdditionalService(lineId: 'line-1', amountDeducted: 5, amountCharged: 0, gbAdded: 30);
      await Future<void>.delayed(Duration.zero);
      final serviceId = cubit.state.additionalServicesFor('line-1').single.id;

      cubit.updateAdditionalService(serviceId: serviceId, amountDeducted: 12, amountCharged: 3, gbAdded: 40);
      await Future<void>.delayed(Duration.zero);

      final row = await (db.select(db.additionalServicesTable)..where((t) => t.id.equals(serviceId))).getSingle();
      expect(row.amountDeducted, 12);
      expect(row.amountCharged, 3);
      expect(row.gbAdded, 40);
    });
  });

  group('markAdditionalServiceUncollected (undo)', () {
    test('flips collected back to false and the charge counts as owed again', () async {
      cubit.addAdditionalService(lineId: 'line-1', amountDeducted: 5, amountCharged: 8, gbAdded: 30);
      await Future<void>.delayed(Duration.zero);
      final serviceId = cubit.state.additionalServicesFor('line-1').single.id;

      cubit.markAdditionalServiceCollected(serviceId);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.totalOwedFor('cust-1'), 0, reason: 'collected — no longer owed');

      cubit.markAdditionalServiceUncollected(serviceId);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.additionalServicesFor('line-1').single.collected, isFalse);
      expect(cubit.state.totalOwedFor('cust-1'), 8, reason: 'undo must put the charge back on the customer\'s debt');

      final row = await (db.select(db.additionalServicesTable)..where((t) => t.id.equals(serviceId))).getSingle();
      expect(row.collected, isFalse);
    });

    test('is a no-op on a service that was never collected', () async {
      cubit.addAdditionalService(lineId: 'line-1', amountDeducted: 5, amountCharged: 8, gbAdded: 30);
      await Future<void>.delayed(Duration.zero);
      final serviceId = cubit.state.additionalServicesFor('line-1').single.id;

      cubit.markAdditionalServiceUncollected(serviceId);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.additionalServicesFor('line-1').single.collected, isFalse);
    });
  });
}
