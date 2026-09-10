import 'dart:async';

import 'package:drift/drift.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/activity_log/activity_action_type.dart';
import '../../../../core/activity_log/activity_logger.dart';
import '../../../../core/auth/auth_service.dart';
import '../../../../core/config/env.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/number_update/number_update_provider.dart';
import '../../../../core/sync/sync_engine.dart';
import '../../../../core/utils/uuid.dart';
import '../../data/number_update_providers.dart';
import '../../domain/entities/number_update_entry.dart';
import 'number_update_state.dart';

/// Number Update: tries a typed number against every supplier this app
/// knows how to talk to automatically — Aloha, Liyan, QuickLine, Areen
/// first (plain HTTP, `data/number_update_providers.dart`, silent and
/// near-instant), **then** SmileSim and Sky last, in that order.
/// SmileSim/Sky both need a real browser for reCAPTCHA, so they're the
/// two that open a visible WebView (`runSmileSimFlow`/`runSkyFlow`, both
/// backed by the shared `FormWebViewUpdater`) — deliberately tried last
/// rather than first: SmileSim's own number-update page matches against
/// a broad/generic link that ends up accepting most numbers regardless
/// of their real supplier, so trying it first meant almost every update
/// opened a WebView even when a plain HTTP provider further down the
/// list would have matched silently. The number does **not** need to be
/// registered to any customer Line first:
/// whichever supplier responds with a real match wins, in whatever order
/// they're tried. A successful match is remembered locally
/// (`NumberUpdateProviderCacheTable`) so the next update for that same
/// number tries that supplier first instead of repeating the full
/// trial-and-error order.
class NumberUpdateCubit extends Cubit<NumberUpdateState> {
  final Future<NumberUpdateResult> Function(String phoneNumber)? _runSmileSimFlow;
  final Future<NumberUpdateResult> Function(String phoneNumber)? _runSkyFlow;
  final AppDatabase? _db;
  final AuthService? _auth;
  final SyncEngine? _syncEngine;

  /// The fixed trial order when nothing is cached yet for a number —
  /// every plain-HTTP provider first (quick, silent, no UI), since
  /// they're each a narrow/specific match (fail fast and cleanly when a
  /// number isn't theirs); the two WebView-based providers
  /// (SmileSim/Sky) last, SmileSim before Sky since it covers the larger
  /// share of what's left by the time the search gets there. See this
  /// class's doc comment for why WebView providers moved to the back —
  /// a visible browser popping up should be the exception (a number none
  /// of the quiet providers recognized), not the common case.
  static const _defaultTryOrder = [
    NumberUpdateProviderKey.aloha,
    NumberUpdateProviderKey.liyan,
    NumberUpdateProviderKey.quickline,
    NumberUpdateProviderKey.areen,
    NumberUpdateProviderKey.smilesim,
    NumberUpdateProviderKey.sky,
  ];

  NumberUpdateCubit({
    Future<NumberUpdateResult> Function(String phoneNumber)? runSmileSimFlow,
    Future<NumberUpdateResult> Function(String phoneNumber)? runSkyFlow,
    AppDatabase? db,
    AuthService? auth,
    SyncEngine? syncEngine,
  })  : _runSmileSimFlow = runSmileSimFlow,
        _runSkyFlow = runSkyFlow,
        _db = _resolveDb(db),
        _auth = _resolveAuth(auth),
        _syncEngine = syncEngine ?? (Env.isConfigured ? getIt<SyncEngine>() : null),
        super(const NumberUpdateState()) {
    if (_db != null && _auth?.currentOwnerId != null) {
      _syncThenLoad();
    }
  }

  static AppDatabase? _resolveDb(AppDatabase? db) => db ?? (Env.isConfigured ? getIt<AppDatabase>() : null);
  static AuthService? _resolveAuth(AuthService? auth) => auth ?? (Env.isConfigured ? getIt<AuthService>() : null);

  bool get _isReal => _db != null && _auth?.currentOwnerId != null;

  final Map<String, NumberUpdateProviderKey> _providerCache = {};

  Future<void> _syncThenLoad() async {
    final engine = _syncEngine;
    final ownerId = _auth?.currentOwnerId;
    if (engine != null && ownerId != null) {
      try {
        await engine.pushPendingNumberUpdateLog(ownerId);
        await engine.pullNumberUpdateLog(ownerId);
        await engine.pushPendingNumberUpdateProviderCache(ownerId);
        await engine.pullNumberUpdateProviderCache(ownerId);
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

    final cacheRows = await (db.select(db.numberUpdateProviderCacheTable)..where((t) => t.ownerId.equals(ownerId))).get();
    _providerCache
      ..clear()
      ..addEntries(cacheRows.map((r) {
        final provider = numberUpdateProviderFromRow(r.provider);
        return provider == null ? null : MapEntry(r.phoneNumber, provider);
      }).whereType<MapEntry<String, NumberUpdateProviderKey>>());

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

  void phoneNumberChanged(String value) => emit(state.copyWith(phoneNumber: value));

  /// [_defaultTryOrder] with the number's cached provider (if any) moved
  /// to the front — trying the known-good one first without ever
  /// dropping the others as a fallback if it stops working (a supplier
  /// could migrate a number away, or reject it for an unrelated reason).
  /// A WebView-backed provider (SmileSim/Sky) is dropped entirely when
  /// its flow isn't wired up (e.g. a test constructing this Cubit
  /// directly) rather than failing partway through the trial.
  List<NumberUpdateProviderKey> _tryOrderFor(String number) {
    final cached = _providerCache[number];
    final order = [
      ?cached,
      ..._defaultTryOrder.where((p) => p != cached),
    ];
    return order.where((p) {
      if (p == NumberUpdateProviderKey.smilesim) return _runSmileSimFlow != null;
      if (p == NumberUpdateProviderKey.sky) return _runSkyFlow != null;
      return true;
    }).toList();
  }

  Future<NumberUpdateResult> _callProvider(NumberUpdateProviderKey provider, String number) {
    switch (provider) {
      case NumberUpdateProviderKey.smilesim:
        return _runSmileSimFlow!(number);
      case NumberUpdateProviderKey.sky:
        return _runSkyFlow!(number);
      case NumberUpdateProviderKey.liyan:
      case NumberUpdateProviderKey.areen:
      case NumberUpdateProviderKey.quickline:
      case NumberUpdateProviderKey.aloha:
        return callNumberUpdateProvider(provider, number);
    }
  }

  Future<void> submitUpdate() async {
    final number = state.phoneNumber.trim();
    if (number.isEmpty || state.isSubmitting) return;

    emit(state.copyWith(isSubmitting: true));

    NumberUpdateProviderKey? matchedProvider;
    NumberUpdateResult? result;
    for (final provider in _tryOrderFor(number)) {
      final attempt = await _callProvider(provider, number);
      if (attempt.status == NumberUpdateStatus.success) {
        matchedProvider = provider;
        result = attempt;
        break;
      }
      // Keep the most recent non-success result so a real "unreachable"
      // failure isn't silently swallowed by a later provider's plain
      // "not found" if every provider ends up failing.
      result = attempt;
    }

    final finalResult = result!;
    final message = matchedProvider != null
        ? '${matchedProvider.label}: ${finalResult.message}'
        : 'numberUpdate.errors.notFoundAnyProvider'.tr();
    final entry = NumberUpdateEntry(
      id: generateUuidV4(),
      phoneNumber: number,
      timestamp: DateTime.now(),
      status: matchedProvider != null ? NumberUpdateStatus.success : NumberUpdateStatus.notFound,
      message: message,
    );
    emit(state.copyWith(isSubmitting: false, log: [entry, ...state.log]));
    if (_isReal) unawaited(_persistEntry(entry));

    if (matchedProvider != null) {
      _providerCache[number] = matchedProvider;
      if (_isReal) unawaited(_persistProviderCache(number, matchedProvider));
      getIt<ActivityLogger>().log(
        ActivityActionType.edit,
        'Refreshed number $number via ${matchedProvider.label}.',
      );
    } else {
      getIt<ActivityLogger>().log(
        ActivityActionType.edit,
        'Tried to refresh number $number — not recognized by any supported supplier.',
      );
    }
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

  Future<void> _persistProviderCache(String phoneNumber, NumberUpdateProviderKey provider) async {
    final db = _db!;
    final ownerId = _auth!.currentOwnerId!;
    try {
      await db.into(db.numberUpdateProviderCacheTable).insertOnConflictUpdate(
            NumberUpdateProviderCacheTableCompanion.insert(
              ownerId: ownerId,
              phoneNumber: phoneNumber,
              provider: numberUpdateProviderToRow(provider),
              synced: const Value(false),
              updatedAt: DateTime.now(),
            ),
          );
      if (_syncEngine != null) {
        await _syncEngine.pushPendingNumberUpdateProviderCache(ownerId);
      }
    } catch (_) {
      // Offline or transient failure — row stays local, next sync retries.
    }
  }
}
