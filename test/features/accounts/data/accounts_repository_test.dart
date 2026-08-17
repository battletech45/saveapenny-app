import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/network/dio_client.dart';
import 'package:saveapenny/features/accounts/data/accounts_api.dart';
import 'package:saveapenny/features/accounts/data/accounts_repository.dart';
import 'package:saveapenny/features/accounts/domain/account.dart';

import '../../../support/test_http_client_adapter.dart';

void main() {
  late TestHttpClientAdapter adapter;
  late AccountsRepositoryImpl repository;

  setUp(() {
    adapter = TestHttpClientAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.saveapenny.app/api/v1'))
      ..httpClientAdapter = adapter;
    repository = AccountsRepositoryImpl(AccountsApi(ApiClient(dio)));
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
}
