import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/network/dio_client.dart';
import 'package:saveapenny/features/reports/data/reports_api.dart';
import 'package:saveapenny/features/reports/data/reports_repository.dart';

import '../../../support/test_http_client_adapter.dart';

void main() {
  late TestHttpClientAdapter adapter;
  late ReportsRepositoryImpl repository;

  setUp(() {
    adapter = TestHttpClientAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.saveapenny.app/api/v1'))
      ..httpClientAdapter = adapter;
    repository = ReportsRepositoryImpl(ReportsApi(ApiClient(dio)));
  });

  test(
    'monthlySummary maps the monthly summary response into domain',
    () async {
      adapter.enqueueJson(
        path: '/reports/monthly-summary',
        statusCode: 200,
        body: <String, dynamic>{
          'success': true,
          'data': <String, dynamic>{
            'startDate': '2026-06-01',
            'endDate': '2026-06-30',
            'totalIncome': 2500,
            'totalExpense': 900,
            'netSavings': 1600,
          },
          'error': null,
          'timestamp': '2026-06-30T12:00:00Z',
        },
      );

      final summary = await repository.monthlySummary(
        from: DateTime.utc(2026, 6, 1),
        to: DateTime.utc(2026, 6, 30),
      );

      expect(summary.totalIncome, 2500);
      expect(summary.totalExpense, 900);
      expect(summary.netSavings, 1600);
    },
  );

  test('categorySpending maps the response list into domain objects', () async {
    adapter.enqueueJson(
      path: '/reports/category-spending',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': <Map<String, dynamic>>[
          <String, dynamic>{
            'categoryId': 'c-1',
            'categoryName': 'Groceries',
            'totalAmount': 450,
            'usagePercentage': 56.25,
          },
        ],
        'error': null,
        'timestamp': '2026-06-30T12:00:00Z',
      },
    );

    final items = await repository.categorySpending(
      from: DateTime.utc(2026, 6, 1),
      to: DateTime.utc(2026, 6, 30),
    );

    expect(items, hasLength(1));
    expect(items.single.categoryName, 'Groceries');
    expect(items.single.usagePercentage, 56.25);
  });

  test(
    'monthlySummary throws a mapped Failure on a success:false envelope',
    () async {
      adapter.enqueueJson(
        path: '/reports/monthly-summary',
        statusCode: 200,
        body: <String, dynamic>{
          'success': false,
          'data': null,
          'error': <String, dynamic>{
            'code': 'VALIDATION_FAILED',
            'message': 'from: must not be null',
            'details': <String>['from: must not be null'],
          },
          'timestamp': '2026-06-30T12:00:00Z',
        },
      );

      await expectLater(
        () => repository.monthlySummary(
          from: DateTime.utc(2026, 6, 1),
          to: DateTime.utc(2026, 6, 30),
        ),
        throwsA(
          isA<ApiFailure>().having(
            (failure) => failure.code,
            'code',
            ApiErrorCode.validationFailed,
          ),
        ),
      );
    },
  );

  test('categorySpending throws a mapped Failure on a DioException', () async {
    adapter.enqueueJson(
      path: '/reports/category-spending',
      statusCode: 500,
      body: <String, dynamic>{
        'success': false,
        'data': null,
        'error': null,
        'timestamp': '2026-06-30T12:00:00Z',
      },
    );

    await expectLater(
      () => repository.categorySpending(
        from: DateTime.utc(2026, 6, 1),
        to: DateTime.utc(2026, 6, 30),
      ),
      throwsA(isA<Failure>()),
    );
  });
}
