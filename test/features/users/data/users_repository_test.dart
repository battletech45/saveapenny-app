import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/network/dio_client.dart';
import 'package:saveapenny/features/users/data/users_api.dart';
import 'package:saveapenny/features/users/data/users_repository.dart';

import '../../../support/test_http_client_adapter.dart';

void main() {
  late TestHttpClientAdapter adapter;
  late UsersRepositoryImpl repository;

  setUp(() {
    adapter = TestHttpClientAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.saveapenny.app/api/v1'))
      ..httpClientAdapter = adapter;
    repository = UsersRepositoryImpl(UsersApi(ApiClient(dio)));
  });

  test('gets the current user profile', () async {
    adapter.enqueueJson(
      path: '/users/me',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{
          'id': 'u-1',
          'email': 'altay@example.com',
          'fullName': 'Altay Yilmaz',
          'active': true,
          'createdAt': '2026-06-09T12:00:00Z',
          'updatedAt': '2026-06-10T15:30:00Z',
        },
        'error': null,
        'timestamp': '2026-06-10T15:30:00Z',
      },
    );

    final profile = await repository.getCurrentUser();

    expect(profile.email, 'altay@example.com');
    expect(profile.fullName, 'Altay Yilmaz');
    expect(profile.active, isTrue);
  });

  test('change password surfaces password reuse failures', () async {
    adapter.enqueueJson(
      path: '/users/me/password',
      statusCode: 200,
      body: <String, dynamic>{
        'success': false,
        'data': null,
        'error': <String, dynamic>{
          'code': 'PASSWORD_REUSE_NOT_ALLOWED',
          'message': 'Password matches a previously used password',
          'details': <String>[],
        },
        'timestamp': '2026-06-10T15:30:00Z',
      },
    );

    await expectLater(
      () => repository.changePassword(
        currentPassword: 'old-secret',
        newPassword: 'StrongPass123!',
      ),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.code,
          'code',
          ApiErrorCode.passwordReuseNotAllowed,
        ),
      ),
    );
  });
}
