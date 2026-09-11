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
/// an actual Supabase call. A quick DNS lookup confirms real reachability
/// without risking that long stall. The timeout is 3s, not 1s — mobile
/// data (weak signal especially) routinely takes longer than 1s to
/// resolve a DNS query even when it's genuinely online, and a 1s cap was
/// misreporting those as offline, silently skipping real sync
/// opportunities (see PROGRESS.md's "mobile data sync" entry). 3s is
/// still fast enough to never read as a stall to the user.
class ConnectivityService {
  final Connectivity _connectivity;

  ConnectivityService({Connectivity? connectivity}) : _connectivity = connectivity ?? Connectivity();

  static const _probeTimeout = Duration(seconds: 3);

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
