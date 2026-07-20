import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'local_notifications_service.g.dart';

/// Displays a heads-up notification for a foreground [RemoteMessage].
///
/// iOS presents foreground FCM notifications natively once
/// `setForegroundNotificationPresentationOptions` is set (see
/// `PushMessagingGateway`), so this only needs to act on Android, where a
/// notification-type message received while the app is foregrounded is
/// otherwise dropped silently.
abstract interface class LocalNotificationsService {
  Future<void> initialize();

  Future<void> showFromRemoteMessage(RemoteMessage message);
}

class FlutterLocalNotificationsService implements LocalNotificationsService {
  FlutterLocalNotificationsService(this._plugin);

  static const _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'Important notifications',
    description: 'Budget alerts, bill reminders, and account updates.',
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin _plugin;

  @override
  Future<void> initialize() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
  }

  @override
  Future<void> showFromRemoteMessage(RemoteMessage message) async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    final notification = message.notification;
    if (notification == null) {
      return;
    }

    await _plugin.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}

@Riverpod(keepAlive: true)
LocalNotificationsService localNotificationsService(Ref ref) {
  return FlutterLocalNotificationsService(FlutterLocalNotificationsPlugin());
}
