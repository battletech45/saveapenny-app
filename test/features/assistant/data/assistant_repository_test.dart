import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/network/dio_client.dart';
import 'package:saveapenny/features/assistant/data/assistant_api.dart';
import 'package:saveapenny/features/assistant/data/assistant_repository.dart';

import '../../../support/test_http_client_adapter.dart';

void main() {
  late TestHttpClientAdapter adapter;
  late AssistantRepositoryImpl repository;

  setUp(() {
    adapter = TestHttpClientAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080/api/v1'))
      ..httpClientAdapter = adapter;
    repository = AssistantRepositoryImpl(AssistantApi(ApiClient(dio)));
  });

  test('chat maps the assistant reply payload', () async {
    adapter.enqueueJson(
      path: '/assistant/chat',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{
          'sessionId': '8e0df436-64d9-49c7-b0be-183b4df62111',
          'reply': 'Dining out is leading your spending this month.',
          'disclaimer':
              'This assistant provides general budgeting guidance, not financial, tax, or legal advice.',
        },
        'error': null,
        'timestamp': '2026-07-14T10:00:00Z',
      },
    );

    final response = await repository.chat(
      message: 'Where am I spending the most this month?',
    );

    expect(response.sessionId, '8e0df436-64d9-49c7-b0be-183b4df62111');
    expect(response.reply, contains('Dining out'));
  });

  test('chat throws typed failure when assistant processing fails', () async {
    adapter.enqueueJson(
      path: '/assistant/chat',
      statusCode: 502,
      body: <String, dynamic>{
        'success': false,
        'data': null,
        'error': <String, dynamic>{
          'code': 'ASSISTANT_PROCESSING_FAILED',
          'message': 'Provider unavailable.',
          'details': <String>[],
        },
        'timestamp': '2026-07-14T10:00:00Z',
      },
    );

    await expectLater(
      repository.chat(message: 'Help me budget better'),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.code,
          'code',
          ApiErrorCode.assistantProcessingFailed,
        ),
      ),
    );
  });
}
