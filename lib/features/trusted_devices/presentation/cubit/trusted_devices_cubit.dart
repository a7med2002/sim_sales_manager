import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/trusted_devices_mock_data.dart';
import '../../domain/entities/trusted_device.dart';

/// Mock-only for now (no Supabase Auth session tracking yet). Revoking
/// removes the device from the list — a real backend would also
/// invalidate its session token.
class TrustedDevicesCubit extends Cubit<List<TrustedDevice>> {
  TrustedDevicesCubit() : super(TrustedDevicesMockData.initialDevices());

  void revoke(String id) {
    emit(state.where((d) => d.id != id).toList());
  }
}
