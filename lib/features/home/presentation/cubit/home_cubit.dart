import 'dart:async';

import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/catalog/company_catalog.dart';
import '../../../../core/catalog/customer_catalog.dart';
import '../../../../core/constants/period_filter.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import 'home_state.dart';

/// Home reads real figures through [CustomerCatalog]/[CompanyCatalog]
/// (see core/catalog/ for why), same as Profits/Reports — no writes
/// happen here. `userName` (first name only, for the "Welcome back"
/// greeting) tracks `ProfileCubit`'s real name live via a stream
/// subscription — `ProfileCubit`'s real name loads asynchronously after
/// sign-in (a Supabase query for `profiles.display_name`), so reading
/// its `state.name` only once at construction (the previous approach)
/// could freeze Home on the email-fallback name forever if that read
/// happened to land before the async fetch resolved.
class HomeCubit extends Cubit<HomeState> {
  final CustomerCatalog _customerCatalog;
  final CompanyCatalog _companyCatalog;
  StreamSubscription<Profile>? _profileSubscription;
  StreamSubscription<void>? _customersSubscription;
  StreamSubscription<void>? _companiesSubscription;

  HomeCubit({required CustomerCatalog customerCatalog, required CompanyCatalog companyCatalog, required ProfileCubit profileCubit})
      : _customerCatalog = customerCatalog,
        _companyCatalog = companyCatalog,
        super(HomeState(
          lines: customerCatalog.allLines,
          companies: companyCatalog.activeCompanies,
          userName: _firstNameOf(profileCubit.state.name),
          now: DateTime.now(),
        )) {
    _profileSubscription = profileCubit.stream.listen((profile) {
      emit(state.copyWith(userName: _firstNameOf(profile.name)));
    });
    // Companies/Customers load asynchronously (Drift/Supabase reads after
    // construction) — on a cold app start Home is very likely built
    // before that first load resolves, so the synchronous reads above
    // capture an empty snapshot. Without this, the dashboard sits on
    // zeros until something else happens to call `refresh()` (e.g.
    // visiting Companies/Customers and coming back).
    _customersSubscription = _customerCatalog.changes.listen((_) => refresh());
    _companiesSubscription = _companyCatalog.changes.listen((_) => refresh());
  }

  static String _firstNameOf(String fullName) {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return trimmed;
    return trimmed.split(RegExp(r'\s+')).first;
  }

  /// Re-pulls the latest lines/companies — call after returning to Home
  /// so newly-added sales/companies show up without needing a full app
  /// restart (the underlying catalogs are always current; this just
  /// re-reads them into `state`).
  void refresh() {
    emit(state.copyWith(lines: _customerCatalog.allLines, companies: _companyCatalog.activeCompanies));
  }

  void selectPeriod(PeriodFilter period) => emit(state.copyWith(selectedPeriod: period));

  void selectCustomRange(DateTimeRange range) =>
      emit(state.copyWith(selectedPeriod: PeriodFilter.custom, customRange: range));

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    _customersSubscription?.cancel();
    _companiesSubscription?.cancel();
    return super.close();
  }
}
