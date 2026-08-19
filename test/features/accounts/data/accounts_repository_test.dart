import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/network/dio_client.dart';
import 'package:saveapenny/core/storage/response_cache_store.dart';
import 'package:saveapenny/features/accounts/data/accounts_api.dart';
import 'package:saveapenny/features/accounts/data/accounts_repository.dart';
import 'package:saveapenny/features/accounts/domain/account.dart';

import '../../../support/test_http_client_adapter.dart';
import '../../../support/test_response_cache_store.dart';

Map<String, dynamic> _accountJson({
  String id = 'a-1',
  String name = 'Main bank',
}) {
  return <String, dynamic>{
    'id': id,
    'name': name,
    'type': 'BANK',
    'currency': 'TRY',
    'balance': 1250,
    'initialBalance': 1000,
    'active': true,
    'createdAt': '2026-06-09T12:00:00Z',
    'updatedAt': '2026-06-09T12:00:00Z',
  };
}

Map<String, dynamic> _accountsPage(List<Map<String, dynamic>> items) {
  return <String, dynamic>{
    'items': items,
    'page': 0,
    'size': 20,
    'totalItems': items.length,
    'totalPages': 1,
    'hasNext': false,
    'hasPrevious': false,
  };
}

void main() {
  late TestHttpClientAdapter adapter;
  late ResponseCacheStore cache;
  late AccountsRepositoryImpl repository;

  setUp(() {
    adapter = TestHttpClientAdapter();
    cache = createTestResponseCacheStore();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.saveapenny.app/api/v1'))
      ..httpClientAdapter = adapter;
    repository = AccountsRepositoryImpl(AccountsApi(ApiClient(dio)), cache);
  });

  test('lists accounts from the paginated payload', () async {
    adapter.enqueueJson(
      path: '/accounts',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{
          'items': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'a-1',
              'name': 'Main bank',
              'type': 'BANK',
              'currency': 'TRY',
              'balance': 1250,
              'initialBalance': 1000,
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

    final accounts = await repository.list();

    expect(accounts, hasLength(1));
    expect(accounts.first.type, AccountType.bank);
  });

  test(
    'create parses a fresh CREDIT account with no open statement yet',
    () async {
      // Backend only populates currentStatementBalance/minimumPaymentDue/
      // statementDate/paymentDueDate/statementStatus once a statement
      // exists; a just-created account has none yet, so these come back
      // null even though creditLimit/apr/statementDay are always set.
      adapter.enqueueJson(
        path: '/accounts',
        statusCode: 200,
        body: <String, dynamic>{
          'success': true,
          'data': <String, dynamic>{
            'id': 'a-2',
            'name': 'New credit card',
            'type': 'CREDIT',
            'currency': 'TRY',
            'balance': 0,
            'initialBalance': 0,
            'active': true,
            'createdAt': '2026-06-09T12:00:00Z',
            'updatedAt': '2026-06-09T12:00:00Z',
            'creditCard': <String, dynamic>{
              'creditLimit': 5000,
              'apr': 24.99,
              'statementDay': 15,
              'gracePeriodDays': 21,
              'availableCredit': 5000,
              'currentStatementBalance': null,
              'minimumPaymentDue': null,
              'statementDate': null,
              'paymentDueDate': null,
              'statementStatus': null,
            },
          },
          'error': null,
          'timestamp': '2026-06-09T12:00:00Z',
        },
      );

      final account = await repository.create(
        name: 'New credit card',
        type: AccountType.credit,
        currency: 'TRY',
        initialBalance: 0,
        creditLimit: 5000,
        apr: 24.99,
        statementDay: 15,
      );

      expect(account.creditCard, isNotNull);
      expect(account.creditCard!.availableCredit, 5000);
      expect(account.creditCard!.statementDate, isNull);
      expect(account.creditCard!.statementStatus, isNull);
    },
  );

  test('create surfaces validation failures', () async {
    adapter.enqueueJson(
      path: '/accounts',
      statusCode: 200,
      body: <String, dynamic>{
        'success': false,
        'data': null,
        'error': <String, dynamic>{
          'code': 'VALIDATION_FAILED',
          'message': 'Invalid account',
          'details': <String>['name: must not be blank'],
        },
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );

    await expectLater(
      () => repository.create(
        name: '',
        type: AccountType.bank,
        currency: 'TRY',
        initialBalance: 0,
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

  test('list falls back to the cached accounts on a network failure', () async {
    adapter.enqueueJson(
      path: '/accounts',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': _accountsPage(<Map<String, dynamic>>[_accountJson()]),
        'error': null,
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );
    final first = await repository.list();
    expect(first, hasLength(1));

    adapter.enqueueError(
      path: '/accounts',
      type: DioExceptionType.connectionError,
    );
    final fallback = await repository.list();

    expect(fallback, hasLength(1));
    expect(fallback.single.name, 'Main bank');
  });

  test('list rethrows a network failure when nothing is cached yet', () async {
    adapter.enqueueError(
      path: '/accounts',
      type: DioExceptionType.connectionError,
    );

    await expectLater(() => repository.list(), throwsA(isA<NetworkFailure>()));
  });

  test('list does not fall back to cache for a non-network failure', () async {
    adapter.enqueueJson(
      path: '/accounts',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': _accountsPage(<Map<String, dynamic>>[_accountJson()]),
        'error': null,
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );
    await repository.list();

    adapter.enqueueJson(
      path: '/accounts',
      statusCode: 200,
      body: <String, dynamic>{
        'success': false,
        'data': null,
        'error': <String, dynamic>{
          'code': 'INTERNAL_ERROR',
          'message': 'boom',
          'details': <String>[],
        },
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );

    await expectLater(() => repository.list(), throwsA(isA<ApiFailure>()));
  });

  test('create invalidates the cached account list', () async {
    adapter.enqueueJson(
      path: '/accounts',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': _accountsPage(<Map<String, dynamic>>[_accountJson()]),
        'error': null,
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );
    await repository.list();

    adapter.enqueueJson(
      path: '/accounts',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': _accountJson(id: 'a-2', name: 'New savings'),
        'error': null,
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );
    await repository.create(
      name: 'New savings',
      type: AccountType.savings,
      currency: 'TRY',
      initialBalance: 0,
    );

    expect(await cache.read('accounts:list'), isNull);
  });

  test('lastSyncedAt reflects the most recent successful list call', () async {
    expect(await repository.lastSyncedAt(), isNull);

    adapter.enqueueJson(
      path: '/accounts',
      statusCode: 200,
      body: <String, dynamic>{
        'success': true,
        'data': _accountsPage(<Map<String, dynamic>>[_accountJson()]),
        'error': null,
        'timestamp': '2026-06-09T12:00:00Z',
      },
    );
    await repository.list();

    final syncedAt = await repository.lastSyncedAt();
    expect(syncedAt, isNotNull);
    expect(
      syncedAt!.difference(DateTime.now()).abs(),
      lessThan(const Duration(seconds: 5)),
    );
  });
}
