import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/push/device_token_registration_service.dart';
import 'package:saveapenny/core/push/local_notifications_service.dart';
import 'package:saveapenny/core/push/push_message_router.dart';
import 'package:saveapenny/core/push/push_messaging_gateway.dart';
import 'package:saveapenny/core/push/push_navigator.dart';
import 'package:saveapenny/features/notifications/application/notifications_controller.dart';

part 'push_notification_controller.g.dart';

/// Registered in `main.dart` via `FirebaseMessaging.onBackgroundMessage`.
/// Must be a top-level (or static) function — it runs in its own isolate.
/// Notification-type messages are rendered by the OS tray without this
/// handler running at all; it exists so a data-only push received while
/// the app is backgrounded/terminated doesn't crash for lack of a
/// registered handler. There's nothing else to process today.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

/// Owns the FCM lifecycle: permission priming, token (re-)registration,
/// foreground display, and tap-to-navigate for background/terminated taps.
/// Watched once from `app.dart` after the user is authenticated.
@Riverpod(keepAlive: true)
class PushNotificationController extends _$PushNotificationController {
  StreamSubscription<String>? _onTokenRefreshSub;
  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onMessageOpenedAppSub;

  @override
  Future<void> build() async {
    ref.onDispose(() {
      unawaited(_onTokenRefreshSub?.cancel());
      unawaited(_onMessageSub?.cancel());
      unawaited(_onMessageOpenedAppSub?.cancel());
    });

    final gateway = ref.read(pushMessagingGatewayProvider);

    await gateway.requestPermission();
    await gateway.setForegroundPresentationOptions();
    await ref.read(localNotificationsServiceProvider).initialize();

    unawaited(_registerToken(await gateway.getToken()));
    _onTokenRefreshSub = gateway.onTokenRefresh.listen(_registerToken);

    _onMessageSub = gateway.onMessage.listen(_handleForegroundMessage);
    _onMessageOpenedAppSub = gateway.onMessageOpenedApp.listen(
      _handleMessageTap,
    );

    final initialMessage = await gateway.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageTap(initialMessage);
    }
  }

  Future<void> _registerToken(String? token) async {
    if (token == null || token.isEmpty) {
      return;
    }
    await ref.read(deviceTokenRegistrationServiceProvider).register(token);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    unawaited(
      ref
          .read(localNotificationsServiceProvider)
          .showFromRemoteMessage(message),
    );
    ref.invalidate(notificationsControllerProvider);
  }

  void _handleMessageTap(RemoteMessage message) {
    final route = resolvePushRoute(message.data);
    ref.read(pushNavigatorProvider).navigateTo(route);
  }
}
