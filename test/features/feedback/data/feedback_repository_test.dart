import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/network/dio_client.dart';
import 'package:saveapenny/features/feedback/data/feedback_api.dart';
import 'package:saveapenny/features/feedback/data/feedback_repository.dart';
import 'package:saveapenny/features/feedback/domain/feedback.dart';

import '../../../support/test_http_client_adapter.dart';

void main() {
  late TestHttpClientAdapter adapter;
  late FeedbackRepositoryImpl repository;

  setUp(() {
    adapter = TestHttpClientAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.saveapenny.app/api/v1'))
      ..httpClientAdapter = adapter;
    repository = FeedbackRepositoryImpl(FeedbackApi(ApiClient(dio)));
  });

  test('submit posts feedback and maps the created item', () async {
    adapter.enqueueJson(
      path: '/feedback',
      statusCode: 201,
      body: <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{
          'id': 'f-1',
          'userId': 'u-1',
          'type': 'FEATURE_REQUEST',
          'rating': 5,
          'message': 'Please add widgets.',
          'metadata': <String, dynamic>{
            'platform': 'ios',
            'appVersion': '1.0.0',
            'screen': 'profile',
          },
          'createdAt': '2026-07-31T10:00:00Z',
          'updatedAt': '2026-07-31T10:00:00Z',
        },
        'error': null,
        'timestamp': '2026-07-31T10:00:00Z',
      },
    );

    final feedback = await repository.submit(
      type: FeedbackType.featureRequest,
      rating: 5,
      message: 'Please add widgets.',
      metadata: <String, dynamic>{
        'platform': 'ios',
        'appVersion': '1.0.0',
        'screen': 'profile',
      },
    );

    final request = adapter.requestsForPath('/feedback').single;

    expect(feedback.type, FeedbackType.featureRequest);
    expect(feedback.rating, 5);
    expect(feedback.metadata?['screen'], 'profile');
    expect(request.data['type'], 'FEATURE_REQUEST');
    expect(request.data['rating'], 5);
    expect(request.data['message'], 'Please add widgets.');
  });

  test('list maps paginated feedback items', () async {
    adapter.enqueueJson(
      path: '/feedback',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{
          'items': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'f-1',
              'userId': 'u-1',
              'type': 'GENERAL',
              'rating': null,
              'message': 'Looks good.',
              'metadata': <String, dynamic>{'screen': 'profile'},
              'createdAt': '2026-07-31T10:00:00Z',
              'updatedAt': '2026-07-31T10:00:00Z',
            },
          ],
          'page': 0,
          'size': 20,
          'totalItems': 1,
          'totalPages': 1,
          'hasNext': false,
          'hasPrevious': false,
        },
        'error': null,
        'timestamp': '2026-07-31T10:00:00Z',
      },
    );

    final page = await repository.list(type: FeedbackType.general);
    final request = adapter.requestsForPath('/feedback').single;

    expect(page.items, hasLength(1));
    expect(page.items.single.type, FeedbackType.general);
    expect(page.items.single.message, 'Looks good.');
    expect(request.queryParameters['type'], 'GENERAL');
  });

  test('getById maps a single feedback item', () async {
    adapter.enqueueJson(
      path: '/feedback/f-1',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{
          'id': 'f-1',
          'userId': 'u-1',
          'type': 'BUG_REPORT',
          'rating': 2,
          'message': 'The screen freezes.',
          'metadata': <String, dynamic>{'screen': 'dashboard'},
          'createdAt': '2026-07-31T10:00:00Z',
          'updatedAt': '2026-07-31T10:00:00Z',
        },
        'error': null,
        'timestamp': '2026-07-31T10:00:00Z',
      },
    );

    final feedback = await repository.getById('f-1');

    expect(feedback.type, FeedbackType.bugReport);
    expect(feedback.message, 'The screen freezes.');
  });

  test('delete surfaces feedback-not-found failures', () async {
    adapter.enqueueJson(
      path: '/feedback/f-1',
      statusCode: 200,
      body: <String, dynamic>{
        'success': false,
        'data': null,
        'error': <String, dynamic>{
          'code': 'FEEDBACK_NOT_FOUND',
          'message': 'Feedback not found.',
          'details': <String>[],
        },
        'timestamp': '2026-07-31T10:00:00Z',
      },
    );

    await expectLater(
      () => repository.delete('f-1'),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.code,
          'code',
          ApiErrorCode.feedbackNotFound,
        ),
      ),
    );
  });
}
