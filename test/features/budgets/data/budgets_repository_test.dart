import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/network/dio_client.dart';
import 'package:saveapenny/features/budgets/data/budgets_api.dart';
import 'package:saveapenny/features/budgets/data/budgets_repository.dart';
import 'package:saveapenny/features/budgets/domain/budget.dart';
import 'package:saveapenny/features/budgets/domain/budget_status.dart';

import '../../../support/test_http_client_adapter.dart';

void main() {
  late TestHttpClientAdapter adapter;
  late BudgetsRepositoryImpl repository;

  setUp(() {
    adapter = TestHttpClientAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.saveapenny.app/api/v1'))
      ..httpClientAdapter = adapter;
    repository = BudgetsRepositoryImpl(BudgetsApi(ApiClient(dio)));
  });

  test('lists budgets and maps period values', () async {
    adapter.enqueueJson(
      path: '/budgets',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{
          'items': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'b-1',
              'userId': 'u-1',
              'categoryId': 'c-1',
              'amount': 500,
              'period': 'MONTHLY',
              'startDate': '2026-06-01T00:00:00.000',
              'endDate': '2026-06-30T00:00:00.000',
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
    expect(page.items.single.period, BudgetPeriod.monthly);
    expect(page.items.single.amount, 500);
  });

  test('loads budget status and maps health values', () async {
    adapter.enqueueJson(
      path: '/budgets/b-1/status',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{
          'category': 'Groceries',
          'budgetAmount': 500,
          'spentAmount': 420,
          'remainingAmount': 80,
          'usagePercentage': 84,
          'status': 'WARNING',
        },
        'error': null,
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );

    final status = await repository.status('b-1');

    expect(status.category, 'Groceries');
    expect(status.status, BudgetHealth.warning);
    expect(status.usagePercentage, 84);
  });

  test('create surfaces duplicate-budget failures', () async {
    adapter.enqueueJson(
      path: '/budgets',
      statusCode: 200,
      body: <String, dynamic>{
        'success': false,
        'data': null,
        'error': <String, dynamic>{
          'code': 'BUDGET_ALREADY_EXISTS',
          'message': 'Duplicate budget',
          'details': <String>[],
        },
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );

    await expectLater(
      () => repository.create(
        categoryId: 'c-1',
        amount: 500,
        period: BudgetPeriod.monthly,
        startDate: DateTime.parse('2026-06-01T00:00:00Z'),
        endDate: DateTime.parse('2026-06-30T00:00:00Z'),
      ),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.code,
          'code',
          ApiErrorCode.budgetAlreadyExists,
        ),
      ),
    );
  });

  test('update surfaces invalid date-range failures', () async {
    adapter.enqueueJson(
      path: '/budgets/b-1',
      statusCode: 200,
      body: <String, dynamic>{
        'success': false,
        'data': null,
        'error': <String, dynamic>{
          'code': 'INVALID_BUDGET_DATE_RANGE',
          'message': 'Invalid budget range',
          'details': <String>[],
        },
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );

    await expectLater(
      () => repository.update(
        budgetId: 'b-1',
        categoryId: 'c-1',
        amount: 500,
        period: BudgetPeriod.monthly,
        startDate: DateTime.parse('2026-06-30T00:00:00Z'),
        endDate: DateTime.parse('2026-06-01T00:00:00Z'),
      ),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.code,
          'code',
          ApiErrorCode.invalidBudgetDateRange,
        ),
      ),
    );
  });

  test('delete surfaces budget-not-found failures', () async {
    adapter.enqueueJson(
      path: '/budgets/b-1',
      statusCode: 200,
      body: <String, dynamic>{
        'success': false,
        'data': null,
        'error': <String, dynamic>{
          'code': 'BUDGET_NOT_FOUND',
          'message': 'Budget not found',
          'details': <String>[],
        },
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );

    await expectLater(
      () => repository.delete('b-1'),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.code,
          'code',
          ApiErrorCode.budgetNotFound,
        ),
      ),
    );
  });
}
