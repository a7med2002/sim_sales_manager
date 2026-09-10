import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Thin wrapper around `connectivity_plus` exposing a plain online/offline
/// stream — `SyncBloc` reacts to this rather than every feature touching
/// `connectivity_plus` directly.
///
/// `connectivity_plus` alone only reports whether a network *adapter*
/// (WiFi, mobile data, ...) is connected — a WiFi router with no working
/// internet uplink still reports "connected" there, which used to make
/// every real/mock cubit's connectivity pre-check pass, then hang on the
/// platform's much longer default socket-connect timeout once it tried
/// an actual Supabase call. A quick DNS lookup with a hard 1-second
/// timeout confirms real reachability without risking that long stall —
/// if there's genuinely no internet, this reports offline within ~1s.
class ConnectivityService {
  final Connectivity _connectivity;

  ConnectivityService({Connectivity? connectivity}) : _connectivity = connectivity ?? Connectivity();

  static const _probeTimeout = Duration(seconds: 1);

  Stream<bool> get onConnectivityChanged => _connectivity.onConnectivityChanged.asyncMap(_hasRealInternet);

  Future<bool> get isOnline async => _hasRealInternet(await _connectivity.checkConnectivity());

  bool _hasAdapter(List<ConnectivityResult> results) => results.any((r) => r != ConnectivityResult.none);

  Future<bool> _hasRealInternet(List<ConnectivityResult> results) async {
    if (!_hasAdapter(results)) return false;
    try {
      final addresses = await InternetAddress.lookup('supabase.co').timeout(_probeTimeout);
      return addresses.isNotEmpty && addresses.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
