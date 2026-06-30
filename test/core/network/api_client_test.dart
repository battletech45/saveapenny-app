import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/network/dio_client.dart';

import '../../support/test_http_client_adapter.dart';

void main() {
  late TestHttpClientAdapter adapter;
  late Dio dio;
  late ApiClient client;

  setUp(() {
    adapter = TestHttpClientAdapter();
    dio = Dio(BaseOptions(baseUrl: 'https://api.saveapenny.app/api/v1'))
      ..httpClientAdapter = adapter;
    client = ApiClient(dio);
  });

  test('returns parsed data from a success envelope', () async {
    adapter.enqueueJson(
      path: '/profile',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{'name': 'Altay'},
        'error': null,
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );

    final result = await client.send<String>(
      call: (dio) => dio.get<dynamic>('/profile'),
      fromData: (data) => (data as Map<String, dynamic>)['name'] as String,
    );

    expect(result, 'Altay');
  });

  test('maps envelope errors to Failure', () async {
    adapter.enqueueJson(
      path: '/profile',
      statusCode: 200,
      body: <String, dynamic>{
        'success': false,
        'data': null,
        'error': <String, dynamic>{
          'code': 'VALIDATION_FAILED',
          'message': 'Bad input',
          'details': <String>['field is required'],
        },
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );

    await expectLater(
      () => client.send<void>(
        call: (dio) => dio.get<dynamic>('/profile'),
        fromData: (_) {},
      ),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.code,
          'code',
          ApiErrorCode.validationFailed,
        ),
      ),
    );
  });
}
