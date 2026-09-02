import 'package:connectivity_plus/connectivity_plus.dart';

/// Thin wrapper around `connectivity_plus` exposing a plain online/offline
/// stream — `SyncBloc` reacts to this rather than every feature touching
/// `connectivity_plus` directly.
class ConnectivityService {
  final Connectivity _connectivity;

  ConnectivityService({Connectivity? connectivity}) : _connectivity = connectivity ?? Connectivity();

  Stream<bool> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged.map(_isOnline);

  Future<bool> get isOnline async => _isOnline(await _connectivity.checkConnectivity());

  bool _isOnline(List<ConnectivityResult> results) => results.any((r) => r != ConnectivityResult.none);
}
