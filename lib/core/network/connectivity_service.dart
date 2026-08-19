import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_service.g.dart';

@Riverpod(keepAlive: true)
Connectivity connectivity(Ref ref) {
  return Connectivity();
}

/// Live "does this device currently have a network path" signal, used to
/// gate the offline banner and to fail fast on mutations instead of letting
/// the user submit a form only to hit a [Failure.network] at the end.
///
/// Reachability, not backend health: a device on Wi-Fi with no internet still
/// reads as online here. The repository/[Failure.network] fallback path is
/// still the source of truth for "the last call actually failed."
@riverpod
Stream<bool> isOnline(Ref ref) {
  final connectivity = ref.watch(connectivityProvider);

  return connectivity.onConnectivityChanged.map(_hasConnection).distinct();
}

bool _hasConnection(List<ConnectivityResult> results) {
  return results.any((result) => result != ConnectivityResult.none);
}
