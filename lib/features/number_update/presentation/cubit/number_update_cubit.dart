import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/activity_log/activity_action_type.dart';
import '../../../../core/activity_log/activity_logger.dart';
import '../../../../core/auth/auth_service.dart';
import '../../../../core/catalog/company_catalog.dart';
import '../../../../core/catalog/customer_catalog.dart';
import '../../../../core/config/env.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/number_update/number_update_provider.dart';
import '../../../../core/sync/sync_engine.dart';
import '../../../../core/utils/uuid.dart';
import '../../data/number_update_mock_data.dart';
import '../../data/number_update_providers.dart';
import '../../domain/entities/number_update_entry.dart';
import 'number_update_state.dart';

/// Number Update: real, automated per-company lookup — a typed number is
/// matched against every real Line (`CustomerCatalog.allLines`) to find
/// which company sold it, that company's `numberUpdateProvider` (set on
/// its own Companies form, or carried over from an "Import Ready-Made"
/// catalog entry) decides which supplier endpoint to call
/// (`callNumberUpdateProvider`, in `data/number_update_providers.dart`),
/// and the result is logged — real Drift/Supabase persistence when
/// `Env.isConfigured` + signed in, same conditional pattern as every
/// other migrated feature; an in-memory mock log otherwise.
///
/// Two distinct "can't do this" cases surface as `state.errorMessage`
/// rather than a log entry, since no provider was ever actually called:
/// the number isn't registered to any Line at all, or it is but that
/// company has no provider configured.
class NumberUpdateCubit extends Cubit<NumberUpdateState> {
  final CompanyCatalog _companyCatalog;
  final CustomerCatalog _customerCatalog;
  final Future<NumberUpdateResult> Function(String phoneNumber)? _runSkyFlow;
  final AppDatabase? _db;
  final AuthService? _auth;
  final SyncEngine? _syncEngine;
  int _idCounter = 100;

  NumberUpdateCubit({
    required CompanyCatalog companyCatalog,
    required CustomerCatalog customerCatalog,
    Future<NumberUpdateResult> Function(String phoneNumber)? runSkyFlow,
    AppDatabase? db,
    AuthService? auth,
    SyncEngine? syncEngine,
  })  : _companyCatalog = companyCatalog,
        _customerCatalog = customerCatalog,
        _runSkyFlow = runSkyFlow,
        _db = _resolveDb(db),
        _auth = _resolveAuth(auth),
        _syncEngine = syncEngine ?? (Env.isConfigured ? getIt<SyncEngine>() : null),
        super(NumberUpdateState(log: _resolveDb(db) == null ? NumberUpdateMockData.initialLog() : const [])) {
    if (_db != null && _auth?.currentOwnerId != null) {
      _syncThenLoad();
    }
  }

  static AppDatabase? _resolveDb(AppDatabase? db) => db ?? (Env.isConfigured ? getIt<AppDatabase>() : null);
  static AuthService? _resolveAuth(AuthService? auth) => auth ?? (Env.isConfigured ? getIt<AuthService>() : null);

  bool get _isReal => _db != null && _auth?.currentOwnerId != null;

  Future<void> _syncThenLoad() async {
    final engine = _syncEngine;
    final ownerId = _auth?.currentOwnerId;
    if (engine != null && ownerId != null) {
      try {
        await engine.pushPendingNumberUpdateLog(ownerId);
        await engine.pullNumberUpdateLog(ownerId);
      } catch (_) {
        // Offline or transient failure — proceed with local data.
      }
    }
    await _loadFromDrift();
  }

  Future<void> _loadFromDrift() async {
    final db = _db!;
    final ownerId = _auth!.currentOwnerId!;
    final rows = await (db.select(db.numberUpdateLogTable)..where((t) => t.ownerId.equals(ownerId))).get();
    final log = rows
        .map((row) => NumberUpdateEntry(
              id: row.id,
              phoneNumber: row.phoneNumber,
              timestamp: row.createdAt,
              status: _statusFromRow(row.status),
              message: row.message,
            ))
        .toList();
    emit(state.copyWith(log: log));
  }

  NumberUpdateStatus _statusFromRow(String status) {
    switch (status) {
      case 'success':
        return NumberUpdateStatus.success;
      case 'not_found':
        return NumberUpdateStatus.notFound;
      default:
        return NumberUpdateStatus.failed;
    }
  }

  String _statusToRow(NumberUpdateStatus status) {
    switch (status) {
      case NumberUpdateStatus.success:
        return 'success';
      case NumberUpdateStatus.notFound:
        return 'not_found';
      case NumberUpdateStatus.failed:
        return 'failed';
    }
  }

  void phoneNumberChanged(String value) => emit(state.copyWith(phoneNumber: value, clearErrorMessage: true));

  Future<void> submitUpdate() async {
    final number = state.phoneNumber.trim();
    if (number.isEmpty || state.isSubmitting) return;

    final matchingLines = _customerCatalog.allLines.where((l) => l.simNumber.trim() == number);
    if (matchingLines.isEmpty) {
      emit(state.copyWith(errorMessage: 'numberUpdate.errors.numberNotRegistered', errorMessageArgs: const {}));
      return;
    }
    final line = matchingLines.first;

    final matchingCompanies = _companyCatalog.activeCompanies.where((c) => c.id == line.companyId);
    final company = matchingCompanies.isEmpty ? null : matchingCompanies.first;
    final provider = company?.numberUpdateProvider;
    if (provider == null) {
      emit(state.copyWith(
        errorMessage: 'numberUpdate.errors.companyNotSupported',
        errorMessageArgs: {'company': company?.name ?? line.companyName},
      ));
      return;
    }

    if (provider == NumberUpdateProviderKey.sky && _runSkyFlow == null) {
      emit(state.copyWith(errorMessage: 'numberUpdate.errors.skyUnavailable', errorMessageArgs: const {}));
      return;
    }

    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));
    final result = provider == NumberUpdateProviderKey.sky
        ? await _runSkyFlow!(number)
        : await callNumberUpdateProvider(provider, number);

    final entry = NumberUpdateEntry(
      id: _isReal ? generateUuidV4() : 'update-${_idCounter++}',
      phoneNumber: number,
      timestamp: DateTime.now(),
      status: result.status,
      message: result.message,
    );
    emit(state.copyWith(isSubmitting: false, log: [entry, ...state.log]));
    if (_isReal) unawaited(_persistEntry(entry));
    getIt<ActivityLogger>().log(
      ActivityActionType.edit,
      'Refreshed number $number via ${provider.label} (${result.status.label}).',
    );
  }

  Future<void> _persistEntry(NumberUpdateEntry entry) async {
    final db = _db!;
    final ownerId = _auth!.currentOwnerId!;
    try {
      await db.into(db.numberUpdateLogTable).insert(NumberUpdateLogTableCompanion.insert(
            id: entry.id,
            ownerId: ownerId,
            phoneNumber: entry.phoneNumber,
            status: _statusToRow(entry.status),
            message: entry.message,
            createdAt: entry.timestamp,
            synced: const Value(false),
            updatedAt: DateTime.now(),
          ));
      if (_syncEngine != null) {
        await _syncEngine.pushPendingNumberUpdateLog(ownerId);
      }
    } catch (_) {
      // Offline or transient failure — row stays local, next sync retries.
    }
  }
}
