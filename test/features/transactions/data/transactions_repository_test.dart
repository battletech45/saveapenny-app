import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/network/dio_client.dart';
import 'package:saveapenny/features/transactions/data/transactions_api.dart';
import 'package:saveapenny/features/transactions/data/transactions_repository.dart';
import 'package:saveapenny/features/transactions/domain/transaction.dart';

import '../../../support/test_http_client_adapter.dart';

void main() {
  late TestHttpClientAdapter adapter;
  late TransactionsRepositoryImpl repository;

  setUp(() {
    adapter = TestHttpClientAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.saveapenny.app/api/v1'))
      ..httpClientAdapter = adapter;
    repository = TransactionsRepositoryImpl(TransactionsApi(ApiClient(dio)));
  });

  test('list maps the paginated response and transaction type', () async {
    adapter.enqueueJson(
      path: '/transactions',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{
          'items': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 't-1',
              'userId': 'u-1',
              'accountId': 'a-1',
              'categoryId': 'c-1',
              'type': 'EXPENSE',
              'amount': 49.99,
              'currency': 'USD',
              'description': 'Groceries',
              'transactionDate': '2026-06-09T00:00:00.000',
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

    final page = await repository.list();

    expect(page.items, hasLength(1));
    expect(page.items.single.type, TransactionType.expense);
    expect(page.items.single.amount, 49.99);
  });

  test(
    'create surfaces a mapped Failure on a success:false envelope',
    () async {
      adapter.enqueueJson(
        path: '/transactions',
        statusCode: 200,
        body: <String, dynamic>{
          'success': false,
          'data': null,
          'error': <String, dynamic>{
            'code': 'VALIDATION_FAILED',
            'message': 'amount: must not be null',
            'details': <String>['amount: must not be null'],
          },
          'timestamp': '2026-06-09T12:00:00Z',
        },
      );

      await expectLater(
        () => repository.create(
          accountId: 'a-1',
          categoryId: 'c-1',
          type: TransactionType.expense,
          amount: 49.99,
          currency: 'USD',
          transactionDate: DateTime.utc(2026, 6, 9),
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

  test('delete surfaces a mapped Failure on a DioException', () async {
    adapter.enqueueJson(
      path: '/transactions/t-1',
      statusCode: 404,
      body: <String, dynamic>{
        'success': false,
        'data': null,
        'error': <String, dynamic>{
          'code': 'TRANSACTION_NOT_FOUND',
          'message': 'Transaction not found',
          'details': <String>[],
        },
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );

    await expectLater(
      () => repository.delete('t-1'),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.code,
          'code',
          ApiErrorCode.transactionNotFound,
        ),
      ),
    );
  });
}
