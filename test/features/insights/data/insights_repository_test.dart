import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/network/dio_client.dart';
import 'package:saveapenny/features/insights/data/insights_api.dart';
import 'package:saveapenny/features/insights/data/insights_repository.dart';
import 'package:saveapenny/features/insights/domain/insight.dart';

import '../../../support/test_http_client_adapter.dart';

void main() {
  late TestHttpClientAdapter adapter;
  late InsightsRepositoryImpl repository;

  setUp(() {
    adapter = TestHttpClientAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.saveapenny.app/api/v1'))
      ..httpClientAdapter = adapter;
    repository = InsightsRepositoryImpl(InsightsApi(ApiClient(dio)));
  });

  test('list maps paginated insights into domain objects', () async {
    adapter.enqueueJson(
      path: '/insights',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{
          'items': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'ins-1',
              'type': 'ANOMALY',
              'title': 'Large grocery purchase',
              'summary': 'One transaction was much larger than usual.',
              'detail': 'Check if this was a one-off stock-up.',
              'categoryId': 'cat-1',
              'severity': 'WARNING',
              'metadata': '{"amount":"950"}',
              'read': false,
              'dismissed': false,
              'generatedAt': '2026-07-12T10:00:00Z',
              'createdAt': '2026-07-12T10:00:00Z',
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
        'timestamp': '2026-07-12T10:00:00Z',
      },
    );

    final response = await repository.list();

    expect(response.items, hasLength(1));
    expect(response.items.single.type, InsightType.anomaly);
    expect(response.items.single.severity, InsightSeverity.warning);
    expect(response.items.single.read, isFalse);
  });

  test('list throws typed failure on backend error', () async {
    adapter.enqueueJson(
      path: '/insights',
      statusCode: 404,
      body: <String, dynamic>{
        'success': false,
        'data': null,
        'error': <String, dynamic>{
          'code': 'INSIGHT_NOT_FOUND',
          'message': 'Insight not found.',
          'details': <String>[],
        },
        'timestamp': '2026-07-12T10:00:00Z',
      },
    );

    await expectLater(
      repository.list(),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.code,
          'code',
          ApiErrorCode.insightNotFound,
        ),
      ),
    );
  });

  test(
    'list prefers items, totalItems, and read over legacy aliases',
    () async {
      adapter.enqueueJson(
        path: '/insights',
        statusCode: 200,
        body: <String, dynamic>{
          'success': true,
          'data': <String, dynamic>{
            'items': <Map<String, dynamic>>[
              <String, dynamic>{
                'id': 'ins-primary',
                'type': 'TREND',
                'title': 'Primary item',
                'summary': 'Parsed from items.',
                'detail': null,
                'categoryId': null,
                'severity': 'INFO',
                'metadata': null,
                'read': false,
                'isRead': true,
                'dismissed': false,
                'generatedAt': '2026-07-12T10:00:00Z',
                'createdAt': '2026-07-12T10:00:00Z',
              },
            ],
            'insights': <Map<String, dynamic>>[
              <String, dynamic>{
                'id': 'ins-legacy',
                'type': 'ANOMALY',
                'title': 'Legacy item',
                'summary': 'Should be ignored.',
                'detail': null,
                'categoryId': null,
                'severity': 'WARNING',
                'metadata': null,
                'read': true,
                'isRead': true,
                'dismissed': false,
                'generatedAt': '2026-07-11T10:00:00Z',
                'createdAt': '2026-07-11T10:00:00Z',
              },
            ],
            'page': 0,
            'size': 20,
            'totalItems': 1,
            'totalElements': 99,
            'totalPages': 1,
            'hasNext': false,
            'hasPrevious': false,
          },
          'error': null,
          'timestamp': '2026-07-12T10:00:00Z',
        },
      );

      final response = await repository.list();

      expect(response.items, hasLength(1));
      expect(response.items.single.id, 'ins-primary');
      expect(response.items.single.read, isFalse);
      expect(response.totalItems, 1);
    },
  );
}
