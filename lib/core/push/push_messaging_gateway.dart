import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'push_messaging_gateway.g.dart';

/// Thin seam over [FirebaseMessaging] so [PushNotificationController] can be
/// unit-tested against a fake instead of the real SDK singleton.
abstract interface class PushMessagingGateway {
  Future<void> requestPermission();

  Future<void> setForegroundPresentationOptions();

  Future<String?> getToken();

  Stream<String> get onTokenRefresh;

  Stream<RemoteMessage> get onMessage;

  Stream<RemoteMessage> get onMessageOpenedApp;

  Future<RemoteMessage?> getInitialMessage();
}

class FirebaseMessagingGateway implements PushMessagingGateway {
  const FirebaseMessagingGateway(this._messaging);

  final FirebaseMessaging _messaging;

  @override
  Future<void> requestPermission() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
  }

  @override
  Future<void> setForegroundPresentationOptions() {
    return _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  @override
  Future<String?> getToken() => _messaging.getToken();

  @override
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  @override
  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;

  @override
  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  @override
  Future<RemoteMessage?> getInitialMessage() => _messaging.getInitialMessage();
}

@Riverpod(keepAlive: true)
PushMessagingGateway pushMessagingGateway(Ref ref) {
  return FirebaseMessagingGateway(FirebaseMessaging.instance);
}
