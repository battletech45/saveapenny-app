import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:saveapenny/core/network/auth_interceptor.dart';
import 'package:saveapenny/core/storage/secure_token_store.dart';

import '../../support/test_http_client_adapter.dart';

class _MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockFlutterSecureStorage storage;
  late SecureTokenStore tokenStore;
  late Map<String, String> values;
  late TestHttpClientAdapter adapter;
  late Dio mainDio;
  late Dio refreshDio;

  setUp(() {
    storage = _MockFlutterSecureStorage();
    tokenStore = SecureTokenStore(storage: storage);
    values = <String, String>{};
    adapter = TestHttpClientAdapter();

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

    mainDio = Dio(BaseOptions(baseUrl: 'https://api.saveapenny.app/api/v1'))
      ..httpClientAdapter = adapter;
    refreshDio = Dio(BaseOptions(baseUrl: 'https://api.saveapenny.app/api/v1'))
      ..httpClientAdapter = adapter;
    mainDio.interceptors.add(
      AuthInterceptor(tokenStore: tokenStore, refreshDio: refreshDio),
    );
  });

  test('attaches bearer token to authenticated requests', () async {
    values['access_token'] = _jwt(
      expiration: DateTime.now().toUtc().add(const Duration(minutes: 10)),
    );
    adapter.enqueueJson(
      path: '/accounts',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{'ok': true},
        'error': null,
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );

    await mainDio.get<dynamic>('/accounts');

    expect(
      adapter.requests.single.headers['Authorization'],
      'Bearer ${values['access_token']}',
    );
  });

  test('refreshes proactively when the access token is near expiry', () async {
    values['access_token'] = _jwt(
      expiration: DateTime.now().toUtc().add(const Duration(seconds: 30)),
    );
    values['refresh_token'] = 'refresh-1';
    final refreshedAccessToken = _jwt(
      expiration: DateTime.now().toUtc().add(const Duration(minutes: 15)),
    );

    adapter.enqueueJson(
      path: '/auth/refresh',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{
          'accessToken': refreshedAccessToken,
          'refreshToken': 'refresh-2',
          'expiresIn': 900,
          'tokenType': 'Bearer',
        },
        'error': null,
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );
    adapter.enqueueJson(
      path: '/accounts',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{'ok': true},
        'error': null,
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );

    await mainDio.get<dynamic>('/accounts');

    expect(adapter.requestsForPath('/auth/refresh'), hasLength(1));
    expect(
      adapter.requestsForPath('/accounts').single.headers['Authorization'],
      'Bearer $refreshedAccessToken',
    );
    expect(values['refresh_token'], 'refresh-2');
  });

  test('retries once after a 401 response', () async {
    values['access_token'] = _jwt(
      expiration: DateTime.now().toUtc().add(const Duration(minutes: 10)),
    );
    values['refresh_token'] = 'refresh-1';
    final refreshedAccessToken = _jwt(
      expiration: DateTime.now().toUtc().add(const Duration(minutes: 15)),
    );

    adapter.enqueueJson(
      path: '/protected',
      statusCode: 401,
      body: <String, dynamic>{
        'success': false,
        'data': null,
        'error': <String, dynamic>{
          'code': 'ACCESS_TOKEN_EXPIRED',
          'message': 'expired',
          'details': <String>[],
        },
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );
    adapter.enqueueJson(
      path: '/protected',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{'ok': true},
        'error': null,
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );
    adapter.enqueueJson(
      path: '/auth/refresh',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{
          'accessToken': refreshedAccessToken,
          'refreshToken': 'refresh-2',
          'expiresIn': 900,
          'tokenType': 'Bearer',
        },
        'error': null,
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );

    final response = await mainDio.get<dynamic>('/protected');

    expect(response.statusCode, 200);
    expect(adapter.requestsForPath('/protected'), hasLength(2));
    expect(adapter.requestsForPath('/auth/refresh'), hasLength(1));
  });
}

String _jwt({required DateTime expiration}) {
  final header = base64Url.encode(utf8.encode('{"alg":"HS512","typ":"JWT"}'));
  final payload = base64Url.encode(
    utf8.encode(
      jsonEncode(<String, int>{
        'exp': expiration.millisecondsSinceEpoch ~/ 1000,
      }),
    ),
  );

  return '$header.$payload.signature';
}
