import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/network/dio_client.dart';
import 'package:saveapenny/core/storage/response_cache_store.dart';
import 'package:saveapenny/features/categories/data/categories_api.dart';
import 'package:saveapenny/features/categories/data/categories_repository.dart';
import 'package:saveapenny/features/categories/domain/category.dart';

import '../../../support/test_http_client_adapter.dart';
import '../../../support/test_response_cache_store.dart';

void _enqueueBothLists(TestHttpClientAdapter adapter) {
  adapter.enqueueJson(
    path: '/categories',
    statusCode: 200,
    body: <String, dynamic>{
      'success': true,
      'data': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'c-1',
          'name': 'Salary',
          'type': 'INCOME',
          'icon': 'salary',
          'color': '#00FF00',
          'createdAt': '2026-06-09T12:00:00Z',
          'updatedAt': '2026-06-09T12:00:00Z',
        },
      ],
      'error': null,
      'timestamp': '2026-06-09T12:00:00Z',
    },
  );
  adapter.enqueueJson(
    path: '/categories',
    statusCode: 200,
    body: <String, dynamic>{
      'success': true,
      'data': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'c-2',
          'name': 'Groceries',
          'type': 'EXPENSE',
          'icon': 'shopping',
          'color': '#FF0000',
          'createdAt': '2026-06-09T12:00:00Z',
          'updatedAt': '2026-06-09T12:00:00Z',
        },
      ],
      'error': null,
      'timestamp': '2026-06-09T12:00:00Z',
    },
  );
}

void main() {
  late TestHttpClientAdapter adapter;
  late ResponseCacheStore cache;
  late CategoriesRepositoryImpl repository;

  setUp(() {
    adapter = TestHttpClientAdapter();
    cache = createTestResponseCacheStore();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.saveapenny.app/api/v1'))
      ..httpClientAdapter = adapter;
    repository = CategoriesRepositoryImpl(CategoriesApi(ApiClient(dio)), cache);
  });

  test('lists categories by merging INCOME and EXPENSE responses', () async {
    adapter.enqueueJson(
      path: '/categories',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'c-1',
            'name': 'Salary',
            'type': 'INCOME',
            'icon': 'salary',
            'color': '#00FF00',
            'createdAt': '2026-06-09T12:00:00Z',
            'updatedAt': '2026-06-09T12:00:00Z',
          },
        ],
        'error': null,
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );

    adapter.enqueueJson(
      path: '/categories',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'c-2',
            'name': 'Groceries',
            'type': 'EXPENSE',
            'icon': 'shopping',
            'color': '#FF0000',
            'createdAt': '2026-06-09T12:00:00Z',
            'updatedAt': '2026-06-09T12:00:00Z',
          },
        ],
        'error': null,
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );

    final categories = await repository.list();

    expect(categories, hasLength(2));
    final income = categories.firstWhere((c) => c.type == CategoryType.income);
    final expense = categories.firstWhere(
      (c) => c.type == CategoryType.expense,
    );
    expect(income.name, 'Salary');
    expect(expense.name, 'Groceries');
  });

  test('create surfaces validation failures', () async {
    adapter.enqueueJson(
      path: '/categories',
      statusCode: 200,
      body: <String, dynamic>{
        'success': false,
        'data': null,
        'error': <String, dynamic>{
          'code': 'VALIDATION_FAILED',
          'message': 'Invalid category',
          'details': <String>['name: must not be blank'],
        },
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );

    await expectLater(
      () => repository.create(name: '', type: CategoryType.expense),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.code,
          'code',
          ApiErrorCode.validationFailed,
        ),
      ),
    );
  });

  test('sends type query parameter on list calls', () async {
    adapter.enqueueJson(
      path: '/categories',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': <Map<String, dynamic>>[],
        'error': null,
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );

    adapter.enqueueJson(
      path: '/categories',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': <Map<String, dynamic>>[],
        'error': null,
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );

    await repository.list();

    expect(adapter.requests, hasLength(2));
    final queries = adapter.requests
        .map((r) => r.queryParameters)
        .toList(growable: false);
    expect(
      queries,
      containsAll(<Map<String, dynamic>>[
        <String, String>{'type': 'INCOME'},
        <String, String>{'type': 'EXPENSE'},
      ]),
    );
  });

  test(
    'list falls back to the cached merged list on a network failure',
    () async {
      _enqueueBothLists(adapter);
      final first = await repository.list();
      expect(first, hasLength(2));

      adapter.enqueueError(
        path: '/categories',
        type: DioExceptionType.connectionError,
      );
      final fallback = await repository.list();

      expect(fallback, hasLength(2));
    },
  );

  test('create invalidates the cached category list', () async {
    _enqueueBothLists(adapter);
    await repository.list();

    adapter.enqueueJson(
      path: '/categories',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{
          'id': 'c-3',
          'name': 'Bonus',
          'type': 'INCOME',
          'icon': null,
          'color': null,
          'createdAt': '2026-06-09T12:00:00Z',
          'updatedAt': '2026-06-09T12:00:00Z',
        },
        'error': null,
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );
    await repository.create(name: 'Bonus', type: CategoryType.income);

    expect(await cache.read('categories:list'), isNull);
  });
}
