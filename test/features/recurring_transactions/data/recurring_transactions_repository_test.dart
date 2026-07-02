import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/network/dio_client.dart';
import 'package:saveapenny/features/recurring_transactions/data/recurring_transactions_api.dart';
import 'package:saveapenny/features/recurring_transactions/data/recurring_transactions_repository.dart';
import 'package:saveapenny/features/recurring_transactions/domain/recurring_transaction.dart';
import 'package:saveapenny/features/recurring_transactions/domain/recurring_transaction_history_entry.dart';

import '../../../support/test_http_client_adapter.dart';

void main() {
  late TestHttpClientAdapter adapter;
  late RecurringTransactionsRepositoryImpl repository;

  setUp(() {
    adapter = TestHttpClientAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.saveapenny.app/api/v1'))
      ..httpClientAdapter = adapter;
    repository = RecurringTransactionsRepositoryImpl(
      RecurringTransactionsApi(ApiClient(dio)),
    );
  });

  test('lists recurring transactions and maps enums', () async {
    adapter.enqueueJson(
      path: '/automations/recurring-transactions',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{
          'items': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'r-1',
              'userId': 'u-1',
              'accountId': 'a-1',
              'categoryId': 'c-1',
              'type': 'EXPENSE',
              'amount': 49.99,
              'frequency': 'MONTHLY',
              'nextRunDate': '2026-07-15T00:00:00.000',
              'status': 'ACTIVE',
              'name': 'Netflix',
              'description': 'Streaming',
              'startDate': '2026-07-01T00:00:00.000',
              'endDate': null,
              'lastRunAt': null,
              'classification': 'SUBSCRIPTION',
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
    expect(page.items.single.type, RecurringTransactionType.expense);
    expect(page.items.single.frequency, RecurringFrequency.monthly);
    expect(page.items.single.status, RecurringStatus.active);
    expect(
      page.items.single.classification,
      RecurringClassification.subscription,
    );
  });

  test('loads upcoming recurring runs', () async {
    adapter.enqueueJson(
      path: '/automations/recurring-transactions/upcoming',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': <Map<String, dynamic>>[
          <String, dynamic>{
            'recurringTransactionId': 'r-1',
            'name': 'Netflix',
            'amount': 49.99,
            'scheduledDate': '2026-07-15T00:00:00.000',
          },
        ],
        'error': null,
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );

    final upcoming = await repository.upcoming();

    expect(upcoming, hasLength(1));
    expect(upcoming.single.name, 'Netflix');
    expect(upcoming.single.amount, 49.99);
  });

  test('loads execution history and maps statuses', () async {
    adapter.enqueueJson(
      path: '/automations/recurring-transactions/r-1/history',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{
          'items': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'h-1',
              'recurringTransactionId': 'r-1',
              'status': 'SKIPPED',
              'scheduledDate': '2026-07-15T00:00:00.000',
              'executedAt': '2026-07-15T08:00:00Z',
              'transactionId': null,
              'failureReason': 'Account inactive',
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
        'timestamp': '2026-07-15T08:00:00Z',
      },
    );

    final page = await repository.history('r-1');

    expect(page.items, hasLength(1));
    expect(page.items.single.status, RecurringExecutionStatus.skipped);
    expect(page.items.single.failureReason, 'Account inactive');
  });

  test('create surfaces invalid next run date failures', () async {
    adapter.enqueueJson(
      path: '/automations/recurring-transactions',
      statusCode: 200,
      body: <String, dynamic>{
        'success': false,
        'data': null,
        'error': <String, dynamic>{
          'code': 'INVALID_RECURRING_TRANSACTION_NEXT_RUN_DATE',
          'message': 'Next run date is in the past',
          'details': <String>[],
        },
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );

    await expectLater(
      () => repository.create(
        accountId: 'a-1',
        categoryId: 'c-1',
        type: RecurringTransactionType.expense,
        amount: 49.99,
        frequency: RecurringFrequency.monthly,
        nextRunDate: DateTime.parse('2026-06-01T00:00:00Z'),
      ),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.code,
          'code',
          ApiErrorCode.invalidRecurringTransactionNextRunDate,
        ),
      ),
    );
  });
}
