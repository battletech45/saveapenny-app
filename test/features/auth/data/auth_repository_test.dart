import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/dio_client.dart';
import 'package:saveapenny/core/push/push_messaging_gateway.dart';
import 'package:saveapenny/core/storage/cache_encryption_key_provider.dart';
import 'package:saveapenny/core/storage/response_cache_store.dart';
import 'package:saveapenny/core/storage/secure_token_store.dart';
import 'package:saveapenny/features/auth/data/auth_api.dart';
import 'package:saveapenny/features/auth/data/auth_repository.dart';
import 'package:saveapenny/features/auth/domain/auth_session.dart';
import 'package:saveapenny/features/push/data/device_token_api.dart';

import '../../../support/test_http_client_adapter.dart';

class _MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class _FakePushMessagingGateway implements PushMessagingGateway {
  String? token;

  @override
  Future<void> requestPermission() async {}

  @override
  Future<void> setForegroundPresentationOptions() async {}

  @override
  Future<String?> getToken() async => token;

  @override
  Stream<String> get onTokenRefresh => const Stream.empty();

  @override
  Stream<RemoteMessage> get onMessage => const Stream.empty();

  @override
  Stream<RemoteMessage> get onMessageOpenedApp => const Stream.empty();

  @override
  Future<RemoteMessage?> getInitialMessage() async => null;
}

void main() {
  late _MockFlutterSecureStorage storage;
  late SecureTokenStore tokenStore;
  late Map<String, String> values;
  late TestHttpClientAdapter adapter;
  late _FakePushMessagingGateway pushMessagingGateway;
  late CacheEncryptionKeyProvider cacheEncryptionKeyProvider;
  late ResponseCacheStore responseCacheStore;
  late Directory cacheDir;
  late AuthRepositoryImpl repository;

  setUp(() {
    storage = _MockFlutterSecureStorage();
    tokenStore = SecureTokenStore(storage: storage);
    values = <String, String>{};
    adapter = TestHttpClientAdapter();
    pushMessagingGateway = _FakePushMessagingGateway();
    // Shares the same mocked secure storage as tokenStore, so asserting
    // `values` is empty after logout also proves the cache encryption key
    // was wiped, not just the auth tokens.
    cacheEncryptionKeyProvider = CacheEncryptionKeyProvider(storage: storage);
    cacheDir = Directory.systemTemp.createTempSync('response_cache_test');
    responseCacheStore = ResponseCacheStore(
      cacheEncryptionKeyProvider,
      directoryResolver: () async => cacheDir,
    );
    addTearDown(() {
      if (cacheDir.existsSync()) {
        cacheDir.deleteSync(recursive: true);
      }
    });

    when(() => storage.read(key: any(named: 'key'))).thenAnswer((
      invocation,
    ) async {
      final key = invocation.namedArguments[#key]! as String;
      return values[key];
    });
    when(
      () => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((invocation) async {
      final key = invocation.namedArguments[#key]! as String;
      final value = invocation.namedArguments[#value]! as String;
      values[key] = value;
    });
    when(() => storage.delete(key: any(named: 'key'))).thenAnswer((
      invocation,
    ) async {
      final key = invocation.namedArguments[#key]! as String;
      values.remove(key);
    });

    final dio = Dio(BaseOptions(baseUrl: 'https://api.saveapenny.app/api/v1'))
      ..httpClientAdapter = adapter;
    final apiClient = ApiClient(dio);
    repository = AuthRepositoryImpl(
      AuthApi(apiClient),
      tokenStore,
      DeviceTokenApi(apiClient),
      pushMessagingGateway,
      cacheEncryptionKeyProvider,
      responseCacheStore,
    );
  });

  test('login stores the issued token pair', () async {
    adapter.enqueueJson(
      path: '/auth/login',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{
          'accessToken': 'access-1',
          'refreshToken': 'refresh-1',
          'tokenType': 'Bearer',
          'expiresIn': 900,
        },
        'error': null,
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );

    final session = await repository.login(
      email: 'altay@example.com',
      password: 'secret',
    );

    expect(session, isA<AuthSession>());
    expect(values['access_token'], 'access-1');
    expect(values['refresh_token'], 'refresh-1');
  });

  test(
    'register surfaces invalid password failures without storing tokens',
    () async {
      adapter.enqueueJson(
        path: '/auth/register',
        statusCode: 200,
        body: <String, dynamic>{
          'success': false,
          'data': null,
          'error': <String, dynamic>{
            'code': 'INVALID_PASSWORD',
            'message': 'Password too weak',
            'details': <String>[],
          },
          'timestamp': '2026-06-09T12:00:00Z',
        },
      );

      await expectLater(
        () => repository.register(
          email: 'altay@example.com',
          password: '123',
          fullName: 'Altay Yilmaz',
        ),
        throwsA(isA<ApiFailure>()),
      );

      expect(values, isEmpty);
    },
  );

  test('logout revokes the refresh token and clears stored tokens', () async {
    values['access_token'] = 'access-1';
    values['refresh_token'] = 'refresh-1';
    adapter.enqueueJson(
      path: '/auth/logout',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': null,
        'error': null,
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );

    await repository.logout();

    expect(values, isEmpty);
  });

  test('logout purges the offline cache and its encryption key', () async {
    values['access_token'] = 'access-1';
    values['refresh_token'] = 'refresh-1';
    await responseCacheStore.write('accounts:list', <String, dynamic>{
      'items': <dynamic>[],
    });
    adapter.enqueueJson(
      path: '/auth/logout',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': null,
        'error': null,
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );

    await repository.logout();

    expect(await responseCacheStore.read('accounts:list'), isNull);
    expect(cacheDir.existsSync(), isFalse);
    expect(values['cache_encryption_key'], isNull);
  });

  test(
    'logout unregisters the FCM device token before clearing tokens',
    () async {
      values['access_token'] = 'access-1';
      values['refresh_token'] = 'refresh-1';
      pushMessagingGateway.token = 'fcm-token-1';
      adapter.enqueueJson(
        path: '/users/me/device-tokens',
        statusCode: 200,
        body: <String, dynamic>{
          'success': true,
          'data': null,
          'error': null,
          'timestamp': '2026-06-09T12:00:00Z',
        },
      );
      adapter.enqueueJson(
        path: '/auth/logout',
        statusCode: 200,
        body: <String, dynamic>{
          'success': true,
          'data': null,
          'error': null,
          'timestamp': '2026-06-09T12:00:00Z',
        },
      );

      await repository.logout();

      final unregisterRequests = adapter.requestsForPath(
        '/users/me/device-tokens',
      );
      expect(unregisterRequests, hasLength(1));
      expect(unregisterRequests.single.method, 'DELETE');
      expect(unregisterRequests.single.queryParameters['token'], 'fcm-token-1');
      expect(values, isEmpty);
    },
  );

  test(
    'logout still clears tokens when device-token unregistration fails',
    () async {
      values['access_token'] = 'access-1';
      values['refresh_token'] = 'refresh-1';
      pushMessagingGateway.token = 'fcm-token-1';
      adapter.enqueueJson(
        path: '/users/me/device-tokens',
        statusCode: 500,
        body: <String, dynamic>{
          'success': false,
          'data': null,
          'error': <String, dynamic>{
            'code': 'INTERNAL_ERROR',
            'message': 'boom',
            'details': <String>[],
          },
          'timestamp': '2026-06-09T12:00:00Z',
        },
      );
      adapter.enqueueJson(
        path: '/auth/logout',
        statusCode: 200,
        body: <String, dynamic>{
          'success': true,
          'data': null,
          'error': null,
          'timestamp': '2026-06-09T12:00:00Z',
        },
      );

      await repository.logout();

      expect(values, isEmpty);
    },
  );

  test('logout skips unregistration when there is no FCM token', () async {
    values['access_token'] = 'access-1';
    values['refresh_token'] = 'refresh-1';
    pushMessagingGateway.token = null;
    adapter.enqueueJson(
      path: '/auth/logout',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': null,
        'error': null,
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );

    await repository.logout();

    expect(adapter.requestsForPath('/users/me/device-tokens'), isEmpty);
    expect(values, isEmpty);
  });
}
