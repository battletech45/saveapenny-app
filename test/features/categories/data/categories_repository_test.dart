import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/network/dio_client.dart';
import 'package:saveapenny/features/categories/data/categories_api.dart';
import 'package:saveapenny/features/categories/data/categories_repository.dart';
import 'package:saveapenny/features/categories/domain/category.dart';

import '../../../support/test_http_client_adapter.dart';

void main() {
  late TestHttpClientAdapter adapter;
  late CategoriesRepositoryImpl repository;

  setUp(() {
    adapter = TestHttpClientAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.saveapenny.app/api/v1'))
      ..httpClientAdapter = adapter;
    repository = CategoriesRepositoryImpl(CategoriesApi(ApiClient(dio)));
  });

  test('lists categories from the paginated payload', () async {
    adapter.enqueueJson(
      path: '/categories',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{
          'items': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'c-1',
              'name': 'Groceries',
              'type': 'SYSTEM',
              'icon': 'shopping',
              'color': '#FF0000',
              'parentId': null,
              'active': true,
              'createdAt': '2026-06-09T12:00:00Z',
              'updatedAt': '2026-06-09T12:00:00Z',
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
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );

    final categories = await repository.list();

    expect(categories, hasLength(1));
    expect(categories.first.type, CategoryType.system);
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
      () => repository.create(name: ''),
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
