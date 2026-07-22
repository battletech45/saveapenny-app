import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/core/push/device_token_registration_service.dart';
import 'package:saveapenny/core/push/local_notifications_service.dart';
import 'package:saveapenny/core/push/push_messaging_gateway.dart';
import 'package:saveapenny/core/push/push_navigator.dart';
import 'package:saveapenny/core/push/push_notification_controller.dart';
import 'package:saveapenny/features/notifications/application/notifications_controller.dart';
import 'package:saveapenny/features/notifications/data/notifications_repository.dart';
import 'package:saveapenny/features/notifications/domain/notification.dart';
import 'package:saveapenny/features/notifications/domain/notifications_repository.dart';

class _FakePushMessagingGateway implements PushMessagingGateway {
  _FakePushMessagingGateway({this.initialToken});

  String? initialToken;
  RemoteMessage? initialMessage;

  int requestPermissionCallCount = 0;
  int setForegroundPresentationOptionsCallCount = 0;

  final _onTokenRefreshController = StreamController<String>.broadcast();
  final _onMessageController = StreamController<RemoteMessage>.broadcast();
  final _onMessageOpenedAppController =
      StreamController<RemoteMessage>.broadcast();

  @override
  Future<void> requestPermission() async {
    requestPermissionCallCount += 1;
  }

  @override
  Future<void> setForegroundPresentationOptions() async {
    setForegroundPresentationOptionsCallCount += 1;
  }

  @override
  Future<String?> getToken() async => initialToken;

  @override
  Stream<String> get onTokenRefresh => _onTokenRefreshController.stream;

  @override
  Stream<RemoteMessage> get onMessage => _onMessageController.stream;

  @override
  Stream<RemoteMessage> get onMessageOpenedApp =>
      _onMessageOpenedAppController.stream;

  @override
  Future<RemoteMessage?> getInitialMessage() async => initialMessage;

  void emitTokenRefresh(String token) => _onTokenRefreshController.add(token);

  void emitMessage(RemoteMessage message) => _onMessageController.add(message);

  void emitMessageOpenedApp(RemoteMessage message) =>
      _onMessageOpenedAppController.add(message);

  Future<void> dispose() async {
    await _onTokenRefreshController.close();
    await _onMessageController.close();
    await _onMessageOpenedAppController.close();
  }
}

class _FakeLocalNotificationsService implements LocalNotificationsService {
  int initializeCallCount = 0;
  final List<RemoteMessage> shown = <RemoteMessage>[];

  @override
  Future<void> initialize() async {
    initializeCallCount += 1;
  }

  @override
  Future<void> showFromRemoteMessage(RemoteMessage message) async {
    shown.add(message);
  }
}

class _FakeDeviceTokenRegistrationService
    implements DeviceTokenRegistrationService {
  final List<String> registered = <String>[];

  @override
  Future<void> register(String token) async {
    registered.add(token);
  }
}

class _FakePushNavigator implements PushNavigator {
  final List<String> routes = <String>[];

  @override
  void navigateTo(String route) {
    routes.add(route);
  }
}

class _FakeNotificationsRepository implements NotificationsRepository {
  int listCallCount = 0;

  @override
  Future<PaginatedData<Notification>> list({
    int page = 0,
    int size = 20,
    String sort = 'createdAt,desc',
  }) async {
    listCallCount += 1;
    return PaginatedData<Notification>(
      items: const <Notification>[],
      page: 0,
      size: size,
      totalItems: 0,
      totalPages: 0,
      hasNext: false,
      hasPrevious: false,
    );
  }

  @override
  Future<int> unreadCount() async => 0;

  @override
  Future<Notification> markRead(String notificationId) {
    throw UnimplementedError();
  }

  @override
  Future<void> markAllRead() {
    throw UnimplementedError();
  }

  @override
  Future<void> delete(String notificationId) {
    throw UnimplementedError();
  }
}

void main() {
  late _FakePushMessagingGateway gateway;
  late _FakeLocalNotificationsService localNotifications;
  late _FakeDeviceTokenRegistrationService tokenRegistration;
  late _FakePushNavigator navigator;
  late _FakeNotificationsRepository notificationsRepository;
  late ProviderContainer container;

  setUp(() {
    gateway = _FakePushMessagingGateway(initialToken: 'token-1');
    localNotifications = _FakeLocalNotificationsService();
    tokenRegistration = _FakeDeviceTokenRegistrationService();
    navigator = _FakePushNavigator();
    notificationsRepository = _FakeNotificationsRepository();

    container = ProviderContainer(
      overrides: [
        pushMessagingGatewayProvider.overrideWithValue(gateway),
        localNotificationsServiceProvider.overrideWithValue(localNotifications),
        deviceTokenRegistrationServiceProvider.overrideWithValue(
          tokenRegistration,
        ),
        pushNavigatorProvider.overrideWithValue(navigator),
        notificationsRepositoryProvider.overrideWithValue(
          notificationsRepository,
        ),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await gateway.dispose();
  });

  test(
    'build primes permission, foreground options, local init, and registers the initial token',
    () async {
      await container.read(pushNotificationControllerProvider.future);

      expect(gateway.requestPermissionCallCount, 1);
      expect(gateway.setForegroundPresentationOptionsCallCount, 1);
      expect(localNotifications.initializeCallCount, 1);
      expect(tokenRegistration.registered, <String>['token-1']);
    },
  );

  test('a cold-start initial message navigates immediately', () async {
    gateway.initialMessage = const RemoteMessage(
      data: <String, dynamic>{'type': 'BUDGET_EXCEEDED'},
    );

    await container.read(pushNotificationControllerProvider.future);

    expect(navigator.routes, <String>['/budgets']);
  });

  test(
    'a foreground message is shown locally and refreshes the notifications badge',
    () async {
      await container.read(pushNotificationControllerProvider.future);
      await container.read(notificationsControllerProvider.future);
      expect(notificationsRepository.listCallCount, 1);

      gateway.emitMessage(
        const RemoteMessage(
          notification: RemoteNotification(title: 'Budget alert'),
          data: <String, dynamic>{'type': 'BUDGET_WARNING'},
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(localNotifications.shown, hasLength(1));
      // invalidate() forces the next read to rebuild against the repository.
      await container.read(notificationsControllerProvider.future);
      expect(notificationsRepository.listCallCount, 2);
    },
  );

  test('a background tap navigates to the resolved route', () async {
    await container.read(pushNotificationControllerProvider.future);

    gateway.emitMessageOpenedApp(
      const RemoteMessage(
        data: <String, dynamic>{
          'type': 'INSIGHT_GENERATED',
          'insightId': 'i-9',
        },
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(navigator.routes, <String>['/insights/i-9']);
  });

  test('a refreshed token is re-registered', () async {
    await container.read(pushNotificationControllerProvider.future);

    gateway.emitTokenRefresh('token-2');
    await Future<void>.delayed(Duration.zero);

    expect(tokenRegistration.registered, <String>['token-1', 'token-2']);
  });
}
